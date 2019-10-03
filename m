Content-Type: multipart/mixed; boundary="===============8023357616486976527=="
MIME-Version: 1.0
From: Natanael Copa <ncopa@alpinelinux.org>
Subject: [PATCH] unit: fix build with musl libc
Date: Thu, 03 Oct 2019 17:03:06 +0200
Message-ID: <20191003150306.11761-1-ncopa@alpinelinux.org>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8023357616486976527==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Define WAIT_ANY if needed. It is not specified in POSIX so we cannot
expect it to be defined.

This fixes build with musl libc.
---
 unit/test-dbus-message-fds.c | 4 ++++
 unit/test-dbus-properties.c  | 4 ++++
 unit/test-dbus.c             | 4 ++++
 3 files changed, 12 insertions(+)

diff --git a/unit/test-dbus-message-fds.c b/unit/test-dbus-message-fds.c
index 6f68bae..6a23141 100644
--- a/unit/test-dbus-message-fds.c
+++ b/unit/test-dbus-message-fds.c
@@ -41,6 +41,10 @@
 #define WAIT_ANY (-1) /* Any process */
 #endif
 =

+#ifndef WAIT_ANY
+#define WAIT_ANY (-1)
+#endif
+
 #define TEST_BUS_ADDRESS "unix:path=3D/tmp/ell-test-bus"
 =

 static pid_t dbus_daemon_pid =3D -1;
diff --git a/unit/test-dbus-properties.c b/unit/test-dbus-properties.c
index 1844ec0..7847c10 100644
--- a/unit/test-dbus-properties.c
+++ b/unit/test-dbus-properties.c
@@ -38,6 +38,10 @@
 #define WAIT_ANY (-1) /* Any process */
 #endif
 =

+#ifndef WAIT_ANY
+#define WAIT_ANY (-1)
+#endif
+
 #define TEST_BUS_ADDRESS "unix:path=3D/tmp/ell-test-bus"
 =

 static pid_t dbus_daemon_pid =3D -1;
diff --git a/unit/test-dbus.c b/unit/test-dbus.c
index 67f0a7b..05de3f9 100644
--- a/unit/test-dbus.c
+++ b/unit/test-dbus.c
@@ -35,6 +35,10 @@
 #define WAIT_ANY (-1) /* Any process */
 #endif
 =

+#ifndef WAIT_ANY
+#define WAIT_ANY (-1)
+#endif
+
 #define TEST_BUS_ADDRESS "unix:path=3D/tmp/ell-test-bus"
 =

 static pid_t dbus_daemon_pid =3D -1;
-- =

2.23.0

--===============8023357616486976527==--

