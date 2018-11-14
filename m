Content-Type: multipart/mixed; boundary="===============0520957226936226052=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 06/12] tls: Add TLS_RSA_WITH_AES_128_GCM_SHA256 cipher suite
Date: Wed, 14 Nov 2018 14:18:56 +0100
Message-ID: <20181114131902.1695-6-andrew.zaborowski@intel.com>
In-Reply-To: <20181114131902.1695-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0520957226936226052==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Defined in RFC5288.  This cipher suite is preferred by a lot of
servers over the block mode AES suites (but the same cipher with
ECDHE key exchange is liked even more.)
---
 ell/tls.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/ell/tls.c b/ell/tls.c
index fd26306..fab4ce6 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -413,6 +413,13 @@ static struct tls_bulk_encryption_algorithm tls_rc4 =
=3D {
 	.key_length =3D 24,
 	.iv_length =3D 8,
 	.block_length =3D 8,
+}, tls_aes128_gcm =3D {
+	.cipher_type =3D TLS_CIPHER_AEAD,
+	.l_aead_id =3D L_AEAD_CIPHER_AES_GCM,
+	.key_length =3D 16,
+	.iv_length =3D 12,
+	.fixed_iv_length =3D 4,
+	.auth_tag_length =3D 16,
 };
 =

 static struct tls_mac_algorithm tls_md5 =3D {
@@ -462,6 +469,13 @@ static struct tls_cipher_suite tls_cipher_suite_pref[]=
 =3D {
 		.mac =3D &tls_sha256,
 		.key_xchg =3D &tls_rsa,
 	},
+	{
+		.id =3D { 0x00, 0x9c },
+		.name =3D "TLS_RSA_WITH_AES_128_GCM_SHA256",
+		.verify_data_length =3D 12,
+		.encryption =3D &tls_aes128_gcm,
+		.key_xchg =3D &tls_rsa,
+	},
 	{
 		.id =3D { 0x00, 0x0a },
 		.name =3D "TLS_RSA_WITH_3DES_EDE_CBC_SHA",
-- =

2.19.1


--===============0520957226936226052==--

