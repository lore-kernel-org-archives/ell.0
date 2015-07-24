Content-Type: multipart/mixed; boundary="===============0989699583115890171=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 02/17] checksum: Add l_checksum_clone API.
Date: Fri, 24 Jul 2015 05:26:43 +0200
Message-ID: <1437708410-28075-2-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1437708410-28075-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0989699583115890171==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

In the kernel API we use and also in GLib's API the l_checksum_get_digest()
equivalents can only be called once on each object meaning that in a
situation when multiple digest values at different points of a
running stream are needed the API becomes impractical.  The new _clone()
call returns a clone of the checksum's state at the current time, on
which get_digest() can be called.
---
 ell/checksum.c | 24 ++++++++++++++++++++++++
 ell/checksum.h |  1 +
 2 files changed, 25 insertions(+)

diff --git a/ell/checksum.c b/ell/checksum.c
index 882f5f6..7604ee0 100644
--- a/ell/checksum.c
+++ b/ell/checksum.c
@@ -242,6 +242,30 @@ struct l_checksum *l_checksum_new_hmac(enum l_checksum=
_type type,
 }
 =

 /**
+ * l_checksum_clone:
+ * @checksum: parent checksum object
+ *
+ * Creates a new checksum with an independent copy of parent @checksum's
+ * state.  l_checksum_get_digest can then be called on the parent or the
+ * clone without affecting the state of the other object.
+ **/
+LIB_EXPORT struct l_checksum *l_checksum_clone(struct l_checksum *checksum)
+{
+	struct l_checksum *clone;
+
+	clone =3D l_new(struct l_checksum, 1);
+	clone->sk =3D accept4(checksum->sk, NULL, 0, SOCK_CLOEXEC);
+
+	if (clone->sk < 0) {
+		l_free(clone);
+		return NULL;
+	}
+
+	strcpy(clone->alg_name, checksum->alg_name);
+	return clone;
+}
+
+/**
  * l_checksum_free:
  * @checksum: checksum object
  *
diff --git a/ell/checksum.h b/ell/checksum.h
index c516580..34401a6 100644
--- a/ell/checksum.h
+++ b/ell/checksum.h
@@ -43,6 +43,7 @@ struct l_checksum *l_checksum_new(enum l_checksum_type ty=
pe);
 struct l_checksum *l_checksum_new_cmac_aes(const void *key, size_t key_len=
);
 struct l_checksum *l_checksum_new_hmac(enum l_checksum_type type,
 					const void *key, size_t key_len);
+struct l_checksum *l_checksum_clone(struct l_checksum *checksum);
 =

 void l_checksum_free(struct l_checksum *checksum);
 =

-- =

2.1.4


--===============0989699583115890171==--

