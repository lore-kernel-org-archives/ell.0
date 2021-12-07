Content-Type: multipart/mixed; boundary="===============3091455668891067607=="
MIME-Version: 1.0
From: James Prestwood <prestwoj at gmail.com>
To: ell at lists.01.org
Subject: [PATCH] unit: add asserts to unitset test
Date: Mon, 06 Dec 2021 16:05:49 -0800
Message-ID: <20211207000549.1386858-1-prestwoj@gmail.com>

--===============3091455668891067607==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

To satisfy static analysis add a few more return checks
---
 unit/test-uintset.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/unit/test-uintset.c b/unit/test-uintset.c
index 0918ef2..31dc274 100644
--- a/unit/test-uintset.c
+++ b/unit/test-uintset.c
@@ -370,18 +370,18 @@ static void test_uintset_size(const void *user_data)
 =

 	assert(l_uintset_size(set) =3D=3D 0);
 =

-	for (i =3D 0; i < 32; i++) {
-		l_uintset_put(set, i);
+	for (i =3D 1; i < 32; i++) {
+		assert(l_uintset_put(set, i));
 		assert(l_uintset_size(set) =3D=3D i);
 	}
 =

 	assert(l_uintset_size(set) =3D=3D i - 1);
 =

-	l_uintset_take(set, 10);
+	assert(l_uintset_take(set, 10));
 	assert(l_uintset_size(set) =3D=3D i - 2);
 =

-	for (i =3D 0; i < 32; i++)
-		l_uintset_take(set, i);
+	for (i =3D 1; i < 32; i++)
+		assert(l_uintset_take(set, i));
 =

 	assert(l_uintset_size(set) =3D=3D 0);
 }
-- =

2.31.1

--===============3091455668891067607==--

