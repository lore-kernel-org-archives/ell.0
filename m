Content-Type: multipart/mixed; boundary="===============7600992595033375409=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 12/12] random: Remove 256 byte limit
Date: Fri, 04 Jan 2019 02:26:40 +0100
Message-ID: <20190104012640.4022-12-andrew.zaborowski@intel.com>
In-Reply-To: <20190104012640.4022-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7600992595033375409==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/random.c | 21 ++++++++++-----------
 1 file changed, 10 insertions(+), 11 deletions(-)

diff --git a/ell/random.c b/ell/random.c
index c646ae7..2068003 100644
--- a/ell/random.c
+++ b/ell/random.c
@@ -37,7 +37,7 @@
 #define GRND_NONBLOCK	0x0001
 #endif
 =

-#ifndef GRND_RANOM
+#ifndef GRND_RANDOM
 #define GRND_RANDOM	0x0002
 #endif
 =

@@ -57,19 +57,18 @@ static inline int getrandom(void *buffer, size_t count,=
 unsigned flags) {
  **/
 LIB_EXPORT bool l_getrandom(void *buf, size_t len)
 {
-	int ret;
-
-	if (len > 256)
-		return false;
+	while (len) {
+		int ret;
 =

-	ret =3D getrandom(buf, len, 0);
-	if (ret < 0)
-		return false;
+		ret =3D TEMP_FAILURE_RETRY(getrandom(buf, len, 0));
+		if (ret < 0)
+			return false;
 =

-	if ((size_t) ret =3D=3D len)
-		return true;
+		buf +=3D ret;
+		len -=3D ret;
+	}
 =

-	return false;
+	return true;
 }
 =

 LIB_EXPORT bool l_getrandom_is_supported()
-- =

2.19.1


--===============7600992595033375409==--

