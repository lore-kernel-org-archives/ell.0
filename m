Content-Type: multipart/mixed; boundary="===============8047766177104233407=="
MIME-Version: 1.0
From: maxin.john@gmail.com
Subject: [PATCH] ell: fix build with musl libc
Date: Thu, 05 Apr 2018 17:54:50 +0300
Message-ID: <1522940090-16702-1-git-send-email-maxin.john@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8047766177104233407==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

From: "Maxin B. John" <maxin.john@intel.com>

musl libc doesn't implement TEMP_FAILURE_RETRY. Use the
TEMP_FAILURE_RETRY from glibc to fix build.
---
 ell/dbus.h | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/ell/dbus.h b/ell/dbus.h
index a7c08d2..3ff5e0f 100644
--- a/ell/dbus.h
+++ b/ell/dbus.h
@@ -28,6 +28,16 @@
 #include <stddef.h>
 #include <stdarg.h>
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
 #ifdef __cplusplus
 extern "C" {
 #endif
-- =

2.4.0


--===============8047766177104233407==--

