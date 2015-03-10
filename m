Content-Type: multipart/mixed; boundary="===============2137809089075601049=="
MIME-Version: 1.0
From: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>
Subject: [PATCH 2/4] genl: Add a message builder API to help creating complex
 nl messages
Date: Tue, 10 Mar 2015 13:14:28 +0200
Message-ID: <1425986070-8808-3-git-send-email-tomasz.bursztyka@linux.intel.com>
In-Reply-To: <1425986070-8808-1-git-send-email-tomasz.bursztyka@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2137809089075601049==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/genl.c | 134 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++=
++++
 ell/genl.h |  18 +++++++++
 2 files changed, 152 insertions(+)

diff --git a/ell/genl.c b/ell/genl.c
index 90c0864..c49c363 100644
--- a/ell/genl.c
+++ b/ell/genl.c
@@ -34,6 +34,7 @@
 #include "io.h"
 #include "netlink-private.h"
 #include "genl.h"
+#include "genl-private.h"
 #include "private.h"
 =

 struct l_genl {
@@ -114,6 +115,12 @@ struct l_genl_family {
 	unsigned int nlctrl_cmd;
 };
 =

+struct l_genl_msg_builder {
+	struct l_genl_msg *message;
+	struct l_queue *nests;
+	struct nlattr *last_nested;
+};
+
 static void destroy_request(void *data)
 {
 	struct genl_request *request =3D data;
@@ -642,6 +649,16 @@ LIB_EXPORT struct l_genl_msg *l_genl_msg_new_sized(uin=
t8_t cmd, uint32_t size)
 	return msg_alloc(cmd, 0x00, size);
 }
 =

+const void *_genl_msg_get_as_raw_data(struct l_genl_msg *msg, uint32_t *le=
n)
+{
+	if (!msg)
+		return NULL;
+
+	*len =3D msg->len;
+
+	return msg->data;
+}
+
 LIB_EXPORT struct l_genl_msg *l_genl_msg_ref(struct l_genl_msg *msg)
 {
 	if (unlikely(!msg))
@@ -1252,3 +1269,120 @@ LIB_EXPORT bool l_genl_family_unregister(struct l_g=
enl_family *family,
 =

 	return true;
 }
+
+LIB_EXPORT struct l_genl_msg_builder *l_genl_msg_builder_new(
+						struct l_genl_msg *message)
+{
+	struct l_genl_msg_builder *ret;
+
+	if (unlikely(!message))
+		return NULL;
+
+	ret =3D l_new(struct l_genl_msg_builder, 1);
+	ret->message =3D l_genl_msg_ref(message);
+
+	return ret;
+}
+
+static inline void builder_message_realign(struct l_genl_msg_builder *buil=
der)
+{
+	if (!builder->last_nested)
+		return;
+
+	if (!builder->nests)
+		builder->message->len =3D NLA_ALIGN(builder->message->len);
+
+	builder->last_nested =3D NULL;
+}
+
+LIB_EXPORT bool l_genl_msg_builder_append_attribute(
+					struct l_genl_msg_builder *builder,
+					uint16_t type, uint16_t len,
+					const void *data)
+{
+	if (unlikely(!builder))
+		return false;
+
+	builder_message_realign(builder);
+
+	return l_genl_msg_append_attr(builder->message, type, len, data);
+}
+
+LIB_EXPORT bool l_genl_msg_builder_enter_nested(
+					struct l_genl_msg_builder *builder,
+					uint16_t type)
+{
+	struct nlattr *nla;
+
+	if (unlikely(!builder))
+		return false;
+
+	if (!builder->nests) {
+		builder->nests =3D l_queue_new();
+		if (!builder->nests)
+			return false;
+	}
+
+	builder_message_realign(builder);
+
+	nla =3D builder->message->data + builder->message->len;
+	nla->nla_len =3D NLA_HDRLEN;
+	nla->nla_type =3D type;
+
+	if (!l_genl_msg_append_attr(builder->message, type, 0, NULL))
+		return false;
+
+	return l_queue_push_head(builder->nests, nla);
+}
+
+LIB_EXPORT bool l_genl_msg_builder_leave_nested(
+					struct l_genl_msg_builder *builder)
+{
+	struct nlattr *nla;
+	uint32_t len;
+
+	if (unlikely(!builder) || unlikely(!builder->nests))
+		return false;
+
+	nla =3D l_queue_pop_head(builder->nests);
+	if (!nla)
+		return false;
+
+	if (l_queue_isempty(builder->nests)) {
+		l_queue_destroy(builder->nests, NULL);
+		builder->nests =3D NULL;
+	}
+
+	// In case nothing has been appended into the nested attribute
+	// it could try to be smart and revert the message back and return true
+	len =3D builder->message->len - ((void *)nla - builder->message->data);
+	if (len <=3D NLA_HDRLEN)
+		return false;
+
+	nla->nla_len =3D len;
+
+	builder->last_nested =3D nla;
+
+	return true;
+}
+
+LIB_EXPORT void l_genl_msg_builder_destroy(struct l_genl_msg_builder *buil=
der)
+{
+	if (unlikely(!builder))
+		return;
+
+	l_queue_destroy(builder->nests, NULL);
+	l_genl_msg_unref(builder->message);
+	l_free(builder);
+}
+
+LIB_EXPORT struct l_genl_msg *l_genl_msg_builder_finalize(
+					struct l_genl_msg_builder *builder)
+{
+	if (unlikely(!builder) || unlikely(builder->nests))
+		return NULL;
+
+	builder_message_realign(builder);
+
+	return builder->message;
+}
diff --git a/ell/genl.h b/ell/genl.h
index c628b8c..a31db1c 100644
--- a/ell/genl.h
+++ b/ell/genl.h
@@ -112,6 +112,24 @@ unsigned int l_genl_family_register(struct l_genl_fami=
ly *family,
 				void *user_data, l_genl_destroy_func_t destroy);
 bool l_genl_family_unregister(struct l_genl_family *family, unsigned int i=
d);
 =

+struct l_genl_msg_builder;
+
+struct l_genl_msg_builder *l_genl_msg_builder_new(struct l_genl_msg *msg);
+
+bool l_genl_msg_builder_append_attribute(struct l_genl_msg_builder *builde=
r,
+						uint16_t type, uint16_t len,
+						const void *data);
+
+bool l_genl_msg_builder_enter_nested(struct l_genl_msg_builder *builder,
+								uint16_t type);
+
+bool l_genl_msg_builder_leave_nested(struct l_genl_msg_builder *builder);
+
+void l_genl_msg_builder_destroy(struct l_genl_msg_builder *builder);
+
+struct l_genl_msg *l_genl_msg_builder_finalize(
+					struct l_genl_msg_builder *builder);
+
 #ifdef __cplusplus
 }
 #endif
-- =

2.0.5


--===============2137809089075601049==--

