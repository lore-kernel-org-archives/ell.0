Content-Type: multipart/mixed; boundary="===============3949017688933309975=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 03/15] dbus: Add _dbus_message_get_nth_string_argument
Date: Mon, 21 Mar 2016 23:10:12 +0100
Message-ID: <1458598224-29325-3-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1458598224-29325-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3949017688933309975==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

We happen to need to access n-th argument specifically only if it is
of a string type in at least three places, so add this shortcut.
---
 ell/dbus-message.c | 45 +++++++++++++++++++++++++++++++++++++++++++++
 ell/dbus-private.h |  2 ++
 2 files changed, 47 insertions(+)

diff --git a/ell/dbus-message.c b/ell/dbus-message.c
index 5b83be7..d35b5a6 100644
--- a/ell/dbus-message.c
+++ b/ell/dbus-message.c
@@ -392,6 +392,51 @@ LIB_EXPORT void l_dbus_message_unref(struct l_dbus_mes=
sage *message)
 	l_free(message);
 }
 =

+const char *_dbus_message_get_nth_string_argument(
+					struct l_dbus_message *message, int n)
+{
+	struct l_dbus_message_iter iter;
+	const char *signature, *value;
+	void *body;
+	size_t size;
+	char type;
+	bool (*skip_entry)(struct l_dbus_message_iter *);
+	bool (*get_basic)(struct l_dbus_message_iter *, char, void *);
+
+	signature =3D l_dbus_message_get_signature(message);
+	body =3D _dbus_message_get_body(message, &size);
+
+	if (!signature)
+		return NULL;
+
+	if (_dbus_message_is_gvariant(message)) {
+		if (!_gvariant_iter_init(&iter, message, signature, NULL,
+						body, size))
+			return NULL;
+
+		skip_entry =3D _gvariant_iter_skip_entry;
+		get_basic =3D _gvariant_iter_next_entry_basic;
+	} else {
+		_dbus1_iter_init(&iter, message, signature, NULL, body, size);
+
+		skip_entry =3D _dbus1_iter_skip_entry;
+		get_basic =3D _dbus1_iter_next_entry_basic;
+	}
+
+	while (n--)
+		if (!skip_entry(&iter))
+			return NULL;
+
+	type =3D l_dbus_message_iter_get_type(&iter);
+	if (!strchr("sog", type))
+		return NULL;
+
+	if (!get_basic(&iter, type, &value))
+		return NULL;
+
+	return value;
+}
+
 static bool message_iter_next_entry_valist(struct l_dbus_message_iter *ori=
g,
 						va_list args)
 {
diff --git a/ell/dbus-private.h b/ell/dbus-private.h
index cfed4f7..607fdf4 100644
--- a/ell/dbus-private.h
+++ b/ell/dbus-private.h
@@ -115,6 +115,8 @@ enum dbus_message_type _dbus_message_get_type(struct l_=
dbus_message *message);
 const char * _dbus_message_get_type_as_string(struct l_dbus_message *messa=
ge);
 uint8_t _dbus_message_get_version(struct l_dbus_message *message);
 uint8_t _dbus_message_get_endian(struct l_dbus_message *message);
+const char *_dbus_message_get_nth_string_argument(
+					struct l_dbus_message *message, int n);
 =

 struct l_dbus_message *_dbus_message_new_method_call(uint8_t version,
 							const char *destination,
-- =

2.5.0


--===============3949017688933309975==--

