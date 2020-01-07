Content-Type: multipart/mixed; boundary="===============7557226697190692850=="
MIME-Version: 1.0
From: =?unknown-8bit?q?Micha=C5=82?= Lowas-Rzechonek <michal.lowas-rzechonek@silvair.com>
Subject: [PATCH] util: Fix -Wcast-align error in l_container_of
Date: Tue, 07 Jan 2020 23:34:31 +0100
Message-ID: <20200107223431.4573-1-michal.lowas-rzechonek@silvair.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7557226697190692850==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This fixes the following build warning:

ell/util.h:40:3: error: cast increases required alignment of target type [-=
Werror=3Dcast-align]
   (type *)((char *) __mptr - offsetof(type, member)); \

Which is a false positive, as recalculating struct pointer does
not affect alignment requirements of the pointer in any way.
---
 ell/util.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/util.h b/ell/util.h
index 4f20ef0..fe7c7e2 100644
--- a/ell/util.h
+++ b/ell/util.h
@@ -37,7 +37,7 @@ extern "C" {
 =

 #define l_container_of(ptr, type, member) ({				\
 		const __typeof__(((type *) 0)->member) *__mptr =3D (ptr);	\
-		(type *)((char *) __mptr - offsetof(type, member));	\
+		(type *)(void *)((char *) __mptr - offsetof(type, member));	\
 	})
 =

 #define likely(x)   __builtin_expect(!!(x), 1)
-- =

2.23.0

--===============7557226697190692850==--

