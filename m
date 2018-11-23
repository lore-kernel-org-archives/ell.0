Content-Type: multipart/mixed; boundary="===============0287725672281734675=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 3/5] cert: Add comments about l_certchain_foreach_*
Date: Fri, 23 Nov 2018 10:44:27 +0100
Message-ID: <20181123094429.7190-3-andrew.zaborowski@intel.com>
In-Reply-To: <20181123094429.7190-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0287725672281734675==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/cert.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/ell/cert.c b/ell/cert.c
index 66433c2..7f0b694 100644
--- a/ell/cert.c
+++ b/ell/cert.c
@@ -253,6 +253,11 @@ LIB_EXPORT struct l_cert *l_certchain_get_leaf(struct =
l_certchain *chain)
 	return chain->leaf;
 }
 =

+/*
+ * Call @cb for each certificate in the chain starting from the leaf
+ * certificate.  If a call returns @true, stop and return @true to
+ * the user, otherwise return @false.
+ */
 LIB_EXPORT bool l_certchain_foreach_from_leaf(struct l_certchain *chain,
 						l_cert_foreach_cb_t cb,
 						void *user_data)
@@ -269,6 +274,11 @@ LIB_EXPORT bool l_certchain_foreach_from_leaf(struct l=
_certchain *chain,
 	return false;
 }
 =

+/*
+ * Call @cb for each certificate in the chain starting from the root
+ * certificate.  If a call returns @true, stop and return @true to
+ * the user, otherwise return @false.
+ */
 LIB_EXPORT bool l_certchain_foreach_from_ca(struct l_certchain *chain,
 						l_cert_foreach_cb_t cb,
 						void *user_data)
-- =

2.19.1


--===============0287725672281734675==--

