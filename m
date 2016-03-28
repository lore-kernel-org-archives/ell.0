Content-Type: multipart/mixed; boundary="===============5789542359924606304=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 3/5] dbus: Classic driver->name_acquire implementation
Date: Tue, 29 Mar 2016 00:09:21 +0200
Message-ID: <1459202963-12390-3-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1459202963-12390-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5789542359924606304==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/dbus.c | 79 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++=
++++
 1 file changed, 79 insertions(+)

diff --git a/ell/dbus.c b/ell/dbus.c
index b9987a2..dfeacbc 100644
--- a/ell/dbus.c
+++ b/ell/dbus.c
@@ -784,6 +784,84 @@ static bool classic_get_name_owner(struct l_dbus *bus,=
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
@@ -794,6 +872,7 @@ static const struct l_dbus_ops classic_ops =3D {
 		.remove_match =3D classic_remove_match,
 		.get_name_owner =3D classic_get_name_owner,
 	},
+	.name_acquire =3D classic_name_acquire,
 };
 =

 static void name_owner_changed_cb(struct l_dbus_message *message,
-- =

2.5.0


--===============5789542359924606304==--

