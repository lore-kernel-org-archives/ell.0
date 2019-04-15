Content-Type: multipart/mixed; boundary="===============1205874960537287740=="
MIME-Version: 1.0
From: Ramon Ribeiro <rhpr@cesar.org.br>
Subject: [PATCH v1 1/2] dbus: Add support to tcp address
Date: Mon, 15 Apr 2019 09:23:26 -0300
Message-ID: <1555331007-26977-2-git-send-email-rhpr@cesar.org.br>
In-Reply-To: <1555331007-26977-1-git-send-email-rhpr@cesar.org.br>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1205874960537287740==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This patch allows a dbus client to connect to a dbus-daemon server
address listenning a TCP transport protocol.
A non-blocking TCP socket is created to avoid blocking the main event
loop.
---
 ell/dbus.c | 151 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++=
++--
 1 file changed, 146 insertions(+), 5 deletions(-)

diff --git a/ell/dbus.c b/ell/dbus.c
index 3a84c90..3a495d0 100644
--- a/ell/dbus.c
+++ b/ell/dbus.c
@@ -31,8 +31,11 @@
 #include <stdarg.h>
 #include <stdlib.h>
 #include <string.h>
+#include <netdb.h>
 #include <sys/socket.h>
 #include <sys/un.h>
+#include <sys/select.h>
+#include <netinet/in.h>
 #include <errno.h>
 =

 #include "util.h"
@@ -75,6 +78,7 @@ struct l_dbus_ops {
 struct l_dbus {
 	struct l_io *io;
 	char *guid;
+	char *transport;
 	bool negotiate_unix_fd;
 	bool support_unix_fd;
 	bool is_ready;
@@ -466,7 +470,8 @@ static bool auth_read_handler(struct l_io *io, void *us=
er_data)
 				return false;
 =

 			break;
-		}
+		} else if (len =3D=3D 0)
+			close(fd);
 =

 		offset +=3D len;
 	}
@@ -511,7 +516,10 @@ static bool auth_read_handler(struct l_io *io, void *u=
ser_data)
 		} else if (!strncmp(ptr, "REJECTED ", 9)) {
 			static const char *command =3D "AUTH ANONYMOUS\r\n";
 =

-			dbus->negotiate_unix_fd =3D true;
+			if (!strcmp(dbus->transport, "unix"))
+				dbus->negotiate_unix_fd =3D true;
+			else
+				dbus->negotiate_unix_fd =3D false;
 =

 			classic->auth_command =3D l_strdup(command);
 			classic->auth_state =3D WAITING_FOR_OK;
@@ -680,6 +688,8 @@ static struct l_dbus_message *classic_recv_message(stru=
ct l_dbus *dbus)
 	len =3D recv(fd, &hdr, DBUS_HEADER_SIZE, MSG_PEEK | MSG_DONTWAIT);
 	if (len !=3D DBUS_HEADER_SIZE)
 		return NULL;
+	else if (len =3D=3D 0)
+		close(fd);
 =

 	header_size =3D align_len(DBUS_HEADER_SIZE + hdr.dbus1.field_length, 8);
 	header =3D l_malloc(header_size);
@@ -1033,7 +1043,8 @@ static const struct l_dbus_ops classic_ops =3D {
 	.name_acquire =3D classic_name_acquire,
 };
 =

-static struct l_dbus *setup_dbus1(int fd, const char *guid)
+static struct l_dbus *setup_dbus1(int fd, const char *guid,
+				  const char *transport)
 {
 	static const unsigned char creds =3D 0x00;
 	char uid[6], hexuid[12], *ptr =3D hexuid;
@@ -1065,11 +1076,13 @@ static struct l_dbus *setup_dbus1(int fd, const cha=
r *guid)
 =

 	dbus_init(dbus, fd);
 	dbus->guid =3D l_strdup(guid);
+	dbus->transport =3D l_strdup(transport);
 =

 	classic->auth_command =3D l_strdup_printf("AUTH EXTERNAL %s\r\n", hexuid);
 	classic->auth_state =3D WAITING_FOR_OK;
 =

-	dbus->negotiate_unix_fd =3D true;
+	if (!strcmp(transport, "unix"))
+		dbus->negotiate_unix_fd =3D true;
 	dbus->support_unix_fd =3D false;
 =

 	l_io_set_read_handler(dbus->io, auth_read_handler, dbus, NULL);
@@ -1145,7 +1158,131 @@ static struct l_dbus *setup_unix(char *params)
 		return NULL;
 	}
 =

-	return setup_dbus1(fd, guid);
+	return setup_dbus1(fd, guid, "unix");
+}
+
+static struct l_dbus *setup_tcp(char *params)
+{
+	struct addrinfo hints;
+	struct addrinfo *results, *rp;
+	fd_set rfds, wfds;
+	socklen_t optlen;
+	struct timeval tv;
+	char *host =3D NULL, *port =3D NULL, *family =3D NULL, *guid =3D NULL;
+	unsigned long port_number;
+	int i, err;
+	int fd =3D -1, socket_fd =3D -1, optval =3D -1;
+
+	while (params) {
+		char *key =3D strsep(&params, ",");
+		char *value;
+
+		if (!key)
+			break;
+
+		value =3D strchr(key, '=3D');
+		if (!value)
+			continue;
+
+		*value++ =3D '\0';
+
+		if (!strcmp(key, "host"))
+			host =3D value;
+		else if (!strcmp(key, "port"))
+			port =3D value;
+		else if (!strcmp(key, "family"))
+			family =3D value;
+		else if (!strcmp(key, "guid"))
+			guid =3D value;
+	}
+
+	if (!host || !port)
+		return NULL;
+
+	port_number =3D strtoul(port, NULL, 10);
+
+	if (port_number =3D=3D 0 || port_number >=3D 65536)
+		return NULL;
+
+	memset(&hints, 0, sizeof(hints));
+
+	hints.ai_family =3D AF_UNSPEC;
+	if (family) {
+		if (!strcmp(family, "ipv4"))
+			hints.ai_family =3D AF_INET;
+		else if (!strcmp(family, "ipv6"))
+			hints.ai_family =3D AF_INET6;
+	}
+
+	hints.ai_socktype =3D SOCK_STREAM;
+	hints.ai_flags =3D 0;
+	hints.ai_protocol =3D 0;
+
+	if (getaddrinfo(host, port, &hints, &results) !=3D 0)
+		return NULL;
+
+	FD_ZERO(&rfds);
+	FD_ZERO(&wfds);
+	for (rp =3D results; rp !=3D NULL; rp =3D rp->ai_next) {
+		fd =3D socket(rp->ai_family, rp->ai_socktype | SOCK_NONBLOCK, rp->ai_pro=
tocol);
+		if (fd < 0)
+			continue;
+
+		errno =3D 0;
+		if (connect(fd, rp->ai_addr, rp->ai_addrlen) =3D=3D -1) {
+			err =3D errno;
+			if (err =3D=3D EINPROGRESS) {
+				FD_SET(fd, &rfds);
+				FD_SET(fd, &wfds);
+			} else if (err =3D=3D ECONNREFUSED){
+				close(fd);
+			}
+		}
+	}
+
+	freeaddrinfo(results);
+
+	tv.tv_sec =3D 1;
+	tv.tv_usec =3D 0;
+
+	// Wait until sockets be ready, otherwise a timeout is thrown
+	if (select(fd + 1, &rfds, &wfds, NULL, &tv) =3D=3D 0) {
+		close(fd);
+		return NULL;
+	}
+
+	for (i =3D 1; i < fd + 1; i++) {
+		if (!FD_ISSET(i, &wfds) && !FD_ISSET(i, &rfds))
+			continue;
+
+		optlen =3D sizeof(optval);
+
+		if (getsockopt(i,
+				SOL_SOCKET, SO_ERROR, &optval,
+				&optlen) =3D=3D -1)
+			return NULL;
+
+		/**
+			* getsockopt() puts the errno value
+			* for connect into optval so 0 means
+			* no-error.
+			*/
+		if (optval =3D=3D 0) {
+			socket_fd =3D i;
+		} else {
+			close(i);
+			return NULL;
+		}
+
+		/* Remove this socket from fd_set */
+		FD_CLR(i, &wfds);
+		FD_CLR(i, &rfds);
+	}
+
+	if (socket_fd < 0)
+		return NULL;
+
+	return setup_dbus1(socket_fd, guid, "tcp");
 }
 =

 static struct l_dbus *setup_address(const char *address)
@@ -1170,6 +1307,9 @@ static struct l_dbus *setup_address(const char *addre=
ss)
 			/* Function will modify params string */
 			dbus =3D setup_unix(params);
 			break;
+		} else if (!strcmp(transport, "tcp")) {
+			dbus =3D setup_tcp(params);
+			break;
 		}
 	}
 =

@@ -1232,6 +1372,7 @@ LIB_EXPORT void l_dbus_destroy(struct l_dbus *dbus)
 =

 	l_free(dbus->guid);
 	l_free(dbus->unique_name);
+	l_free(dbus->transport);
 =

 	_dbus_object_tree_free(dbus->tree);
 =

-- =

2.7.4


--===============1205874960537287740==--

