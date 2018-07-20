Content-Type: multipart/mixed; boundary="===============2297418554703775097=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/3] Move TEMP_FAILURE_RETRY outside dbus.h
Date: Fri, 20 Jul 2018 18:49:49 +0200
Message-ID: <20180720164951.9338-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2297418554703775097==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Make this macro available for the rest of ell in private.h and on the
other hand remove from public header as it doesn't start with "L_".
Note that IWD does optionally use it in rfkill.c and storage.c.
---
 ell/dbus.h    | 10 ----------
 ell/private.h | 11 +++++++++++
 2 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/ell/dbus.h b/ell/dbus.h
index 3ff5e0f..a7c08d2 100644
--- a/ell/dbus.h
+++ b/ell/dbus.h
@@ -28,16 +28,6 @@
 #include <stddef.h>
 #include <stdarg.h>
 =

-/* taken from glibc unistd.h for musl support */
-#ifndef TEMP_FAILURE_RETRY
-#define TEMP_FAILURE_RETRY(expression)             \
-  (__extension__                                   \
-    ({ long int __result;                          \
-       do __result =3D (long int) (expression);      \
-       while (__result =3D=3D -1L && errno =3D=3D EINTR);  \
-       __result; }))
-#endif
-
 #ifdef __cplusplus
 extern "C" {
 #endif
diff --git a/ell/private.h b/ell/private.h
index ed0297d..bf71f6d 100644
--- a/ell/private.h
+++ b/ell/private.h
@@ -21,6 +21,7 @@
  */
 =

 #include <stdint.h>
+#include <errno.h>
 =

 #include <ell/util.h>
 =

@@ -34,6 +35,16 @@
 =

 #define LIB_EXPORT __attribute__ ((visibility("default")))
 =

+/* taken from glibc unistd.h for musl support */
+#ifndef TEMP_FAILURE_RETRY
+#define TEMP_FAILURE_RETRY(expression)             \
+  (__extension__                                   \
+    ({ long int __result;                          \
+       do __result =3D (long int) (expression);      \
+       while (__result =3D=3D -1L && errno =3D=3D EINTR);  \
+       __result; }))
+#endif
+
 struct l_debug_desc;
 =

 void debug_enable(struct l_debug_desc *start, struct l_debug_desc *stop);
-- =

2.14.1


--===============2297418554703775097==--

