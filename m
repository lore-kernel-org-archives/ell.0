Content-Type: multipart/mixed; boundary="===============5401831259253163209=="
MIME-Version: 1.0
From: Fabrice Fontaine <fontaine.fabrice@gmail.com>
Subject: [PATCH] ell/cipher.c: fix build on uclibc
Date: Sun, 17 Jan 2021 14:46:18 +0100
Message-ID: <20210117134618.343640-1-fontaine.fabrice@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5401831259253163209==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Include missing.h to avoid a build failure when explicit_bzero is
missing

Signed-off-by: Fabrice Fontaine <fontaine.fabrice@gmail.com>
---
 ell/cipher.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/ell/cipher.c b/ell/cipher.c
index 5d67d7a..e274459 100644
--- a/ell/cipher.c
+++ b/ell/cipher.c
@@ -34,6 +34,7 @@
 #include "cipher.h"
 #include "private.h"
 #include "random.h"
+#include "missing.h"
 =

 #ifndef HAVE_LINUX_IF_ALG_H
 #ifndef HAVE_LINUX_TYPES_H
-- =

2.29.2

--===============5401831259253163209==--

