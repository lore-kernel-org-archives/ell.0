Content-Type: multipart/mixed; boundary="===============4185077648453470228=="
MIME-Version: 1.0
From: Ross Burton <ross@burtonini.com>
Subject: [PATCH 1/2] build: pass -no-undefined properly
Date: Tue, 15 Sep 2020 19:00:40 +0100
Message-ID: <20200915180041.2361066-1-ross@burtonini.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4185077648453470228==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

From: Ross Burton <ross.burton@arm.com>

-no-undefined was added to the libell.la LDFLAGS in commit 8391d72d,
back in 2012, as part of adding versioning. I believe there was some
confusion here as passing -no-undefined to libtool is different to
passing -no-undefined to the linker.  The former changes libtool's
behaviour on Windows hosts related to static libraries, the latter will
warn if symbols are used but not defined.
---
 Makefile.am | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/Makefile.am b/Makefile.am
index 4eb20c6..395edc3 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -138,7 +138,7 @@ ell_libell_la_SOURCES =3D $(linux_headers) \
 			ell/gpio.c \
 			ell/path.c
 =

-ell_libell_la_LDFLAGS =3D -no-undefined \
+ell_libell_la_LDFLAGS =3D -Wl,--no-undefined \
 			-Wl,--version-script=3D$(top_srcdir)/ell/ell.sym \
 			-version-info $(ELL_CURRENT):$(ELL_REVISION):$(ELL_AGE)
 =

-- =

2.28.0

--===============4185077648453470228==--

