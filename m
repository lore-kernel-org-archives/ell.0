Content-Type: multipart/mixed; boundary="===============5878571228110639803=="
MIME-Version: 1.0
From: James Prestwood <james.prestwood@linux.intel.com>
Subject: [PATCH 7/9] unit: update test-ecdh with more random bytes
Date: Thu, 29 Nov 2018 14:08:06 -0800
Message-ID: <20181129220808.22151-7-james.prestwood@linux.intel.com>
In-Reply-To: <20181129220808.22151-1-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5878571228110639803==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

With the addition of P384, our wrapped l_getrandom needs enough random
bytes to fill a P384 integer, 48 bytes.
---
 unit/test-ecdh.c | 24 +++++++++++++++++-------
 1 file changed, 17 insertions(+), 7 deletions(-)

diff --git a/unit/test-ecdh.c b/unit/test-ecdh.c
index efc47de..e44c4b6 100644
--- a/unit/test-ecdh.c
+++ b/unit/test-ecdh.c
@@ -35,13 +35,23 @@ bool __real_l_getrandom(void *buf, size_t len);
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
+	/*
+	 * Note: we at least need enough bytes for the largest curve group,
+	 * currently P384
+	 */
+	static const uint8_t random_buf[] =3D { 0x0b, 0x34, 0x0f, 0x16, 0x02,
+						0x31, 0x88, 0xe1, 0x0e, 0x08,
+						0xb2, 0x5f, 0x03, 0x4c, 0x3c,
+						0xe8, 0x3d, 0xf4, 0xaa, 0xc5,
+						0x8d, 0x2b, 0x1f, 0x43, 0xb8,
+						0x0e, 0xf3, 0xed, 0x73, 0xd0,
+						0xd7, 0x8d, 0x77, 0x62, 0xaf,
+						0xa7, 0x37, 0xca, 0x20, 0x3f,
+						0xd8, 0xf5, 0x32, 0x64, 0x7e,
+						0xf6, 0x45, 0x46 };
+
+	if (len > sizeof(random_buf))
+		return false;
 =

 	if (use_real_getrandom)
 		return __real_l_getrandom(buf, len);
-- =

2.17.1


--===============5878571228110639803==--

