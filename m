Content-Type: multipart/mixed; boundary="===============7080209303981249070=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/2] unit: Define WAIT_ANY if necessary
Date: Fri, 15 Mar 2019 01:13:31 +0100
Message-ID: <20190315001331.1944-2-andrew.zaborowski@intel.com>
In-Reply-To: <20190315001331.1944-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7080209303981249070==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

WAIT_ANY is not POSIX and musl libc doesn't define it.  Fix based on
http://git.yoctoproject.org/cgit/cgit.cgi/meta-virtualization/tree/recipes-=
networking/openvswitch/openvswitch-git/0002-Define-WAIT_ANY-if-not-provided=
-by-system.patch

Reported-by: Natanael Copa
Tested-by: Natanael Copa
---
 unit/test-dbus-message-fds.c | 4 ++++
 unit/test-dbus-properties.c  | 4 ++++
 unit/test-dbus.c             | 4 ++++
 3 files changed, 12 insertions(+)

diff --git a/unit/test-dbus-message-fds.c b/unit/test-dbus-message-fds.c
index d6d0b38..6f68bae 100644
--- a/unit/test-dbus-message-fds.c
+++ b/unit/test-dbus-message-fds.c
@@ -37,6 +37,10 @@
 #include <ell/ell.h>
 #include "ell/dbus-private.h"
 =

+#ifndef WAIT_ANY
+#define WAIT_ANY (-1) /* Any process */
+#endif
+
 #define TEST_BUS_ADDRESS "unix:path=3D/tmp/ell-test-bus"
 =

 static pid_t dbus_daemon_pid =3D -1;
diff --git a/unit/test-dbus-properties.c b/unit/test-dbus-properties.c
index f91ba73..1844ec0 100644
--- a/unit/test-dbus-properties.c
+++ b/unit/test-dbus-properties.c
@@ -34,6 +34,10 @@
 #include <ell/ell.h>
 #include "ell/dbus-private.h"
 =

+#ifndef WAIT_ANY
+#define WAIT_ANY (-1) /* Any process */
+#endif
+
 #define TEST_BUS_ADDRESS "unix:path=3D/tmp/ell-test-bus"
 =

 static pid_t dbus_daemon_pid =3D -1;
diff --git a/unit/test-dbus.c b/unit/test-dbus.c
index d5bd8c5..67f0a7b 100644
--- a/unit/test-dbus.c
+++ b/unit/test-dbus.c
@@ -31,6 +31,10 @@
 =

 #include <ell/ell.h>
 =

+#ifndef WAIT_ANY
+#define WAIT_ANY (-1) /* Any process */
+#endif
+
 #define TEST_BUS_ADDRESS "unix:path=3D/tmp/ell-test-bus"
 =

 static pid_t dbus_daemon_pid =3D -1;
-- =

2.19.1


--===============7080209303981249070==--

