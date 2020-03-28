Content-Type: multipart/mixed; boundary="===============1445339725615148151=="
MIME-Version: 1.0
From: Fabrice Fontaine <fontaine.fabrice@gmail.com>
Subject: [PATCH] ell/ecc.h: fix build with uclibc
Date: Sat, 28 Mar 2020 12:40:41 +0100
Message-ID: <20200328114041.1084249-1-fontaine.fabrice@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1445339725615148151==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

ssize_t is defined in sys/types.h

Fixes:
 - http://autobuild.buildroot.org/results/444c9deb728fb041e560d940145f96cc4=
f455080

Signed-off-by: Fabrice Fontaine <fontaine.fabrice@gmail.com>
---
 ell/ecc.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/ell/ecc.h b/ell/ecc.h
index 26a5889..65c49e8 100644
--- a/ell/ecc.h
+++ b/ell/ecc.h
@@ -27,6 +27,8 @@
 extern "C" {
 #endif
 =

+#include <sys/types.h> // for ssize_t
+
 #define L_ECC_MAX_DIGITS 6
 #define L_ECC_SCALAR_MAX_BYTES		L_ECC_MAX_DIGITS * 8
 #define L_ECC_POINT_MAX_BYTES		L_ECC_SCALAR_MAX_BYTES * 2
-- =

2.20.1

--===============1445339725615148151==--

