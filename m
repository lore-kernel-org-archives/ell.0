Content-Type: multipart/mixed; boundary="===============6393480336675646555=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 4/4] tls: Add DHE_RSA-based cipher suites
Date: Wed, 09 Jan 2019 11:43:49 +0100
Message-ID: <20190109104349.11763-4-andrew.zaborowski@intel.com>
In-Reply-To: <20190109104349.11763-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6393480336675646555==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add the 5 DHE_RSA suites defined in RFC 5246 and the 2 defined in
RFC 5288.
---
 ell/tls-suites.c | 55 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 55 insertions(+)

diff --git a/ell/tls-suites.c b/ell/tls-suites.c
index b9fdc0f..2ae13ea 100644
--- a/ell/tls-suites.c
+++ b/ell/tls-suites.c
@@ -1213,6 +1213,13 @@ static struct tls_cipher_suite tls_rsa_with_rc4_128_=
md5 =3D {
 	.encryption =3D &tls_3des_ede,
 	.mac =3D &tls_sha,
 	.key_xchg =3D &tls_rsa,
+}, tls_dhe_rsa_with_3des_ede_cbc_sha =3D {
+	.id =3D { 0x00, 0x16 },
+	.name =3D "TLS_DHE_RSA_WITH_3DES_EDE_CBC_SHA",
+	.verify_data_length =3D 12,
+	.encryption =3D &tls_3des_ede,
+	.mac =3D &tls_sha,
+	.key_xchg =3D &tls_dhe_rsa,
 }, tls_rsa_with_aes_128_cbc_sha =3D {
 	.id =3D { 0x00, 0x2f },
 	.name =3D "TLS_RSA_WITH_AES_128_CBC_SHA",
@@ -1220,6 +1227,13 @@ static struct tls_cipher_suite tls_rsa_with_rc4_128_=
md5 =3D {
 	.encryption =3D &tls_aes128,
 	.mac =3D &tls_sha,
 	.key_xchg =3D &tls_rsa,
+}, tls_dhe_rsa_with_aes_128_cbc_sha =3D {
+	.id =3D { 0x00, 0x33 },
+	.name =3D "TLS_DHE_RSA_WITH_AES_128_CBC_SHA",
+	.verify_data_length =3D 12,
+	.encryption =3D &tls_aes128,
+	.mac =3D &tls_sha,
+	.key_xchg =3D &tls_dhe_rsa,
 }, tls_rsa_with_aes_256_cbc_sha =3D {
 	.id =3D { 0x00, 0x35 },
 	.name =3D "TLS_RSA_WITH_AES_256_CBC_SHA",
@@ -1227,6 +1241,13 @@ static struct tls_cipher_suite tls_rsa_with_rc4_128_=
md5 =3D {
 	.encryption =3D &tls_aes256,
 	.mac =3D &tls_sha,
 	.key_xchg =3D &tls_rsa,
+}, tls_dhe_rsa_with_aes_256_cbc_sha =3D {
+	.id =3D { 0x00, 0x39 },
+	.name =3D "TLS_DHE_RSA_WITH_AES_256_CBC_SHA",
+	.verify_data_length =3D 12,
+	.encryption =3D &tls_aes256,
+	.mac =3D &tls_sha,
+	.key_xchg =3D &tls_dhe_rsa,
 }, tls_rsa_with_aes_128_cbc_sha256 =3D {
 	.id =3D { 0x00, 0x3c },
 	.name =3D "TLS_RSA_WITH_AES_128_CBC_SHA256",
@@ -1241,6 +1262,20 @@ static struct tls_cipher_suite tls_rsa_with_rc4_128_=
md5 =3D {
 	.encryption =3D &tls_aes256,
 	.mac =3D &tls_sha256,
 	.key_xchg =3D &tls_rsa,
+}, tls_dhe_rsa_with_aes_128_cbc_sha256 =3D {
+	.id =3D { 0x00, 0x67 },
+	.name =3D "TLS_DHE_RSA_WITH_AES_128_CBC_SHA256",
+	.verify_data_length =3D 12,
+	.encryption =3D &tls_aes128,
+	.mac =3D &tls_sha256,
+	.key_xchg =3D &tls_dhe_rsa,
+}, tls_dhe_rsa_with_aes_256_cbc_sha256 =3D {
+	.id =3D { 0x00, 0x6b },
+	.name =3D "TLS_DHE_RSA_WITH_AES_256_CBC_SHA256",
+	.verify_data_length =3D 12,
+	.encryption =3D &tls_aes256,
+	.mac =3D &tls_sha256,
+	.key_xchg =3D &tls_dhe_rsa,
 }, tls_rsa_with_aes_128_gcm_sha256 =3D {
 	.id =3D { 0x00, 0x9c },
 	.name =3D "TLS_RSA_WITH_AES_128_GCM_SHA256",
@@ -1254,6 +1289,19 @@ static struct tls_cipher_suite tls_rsa_with_rc4_128_=
md5 =3D {
 	.encryption =3D &tls_aes256_gcm,
 	.prf_hmac =3D L_CHECKSUM_SHA384,
 	.key_xchg =3D &tls_rsa,
+}, tls_dhe_rsa_with_aes_128_gcm_sha256 =3D {
+	.id =3D { 0x00, 0x9e },
+	.name =3D "TLS_DHE_RSA_WITH_AES_128_GCM_SHA256",
+	.verify_data_length =3D 12,
+	.encryption =3D &tls_aes128_gcm,
+	.key_xchg =3D &tls_dhe_rsa,
+}, tls_dhe_rsa_with_aes_256_gcm_sha384 =3D {
+	.id =3D { 0x00, 0x9f },
+	.name =3D "TLS_DHE_RSA_WITH_AES_256_GCM_SHA384",
+	.verify_data_length =3D 12,
+	.encryption =3D &tls_aes256_gcm,
+	.prf_hmac =3D L_CHECKSUM_SHA384,
+	.key_xchg =3D &tls_dhe_rsa,
 }, tls_ecdhe_rsa_with_rc4_128_sha =3D {
 	.id =3D { 0xc0, 0x11 },
 	.name =3D "TLS_ECDHE_RSA_WITH_RC4_128_SHA",
@@ -1315,17 +1363,24 @@ static struct tls_cipher_suite tls_rsa_with_rc4_128=
_md5 =3D {
 struct tls_cipher_suite *tls_cipher_suite_pref[] =3D {
 	&tls_ecdhe_rsa_with_aes_256_cbc_sha,
 	&tls_ecdhe_rsa_with_aes_128_cbc_sha,
+	&tls_dhe_rsa_with_aes_256_cbc_sha,
+	&tls_dhe_rsa_with_aes_128_cbc_sha,
 	&tls_rsa_with_aes_256_cbc_sha,
 	&tls_rsa_with_aes_128_cbc_sha,
 	&tls_ecdhe_rsa_with_aes_256_cbc_sha384,
 	&tls_ecdhe_rsa_with_aes_128_cbc_sha256,
+	&tls_dhe_rsa_with_aes_256_cbc_sha256,
+	&tls_dhe_rsa_with_aes_128_cbc_sha256,
 	&tls_rsa_with_aes_256_cbc_sha256,
 	&tls_rsa_with_aes_128_cbc_sha256,
 	&tls_ecdhe_rsa_with_aes_256_gcm_sha384,
 	&tls_ecdhe_rsa_with_aes_128_gcm_sha256,
+	&tls_dhe_rsa_with_aes_256_gcm_sha384,
+	&tls_dhe_rsa_with_aes_128_gcm_sha256,
 	&tls_rsa_with_aes_256_gcm_sha384,
 	&tls_rsa_with_aes_128_gcm_sha256,
 	&tls_ecdhe_rsa_with_3des_ede_cbc_sha,
+	&tls_dhe_rsa_with_3des_ede_cbc_sha,
 	&tls_rsa_with_3des_ede_cbc_sha,
 	&tls_ecdhe_rsa_with_rc4_128_sha,
 	&tls_rsa_with_rc4_128_sha,
-- =

2.19.1


--===============6393480336675646555==--

