Content-Type: multipart/mixed; boundary="===============3998171659062210143=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 3/3] tls: Check DH is supported by keyctl before offering DHE
 suites
Date: Thu, 10 Jan 2019 23:25:37 +0100
Message-ID: <20190110222537.14492-3-andrew.zaborowski@intel.com>
In-Reply-To: <20190110222537.14492-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3998171659062210143==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/tls.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/ell/tls.c b/ell/tls.c
index 0e7928a..f9e1e95 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -464,6 +464,19 @@ static bool tls_cipher_suite_is_compatible(struct l_tl=
s *tls,
 		return false;
 	}
 =

+	if (suite->key_xchg->need_ffdh &&
+			!l_key_is_supported(L_KEY_FEATURE_DH)) {
+		if (error) {
+			*error =3D error_buf;
+			snprintf(error_buf, sizeof(error_buf),
+					"Cipher suite %s's key exchange "
+					"mechanism needs kernel DH support",
+					suite->name);
+		}
+
+		return false;
+	}
+
 	leaf =3D l_certchain_get_leaf(tls->cert);
 	if (leaf && !suite->key_xchg->validate_cert_key_type(leaf)) {
 		if (error) {
-- =

2.19.1


--===============3998171659062210143==--

