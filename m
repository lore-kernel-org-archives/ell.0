Content-Type: multipart/mixed; boundary="===============6319787109351809965=="
MIME-Version: 1.0
From: Ross Burton <ross@burtonini.com>
Subject: [PATCH 1/2] build: pass -no-undefined properly
Date: Wed, 14 Oct 2020 11:46:42 +0100
Message-ID: <20201014104643.3993077-1-ross@burtonini.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6319787109351809965==
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
index 9b3e3c9..7518c6a 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -141,7 +141,7 @@ ell_libell_la_SOURCES =3D $(linux_headers) \
 			ell/icmp6.c \
 			ell/icmp6-private.h
 =

-ell_libell_la_LDFLAGS =3D -no-undefined \
+ell_libell_la_LDFLAGS =3D -Wl,--no-undefined \
 			-Wl,--version-script=3D$(top_srcdir)/ell/ell.sym \
 			-version-info $(ELL_CURRENT):$(ELL_REVISION):$(ELL_AGE)
 =

-- =

2.28.0

--===============6319787109351809965==--

