Content-Type: multipart/mixed; boundary="===============7956432965967376951=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 3/4] genl: Take advantage of msg_as_bytes in can_write_data
Date: Sat, 15 Feb 2020 00:37:31 +0100
Message-ID: <20200214233732.20146-3-andrew.zaborowski@intel.com>
In-Reply-To: <20200214233732.20146-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7956432965967376951==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/genl.c | 22 +++++-----------------
 1 file changed, 5 insertions(+), 17 deletions(-)

diff --git a/ell/genl.c b/ell/genl.c
index 815af90..f65263d 100644
--- a/ell/genl.c
+++ b/ell/genl.c
@@ -832,8 +832,8 @@ static bool can_write_data(struct l_io *io, void *user_=
data)
 {
 	struct l_genl *genl =3D user_data;
 	struct genl_request *request;
-	struct nlmsghdr *nlmsg;
-	struct genlmsghdr *genlmsg;
+	const void *data;
+	size_t size;
 	ssize_t bytes_written;
 =

 	request =3D l_queue_pop_head(genl->request_queue);
@@ -841,22 +841,10 @@ static bool can_write_data(struct l_io *io, void *use=
r_data)
 		return false;
 =

 	request->seq =3D get_next_id(&genl->next_seq);
+	data =3D msg_as_bytes(request->msg, request->type, request->flags,
+				request->seq, genl->pid, &size);
 =

-	nlmsg =3D request->msg->data;
-
-	nlmsg->nlmsg_len =3D request->msg->len;
-	nlmsg->nlmsg_type =3D request->type;
-	nlmsg->nlmsg_flags =3D request->flags;
-	nlmsg->nlmsg_seq =3D request->seq;
-	nlmsg->nlmsg_pid =3D genl->pid;
-
-	genlmsg =3D request->msg->data + NLMSG_HDRLEN;
-
-	genlmsg->cmd =3D request->msg->cmd;
-	genlmsg->version =3D request->msg->version;
-
-	bytes_written =3D send(genl->fd, request->msg->data,
-						request->msg->len, 0);
+	bytes_written =3D send(genl->fd, data, size, 0);
 	if (bytes_written < 0) {
 		l_queue_push_head(genl->request_queue, request);
 		return false;
-- =

2.20.1

--===============7956432965967376951==--

