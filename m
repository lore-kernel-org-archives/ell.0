Content-Type: multipart/mixed; boundary="===============6473304885031511259=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH] genl: Add l_genl_msg_attr_append_data
Date: Thu, 06 Oct 2016 00:45:20 +0200
Message-ID: <1475707520-25740-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6473304885031511259==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Try to minimise the amount of buffers allocated and copied by clients
when building a message attribute that is a concatenation of other
buffers, such as an IE sequence.  The client would the following three
calls:

l_genl_msg_enter_nested
l_genl_msg_attr_append_data
l_genl_msg_leave_nested
---
 ell/genl.c | 26 ++++++++++++++++++++++++++
 ell/genl.h |  1 +
 2 files changed, 27 insertions(+)

diff --git a/ell/genl.c b/ell/genl.c
index 85e447a..aefea5f 100644
--- a/ell/genl.c
+++ b/ell/genl.c
@@ -828,14 +828,40 @@ LIB_EXPORT bool l_genl_msg_leave_nested(struct l_genl=
_msg *msg)
 	if (unlikely(msg->nesting_level =3D=3D 0))
 		return false;
 =

+	if (NLA_ALIGN(msg->len) > msg->size)
+		return false;
+
 	nla =3D msg->nests[msg->nesting_level - 1];
 	nla->nla_len =3D msg->len - nla->nla_len;
 =

 	msg->nesting_level -=3D 1;
 =

+	msg->len =3D NLA_ALIGN(msg->len);
+
 	return true;
 }
 =

+LIB_EXPORT void *l_genl_msg_attr_append_data(struct l_genl_msg *msg,
+						uint16_t len)
+{
+	void *ptr;
+
+	if (unlikely(!msg))
+		return false;
+
+	if (msg->len + len > msg->size)
+		return false;
+
+	if (unlikely(msg->nesting_level =3D=3D 0))
+		return false;
+
+	ptr =3D msg->data + msg->len;
+
+	msg->len +=3D len;
+
+	return ptr;
+}
+
 #define NLA_OK(nla,len)         ((len) >=3D (int) sizeof(struct nlattr) &&=
 \
 				(nla)->nla_len >=3D sizeof(struct nlattr) && \
 				(nla)->nla_len <=3D (len))
diff --git a/ell/genl.h b/ell/genl.h
index 5b37d55..5bfa459 100644
--- a/ell/genl.h
+++ b/ell/genl.h
@@ -73,6 +73,7 @@ bool l_genl_msg_append_attr(struct l_genl_msg *msg, uint1=
6_t type,
 					uint16_t len, const void *data);
 bool l_genl_msg_enter_nested(struct l_genl_msg *msg, uint16_t type);
 bool l_genl_msg_leave_nested(struct l_genl_msg *msg);
+void *l_genl_msg_attr_append_data(struct l_genl_msg *msg, uint16_t len);
 =

 bool l_genl_attr_init(struct l_genl_attr *attr, struct l_genl_msg *msg);
 bool l_genl_attr_next(struct l_genl_attr *attr, uint16_t *type,
-- =

2.7.4


--===============6473304885031511259==--

