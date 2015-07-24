Content-Type: multipart/mixed; boundary="===============7394445268597806526=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 16/17] examples: Add TLS server and client example programs.
Date: Fri, 24 Jul 2015 05:27:51 +0200
Message-ID: <1437708472-28124-7-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1437708472-28124-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7394445268597806526==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 .gitignore                   |   2 +
 Makefile.am                  |   4 +-
 examples/https-client-test.c | 181 +++++++++++++++++++++++++++++++++++++++=
++++
 examples/https-server-test.c | 169 ++++++++++++++++++++++++++++++++++++++++
 4 files changed, 355 insertions(+), 1 deletion(-)
 create mode 100644 examples/https-client-test.c
 create mode 100644 examples/https-server-test.c

diff --git a/.gitignore b/.gitignore
index c50d7e7..4f964de 100644
--- a/.gitignore
+++ b/.gitignore
@@ -51,4 +51,6 @@ unit/test-cert
 unit/*.log
 unit/*.trs
 examples/dbus-service
+examples/https-server-test
+examples/https-client-test
 test-suite.log
diff --git a/Makefile.am b/Makefile.am
index 0896100..1708341 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -206,13 +206,15 @@ unit_example_plugin_la_LDFLAGS =3D -no-undefined -mod=
ule -avoid-version \
 =

 unit_test_data_files =3D unit/settings.test unit/cert-ca.pem unit/cert-cli=
ent.pem unit/cert-server.pem unit/cert-client-key.pem unit/cert-server-key.=
pem
 =

-examples =3D examples/dbus-service
+examples =3D examples/dbus-service examples/https-client-test examples/htt=
ps-server-test
 =

 if MAINTAINER_MODE
 noinst_PROGRAMS +=3D $(examples)
 endif
 =

 examples_dbus_service_LDADD =3D ell/libell-private.la
+examples_https_client_test_LDADD =3D ell/libell-private.la
+examples_https_server_test_LDADD =3D ell/libell-private.la
 =

 EXTRA_DIST =3D $(unit_test_data_files)
 =

diff --git a/examples/https-client-test.c b/examples/https-client-test.c
new file mode 100644
index 0000000..9b12039
--- /dev/null
+++ b/examples/https-client-test.c
@@ -0,0 +1,181 @@
+/*
+ *  Embedded Linux library
+ *
+ *  Copyright (C) 2011-2014  Intel Corporation. All rights reserved.
+ *
+ *  This library is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU Lesser General Public
+ *  License as published by the Free Software Foundation; either
+ *  version 2.1 of the License, or (at your option) any later version.
+ *
+ *  This library is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ *  Lesser General Public License for more details.
+ *
+ *  You should have received a copy of the GNU Lesser General Public
+ *  License along with this library; if not, write to the Free Software
+ *  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 =
 USA
+ */
+
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif
+
+#include <sys/socket.h>
+#include <sys/types.h>
+#include <netinet/in.h>
+#include <netdb.h>
+#include <stdio.h>
+#include <string.h>
+#include <stdlib.h>
+#include <unistd.h>
+#include <errno.h>
+#include <arpa/inet.h>
+
+#include <ell/ell.h>
+
+static struct l_io *io;
+static struct l_tls *tls;
+static const char *hostname;
+
+static void https_io_disconnect(struct l_io *io, void *user_data)
+{
+	l_main_quit();
+}
+
+static bool https_io_read(struct l_io *io, void *user_data)
+{
+	uint8_t buf[2048];
+	int l;
+
+	l =3D read(l_io_get_fd(io), buf, sizeof(buf));
+	if (l =3D=3D 0)
+		l_main_quit();
+	else if (l > 0)
+		l_tls_handle_rx(tls, buf, l);
+
+	return true;
+}
+
+static void https_tls_disconnected(void *user_data,
+					enum l_tls_alert_desc reason,
+					bool remote)
+{
+	if (reason)
+		printf("TLS error: %s\n", l_tls_alert_to_str(reason));
+	l_main_quit();
+}
+
+static void https_new_data(void *user_data, const uint8_t *data, size_t le=
n)
+{
+	int r;
+
+	while (len) {
+		r =3D write(1, data, len);
+		if (r < 0) {
+			l_main_quit();
+			break;
+		}
+		len -=3D r;
+		data +=3D r;
+	}
+}
+
+static void https_tls_write(void *user_data, const uint8_t *data, size_t l=
en)
+{
+	int r;
+
+	while (len) {
+		r =3D write(l_io_get_fd(io), data, len);
+		if (r < 0) {
+			l_main_quit();
+			break;
+		}
+		len -=3D r;
+		data +=3D r;
+	}
+}
+
+static void https_tls_ready(void *user_data, const char *peer_identity)
+{
+	uint8_t buf[2048];
+	int l;
+
+	if (peer_identity)
+		printf("Server authenticated as %s\n", peer_identity);
+	else
+		printf("Server not authenticated\n");
+
+	l =3D snprintf((char *) buf, sizeof(buf),
+			"HEAD / HTTP/1.1\r\n"
+			"Connection: close\r\n"
+			"Host: %s\r\n\r\n", hostname);
+	l_tls_write(tls, buf, l);
+}
+
+int main(int argc, char *argv[])
+{
+	struct hostent *he;
+	struct in_addr **addr_list;
+	struct sockaddr_in addr;
+	int fd;
+
+	if (argc !=3D 2 && argc !=3D 3 && argc !=3D 6) {
+		printf("Usage: %s <https-host-name> [<ca-cert-path> "
+				"[<client-cert-path> <client-key-path> "
+				"<client-key-passphrase>]]\n"
+				"Note: The passphrase will be ignored if the "
+				"key is not encrypted.\n",
+				argv[0]);
+		return -1;
+	}
+
+	l_log_set_stderr();
+
+	hostname =3D argv[1];
+	he =3D gethostbyname(hostname);
+	if (!he) {
+		printf("gethostbyname: %s\n", strerror(errno));
+		return -1;
+	}
+
+	addr_list =3D (struct in_addr **) he->h_addr_list;
+	if (!addr_list) {
+		printf("No host addresses found\n");
+		return -1;
+	}
+
+	fd =3D socket(AF_INET, SOCK_STREAM, 0);
+	if (fd < 0) {
+		printf("socket: %s\n", strerror(errno));
+		return -1;
+	}
+
+	addr.sin_family =3D AF_INET;
+	addr.sin_port =3D htons(443);
+	memcpy(&addr.sin_addr, addr_list[0], sizeof(addr.sin_addr));
+	if (connect(fd, (struct sockaddr *) &addr, sizeof(addr)) < 0) {
+		printf("connect: %s\n", strerror(errno));
+		return -1;
+	}
+
+	io =3D l_io_new(fd);
+	l_io_set_close_on_destroy(io, true);
+	l_io_set_read_handler(io, https_io_read, tls, NULL);
+	l_io_set_disconnect_handler(io, https_io_disconnect, tls, NULL);
+
+	tls =3D l_tls_new(false, https_new_data, https_tls_write,
+			https_tls_ready, https_tls_disconnected, NULL);
+	if (argc > 2)
+		l_tls_set_cacert(tls, argv[2]);
+	if (argc > 5)
+		l_tls_set_auth_data(tls, argv[3], argv[4], argv[5]);
+
+	l_main_run();
+
+	l_io_destroy(io);
+	l_tls_free(tls);
+
+	return 0;
+}
diff --git a/examples/https-server-test.c b/examples/https-server-test.c
new file mode 100644
index 0000000..a666a00
--- /dev/null
+++ b/examples/https-server-test.c
@@ -0,0 +1,169 @@
+/*
+ *  Embedded Linux library
+ *
+ *  Copyright (C) 2011-2014  Intel Corporation. All rights reserved.
+ *
+ *  This library is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU Lesser General Public
+ *  License as published by the Free Software Foundation; either
+ *  version 2.1 of the License, or (at your option) any later version.
+ *
+ *  This library is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ *  Lesser General Public License for more details.
+ *
+ *  You should have received a copy of the GNU Lesser General Public
+ *  License along with this library; if not, write to the Free Software
+ *  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 =
 USA
+ */
+
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif
+
+#include <sys/socket.h>
+#include <sys/types.h>
+#include <netinet/in.h>
+#include <netdb.h>
+#include <stdio.h>
+#include <string.h>
+#include <stdlib.h>
+#include <unistd.h>
+#include <errno.h>
+#include <arpa/inet.h>
+
+#include <ell/ell.h>
+
+static struct l_io *io;
+static struct l_tls *tls;
+bool served;
+
+static void https_io_disconnect(struct l_io *io, void *user_data)
+{
+	if (!served)
+		printf("Disconnected before serving a page\n");
+	l_main_quit();
+}
+
+static bool https_io_read(struct l_io *io, void *user_data)
+{
+	uint8_t buf[2048];
+	int l;
+
+	l =3D read(l_io_get_fd(io), buf, sizeof(buf));
+	if (l =3D=3D 0)
+		l_main_quit();
+	else if (l > 0)
+		l_tls_handle_rx(tls, buf, l);
+
+	return true;
+}
+
+static void https_tls_disconnected(void *user_data,
+					enum l_tls_alert_desc reason,
+					bool remote)
+{
+	if (reason)
+		printf("TLS error: %s\n", l_tls_alert_to_str(reason));
+	l_main_quit();
+}
+
+static void https_new_data(void *user_data, const uint8_t *data, size_t le=
n)
+{
+	char *reply =3D "HTTP/1.1 200 OK\r\n"
+		"Content-Type: text/plain\r\n"
+		"Connection: close\r\n"
+		"\r\n"
+		"Hello, world!\n";
+
+	if (len >=3D 4 && !memcmp(data + len - 4, "\r\n\r\n", 4)) {
+		l_tls_write(tls, (void *) reply, strlen(reply));
+		l_tls_close(tls);
+		served =3D true;
+		printf("Hello world page served\n");
+	}
+}
+
+static void https_tls_write(void *user_data, const uint8_t *data, size_t l=
en)
+{
+	int r;
+
+	while (len) {
+		r =3D write(l_io_get_fd(io), data, len);
+		if (r < 0) {
+			l_main_quit();
+			break;
+		}
+		len -=3D r;
+		data +=3D r;
+	}
+}
+
+static void https_tls_ready(void *user_data, const char *peer_identity)
+{
+	if (peer_identity)
+		printf("Client authenticated as %s\n", peer_identity);
+	else
+		printf("Client not authenticated\n");
+}
+
+int main(int argc, char *argv[])
+{
+	struct sockaddr_in addr;
+	int fd, listenfd;
+
+	if (argc !=3D 4 && argc !=3D 5) {
+		printf("Usage: %s <server-cert-path> <server-key-path> "
+				"<server-key-passphrase> [<ca-cert-path>]\n"
+				"Note: The passphrase will be ignored if the "
+				"key is not encrypted.\n",
+				argv[0]);
+
+		return -1;
+	}
+
+	l_log_set_stderr();
+
+	listenfd =3D socket(AF_INET, SOCK_STREAM, 0);
+	setsockopt(listenfd, SOL_SOCKET, SO_REUSEADDR, &(int) { 1 },
+			sizeof(int));
+	addr.sin_family =3D AF_INET;
+	addr.sin_addr.s_addr =3D htonl(INADDR_ANY);
+	addr.sin_port =3D htons(1234);
+
+	if (bind(listenfd, (struct sockaddr *) &addr, sizeof(addr)) =3D=3D -1) {
+		printf("bind: %s\n", strerror(errno));
+		return -1;
+	}
+	if (listen(listenfd, 1) =3D=3D -1) {
+		printf("listen: %s\n", strerror(errno));
+		return -1;
+	}
+
+	printf("Try https://localhost:1234/ now\n");
+
+	fd =3D accept(listenfd, NULL, NULL);
+	close(listenfd);
+	if (fd =3D=3D -1) {
+		printf("accept: %s\n", strerror(errno));
+		return -1;
+	}
+
+	io =3D l_io_new(fd);
+	l_io_set_close_on_destroy(io, true);
+	l_io_set_read_handler(io, https_io_read, tls, NULL);
+	l_io_set_disconnect_handler(io, https_io_disconnect, tls, NULL);
+
+	tls =3D l_tls_new(true, https_new_data, https_tls_write,
+			https_tls_ready, https_tls_disconnected, NULL);
+	l_tls_set_auth_data(tls, argv[1], argv[2], argv[3]);
+	l_tls_set_cacert(tls, argc > 4 ? argv[4] : NULL);
+
+	l_main_run();
+
+	l_io_destroy(io);
+	l_tls_free(tls);
+
+	return 0;
+}
-- =

2.1.4


--===============7394445268597806526==--

