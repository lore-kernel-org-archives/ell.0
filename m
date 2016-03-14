Content-Type: multipart/mixed; boundary="===============4073676289431701209=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 18/20] dbus: Classic dbus driver->name_acquire and public API.
Date: Mon, 14 Mar 2016 04:41:34 +0100
Message-ID: <1457926896-9843-18-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1457926896-9843-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4073676289431701209==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/dbus.c | 89 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++=
++++
 ell/dbus.h |  5 ++++
 2 files changed, 94 insertions(+)

diff --git a/ell/dbus.c b/ell/dbus.c
index c5cc1fc..6c267ae 100644
--- a/ell/dbus.c
+++ b/ell/dbus.c
@@ -822,6 +822,84 @@ static bool classic_get_name_owner(struct l_dbus *bus,=
 const char *name)
 	return true;
 }
 =

+struct name_request {
+	l_dbus_name_acquire_func_t callback;
+	void *user_data;
+	struct l_dbus *dbus;
+};
+
+enum dbus_name_flag {
+	DBUS_NAME_FLAG_ALLOW_REPLACEMENT	=3D 0x1,
+	DBUS_NAME_FLAG_REPLACE_EXISTING		=3D 0x2,
+	DBUS_NAME_FLAG_DO_NOT_QUEUE		=3D 0x4,
+};
+
+enum dbus_name_reply {
+	DBUS_REQUEST_NAME_REPLY_PRIMARY_OWNER	=3D 1,
+	DBUS_REQUEST_NAME_REPLY_IN_QUEUE	=3D 2,
+	DBUS_REQUEST_NAME_REPLY_EXISTS		=3D 3,
+	DBUS_REQUEST_NAME_REPLY_ALREADY_OWNER	=3D 4,
+};
+
+static void request_name_reply_cb(struct l_dbus_message *reply, void *user=
_data)
+{
+	struct name_request *req =3D user_data;
+	bool success =3D false, queued =3D false;
+	uint32_t retval;
+
+	if (!req->callback)
+		return;
+
+	/* No name owner yet */
+	if (l_dbus_message_is_error(reply))
+		goto call_back;
+
+	/* Shouldn't happen */
+	if (!l_dbus_message_get_arguments(reply, "u", &retval))
+		goto call_back;
+
+	success =3D (retval =3D=3D DBUS_REQUEST_NAME_REPLY_PRIMARY_OWNER) ||
+		(retval =3D=3D DBUS_REQUEST_NAME_REPLY_ALREADY_OWNER) ||
+		(retval =3D=3D DBUS_REQUEST_NAME_REPLY_IN_QUEUE);
+	queued =3D (retval =3D=3D DBUS_REQUEST_NAME_REPLY_IN_QUEUE);
+
+call_back:
+	req->callback(req->dbus, success, queued, req->user_data);
+}
+
+static uint32_t classic_name_acquire(struct l_dbus *dbus, const char *name,
+					bool allow_replacement,
+					bool replace_existing, bool queue,
+					l_dbus_name_acquire_func_t callback,
+					void *user_data)
+{
+	struct name_request *req;
+	struct l_dbus_message *message;
+	uint32_t flags =3D 0;
+
+	req =3D l_new(struct name_request, 1);
+	req->dbus =3D dbus;
+	req->user_data =3D user_data;
+	req->callback =3D callback;
+
+	message =3D l_dbus_message_new_method_call(dbus, DBUS_SERVICE_DBUS,
+							DBUS_PATH_DBUS,
+							L_DBUS_INTERFACE_DBUS,
+							"RequestName");
+
+	if (allow_replacement)
+		flags |=3D DBUS_NAME_FLAG_ALLOW_REPLACEMENT;
+	if (replace_existing)
+		flags |=3D DBUS_NAME_FLAG_REPLACE_EXISTING;
+	if (!queue)
+		flags |=3D DBUS_NAME_FLAG_DO_NOT_QUEUE;
+
+	l_dbus_message_set_arguments(message, "su", name, flags);
+
+	return send_message(dbus, false, message, request_name_reply_cb,
+				req, free);
+}
+
 static const struct l_dbus_ops classic_ops =3D {
 	.version =3D 1,
 	.send_message =3D classic_send_message,
@@ -833,6 +911,7 @@ static const struct l_dbus_ops classic_ops =3D {
 		.remove_match =3D classic_remove_match,
 		.get_name_owner =3D classic_get_name_owner,
 	},
+	.name_acquire =3D classic_name_acquire,
 };
 =

 static void name_owner_changed_cb(struct l_dbus_message *message,
@@ -2048,3 +2127,13 @@ LIB_EXPORT bool l_dbus_remove_signal_watch(struct l_=
dbus *dbus, unsigned int id)
 {
 	return _dbus_filter_remove_rule(dbus->filter, id);
 }
+
+LIB_EXPORT uint32_t l_dbus_name_acquire(struct l_dbus *dbus, const char *n=
ame,
+				bool allow_replacement, bool replace_existing,
+				bool queue, l_dbus_name_acquire_func_t callback,
+				void *user_data)
+{
+	return dbus->driver->name_acquire(dbus, name, allow_replacement,
+						replace_existing, queue,
+						callback, user_data);
+}
diff --git a/ell/dbus.h b/ell/dbus.h
index 0b82899..f4b2527 100644
--- a/ell/dbus.h
+++ b/ell/dbus.h
@@ -256,6 +256,11 @@ unsigned int l_dbus_add_signal_watch(struct l_dbus *db=
us,
 					const char *member, ...);
 bool l_dbus_remove_signal_watch(struct l_dbus *dbus, unsigned int id);
 =

+uint32_t l_dbus_name_acquire(struct l_dbus *dbus, const char *name,
+				bool allow_replacement, bool replace_existing,
+				bool queue, l_dbus_name_acquire_func_t callback,
+				void *user_data);
+
 #ifdef __cplusplus
 }
 #endif
-- =

2.5.0


--===============4073676289431701209==--

