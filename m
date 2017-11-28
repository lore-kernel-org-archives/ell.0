Content-Type: multipart/mixed; boundary="===============8004267636859945785=="
MIME-Version: 1.0
From: Szymon Janc <szymon.janc@codecoup.pl>
Subject: [PATCH] build: Fix parallel build
Date: Tue, 28 Nov 2017 14:29:18 +0100
Message-ID: <20171128132918.28219-1-szymon.janc@codecoup.pl>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8004267636859945785==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

  GEN      unit/cert-intca.pem
  GEN      unit/cert-server.pem
  GEN      unit/cert-chain.pem
  GEN      unit/cert-entity-int.pem
  CCLD     unit/test-pem
  CCLD     unit/test-tls
  CCLD     unit/test-key
libtool:   error: cannot find the library 'ell/libell-private.la' or
    unhandled argument 'ell/libell-private.la'
make[1]: *** [Makefile:1392: unit/test-tls] Error 1
make[1]: *** Waiting for unfinished jobs....
libtool:   error: cannot find the library 'ell/libell-private.la' or
     unhandled argument 'ell/libell-private.la'
make[1]: *** [Makefile:1344: unit/test-pem] Error 1
make: *** [Makefile:1000: all] Error 2
---
 Makefile.am | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/Makefile.am b/Makefile.am
index 9b4ca06..a95bac4 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -238,13 +238,13 @@ unit_test_base64_LDADD =3D ell/libell-private.la
 unit_test_pbkdf2_LDADD =3D ell/libell-private.la
 =

 unit_test_pem_LDADD =3D ell/libell-private.la
-unit_test_pem_DEPENDENCIES =3D $(cert_files)
+unit_test_pem_DEPENDENCIES =3D $(cert_files) ell/libell-private.la
 =

 unit_test_tls_LDADD =3D ell/libell-private.la
-unit_test_tls_DEPENDENCIES =3D $(cert_files)
+unit_test_tls_DEPENDENCIES =3D $(cert_files) ell/libell-private.la
 =

 unit_test_key_LDADD =3D ell/libell-private.la
-unit_test_key_DEPENDENCIES =3D $(cert_files)
+unit_test_key_DEPENDENCIES =3D $(cert_files) ell/libell-private.la
 =

 unit_test_uuid_LDADD =3D ell/libell-private.la
 =

-- =

2.14.3


--===============8004267636859945785==--

