Content-Type: multipart/mixed; boundary="===============5759053388753279243=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 4/8] dbus: Message builder function to copy from an iter.
Date: Fri, 05 Feb 2016 03:58:30 +0100
Message-ID: <1454641114-3421-4-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1454641114-3421-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5759053388753279243==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/dbus-message.c | 125 +++++++++++++++++++++++++++++++++++++++++++++++++=
++++
 ell/dbus.h         |   4 ++
 2 files changed, 129 insertions(+)

diff --git a/ell/dbus-message.c b/ell/dbus-message.c
index 159df82..e618cf7 100644
--- a/ell/dbus-message.c
+++ b/ell/dbus-message.c
@@ -1584,6 +1584,131 @@ LIB_EXPORT bool l_dbus_message_builder_leave_varian=
t(
 	return l_dbus_message_builder_leave_container(builder, 'v');
 }
 =

+/**
+ * l_dbus_message_builder_append_from_iter:
+ * @builder: message builder to receive a new value
+ * @from: message iterator to have its position moved by one value
+ *
+ * Copy one value from a message iterator onto a message builder.  The
+ * value's signature is also copied.
+ *
+ * Returns: whether the value was correctly copied.  On failure both
+ *          the @from iterator and the @builder may have their positions
+ *          moved to somewhere within the new value if it's of a
+ *          container type.
+ **/
+LIB_EXPORT bool l_dbus_message_builder_append_from_iter(
+					struct l_dbus_message_builder *builder,
+					struct l_dbus_message_iter *from)
+{
+	static const char *simple_types =3D "sogybnqiuxtd";
+	char type =3D from->sig_start[from->sig_pos];
+	char container_type;
+	char signature[256];
+	struct l_dbus_message_iter iter;
+	void *basic_ptr;
+	uint64_t basic;
+	uint32_t uint32_val;
+	int fd;
+	bool (*get_basic)(struct l_dbus_message_iter *, char, void *);
+	bool (*enter_func)(struct l_dbus_message_iter *,
+				struct l_dbus_message_iter *);
+	bool (*enter_struct)(struct l_dbus_message_iter *,
+				struct l_dbus_message_iter *);
+	bool (*enter_array)(struct l_dbus_message_iter *,
+				struct l_dbus_message_iter *);
+	bool (*enter_variant)(struct l_dbus_message_iter *,
+				struct l_dbus_message_iter *);
+
+	if (_dbus_message_is_gvariant(from->message)) {
+		get_basic =3D _gvariant_iter_next_entry_basic;
+		enter_struct =3D _gvariant_iter_enter_struct;
+		enter_array =3D _gvariant_iter_enter_array;
+		enter_variant =3D _gvariant_iter_enter_variant;
+	} else {
+		get_basic =3D _dbus1_iter_next_entry_basic;
+		enter_struct =3D _dbus1_iter_enter_struct;
+		enter_array =3D _dbus1_iter_enter_array;
+		enter_variant =3D _dbus1_iter_enter_variant;
+	}
+
+	if (strchr(simple_types, type)) {
+		if (strchr("sog", type)) {
+			if (!get_basic(from, type, &basic_ptr))
+				return false;
+		} else {
+			basic_ptr =3D &basic;
+
+			if (!get_basic(from, type, basic_ptr))
+				return false;
+		}
+
+		if (!l_dbus_message_builder_append_basic(builder, type,
+								basic_ptr))
+			return false;
+
+		return true;
+	}
+
+	switch (type) {
+	case 'h':
+		if (!get_basic(from, type, &uint32_val))
+			return false;
+
+		if (uint32_val >=3D from->message->num_fds)
+			return false;
+
+		fd =3D fcntl(from->message->fds[uint32_val], F_DUPFD_CLOEXEC, 3);
+
+		uint32_val =3D builder->message->num_fds;
+		builder->message->fds[builder->message->num_fds++] =3D fd;
+
+		if (!l_dbus_message_builder_append_basic(builder, type,
+								&uint32_val))
+			return false;
+
+		return true;
+	case '(':
+		enter_func =3D enter_struct;
+		container_type =3D DBUS_CONTAINER_TYPE_STRUCT;
+		break;
+	case '{':
+		enter_func =3D enter_struct;
+		container_type =3D DBUS_CONTAINER_TYPE_DICT_ENTRY;
+		break;
+	case 'a':
+		enter_func =3D enter_array;
+		container_type =3D DBUS_CONTAINER_TYPE_ARRAY;
+		break;
+	case 'v':
+		enter_func =3D enter_variant;
+		container_type =3D DBUS_CONTAINER_TYPE_VARIANT;
+		break;
+	default:
+		return false;
+	}
+
+	if (!enter_func(from, &iter))
+		return false;
+
+	memcpy(signature, iter.sig_start, iter.sig_len);
+	signature[iter.sig_len] =3D '\0';
+
+	if (!l_dbus_message_builder_enter_container(builder,
+						container_type, signature))
+		return false;
+
+	while (iter.sig_pos < iter.sig_len)
+		if (!l_dbus_message_builder_append_from_iter(builder, &iter))
+			return false;
+
+	if (!l_dbus_message_builder_leave_container(builder,
+						container_type))
+		return false;
+
+	return true;
+}
+
 LIB_EXPORT struct l_dbus_message *l_dbus_message_builder_finalize(
 					struct l_dbus_message_builder *builder)
 {
diff --git a/ell/dbus.h b/ell/dbus.h
index 011d59a..29253b6 100644
--- a/ell/dbus.h
+++ b/ell/dbus.h
@@ -188,6 +188,10 @@ bool l_dbus_message_builder_enter_variant(
 bool l_dbus_message_builder_leave_variant(
 					struct l_dbus_message_builder *builder);
 =

+bool l_dbus_message_builder_append_from_iter(
+					struct l_dbus_message_builder *builder,
+					struct l_dbus_message_iter *from);
+
 struct l_dbus_message *l_dbus_message_builder_finalize(
 					struct l_dbus_message_builder *builder);
 =

-- =

2.5.0


--===============5759053388753279243==--

