Content-Type: multipart/mixed; boundary="===============5892030452295675413=="
MIME-Version: 1.0
From: James Prestwood <james.prestwood@linux.intel.com>
Subject: [PATCH v2 2/3] genl: rework l_genl_family to avoid extra lookups
Date: Wed, 31 Oct 2018 13:31:44 -0700
Message-ID: <20181031203145.5637-2-james.prestwood@linux.intel.com>
In-Reply-To: <20181031203145.5637-1-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5892030452295675413==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Rather than doing a full lookup in the kernel when creating a new family
object, we can use a previous lookup that matches our family name. Several
API changes were introduced in order for this to work cleanly.

l_genl_family_new was removed, and instead l_genl_get_family should be used.
This is an async function that returns the l_genl_family object in the
callback. This better matches how the lookup actually works. Because of this
l_genl_set_watches was also removed (since the "appeared" callback is now
provided directly to l_genl_get_family, "vanished" callback is explained
further below). It is up to the caller to manage the l_genl_family object
memory (genl does not keep a list of created family objects).

l_genl_family_set_watches was removed in place of l_genl_add_destroy_watch.
This is a watch on the genl object rather than on each family object. This
watchlist will get notified if the genl object disappears.

l_genl_family_[ref|unref] were both removed as they no longer made sense.
l_genl_family objects should now be cleaned up with l_genl_family_destroy.

The main intent with this patch is for each module that requires genl to
"get" its own family object and send messages on that object rather than
a shared global object. This, in most cases, will remove the need for
command ID message tracking since messages on a family object can be
canceled without affecting other family objects under the same name using
l_genl_family_cancel_all.

Internally, the l_genl_family object is now a thin struct containing only
a pointer back to the parent and a group ID. The parent object
(genl_family_internal) now holds all the lookup information for a given
name. If a new family is requested and a parent object already exists
then we do not need to lookup the family in the kernel then the new
l_genl_family object is returned in the callback. All l_genl_family
objects are tagged with a unique group ID (gid), and any messages sent
on that family are also tagged with the same gid. This allows cancelling
all messages by gid, which leaves other l_genl_family messages untouched,
even if they are under the same family name.
---
 ell/genl.c | 505 +++++++++++++++++++++++++++++++++++------------------
 ell/genl.h |  26 +--
 2 files changed, 353 insertions(+), 178 deletions(-)

diff --git a/ell/genl.c b/ell/genl.c
index 3a0281a..b38d044 100644
--- a/ell/genl.c
+++ b/ell/genl.c
@@ -2,7 +2,7 @@
  *
  *  Embedded Linux library
  *
- *  Copyright (C) 2011-2014  Intel Corporation. All rights reserved.
+ *  Copyright (C) 2011-2018  Intel Corporation. All rights reserved.
  *
  *  This library is free software; you can redistribute it and/or
  *  modify it under the terms of the GNU Lesser General Public
@@ -36,6 +36,8 @@
 #include "genl.h"
 #include "genl-private.h"
 #include "private.h"
+#include "watchlist.h"
+#include "idle.h"
 =

 #define MAX_NESTING_LEVEL 4
 =

@@ -63,12 +65,14 @@ struct l_genl {
 	struct l_queue *notify_list;
 	unsigned int next_request_id;
 	unsigned int next_notify_id;
+	unsigned int next_gid;
 	struct l_queue *family_list;
-	struct l_genl_family *nlctrl;
+	struct genl_family_internal *nlctrl;
 	struct genl_unicast_notify *unicast_notify;
 	l_genl_debug_func_t debug_callback;
 	l_genl_destroy_func_t debug_destroy;
 	void *debug_data;
+	struct l_watchlist destroy_watches;
 };
 =

 struct l_genl_msg {
@@ -85,6 +89,7 @@ struct l_genl_msg {
 =

 struct genl_request {
 	unsigned int id;
+	unsigned int gid;
 	uint16_t type;
 	uint16_t flags;
 	uint32_t seq;
@@ -114,8 +119,8 @@ struct genl_mcast {
 	unsigned int users;
 };
 =

-struct l_genl_family {
-	int ref_count;
+struct genl_family_internal {
+	unsigned int ref_count;
 	struct l_genl *genl;
 	char name[GENL_NAMSIZ];
 	uint16_t id;
@@ -124,11 +129,21 @@ struct l_genl_family {
 	uint32_t maxattr;
 	struct l_queue *op_list;
 	struct l_queue *mcast_list;
-	l_genl_watch_func_t watch_appeared;
-	l_genl_watch_func_t watch_vanished;
-	l_genl_destroy_func_t watch_destroy;
-	void *watch_data;
 	unsigned int nlctrl_cmd;
+	struct l_queue *pending_lookups;
+	bool live;
+};
+
+struct l_genl_family {
+	struct genl_family_internal *internal;
+	unsigned int gid;
+};
+
+struct cb_data {
+	l_genl_get_family_func_t cb;
+	l_genl_destroy_func_t destroy;
+	struct l_genl_family *family;
+	void *user_data;
 };
 =

 static void destroy_request(void *data)
@@ -153,20 +168,42 @@ static void destroy_notify(void *data)
 	l_free(notify);
 }
 =

-static struct l_genl_family *family_alloc(struct l_genl *genl,
-							const char *name)
+static struct genl_family_internal *family_internal_ref(
+					struct genl_family_internal *internal)
 {
-	struct l_genl_family *family;
+	if (unlikely(!internal))
+		return NULL;
 =

-	family =3D l_new(struct l_genl_family, 1);
+	__sync_fetch_and_add(&internal->ref_count, 1);
 =

-	family->genl =3D genl;
-	strncpy(family->name, name, GENL_NAMSIZ);
+	return internal;
+}
+
+static struct l_genl_family *family_alloc(
+					struct genl_family_internal *internal)
+{
+	struct l_genl_family *family =3D l_new(struct l_genl_family, 1);
 =

-	family->op_list =3D l_queue_new();
-	family->mcast_list =3D l_queue_new();
+	family->internal =3D family_internal_ref(internal);
+	family->gid =3D ++internal->genl->next_gid;
 =

-	return l_genl_family_ref(family);
+	return family;
+}
+
+static struct genl_family_internal *family_alloc_internal(struct l_genl *g=
enl,
+							const char *name)
+{
+	struct genl_family_internal *internal =3D l_new(
+						struct genl_family_internal, 1);
+
+	internal->genl =3D l_genl_ref(genl);
+	strncpy(internal->name, name, GENL_NAMSIZ);
+
+	internal->op_list =3D l_queue_new();
+	internal->mcast_list =3D l_queue_new();
+	internal->pending_lookups =3D l_queue_new();
+
+	return internal;
 }
 =

 static void op_free(void *data)
@@ -191,16 +228,56 @@ static void mcast_free(void *data, void *user_data)
 	l_free(mcast);
 }
 =

-static void family_free(void *data)
+static void destroy_lookups(void *user_data)
 {
-	struct l_genl_family *family =3D data;
+	struct cb_data *cbd =3D user_data;
 =

-	family->genl =3D NULL;
+	if (cbd->destroy)
+		cbd->destroy(cbd->user_data);
 =

-	l_genl_family_unref(family);
+	l_free(cbd->family);
+	l_free(cbd);
 }
 =

-static void family_add_op(struct l_genl_family *family, uint32_t id,
+static void internal_free(void *data)
+{
+	struct genl_family_internal *internal =3D data;
+	struct l_genl *genl =3D internal->genl;
+
+	if (internal->pending_lookups) {
+		l_queue_destroy(internal->pending_lookups, destroy_lookups);
+		internal->pending_lookups =3D NULL;
+	}
+
+	l_queue_destroy(internal->op_list, op_free);
+
+	l_queue_foreach(internal->mcast_list, mcast_free, internal->genl);
+	l_queue_destroy(internal->mcast_list, NULL);
+	internal->mcast_list =3D NULL;
+
+	l_genl_unref(genl);
+
+	l_free(internal);
+}
+
+static void family_internal_unref(struct genl_family_internal *internal)
+{
+	struct l_genl *genl;
+
+	if (unlikely(!internal))
+		return;
+
+	if (__sync_sub_and_fetch(&internal->ref_count, 1))
+		return;
+
+	genl =3D internal->genl;
+	if (genl)
+		l_queue_remove(genl->family_list, internal);
+
+	internal_free(internal);
+}
+
+static void family_add_op(struct genl_family_internal *internal, uint32_t =
id,
 							uint32_t flags)
 {
 	struct genl_op *op;
@@ -210,7 +287,7 @@ static void family_add_op(struct l_genl_family *family,=
 uint32_t id,
 	op->id =3D id;
 	op->flags =3D flags;
 =

-	l_queue_push_tail(family->op_list, op);
+	l_queue_push_tail(internal->op_list, op);
 }
 =

 static bool match_mcast_name(const void *a, const void *b)
@@ -221,16 +298,16 @@ static bool match_mcast_name(const void *a, const voi=
d *b)
 	return !strcmp(mcast->name, name);
 }
 =

-static void family_add_mcast(struct l_genl_family *family, const char *nam=
e,
+static void family_add_mcast(struct genl_family_internal *internal, const =
char *name,
 								uint32_t id)
 {
-	struct l_genl *genl =3D family->genl;
+	struct l_genl *genl =3D internal->genl;
 	struct genl_mcast *mcast;
 =

 	if (!genl)
 		return;
 =

-	mcast =3D l_queue_find(family->mcast_list, match_mcast_name,
+	mcast =3D l_queue_find(internal->mcast_list, match_mcast_name,
 							(char *) name);
 	if (mcast)
 		return;
@@ -241,7 +318,26 @@ static void family_add_mcast(struct l_genl_family *fam=
ily, const char *name,
 	mcast->id =3D id;
 	mcast->users =3D 0;
 =

-	l_queue_push_tail(family->mcast_list, mcast);
+	l_queue_push_tail(internal->mcast_list, mcast);
+}
+
+/* special initializer for the nlctrl object */
+static struct genl_family_internal *family_alloc_ctrl(struct l_genl *genl)
+{
+	struct genl_family_internal *nlctrl;
+
+	nlctrl =3D l_new(struct genl_family_internal, 1);
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
@@ -473,6 +569,10 @@ static void process_multicast(struct l_genl *genl, uin=
t32_t group,
 =

 static void read_watch_destroy(void *user_data)
 {
+	struct l_genl *genl =3D user_data;
+
+	L_WATCHLIST_NOTIFY_NO_ARGS(&genl->destroy_watches,
+					l_genl_destroy_func_t);
 }
 =

 static bool received_data(struct l_io *io, void *user_data)
@@ -549,13 +649,7 @@ LIB_EXPORT struct l_genl *l_genl_new(int fd)
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

@@ -563,6 +657,7 @@ LIB_EXPORT struct l_genl *l_genl_new(int fd)
 	genl->pending_list =3D l_queue_new();
 	genl->notify_list =3D l_queue_new();
 	genl->family_list =3D l_queue_new();
+	l_watchlist_init(&genl->destroy_watches, NULL);
 =

 	l_io_set_read_handler(genl->io, received_data, genl,
 						read_watch_destroy);
@@ -611,6 +706,20 @@ LIB_EXPORT struct l_genl *l_genl_new_default(void)
 	return genl;
 }
 =

+LIB_EXPORT unsigned int l_genl_add_destroy_watch(struct l_genl *genl,
+					l_genl_destroy_func_t destroy,
+					void *user_data)
+{
+	return l_watchlist_add(&genl->destroy_watches, (void *)destroy,
+				user_data, NULL);
+}
+
+LIB_EXPORT void l_genl_remove_destroy_watch(struct l_genl *genl,
+						unsigned int id)
+{
+	l_watchlist_remove(&genl->destroy_watches, id);
+}
+
 LIB_EXPORT struct l_genl *l_genl_ref(struct l_genl *genl)
 {
 	if (unlikely(!genl))
@@ -632,6 +741,7 @@ LIB_EXPORT void l_genl_unref(struct l_genl *genl)
 	l_queue_destroy(genl->notify_list, destroy_notify);
 	l_queue_destroy(genl->pending_list, destroy_request);
 	l_queue_destroy(genl->request_queue, destroy_request);
+	genl->request_queue =3D NULL;
 =

 	l_io_set_write_handler(genl->io, NULL, NULL, NULL);
 	l_io_set_read_handler(genl->io, NULL, NULL, NULL);
@@ -639,9 +749,10 @@ LIB_EXPORT void l_genl_unref(struct l_genl *genl)
 	l_io_destroy(genl->io);
 	genl->io =3D NULL;
 =

-	l_genl_family_unref(genl->nlctrl);
+	internal_free(genl->nlctrl);
 =

-	l_queue_destroy(genl->family_list, family_free);
+	l_queue_destroy(genl->family_list, internal_free);
+	l_watchlist_destroy(&genl->destroy_watches);
 =

 	if (genl->close_on_unref)
 		close(genl->fd);
@@ -984,7 +1095,7 @@ LIB_EXPORT bool l_genl_attr_recurse(struct l_genl_attr=
 *attr,
 	return true;
 }
 =

-static void family_ops(struct l_genl_family *family, struct l_genl_attr *a=
ttr)
+static void family_ops(struct genl_family_internal *internal, struct l_gen=
l_attr *attr)
 {
 	uint16_t type, len;
 	const void *data;
@@ -1007,11 +1118,11 @@ static void family_ops(struct l_genl_family *family=
, struct l_genl_attr *attr)
 		}
 =

 		if (id > 0)
-			family_add_op(family, id, flags);
+			family_add_op(internal, id, flags);
 	}
 }
 =

-static void family_mcast_groups(struct l_genl_family *family,
+static void family_mcast_groups(struct genl_family_internal *internal,
 						struct l_genl_attr *attr)
 {
 	uint16_t type, len;
@@ -1036,27 +1147,37 @@ static void family_mcast_groups(struct l_genl_famil=
y *family,
 		}
 =

 		if (name && id > 0)
-			family_add_mcast(family, name, id);
+			family_add_mcast(internal, name, id);
 	}
 }
 =

+static void family_notify_appeared(void *data)
+{
+	struct cb_data *cbd =3D data;
+
+	if (cbd->cb)
+		cbd->cb(cbd->family, cbd->user_data);
+
+	l_free(cbd);
+}
+
 static void get_family_callback(struct l_genl_msg *msg, void *user_data)
 {
-	struct l_genl_family *family =3D user_data;
+	struct genl_family_internal *internal =3D user_data;
 	struct l_genl_attr attr, nested;
 	uint16_t type, len;
 	const void *data;
 	int error;
 =

-	family->nlctrl_cmd =3D 0;
+	internal->nlctrl_cmd =3D 0;
 =

-	if (family->id > 0)
+	if (internal->id > 0)
 		return;
 =

 	error =3D l_genl_msg_get_error(msg);
 	if (error < 0) {
-		if (family->watch_vanished)
-			family->watch_vanished(family->watch_data);
+		l_queue_remove(internal->genl->family_list, internal);
+		internal_free(internal);
 		return;
 	}
 =

@@ -1066,127 +1187,164 @@ static void get_family_callback(struct l_genl_msg=
 *msg, void *user_data)
 	while (l_genl_attr_next(&attr, &type, &len, &data)) {
 		switch (type) {
 		case CTRL_ATTR_FAMILY_ID:
-			family->id =3D *((uint16_t *) data);
+			internal->id =3D *((uint16_t *) data);
 			break;
 		case CTRL_ATTR_FAMILY_NAME:
-			strncpy(family->name, data, GENL_NAMSIZ);
+			strncpy(internal->name, data, GENL_NAMSIZ);
 			break;
 		case CTRL_ATTR_VERSION:
-			family->version =3D *((uint32_t *) data);
+			internal->version =3D *((uint32_t *) data);
 			break;
 		case CTRL_ATTR_HDRSIZE:
-			family->hdrsize =3D *((uint32_t *) data);
+			internal->hdrsize =3D *((uint32_t *) data);
 			break;
 		case CTRL_ATTR_MAXATTR:
-			family->maxattr =3D *((uint32_t *) data);
+			internal->maxattr =3D *((uint32_t *) data);
 			break;
 		case CTRL_ATTR_OPS:
 			if (l_genl_attr_recurse(&attr, &nested))
-				family_ops(family, &nested);
+				family_ops(internal, &nested);
 			break;
 		case CTRL_ATTR_MCAST_GROUPS:
 			if (l_genl_attr_recurse(&attr, &nested))
-				family_mcast_groups(family, &nested);
+				family_mcast_groups(internal, &nested);
 			break;
 		}
 	}
 =

-	if (family->watch_appeared)
-		family->watch_appeared(family->watch_data);
+	internal->live =3D true;
+
+	l_queue_destroy(internal->pending_lookups, family_notify_appeared);
+	internal->pending_lookups =3D NULL;
 }
 =

-LIB_EXPORT struct l_genl_family *l_genl_family_new(struct l_genl *genl,
-							const char *name)
+static bool match_family_name(const void *a, const void *b)
 {
-	struct l_genl_family *family;
-	struct l_genl_msg *msg;
+	const struct genl_family_internal *internal =3D a;
 =

-	if (unlikely(!genl) || unlikely(!name) ||
-			unlikely(strlen(name) >=3D GENL_NAMSIZ))
-		return NULL;
+	return !strncmp(internal->name, (const char *)b, GENL_NAMSIZ);
+}
 =

-	family =3D family_alloc(genl, name);
-	if (!family)
-		return NULL;
+static unsigned int send_common(struct genl_family_internal *internal, uin=
t16_t flags,
+				struct l_genl_msg *msg, unsigned int gid,
+				l_genl_msg_func_t callback, void *user_data,
+				l_genl_destroy_func_t destroy)
+{
+	struct l_genl *genl;
+	struct genl_request *request;
 =

-	msg =3D l_genl_msg_new_sized(CTRL_CMD_GETFAMILY, NLA_HDRLEN + GENL_NAMSIZ=
);
+	if (!internal || !msg)
+		return 0;
 =

-	l_genl_msg_append_attr(msg, CTRL_ATTR_FAMILY_NAME,
-						GENL_NAMSIZ, family->name);
+	genl =3D internal->genl;
+	if (!genl)
+		return 0;
 =

-	family->nlctrl_cmd =3D l_genl_family_send(genl->nlctrl, msg,
-					get_family_callback, family, NULL);
+	request =3D l_new(struct genl_request, 1);
 =

-	if (!family->nlctrl_cmd) {
-		family_free(family);
-		return NULL;
-	}
+	request->type =3D internal->id;
+	request->flags =3D NLM_F_REQUEST | flags;
 =

-	l_queue_push_tail(genl->family_list, family);
+	request->msg =3D msg;
+	request->gid =3D gid;
 =

-	return family;
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

-LIB_EXPORT struct l_genl_family *l_genl_family_ref(
-						struct l_genl_family *family)
+static struct cb_data *cb_data_new(struct l_genl_family *family,
+				l_genl_get_family_func_t cb, void *user_data,
+				l_genl_destroy_func_t destroy)
 {
-	if (unlikely(!family))
-		return NULL;
+	struct cb_data *cbd =3D l_new(struct cb_data, 1);
 =

-	__sync_fetch_and_add(&family->ref_count, 1);
+	cbd->family =3D family;
+	cbd->cb =3D cb;
+	cbd->destroy =3D destroy;
+	cbd->user_data =3D user_data;
 =

-	return family;
+	return cbd;
+}
+static void idle_get_family(void *user_data)
+{
+	struct cb_data *cbd =3D user_data;
+
+	if (cbd->cb)
+		cbd->cb(cbd->family, cbd->user_data);
 }
 =

-LIB_EXPORT void l_genl_family_unref(struct l_genl_family *family)
+LIB_EXPORT bool l_genl_get_family(struct l_genl *genl, const char *name,
+					l_genl_get_family_func_t callback,
+					void *user_data,
+					l_genl_destroy_func_t destroy)
 {
-	struct l_genl *genl;
+	struct genl_family_internal *internal;
+	struct l_genl_family *family;
+	struct l_genl_msg *msg;
+	struct cb_data *cbd;
 =

-	if (unlikely(!family))
-		return;
+	if (unlikely(!genl) || unlikely(!name) ||
+			unlikely(strlen(name) >=3D GENL_NAMSIZ))
+		return false;
 =

-	if (__sync_sub_and_fetch(&family->ref_count, 1))
-		return;
+	internal =3D l_queue_find(genl->family_list, match_family_name, name);
+	if (internal) {
+		family =3D family_alloc(internal);
 =

-	if (family->nlctrl_cmd > 0)
-		l_genl_family_cancel(family, family->nlctrl_cmd);
+		cbd =3D cb_data_new(family, callback, user_data, destroy);
 =

-	genl =3D family->genl;
-	if (genl)
-		l_queue_remove(genl->family_list, family);
+		/*
+		 * If family is looked up, just call the callback in the next
+		 * event loop. Otherwise we must have a currently pending lookup
+		 * so add the callback data to the pending queue
+		 */
+		if (internal->live)
+			return l_idle_oneshot(idle_get_family, cbd, l_free);
+		else
+			return l_queue_push_tail(internal->pending_lookups,
+							cbd);
+	}
+
+	internal =3D family_alloc_internal(genl, name);
+	if (!internal)
+		return false;
 =

-	l_queue_destroy(family->op_list, op_free);
+	family =3D family_alloc(internal);
 =

-	l_queue_foreach(family->mcast_list, mcast_free, genl);
+	cbd =3D cb_data_new(family, callback, user_data, destroy);
 =

-	l_queue_destroy(family->mcast_list, NULL);
-	family->mcast_list =3D NULL;
+	l_queue_push_tail(internal->pending_lookups, cbd);
 =

-	if (family->id > 0 && family->watch_vanished)
-		family->watch_vanished(family->watch_data);
+	/* family has not yet been looked up */
+	msg =3D l_genl_msg_new_sized(CTRL_CMD_GETFAMILY,
+						NLA_HDRLEN + GENL_NAMSIZ);
 =

-	if (family->watch_destroy)
-		family->watch_destroy(family->watch_data);
+	l_genl_msg_append_attr(msg, CTRL_ATTR_FAMILY_NAME,
+						GENL_NAMSIZ, internal->name);
 =

-	l_free(family);
-}
+	internal->nlctrl_cmd =3D send_common(genl->nlctrl, NLM_F_ACK, msg, 0,
+						get_family_callback, internal,
+						NULL);
 =

-LIB_EXPORT bool l_genl_family_set_watches(struct l_genl_family *family,
-						l_genl_watch_func_t appeared,
-						l_genl_watch_func_t vanished,
-						void *user_data,
-						l_genl_destroy_func_t destroy)
-{
-	if (unlikely(!family))
+	if (!internal->nlctrl_cmd) {
+		l_genl_family_destroy(family);
+		internal_free(internal);
 		return false;
+	}
 =

-	if (family->watch_destroy)
-		family->watch_destroy(family->watch_data);
-
-	family->watch_appeared =3D appeared;
-	family->watch_vanished =3D vanished;
-	family->watch_destroy =3D destroy;
-	family->watch_data =3D user_data;
+	l_queue_push_tail(genl->family_list, internal);
 =

 	return true;
 }
@@ -1196,7 +1354,7 @@ LIB_EXPORT uint32_t l_genl_family_get_version(struct =
l_genl_family *family)
 	if (unlikely(!family))
 		return 0;
 =

-	return family->version;
+	return family->internal->version;
 }
 =

 LIB_EXPORT struct l_genl *l_genl_family_get_genl(struct l_genl_family *fam=
ily)
@@ -1204,7 +1362,7 @@ LIB_EXPORT struct l_genl *l_genl_family_get_genl(stru=
ct l_genl_family *family)
 	if (unlikely(!family))
 		return 0;
 =

-	return family->genl;
+	return family->internal->genl;
 }
 =

 static bool match_op_id(const void *a, const void *b)
@@ -1223,7 +1381,8 @@ LIB_EXPORT bool l_genl_family_can_send(struct l_genl_=
family *family,
 	if (unlikely(!family))
 		return false;
 =

-	op =3D l_queue_find(family->op_list, match_op_id, L_UINT_TO_PTR(cmd));
+	op =3D l_queue_find(family->internal->op_list, match_op_id,
+				L_UINT_TO_PTR(cmd));
 	if (!op)
 		return false;
 =

@@ -1241,7 +1400,8 @@ LIB_EXPORT bool l_genl_family_can_dump(struct l_genl_=
family *family,
 	if (!family)
 		return false;
 =

-	op =3D l_queue_find(family->op_list, match_op_id, L_UINT_TO_PTR(cmd));
+	op =3D l_queue_find(family->internal->op_list, match_op_id,
+				L_UINT_TO_PTR(cmd));
 	if (!op)
 		return false;
 =

@@ -1251,51 +1411,14 @@ LIB_EXPORT bool l_genl_family_can_dump(struct l_gen=
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
+	return send_common(family->internal, NLM_F_ACK, msg, family->gid,
+						callback, user_data, destroy);
 }
 =

 LIB_EXPORT unsigned int l_genl_family_dump(struct l_genl_family *family,
@@ -1304,8 +1427,9 @@ LIB_EXPORT unsigned int l_genl_family_dump(struct l_g=
enl_family *family,
 						void *user_data,
 						l_genl_destroy_func_t destroy)
 {
-	return send_common(family, NLM_F_ACK | NLM_F_DUMP, msg, callback,
-							user_data, destroy);
+	return send_common(family->internal, NLM_F_ACK | NLM_F_DUMP, msg,
+						family->gid, callback,
+						user_data, destroy);
 }
 =

 static bool match_request_id(const void *a, const void *b)
@@ -1325,7 +1449,7 @@ LIB_EXPORT bool l_genl_family_cancel(struct l_genl_fa=
mily *family,
 	if (unlikely(!family) || unlikely(!id))
 		return false;
 =

-	genl =3D family->genl;
+	genl =3D family->internal->genl;
 	if (!genl)
 		return false;
 =

@@ -1345,6 +1469,53 @@ done:
 	return true;
 }
 =

+static bool remove_by_gid(void *data, void *user_data)
+{
+	struct genl_request *request =3D data;
+	unsigned int gid =3D L_PTR_TO_UINT(user_data);
+
+	if (request->gid !=3D gid)
+		return false;
+
+	destroy_request(request);
+
+	return true;
+}
+
+LIB_EXPORT bool l_genl_family_cancel_all(struct l_genl_family *family)
+{
+	struct l_genl *genl;
+	unsigned int removed;
+
+	if (unlikely(!family))
+		return false;
+
+	genl =3D family->internal->genl;
+	if (!genl)
+		return false;
+
+	removed =3D l_queue_foreach_remove(genl->request_queue, remove_by_gid,
+						L_UINT_TO_PTR(family->gid));
+	if (removed)
+		return true;
+
+	removed =3D l_queue_foreach_remove(genl->pending_list, remove_by_gid,
+						L_UINT_TO_PTR(family->gid));
+	if (!removed)
+		return false;
+
+	return true;
+}
+
+LIB_EXPORT void l_genl_family_destroy(struct l_genl_family *family)
+{
+	l_genl_family_cancel_all(family);
+
+	family_internal_unref(family->internal);
+
+	l_free(family);
+}
+
 static void add_membership(struct l_genl *genl, struct genl_mcast *mcast)
 {
 	int group =3D mcast->id;
@@ -1367,7 +1538,7 @@ LIB_EXPORT bool l_genl_family_has_group(struct l_genl=
_family *family,
 	if (unlikely(!family))
 		return false;
 =

-	mcast =3D l_queue_find(family->mcast_list, match_mcast_name,
+	mcast =3D l_queue_find(family->internal->mcast_list, match_mcast_name,
 							(char *) group);
 	if (!mcast)
 		return false;
@@ -1388,18 +1559,18 @@ LIB_EXPORT unsigned int l_genl_family_register(stru=
ct l_genl_family *family,
 	if (unlikely(!family) || unlikely(!group))
 		return 0;
 =

-	genl =3D family->genl;
+	genl =3D family->internal->genl;
 	if (!genl)
 		return 0;
 =

-	mcast =3D l_queue_find(family->mcast_list, match_mcast_name,
+	mcast =3D l_queue_find(family->internal->mcast_list, match_mcast_name,
 							(char *) group);
 	if (!mcast)
 		return 0;
 =

 	notify =3D l_new(struct genl_mcast_notify, 1);
 =

-	notify->type =3D family->id;
+	notify->type =3D family->internal->id;
 	notify->group =3D mcast->id;
 =

 	notify->callback =3D callback;
@@ -1435,7 +1606,7 @@ LIB_EXPORT bool l_genl_family_unregister(struct l_gen=
l_family *family,
 	if (!family || !id)
 		return false;
 =

-	genl =3D family->genl;
+	genl =3D family->internal->genl;
 	if (!genl)
 		return false;
 =

diff --git a/ell/genl.h b/ell/genl.h
index ff5687c..1a92e3a 100644
--- a/ell/genl.h
+++ b/ell/genl.h
@@ -2,7 +2,7 @@
  *
  *  Embedded Linux library
  *
- *  Copyright (C) 2011-2014  Intel Corporation. All rights reserved.
+ *  Copyright (C) 2011-2018  Intel Corporation. All rights reserved.
  *
  *  This library is free software; you can redistribute it and/or
  *  modify it under the terms of the GNU Lesser General Public
@@ -33,12 +33,16 @@ extern "C" {
 =

 typedef void (*l_genl_destroy_func_t)(void *user_data);
 =

-
 struct l_genl;
 =

 struct l_genl *l_genl_new(int fd);
 struct l_genl *l_genl_new_default(void);
 =

+unsigned int l_genl_add_destroy_watch(struct l_genl *genl,
+					l_genl_destroy_func_t destroy,
+					void *user_data);
+void l_genl_remove_destroy_watch(struct l_genl *genl, unsigned int id);
+
 struct l_genl *l_genl_ref(struct l_genl *genl);
 void l_genl_unref(struct l_genl *genl);
 =

@@ -49,7 +53,6 @@ bool l_genl_set_debug(struct l_genl *genl, l_genl_debug_f=
unc_t callback,
 =

 bool l_genl_set_close_on_unref(struct l_genl *genl, bool do_close);
 =

-
 struct l_genl_msg;
 =

 struct l_genl_attr {
@@ -85,17 +88,17 @@ bool l_genl_attr_recurse(struct l_genl_attr *attr, stru=
ct l_genl_attr *nested);
 =

 struct l_genl_family;
 =

-struct l_genl_family *l_genl_family_new(struct l_genl *genl, const char *n=
ame);
+typedef void (*l_genl_get_family_func_t)(struct l_genl_family *family,
+						void *user_data);
 =

-struct l_genl_family *l_genl_family_ref(struct l_genl_family *family);
-void l_genl_family_unref(struct l_genl_family *family);
+bool l_genl_get_family(struct l_genl *genl, const char *name,
+					l_genl_get_family_func_t callback,
+					void *user_data,
+					l_genl_destroy_func_t destroy);
 =

-typedef void (*l_genl_watch_func_t)(void *user_data);
+void l_genl_family_destroy(struct l_genl_family *family);
 =

-bool l_genl_family_set_watches(struct l_genl_family *family,
-				l_genl_watch_func_t appeared,
-				l_genl_watch_func_t vanished,
-				void *user_data, l_genl_destroy_func_t destroy);
+typedef void (*l_genl_watch_func_t)(void *user_data);
 =

 typedef void (*l_genl_msg_func_t)(struct l_genl_msg *msg, void *user_data);
 =

@@ -116,6 +119,7 @@ unsigned int l_genl_family_dump(struct l_genl_family *f=
amily,
 				struct l_genl_msg *msg, l_genl_msg_func_t callback,
 				void *user_data, l_genl_destroy_func_t destroy);
 bool l_genl_family_cancel(struct l_genl_family *family, unsigned int id);
+bool l_genl_family_cancel_all(struct l_genl_family *family);
 =

 bool l_genl_family_has_group(struct l_genl_family *family, const char *gro=
up);
 unsigned int l_genl_family_register(struct l_genl_family *family,
-- =

2.17.1


--===============5892030452295675413==--

