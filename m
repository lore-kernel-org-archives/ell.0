Content-Type: multipart/mixed; boundary="===============8235616770266164215=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [RFC PATCH 4/8] dbus: Message builder function to copy from an iter.
Date: Sat, 23 Jan 2016 03:59:28 +0100
Message-ID: <1453517972-22833-4-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1453517972-22833-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8235616770266164215==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/dbus-message.c | 112 +++++++++++++++++++++++++++++++++++++++++++++++++=
++++
 ell/dbus.h         |   4 ++
 2 files changed, 116 insertions(+)

diff --git a/ell/dbus-message.c b/ell/dbus-message.c
index 159df82..dc4850d 100644
--- a/ell/dbus-message.c
+++ b/ell/dbus-message.c
@@ -1584,6 +1584,118 @@ LIB_EXPORT bool l_dbus_message_builder_leave_varian=
t(
 	return l_dbus_message_builder_leave_container(builder, 'v');
 }
 =

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


--===============8235616770266164215==--

