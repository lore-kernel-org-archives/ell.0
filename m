Content-Type: multipart/mixed; boundary="===============5994281413339247787=="
MIME-Version: 1.0
From: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>
Subject: [RFC] genl: Add a message builder API to help creating complex nl
 messages
Date: Tue, 24 Mar 2015 13:21:49 +0200
Message-ID: <1427196109-21373-1-git-send-email-tomasz.bursztyka@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5994281413339247787==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---

Hi Marcel,

Quickly, as an RFC, does this look better?
For building message I think either one uses l_genl_msg or l_genl_msg_build=
er.
Thus I changed l_genl_msg_builder_new(): it creates the l_genl_msg by itsel=
f.

Only when one calls l_genl_msg_builder_finalize(), he will get a reference =
on
the message. Such reference l_genl_family_send() will unref, or that he will
in case of error.

Does that look saner? At least it avoids the user to call l_genl_msg_new()
and again l_genl_msg_builder() afterwards. I think it's better to separate
properly both.

I kept the queue for the nested of nested etc... I still want your opinion:
either a queue or a fixed depth of nested of nested ? or we don't care?
(I think we do care).

 ell/genl.c | 118 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++=
++++
 ell/genl.h |  19 ++++++++++
 2 files changed, 137 insertions(+)

diff --git a/ell/genl.c b/ell/genl.c
index 1b1afab..460d078 100644
--- a/ell/genl.c
+++ b/ell/genl.c
@@ -115,6 +115,12 @@ struct l_genl_family {
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
@@ -1280,3 +1286,115 @@ LIB_EXPORT bool l_genl_family_unregister(struct l_g=
enl_family *family,
 =

 	return true;
 }
+
+LIB_EXPORT struct l_genl_msg_builder *l_genl_msg_builder_new(uint8_t cmd,
+								uint32_t size)
+{
+	struct l_genl_msg_builder *ret;
+
+	ret =3D l_new(struct l_genl_msg_builder, 1);
+	ret->message =3D l_genl_msg_new_sized(cmd, size);
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
+LIB_EXPORT bool l_genl_msg_builder_append_attr(
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
+	return l_genl_msg_ref(builder->message);
+}
diff --git a/ell/genl.h b/ell/genl.h
index c628b8c..773682a 100644
--- a/ell/genl.h
+++ b/ell/genl.h
@@ -112,6 +112,25 @@ unsigned int l_genl_family_register(struct l_genl_fami=
ly *family,
 				void *user_data, l_genl_destroy_func_t destroy);
 bool l_genl_family_unregister(struct l_genl_family *family, unsigned int i=
d);
 =

+struct l_genl_msg_builder;
+
+struct l_genl_msg_builder *l_genl_msg_builder_new(uint8_t cmd,
+							uint32_t size);
+
+bool l_genl_msg_builder_append_attr(struct l_genl_msg_builder *builder,
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


--===============5994281413339247787==--

