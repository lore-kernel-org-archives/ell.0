Content-Type: multipart/mixed; boundary="===============3176787048955415090=="
MIME-Version: 1.0
From: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>
Subject: [PATCH] genl: Add utility function no append nested attribute into a
 message
Date: Wed, 25 Feb 2015 14:06:30 +0200
Message-ID: <1424865990-7503-1-git-send-email-tomasz.bursztyka@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3176787048955415090==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

It will fill-in a l_genl_attr structure with the necessary information
where the nested attribute starts. Thus at the end, it will update the
nested attribute with the final length.
---
 ell/genl.c | 48 ++++++++++++++++++++++++++++++++++++++++++++++++
 ell/genl.h |  3 +++
 2 files changed, 51 insertions(+)

diff --git a/ell/genl.c b/ell/genl.c
index 2ef6a34..b74f3c0 100644
--- a/ell/genl.c
+++ b/ell/genl.c
@@ -707,6 +707,54 @@ bool l_genl_msg_append_attr(struct l_genl_msg *msg, ui=
nt16_t type,
 	return true;
 }
 =

+bool l_genl_msg_append_init_recurse(struct l_genl_msg *msg, uint16_t type,
+						struct l_genl_attr *nested)
+{
+	struct nlattr *nla;
+
+	if (!msg || !nested)
+		return false;
+
+	nla =3D msg->data + msg->len;
+	nla->nla_len =3D NLA_HDRLEN;
+	nla->nla_type =3D type;
+
+	if (!l_genl_msg_append_attr(msg, type, 0, NULL))
+		return false;
+
+	nested->msg =3D msg;
+	nested->data =3D nla;
+	nested->len =3D 0;
+	nested->next_data =3D NULL;
+	nested->next_len =3D 0;
+
+	return true;
+}
+
+bool l_genl_msg_append_end_recurse(struct l_genl_attr *nested)
+{
+	struct l_genl_msg *msg;
+	struct nlattr *nla;
+	uint32_t len;
+
+	if (!nested || !nested->msg)
+		return false;
+
+	msg =3D nested->msg;
+	len =3D nested->data - msg->data;
+	nla =3D msg->data + len;
+
+	len =3D msg->len - len;
+	if (len <=3D NLA_HDRLEN)
+		return false;
+
+	nla->nla_len =3D len;
+
+	msg->len =3D NLA_ALIGN(msg->len);
+
+	return true;
+}
+
 #define NLA_OK(nla,len)         ((len) >=3D (int) sizeof(struct nlattr) &&=
 \
 				(nla)->nla_len >=3D sizeof(struct nlattr) && \
 				(nla)->nla_len <=3D (len))
diff --git a/ell/genl.h b/ell/genl.h
index c628b8c..13fe149 100644
--- a/ell/genl.h
+++ b/ell/genl.h
@@ -71,6 +71,9 @@ int l_genl_msg_get_error(struct l_genl_msg *msg);
 =

 bool l_genl_msg_append_attr(struct l_genl_msg *msg, uint16_t type,
 					uint16_t len, const void *data);
+bool l_genl_msg_append_init_recurse(struct l_genl_msg *msg, uint16_t type,
+						struct l_genl_attr *nested);
+bool l_genl_msg_append_end_recurse(struct l_genl_attr *nested);
 =

 bool l_genl_attr_init(struct l_genl_attr *attr, struct l_genl_msg *msg);
 bool l_genl_attr_next(struct l_genl_attr *attr, uint16_t *type,
-- =

2.0.5


--===============3176787048955415090==--

