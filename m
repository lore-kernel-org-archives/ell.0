Content-Type: multipart/mixed; boundary="===============4108067717210437064=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman at gmail.com>
To: ell at lists.01.org
Subject: [PATCH 3/3] Makefile: Bump library 'current' version.
Date: Tue, 09 Nov 2021 16:14:48 -0800
Message-ID: <20211110001448.175980-4-ossama.othman@intel.com>
In-Reply-To: 20211110001448.175980-1-ossama.othman@intel.com

--===============4108067717210437064==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The l_rtnl interface changed.  Bump the "current" ELL library version
number accordingly.
---
 Makefile.am | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/Makefile.am b/Makefile.am
index 4e650c9..73f5298 100644
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

 linux_headers =3D linux/gpio.h
-- =

2.32.0

--===============4108067717210437064==--

