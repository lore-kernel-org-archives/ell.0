Content-Type: multipart/mixed; boundary="===============2569370863737451778=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/2] dbus: Add _gvariant_builder_mark and _rewind.
Date: Sat, 19 Mar 2016 07:00:46 +0100
Message-ID: <1458367247-14607-8-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1458367247-14607-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2569370863737451778==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/dbus-message.c     |  2 ++
 ell/gvariant-private.h |  2 ++
 ell/gvariant-util.c    | 78 +++++++++++++++++++++++++++++++++++++++++-----=
----
 3 files changed, 69 insertions(+), 13 deletions(-)

diff --git a/ell/dbus-message.c b/ell/dbus-message.c
index 30c09b9..ef6a50d 100644
--- a/ell/dbus-message.c
+++ b/ell/dbus-message.c
@@ -773,6 +773,8 @@ static struct builder_driver gvariant_driver =3D {
 	.enter_array =3D _gvariant_builder_enter_array,
 	.leave_array =3D _gvariant_builder_leave_array,
 	.finish =3D _gvariant_builder_finish,
+	.mark =3D _gvariant_builder_mark,
+	.rewind =3D _gvariant_builder_rewind,
 	.new =3D _gvariant_builder_new,
 	.free =3D _gvariant_builder_free,
 };
diff --git a/ell/gvariant-private.h b/ell/gvariant-private.h
index 2a20feb..f8f1313 100644
--- a/ell/gvariant-private.h
+++ b/ell/gvariant-private.h
@@ -47,6 +47,8 @@ struct dbus_builder *_gvariant_builder_new(void *body, si=
ze_t body_size);
 void _gvariant_builder_free(struct dbus_builder *builder);
 bool _gvariant_builder_append_basic(struct dbus_builder *builder,
 					char type, const void *value);
+bool _gvariant_builder_mark(struct dbus_builder *builder);
+bool _gvariant_builder_rewind(struct dbus_builder *builder);
 char *_gvariant_builder_finish(struct dbus_builder *builder,
 				void **body, size_t *body_size);
 bool _gvariant_builder_enter_struct(struct dbus_builder *builder,
diff --git a/ell/gvariant-util.c b/ell/gvariant-util.c
index 4601222..79f1a68 100644
--- a/ell/gvariant-util.c
+++ b/ell/gvariant-util.c
@@ -753,7 +753,15 @@ struct dbus_builder {
 	struct l_string *signature;
 	void *body;
 	size_t body_size;
+	size_t body_pos;
 	struct l_queue *containers;
+	struct {
+		struct container *container;
+		int sig_end;
+		size_t body_pos;
+		size_t offset_index;
+		bool variable_is_last : 1;
+	} mark;
 };
 =

 struct container {
@@ -770,18 +778,19 @@ struct container {
 static inline size_t grow_body(struct dbus_builder *builder,
 					size_t len, unsigned int alignment)
 {
-	size_t size =3D align_len(builder->body_size, alignment);
+	size_t size =3D align_len(builder->body_pos, alignment);
 =

 	if (size + len > builder->body_size) {
 		builder->body =3D l_realloc(builder->body, size + len);
-
-		if (size - builder->body_size > 0)
-			memset(builder->body + builder->body_size, 0,
-						size - builder->body_size);
-
 		builder->body_size =3D size + len;
 	}
 =

+	if (size - builder->body_pos > 0)
+		memset(builder->body + builder->body_pos, 0,
+			size - builder->body_pos);
+
+	builder->body_pos =3D size + len;
+
 	return size;
 }
 =

@@ -840,7 +849,7 @@ static void container_append_struct_offsets(struct cont=
ainer *container,
 	if (container->offset_index =3D=3D 0)
 		return;
 =

-	offset_size =3D offset_length(builder->body_size,
+	offset_size =3D offset_length(builder->body_pos,
 						container->offset_index);
 	i =3D container->offset_index - 1;
 =

@@ -863,7 +872,7 @@ static void container_append_array_offsets(struct conta=
iner *container,
 	if (container->offset_index =3D=3D 0)
 		return;
 =

-	offset_size =3D offset_length(builder->body_size,
+	offset_size =3D offset_length(builder->body_pos,
 						container->offset_index);
 	start =3D grow_body(builder, offset_size * container->offset_index, 1);
 =

@@ -888,6 +897,9 @@ struct dbus_builder *_gvariant_builder_new(void *body, =
size_t body_size)
 =

 	builder->body =3D body;
 	builder->body_size =3D body_size;
+	builder->body_pos =3D body_size;
+
+	builder->mark.container =3D root;
 =

 	return builder;
 }
@@ -1003,7 +1015,7 @@ static bool leave_struct_dict_common(struct dbus_buil=
der *builder,
 			return false;
 =

 		container_append_struct_offsets(container, builder);
-		offset =3D builder->body_size - parent->start;
+		offset =3D builder->body_pos - parent->start;
 		parent->offsets[parent->offset_index++] =3D offset;
 		parent->variable_is_last =3D true;
 	}
@@ -1086,7 +1098,7 @@ bool _gvariant_builder_leave_variant(struct dbus_buil=
der *builder)
 	if (!grow_offsets(parent))
 		return false;
 =

-	offset =3D builder->body_size - parent->start;
+	offset =3D builder->body_pos - parent->start;
 	parent->offsets[parent->offset_index++] =3D offset;
 	parent->variable_is_last =3D true;
 =

@@ -1166,7 +1178,7 @@ bool _gvariant_builder_leave_array(struct dbus_builde=
r *builder)
 	if (!grow_offsets(parent))
 		return false;
 =

-	offset =3D builder->body_size - parent->start;
+	offset =3D builder->body_pos - parent->start;
 	parent->offsets[parent->offset_index++] =3D offset;
 	parent->variable_is_last =3D true;
 =

@@ -1225,7 +1237,7 @@ bool _gvariant_builder_append_basic(struct dbus_build=
er *builder,
 	start =3D grow_body(builder, len, alignment);
 	memcpy(builder->body + start, value, len);
 =

-	offset =3D builder->body_size - container->start;
+	offset =3D builder->body_pos - container->start;
 	container->offsets[container->offset_index++] =3D offset;
 	container->variable_is_last =3D true;
 =

@@ -1235,6 +1247,46 @@ bool _gvariant_builder_append_basic(struct dbus_buil=
der *builder,
 	return true;
 }
 =

+bool _gvariant_builder_mark(struct dbus_builder *builder)
+{
+	struct container *container =3D l_queue_peek_head(builder->containers);
+
+	builder->mark.container =3D container;
+
+	if (l_queue_length(builder->containers) =3D=3D 1)
+		builder->mark.sig_end =3D l_string_length(builder->signature);
+	else
+		builder->mark.sig_end =3D container->sigindex;
+
+	builder->mark.body_pos =3D builder->body_pos;
+	builder->mark.offset_index =3D container->offset_index;
+	builder->mark.variable_is_last =3D container->variable_is_last;
+
+	return true;
+}
+
+bool _gvariant_builder_rewind(struct dbus_builder *builder)
+{
+	struct container *container;
+
+	while ((container =3D l_queue_peek_head(builder->containers)) !=3D
+				builder->mark.container) {
+		container_free(container);
+		l_queue_pop_head(builder->containers);
+	}
+
+	builder->body_pos =3D builder->mark.body_pos;
+	container->offset_index =3D builder->mark.offset_index;
+	container->variable_is_last =3D builder->mark.variable_is_last;
+
+	if (l_queue_length(builder->containers) =3D=3D 1)
+		l_string_truncate(builder->signature, builder->mark.sig_end);
+	else
+		container->sigindex =3D builder->mark.sig_end;
+
+	return true;
+}
+
 char *_gvariant_builder_finish(struct dbus_builder *builder,
 				void **body, size_t *body_size)
 {
@@ -1259,7 +1311,7 @@ char *_gvariant_builder_finish(struct dbus_builder *b=
uilder,
 		container_append_struct_offsets(root, builder);
 =

 	*body =3D builder->body;
-	*body_size =3D builder->body_size;
+	*body_size =3D builder->body_pos;
 	builder->body =3D NULL;
 	builder->body_size =3D 0;
 =

-- =

2.5.0


--===============2569370863737451778==--

