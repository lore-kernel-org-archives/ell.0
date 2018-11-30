Content-Type: multipart/mixed; boundary="===============1864934609515648644=="
MIME-Version: 1.0
From: Luiz Augusto von Dentz <luiz.dentz@gmail.com>
Subject: [PATCH v2 1/2] main: Add support for $NOTIFY_SOCKET
Date: Fri, 30 Nov 2018 11:44:01 +0200
Message-ID: <20181130094402.22111-1-luiz.dentz@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1864934609515648644==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

From: Luiz Augusto von Dentz <luiz.von.dentz@intel.com>

This adds support for sending states to the service manager using the
socket set in $NOTIFY_SOCKET:

https://www.freedesktop.org/software/systemd/man/sd_notify.html
---
 ell/main.c | 71 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 ell/main.h |  2 ++
 2 files changed, 73 insertions(+)

diff --git a/ell/main.c b/ell/main.c
index b1d12b6..029ac8b 100644
--- a/ell/main.c
+++ b/ell/main.c
@@ -28,9 +28,12 @@
 #include <errno.h>
 #include <unistd.h>
 #include <stdlib.h>
+#include <stddef.h>
 #include <limits.h>
 #include <signal.h>
 #include <sys/epoll.h>
+#include <sys/socket.h>
+#include <sys/un.h>
 =

 #include "signal.h"
 #include "queue.h"
@@ -59,6 +62,8 @@ static bool epoll_running;
 static bool epoll_terminate;
 static int idle_id;
 =

+static int notify_fd;
+
 static struct l_queue *idle_list;
 =

 struct watch_data {
@@ -324,6 +329,40 @@ static void idle_dispatch(void *data, void *user_data)
 	idle->flags &=3D ~IDLE_FLAG_DISPATCHING;
 }
 =

+static void create_sd_notify_socket(void)
+{
+	const char *sock;
+	struct sockaddr_un addr;
+
+	/* check if NOTIFY_SOCKET has been set */
+	sock =3D getenv("NOTIFY_SOCKET");
+	if (!sock)
+		return;
+
+	/* check for abstract socket or absolute path */
+	if (sock[0] !=3D '@' && sock[0] !=3D '/')
+		return;
+
+	notify_fd =3D socket(AF_UNIX, SOCK_DGRAM | SOCK_CLOEXEC, 0);
+	if (notify_fd < 0) {
+		notify_fd =3D 0;
+		return;
+	}
+
+	memset(&addr, 0, sizeof(addr));
+	addr.sun_family =3D AF_UNIX;
+	strncpy(addr.sun_path, sock, sizeof(addr.sun_path) - 1);
+
+	if (addr.sun_path[0] =3D=3D '@')
+		addr.sun_path[0] =3D '\0';
+
+	if (bind(notify_fd, (struct sockaddr *) &addr, sizeof(addr)) < 0) {
+		close(notify_fd);
+		notify_fd =3D 0;
+	}
+}
+
+
 /**
  * l_main_init:
  *
@@ -342,6 +381,8 @@ LIB_EXPORT bool l_main_init(void)
 	if (!create_epoll())
 		return false;
 =

+	create_sd_notify_socket();
+
 	epoll_terminate =3D false;
 =

 	return true;
@@ -438,6 +479,11 @@ LIB_EXPORT int l_main_run(void)
 =

 	epoll_running =3D false;
 =

+	if (notify_fd) {
+		close(notify_fd);
+		notify_fd =3D 0;
+	}
+
 	return EXIT_SUCCESS;
 }
 =

@@ -570,3 +616,28 @@ LIB_EXPORT int l_main_get_epoll_fd(void)
 {
 	return epoll_fd;
 }
+
+/**
+ * l_main_sd_notify:
+ *
+ * Notify service manager about start-up completion and other service stat=
us
+ * changes:
+ * https://www.freedesktop.org/software/systemd/man/sd_notify.html
+ *
+ * Returns: On failure, these calls return a negative errno-style error co=
de.
+ * If $NOTIFY_SOCKET was not set and hence no status message could be sent,
+ * -ENOCONN is returned.
+ **/
+LIB_EXPORT int l_main_sd_notify(const char *state)
+{
+	int err;
+
+	if (notify_fd <=3D 0)
+		return -ENOTCONN;
+
+	err =3D send(notify_fd, state, strlen(state), MSG_NOSIGNAL);
+	if (err < 0)
+		return -errno;
+
+	return err;
+}
diff --git a/ell/main.h b/ell/main.h
index 99b34ad..ffa40af 100644
--- a/ell/main.h
+++ b/ell/main.h
@@ -44,6 +44,8 @@ int l_main_run_with_signal(l_main_signal_cb_t callback, v=
oid *user_data);
 =

 int l_main_get_epoll_fd();
 =

+int l_main_sd_notify(const char *state);
+
 #ifdef __cplusplus
 }
 #endif
-- =

2.17.2


--===============1864934609515648644==--

