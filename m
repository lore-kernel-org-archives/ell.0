Content-Type: multipart/mixed; boundary="===============6791686403504262925=="
MIME-Version: 1.0
From: Jan Engelhardt <jengelh@inai.de>
Subject: [PATCH] ell:: build: bump SO version of libell (fwd)
Date: Mon, 26 Nov 2018 10:57:48 +0100
Message-ID: <nycvar.YFH.7.76.1811261057340.25874@n3.vanv.qr>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6791686403504262925==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Commit 0.13-7-g4a386a1 changed the ABI of l_signal_create. This
warrants a bump in the SO version.
---
 Makefile.am | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/Makefile.am b/Makefile.am
index d115360..5a44f40 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -8,8 +8,8 @@ ACLOCAL_AMFLAGS =3D -I build-aux
 # Interfaces added:		CURRENT++ REVISION=3D0 AGE++
 # Interfaces removed:		CURRENT++ REVISION=3D0 AGE=3D0
 =

-ELL_CURRENT =3D 0
-ELL_REVISION =3D 2
+ELL_CURRENT =3D 1
+ELL_REVISION =3D 0
 ELL_AGE =3D 0
 =

 pkginclude_HEADERS =3D ell/ell.h \
-- =

2.19.1

--===============6791686403504262925==--

