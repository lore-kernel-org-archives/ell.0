Content-Type: multipart/mixed; boundary="===============6173144844253865753=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 05/12] dbus: Fix parsing GVariant header/body information
Date: Sun, 10 Apr 2016 06:02:37 +0200
Message-ID: <1460260961-9183-5-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1460260961-9183-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6173144844253865753==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

In GVariant messages there's no body size field (it is reserved and must
be sent as 0) or header size information or signature.  We do still add
the signature as a field same as in Dbus-1 because it's not prohibited
but we can't rely on it being there.  The message needs to be parsed as
a single GVariant blob if we want to split it into a header and a body.
---
 ell/dbus-kernel.c  |   3 --
 ell/dbus-message.c | 105 +++++++++++++++++++++++++++++++++++++------------=
----
 2 files changed, 74 insertions(+), 34 deletions(-)

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
index 085c5e1..b5bbd5c 100644
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
@@ -387,6 +389,9 @@ LIB_EXPORT void l_dbus_message_unref(struct l_dbus_mess=
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
@@ -567,19 +572,11 @@ static bool get_header_field_from_iter_valist(struct =
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
+					message->header + 16,
+					message->header_end - 16))
 			return false;
 =

 		if (!_gvariant_iter_enter_array(&header, &array))
@@ -652,6 +649,7 @@ struct l_dbus_message *dbus_message_from_blob(const voi=
d *data, size_t size)
 {
 	const struct dbus_header *hdr =3D data;
 	struct l_dbus_message *message;
+	size_t body_pos;
 =

 	if (unlikely(size < DBUS_HEADER_SIZE))
 		return NULL;
@@ -660,27 +658,62 @@ struct l_dbus_message *dbus_message_from_blob(const v=
oid *data, size_t size)
 =

 	message->refcount =3D 1;
 =

-	message->header_size =3D align_len(DBUS_HEADER_SIZE +
-						hdr->field_length, 8);
-	message->body_size =3D hdr->body_length;
+	if (hdr->version =3D=3D 1) {
+		message->header_size =3D align_len(DBUS_HEADER_SIZE +
+							hdr->field_length, 8);
+		message->body_size =3D hdr->body_length;
 =

-	if (message->header_size + message->body_size < size) {
-		l_free(message);
-		return NULL;
+		if (message->header_size + message->body_size < size)
+			goto free;
+
+		body_pos =3D message->header_size;
+	} else {
+		struct l_dbus_message_iter iter, header,
+			variant, structure, body;
+
+		if (!_gvariant_iter_init(&iter, message, "((yyyyuta{tv})v)",
+						NULL, data, size))
+			goto free;
+
+		if (!_gvariant_iter_enter_struct(&iter, &structure))
+			goto free;
+
+		if (!_gvariant_iter_enter_struct(&structure, &header))
+			goto free;
+
+		if (!_gvariant_iter_enter_variant(&structure, &variant))
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

-	get_header_field(message, DBUS_MESSAGE_FIELD_SIGNATURE, 'g',
-						&message->signature);
+	if (hdr->version =3D=3D 1)
+		if (!get_header_field(message, DBUS_MESSAGE_FIELD_SIGNATURE,
+					'g', &message->signature))
+			goto free;
 =

 	return message;
+
+free:
+	l_free(message);
+	return NULL;
 }
 =

 struct l_dbus_message *dbus_message_build(void *header, size_t header_size,
@@ -696,6 +729,13 @@ struct l_dbus_message *dbus_message_build(void *header=
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
@@ -827,21 +867,23 @@ static void build_header(struct l_dbus_message *messa=
ge, const char *signature)
 	char *generated_signature;
 	struct dbus_header *hdr;
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

-	builder =3D driver->new(message->header, message->header_size);
+	header_size =3D message->header_size;
 =

-	if (_dbus_message_is_gvariant(message)) {
-		uint32_t field_length =3D 0;
-		driver->append_basic(builder, 'u', &field_length);
-	}
+	if (gvariant)
+		header_size +=3D 4;
+
+	builder =3D driver->new(message->header, header_size);
 =

-	driver->enter_array(builder, _dbus_message_is_gvariant(message) ?
-				"(tv)" : "(yv)");
+	driver->enter_array(builder, gvariant ? "(tv)" : "(yv)");
 =

 	if (message->path) {
 		add_field(builder, driver, DBUS_MESSAGE_FIELD_PATH,
@@ -906,15 +948,16 @@ static void build_header(struct l_dbus_message *messa=
ge, const char *signature)
 	hdr =3D message->header;
 =

 	if (_dbus_message_is_gvariant(message))
-		hdr->field_length =3D header_size - 16;
-
-	hdr->body_length =3D message->body_size;
+		hdr->body_length =3D 0;
+	else
+		hdr->body_length =3D message->body_size;
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
-- =

2.5.0


--===============6173144844253865753==--

