Content-Type: multipart/mixed; boundary="===============6867820264180469445=="
MIME-Version: 1.0
From: Lukas Rusak <lrusak@libreelec.tv>
Subject: [PATCH 4/5] Makefile.am: remove kdbus
Date: Fri, 17 Mar 2017 13:10:30 -0700
Message-ID: <20170317201031.4927-4-lrusak@libreelec.tv>
In-Reply-To: <20170317201031.4927-1-lrusak@libreelec.tv>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6867820264180469445==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

From: Lukas Rusak <lorusak@gmail.com>

---
 Makefile.am | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/Makefile.am b/Makefile.am
index d6863ba..d2e33de 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -12,8 +12,6 @@ ELL_CURRENT =3D 0
 ELL_REVISION =3D 0
 ELL_AGE =3D 0
 =

-linux_headers =3D linux/kdbus.h
-
 pkginclude_HEADERS =3D ell/ell.h \
 			ell/util.h \
 			ell/test.h \
@@ -71,7 +69,6 @@ ell_libell_la_SOURCES =3D $(linux_headers) \
 			ell/genl.c \
 			ell/dbus-private.h \
 			ell/dbus.c \
-			ell/dbus-kernel.c \
 			ell/dbus-message.c \
 			ell/dbus-util.c \
 			ell/dbus-service.c \
@@ -135,8 +132,7 @@ unit_tests =3D unit/test-unit \
 			unit/test-uuid \
 			unit/test-key
 =

-dbus_tests =3D unit/test-kdbus \
-			unit/test-dbus \
+dbus_tests =3D unit/test-dbus \
 			unit/test-dbus-util \
 			unit/test-dbus-message \
 			unit/test-dbus-message-fds \
@@ -180,8 +176,6 @@ unit_test_genl_LDADD =3D ell/libell-private.la
 =

 unit_test_genl_msg_LDADD =3D ell/libell-private.la
 =

-unit_test_kdbus_LDADD =3D ell/libell-private.la
-
 unit_test_dbus_LDADD =3D ell/libell-private.la
 =

 unit_test_dbus_message_LDADD =3D ell/libell-private.la
-- =

2.9.3


--===============6867820264180469445==--

