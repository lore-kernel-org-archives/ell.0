Content-Type: multipart/mixed; boundary="===============8348268487145941477=="
MIME-Version: 1.0
From: Szymon Janc <szymon.janc@codecoup.pl>
Subject: [PATCH 3/4] unit: Add tests for NULL set in uintset
Date: Wed, 21 Oct 2015 23:13:14 +0200
Message-ID: <1445461995-22036-3-git-send-email-szymon.janc@codecoup.pl>
In-Reply-To: <1445461995-22036-1-git-send-email-szymon.janc@codecoup.pl>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8348268487145941477==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-uintset.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/unit/test-uintset.c b/unit/test-uintset.c
index 7e17113..8d83a2a 100644
--- a/unit/test-uintset.c
+++ b/unit/test-uintset.c
@@ -25,6 +25,7 @@
 #endif
 =

 #include <assert.h>
+#include <limits.h>
 =

 #include <ell/ell.h>
 =

@@ -34,6 +35,10 @@ static void test_uintset(const void *data)
 	int i;
 	bool r;
 =

+	assert(l_uintset_get_min(NULL) =3D=3D UINT_MAX);
+	assert(l_uintset_find_max(NULL) =3D=3D UINT_MAX);
+	assert(l_uintset_find_min(NULL) =3D=3D UINT_MAX);
+
 	set =3D l_uintset_new_from_range(1, 76);
 	assert(set);
 =

-- =

2.6.2


--===============8348268487145941477==--

