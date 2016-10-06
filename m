Content-Type: multipart/mixed; boundary="===============2908044464407161810=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH] genl: Add l_genl_msg_append_attrv
Date: Thu, 06 Oct 2016 11:18:22 +0200
Message-ID: <1475745502-4866-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2908044464407161810==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Try to minimise the amount of buffers allocated and copied by clients
when building a message attribute that is a concatenation of other
buffers, such as an IE sequence.
---
 ell/genl.c | 32 ++++++++++++++++++++++++++++++++
 ell/genl.h |  2 ++
 2 files changed, 34 insertions(+)

diff --git a/ell/genl.c b/ell/genl.c
index 85e447a..c522ae7 100644
--- a/ell/genl.c
+++ b/ell/genl.c
@@ -793,6 +793,38 @@ LIB_EXPORT bool l_genl_msg_append_attr(struct l_genl_m=
sg *msg, uint16_t type,
 	return true;
 }
 =

+LIB_EXPORT bool l_genl_msg_append_attrv(struct l_genl_msg *msg, uint16_t t=
ype,
+					struct iovec *iov, size_t iov_len)
+{
+	struct nlattr *nla;
+	size_t len =3D 0;
+	unsigned int i;
+
+	if (unlikely(!msg))
+		return false;
+
+	for (i =3D 0; i < iov_len; i++)
+		len +=3D iov[i].iov_len;
+
+	if (msg->len + NLA_HDRLEN + NLA_ALIGN(len) > msg->size)
+		return false;
+
+	nla =3D msg->data + msg->len;
+	nla->nla_len =3D NLA_HDRLEN + len;
+	nla->nla_type =3D type;
+
+	msg->len +=3D NLA_HDRLEN;
+
+	for (i =3D 0; i < iov_len; i++, iov++) {
+		memcpy(msg->data + msg->len, iov->iov_base, iov->iov_len);
+		msg->len +=3D iov->iov_len;
+	}
+
+	msg->len +=3D NLA_ALIGN(len) - len;
+
+	return true;
+}
+
 LIB_EXPORT bool l_genl_msg_enter_nested(struct l_genl_msg *msg, uint16_t t=
ype)
 {
 	struct nlattr *nla;
diff --git a/ell/genl.h b/ell/genl.h
index 5b37d55..fe188d9 100644
--- a/ell/genl.h
+++ b/ell/genl.h
@@ -71,6 +71,8 @@ int l_genl_msg_get_error(struct l_genl_msg *msg);
 =

 bool l_genl_msg_append_attr(struct l_genl_msg *msg, uint16_t type,
 					uint16_t len, const void *data);
+bool l_genl_msg_append_attrv(struct l_genl_msg *msg, uint16_t type,
+					struct iovec *iov, size_t iov_len);
 bool l_genl_msg_enter_nested(struct l_genl_msg *msg, uint16_t type);
 bool l_genl_msg_leave_nested(struct l_genl_msg *msg);
 =

-- =

2.7.4


--===============2908044464407161810==--

