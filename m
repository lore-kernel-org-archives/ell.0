Content-Type: multipart/mixed; boundary="===============5653925368200012718=="
MIME-Version: 1.0
From: Luiz Augusto von Dentz <luiz.dentz@gmail.com>
Subject: [PATCH v2 2/2] main: Add support for $WATCHDOG_USEC
Date: Fri, 30 Nov 2018 11:44:02 +0200
Message-ID: <20181130094402.22111-2-luiz.dentz@gmail.com>
In-Reply-To: <20181130094402.22111-1-luiz.dentz@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5653925368200012718==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

From: Luiz Augusto von Dentz <luiz.von.dentz@intel.com>

This adds handling to watchdog set by service manager by sending
"WATCHDOG=3D1" to it in intervals shorter than what is set in
$WATCHDOG_USEC.
---
 ell/main.c | 32 ++++++++++++++++++++++++++++++++
 1 file changed, 32 insertions(+)

diff --git a/ell/main.c b/ell/main.c
index 029ac8b..cae1453 100644
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
@@ -64,6 +67,8 @@ static int idle_id;
 =

 static int notify_fd;
 =

+static struct l_timeout *watchdog;
+
 static struct l_queue *idle_list;
 =

 struct watch_data {
@@ -329,10 +334,21 @@ static void idle_dispatch(void *data, void *user_data)
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
 static void create_sd_notify_socket(void)
 {
 	const char *sock;
 	struct sockaddr_un addr;
+	const char *watchdog_usec;
+	int msec;
 =

 	/* check if NOTIFY_SOCKET has been set */
 	sock =3D getenv("NOTIFY_SOCKET");
@@ -359,7 +375,21 @@ static void create_sd_notify_socket(void)
 	if (bind(notify_fd, (struct sockaddr *) &addr, sizeof(addr)) < 0) {
 		close(notify_fd);
 		notify_fd =3D 0;
+		return;
 	}
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

@@ -482,6 +512,8 @@ LIB_EXPORT int l_main_run(void)
 	if (notify_fd) {
 		close(notify_fd);
 		notify_fd =3D 0;
+		l_timeout_remove(watchdog);
+		watchdog =3D NULL;
 	}
 =

 	return EXIT_SUCCESS;
-- =

2.17.2


--===============5653925368200012718==--

