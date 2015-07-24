Content-Type: multipart/mixed; boundary="===============1866551848257232493=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 01/17] checksum: Add SHA384 and SHA512 hash & hmac types.
Date: Fri, 24 Jul 2015 05:26:42 +0200
Message-ID: <1437708410-28075-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1866551848257232493==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/checksum.c | 20 ++++++++++++++++++--
 ell/checksum.h |  2 ++
 2 files changed, 20 insertions(+), 2 deletions(-)

diff --git a/ell/checksum.c b/ell/checksum.c
index 243470f..882f5f6 100644
--- a/ell/checksum.c
+++ b/ell/checksum.c
@@ -73,7 +73,7 @@ struct sockaddr_alg {
  * Checksum handling
  */
 =

-#define is_valid_type(type)  ((type) <=3D L_CHECKSUM_SHA256)
+#define is_valid_type(type)  ((type) <=3D L_CHECKSUM_SHA512)
 =

 /**
  * l_checksum:
@@ -136,6 +136,12 @@ LIB_EXPORT struct l_checksum *l_checksum_new(enum l_ch=
ecksum_type type)
 	case L_CHECKSUM_SHA256:
 		name =3D "sha256";
 		break;
+	case L_CHECKSUM_SHA384:
+		name =3D "sha384";
+		break;
+	case L_CHECKSUM_SHA512:
+		name =3D "sha512";
+		break;
 	}
 =

 	fd =3D create_alg(name);
@@ -205,6 +211,12 @@ struct l_checksum *l_checksum_new_hmac(enum l_checksum=
_type type,
 	case L_CHECKSUM_SHA256:
 		name =3D "hmac(sha256)";
 		break;
+	case L_CHECKSUM_SHA384:
+		name =3D "hmac(sha384)";
+		break;
+	case L_CHECKSUM_SHA512:
+		name =3D "hmac(sha512)";
+		break;
 	}
 =

 	fd =3D create_alg(name);
@@ -338,13 +350,17 @@ LIB_EXPORT char *l_checksum_get_string(struct l_check=
sum *checksum)
 		{ .name =3D "md5", .digest_len =3D 16 },
 		{ .name =3D "sha1", .digest_len =3D 20 },
 		{ .name =3D "sha256", .digest_len =3D 32 },
+		{ .name =3D "sha384", .digest_len =3D 48 },
+		{ .name =3D "sha512", .digest_len =3D 64 },
 		{ .name =3D "cmac(aes)", .digest_len =3D 16 },
 		{ .name =3D "hmac(md5)", .digest_len =3D 16 },
 		{ .name =3D "hmac(sha1)", .digest_len =3D 20 },
 		{ .name =3D "hmac(sha256)", .digest_len =3D 32 },
+		{ .name =3D "hmac(sha384)", .digest_len =3D 48 },
+		{ .name =3D "hmac(sha512)", .digest_len =3D 64 },
 		{ .name =3D NULL, .digest_len =3D 0 },
 	};
-	unsigned char digest[32];
+	unsigned char digest[64];
 	unsigned int i;
 =

 	if (unlikely(!checksum))
diff --git a/ell/checksum.h b/ell/checksum.h
index 8e163c4..c516580 100644
--- a/ell/checksum.h
+++ b/ell/checksum.h
@@ -35,6 +35,8 @@ enum l_checksum_type {
 	L_CHECKSUM_MD5,
 	L_CHECKSUM_SHA1,
 	L_CHECKSUM_SHA256,
+	L_CHECKSUM_SHA384,
+	L_CHECKSUM_SHA512,
 };
 =

 struct l_checksum *l_checksum_new(enum l_checksum_type type);
-- =

2.1.4


--===============1866551848257232493==--

