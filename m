Content-Type: multipart/mixed; boundary="===============0756760186233374975=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 16/17] tls: Add DHE_RSA-based cipher suites
Date: Tue, 01 Jan 2019 20:49:38 +0100
Message-ID: <20190101194939.5974-16-andrew.zaborowski@intel.com>
In-Reply-To: <20190101194939.5974-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0756760186233374975==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add the 5 DHE_RSA suites defined in RFC 5246 and the 2 defined in
RFC 5288.
---
 ell/tls-suites.c | 55 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 55 insertions(+)

diff --git a/ell/tls-suites.c b/ell/tls-suites.c
index 8e975a0..7b2ed27 100644
--- a/ell/tls-suites.c
+++ b/ell/tls-suites.c
@@ -1283,6 +1283,13 @@ static struct tls_cipher_suite tls_rsa_with_rc4_128_=
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
@@ -1290,6 +1297,13 @@ static struct tls_cipher_suite tls_rsa_with_rc4_128_=
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
@@ -1297,6 +1311,13 @@ static struct tls_cipher_suite tls_rsa_with_rc4_128_=
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
@@ -1311,6 +1332,20 @@ static struct tls_cipher_suite tls_rsa_with_rc4_128_=
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
@@ -1324,6 +1359,19 @@ static struct tls_cipher_suite tls_rsa_with_rc4_128_=
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
@@ -1385,17 +1433,24 @@ static struct tls_cipher_suite tls_rsa_with_rc4_128=
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


--===============0756760186233374975==--

