Content-Type: multipart/mixed; boundary="===============0038284902112732237=="
MIME-Version: 1.0
From: Luiz Augusto von Dentz <luiz.dentz@gmail.com>
Subject: [PATCH 1/2] main: Add support for $NOTIFY_SOCKET
Date: Wed, 28 Nov 2018 14:16:30 +0200
Message-ID: <20181128121631.31642-1-luiz.dentz@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0038284902112732237==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

From: Luiz Augusto von Dentz <luiz.von.dentz@intel.com>

This adds support for sending states to the service manager using the
socket set in $NOTIFY_SOCKET:

https://www.freedesktop.org/software/systemd/man/sd_notify.html
---
 ell/main.c | 80 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 ell/main.h |  2 ++
 2 files changed, 82 insertions(+)

diff --git a/ell/main.c b/ell/main.c
index b1d12b6..7eedf1a 100644
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
@@ -59,6 +62,9 @@ static bool epoll_running;
 static bool epoll_terminate;
 static int idle_id;
 =

+static char *notify_sock;
+static int notify_fd;
+
 static struct l_queue *idle_list;
 =

 struct watch_data {
@@ -324,6 +330,27 @@ static void idle_dispatch(void *data, void *user_data)
 	idle->flags &=3D ~IDLE_FLAG_DISPATCHING;
 }
 =

+static inline void __attribute__ ((always_inline)) notify_socket(void)
+{
+	const char *sock;
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
+	notify_sock =3D l_strdup(sock);
+
+	notify_fd =3D socket(AF_UNIX, SOCK_DGRAM | SOCK_CLOEXEC, 0);
+	if (notify_fd < 0)
+		notify_fd =3D 0;
+}
+
+
 /**
  * l_main_init:
  *
@@ -342,6 +369,8 @@ LIB_EXPORT bool l_main_init(void)
 	if (!create_epoll())
 		return false;
 =

+	notify_socket();
+
 	epoll_terminate =3D false;
 =

 	return true;
@@ -438,6 +467,13 @@ LIB_EXPORT int l_main_run(void)
 =

 	epoll_running =3D false;
 =

+	if (notify_fd) {
+		close(notify_fd);
+		notify_fd =3D 0;
+		l_free(notify_sock);
+		notify_sock =3D NULL;
+	}
+
 	return EXIT_SUCCESS;
 }
 =

@@ -570,3 +606,47 @@ LIB_EXPORT int l_main_get_epoll_fd(void)
 {
 	return epoll_fd;
 }
+
+/**
+ * l_main_sd_notify:
+ *
+ * Notify service manager about start-up completion and other service stat=
us
+ * changes.
+ *
+ * Returns: On failure, these calls return a negative errno-style error co=
de.
+ * If $NOTIFY_SOCKET was not set and hence no status message could be sent,
+ * -ENOCONN is returned.
+ **/
+LIB_EXPORT int l_main_sd_notify(const char *state)
+{
+	struct sockaddr_un addr;
+	struct msghdr msghdr;
+	struct iovec iovec;
+
+	if (!notify_fd)
+		return -ENOTCONN;
+
+	memset(&addr, 0, sizeof(addr));
+	addr.sun_family =3D AF_UNIX;
+	strncpy(addr.sun_path, notify_sock, sizeof(addr.sun_path) - 1);
+
+	if (addr.sun_path[0] =3D=3D '@')
+		addr.sun_path[0] =3D '\0';
+
+	memset(&iovec, 0, sizeof(iovec));
+	iovec.iov_base =3D (char *) state;
+	iovec.iov_len =3D strlen(state);
+
+	memset(&msghdr, 0, sizeof(msghdr));
+	msghdr.msg_name =3D &addr;
+	msghdr.msg_namelen =3D offsetof(struct sockaddr_un, sun_path) +
+							strlen(notify_sock);
+
+	if (msghdr.msg_namelen > sizeof(struct sockaddr_un))
+		msghdr.msg_namelen =3D sizeof(struct sockaddr_un);
+
+	msghdr.msg_iov =3D &iovec;
+	msghdr.msg_iovlen =3D 1;
+
+	return sendmsg(notify_fd, &msghdr, MSG_NOSIGNAL);
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


--===============0038284902112732237==--

