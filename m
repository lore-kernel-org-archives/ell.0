Content-Type: multipart/mixed; boundary="===============5336348042509854333=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH v3 1/9] dbus: Update GVariant message header format
Date: Fri, 15 Apr 2016 02:33:54 +0200
Message-ID: <1460680442-15201-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5336348042509854333==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

In the current GVariant message format since about Jan 2015 there's no
body size field (it is reserved and must be sent as 0) or header size
information or signature.  The message needs to be parsed as a single
GVariant blob if we want to split it into a header and a body.
---
 ell/dbus-kernel.c  |   3 -
 ell/dbus-message.c | 167 ++++++++++++++++++++++++++++++++++++++-----------=
----
 ell/dbus-private.h |  16 ++++-
 ell/dbus-util.c    |   4 +-
 ell/dbus.c         |   4 +-
 5 files changed, 137 insertions(+), 57 deletions(-)

diff --git a/ell/dbus-kernel.c b/ell/dbus-kernel.c
index 09721c2..4a3aed0 100644
--- a/ell/dbus-kernel.c
+++ b/ell/dbus-kernel.c
@@ -551,9 +551,6 @@ static int _dbus_kernel_make_message(struct kdbus_msg *=
kmsg,
 	if (hdr->version !=3D 2)
 		return -EPROTO;
 =

-	if (hdr->body_length !=3D body_size)
-		return -EBADMSG;
-
 	r =3D collect_body_parts(kmsg, header_size, &header,
 						body_size, &body);
 	if (r < 0)
diff --git a/ell/dbus-message.c b/ell/dbus-message.c
index 3bc52ea..9fdc0ff 100644
--- a/ell/dbus-message.c
+++ b/ell/dbus-message.c
@@ -58,7 +58,8 @@ struct l_dbus_message {
 	int refcount;
 	void *header;
 	size_t header_size;
-	const char *signature;
+	size_t header_end;
+	char *signature;
 	void *body;
 	size_t body_size;
 	char *path;
@@ -74,6 +75,7 @@ struct l_dbus_message {
 	bool sealed : 1;
 	bool kdbus_sender : 1;
 	bool kdbus_destination : 1;
+	bool signature_free : 1;
 };
 =

 struct l_dbus_message_builder {
@@ -109,14 +111,20 @@ void _dbus_message_set_serial(struct l_dbus_message *=
msg, uint32_t serial)
 {
 	struct dbus_header *hdr =3D msg->header;
 =

-	hdr->serial =3D serial;
+	if (_dbus_message_is_gvariant(msg))
+		hdr->kdbus.cookie =3D serial;
+	else
+		hdr->dbus1.serial =3D serial;
 }
 =

 uint32_t _dbus_message_get_serial(struct l_dbus_message *msg)
 {
 	struct dbus_header *hdr =3D msg->header;
 =

-	return hdr->serial;
+	if (_dbus_message_is_gvariant(msg))
+		return hdr->kdbus.cookie;
+	else
+		return hdr->dbus1.serial;
 }
 =

 LIB_EXPORT bool l_dbus_message_set_no_reply(struct l_dbus_message *msg, bo=
ol on)
@@ -196,10 +204,12 @@ static struct l_dbus_message *message_new_common(uint=
8_t type, uint8_t flags,
 =

 	/*
 	 * We allocate the header with the initial 12 bytes (up to the field
-	 * length) so that we can store the basic information here
+	 * length) so that we can store the basic information here.  For
+	 * GVariant we need 16 bytes.
 	 */
-	message->header =3D l_realloc(NULL, 12);
-	message->header_size =3D 12;
+	message->header_size =3D version =3D=3D 1 ? 12 : 16;
+	message->header_end =3D message->header_size;
+	message->header =3D l_realloc(NULL, message->header_size);
 =

 	hdr =3D message->header;
 	hdr->endian =3D DBUS_NATIVE_ENDIAN;
@@ -290,7 +300,7 @@ LIB_EXPORT struct l_dbus_message *l_dbus_message_new_me=
thod_return(
 					DBUS_MESSAGE_FLAG_NO_REPLY_EXPECTED,
 					hdr->version);
 =

-	message->reply_serial =3D hdr->serial;
+	message->reply_serial =3D _dbus_message_get_serial(method_call);
 =

 	sender =3D l_dbus_message_get_sender(method_call);
 	if (sender)
@@ -317,7 +327,7 @@ LIB_EXPORT struct l_dbus_message *l_dbus_message_new_er=
ror_valist(
 					DBUS_MESSAGE_FLAG_NO_REPLY_EXPECTED,
 					hdr->version);
 =

-	reply->reply_serial =3D hdr->serial;
+	reply->reply_serial =3D _dbus_message_get_serial(method_call);
 =

 	sender =3D l_dbus_message_get_sender(method_call);
 	if (sender)
@@ -387,6 +397,9 @@ LIB_EXPORT void l_dbus_message_unref(struct l_dbus_mess=
age *message)
 	if (message->kdbus_destination)
 		l_free(message->destination);
 =

+	if (message->signature_free)
+		l_free(message->signature);
+
 	l_free(message->header);
 	l_free(message->body);
 	l_free(message);
@@ -567,20 +580,11 @@ static bool get_header_field_from_iter_valist(struct =
l_dbus_message *message,
 		return false;
 =

 	if (_dbus_message_is_gvariant(message)) {
-		uint32_t header_length;
 		uint64_t field_type;
 =

-		if (!_gvariant_iter_init(&header, message, "yyyyuuu", NULL,
-					message->header, message->header_size))
-			return false;
-
-		if (!message_iter_next_entry(&header, &endian, &message_type,
-						&flags, &version, &body_length,
-						&serial, &header_length))
-			return false;
-
 		if (!_gvariant_iter_init(&header, message, "a(tv)", NULL,
-					message->header + 16, header_length))
+						message->header + 16,
+						message->header_end - 16))
 			return false;
 =

 		if (!_gvariant_iter_enter_array(&header, &array))
@@ -643,8 +647,14 @@ static bool valid_header(const struct dbus_header *hdr)
 	if (hdr->version !=3D 1 && hdr->version !=3D 2)
 		return false;
 =

-	if (hdr->serial =3D=3D 0)
-		return false;
+	if (hdr->version =3D=3D 1) {
+		if (hdr->dbus1.serial =3D=3D 0)
+			return false;
+	} else {
+		/* We don't support 64-bit GVariant cookies */
+		if (hdr->kdbus.cookie =3D=3D 0 || (hdr->kdbus.cookie >> 32))
+			return false;
+	}
 =

 	return true;
 }
@@ -653,6 +663,7 @@ struct l_dbus_message *dbus_message_from_blob(const voi=
d *data, size_t size)
 {
 	const struct dbus_header *hdr =3D data;
 	struct l_dbus_message *message;
+	size_t body_pos;
 =

 	if (unlikely(size < DBUS_HEADER_SIZE))
 		return NULL;
@@ -661,28 +672,66 @@ struct l_dbus_message *dbus_message_from_blob(const v=
oid *data, size_t size)
 =

 	message->refcount =3D 1;
 =

-	message->header_size =3D align_len(DBUS_HEADER_SIZE +
-						hdr->field_length, 8);
-	message->body_size =3D hdr->body_length;
+	if (hdr->version =3D=3D 1) {
+		message->header_size =3D align_len(DBUS_HEADER_SIZE +
+						hdr->dbus1.field_length, 8);
+		message->body_size =3D hdr->dbus1.body_length;
 =

-	if (message->header_size + message->body_size < size) {
-		l_free(message);
-		return NULL;
+		if (message->header_size + message->body_size < size)
+			goto free;
+
+		body_pos =3D message->header_size;
+	} else {
+		struct l_dbus_message_iter iter;
+		struct l_dbus_message_iter header, variant, body;
+
+		/*
+		 * GVariant message structure as per
+		 * https://wiki.gnome.org/Projects/GLib/GDBus/Version2
+		 * is "(yyyyuta{tv}v)".  As noted this is equivalent to
+		 * some other types, this one lets us get iterators for
+		 * the header and the body in the fewest steps.
+		 */
+		if (!_gvariant_iter_init(&iter, message, "(yyyyuta{tv})v",
+						NULL, data, size))
+			goto free;
+
+		if (!_gvariant_iter_enter_struct(&iter, &header))
+			goto free;
+
+		if (!_gvariant_iter_enter_variant(&iter, &variant))
+			goto free;
+
+		if (!_gvariant_iter_enter_struct(&variant, &body))
+			goto free;
+
+		message->header_size =3D align_len(header.len - header.pos, 8);
+		message->body_size =3D body.len - body.pos;
+		message->signature =3D l_strndup(body.sig_start + body.sig_pos,
+						body.sig_len - body.sig_pos);
+		message->signature_free =3D true;
+		message->header_end =3D header.len;
+		body_pos =3D body.data + body.pos - data;
 	}
 =

 	message->header =3D l_malloc(message->header_size);
 	message->body =3D l_malloc(message->body_size);
 =

 	memcpy(message->header, data, message->header_size);
-	memcpy(message->body, data + message->header_size, message->body_size);
+	memcpy(message->body, data + body_pos, message->body_size);
 =

 	message->sealed =3D true;
 =

 	/* If the field is absent message->signature will remain NULL */
-	get_header_field(message, DBUS_MESSAGE_FIELD_SIGNATURE, 'g',
-						&message->signature);
+	if (hdr->version =3D=3D 1)
+		get_header_field(message, DBUS_MESSAGE_FIELD_SIGNATURE,
+					'g', &message->signature);
 =

 	return message;
+
+free:
+	l_free(message);
+	return NULL;
 }
 =

 struct l_dbus_message *dbus_message_build(void *header, size_t header_size,
@@ -698,6 +747,13 @@ struct l_dbus_message *dbus_message_build(void *header=
, size_t header_size,
 	if (unlikely(!valid_header(hdr)))
 		return NULL;
 =

+	/*
+	 * With GVariant we need to know the signature, use
+	 * dbus_message_from_blob instead.
+	 */
+	if (unlikely(hdr->version !=3D 1))
+		return NULL;
+
 	message =3D l_new(struct l_dbus_message, 1);
 =

 	message->refcount =3D 1;
@@ -825,23 +881,19 @@ static void build_header(struct l_dbus_message *messa=
ge, const char *signature)
 	struct dbus_builder *builder;
 	struct builder_driver *driver;
 	char *generated_signature;
-	struct dbus_header *hdr;
 	size_t header_size;
+	bool gvariant;
 =

-	if (_dbus_message_is_gvariant(message))
+	gvariant =3D _dbus_message_is_gvariant(message);
+
+	if (gvariant)
 		driver =3D &gvariant_driver;
 	else
 		driver =3D &dbus1_driver;
 =

 	builder =3D driver->new(message->header, message->header_size);
 =

-	if (_dbus_message_is_gvariant(message)) {
-		uint32_t field_length =3D 0;
-		driver->append_basic(builder, 'u', &field_length);
-	}
-
-	driver->enter_array(builder, _dbus_message_is_gvariant(message) ?
-				"(tv)" : "(yv)");
+	driver->enter_array(builder, gvariant ? "(tv)" : "(yv)");
 =

 	if (message->path) {
 		add_field(builder, driver, DBUS_MESSAGE_FIELD_PATH,
@@ -879,8 +931,18 @@ static void build_header(struct l_dbus_message *messag=
e, const char *signature)
 	}
 =

 	if (message->reply_serial !=3D 0) {
-		add_field(builder, driver, DBUS_MESSAGE_FIELD_REPLY_SERIAL,
+		if (gvariant) {
+			uint64_t reply_serial =3D message->reply_serial;
+
+			add_field(builder, driver,
+					DBUS_MESSAGE_FIELD_REPLY_SERIAL,
+					"t", &reply_serial);
+		} else {
+			add_field(builder, driver,
+					DBUS_MESSAGE_FIELD_REPLY_SERIAL,
 					"u", &message->reply_serial);
+		}
+
 		message->reply_serial =3D 0;
 	}
 =

@@ -903,18 +965,18 @@ static void build_header(struct l_dbus_message *messa=
ge, const char *signature)
 =

 	driver->free(builder);
 =

-	hdr =3D message->header;
-
-	if (_dbus_message_is_gvariant(message))
-		hdr->field_length =3D header_size - 16;
+	if (!_dbus_message_is_gvariant(message)) {
+		struct dbus_header *hdr =3D message->header;
 =

-	hdr->body_length =3D message->body_size;
+		hdr->dbus1.body_length =3D message->body_size;
+	}
 =

 	/* We must align the end of the header to an 8-byte boundary */
 	message->header_size =3D align_len(header_size, 8);
 	message->header =3D l_realloc(message->header, message->header_size);
 	memset(message->header + header_size, 0,
 			message->header_size - header_size);
+	message->header_end =3D header_size;
 }
 =

 struct container {
@@ -1313,9 +1375,20 @@ uint32_t _dbus_message_get_reply_serial(struct l_dbu=
s_message *message)
 	if (unlikely(!message))
 		return 0;
 =

-	if (message->reply_serial =3D=3D 0)
-		get_header_field(message, DBUS_MESSAGE_FIELD_REPLY_SERIAL, 'u',
+	if (message->reply_serial =3D=3D 0) {
+		if (_dbus_message_is_gvariant(message)) {
+			uint64_t reply_serial;
+
+			get_header_field(message,
+					DBUS_MESSAGE_FIELD_REPLY_SERIAL, 't',
+					&reply_serial);
+
+			message->reply_serial =3D reply_serial;
+		} else
+			get_header_field(message,
+					DBUS_MESSAGE_FIELD_REPLY_SERIAL, 'u',
 					&message->reply_serial);
+	}
 =

 	return message->reply_serial;
 }
diff --git a/ell/dbus-private.h b/ell/dbus-private.h
index 764ed42..6a4ea96 100644
--- a/ell/dbus-private.h
+++ b/ell/dbus-private.h
@@ -49,9 +49,19 @@ struct dbus_header {
 	uint8_t  message_type;
 	uint8_t  flags;
 	uint8_t  version;
-	uint32_t body_length;
-	uint32_t serial;
-	uint32_t field_length;
+
+	union {
+		struct {
+			uint32_t body_length;
+			uint32_t serial;
+			uint32_t field_length;
+		} __attribute__ ((packed)) dbus1;
+
+		struct {
+			uint32_t reserved1;
+			uint64_t cookie;
+		} __attribute__ ((packed)) kdbus;
+	};
 } __attribute__ ((packed));
 #define DBUS_HEADER_SIZE 16
 =

diff --git a/ell/dbus-util.c b/ell/dbus-util.c
index ab0600a..900b71b 100644
--- a/ell/dbus-util.c
+++ b/ell/dbus-util.c
@@ -423,9 +423,9 @@ bool _dbus_header_is_valid(void *data, size_t size)
 	hdr =3D data;
 =

 	if (hdr->endian !=3D DBUS_NATIVE_ENDIAN)
-		header_len =3D bswap_32(hdr->field_length);
+		header_len =3D bswap_32(hdr->dbus1.field_length);
 	else
-		header_len =3D hdr->field_length;
+		header_len =3D hdr->dbus1.field_length;
 =

 	header_len +=3D sizeof(struct dbus_header);
 	return size >=3D header_len;
diff --git a/ell/dbus.c b/ell/dbus.c
index 81a7f9e..9bb47ae 100644
--- a/ell/dbus.c
+++ b/ell/dbus.c
@@ -613,10 +613,10 @@ static struct l_dbus_message *classic_recv_message(st=
ruct l_dbus *dbus)
 	if (len !=3D DBUS_HEADER_SIZE)
 		return NULL;
 =

-	header_size =3D align_len(DBUS_HEADER_SIZE + hdr.field_length, 8);
+	header_size =3D align_len(DBUS_HEADER_SIZE + hdr.dbus1.field_length, 8);
 	header =3D l_malloc(header_size);
 =

-	body_size =3D hdr.body_length;
+	body_size =3D hdr.dbus1.body_length;
 	body =3D l_malloc(body_size);
 =

 	iov[0].iov_base =3D header;
-- =

2.5.0


--===============5336348042509854333==--

