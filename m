Content-Type: multipart/mixed; boundary="===============5681702909732382743=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/5] dbus: Remove memcpy and fix setting of FD_CLOEXEC on FDs
Date: Sat, 30 Apr 2016 00:43:59 +0200
Message-ID: <1461969842-11704-2-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1461969842-11704-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5681702909732382743==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Make sure the size of the FD buffer passed to recvmsg is properly
aligned, etc. and remove the memcpy which seems unneeded.  Also it looks
like the fcntl() calls operated on one dbus socket FD instead of the
message FDs.
---
 ell/dbus.c | 17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

diff --git a/ell/dbus.c b/ell/dbus.c
index 59506c5..35378b2 100644
--- a/ell/dbus.c
+++ b/ell/dbus.c
@@ -628,7 +628,11 @@ static struct l_dbus_message *classic_recv_message(str=
uct l_dbus *dbus)
 	ssize_t len;
 	void *header, *body;
 	size_t header_size, body_size;
-	int fds[16];
+	union {
+		uint8_t bytes[CMSG_SPACE(16 * sizeof(int))];
+		struct cmsghdr align;
+	} fd_buf;
+	int *fds =3D NULL;
 	uint32_t num_fds =3D 0;
 =

 	len =3D recv(fd, &hdr, DBUS_HEADER_SIZE, MSG_PEEK);
@@ -649,8 +653,8 @@ static struct l_dbus_message *classic_recv_message(stru=
ct l_dbus *dbus)
 	memset(&msg, 0, sizeof(msg));
 	msg.msg_iov =3D iov;
 	msg.msg_iovlen =3D 2;
-	msg.msg_control =3D &fds;
-	msg.msg_controllen =3D CMSG_SPACE(16 * sizeof(int));
+	msg.msg_control =3D &fd_buf;
+	msg.msg_controllen =3D sizeof(fd_buf);
 =

 	len =3D recvmsg(fd, &msg, MSG_CMSG_CLOEXEC);
 	if (len < 0)
@@ -665,19 +669,18 @@ static struct l_dbus_message *classic_recv_message(st=
ruct l_dbus *dbus)
 			continue;
 =

 		num_fds =3D (cmsg->cmsg_len - CMSG_LEN(0)) / sizeof(int);
-
-		memcpy(fds, CMSG_DATA(cmsg), num_fds * sizeof(int));
+		fds =3D (void *) CMSG_DATA(cmsg);
 =

 		/* Set FD_CLOEXEC on all file descriptors */
 		for (i =3D 0; i < num_fds; i++) {
 			long flags;
 =

-			flags =3D fcntl(fd, F_GETFD, NULL);
+			flags =3D fcntl(fds[i], F_GETFD, NULL);
 			if (flags < 0)
 				continue;
 =

 			if (!(flags & FD_CLOEXEC))
-				fcntl(fd, F_SETFD, flags | FD_CLOEXEC);
+				fcntl(fds[i], F_SETFD, flags | FD_CLOEXEC);
                 }
 	}
 =

-- =

2.5.0


--===============5681702909732382743==--

