Content-Type: multipart/mixed; boundary="===============8925892631943539605=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 08/12] tls: Add TLS_RSA_WITH_AES_256_GCM_SHA384 cipher suite
Date: Wed, 14 Nov 2018 14:18:58 +0100
Message-ID: <20181114131902.1695-8-andrew.zaborowski@intel.com>
In-Reply-To: <20181114131902.1695-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8925892631943539605==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Defined in RFC5288.  This cipher suite is preferred by some servers
over TLS_RSA_WITH_AES_128_GCM_SHA256 but not by others.
---
 ell/tls-private.h |  3 ++-
 ell/tls.c         | 16 ++++++++++++++++
 2 files changed, 18 insertions(+), 1 deletion(-)

diff --git a/ell/tls-private.h b/ell/tls-private.h
index 4f98cfe..5b76e73 100644
--- a/ell/tls-private.h
+++ b/ell/tls-private.h
@@ -128,12 +128,13 @@ enum tls_content_type {
  * keep at least the hashes our supported cipher suites specify for the PR=
F.
  */
 enum handshake_hash_type {
+	HANDSHAKE_HASH_SHA384,
 	HANDSHAKE_HASH_SHA256,
 	HANDSHAKE_HASH_MD5,
 	HANDSHAKE_HASH_SHA1,
 	__HANDSHAKE_HASH_COUNT,
 };
-#define HANDSHAKE_HASH_MAX_SIZE	32
+#define HANDSHAKE_HASH_MAX_SIZE	48
 =

 struct l_tls {
 	bool server;
diff --git a/ell/tls.c b/ell/tls.c
index 93a3bd5..0645897 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -416,6 +416,13 @@ static struct tls_bulk_encryption_algorithm tls_rc4 =
=3D {
 	.iv_length =3D 12,
 	.fixed_iv_length =3D 4,
 	.auth_tag_length =3D 16,
+}, tls_aes256_gcm =3D {
+	.cipher_type =3D TLS_CIPHER_AEAD,
+	.l_aead_id =3D L_AEAD_CIPHER_AES_GCM,
+	.key_length =3D 32,
+	.iv_length =3D 12,
+	.fixed_iv_length =3D 4,
+	.auth_tag_length =3D 16,
 };
 =

 static struct tls_mac_algorithm tls_md5 =3D {
@@ -465,6 +472,14 @@ static struct tls_cipher_suite tls_cipher_suite_pref[]=
 =3D {
 		.mac =3D &tls_sha256,
 		.key_xchg =3D &tls_rsa,
 	},
+	{
+		.id =3D { 0x00, 0x9d },
+		.name =3D "TLS_RSA_WITH_AES_256_GCM_SHA384",
+		.verify_data_length =3D 12,
+		.encryption =3D &tls_aes256_gcm,
+		.prf_hmac =3D L_CHECKSUM_SHA384,
+		.key_xchg =3D &tls_rsa,
+	},
 	{
 		.id =3D { 0x00, 0x9c },
 		.name =3D "TLS_RSA_WITH_AES_128_GCM_SHA256",
@@ -530,6 +545,7 @@ static struct tls_compression_method *tls_find_compress=
ion_method(
 }
 =

 static const struct tls_hash_algorithm tls_handshake_hash_data[] =3D {
+	[HANDSHAKE_HASH_SHA384]	=3D { 5, L_CHECKSUM_SHA384, 48, "SHA384" },
 	[HANDSHAKE_HASH_SHA256]	=3D { 4, L_CHECKSUM_SHA256, 32, "SHA256" },
 	[HANDSHAKE_HASH_MD5]	=3D { 1, L_CHECKSUM_MD5, 16, "MD5" },
 	[HANDSHAKE_HASH_SHA1]	=3D { 2, L_CHECKSUM_SHA1, 20, "SHA1" },
-- =

2.19.1


--===============8925892631943539605==--

