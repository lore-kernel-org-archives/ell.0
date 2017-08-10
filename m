Content-Type: multipart/mixed; boundary="===============0159829602702237163=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 01/10] checksum: Add SHA224 checksum type
Date: Fri, 11 Aug 2017 01:10:07 +0200
Message-ID: <20170810231016.29445-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0159829602702237163==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/checksum.c | 2 ++
 ell/checksum.h | 1 +
 ell/key.c      | 3 +++
 3 files changed, 6 insertions(+)

diff --git a/ell/checksum.c b/ell/checksum.c
index 54cddac..4045489 100644
--- a/ell/checksum.c
+++ b/ell/checksum.c
@@ -142,6 +142,8 @@ static const char *checksum_type_to_name(enum l_checksu=
m_type type)
 		return "md5";
 	case L_CHECKSUM_SHA1:
 		return "sha1";
+	case L_CHECKSUM_SHA224:
+		return "sha224";
 	case L_CHECKSUM_SHA256:
 		return "sha256";
 	case L_CHECKSUM_SHA384:
diff --git a/ell/checksum.h b/ell/checksum.h
index 5e6c027..05927b6 100644
--- a/ell/checksum.h
+++ b/ell/checksum.h
@@ -38,6 +38,7 @@ enum l_checksum_type {
 	L_CHECKSUM_MD4,
 	L_CHECKSUM_MD5,
 	L_CHECKSUM_SHA1,
+	L_CHECKSUM_SHA224,
 	L_CHECKSUM_SHA256,
 	L_CHECKSUM_SHA384,
 	L_CHECKSUM_SHA512,
diff --git a/ell/key.c b/ell/key.c
index fba400f..5a73bbd 100644
--- a/ell/key.c
+++ b/ell/key.c
@@ -380,6 +380,9 @@ static const char *lookup_checksum(enum l_checksum_type=
 checksum)
 	case L_CHECKSUM_SHA1:
 		ret =3D "sha1";
 		break;
+	case L_CHECKSUM_SHA224:
+		ret =3D "sha224";
+		break;
 	case L_CHECKSUM_SHA256:
 		ret =3D "sha256";
 		break;
-- =

2.11.0


--===============0159829602702237163==--

