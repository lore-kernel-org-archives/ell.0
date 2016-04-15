Content-Type: multipart/mixed; boundary="===============4501940323116427515=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH v3 3/9] gvariant: New gvariant message format support
Date: Fri, 15 Apr 2016 02:33:56 +0200
Message-ID: <1460680442-15201-3-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1460680442-15201-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4501940323116427515==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Make the builder write a complete struct enclosed in a variant and add a
utility to add the final framing offset to produce a single parseable
GVariant blob.
---
 ell/gvariant-private.h |  4 ++++
 ell/gvariant-util.c    | 44 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 48 insertions(+)

diff --git a/ell/gvariant-private.h b/ell/gvariant-private.h
index f8f1313..6c0005a 100644
--- a/ell/gvariant-private.h
+++ b/ell/gvariant-private.h
@@ -63,3 +63,7 @@ bool _gvariant_builder_leave_variant(struct dbus_builder =
*builder);
 bool _gvariant_builder_enter_array(struct dbus_builder *builder,
 					const char *signature);
 bool _gvariant_builder_leave_array(struct dbus_builder *builder);
+
+size_t _gvariant_message_finalize(size_t header_end,
+					void *body, size_t body_size,
+					const char *signature);
diff --git a/ell/gvariant-util.c b/ell/gvariant-util.c
index 0baf1c6..e07bd2f 100644
--- a/ell/gvariant-util.c
+++ b/ell/gvariant-util.c
@@ -1292,6 +1292,8 @@ char *_gvariant_builder_finish(struct dbus_builder *b=
uilder,
 {
 	char *signature;
 	struct container *root;
+	uint8_t *variant_buf;
+	size_t size;
 =

 	if (unlikely(!builder))
 		return NULL;
@@ -1307,9 +1309,30 @@ char *_gvariant_builder_finish(struct dbus_builder *=
builder,
 	if (_gvariant_is_fixed_size(signature)) {
 		int alignment =3D _gvariant_get_alignment(signature);
 		grow_body(builder, 0, alignment);
+
+		/* Empty struct or "unit type" is encoded one zero byte */
+		if (signature[0] =3D=3D '\0')
+			grow_body(builder, 1, 1);
 	} else
 		container_append_struct_offsets(root, builder);
 =

+	/*
+	 * Make sure there's enough space after the body for the variant
+	 * signature written here but not included in the body size and
+	 * one framing offset value to be written in
+	 * _gvariant_message_finalize.
+	 */
+	size =3D 3 + strlen(signature) + 8;
+	if (builder->body_pos + size > builder->body_size)
+		builder->body =3D l_realloc(builder->body,
+						builder->body_pos + size);
+
+	variant_buf =3D builder->body + builder->body_pos;
+	*variant_buf++ =3D 0;
+	*variant_buf++ =3D '(';
+	variant_buf =3D mempcpy(variant_buf, signature, strlen(signature));
+	*variant_buf++ =3D ')';
+
 	*body =3D builder->body;
 	*body_size =3D builder->body_pos;
 	builder->body =3D NULL;
@@ -1317,3 +1340,24 @@ char *_gvariant_builder_finish(struct dbus_builder *=
builder,
 =

 	return signature;
 }
+
+/*
+ * Write the header's framing offset after the body variant which is the
+ * last piece of data in the message after the header, the padding and
+ * the builder has written the message body.
+ */
+size_t _gvariant_message_finalize(size_t header_end,
+					void *body, size_t body_size,
+					const char *signature)
+{
+	size_t offset_start;
+	size_t offset_size;
+
+	offset_start =3D body_size + 3 + strlen(signature);
+
+	offset_size =3D offset_length(align_len(header_end, 8) + offset_start, 1);
+
+	write_word_le(body + offset_start, header_end, offset_size);
+
+	return align_len(header_end, 8) + offset_start + offset_size;
+}
-- =

2.5.0


--===============4501940323116427515==--

