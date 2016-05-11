Content-Type: multipart/mixed; boundary="===============1557770510027642771=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/2] dbus: Use blocking socket for Dbus1, adapt IO calls
Date: Wed, 11 May 2016 11:36:10 +0200
Message-ID: <1462959370-30764-4-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1462959370-30764-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1557770510027642771==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

We need to handle partial reads and writes and FD passing with multiple
messages in the socket's queue so we may need multiple calls to send or
recv.  With a blocking socket we can call them in the loop and simplify
buffering of message data.
---
 ell/dbus.c | 220 +++++++++++++++++++++++++++++++++++++++++++--------------=
----
 1 file changed, 157 insertions(+), 63 deletions(-)

diff --git a/ell/dbus.c b/ell/dbus.c
index 69222e9..f6ae531 100644
--- a/ell/dbus.c
+++ b/ell/dbus.c
@@ -114,6 +114,8 @@ struct l_dbus_classic {
 	void *auth_command;
 	enum auth_state auth_state;
 	struct l_hashmap *match_strings;
+	int *fd_buf;
+	unsigned int num_fds;
 };
 =

 struct message_callback {
@@ -397,6 +399,12 @@ static bool auth_write_handler(struct l_io *io, void *=
user_data)
 	l_util_hexdump(false, classic->auth_command, written,
 					dbus->debug_handler, dbus->debug_data);
 =

+	if (written < len) {
+		memmove(classic->auth_command, classic->auth_command + written,
+				len + 1 - written);
+		return true;
+	}
+
 	l_free(classic->auth_command);
 	classic->auth_command =3D NULL;
 =

@@ -436,9 +444,13 @@ static bool auth_read_handler(struct l_io *io, void *u=
ser_data)
 	offset =3D 0;
 =

 	while (1) {
-		len =3D recv(fd, ptr + offset, sizeof(buffer) - offset, 0);
-		if (len < 1)
+		len =3D recv(fd, ptr + offset, sizeof(buffer) - offset,
+				MSG_DONTWAIT);
+		if (len < 1) {
+			if (len =3D=3D -1 && errno =3D=3D EINTR)
+				continue;
 			break;
+		}
 =

 		offset +=3D len;
 	}
@@ -552,6 +564,11 @@ static void classic_free(struct l_dbus *dbus)
 {
 	struct l_dbus_classic *classic =3D
 		container_of(dbus, struct l_dbus_classic, super);
+	unsigned int i;
+
+	for (i =3D 0; i < classic->num_fds; i++)
+		close(classic->fd_buf[i]);
+	l_free(classic->fd_buf);
 =

 	l_free(classic->auth_command);
 	l_hashmap_destroy(classic->match_strings, l_free);
@@ -563,48 +580,79 @@ static bool classic_send_message(struct l_dbus *dbus,
 {
 	int fd =3D l_io_get_fd(dbus->io);
 	struct msghdr msg;
-	struct iovec iov[2];
-	ssize_t len;
+	struct iovec iov[2], *iovpos;
+	ssize_t r;
 	int *fds;
 	uint32_t num_fds =3D 0;
 	struct cmsghdr *cmsg;
+	int iovlen;
 =

 	iov[0].iov_base =3D _dbus_message_get_header(message, &iov[0].iov_len);
 	iov[1].iov_base =3D _dbus_message_get_body(message, &iov[1].iov_len);
 =

-	memset(&msg, 0, sizeof(msg));
-	msg.msg_iov =3D iov;
-	msg.msg_iovlen =3D 2;
-
 	if (dbus->support_unix_fd)
 		fds =3D _dbus_message_get_fds(message, &num_fds);
 =

-	if (num_fds) {
-		msg.msg_control =3D alloca(CMSG_SPACE(num_fds * sizeof(int)));
-		msg.msg_controllen =3D CMSG_LEN(num_fds * sizeof(int));
+	iovpos =3D iov;
+	iovlen =3D 2;
 =

-		cmsg =3D CMSG_FIRSTHDR(&msg);
-		cmsg->cmsg_len =3D msg.msg_controllen;
-		cmsg->cmsg_level =3D SOL_SOCKET;
-		cmsg->cmsg_type =3D SCM_RIGHTS;
-		memcpy(CMSG_DATA(cmsg), fds, num_fds * sizeof(int));
-	}
+	while (1) {
+		memset(&msg, 0, sizeof(msg));
+		msg.msg_iov =3D iovpos;
+		msg.msg_iovlen =3D iovlen;
+
+		if (num_fds) {
+			msg.msg_control =3D
+				alloca(CMSG_SPACE(num_fds * sizeof(int)));
+			msg.msg_controllen =3D CMSG_LEN(num_fds * sizeof(int));
+
+			cmsg =3D CMSG_FIRSTHDR(&msg);
+			cmsg->cmsg_len =3D msg.msg_controllen;
+			cmsg->cmsg_level =3D SOL_SOCKET;
+			cmsg->cmsg_type =3D SCM_RIGHTS;
+			memcpy(CMSG_DATA(cmsg), fds, num_fds * sizeof(int));
+		}
 =

-	len =3D sendmsg(fd, &msg, 0);
-	if (len < 0)
-		return false;
+		r =3D sendmsg(fd, &msg, 0);
+		if (r <=3D 0) {
+			if (r < 0 && errno !=3D EINTR)
+				return false;
+
+			continue;
+		}
+
+		while ((size_t) r >=3D iovpos->iov_len) {
+			r -=3D iovpos->iov_len;
+			iovpos++;
+			iovlen--;
+
+			if (!iovlen)
+				break;
+		}
+
+		if (!iovlen)
+			break;
+
+		iovpos->iov_base +=3D r;
+		iovpos->iov_len -=3D r;
+
+		/* The FDs have been transmitted, don't retransmit */
+		num_fds =3D 0;
+	}
 =

 	return true;
 }
 =

 static struct l_dbus_message *classic_recv_message(struct l_dbus *dbus)
 {
+	struct l_dbus_classic *classic =3D
+		container_of(dbus, struct l_dbus_classic, super);
 	int fd =3D l_io_get_fd(dbus->io);
 	struct dbus_header hdr;
 	struct msghdr msg;
-	struct iovec iov[2];
+	struct iovec iov[2], *iovpos;
 	struct cmsghdr *cmsg;
-	ssize_t len;
+	ssize_t len, r;
 	void *header, *body;
 	size_t header_size, body_size;
 	union {
@@ -613,6 +661,9 @@ static struct l_dbus_message *classic_recv_message(stru=
ct l_dbus *dbus)
 	} fd_buf;
 	int *fds =3D NULL;
 	uint32_t num_fds =3D 0;
+	int iovlen;
+	struct l_dbus_message *message;
+	unsigned int i;
 =

 	len =3D recv(fd, &hdr, DBUS_HEADER_SIZE, MSG_PEEK);
 	if (len !=3D DBUS_HEADER_SIZE)
@@ -629,38 +680,68 @@ static struct l_dbus_message *classic_recv_message(st=
ruct l_dbus *dbus)
 	iov[1].iov_base =3D body;
 	iov[1].iov_len  =3D body_size;
 =

-	memset(&msg, 0, sizeof(msg));
-	msg.msg_iov =3D iov;
-	msg.msg_iovlen =3D 2;
-	msg.msg_control =3D &fd_buf;
-	msg.msg_controllen =3D sizeof(fd_buf);
+	iovpos =3D iov;
+	iovlen =3D 2;
 =

-	len =3D recvmsg(fd, &msg, MSG_CMSG_CLOEXEC);
-	if (len < 0)
-		goto cmsg_fail;
+	while (1) {
+		memset(&msg, 0, sizeof(msg));
+		msg.msg_iov =3D iovpos;
+		msg.msg_iovlen =3D iovlen;
+		msg.msg_control =3D &fd_buf;
+		msg.msg_controllen =3D sizeof(fd_buf);
 =

-	for (cmsg =3D CMSG_FIRSTHDR(&msg); cmsg;
-				cmsg =3D CMSG_NXTHDR(&msg, cmsg)) {
-		unsigned int i;
+		r =3D recvmsg(fd, &msg, MSG_CMSG_CLOEXEC | MSG_WAITALL);
+		if (r < 0) {
+			if (errno !=3D EINTR)
+				goto cmsg_fail;
 =

-		if (cmsg->cmsg_level !=3D SOL_SOCKET ||
-					cmsg->cmsg_type !=3D SCM_RIGHTS)
 			continue;
+		}
+
+		for (cmsg =3D CMSG_FIRSTHDR(&msg); cmsg;
+				cmsg =3D CMSG_NXTHDR(&msg, cmsg)) {
+			if (cmsg->cmsg_level !=3D SOL_SOCKET ||
+					cmsg->cmsg_type !=3D SCM_RIGHTS)
+				continue;
 =

-		num_fds =3D (cmsg->cmsg_len - CMSG_LEN(0)) / sizeof(int);
-		fds =3D (void *) CMSG_DATA(cmsg);
+			num_fds =3D (cmsg->cmsg_len - CMSG_LEN(0)) / sizeof(int);
+			fds =3D (void *) CMSG_DATA(cmsg);
 =

-		/* Set FD_CLOEXEC on all file descriptors */
-		for (i =3D 0; i < num_fds; i++) {
-			long flags;
+			/* Set FD_CLOEXEC on all file descriptors */
+			for (i =3D 0; i < num_fds; i++) {
+				long flags;
 =

-			flags =3D fcntl(fds[i], F_GETFD, NULL);
-			if (flags < 0)
-				continue;
+				flags =3D fcntl(fds[i], F_GETFD, NULL);
+				if (flags < 0)
+					continue;
+
+				if (!(flags & FD_CLOEXEC))
+					fcntl(fds[i], F_SETFD,
+						flags | FD_CLOEXEC);
+			}
+
+			classic->fd_buf =3D l_realloc(classic->fd_buf,
+						(classic->num_fds + num_fds) *
+						sizeof(int));
+			memcpy(classic->fd_buf + classic->num_fds, fds,
+				num_fds * sizeof(int));
+			classic->num_fds +=3D num_fds;
+		}
 =

-			if (!(flags & FD_CLOEXEC))
-				fcntl(fds[i], F_SETFD, flags | FD_CLOEXEC);
-                }
+		while ((size_t) r >=3D iovpos->iov_len) {
+			r -=3D iovpos->iov_len;
+			iovpos++;
+			iovlen--;
+
+			if (!iovlen)
+				break;
+		}
+
+		if (!iovlen)
+			break;
+
+		iovpos->iov_base +=3D r;
+		iovpos->iov_len -=3D r;
 	}
 =

 	if (hdr.endian !=3D DBUS_NATIVE_ENDIAN) {
@@ -675,11 +756,39 @@ static struct l_dbus_message *classic_recv_message(st=
ruct l_dbus *dbus)
 		goto bad_msg;
 	}
 =

-	return dbus_message_build(header, header_size, body, body_size,
-					fds, num_fds);
+	num_fds =3D _dbus_message_unix_fds_from_header(header, header_size);
+	if (num_fds > classic->num_fds)
+		goto bad_msg;
+
+	message =3D dbus_message_build(header, header_size, body, body_size,
+					classic->fd_buf, num_fds);
+
+	if (message && num_fds) {
+		if (classic->num_fds > num_fds) {
+			memmove(classic->fd_buf, classic->fd_buf + num_fds,
+				(classic->num_fds - num_fds) * sizeof(int));
+			classic->num_fds -=3D num_fds;
+		} else {
+			l_free(classic->fd_buf);
+
+			classic->fd_buf =3D NULL;
+			classic->num_fds =3D 0;
+		}
+	}
+
+	if (message)
+		return message;
 =

 bad_msg:
 cmsg_fail:
+	for (i =3D 0; i < classic->num_fds; i++)
+		close(classic->fd_buf[i]);
+
+	l_free(classic->fd_buf);
+
+	classic->fd_buf =3D NULL;
+	classic->num_fds =3D 0;
+
 	l_free(header);
 	l_free(body);
 =

@@ -923,7 +1032,6 @@ static struct l_dbus *setup_dbus1(int fd, const char *=
guid)
 	struct l_dbus_classic *classic;
 	ssize_t written;
 	unsigned int i;
-	long flags;
 =

 	if (snprintf(uid, sizeof(uid), "%d", geteuid()) < 1) {
 		close(fd);
@@ -940,20 +1048,6 @@ static struct l_dbus *setup_dbus1(int fd, const char =
*guid)
 		return NULL;
 	}
 =

-	flags =3D fcntl(fd, F_GETFL, NULL);
-	if (flags < 0) {
-		close(fd);
-		return NULL;
-	}
-
-	/* Input handling requires non-blocking socket */
-	if (!(flags & O_NONBLOCK)) {
-		if (fcntl(fd, F_SETFL, flags | O_NONBLOCK) < 0) {
-			close(fd);
-			return NULL;
-		}
-	}
-
 	classic =3D l_new(struct l_dbus_classic, 1);
 	dbus =3D &classic->super;
 	dbus->driver =3D &classic_ops;
-- =

2.7.4


--===============1557770510027642771==--

