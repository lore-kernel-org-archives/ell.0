Content-Type: multipart/mixed; boundary="===============9029542717956796656=="
MIME-Version: 1.0
From: James Prestwood <james.prestwood@linux.intel.com>
Subject: [PATCH] checksum: add l_checksum_digest_length
Date: Tue, 15 Jan 2019 14:38:09 -0800
Message-ID: <20190115223809.5763-1-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============9029542717956796656==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

IWD needs the ability to get the digest length for a given checksum.
This was trivial to do in IWD, but since the we already have the
digest length in ELL its more fitting to add a proper ELL API.
---
 ell/checksum.c | 17 +++++++++++++++++
 ell/checksum.h |  2 ++
 ell/ell.sym    |  1 +
 3 files changed, 20 insertions(+)

diff --git a/ell/checksum.c b/ell/checksum.c
index 56b337c..0bb16fd 100644
--- a/ell/checksum.c
+++ b/ell/checksum.c
@@ -510,3 +510,20 @@ LIB_EXPORT bool l_checksum_cmac_aes_supported()
 =

 	return is_supported("cmac(aes)");
 }
+
+LIB_EXPORT ssize_t l_checksum_digest_length(enum l_checksum_type type)
+{
+	const char *name;
+	int i;
+
+	name =3D checksum_type_to_name(type);
+	if (!name)
+		return -EINVAL;
+
+	for (i =3D 0; checksum_info_table[i].name; i++) {
+		if (!strcmp(checksum_info_table[i].name, name))
+			return checksum_info_table[i].digest_len;
+	}
+
+	return 0;
+}
diff --git a/ell/checksum.h b/ell/checksum.h
index 05927b6..08d74b7 100644
--- a/ell/checksum.h
+++ b/ell/checksum.h
@@ -66,6 +66,8 @@ char *l_checksum_get_string(struct l_checksum *checksum);
 bool l_checksum_is_supported(enum l_checksum_type type, bool check_hmac);
 bool l_checksum_cmac_aes_supported();
 =

+ssize_t l_checksum_digest_length(enum l_checksum_type type);
+
 #ifdef __cplusplus
 }
 #endif
diff --git a/ell/ell.sym b/ell/ell.sym
index 4a806aa..203a291 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -115,6 +115,7 @@ global:
 	l_checksum_get_string;
 	l_checksum_is_supported;
 	l_checksum_cmac_aes_supported;
+	l_checksum_digest_length;
 	/* cipher */
 	l_cipher_new;
 	l_aead_cipher_new;
-- =

2.17.1


--===============9029542717956796656==--

