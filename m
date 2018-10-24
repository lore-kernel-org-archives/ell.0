Content-Type: multipart/mixed; boundary="===============3769283143652587369=="
MIME-Version: 1.0
From: James Prestwood <james.prestwood@linux.intel.com>
Subject: [PATCH 1/2] genl: rework l_genl_family to avoid extra lookups
Date: Wed, 24 Oct 2018 13:52:13 -0700
Message-ID: <20181024205214.8376-1-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3769283143652587369==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Instead of looking up and re-allocating an entirely new l_genl_family
with each call to l_genl_family_new, we can use a previous lookup that
matches our family name.

A new internal structure was introduced, genl_parent, which holds all
the lookup information for a given family name. Now, when
l_genl_famil_new is called, we allocate a smaller child structure
(l_genl_family) which holds a pointer back to the parent object in order
to send and receive messages. This child structure only holds callback
information and the (new) group ID (gid).

Messages are now tagged with child group ID which allows for cancelling
all requets on a given child object without affecting other children of
the same parent. Cancelling all requets on a child object is as simple
as destroying the l_genl_family object (l_genl_family_unref).
---
 ell/genl.c | 369 +++++++++++++++++++++++++++++++++++------------------
 1 file changed, 245 insertions(+), 124 deletions(-)

diff --git a/ell/genl.c b/ell/genl.c
index 3a0281a..1dfdf1f 100644
--- a/ell/genl.c
+++ b/ell/genl.c
@@ -63,8 +63,9 @@ struct l_genl {
 	struct l_queue *notify_list;
 	unsigned int next_request_id;
 	unsigned int next_notify_id;
+	unsigned int next_gid;
 	struct l_queue *family_list;
-	struct l_genl_family *nlctrl;
+	struct genl_parent *nlctrl;
 	struct genl_unicast_notify *unicast_notify;
 	l_genl_debug_func_t debug_callback;
 	l_genl_destroy_func_t debug_destroy;
@@ -85,6 +86,7 @@ struct l_genl_msg {
 =

 struct genl_request {
 	unsigned int id;
+	unsigned int gid;
 	uint16_t type;
 	uint16_t flags;
 	uint32_t seq;
@@ -114,8 +116,7 @@ struct genl_mcast {
 	unsigned int users;
 };
 =

-struct l_genl_family {
-	int ref_count;
+struct genl_parent {
 	struct l_genl *genl;
 	char name[GENL_NAMSIZ];
 	uint16_t id;
@@ -124,11 +125,19 @@ struct l_genl_family {
 	uint32_t maxattr;
 	struct l_queue *op_list;
 	struct l_queue *mcast_list;
+	unsigned int nlctrl_cmd;
+	struct l_queue *children;
+	bool live;
+};
+
+struct l_genl_family {
+	struct genl_parent *parent;
+	int ref_count;
+	unsigned int gid;
 	l_genl_watch_func_t watch_appeared;
 	l_genl_watch_func_t watch_vanished;
 	l_genl_destroy_func_t watch_destroy;
 	void *watch_data;
-	unsigned int nlctrl_cmd;
 };
 =

 static void destroy_request(void *data)
@@ -153,20 +162,31 @@ static void destroy_notify(void *data)
 	l_free(notify);
 }
 =

-static struct l_genl_family *family_alloc(struct l_genl *genl,
-							const char *name)
+static struct l_genl_family *family_alloc_child(struct genl_parent *parent)
 {
-	struct l_genl_family *family;
+	struct l_genl_family *family =3D l_new(struct l_genl_family, 1);
 =

-	family =3D l_new(struct l_genl_family, 1);
+	family->parent =3D parent;
+	family->gid =3D parent->genl->next_gid++;
 =

-	family->genl =3D genl;
-	strncpy(family->name, name, GENL_NAMSIZ);
+	l_queue_push_tail(parent->children, family);
 =

-	family->op_list =3D l_queue_new();
-	family->mcast_list =3D l_queue_new();
+	return family;
+}
 =

-	return l_genl_family_ref(family);
+static struct genl_parent *family_alloc_parent(struct l_genl *genl,
+							const char *name)
+{
+	struct genl_parent *parent =3D l_new(struct genl_parent, 1);
+
+	parent->genl =3D genl;
+	strncpy(parent->name, name, GENL_NAMSIZ);
+
+	parent->op_list =3D l_queue_new();
+	parent->mcast_list =3D l_queue_new();
+	parent->children =3D l_queue_new();
+
+	return parent;
 }
 =

 static void op_free(void *data)
@@ -191,16 +211,63 @@ static void mcast_free(void *data, void *user_data)
 	l_free(mcast);
 }
 =

-static void family_free(void *data)
+static bool request_match_gid(const void *a, const void *b)
 {
-	struct l_genl_family *family =3D data;
+	const struct genl_request *request =3D a;
+	unsigned int gid =3D L_PTR_TO_UINT(b);
+
+	if (request->gid =3D=3D gid)
+		return true;
+
+	return false;
+}
+
+static void cancel_all_requests(struct l_genl_family *child)
+{
+	struct l_genl *genl =3D child->parent->genl;
+	struct genl_request *request;
+
+	/* genl has already been cleaned up */
+	if (!genl->request_queue)
+		return;
+
+	while ((request =3D l_queue_find(genl->request_queue, request_match_gid,
+					L_UINT_TO_PTR(child->gid))))
+		l_genl_family_cancel(child, request->id);
+}
+
+static void child_free(void *data)
+{
+	struct l_genl_family *child =3D data;
+
+	cancel_all_requests(child);
+
+	if (child->parent->id > 0 && child->watch_vanished)
+		child->watch_vanished(child->watch_data);
+
+	if (child->watch_destroy)
+		child->watch_destroy(child->watch_data);
+
+
+	l_free(child);
+}
+
+static void parent_free(void *data)
+{
+	struct genl_parent *parent =3D data;
+
+	l_queue_destroy(parent->children, child_free);
+
+	l_queue_destroy(parent->op_list, op_free);
 =

-	family->genl =3D NULL;
+	l_queue_foreach(parent->mcast_list, mcast_free, parent->genl);
+	l_queue_destroy(parent->mcast_list, NULL);
+	parent->mcast_list =3D NULL;
 =

-	l_genl_family_unref(family);
+	l_free(parent);
 }
 =

-static void family_add_op(struct l_genl_family *family, uint32_t id,
+static void family_add_op(struct genl_parent *parent, uint32_t id,
 							uint32_t flags)
 {
 	struct genl_op *op;
@@ -210,7 +277,7 @@ static void family_add_op(struct l_genl_family *family,=
 uint32_t id,
 	op->id =3D id;
 	op->flags =3D flags;
 =

-	l_queue_push_tail(family->op_list, op);
+	l_queue_push_tail(parent->op_list, op);
 }
 =

 static bool match_mcast_name(const void *a, const void *b)
@@ -221,16 +288,16 @@ static bool match_mcast_name(const void *a, const voi=
d *b)
 	return !strcmp(mcast->name, name);
 }
 =

-static void family_add_mcast(struct l_genl_family *family, const char *nam=
e,
+static void family_add_mcast(struct genl_parent *parent, const char *name,
 								uint32_t id)
 {
-	struct l_genl *genl =3D family->genl;
+	struct l_genl *genl =3D parent->genl;
 	struct genl_mcast *mcast;
 =

 	if (!genl)
 		return;
 =

-	mcast =3D l_queue_find(family->mcast_list, match_mcast_name,
+	mcast =3D l_queue_find(parent->mcast_list, match_mcast_name,
 							(char *) name);
 	if (mcast)
 		return;
@@ -241,7 +308,26 @@ static void family_add_mcast(struct l_genl_family *fam=
ily, const char *name,
 	mcast->id =3D id;
 	mcast->users =3D 0;
 =

-	l_queue_push_tail(family->mcast_list, mcast);
+	l_queue_push_tail(parent->mcast_list, mcast);
+}
+
+/* special initializer for the nlctrl object */
+static struct genl_parent *family_alloc_ctrl(struct l_genl *genl)
+{
+	struct genl_parent *nlctrl;
+
+	nlctrl =3D l_new(struct genl_parent, 1);
+
+	nlctrl->genl =3D genl;
+	strncpy(nlctrl->name, "nlctrl", GENL_NAMSIZ);
+
+	nlctrl->op_list =3D l_queue_new();
+	nlctrl->mcast_list =3D l_queue_new();
+	nlctrl->id =3D GENL_ID_CTRL;
+
+	family_add_mcast(nlctrl, "notify", GENL_ID_CTRL);
+
+	return nlctrl;
 }
 =

 static struct l_genl_msg *msg_alloc(uint8_t cmd, uint8_t version, uint32_t=
 size)
@@ -549,13 +635,7 @@ LIB_EXPORT struct l_genl *l_genl_new(int fd)
 	genl->fd =3D fd;
 	genl->close_on_unref =3D false;
 =

-	genl->nlctrl =3D family_alloc(genl, "nlctrl");
-
-	genl->nlctrl->id =3D GENL_ID_CTRL;
-
-	family_add_mcast(genl->nlctrl, "notify", GENL_ID_CTRL);
-
-	l_queue_push_tail(genl->family_list, genl->nlctrl);
+	genl->nlctrl =3D family_alloc_ctrl(genl);
 =

 	genl->io =3D l_io_new(genl->fd);
 =

@@ -632,6 +712,7 @@ LIB_EXPORT void l_genl_unref(struct l_genl *genl)
 	l_queue_destroy(genl->notify_list, destroy_notify);
 	l_queue_destroy(genl->pending_list, destroy_request);
 	l_queue_destroy(genl->request_queue, destroy_request);
+	genl->request_queue =3D NULL;
 =

 	l_io_set_write_handler(genl->io, NULL, NULL, NULL);
 	l_io_set_read_handler(genl->io, NULL, NULL, NULL);
@@ -639,9 +720,9 @@ LIB_EXPORT void l_genl_unref(struct l_genl *genl)
 	l_io_destroy(genl->io);
 	genl->io =3D NULL;
 =

-	l_genl_family_unref(genl->nlctrl);
+	parent_free(genl->nlctrl);
 =

-	l_queue_destroy(genl->family_list, family_free);
+	l_queue_destroy(genl->family_list, parent_free);
 =

 	if (genl->close_on_unref)
 		close(genl->fd);
@@ -984,7 +1065,7 @@ LIB_EXPORT bool l_genl_attr_recurse(struct l_genl_attr=
 *attr,
 	return true;
 }
 =

-static void family_ops(struct l_genl_family *family, struct l_genl_attr *a=
ttr)
+static void family_ops(struct genl_parent *parent, struct l_genl_attr *att=
r)
 {
 	uint16_t type, len;
 	const void *data;
@@ -1007,11 +1088,11 @@ static void family_ops(struct l_genl_family *family=
, struct l_genl_attr *attr)
 		}
 =

 		if (id > 0)
-			family_add_op(family, id, flags);
+			family_add_op(parent, id, flags);
 	}
 }
 =

-static void family_mcast_groups(struct l_genl_family *family,
+static void family_mcast_groups(struct genl_parent *parent,
 						struct l_genl_attr *attr)
 {
 	uint16_t type, len;
@@ -1036,21 +1117,30 @@ static void family_mcast_groups(struct l_genl_famil=
y *family,
 		}
 =

 		if (name && id > 0)
-			family_add_mcast(family, name, id);
+			family_add_mcast(parent, name, id);
 	}
 }
 =

+static void family_notify_appeared(void *data, void *user_data)
+{
+	struct l_genl_family *family =3D data;
+
+	if (family->watch_appeared)
+		family->watch_appeared(family->watch_data);
+}
+
 static void get_family_callback(struct l_genl_msg *msg, void *user_data)
 {
 	struct l_genl_family *family =3D user_data;
+	struct genl_parent *parent =3D family->parent;
 	struct l_genl_attr attr, nested;
 	uint16_t type, len;
 	const void *data;
 	int error;
 =

-	family->nlctrl_cmd =3D 0;
+	parent->nlctrl_cmd =3D 0;
 =

-	if (family->id > 0)
+	if (parent->id > 0)
 		return;
 =

 	error =3D l_genl_msg_get_error(msg);
@@ -1066,38 +1156,86 @@ static void get_family_callback(struct l_genl_msg *=
msg, void *user_data)
 	while (l_genl_attr_next(&attr, &type, &len, &data)) {
 		switch (type) {
 		case CTRL_ATTR_FAMILY_ID:
-			family->id =3D *((uint16_t *) data);
+			parent->id =3D *((uint16_t *) data);
 			break;
 		case CTRL_ATTR_FAMILY_NAME:
-			strncpy(family->name, data, GENL_NAMSIZ);
+			strncpy(parent->name, data, GENL_NAMSIZ);
 			break;
 		case CTRL_ATTR_VERSION:
-			family->version =3D *((uint32_t *) data);
+			parent->version =3D *((uint32_t *) data);
 			break;
 		case CTRL_ATTR_HDRSIZE:
-			family->hdrsize =3D *((uint32_t *) data);
+			parent->hdrsize =3D *((uint32_t *) data);
 			break;
 		case CTRL_ATTR_MAXATTR:
-			family->maxattr =3D *((uint32_t *) data);
+			parent->maxattr =3D *((uint32_t *) data);
 			break;
 		case CTRL_ATTR_OPS:
 			if (l_genl_attr_recurse(&attr, &nested))
-				family_ops(family, &nested);
+				family_ops(parent, &nested);
 			break;
 		case CTRL_ATTR_MCAST_GROUPS:
 			if (l_genl_attr_recurse(&attr, &nested))
-				family_mcast_groups(family, &nested);
+				family_mcast_groups(parent, &nested);
 			break;
 		}
 	}
 =

-	if (family->watch_appeared)
-		family->watch_appeared(family->watch_data);
+	parent->live =3D true;
+
+	l_queue_foreach(parent->children, family_notify_appeared, NULL);
+}
+
+static bool match_family_name(const void *a, const void *b)
+{
+	const struct genl_parent *parent =3D a;
+
+	return !strncmp(parent->name, (const char *)b, GENL_NAMSIZ);
+}
+
+static unsigned int send_common(struct genl_parent *parent, uint16_t flags,
+				struct l_genl_msg *msg, unsigned int gid,
+				l_genl_msg_func_t callback, void *user_data,
+				l_genl_destroy_func_t destroy)
+{
+	struct l_genl *genl;
+	struct genl_request *request;
+
+	if (!parent || !msg)
+		return 0;
+
+	genl =3D parent->genl;
+	if (!genl)
+		return 0;
+
+	request =3D l_new(struct genl_request, 1);
+
+	request->type =3D parent->id;
+	request->flags =3D NLM_F_REQUEST | flags;
+
+	request->msg =3D msg;
+	request->gid =3D gid;
+
+	request->callback =3D callback;
+	request->destroy =3D destroy;
+	request->user_data =3D user_data;
+
+	if (genl->next_request_id < 1)
+		genl->next_request_id =3D 1;
+
+	request->id =3D genl->next_request_id++;
+
+	l_queue_push_tail(genl->request_queue, request);
+
+	wakeup_writer(genl);
+
+	return request->id;
 }
 =

 LIB_EXPORT struct l_genl_family *l_genl_family_new(struct l_genl *genl,
 							const char *name)
 {
+	struct genl_parent *parent;
 	struct l_genl_family *family;
 	struct l_genl_msg *msg;
 =

@@ -1105,26 +1243,38 @@ LIB_EXPORT struct l_genl_family *l_genl_family_new(=
struct l_genl *genl,
 			unlikely(strlen(name) >=3D GENL_NAMSIZ))
 		return NULL;
 =

-	family =3D family_alloc(genl, name);
-	if (!family)
+	parent =3D l_queue_find(genl->family_list, match_family_name, name);
+	if (parent) {
+		family =3D family_alloc_child(parent);
+		goto done;
+	}
+
+	parent =3D family_alloc_parent(genl, name);
+
+	if (!parent)
 		return NULL;
 =

+	family =3D family_alloc_child(parent);
+
+	/* family has not yet been looked up */
 	msg =3D l_genl_msg_new_sized(CTRL_CMD_GETFAMILY, NLA_HDRLEN + GENL_NAMSIZ=
);
 =

 	l_genl_msg_append_attr(msg, CTRL_ATTR_FAMILY_NAME,
-						GENL_NAMSIZ, family->name);
+						GENL_NAMSIZ, parent->name);
 =

-	family->nlctrl_cmd =3D l_genl_family_send(genl->nlctrl, msg,
-					get_family_callback, family, NULL);
+	parent->nlctrl_cmd =3D send_common(genl->nlctrl, NLM_F_ACK, msg, 0,
+						get_family_callback, family,
+						NULL);
 =

-	if (!family->nlctrl_cmd) {
-		family_free(family);
+	if (!parent->nlctrl_cmd) {
+		parent_free(parent);
 		return NULL;
 	}
 =

-	l_queue_push_tail(genl->family_list, family);
+	l_queue_push_tail(genl->family_list, parent);
 =

-	return family;
+done:
+	return l_genl_family_ref(family);
 }
 =

 LIB_EXPORT struct l_genl_family *l_genl_family_ref(
@@ -1141,34 +1291,35 @@ LIB_EXPORT struct l_genl_family *l_genl_family_ref(
 LIB_EXPORT void l_genl_family_unref(struct l_genl_family *family)
 {
 	struct l_genl *genl;
+	struct genl_parent *parent;
 =

 	if (unlikely(!family))
 		return;
 =

+	parent =3D family->parent;
+
 	if (__sync_sub_and_fetch(&family->ref_count, 1))
 		return;
 =

-	if (family->nlctrl_cmd > 0)
-		l_genl_family_cancel(family, family->nlctrl_cmd);
-
-	genl =3D family->genl;
-	if (genl)
-		l_queue_remove(genl->family_list, family);
-
-	l_queue_destroy(family->op_list, op_free);
-
-	l_queue_foreach(family->mcast_list, mcast_free, genl);
+	if (!l_queue_remove(parent->children, family))
+		return;
 =

-	l_queue_destroy(family->mcast_list, NULL);
-	family->mcast_list =3D NULL;
+	/* parent still has children, just free this child instance */
+	if (!l_queue_isempty(parent->children)) {
+		child_free(family);
+		return;
+	}
 =

-	if (family->id > 0 && family->watch_vanished)
-		family->watch_vanished(family->watch_data);
+	if (parent->nlctrl_cmd > 0)
+		l_genl_family_cancel(family, parent->nlctrl_cmd);
 =

-	if (family->watch_destroy)
-		family->watch_destroy(family->watch_data);
+	genl =3D parent->genl;
+	if (genl)
+		l_queue_remove(genl->family_list, parent);
 =

-	l_free(family);
+	/* child is no longer in 'children' list, free manually */
+	child_free(family);
+	parent_free(parent);
 }
 =

 LIB_EXPORT bool l_genl_family_set_watches(struct l_genl_family *family,
@@ -1188,6 +1339,10 @@ LIB_EXPORT bool l_genl_family_set_watches(struct l_g=
enl_family *family,
 	family->watch_destroy =3D destroy;
 	family->watch_data =3D user_data;
 =

+	/* if the parent has already been looked up, we notify immediately */
+	if (family->parent->live)
+		family->watch_appeared(family->watch_data);
+
 	return true;
 }
 =

@@ -1196,7 +1351,7 @@ LIB_EXPORT uint32_t l_genl_family_get_version(struct =
l_genl_family *family)
 	if (unlikely(!family))
 		return 0;
 =

-	return family->version;
+	return family->parent->version;
 }
 =

 LIB_EXPORT struct l_genl *l_genl_family_get_genl(struct l_genl_family *fam=
ily)
@@ -1204,7 +1359,7 @@ LIB_EXPORT struct l_genl *l_genl_family_get_genl(stru=
ct l_genl_family *family)
 	if (unlikely(!family))
 		return 0;
 =

-	return family->genl;
+	return family->parent->genl;
 }
 =

 static bool match_op_id(const void *a, const void *b)
@@ -1223,7 +1378,8 @@ LIB_EXPORT bool l_genl_family_can_send(struct l_genl_=
family *family,
 	if (unlikely(!family))
 		return false;
 =

-	op =3D l_queue_find(family->op_list, match_op_id, L_UINT_TO_PTR(cmd));
+	op =3D l_queue_find(family->parent->op_list, match_op_id,
+				L_UINT_TO_PTR(cmd));
 	if (!op)
 		return false;
 =

@@ -1241,7 +1397,8 @@ LIB_EXPORT bool l_genl_family_can_dump(struct l_genl_=
family *family,
 	if (!family)
 		return false;
 =

-	op =3D l_queue_find(family->op_list, match_op_id, L_UINT_TO_PTR(cmd));
+	op =3D l_queue_find(family->parent->op_list, match_op_id,
+				L_UINT_TO_PTR(cmd));
 	if (!op)
 		return false;
 =

@@ -1251,51 +1408,14 @@ LIB_EXPORT bool l_genl_family_can_dump(struct l_gen=
l_family *family,
 	return false;
 }
 =

-static unsigned int send_common(struct l_genl_family *family, uint16_t fla=
gs,
-				struct l_genl_msg *msg, l_genl_msg_func_t callback,
-				void *user_data, l_genl_destroy_func_t destroy)
-{
-	struct l_genl *genl;
-	struct genl_request *request;
-
-	if (!family || !msg)
-		return 0;
-
-	genl =3D family->genl;
-	if (!genl)
-		return 0;
-
-	request =3D l_new(struct genl_request, 1);
-
-	request->type =3D family->id;
-	request->flags =3D NLM_F_REQUEST | flags;
-
-	request->msg =3D msg;
-
-	request->callback =3D callback;
-	request->destroy =3D destroy;
-	request->user_data =3D user_data;
-
-	if (genl->next_request_id < 1)
-		genl->next_request_id =3D 1;
-
-	request->id =3D genl->next_request_id++;
-
-	l_queue_push_tail(genl->request_queue, request);
-
-	wakeup_writer(genl);
-
-	return request->id;
-}
-
 LIB_EXPORT unsigned int l_genl_family_send(struct l_genl_family *family,
 						struct l_genl_msg *msg,
 						l_genl_msg_func_t callback,
 						void *user_data,
 						l_genl_destroy_func_t destroy)
 {
-	return send_common(family, NLM_F_ACK, msg, callback,
-						user_data, destroy);
+	return send_common(family->parent, NLM_F_ACK, msg, family->gid,
+						callback, user_data, destroy);
 }
 =

 LIB_EXPORT unsigned int l_genl_family_dump(struct l_genl_family *family,
@@ -1304,8 +1424,9 @@ LIB_EXPORT unsigned int l_genl_family_dump(struct l_g=
enl_family *family,
 						void *user_data,
 						l_genl_destroy_func_t destroy)
 {
-	return send_common(family, NLM_F_ACK | NLM_F_DUMP, msg, callback,
-							user_data, destroy);
+	return send_common(family->parent, NLM_F_ACK | NLM_F_DUMP, msg,
+						family->gid, callback,
+						user_data, destroy);
 }
 =

 static bool match_request_id(const void *a, const void *b)
@@ -1325,7 +1446,7 @@ LIB_EXPORT bool l_genl_family_cancel(struct l_genl_fa=
mily *family,
 	if (unlikely(!family) || unlikely(!id))
 		return false;
 =

-	genl =3D family->genl;
+	genl =3D family->parent->genl;
 	if (!genl)
 		return false;
 =

@@ -1367,7 +1488,7 @@ LIB_EXPORT bool l_genl_family_has_group(struct l_genl=
_family *family,
 	if (unlikely(!family))
 		return false;
 =

-	mcast =3D l_queue_find(family->mcast_list, match_mcast_name,
+	mcast =3D l_queue_find(family->parent->mcast_list, match_mcast_name,
 							(char *) group);
 	if (!mcast)
 		return false;
@@ -1388,18 +1509,18 @@ LIB_EXPORT unsigned int l_genl_family_register(stru=
ct l_genl_family *family,
 	if (unlikely(!family) || unlikely(!group))
 		return 0;
 =

-	genl =3D family->genl;
+	genl =3D family->parent->genl;
 	if (!genl)
 		return 0;
 =

-	mcast =3D l_queue_find(family->mcast_list, match_mcast_name,
+	mcast =3D l_queue_find(family->parent->mcast_list, match_mcast_name,
 							(char *) group);
 	if (!mcast)
 		return 0;
 =

 	notify =3D l_new(struct genl_mcast_notify, 1);
 =

-	notify->type =3D family->id;
+	notify->type =3D family->parent->id;
 	notify->group =3D mcast->id;
 =

 	notify->callback =3D callback;
@@ -1435,7 +1556,7 @@ LIB_EXPORT bool l_genl_family_unregister(struct l_gen=
l_family *family,
 	if (!family || !id)
 		return false;
 =

-	genl =3D family->genl;
+	genl =3D family->parent->genl;
 	if (!genl)
 		return false;
 =

-- =

2.17.1


--===============3769283143652587369==--

