Content-Type: multipart/mixed; boundary="===============3853757163715031145=="
MIME-Version: 1.0
From: Ard Biesheuvel <ardb@kernel.org>
Subject: [PATCH 1/2] tls: remove support for RC4 cipher suites
Date: Mon, 03 Aug 2020 12:54:48 +0200
Message-ID: <20200803105449.124714-2-ardb@kernel.org>
In-Reply-To: <20200803105449.124714-1-ardb@kernel.org>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3853757163715031145==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The RC4 based TLS suites rely on a quirky kernel implementation (the
ecb(arc4) skcipher), are not covered by any tests, and RFC 7465, which
was issued in 2015, explicitly forbids the use of RC4 in TLS under any
circumstances.

Signed-off-by: Ard Biesheuvel <ardb@kernel.org>
---
 ell/tls-suites.c | 41 ++------------------
 unit/test-tls.c  |  3 +-
 2 files changed, 4 insertions(+), 40 deletions(-)

diff --git a/ell/tls-suites.c b/ell/tls-suites.c
index 91bc2cfe2622..7ec49a86c9ab 100644
--- a/ell/tls-suites.c
+++ b/ell/tls-suites.c
@@ -1096,11 +1096,7 @@ static struct tls_key_exchange_algorithm tls_dhe =3D=
 {
 	.free_params =3D tls_free_dhe_params,
 };
 =

-static struct tls_bulk_encryption_algorithm tls_rc4 =3D {
-	.cipher_type =3D TLS_CIPHER_STREAM,
-	.l_id =3D L_CIPHER_ARC4,
-	.key_length =3D 16,
-}, tls_aes128 =3D {
+static struct tls_bulk_encryption_algorithm tls_aes128 =3D {
 	.cipher_type =3D TLS_CIPHER_BLOCK,
 	.l_id =3D L_CIPHER_AES_CBC,
 	.key_length =3D 16,
@@ -1134,11 +1130,7 @@ static struct tls_bulk_encryption_algorithm tls_rc4 =
=3D {
 	.auth_tag_length =3D 16,
 };
 =

-static struct tls_mac_algorithm tls_md5 =3D {
-	.id =3D 1,
-	.hmac_type =3D L_CHECKSUM_MD5,
-	.mac_length =3D 16,
-}, tls_sha =3D {
+static struct tls_mac_algorithm tls_sha =3D {
 	.id =3D 2,
 	.hmac_type =3D L_CHECKSUM_SHA1,
 	.mac_length =3D 20,
@@ -1152,23 +1144,7 @@ static struct tls_mac_algorithm tls_md5 =3D {
 	.mac_length =3D 48,
 };
 =

-static struct tls_cipher_suite tls_rsa_with_rc4_128_md5 =3D {
-	.id =3D { 0x00, 0x04 },
-	.name =3D "TLS_RSA_WITH_RC4_128_MD5",
-	.verify_data_length =3D 12,
-	.encryption =3D &tls_rc4,
-	.mac =3D &tls_md5,
-	.signature =3D &tls_rsa_signature,
-	.key_xchg =3D &tls_rsa_key_xchg,
-}, tls_rsa_with_rc4_128_sha =3D {
-	.id =3D { 0x00, 0x05 },
-	.name =3D "TLS_RSA_WITH_RC4_128_SHA",
-	.verify_data_length =3D 12,
-	.encryption =3D &tls_rc4,
-	.mac =3D &tls_sha,
-	.signature =3D &tls_rsa_signature,
-	.key_xchg =3D &tls_rsa_key_xchg,
-}, tls_rsa_with_3des_ede_cbc_sha =3D {
+static struct tls_cipher_suite tls_rsa_with_3des_ede_cbc_sha =3D {
 	.id =3D { 0x00, 0x0a },
 	.name =3D "TLS_RSA_WITH_3DES_EDE_CBC_SHA",
 	.verify_data_length =3D 12,
@@ -1278,14 +1254,6 @@ static struct tls_cipher_suite tls_rsa_with_rc4_128_=
md5 =3D {
 	.prf_hmac =3D L_CHECKSUM_SHA384,
 	.signature =3D &tls_rsa_signature,
 	.key_xchg =3D &tls_dhe,
-}, tls_ecdhe_rsa_with_rc4_128_sha =3D {
-	.id =3D { 0xc0, 0x11 },
-	.name =3D "TLS_ECDHE_RSA_WITH_RC4_128_SHA",
-	.verify_data_length =3D 12,
-	.encryption =3D &tls_rc4,
-	.mac =3D &tls_sha,
-	.signature =3D &tls_rsa_signature,
-	.key_xchg =3D &tls_ecdhe,
 }, tls_ecdhe_rsa_with_3des_ede_cbc_sha =3D {
 	.id =3D { 0xc0, 0x12 },
 	.name =3D "TLS_ECDHE_RSA_WITH_3DES_EDE_CBC_SHA",
@@ -1366,8 +1334,5 @@ struct tls_cipher_suite *tls_cipher_suite_pref[] =3D {
 	&tls_ecdhe_rsa_with_3des_ede_cbc_sha,
 	&tls_dhe_rsa_with_3des_ede_cbc_sha,
 	&tls_rsa_with_3des_ede_cbc_sha,
-	&tls_ecdhe_rsa_with_rc4_128_sha,
-	&tls_rsa_with_rc4_128_sha,
-	&tls_rsa_with_rc4_128_md5,
 	NULL,
 };
diff --git a/unit/test-tls.c b/unit/test-tls.c
index 89dcb9ad3215..9503f6b0a493 100644
--- a/unit/test-tls.c
+++ b/unit/test-tls.c
@@ -956,8 +956,7 @@ int main(int argc, char *argv[])
 	}
 =

 	if (!l_cipher_is_supported(L_CIPHER_DES3_EDE_CBC) ||
-			!l_cipher_is_supported(L_CIPHER_AES_CBC) ||
-			!l_cipher_is_supported(L_CIPHER_ARC4)) {
+			!l_cipher_is_supported(L_CIPHER_AES_CBC)) {
 		printf("Needed ciphers missing, "
 				"skipping TLS connection tests...\n");
 		goto done;
-- =

2.20.1

--===============3853757163715031145==--

