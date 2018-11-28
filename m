Content-Type: multipart/mixed; boundary="===============2320554460399211081=="
MIME-Version: 1.0
From: Luiz Augusto von Dentz <luiz.dentz@gmail.com>
Subject: [PATCH 2/2] main: Add support for $WATCHDOG_USEC
Date: Wed, 28 Nov 2018 14:16:31 +0200
Message-ID: <20181128121631.31642-2-luiz.dentz@gmail.com>
In-Reply-To: <20181128121631.31642-1-luiz.dentz@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2320554460399211081==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

From: Luiz Augusto von Dentz <luiz.von.dentz@intel.com>

This adds handling to watchdog set by service manager by sending
"WATCHDOG=3D1" to it in intervals shorter than what is set in
$WATCHDOG_USEC.
---
 ell/main.c | 35 ++++++++++++++++++++++++++++++++++-
 1 file changed, 34 insertions(+), 1 deletion(-)

diff --git a/ell/main.c b/ell/main.c
index 7eedf1a..a59de16 100644
--- a/ell/main.c
+++ b/ell/main.c
@@ -41,6 +41,7 @@
 #include "util.h"
 #include "main.h"
 #include "private.h"
+#include "timeout.h"
 =

 /**
  * SECTION:main
@@ -57,6 +58,8 @@
 #define WATCH_FLAG_DISPATCHING	1
 #define WATCH_FLAG_DESTROYED	2
 =

+#define WATCHDOG_TRIGGER_FREQ	2
+
 static int epoll_fd;
 static bool epoll_running;
 static bool epoll_terminate;
@@ -65,6 +68,8 @@ static int idle_id;
 static char *notify_sock;
 static int notify_fd;
 =

+static struct l_timeout *watchdog;
+
 static struct l_queue *idle_list;
 =

 struct watch_data {
@@ -330,9 +335,20 @@ static void idle_dispatch(void *data, void *user_data)
 	idle->flags &=3D ~IDLE_FLAG_DISPATCHING;
 }
 =

+static void watchdog_callback(struct l_timeout *timeout, void *user_data)
+{
+	int msec =3D L_PTR_TO_INT(user_data);
+
+	l_main_sd_notify("WATCHDOG=3D1");
+
+	l_timeout_modify_ms(timeout, msec);
+}
+
 static inline void __attribute__ ((always_inline)) notify_socket(void)
 {
 	const char *sock;
+	const char *watchdog_usec;
+	int msec;
 =

 	/* check if NOTIFY_SOCKET has been set */
 	sock =3D getenv("NOTIFY_SOCKET");
@@ -346,8 +362,23 @@ static inline void __attribute__ ((always_inline)) not=
ify_socket(void)
 	notify_sock =3D l_strdup(sock);
 =

 	notify_fd =3D socket(AF_UNIX, SOCK_DGRAM | SOCK_CLOEXEC, 0);
-	if (notify_fd < 0)
+	if (notify_fd < 0) {
 		notify_fd =3D 0;
+		return;
+	}
+
+	watchdog_usec =3D getenv("WATCHDOG_USEC");
+	if (!watchdog_usec)
+		return;
+
+	msec =3D atoi(watchdog_usec) / 1000;
+	if (msec < 0)
+		return;
+
+	msec /=3D WATCHDOG_TRIGGER_FREQ;
+
+	watchdog =3D l_timeout_create_ms(msec, watchdog_callback,
+					L_INT_TO_PTR(msec), NULL);
 }
 =

 =

@@ -472,6 +503,8 @@ LIB_EXPORT int l_main_run(void)
 		notify_fd =3D 0;
 		l_free(notify_sock);
 		notify_sock =3D NULL;
+		l_timeout_remove(watchdog);
+		watchdog =3D NULL;
 	}
 =

 	return EXIT_SUCCESS;
-- =

2.17.2


--===============2320554460399211081==--

