Content-Type: multipart/mixed; boundary="===============7526167064024520818=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/3] genl: Use l_buf for l_genl_msg building
Date: Fri, 08 Jan 2021 02:13:23 +0100
Message-ID: <20210108011324.1551320-2-andrew.zaborowski@intel.com>
In-Reply-To: <20210108011324.1551320-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7526167064024520818==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Replace l_genl_msg.data with an l_buf and update all of the users so
that genl.c doesn't need to do the size checks and reallocs.  The
function signatures are not changed except for l_genl_msg_to_data()
being replaced with l_genl_msg_get_buf().  Two new functions are added.

One little annoyance with the new code is that the order of attributes
may not be preserved as with the old code.

It would have been possible to get rid of l_genl_msg.nests[] but the
code would be slightly uglier.
---
 ell/ell.sym |   4 +-
 ell/genl.c  | 218 +++++++++++++++++++++++++++-------------------------
 ell/genl.h  |  12 ++-
 3 files changed, 124 insertions(+), 110 deletions(-)

diff --git a/ell/ell.sym b/ell/ell.sym
index 8372e5f..ee02b7a 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -297,8 +297,9 @@ global:
 	l_genl_request_family;
 	l_genl_msg_new;
 	l_genl_msg_new_sized;
+	l_genl_msg_new_bufs;
 	l_genl_msg_new_from_data;
-	l_genl_msg_to_data;
+	l_genl_msg_get_buf;
 	l_genl_msg_ref;
 	l_genl_msg_unref;
 	l_genl_msg_get_command;
@@ -307,6 +308,7 @@ global:
 	l_genl_msg_get_extended_error;
 	l_genl_msg_append_attr;
 	l_genl_msg_append_attrv;
+	l_genl_msg_append_attr_buf;
 	l_genl_msg_enter_nested;
 	l_genl_msg_leave_nested;
 	l_genl_attr_init;
diff --git a/ell/genl.c b/ell/genl.c
index a4f7252..7e6f2f1 100644
--- a/ell/genl.c
+++ b/ell/genl.c
@@ -34,6 +34,7 @@
 #include "io.h"
 #include "netlink-private.h"
 #include "genl.h"
+#include "buf.h"
 #include "private.h"
 =

 #define MAX_NESTING_LEVEL 4
@@ -43,7 +44,7 @@
 =

 struct nest_info {
 	uint16_t type;
-	uint16_t offset;
+	struct l_buf *parent_buf;
 };
 =

 struct unicast_watch {
@@ -104,11 +105,13 @@ struct l_genl_msg {
 	char *error_msg;
 	uint8_t cmd;
 	uint8_t version;
-	void *data;
 	uint32_t size;
-	uint32_t len;
+	struct l_buf *buf;
+	struct l_buf *cur_buf;
 	struct nest_info nests[MAX_NESTING_LEVEL];
 	uint8_t nesting_level;
+	uint16_t attr_type;
+	struct l_buf *attr_buf;
 };
 =

 struct genl_request {
@@ -740,7 +743,8 @@ static bool match_request_hid(const void *a, const void=
 *b)
 #define NLA_DATA(nla)		((void*)(((char*)(nla)) + NLA_LENGTH(0)))
 #define NLA_PAYLOAD(nla)	((int)((nla)->nla_len) - NLA_LENGTH(0))
 =

-static struct l_genl_msg *msg_alloc(uint8_t cmd, uint8_t version, uint32_t=
 size)
+static struct l_genl_msg *msg_alloc(uint8_t cmd, uint8_t version, uint32_t=
 size,
+					uint32_t n_bufs)
 {
 	struct l_genl_msg *msg;
 =

@@ -749,35 +753,15 @@ static struct l_genl_msg *msg_alloc(uint8_t cmd, uint=
8_t version, uint32_t size)
 	msg->cmd =3D cmd;
 	msg->version =3D version;
 =

-	msg->len =3D NLMSG_HDRLEN + GENL_HDRLEN;
-	msg->size =3D msg->len + NLMSG_ALIGN(size);
-
-	msg->data =3D l_realloc(NULL, msg->size);
-	memset(msg->data, 0, msg->size);
+	msg->size =3D NLMSG_ALIGN(size);
+	msg->buf =3D l_buf_new(NLMSG_HDRLEN + GENL_HDRLEN, msg->size, n_bufs);
+	msg->cur_buf =3D msg->buf;
 	msg->nesting_level =3D 0;
+	msg->attr_buf =3D NULL;
 =

 	return l_genl_msg_ref(msg);
 }
 =

-static bool msg_grow(struct l_genl_msg *msg, uint32_t needed)
-{
-	uint32_t grow_by;
-
-	if (msg->size >=3D msg->len + needed)
-		return true;
-
-	grow_by =3D msg->len + needed - msg->size;
-
-	if (grow_by < 32)
-		grow_by =3D 128;
-
-	msg->data =3D l_realloc(msg->data, msg->size + grow_by);
-	memset(msg->data + msg->size, 0, grow_by);
-	msg->size +=3D grow_by;
-
-	return true;
-}
-
 static struct l_genl_msg *msg_create(const struct nlmsghdr *nlmsg)
 {
 	struct l_genl_msg *msg;
@@ -828,13 +812,13 @@ static struct l_genl_msg *msg_create(const struct nlm=
sghdr *nlmsg)
 		}
 	}
 =

-	msg->data =3D l_memdup(nlmsg, nlmsg->nlmsg_len);
-
-	msg->len =3D nlmsg->nlmsg_len;
+	msg->buf =3D l_buf_new(0, nlmsg->nlmsg_len, 0);
 	msg->size =3D nlmsg->nlmsg_len;
 =

-	if (msg->len >=3D GENL_HDRLEN) {
-		struct genlmsghdr *genlmsg =3D msg->data + NLMSG_HDRLEN;
+	l_buf_append(msg->buf, nlmsg, nlmsg->nlmsg_len);
+
+	if (msg->size >=3D GENL_HDRLEN) {
+		struct genlmsghdr *genlmsg =3D msg->buf->used->iov_base + NLMSG_HDRLEN;
 =

 		msg->cmd =3D genlmsg->cmd;
 		msg->version =3D genlmsg->version;
@@ -844,30 +828,25 @@ done:
 	return l_genl_msg_ref(msg);
 }
 =

-static const void *msg_as_bytes(struct l_genl_msg *msg, uint16_t type,
-				uint16_t flags, uint32_t seq, uint32_t pid,
-				size_t *out_size)
+static void genl_msg_write_header(struct l_genl_msg *msg, uint16_t type,
+					uint16_t flags, uint32_t seq,
+					uint32_t pid)
 {
-	struct nlmsghdr *nlmsg;
-	struct genlmsghdr *genlmsg;
-
-	nlmsg =3D msg->data;
-
-	nlmsg->nlmsg_len =3D msg->len;
-	nlmsg->nlmsg_type =3D type;
-	nlmsg->nlmsg_flags =3D flags;
-	nlmsg->nlmsg_seq =3D seq;
-	nlmsg->nlmsg_pid =3D pid;
-
-	genlmsg =3D msg->data + NLMSG_HDRLEN;
-
-	genlmsg->cmd =3D msg->cmd;
-	genlmsg->version =3D msg->version;
+	struct nlmsghdr nlmsg =3D {
+		.nlmsg_len =3D l_buf_get_len(msg->buf) +
+			NLMSG_HDRLEN + GENL_HDRLEN,
+		.nlmsg_type =3D type,
+		.nlmsg_flags =3D flags,
+		.nlmsg_seq =3D seq,
+		.nlmsg_pid =3D pid,
+	};
+	struct genlmsghdr genlmsg =3D {
+		.cmd =3D msg->cmd,
+		.version =3D msg->version,
+	};
 =

-	if (out_size)
-		*out_size =3D msg->len;
-
-	return msg->data;
+	l_buf_prepend(msg->buf, &genlmsg, GENL_HDRLEN);
+	l_buf_prepend(msg->buf, &nlmsg, NLMSG_HDRLEN);
 }
 =

 static void write_watch_destroy(void *user_data)
@@ -881,25 +860,29 @@ static bool can_write_data(struct l_io *io, void *use=
r_data)
 {
 	struct l_genl *genl =3D user_data;
 	struct genl_request *request;
-	const void *data;
-	size_t size;
 	ssize_t bytes_written;
+	unsigned int i;
 =

 	request =3D l_queue_pop_head(genl->request_queue);
 	if (!request)
 		return false;
 =

 	request->seq =3D get_next_id(&genl->next_seq);
-	data =3D msg_as_bytes(request->msg, request->type, request->flags,
-				request->seq, genl->pid, &size);
+	genl_msg_write_header(request->msg, request->type, request->flags,
+				request->seq, genl->pid);
 =

-	bytes_written =3D send(genl->fd, data, size, 0);
+	bytes_written =3D writev(genl->fd, request->msg->buf->used,
+				request->msg->buf->used_cnt);
 	if (bytes_written < 0) {
+		l_buf_put_headroom(request->msg->buf,
+					GENL_HDRLEN + NLMSG_HDRLEN);
 		l_queue_push_head(genl->request_queue, request);
 		return false;
 	}
 =

-	l_util_hexdump(false, request->msg->data, bytes_written,
+	for (i =3D 0; i < request->msg->buf->used_cnt; i++)
+		l_util_hexdump(false, request->msg->buf->used[i].iov_base,
+				request->msg->buf->used[i].iov_len,
 				genl->debug_callback, genl->debug_data);
 =

 	l_queue_push_tail(genl->pending_list, request);
@@ -1567,7 +1550,12 @@ LIB_EXPORT struct l_genl_msg *l_genl_msg_new(uint8_t=
 cmd)
 =

 LIB_EXPORT struct l_genl_msg *l_genl_msg_new_sized(uint8_t cmd, uint32_t s=
ize)
 {
-	return msg_alloc(cmd, 0x00, size);
+	return msg_alloc(cmd, 0x00, size, 16);
+}
+
+LIB_EXPORT struct l_genl_msg *l_genl_msg_new_bufs(uint8_t cmd, uint32_t n_=
bufs)
+{
+	return msg_alloc(cmd, 0x00, 256, n_bufs);
 }
 =

 LIB_EXPORT struct l_genl_msg *l_genl_msg_new_from_data(const void *data,
@@ -1584,12 +1572,15 @@ LIB_EXPORT struct l_genl_msg *l_genl_msg_new_from_d=
ata(const void *data,
 	return msg_create(nlmsg);
 }
 =

-LIB_EXPORT const void *l_genl_msg_to_data(struct l_genl_msg *msg, uint16_t=
 type,
-						uint16_t flags, uint32_t seq,
-						uint32_t pid,
-						size_t *out_size)
+LIB_EXPORT const struct l_buf *l_genl_msg_get_buf(struct l_genl_msg *msg,
+							uint16_t type,
+							uint16_t flags,
+							uint32_t seq,
+							uint32_t pid)
 {
-	return msg_as_bytes(msg, type, flags, seq, pid, out_size);
+	genl_msg_write_header(msg, type, flags, seq, pid);
+
+	return msg->buf;
 }
 =

 LIB_EXPORT struct l_genl_msg *l_genl_msg_ref(struct l_genl_msg *msg)
@@ -1611,7 +1602,7 @@ LIB_EXPORT void l_genl_msg_unref(struct l_genl_msg *m=
sg)
 		return;
 =

 	l_free(msg->error_msg);
-	l_free(msg->data);
+	l_buf_free(msg->buf);
 	l_free(msg);
 }
 =

@@ -1650,23 +1641,17 @@ LIB_EXPORT const char *l_genl_msg_get_extended_erro=
r(struct l_genl_msg *msg)
 LIB_EXPORT bool l_genl_msg_append_attr(struct l_genl_msg *msg, uint16_t ty=
pe,
 						uint16_t len, const void *data)
 {
-	struct nlattr *nla;
+	struct nlattr nla =3D {
+		.nla_len =3D NLA_HDRLEN + len,
+		.nla_type =3D type,
+	};
 =

 	if (unlikely(!msg))
 		return false;
 =

-	if (!msg_grow(msg, NLA_HDRLEN + NLA_ALIGN(len)))
-		return false;
-
-	nla =3D msg->data + msg->len;
-	nla->nla_len =3D NLA_HDRLEN + len;
-	nla->nla_type =3D type;
-
-	if (len)
-		memcpy(msg->data + msg->len + NLA_HDRLEN, data, len);
-
-	msg->len +=3D NLA_HDRLEN + NLA_ALIGN(len);
-
+	l_buf_append(msg->cur_buf, &nla, NLA_HDRLEN);
+	l_buf_append(msg->cur_buf, data, len);
+	l_buf_pad(msg->cur_buf, 0, NLA_ALIGN(len) - len);
 	return true;
 }
 =

@@ -1674,7 +1659,7 @@ LIB_EXPORT bool l_genl_msg_append_attrv(struct l_genl=
_msg *msg, uint16_t type,
 					const struct iovec *iov,
 					size_t iov_len)
 {
-	struct nlattr *nla;
+	struct nlattr nla =3D { .nla_type =3D type };
 	size_t len =3D 0;
 	unsigned int i;
 =

@@ -1684,23 +1669,26 @@ LIB_EXPORT bool l_genl_msg_append_attrv(struct l_ge=
nl_msg *msg, uint16_t type,
 	for (i =3D 0; i < iov_len; i++)
 		len +=3D iov[i].iov_len;
 =

-	if (!msg_grow(msg, NLA_HDRLEN + NLA_ALIGN(len)))
-		return false;
+	nla.nla_len =3D NLA_HDRLEN + len;
 =

-	nla =3D msg->data + msg->len;
-	nla->nla_len =3D NLA_HDRLEN + len;
-	nla->nla_type =3D type;
+	l_buf_append(msg->cur_buf, &nla, NLA_HDRLEN);
+	l_buf_appendv(msg->cur_buf, iov, iov_len);
+	l_buf_pad(msg->cur_buf, 0, NLA_ALIGN(len) - len);
+	return true;
+}
 =

-	msg->len +=3D NLA_HDRLEN;
+static void genl_msg_write_attr_header(struct l_genl_msg *msg)
+{
+	struct nlattr nla =3D {};
 =

-	for (i =3D 0; i < iov_len; i++, iov++) {
-		memcpy(msg->data + msg->len, iov->iov_base, iov->iov_len);
-		msg->len +=3D iov->iov_len;
-	}
+	if (!msg->attr_buf)
+		return;
 =

-	msg->len +=3D NLA_ALIGN(len) - len;
+	nla.nla_type =3D msg->attr_type;
+	nla.nla_len =3D l_buf_get_len(msg->attr_buf) + NLA_HDRLEN;
+	l_buf_prepend(msg->attr_buf, &nla, NLA_HDRLEN);
 =

-	return true;
+	msg->attr_buf =3D NULL;
 }
 =

 LIB_EXPORT bool l_genl_msg_enter_nested(struct l_genl_msg *msg, uint16_t t=
ype)
@@ -1711,21 +1699,19 @@ LIB_EXPORT bool l_genl_msg_enter_nested(struct l_ge=
nl_msg *msg, uint16_t type)
 	if (unlikely(msg->nesting_level =3D=3D MAX_NESTING_LEVEL))
 		return false;
 =

-	if (!msg_grow(msg, NLA_HDRLEN))
-		return false;
-
 	msg->nests[msg->nesting_level].type =3D type | NLA_F_NESTED;
-	msg->nests[msg->nesting_level].offset =3D msg->len;
+	msg->nests[msg->nesting_level].parent_buf =3D msg->cur_buf;
 	msg->nesting_level +=3D 1;
 =

-	msg->len +=3D NLA_HDRLEN;
+	genl_msg_write_attr_header(msg);
+	msg->cur_buf =3D l_buf_append_new(msg->cur_buf, NLA_HDRLEN, msg->size);
 =

 	return true;
 }
 =

 LIB_EXPORT bool l_genl_msg_leave_nested(struct l_genl_msg *msg)
 {
-	struct nlattr *nla;
+	struct nlattr nla =3D {};
 =

 	if (unlikely(!msg))
 		return false;
@@ -1733,15 +1719,33 @@ LIB_EXPORT bool l_genl_msg_leave_nested(struct l_ge=
nl_msg *msg)
 	if (unlikely(msg->nesting_level =3D=3D 0))
 		return false;
 =

-	nla =3D msg->data + msg->nests[msg->nesting_level - 1].offset;
-	nla->nla_type =3D msg->nests[msg->nesting_level - 1].type;
-	nla->nla_len =3D msg->len - msg->nests[msg->nesting_level - 1].offset;
+	genl_msg_write_attr_header(msg);
 =

+	nla.nla_type =3D msg->nests[msg->nesting_level - 1].type;
+	nla.nla_len =3D l_buf_get_len(msg->cur_buf) + NLA_HDRLEN;
+	l_buf_prepend(msg->cur_buf, &nla, NLA_HDRLEN);
+
+	msg->cur_buf =3D msg->nests[msg->nesting_level - 1].parent_buf;
 	msg->nesting_level -=3D 1;
 =

 	return true;
 }
 =

+LIB_EXPORT struct l_buf *l_genl_msg_append_attr_buf(struct l_genl_msg *msg,
+							uint16_t type,
+							size_t headroom,
+							size_t tailroom)
+{
+	if (unlikely(!msg))
+		return NULL;
+
+	genl_msg_write_attr_header(msg);
+	msg->attr_buf =3D l_buf_append_new(msg->cur_buf, headroom + NLA_HDRLEN,
+						tailroom);
+
+	return msg->attr_buf;
+}
+
 LIB_EXPORT bool l_genl_attr_init(struct l_genl_attr *attr,
 						struct l_genl_msg *msg)
 {
@@ -1751,11 +1755,11 @@ LIB_EXPORT bool l_genl_attr_init(struct l_genl_attr=
 *attr,
 	if (unlikely(!attr) || unlikely(!msg))
 		return false;
 =

-	if (!msg->data || msg->len < NLMSG_HDRLEN + GENL_HDRLEN)
+	if (msg->buf->used->iov_len < NLMSG_HDRLEN + GENL_HDRLEN)
 		return false;
 =

-	nla =3D msg->data + NLMSG_HDRLEN + GENL_HDRLEN;
-	len =3D msg->len - NLMSG_HDRLEN - GENL_HDRLEN;
+	nla =3D msg->buf->used->iov_base + NLMSG_HDRLEN + GENL_HDRLEN;
+	len =3D msg->buf->used->iov_len - NLMSG_HDRLEN - GENL_HDRLEN;
 =

 	if (!NLA_OK(nla, len))
 		return false;
@@ -1898,6 +1902,8 @@ static unsigned int send_common(struct l_genl_family =
*family, uint16_t flags,
 	if (!genl)
 		return 0;
 =

+	genl_msg_write_attr_header(msg);
+
 	request =3D l_new(struct genl_request, 1);
 	request->type =3D family->id;
 	request->flags =3D NLM_F_REQUEST | flags;
diff --git a/ell/genl.h b/ell/genl.h
index 7550bf8..14e8b36 100644
--- a/ell/genl.h
+++ b/ell/genl.h
@@ -37,6 +37,7 @@ struct l_genl;
 struct l_genl_family_info;
 struct l_genl_family;
 struct l_genl_msg;
+struct l_buf;
 =

 typedef void (*l_genl_destroy_func_t)(void *user_data);
 typedef void (*l_genl_debug_func_t)(const char *str, void *user_data);
@@ -85,11 +86,12 @@ struct l_genl_attr {
 =

 struct l_genl_msg* l_genl_msg_new(uint8_t cmd);
 struct l_genl_msg *l_genl_msg_new_sized(uint8_t cmd, uint32_t size);
+struct l_genl_msg *l_genl_msg_new_bufs(uint8_t cmd, uint32_t n_bufs);
 struct l_genl_msg *l_genl_msg_new_from_data(const void *data, size_t size);
 =

-const void *l_genl_msg_to_data(struct l_genl_msg *msg, uint16_t type,
-				uint16_t flags, uint32_t seq, uint32_t pid,
-				size_t *out_size);
+const struct l_buf *l_genl_msg_get_buf(struct l_genl_msg *msg,
+					uint16_t type, uint16_t flags,
+					uint32_t seq, uint32_t pid);
 =

 struct l_genl_msg *l_genl_msg_ref(struct l_genl_msg *msg);
 void l_genl_msg_unref(struct l_genl_msg *msg);
@@ -103,6 +105,10 @@ bool l_genl_msg_append_attr(struct l_genl_msg *msg, ui=
nt16_t type,
 					uint16_t len, const void *data);
 bool l_genl_msg_append_attrv(struct l_genl_msg *msg, uint16_t type,
 				const struct iovec *iov, size_t iov_len);
+struct l_buf *l_genl_msg_append_attr_buf(struct l_genl_msg *msg,
+						uint16_t type,
+						size_t headroom,
+						size_t tailroom);
 bool l_genl_msg_enter_nested(struct l_genl_msg *msg, uint16_t type);
 bool l_genl_msg_leave_nested(struct l_genl_msg *msg);
 =

-- =

2.27.0

--===============7526167064024520818==--

