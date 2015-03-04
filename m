Content-Type: multipart/mixed; boundary="===============9204318812138968279=="
MIME-Version: 1.0
From: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>
Subject: [PATCH 1/2] genl: Normilize functions exports and parameters check as
 it should
Date: Wed, 04 Mar 2015 15:05:54 +0200
Message-ID: <1425474355-30536-2-git-send-email-tomasz.bursztyka@linux.intel.com>
In-Reply-To: <1425474355-30536-1-git-send-email-tomasz.bursztyka@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============9204318812138968279==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Ell follows a certain way of exporting library functions and checking
parameter's validity, so let's apply these rules to genl.c
---
 ell/genl.c | 152 ++++++++++++++++++++++++++++++++++-----------------------=
----
 1 file changed, 85 insertions(+), 67 deletions(-)

diff --git a/ell/genl.c b/ell/genl.c
index 5944da6..90c0864 100644
--- a/ell/genl.c
+++ b/ell/genl.c
@@ -489,11 +489,11 @@ static bool received_data(struct l_io *io, void *user=
_data)
 	return true;
 }
 =

-struct l_genl *l_genl_new(int fd)
+LIB_EXPORT struct l_genl *l_genl_new(int fd)
 {
 	struct l_genl *genl;
 =

-	if (fd < 0)
+	if (unlikely(fd < 0))
 		return NULL;
 =

 	genl =3D l_new(struct l_genl, 1);
@@ -522,7 +522,7 @@ struct l_genl *l_genl_new(int fd)
 	return l_genl_ref(genl);
 }
 =

-struct l_genl *l_genl_new_default(void)
+LIB_EXPORT struct l_genl *l_genl_new_default(void)
 {
 	struct l_genl *genl;
 	struct sockaddr_nl addr;
@@ -563,9 +563,9 @@ struct l_genl *l_genl_new_default(void)
 	return genl;
 }
 =

-struct l_genl *l_genl_ref(struct l_genl *genl)
+LIB_EXPORT struct l_genl *l_genl_ref(struct l_genl *genl)
 {
-	if (!genl)
+	if (unlikely(!genl))
 		return NULL;
 =

 	__sync_fetch_and_add(&genl->ref_count, 1);
@@ -573,9 +573,9 @@ struct l_genl *l_genl_ref(struct l_genl *genl)
 	return genl;
 }
 =

-void l_genl_unref(struct l_genl *genl)
+LIB_EXPORT void l_genl_unref(struct l_genl *genl)
 {
-	if (!genl)
+	if (unlikely(!genl))
 		return;
 =

 	if (__sync_sub_and_fetch(&genl->ref_count, 1))
@@ -604,10 +604,12 @@ void l_genl_unref(struct l_genl *genl)
 	l_free(genl);
 }
 =

-bool l_genl_set_debug(struct l_genl *genl, l_genl_debug_func_t callback,
-				void *user_data, l_genl_destroy_func_t destroy)
+LIB_EXPORT bool l_genl_set_debug(struct l_genl *genl,
+					l_genl_debug_func_t callback,
+					void *user_data,
+					l_genl_destroy_func_t destroy)
 {
-	if (!genl)
+	if (unlikely(!genl))
 		return false;
 =

 	if (genl->debug_destroy)
@@ -620,9 +622,9 @@ bool l_genl_set_debug(struct l_genl *genl, l_genl_debug=
_func_t callback,
 	return true;
 }
 =

-bool l_genl_set_close_on_unref(struct l_genl *genl, bool do_close)
+LIB_EXPORT bool l_genl_set_close_on_unref(struct l_genl *genl, bool do_clo=
se)
 {
-	if (!genl)
+	if (unlikely(!genl))
 		return false;
 =

 	genl->close_on_unref =3D do_close;
@@ -630,19 +632,19 @@ bool l_genl_set_close_on_unref(struct l_genl *genl, b=
ool do_close)
 	return true;
 }
 =

-struct l_genl_msg *l_genl_msg_new(uint8_t cmd)
+LIB_EXPORT struct l_genl_msg *l_genl_msg_new(uint8_t cmd)
 {
 	return l_genl_msg_new_sized(cmd, 0);
 }
 =

-struct l_genl_msg *l_genl_msg_new_sized(uint8_t cmd, uint32_t size)
+LIB_EXPORT struct l_genl_msg *l_genl_msg_new_sized(uint8_t cmd, uint32_t s=
ize)
 {
 	return msg_alloc(cmd, 0x00, size);
 }
 =

-struct l_genl_msg *l_genl_msg_ref(struct l_genl_msg *msg)
+LIB_EXPORT struct l_genl_msg *l_genl_msg_ref(struct l_genl_msg *msg)
 {
-	if (!msg)
+	if (unlikely(!msg))
 		return NULL;
 =

 	__sync_fetch_and_add(&msg->ref_count, 1);
@@ -650,9 +652,9 @@ struct l_genl_msg *l_genl_msg_ref(struct l_genl_msg *ms=
g)
 	return msg;
 }
 =

-void l_genl_msg_unref(struct l_genl_msg *msg)
+LIB_EXPORT void l_genl_msg_unref(struct l_genl_msg *msg)
 {
-	if (!msg)
+	if (unlikely(!msg))
 		return;
 =

 	if (__sync_sub_and_fetch(&msg->ref_count, 1))
@@ -662,36 +664,36 @@ void l_genl_msg_unref(struct l_genl_msg *msg)
 	l_free(msg);
 }
 =

-uint8_t l_genl_msg_get_command(struct l_genl_msg *msg)
+LIB_EXPORT uint8_t l_genl_msg_get_command(struct l_genl_msg *msg)
 {
-	if (!msg)
+	if (unlikely(!msg))
 		return 0;
 =

 	return msg->cmd;
 }
 =

-uint8_t l_genl_msg_get_version(struct l_genl_msg *msg)
+LIB_EXPORT uint8_t l_genl_msg_get_version(struct l_genl_msg *msg)
 {
-	if (!msg)
+	if (unlikely(!msg))
 		return 0;
 =

 	return msg->version;
 }
 =

-int l_genl_msg_get_error(struct l_genl_msg *msg)
+LIB_EXPORT int l_genl_msg_get_error(struct l_genl_msg *msg)
 {
-	if (!msg)
+	if (unlikely(!msg))
 		return -ENOMSG;
 =

 	return msg->error;
 }
 =

-bool l_genl_msg_append_attr(struct l_genl_msg *msg, uint16_t type,
-					uint16_t len, const void *data)
+LIB_EXPORT bool l_genl_msg_append_attr(struct l_genl_msg *msg, uint16_t ty=
pe,
+						uint16_t len, const void *data)
 {
 	struct nlattr *nla;
 =

-	if (!msg)
+	if (unlikely(!msg))
 		return false;
 =

 	if (msg->len + NLA_HDRLEN + NLA_ALIGN(len) > msg->size)
@@ -718,12 +720,13 @@ bool l_genl_msg_append_attr(struct l_genl_msg *msg, u=
int16_t type,
 #define NLA_DATA(nla)		((void*)(((char*)(nla)) + NLA_LENGTH(0)))
 #define NLA_PAYLOAD(nla)	((int)((nla)->nla_len) - NLA_LENGTH(0))
 =

-bool l_genl_attr_init(struct l_genl_attr *attr, struct l_genl_msg *msg)
+LIB_EXPORT bool l_genl_attr_init(struct l_genl_attr *attr,
+						struct l_genl_msg *msg)
 {
 	const struct nlattr *nla;
 	uint32_t len;
 =

-	if (!attr || !msg)
+	if (unlikely(!attr) || unlikely(!msg))
 		return false;
 =

 	if (!msg->data || msg->len < NLMSG_HDRLEN + GENL_HDRLEN)
@@ -744,12 +747,14 @@ bool l_genl_attr_init(struct l_genl_attr *attr, struc=
t l_genl_msg *msg)
 	return true;
 }
 =

-bool l_genl_attr_next(struct l_genl_attr *attr, uint16_t *type,
-					uint16_t *len, const void **data)
+LIB_EXPORT bool l_genl_attr_next(struct l_genl_attr *attr,
+						uint16_t *type,
+						uint16_t *len,
+						const void **data)
 {
 	const struct nlattr *nla;
 =

-	if (!attr)
+	if (unlikely(!attr))
 		return false;
 =

 	nla =3D attr->next_data;
@@ -774,11 +779,12 @@ bool l_genl_attr_next(struct l_genl_attr *attr, uint1=
6_t *type,
 	return true;
 }
 =

-bool l_genl_attr_recurse(struct l_genl_attr *attr, struct l_genl_attr *nes=
ted)
+LIB_EXPORT bool l_genl_attr_recurse(struct l_genl_attr *attr,
+						struct l_genl_attr *nested)
 {
 	const struct nlattr *nla;
 =

-	if (!attr || !nested)
+	if (unlikely(!attr) || unlikely(!nested))
 		return false;
 =

 	nla =3D attr->data;
@@ -905,12 +911,13 @@ static void get_family_callback(struct l_genl_msg *ms=
g, void *user_data)
 		family->watch_appeared(family->watch_data);
 }
 =

-struct l_genl_family *l_genl_family_new(struct l_genl *genl, const char *n=
ame)
+LIB_EXPORT struct l_genl_family *l_genl_family_new(struct l_genl *genl,
+							const char *name)
 {
 	struct l_genl_family *family;
 	struct l_genl_msg *msg;
 =

-	if (!genl || !name)
+	if (unlikely(!genl) || unlikely(!name))
 		return NULL;
 =

 	family =3D family_alloc(genl, name);
@@ -935,9 +942,10 @@ struct l_genl_family *l_genl_family_new(struct l_genl =
*genl, const char *name)
 	return family;
 }
 =

-struct l_genl_family *l_genl_family_ref(struct l_genl_family *family)
+LIB_EXPORT struct l_genl_family *l_genl_family_ref(
+						struct l_genl_family *family)
 {
-	if (!family)
+	if (unlikely(!family))
 		return NULL;
 =

 	__sync_fetch_and_add(&family->ref_count, 1);
@@ -945,11 +953,11 @@ struct l_genl_family *l_genl_family_ref(struct l_genl=
_family *family)
 	return family;
 }
 =

-void l_genl_family_unref(struct l_genl_family *family)
+LIB_EXPORT void l_genl_family_unref(struct l_genl_family *family)
 {
 	struct l_genl *genl;
 =

-	if (!family)
+	if (unlikely(!family))
 		return;
 =

 	if (__sync_sub_and_fetch(&family->ref_count, 1))
@@ -975,12 +983,13 @@ void l_genl_family_unref(struct l_genl_family *family)
 	l_free(family);
 }
 =

-bool l_genl_family_set_watches(struct l_genl_family *family,
-				l_genl_watch_func_t appeared,
-				l_genl_watch_func_t vanished,
-				void *user_data, l_genl_destroy_func_t destroy)
+LIB_EXPORT bool l_genl_family_set_watches(struct l_genl_family *family,
+						l_genl_watch_func_t appeared,
+						l_genl_watch_func_t vanished,
+						void *user_data,
+						l_genl_destroy_func_t destroy)
 {
-	if (!family)
+	if (unlikely(!family))
 		return false;
 =

 	if (family->watch_destroy)
@@ -994,9 +1003,9 @@ bool l_genl_family_set_watches(struct l_genl_family *f=
amily,
 	return true;
 }
 =

-uint32_t l_genl_family_get_version(struct l_genl_family *family)
+LIB_EXPORT uint32_t l_genl_family_get_version(struct l_genl_family *family)
 {
-	if (!family)
+	if (unlikely(!family))
 		return 0;
 =

 	return family->version;
@@ -1010,11 +1019,12 @@ static bool match_op_id(const void *a, const void *=
b)
 	return op->id =3D=3D id;
 }
 =

-bool l_genl_family_can_send(struct l_genl_family *family, uint8_t cmd)
+LIB_EXPORT bool l_genl_family_can_send(struct l_genl_family *family,
+								uint8_t cmd)
 {
 	struct genl_op *op;
 =

-	if (!family)
+	if (unlikely(!family))
 		return false;
 =

 	op =3D l_queue_find(family->op_list, match_op_id, L_UINT_TO_PTR(cmd));
@@ -1027,7 +1037,8 @@ bool l_genl_family_can_send(struct l_genl_family *fam=
ily, uint8_t cmd)
 	return false;
 }
 =

-bool l_genl_family_can_dump(struct l_genl_family *family, uint8_t cmd)
+LIB_EXPORT bool l_genl_family_can_dump(struct l_genl_family *family,
+								uint8_t cmd)
 {
 	struct genl_op *op;
 =

@@ -1081,19 +1092,21 @@ static unsigned int send_common(struct l_genl_famil=
y *family, uint16_t flags,
 	return request->id;
 }
 =

-unsigned int l_genl_family_send(struct l_genl_family *family,
-				struct l_genl_msg *msg,
-				l_genl_msg_func_t callback,
-				void *user_data, l_genl_destroy_func_t destroy)
+LIB_EXPORT unsigned int l_genl_family_send(struct l_genl_family *family,
+						struct l_genl_msg *msg,
+						l_genl_msg_func_t callback,
+						void *user_data,
+						l_genl_destroy_func_t destroy)
 {
 	return send_common(family, NLM_F_ACK, msg, callback,
 						user_data, destroy);
 }
 =

-unsigned int l_genl_family_dump(struct l_genl_family *family,
-				struct l_genl_msg *msg,
-				l_genl_msg_func_t callback,
-				void *user_data, l_genl_destroy_func_t destroy)
+LIB_EXPORT unsigned int l_genl_family_dump(struct l_genl_family *family,
+						struct l_genl_msg *msg,
+						l_genl_msg_func_t callback,
+						void *user_data,
+						l_genl_destroy_func_t destroy)
 {
 	return send_common(family, NLM_F_ACK | NLM_F_DUMP, msg, callback,
 							user_data, destroy);
@@ -1107,12 +1120,13 @@ static bool match_request_id(const void *a, const v=
oid *b)
 	return request->id =3D=3D id;
 }
 =

-bool l_genl_family_cancel(struct l_genl_family *family, unsigned int id)
+LIB_EXPORT bool l_genl_family_cancel(struct l_genl_family *family,
+							unsigned int id)
 {
 	struct l_genl *genl;
 	struct genl_request *request;
 =

-	if (!family || !id)
+	if (unlikely(!family) || unlikely(!id))
 		return false;
 =

 	genl =3D family->genl;
@@ -1149,11 +1163,12 @@ static void add_membership(struct l_genl *genl, str=
uct genl_mcast *mcast)
 	mcast->users++;
 }
 =

-bool l_genl_family_has_group(struct l_genl_family *family, const char *gro=
up)
+LIB_EXPORT bool l_genl_family_has_group(struct l_genl_family *family,
+							const char *group)
 {
 	struct genl_mcast *mcast;
 =

-	if (!family)
+	if (unlikely(!family))
 		return false;
 =

 	mcast =3D l_queue_find(family->mcast_list, match_mcast_name,
@@ -1164,15 +1179,17 @@ bool l_genl_family_has_group(struct l_genl_family *=
family, const char *group)
 	return true;
 }
 =

-unsigned int l_genl_family_register(struct l_genl_family *family,
-				const char *group, l_genl_msg_func_t callback,
-				void *user_data, l_genl_destroy_func_t destroy)
+LIB_EXPORT unsigned int l_genl_family_register(struct l_genl_family *famil=
y,
+						const char *group,
+						l_genl_msg_func_t callback,
+						void *user_data,
+						l_genl_destroy_func_t destroy)
 {
 	struct l_genl *genl;
 	struct genl_notify *notify;
 	struct genl_mcast *mcast;
 =

-	if (!family || !group)
+	if (unlikely(!family) || unlikely(!group))
 		return 0;
 =

 	genl =3D family->genl;
@@ -1213,7 +1230,8 @@ static bool match_notify_id(const void *a, const void=
 *b)
 	return notify->id =3D=3D id;
 }
 =

-bool l_genl_family_unregister(struct l_genl_family *family, unsigned int i=
d)
+LIB_EXPORT bool l_genl_family_unregister(struct l_genl_family *family,
+							unsigned int id)
 {
 	struct l_genl *genl;
 	struct genl_notify *notify;
-- =

2.0.5


--===============9204318812138968279==--

