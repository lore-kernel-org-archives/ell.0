Content-Type: multipart/mixed; boundary="===============7501914695356905825=="
MIME-Version: 1.0
From: Markus Ongyerth <ongy@ongy.net>
Subject: [PATCH 1/2] Add DES and MD4 support
Date: Sat, 10 Dec 2016 09:44:56 +0100
Message-ID: <20161210084457.12774-1-ongy@ongy.net>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7501914695356905825==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

From: Markus Ongyerth <ell@ongy.net>

Add support for DES in cipher and MD4 in checksum to allow implementing
the mschapv2 protocol.
---
 ell/checksum.c | 8 ++++++++
 ell/checksum.h | 1 +
 ell/cipher.c   | 3 +++
 ell/cipher.h   | 1 +
 ell/key.c      | 3 +++
 5 files changed, 16 insertions(+)

diff --git a/ell/checksum.c b/ell/checksum.c
index 5a5228d..39e351e 100644
--- a/ell/checksum.c
+++ b/ell/checksum.c
@@ -128,6 +128,9 @@ LIB_EXPORT struct l_checksum *l_checksum_new(enum l_che=
cksum_type type)
 	switch (type) {
 	case L_CHECKSUM_NONE:
 		return NULL;
+	case L_CHECKSUM_MD4:
+		name =3D "md4";
+		break;
 	case L_CHECKSUM_MD5:
 		name =3D "md5";
 		break;
@@ -207,6 +210,9 @@ struct l_checksum *l_checksum_new_hmac(enum l_checksum_=
type type,
 	switch (type) {
 	case L_CHECKSUM_NONE:
 		return NULL;
+	case L_CHECKSUM_MD4:
+		name =3D "hmac(md4)";
+		break;
 	case L_CHECKSUM_MD5:
 		name =3D "hmac(md5)";
 		break;
@@ -406,12 +412,14 @@ LIB_EXPORT char *l_checksum_get_string(struct l_check=
sum *checksum)
 		const char *name;
 		size_t digest_len;
 	} digest_lut[] =3D {
+		{ .name =3D "md4", .digest_len =3D 16 },
 		{ .name =3D "md5", .digest_len =3D 16 },
 		{ .name =3D "sha1", .digest_len =3D 20 },
 		{ .name =3D "sha256", .digest_len =3D 32 },
 		{ .name =3D "sha384", .digest_len =3D 48 },
 		{ .name =3D "sha512", .digest_len =3D 64 },
 		{ .name =3D "cmac(aes)", .digest_len =3D 16 },
+		{ .name =3D "hmac(md4)", .digest_len =3D 16 },
 		{ .name =3D "hmac(md5)", .digest_len =3D 16 },
 		{ .name =3D "hmac(sha1)", .digest_len =3D 20 },
 		{ .name =3D "hmac(sha256)", .digest_len =3D 32 },
diff --git a/ell/checksum.h b/ell/checksum.h
index be118ff..9895b1c 100644
--- a/ell/checksum.h
+++ b/ell/checksum.h
@@ -35,6 +35,7 @@ struct l_checksum;
 =

 enum l_checksum_type {
 	L_CHECKSUM_NONE,
+	L_CHECKSUM_MD4,
 	L_CHECKSUM_MD5,
 	L_CHECKSUM_SHA1,
 	L_CHECKSUM_SHA256,
diff --git a/ell/cipher.c b/ell/cipher.c
index 8312451..139331e 100644
--- a/ell/cipher.c
+++ b/ell/cipher.c
@@ -156,6 +156,9 @@ LIB_EXPORT struct l_cipher *l_cipher_new(enum l_cipher_=
type type,
 	case L_CIPHER_ARC4:
 		alg_name =3D "ecb(arc4)";
 		break;
+	case L_CIPHER_DES:
+		alg_name =3D "ecb(des)";
+		break;
 	case L_CIPHER_DES3_EDE_CBC:
 		alg_name =3D "cbc(des3_ede)";
 		break;
diff --git a/ell/cipher.h b/ell/cipher.h
index f5c6646..f9ff42f 100644
--- a/ell/cipher.h
+++ b/ell/cipher.h
@@ -33,6 +33,7 @@ enum l_cipher_type {
 	L_CIPHER_AES =3D 0,
 	L_CIPHER_AES_CBC,
 	L_CIPHER_ARC4,
+	L_CIPHER_DES,
 	L_CIPHER_DES3_EDE_CBC,
 };
 =

diff --git a/ell/key.c b/ell/key.c
index 11700e8..db9abb1 100644
--- a/ell/key.c
+++ b/ell/key.c
@@ -357,6 +357,9 @@ static const char *lookup_checksum(enum l_checksum_type=
 checksum)
 	switch (checksum) {
 	case L_CHECKSUM_NONE:
 		break;
+	case L_CHECKSUM_MD4:
+		ret =3D "md4";
+		break;
 	case L_CHECKSUM_MD5:
 		ret =3D "md5";
 		break;
-- =

2.10.2


--===============7501914695356905825==--

