Content-Type: multipart/mixed; boundary="===============5564353892527332749=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 01/12] dbus: Kdbus message timeout_ns is absolute time
Date: Sun, 10 Apr 2016 06:02:33 +0200
Message-ID: <1460260961-9183-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5564353892527332749==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

It is even documented in systemd, although not very clearly, that
timeout_ns is a CLOCK_MONOTONIC_COARSE-based absolute value.
---
 ell/dbus-kernel.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/ell/dbus-kernel.c b/ell/dbus-kernel.c
index f45ec04..2b41177 100644
--- a/ell/dbus-kernel.c
+++ b/ell/dbus-kernel.c
@@ -34,6 +34,7 @@
 #include <errno.h>
 #include <sys/mman.h>
 #include <sys/ioctl.h>
+#include <time.h>
 =

 #include "linux/kdbus.h"
 =

@@ -392,8 +393,16 @@ int _dbus_kernel_send(int fd, size_t bloom_size, uint8=
_t bloom_n_hash,
 		break;
 	}
 	case DBUS_MESSAGE_TYPE_METHOD_CALL:
-		if (!l_dbus_message_get_no_reply(message))
-			kmsg->timeout_ns =3D 30000 * 1000000ULL;
+		if (!l_dbus_message_get_no_reply(message)) {
+			struct timespec now;
+
+			clock_gettime(CLOCK_MONOTONIC_COARSE, &now);
+
+			kmsg->timeout_ns =3D
+				now.tv_sec * 1000000000ULL + now.tv_nsec +
+				30000 * 1000000ULL;
+		}
+
 		break;
 	case DBUS_MESSAGE_TYPE_SIGNAL:
 		kmsg->flags |=3D KDBUS_MSG_SIGNAL;
-- =

2.5.0


--===============5564353892527332749==--

