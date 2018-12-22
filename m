Content-Type: multipart/mixed; boundary="===============6753635968298443029=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 11/11] tls: Add cipher suites using the ECDHE_RSA key exchange
Date: Sat, 22 Dec 2018 05:16:35 +0100
Message-ID: <20181222041635.6533-11-andrew.zaborowski@intel.com>
In-Reply-To: <20181222041635.6533-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6753635968298443029==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add all cipher suites defined in RFC 8422 that we can now support with
the new ECDHE_RSA key exchange (see section 6 for the full list of
ECDH-based cipher suites)
---
 ell/tls-suites.c | 39 +++++++++++++++++++++++++++++++++++++++
 1 file changed, 39 insertions(+)

diff --git a/ell/tls-suites.c b/ell/tls-suites.c
index 4ec6d54..dff2e3a 100644
--- a/ell/tls-suites.c
+++ b/ell/tls-suites.c
@@ -802,15 +802,54 @@ static struct tls_cipher_suite tls_rsa_with_rc4_128_m=
d5 =3D {
 	.encryption =3D &tls_aes256_gcm,
 	.prf_hmac =3D L_CHECKSUM_SHA384,
 	.key_xchg =3D &tls_rsa,
+}, tls_ecdhe_rsa_with_3des_ede_cbc_sha =3D {
+	.id =3D { 0xc0, 0x12 },
+	.name =3D "TLS_ECDHE_RSA_WITH_3DES_EDE_CBC_SHA",
+	.verify_data_length =3D 12,
+	.encryption =3D &tls_3des_ede,
+	.mac =3D &tls_sha,
+	.key_xchg =3D &tls_ecdhe_rsa,
+}, tls_ecdhe_rsa_with_aes_128_cbc_sha =3D {
+	.id =3D { 0xc0, 0x13 },
+	.name =3D "TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA",
+	.verify_data_length =3D 12,
+	.encryption =3D &tls_aes128,
+	.mac =3D &tls_sha,
+	.key_xchg =3D &tls_ecdhe_rsa,
+}, tls_ecdhe_rsa_with_aes_256_cbc_sha =3D {
+	.id =3D { 0xc0, 0x14 },
+	.name =3D "TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA",
+	.verify_data_length =3D 12,
+	.encryption =3D &tls_aes256,
+	.mac =3D &tls_sha,
+	.key_xchg =3D &tls_ecdhe_rsa,
+}, tls_ecdhe_rsa_with_aes_128_gcm_sha256 =3D {
+	.id =3D { 0xc0, 0x2f },
+	.name =3D "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256",
+	.verify_data_length =3D 12,
+	.encryption =3D &tls_aes128_gcm,
+	.key_xchg =3D &tls_ecdhe_rsa,
+}, tls_ecdhe_rsa_with_aes_256_gcm_sha384 =3D {
+	.id =3D { 0xc0, 0x30 },
+	.name =3D "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384",
+	.verify_data_length =3D 12,
+	.encryption =3D &tls_aes256_gcm,
+	.prf_hmac =3D L_CHECKSUM_SHA384,
+	.key_xchg =3D &tls_ecdhe_rsa,
 };
 =

 struct tls_cipher_suite *tls_cipher_suite_pref[] =3D {
+	&tls_ecdhe_rsa_with_aes_256_cbc_sha,
+	&tls_ecdhe_rsa_with_aes_128_cbc_sha,
 	&tls_rsa_with_aes_256_cbc_sha,
 	&tls_rsa_with_aes_128_cbc_sha,
 	&tls_rsa_with_aes_256_cbc_sha256,
 	&tls_rsa_with_aes_128_cbc_sha256,
+	&tls_ecdhe_rsa_with_aes_256_gcm_sha384,
+	&tls_ecdhe_rsa_with_aes_128_gcm_sha256,
 	&tls_rsa_with_aes_256_gcm_sha384,
 	&tls_rsa_with_aes_128_gcm_sha256,
+	&tls_ecdhe_rsa_with_3des_ede_cbc_sha,
 	&tls_rsa_with_3des_ede_cbc_sha,
 	&tls_rsa_with_rc4_128_sha,
 	&tls_rsa_with_rc4_128_md5,
-- =

2.19.1


--===============6753635968298443029==--

