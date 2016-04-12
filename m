Content-Type: multipart/mixed; boundary="===============4357530967166403108=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH v2 08/11] dbus: Fix the kdbus message encoding
Date: Tue, 12 Apr 2016 03:56:12 +0200
Message-ID: <1460426175-25501-8-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1460426175-25501-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4357530967166403108==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Keep sending the message header+padding as a separate
KDBUS_ITEM_PAYLOAD_OFF buffer like in DBus-1, the systemd busctl utility
also seems to do that.  But fix what we send after the header.
---
 ell/dbus-kernel.c  | 17 +++++++++--------
 ell/dbus-message.c | 19 +++++++++++++++++++
 ell/dbus-private.h |  3 +++
 3 files changed, 31 insertions(+), 8 deletions(-)

diff --git a/ell/dbus-kernel.c b/ell/dbus-kernel.c
index 7797153..da5920f 100644
--- a/ell/dbus-kernel.c
+++ b/ell/dbus-kernel.c
@@ -427,14 +427,15 @@ int _dbus_kernel_send(int fd, size_t bloom_size, uint=
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
+	_dbus_message_build_contents(message, NULL, &body_size);
+	body =3D alloca(body_size);
+	_dbus_message_build_contents(message, body, NULL);
+
+	item->size =3D KDBUS_ITEM_HEADER_SIZE + sizeof(struct kdbus_vec);
+	item->type =3D KDBUS_ITEM_PAYLOAD_VEC;
+	item->vec.address =3D (uintptr_t) body;
+	item->vec.size =3D body_size;
+	item =3D KDBUS_ITEM_NEXT(item);
 =

 	kmsg->size =3D (void *)item - (void *)kmsg;
 =

diff --git a/ell/dbus-message.c b/ell/dbus-message.c
index eb47eb3..1a1e3ab 100644
--- a/ell/dbus-message.c
+++ b/ell/dbus-message.c
@@ -107,6 +107,25 @@ void *_dbus_message_get_body(struct l_dbus_message *ms=
g, size_t *out_size)
 	return msg->body;
 }
 =

+void _dbus_message_build_contents(struct l_dbus_message *msg,
+					uint8_t *out_buf, size_t *out_size)
+{
+	if (_dbus_message_is_gvariant(msg)) {
+		_gvariant_message_build_contents(msg->header_end, msg->body,
+							msg->body_size,
+							msg->signature,
+							out_buf, out_size);
+
+		return;
+	}
+
+	if (out_size)
+		*out_size =3D msg->body_size;
+
+	if (out_buf)
+		memcpy(out_buf, msg->body, msg->body_size);
+}
+
 void _dbus_message_set_serial(struct l_dbus_message *msg, uint32_t serial)
 {
 	struct dbus_header *hdr =3D msg->header;
diff --git a/ell/dbus-private.h b/ell/dbus-private.h
index 764ed42..b7f00b6 100644
--- a/ell/dbus-private.h
+++ b/ell/dbus-private.h
@@ -141,6 +141,9 @@ bool dbus_message_compare(struct l_dbus_message *messag=
e,
 bool _dbus_message_builder_mark(struct l_dbus_message_builder *builder);
 bool _dbus_message_builder_rewind(struct l_dbus_message_builder *builder);
 =

+void _dbus_message_build_contents(struct l_dbus_message *msg,
+					uint8_t *out_buf, size_t *out_size);
+
 const char *_dbus_signature_end(const char *signature);
 =

 bool _dbus_valid_object_path(const char *path);
-- =

2.5.0


--===============4357530967166403108==--

