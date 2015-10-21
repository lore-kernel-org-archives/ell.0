Content-Type: multipart/mixed; boundary="===============8328052572566301360=="
MIME-Version: 1.0
From: Szymon Janc <szymon.janc@codecoup.pl>
Subject: [PATCH 1/4] uintset: Fix memory leak in l_uintset_new_from_range
Date: Wed, 21 Oct 2015 23:13:12 +0200
Message-ID: <1445461995-22036-1-git-send-email-szymon.janc@codecoup.pl>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8328052572566301360==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Allocate ret only after checking size parameter.
---
 ell/uintset.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/ell/uintset.c b/ell/uintset.c
index 3d9c8e3..4547ac9 100644
--- a/ell/uintset.c
+++ b/ell/uintset.c
@@ -149,12 +149,13 @@ struct l_uintset {
 LIB_EXPORT struct l_uintset *l_uintset_new_from_range(uint32_t min,
 								uint32_t max)
 {
-	struct l_uintset *ret =3D l_new(struct l_uintset, 1);
+	struct l_uintset *ret;
 	unsigned int size =3D max - min + 1;
 =

 	if (size > USHRT_MAX)
 		return NULL;
 =

+	ret =3D l_new(struct l_uintset, 1);
 	ret->bits =3D l_new(unsigned long,
 				(size + BITS_PER_LONG - 1) / BITS_PER_LONG);
 	ret->size =3D size;
-- =

2.6.2


--===============8328052572566301360==--

