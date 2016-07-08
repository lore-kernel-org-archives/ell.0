Content-Type: multipart/mixed; boundary="===============7092840454211713381=="
MIME-Version: 1.0
From: Tim Kourt <tim.a.kourt@linux.intel.com>
Subject: [PATCH v4] genl: Add unicast handler
Date: Fri, 08 Jul 2016 14:26:03 -0700
Message-ID: <1468013163-61895-1-git-send-email-tim.a.kourt@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7092840454211713381==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/genl.c | 99 +++++++++++++++++++++++++++++++++++++++++++++++-----------=
----
 ell/genl.h |  5 ++++
 2 files changed, 80 insertions(+), 24 deletions(-)

diff --git a/ell/genl.c b/ell/genl.c
index 15f4782..85e447a 100644
--- a/ell/genl.c
+++ b/ell/genl.c
@@ -39,6 +39,12 @@
 =

 #define MAX_NESTING_LEVEL 4
 =

+struct genl_unicast_notify {
+	l_genl_msg_func_t handler;
+	l_genl_destroy_func_t destroy;
+	void *user_data;
+};
+
 struct l_genl {
 	int ref_count;
 	int fd;
@@ -54,6 +60,7 @@ struct l_genl {
 	unsigned int next_notify_id;
 	struct l_queue *family_list;
 	struct l_genl_family *nlctrl;
+	struct genl_unicast_notify *unicast_notify;
 	l_genl_debug_func_t debug_callback;
 	l_genl_destroy_func_t debug_destroy;
 	void *debug_data;
@@ -82,7 +89,7 @@ struct genl_request {
 	void *user_data;
 };
 =

-struct genl_notify {
+struct genl_mcast_notify {
 	unsigned int id;
 	uint16_t type;
 	uint32_t group;
@@ -133,7 +140,7 @@ static void destroy_request(void *data)
 =

 static void destroy_notify(void *data)
 {
-	struct genl_notify *notify =3D data;
+	struct genl_mcast_notify *notify =3D data;
 =

 	if (notify->destroy)
 		notify->destroy(notify->user_data);
@@ -356,10 +363,11 @@ static bool match_request_seq(const void *a, const vo=
id *b)
 	return request->seq =3D=3D seq;
 }
 =

-static void process_request(struct l_genl *genl, const struct nlmsghdr *nl=
msg)
+static void process_unicast(struct l_genl *genl, const struct nlmsghdr *nl=
msg)
 {
 	struct l_genl_msg *msg;
 	struct genl_request *request;
+	struct genl_unicast_notify *notify;
 =

 	if (nlmsg->nlmsg_type =3D=3D NLMSG_NOOP ||
 					nlmsg->nlmsg_type =3D=3D NLMSG_OVERRUN)
@@ -367,28 +375,34 @@ static void process_request(struct l_genl *genl, cons=
t struct nlmsghdr *nlmsg)
 =

 	request =3D l_queue_remove_if(genl->pending_list, match_request_seq,
 					L_UINT_TO_PTR(nlmsg->nlmsg_seq));
-	if (!request)
-		return;
 =

 	msg =3D _genl_msg_create(nlmsg);
 	if (!msg) {
-		destroy_request(request);
-		wakeup_writer(genl);
+		if (request) {
+			destroy_request(request);
+			wakeup_writer(genl);
+		}
 		return;
 	}
 =

-	if (request->callback && nlmsg->nlmsg_type !=3D NLMSG_DONE)
-		request->callback(msg, request->user_data);
-
-	if (nlmsg->nlmsg_flags & NLM_F_MULTI) {
-		if (nlmsg->nlmsg_type =3D=3D NLMSG_DONE) {
+	if (request) {
+		if (request->callback && nlmsg->nlmsg_type !=3D NLMSG_DONE)
+			request->callback(msg, request->user_data);
+
+		if (nlmsg->nlmsg_flags & NLM_F_MULTI) {
+			if (nlmsg->nlmsg_type =3D=3D NLMSG_DONE) {
+				destroy_request(request);
+				wakeup_writer(genl);
+			} else
+				l_queue_push_head(genl->pending_list, request);
+		} else {
 			destroy_request(request);
 			wakeup_writer(genl);
-		} else
-			l_queue_push_head(genl->pending_list, request);
+		}
 	} else {
-		destroy_request(request);
-		wakeup_writer(genl);
+		notify =3D genl->unicast_notify;
+		if (notify && notify->handler)
+			notify->handler(msg, notify->user_data);
 	}
 =

 	l_genl_msg_unref(msg);
@@ -402,7 +416,7 @@ struct notify_type_group {
 =

 static void notify_handler(void *data, void *user_data)
 {
-	struct genl_notify *notify =3D data;
+	struct genl_mcast_notify *notify =3D data;
 	struct notify_type_group *match =3D user_data;
 =

 	if (notify->type !=3D match->type)
@@ -415,7 +429,7 @@ static void notify_handler(void *data, void *user_data)
 		notify->callback(match->msg, notify->user_data);
 }
 =

-static void process_notify(struct l_genl *genl, uint32_t group,
+static void process_multicast(struct l_genl *genl, uint32_t group,
 						const struct nlmsghdr *nlmsg)
 {
 	struct notify_type_group match;
@@ -487,9 +501,9 @@ static bool received_data(struct l_io *io, void *user_d=
ata)
 	for (nlmsg =3D iov.iov_base; NLMSG_OK(nlmsg, bytes_read);
 				nlmsg =3D NLMSG_NEXT(nlmsg, bytes_read)) {
 		if (group > 0)
-			process_notify(genl, group, nlmsg);
+			process_multicast(genl, group, nlmsg);
 		else
-			process_request(genl, nlmsg);
+			process_unicast(genl, nlmsg);
 	}
 =

 	return true;
@@ -607,6 +621,8 @@ LIB_EXPORT void l_genl_unref(struct l_genl *genl)
 	if (genl->debug_destroy)
 		genl->debug_destroy(genl->debug_data);
 =

+	l_genl_set_unicast_handler(genl, NULL, NULL, NULL);
+
 	l_free(genl);
 }
 =

@@ -638,6 +654,41 @@ LIB_EXPORT bool l_genl_set_close_on_unref(struct l_gen=
l *genl, bool do_close)
 	return true;
 }
 =

+LIB_EXPORT bool l_genl_set_unicast_handler(struct l_genl *genl,
+						l_genl_msg_func_t handler,
+						void *user_data,
+						l_genl_destroy_func_t destroy)
+{
+	struct genl_unicast_notify *notify;
+
+	if (!genl)
+		return false;
+
+	notify =3D genl->unicast_notify;
+	if (notify) {
+		if (notify->destroy)
+			notify->destroy(notify->user_data);
+
+		if (!handler) {
+			l_free(notify);
+			genl->unicast_notify =3D NULL;
+			return true;
+		}
+	} else {
+		if (!handler)
+			return false;
+
+		notify =3D l_new(struct genl_unicast_notify, 1);
+		genl->unicast_notify =3D notify;
+	}
+
+	notify->handler =3D handler;
+	notify->destroy =3D destroy;
+	notify->user_data =3D user_data;
+
+	return true;
+}
+
 const void *_genl_msg_as_bytes(struct l_genl_msg *msg, uint16_t type,
 					uint16_t flags, uint32_t seq,
 					uint32_t pid,
@@ -1265,7 +1316,7 @@ LIB_EXPORT unsigned int l_genl_family_register(struct=
 l_genl_family *family,
 						l_genl_destroy_func_t destroy)
 {
 	struct l_genl *genl;
-	struct genl_notify *notify;
+	struct genl_mcast_notify *notify;
 	struct genl_mcast *mcast;
 =

 	if (unlikely(!family) || unlikely(!group))
@@ -1280,7 +1331,7 @@ LIB_EXPORT unsigned int l_genl_family_register(struct=
 l_genl_family *family,
 	if (!mcast)
 		return 0;
 =

-	notify =3D l_new(struct genl_notify, 1);
+	notify =3D l_new(struct genl_mcast_notify, 1);
 =

 	notify->type =3D family->id;
 	notify->group =3D mcast->id;
@@ -1303,7 +1354,7 @@ LIB_EXPORT unsigned int l_genl_family_register(struct=
 l_genl_family *family,
 =

 static bool match_notify_id(const void *a, const void *b)
 {
-	const struct genl_notify *notify =3D a;
+	const struct genl_mcast_notify *notify =3D a;
 	unsigned int id =3D L_PTR_TO_UINT(b);
 =

 	return notify->id =3D=3D id;
@@ -1313,7 +1364,7 @@ LIB_EXPORT bool l_genl_family_unregister(struct l_gen=
l_family *family,
 							unsigned int id)
 {
 	struct l_genl *genl;
-	struct genl_notify *notify;
+	struct genl_mcast_notify *notify;
 =

 	if (!family || !id)
 		return false;
diff --git a/ell/genl.h b/ell/genl.h
index 8f5fd52..5b37d55 100644
--- a/ell/genl.h
+++ b/ell/genl.h
@@ -96,6 +96,11 @@ bool l_genl_family_set_watches(struct l_genl_family *fam=
ily,
 =

 typedef void (*l_genl_msg_func_t)(struct l_genl_msg *msg, void *user_data);
 =

+bool l_genl_set_unicast_handler(struct l_genl *genl,
+						l_genl_msg_func_t handler,
+						void *user_data,
+						l_genl_destroy_func_t destroy);
+
 uint32_t l_genl_family_get_version(struct l_genl_family *family);
 =

 bool l_genl_family_can_send(struct l_genl_family *family, uint8_t cmd);
-- =

2.5.5


--===============7092840454211713381==--

