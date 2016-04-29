Content-Type: multipart/mixed; boundary="===============6844506695782774815=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 07/11] dbus: Attach FDs to Dbus1 messages being sent
Date: Fri, 29 Apr 2016 05:32:04 +0200
Message-ID: <1461900728-20662-12-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1461900728-20662-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6844506695782774815==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/dbus.c | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/ell/dbus.c b/ell/dbus.c
index af0000d..70da849 100644
--- a/ell/dbus.c
+++ b/ell/dbus.c
@@ -596,6 +596,9 @@ static bool classic_send_message(struct l_dbus *dbus,
 	struct msghdr msg;
 	struct iovec iov[2];
 	ssize_t len;
+	int *fds;
+	uint32_t num_fds =3D 0;
+	struct cmsghdr *cmsg;
 =

 	iov[0].iov_base =3D _dbus_message_get_header(message, &iov[0].iov_len);
 	iov[1].iov_base =3D _dbus_message_get_body(message, &iov[1].iov_len);
@@ -604,6 +607,20 @@ static bool classic_send_message(struct l_dbus *dbus,
 	msg.msg_iov =3D iov;
 	msg.msg_iovlen =3D 2;
 =

+	if (dbus->support_unix_fd)
+		fds =3D _dbus_message_get_fds(message, &num_fds);
+
+	if (num_fds) {
+		msg.msg_control =3D alloca(CMSG_SPACE(num_fds * sizeof(int)));
+		msg.msg_controllen =3D CMSG_LEN(num_fds * sizeof(int));
+
+		cmsg =3D CMSG_FIRSTHDR(&msg);
+		cmsg->cmsg_len =3D msg.msg_controllen;
+		cmsg->cmsg_level =3D SOL_SOCKET;
+		cmsg->cmsg_type =3D SCM_RIGHTS;
+		memcpy(CMSG_DATA(cmsg), fds, num_fds * sizeof(int));
+	}
+
 	len =3D sendmsg(fd, &msg, 0);
 	if (len < 0)
 		return false;
-- =

2.5.0


--===============6844506695782774815==--

