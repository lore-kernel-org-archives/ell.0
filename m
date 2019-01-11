Content-Type: multipart/mixed; boundary="===============7886842097137814575=="
MIME-Version: 1.0
From: James Prestwood <james.prestwood@linux.intel.com>
Subject: [PATCH] unit: test-ecdh: add bytes to l_getrandom wrapper
Date: Fri, 11 Jan 2019 09:38:59 -0800
Message-ID: <20190111173859.13407-1-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7886842097137814575==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This should have been put into the commit adding the P384 unit test.
Since P384 works with 48 byte integers we need 48 bytes of randomness
in the l_getrandom wrapper. A check was also added so l_getrandom will
fail if too many bytes are requested (e.g. if a larger curve is added).
---
 unit/test-ecdh.c | 20 +++++++++++++-------
 1 file changed, 13 insertions(+), 7 deletions(-)

diff --git a/unit/test-ecdh.c b/unit/test-ecdh.c
index cc0f3a8..68b8d37 100644
--- a/unit/test-ecdh.c
+++ b/unit/test-ecdh.c
@@ -37,17 +37,23 @@ bool __real_l_getrandom(void *buf, size_t len);
 =

 bool __wrap_l_getrandom(void *buf, size_t len)
 {
-	static const uint8_t random_buf[] =3D { 0x75, 0xc5, 0xfe, 0x3e, 0x53,
-						0xcc, 0x33, 0x33, 0x64, 0xea,
-						0xdd, 0xa1, 0xe6, 0x62, 0x7a,
-						0xb1, 0x98, 0xa7, 0xa0, 0x1e,
-						0xac, 0x4b, 0x1d, 0xb8, 0x71,
-						0x5b, 0x1d, 0x00, 0x36, 0xd0,
-						0x0f, 0xde };
+	static const uint8_t random_buf[] =3D { 0xba, 0xaf, 0x6d, 0x97, 0x71,
+						0xe5, 0xda, 0xc9, 0x89, 0x6e,
+						0x58, 0x18, 0x92, 0xf8, 0x55,
+						0x4f, 0x29, 0xf0, 0xbd, 0x10,
+						0xaf, 0x0e, 0x38, 0xb5, 0xe6,
+						0x44, 0x56, 0x9d, 0x99, 0x2a,
+						0x7f, 0xe2, 0x8d, 0x46, 0xb0,
+						0x73, 0xcd, 0xd3, 0x6a, 0x7b,
+						0xa6, 0xd3, 0xde, 0xbf, 0x38,
+						0x96, 0xb7, 0xc3 };
 =

 	if (use_real_getrandom)
 		return __real_l_getrandom(buf, len);
 =

+	if (len > sizeof(random_buf))
+		return false;
+
 	memcpy(buf, random_buf, len);
 =

 	return true;
-- =

2.17.1


--===============7886842097137814575==--

