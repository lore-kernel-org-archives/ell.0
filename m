Content-Type: multipart/mixed; boundary="===============7976810465096557007=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 12/17] tls: Add RFC5289 suites using the ECDHE_RSA key exchange
Date: Tue, 01 Jan 2019 20:49:34 +0100
Message-ID: <20190101194939.5974-12-andrew.zaborowski@intel.com>
In-Reply-To: <20190101194939.5974-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7976810465096557007==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add the 4 cipher suites defined in RFC 5289 that we can now support
with the new ECDHE_RSA key exchange, 2 of these are the same ones
defined in RFC 8422.
---
 ell/tls-suites.c | 36 ++++++++++++++++++++++++++++++++++++
 1 file changed, 36 insertions(+)

diff --git a/ell/tls-suites.c b/ell/tls-suites.c
index 297b3d4..af8cbcd 100644
--- a/ell/tls-suites.c
+++ b/ell/tls-suites.c
@@ -738,6 +738,10 @@ static struct tls_mac_algorithm tls_md5 =3D {
 	.id =3D 4,
 	.hmac_type =3D L_CHECKSUM_SHA256,
 	.mac_length =3D 32,
+}, tls_sha384 =3D {
+	.id =3D 5,
+	.hmac_type =3D L_CHECKSUM_SHA384,
+	.mac_length =3D 48,
 };
 =

 static struct tls_cipher_suite tls_rsa_with_rc4_128_md5 =3D {
@@ -830,6 +834,34 @@ static struct tls_cipher_suite tls_rsa_with_rc4_128_md=
5 =3D {
 	.encryption =3D &tls_aes256,
 	.mac =3D &tls_sha,
 	.key_xchg =3D &tls_ecdhe_rsa,
+}, tls_ecdhe_rsa_with_aes_128_cbc_sha256 =3D {
+	.id =3D { 0xc0, 0x27 },
+	.name =3D "TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256",
+	.verify_data_length =3D 12,
+	.encryption =3D &tls_aes128,
+	.mac =3D &tls_sha256,
+	.key_xchg =3D &tls_ecdhe_rsa,
+}, tls_ecdhe_rsa_with_aes_256_cbc_sha384 =3D {
+	.id =3D { 0xc0, 0x28 },
+	.name =3D "TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384",
+	.verify_data_length =3D 12,
+	.encryption =3D &tls_aes256,
+	.mac =3D &tls_sha384,
+	.prf_hmac =3D L_CHECKSUM_SHA384,
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
@@ -837,8 +869,12 @@ struct tls_cipher_suite *tls_cipher_suite_pref[] =3D {
 	&tls_ecdhe_rsa_with_aes_128_cbc_sha,
 	&tls_rsa_with_aes_256_cbc_sha,
 	&tls_rsa_with_aes_128_cbc_sha,
+	&tls_ecdhe_rsa_with_aes_256_cbc_sha384,
+	&tls_ecdhe_rsa_with_aes_128_cbc_sha256,
 	&tls_rsa_with_aes_256_cbc_sha256,
 	&tls_rsa_with_aes_128_cbc_sha256,
+	&tls_ecdhe_rsa_with_aes_256_gcm_sha384,
+	&tls_ecdhe_rsa_with_aes_128_gcm_sha256,
 	&tls_rsa_with_aes_256_gcm_sha384,
 	&tls_rsa_with_aes_128_gcm_sha256,
 	&tls_ecdhe_rsa_with_3des_ede_cbc_sha,
-- =

2.19.1


--===============7976810465096557007==--

