Content-Type: multipart/mixed; boundary="===============1813806441777917506=="
MIME-Version: 1.0
From: =?unknown-8bit?q?Micha=C5=82?= Lowas-Rzechonek <michal.lowas-rzechonek@silvair.com>
Subject: [PATCH] util: Fix increased alignment error in l_container_of
Date: Mon, 08 Jul 2019 22:15:26 +0200
Message-ID: <20190708201526.15052-1-michal.lowas-rzechonek@silvair.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1813806441777917506==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

From: Micha=C5=82 'Khorne' Lowas-Rzechonek <michal@rzechonek.net>

This fixes build failures when building with -Wcast-align -Werror on
some platforms (most notably: 32bit ARM).
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

2.22.0


--===============1813806441777917506==--

