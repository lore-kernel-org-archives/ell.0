Content-Type: multipart/mixed; boundary="===============5897218080774775117=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH 1/2] genl: Implement message nesting
Date: Tue, 24 Mar 2015 07:36:07 -0500
Message-ID: <1427200568-23220-1-git-send-email-denkenz@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5897218080774775117==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/genl.c | 48 ++++++++++++++++++++++++++++++++++++++++++++++++
 ell/genl.h |  2 ++
 2 files changed, 50 insertions(+)

diff --git a/ell/genl.c b/ell/genl.c
index 1b1afab..290325f 100644
--- a/ell/genl.c
+++ b/ell/genl.c
@@ -37,6 +37,8 @@
 #include "genl-private.h"
 #include "private.h"
 =

+#define MAX_NESTING_LEVEL 4
+
 struct l_genl {
 	int ref_count;
 	int fd;
@@ -65,6 +67,8 @@ struct l_genl_msg {
 	void *data;
 	uint32_t size;
 	uint32_t len;
+	struct nlattr *nests[MAX_NESTING_LEVEL];
+	uint8_t nesting_level;
 };
 =

 struct genl_request {
@@ -241,6 +245,7 @@ static struct l_genl_msg *msg_alloc(uint8_t cmd, uint8_=
t version, uint32_t size)
 	msg->size =3D msg->len + NLMSG_ALIGN(size);
 =

 	msg->data =3D l_new(unsigned char, msg->size);
+	msg->nesting_level =3D 0;
 =

 	return l_genl_msg_ref(msg);
 }
@@ -737,6 +742,49 @@ LIB_EXPORT bool l_genl_msg_append_attr(struct l_genl_m=
sg *msg, uint16_t type,
 	return true;
 }
 =

+LIB_EXPORT bool l_genl_msg_enter_nested(struct l_genl_msg *msg, uint16_t t=
ype)
+{
+	struct nlattr *nla;
+
+	if (unlikely(!msg))
+		return false;
+
+	if (unlikely(msg->nesting_level =3D=3D MAX_NESTING_LEVEL))
+		return false;
+
+	if (msg->len + NLA_HDRLEN > msg->size)
+		return false;
+
+	nla =3D msg->data + msg->len;
+	nla->nla_type =3D type;
+	nla->nla_len =3D msg->len; /* Save position */
+
+	msg->nests[msg->nesting_level] =3D nla;
+	msg->nesting_level +=3D 1;
+
+	msg->len +=3D NLA_HDRLEN;
+
+	return true;
+}
+
+LIB_EXPORT bool l_genl_msg_leave_nested(struct l_genl_msg *msg)
+{
+	struct nlattr *nla;
+
+	if (unlikely(!msg))
+		return false;
+
+	if (unlikely(msg->nesting_level =3D=3D 0))
+		return false;
+
+	nla =3D msg->nests[msg->nesting_level - 1];
+	nla->nla_len =3D msg->len - nla->nla_len;
+
+	msg->nesting_level -=3D 1;
+
+	return true;
+}
+
 #define NLA_OK(nla,len)         ((len) >=3D (int) sizeof(struct nlattr) &&=
 \
 				(nla)->nla_len >=3D sizeof(struct nlattr) && \
 				(nla)->nla_len <=3D (len))
diff --git a/ell/genl.h b/ell/genl.h
index c628b8c..8f5fd52 100644
--- a/ell/genl.h
+++ b/ell/genl.h
@@ -71,6 +71,8 @@ int l_genl_msg_get_error(struct l_genl_msg *msg);
 =

 bool l_genl_msg_append_attr(struct l_genl_msg *msg, uint16_t type,
 					uint16_t len, const void *data);
+bool l_genl_msg_enter_nested(struct l_genl_msg *msg, uint16_t type);
+bool l_genl_msg_leave_nested(struct l_genl_msg *msg);
 =

 bool l_genl_attr_init(struct l_genl_attr *attr, struct l_genl_msg *msg);
 bool l_genl_attr_next(struct l_genl_attr *attr, uint16_t *type,
-- =

2.0.4


--===============5897218080774775117==--

