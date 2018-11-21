Content-Type: multipart/mixed; boundary="===============8221426432111393941=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 06/16] tls: Check cipher suites against ceritficate key type
Date: Wed, 21 Nov 2018 16:08:53 +0100
Message-ID: <20181121150903.24437-6-andrew.zaborowski@intel.com>
In-Reply-To: <20181121150903.24437-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8221426432111393941==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Check that the key exchange mechanism in the cipher suite is compatible
with the supplied certificate if any, in tls_cipher_suite_is_compatible.
---
 ell/tls.c | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/ell/tls.c b/ell/tls.c
index f1e308f..7d6b0e0 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -519,6 +519,7 @@ static bool tls_cipher_suite_is_compatible(struct l_tls=
 *tls,
 					const char **error)
 {
 	static char error_buf[200];
+	struct l_cert *leaf;
 =

 	if (suite->encryption &&
 			suite->encryption->cipher_type =3D=3D TLS_CIPHER_AEAD) {
@@ -591,7 +592,18 @@ static bool tls_cipher_suite_is_compatible(struct l_tl=
s *tls,
 		return false;
 	}
 =

-	/* TODO: Check suite->key_xchg->validate_cert_key_type(tls->cert) */
+	leaf =3D l_certchain_get_leaf(tls->cert);
+	if (leaf && !suite->key_xchg->validate_cert_key_type(leaf)) {
+		if (error) {
+			*error =3D error_buf;
+			snprintf(error_buf, sizeof(error_buf),
+					"Local certificate has key type "
+					"incompatible with cipher suite %s's "
+					"key xchg mechanism", suite->name);
+		}
+
+		return false;
+	}
 =

 	return true;
 }
-- =

2.19.1


--===============8221426432111393941==--

