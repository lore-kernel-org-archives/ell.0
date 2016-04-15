Content-Type: multipart/mixed; boundary="===============6901259918064299923=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH v3 2/9] dbus: Don't rely on 1st KDBUS_ITEM_PAYLOAD_OFF being
 the header
Date: Fri, 15 Apr 2016 02:33:55 +0200
Message-ID: <1460680442-15201-2-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1460680442-15201-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6901259918064299923==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The header of the GVariant message can't be split into multiple
KDBUS_ITEM_PAYLOAD_OFF items according to the docs but it doesn't have
to be split from the body.  We need to use dbus_message_from_blob
because we can't know the header/body split positions without parsing
the received contents.
---
 ell/dbus-kernel.c | 75 +++++++++++++++------------------------------------=
----
 1 file changed, 20 insertions(+), 55 deletions(-)

diff --git a/ell/dbus-kernel.c b/ell/dbus-kernel.c
index 4a3aed0..7797153 100644
--- a/ell/dbus-kernel.c
+++ b/ell/dbus-kernel.c
@@ -449,84 +449,51 @@ int _dbus_kernel_send(int fd, size_t bloom_size, uint=
8_t bloom_n_hash,
 	return 0;
 }
 =

-static int collect_body_parts(struct kdbus_msg *kmsg,
-					size_t header_size, void **out_header,
-					size_t body_size, void **out_body)
+static void collect_body_parts(struct kdbus_msg *kmsg, size_t size, void *=
*data)
 {
 	struct kdbus_item *item;
-	void *body;
-	void *header;
-	bool saw_header =3D false;
 	size_t offset =3D 0;
 =

-	header =3D l_malloc(header_size);
-	if (!header)
-		return -ENOMEM;
-
-	body =3D NULL;
-
-	if (body_size > 0) {
-		body =3D l_malloc(body_size);
-		if (!body) {
-			l_free(header);
-			return -ENOMEM;
-		}
-	}
+	*data =3D l_malloc(size);
 =

 	KDBUS_ITEM_FOREACH(item, kmsg, items) {
 		switch (item->type) {
 		case KDBUS_ITEM_PAYLOAD_OFF:
-			if (saw_header) {
-				memcpy(body + offset,
-					(void *)kmsg + item->vec.offset,
-					item->vec.size);
+			memcpy(*data + offset, (void *) kmsg + item->vec.offset,
+				item->vec.size);
 =

-				offset +=3D item->vec.size;
-			} else {
-				memcpy(header, (void *)kmsg + item->vec.offset,
-					item->vec.size);
-				saw_header =3D true;
-			}
+			offset +=3D item->vec.size;
 =

 			break;
 		}
 	}
-
-	*out_body =3D body;
-	*out_header =3D header;
-
-	return 0;
 }
 =

 static int _dbus_kernel_make_message(struct kdbus_msg *kmsg,
 				struct l_dbus_message **out_message)
 {
 	struct kdbus_item *item;
-	void *header =3D 0;
-	size_t header_size =3D 0;
+	void *data =3D 0;
+	size_t size =3D 0;
 	struct dbus_header *hdr;
-	void *body =3D 0;
-	size_t body_size =3D 0;
-	int r;
 	const char *destination =3D 0;
 	char unique_bus_name[128];
 =

 	KDBUS_ITEM_FOREACH(item, kmsg, items) {
 		switch (item->type) {
 		case KDBUS_ITEM_PAYLOAD_OFF:
-			if (!header_size) {
-				header =3D (void *)kmsg + item->vec.offset;
+			if (!size) {
+				if (item->vec.size < sizeof(struct dbus_header))
+					return -EBADMSG;
 =

-				header_size =3D item->vec.size;
+				hdr =3D (void *)kmsg + item->vec.offset;
+			}
 =

-				if (!_dbus_header_is_valid(header, header_size))
-					return -EBADMSG;
-			} else
-				body_size +=3D item->vec.size;
+			size +=3D item->vec.size;
 =

 			break;
 		case KDBUS_ITEM_PAYLOAD_MEMFD:
-			if (!header_size)
+			if (!size)
 				return -EBADMSG;
 =

 			return -ENOTSUP;
@@ -541,23 +508,21 @@ static int _dbus_kernel_make_message(struct kdbus_msg=
 *kmsg,
 		}
 	}
 =

-	if (!header)
+	if (!size)
 		return -EBADMSG;
 =

-	hdr =3D header;
 	if (hdr->endian !=3D DBUS_NATIVE_ENDIAN)
 		return -EPROTOTYPE;
 =

 	if (hdr->version !=3D 2)
 		return -EPROTO;
 =

-	r =3D collect_body_parts(kmsg, header_size, &header,
-						body_size, &body);
-	if (r < 0)
-		return r;
+	collect_body_parts(kmsg, size, &data);
+
+	*out_message =3D dbus_message_from_blob(data, size);
+
+	l_free(data);
 =

-	*out_message =3D dbus_message_build(header, header_size, body, body_size,
-						NULL, 0);
 	if (!*out_message)
 		return -EBADMSG;
 =

-- =

2.5.0


--===============6901259918064299923==--

