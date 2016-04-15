Content-Type: multipart/mixed; boundary="===============1111873770685347278=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH v3 6/9] dbus: Fix the kdbus message encoding
Date: Fri, 15 Apr 2016 02:33:59 +0200
Message-ID: <1460680442-15201-6-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1460680442-15201-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1111873770685347278==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Keep sending the message header+padding as a separate
KDBUS_ITEM_PAYLOAD_OFF buffer like in DBus-1, systemd also seems to do
that.  But fix the structure of the message body.

The term footer is used in systemd, probably there's a better name.
---
 ell/dbus-kernel.c  | 19 +++++++++----------
 ell/dbus-message.c | 19 +++++++++++++++++++
 ell/dbus-private.h |  1 +
 3 files changed, 29 insertions(+), 10 deletions(-)

diff --git a/ell/dbus-kernel.c b/ell/dbus-kernel.c
index 7797153..b5a07a5 100644
--- a/ell/dbus-kernel.c
+++ b/ell/dbus-kernel.c
@@ -323,8 +323,8 @@ int _dbus_kernel_send(int fd, size_t bloom_size, uint8_=
t bloom_n_hash,
 	struct kdbus_item *item;
 	void *header;
 	size_t header_size;
-	void *body;
-	size_t body_size;
+	void *footer;
+	size_t footer_size;
 	int ret;
 	struct kdbus_cmd_send cmd;
 	L_AUTO_FREE_VAR(struct kdbus_msg *, kmsg);
@@ -427,14 +427,13 @@ int _dbus_kernel_send(int fd, size_t bloom_size, uint=
8_t bloom_n_hash,
 	item->vec.size =3D header_size;
 	item =3D KDBUS_ITEM_NEXT(item);
 =

-	body =3D _dbus_message_get_body(message, &body_size);
-	if (body_size > 0) {
-		item->size =3D KDBUS_ITEM_HEADER_SIZE + sizeof(struct kdbus_vec);
-		item->type =3D KDBUS_ITEM_PAYLOAD_VEC;
-		item->vec.address =3D (uintptr_t) body;
-		item->vec.size =3D body_size;
-		item =3D KDBUS_ITEM_NEXT(item);
-	}
+	footer =3D _dbus_message_get_footer(message, &footer_size);
+
+	item->size =3D KDBUS_ITEM_HEADER_SIZE + sizeof(struct kdbus_vec);
+	item->type =3D KDBUS_ITEM_PAYLOAD_VEC;
+	item->vec.address =3D (uintptr_t) footer;
+	item->vec.size =3D footer_size;
+	item =3D KDBUS_ITEM_NEXT(item);
 =

 	kmsg->size =3D (void *)item - (void *)kmsg;
 =

diff --git a/ell/dbus-message.c b/ell/dbus-message.c
index 9fdc0ff..00d9838 100644
--- a/ell/dbus-message.c
+++ b/ell/dbus-message.c
@@ -107,6 +107,25 @@ void *_dbus_message_get_body(struct l_dbus_message *ms=
g, size_t *out_size)
 	return msg->body;
 }
 =

+/* Get a buffer containing the final message contents except the header */
+void *_dbus_message_get_footer(struct l_dbus_message *msg, size_t *out_siz=
e)
+{
+	size_t size;
+
+	if (_dbus_message_is_gvariant(msg)) {
+		size =3D _gvariant_message_finalize(msg->header_end,
+						msg->body, msg->body_size,
+						msg->signature);
+		size -=3D msg->header_size;
+	} else
+		size =3D msg->body_size;
+
+	if (out_size)
+		*out_size =3D size;
+
+	return msg->body;
+}
+
 void _dbus_message_set_serial(struct l_dbus_message *msg, uint32_t serial)
 {
 	struct dbus_header *hdr =3D msg->header;
diff --git a/ell/dbus-private.h b/ell/dbus-private.h
index 6a4ea96..71767a4 100644
--- a/ell/dbus-private.h
+++ b/ell/dbus-private.h
@@ -115,6 +115,7 @@ bool _dbus1_builder_rewind(struct dbus_builder *builder=
);
 =

 void *_dbus_message_get_body(struct l_dbus_message *msg, size_t *out_size);
 void *_dbus_message_get_header(struct l_dbus_message *msg, size_t *out_siz=
e);
+void *_dbus_message_get_footer(struct l_dbus_message *msg, size_t *out_siz=
e);
 void _dbus_message_set_serial(struct l_dbus_message *msg, uint32_t serial);
 uint32_t _dbus_message_get_serial(struct l_dbus_message *msg);
 uint32_t _dbus_message_get_reply_serial(struct l_dbus_message *message);
-- =

2.5.0


--===============1111873770685347278==--

