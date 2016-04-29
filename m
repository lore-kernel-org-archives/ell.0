Content-Type: multipart/mixed; boundary="===============1618343483340128798=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 01/11] dbus: Accept a list of FDs in dbus_message_from_blob
Date: Fri, 29 Apr 2016 05:31:58 +0200
Message-ID: <1461900728-20662-6-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1461900728-20662-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1618343483340128798==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/dbus-kernel.c  |  2 +-
 ell/dbus-message.c | 16 ++++++++++++++--
 ell/dbus-private.h |  3 ++-
 3 files changed, 17 insertions(+), 4 deletions(-)

diff --git a/ell/dbus-kernel.c b/ell/dbus-kernel.c
index 50ee0ed..7446ece 100644
--- a/ell/dbus-kernel.c
+++ b/ell/dbus-kernel.c
@@ -516,7 +516,7 @@ static int _dbus_kernel_make_message(struct kdbus_msg *=
kmsg,
 =

 	collect_body_parts(kmsg, size, &data);
 =

-	*out_message =3D dbus_message_from_blob(data, size);
+	*out_message =3D dbus_message_from_blob(data, size, NULL, 0);
 =

 	l_free(data);
 =

diff --git a/ell/dbus-message.c b/ell/dbus-message.c
index f3d82d8..9fe2a59 100644
--- a/ell/dbus-message.c
+++ b/ell/dbus-message.c
@@ -691,11 +691,13 @@ static bool valid_header(const struct dbus_header *hd=
r)
 	return true;
 }
 =

-struct l_dbus_message *dbus_message_from_blob(const void *data, size_t siz=
e)
+struct l_dbus_message *dbus_message_from_blob(const void *data, size_t siz=
e,
+						int fds[], uint32_t num_fds)
 {
 	const struct dbus_header *hdr =3D data;
 	struct l_dbus_message *message;
 	size_t body_pos;
+	unsigned int i;
 =

 	if (unlikely(size < DBUS_HEADER_SIZE))
 		return NULL;
@@ -759,6 +761,16 @@ struct l_dbus_message *dbus_message_from_blob(const vo=
id *data, size_t size)
 		get_header_field(message, DBUS_MESSAGE_FIELD_SIGNATURE,
 					'g', &message->signature);
 =

+	if (num_fds > L_ARRAY_SIZE(message->fds)) {
+		for (i =3D L_ARRAY_SIZE(message->fds); i < num_fds; i++)
+			close(fds[i]);
+
+		num_fds =3D L_ARRAY_SIZE(message->fds);
+	}
+
+	message->num_fds =3D num_fds;
+	memcpy(message->fds, fds, num_fds * sizeof(int));
+
 	return message;
 =

 free:
@@ -812,7 +824,7 @@ bool dbus_message_compare(struct l_dbus_message *messag=
e,
 	struct l_dbus_message *other;
 	bool ret =3D false;
 =

-	other =3D dbus_message_from_blob(data, size);
+	other =3D dbus_message_from_blob(data, size, NULL, 0);
 =

 	if (message->signature) {
 		if (!other->signature)
diff --git a/ell/dbus-private.h b/ell/dbus-private.h
index f4209b8..e8dbce7 100644
--- a/ell/dbus-private.h
+++ b/ell/dbus-private.h
@@ -147,7 +147,8 @@ struct l_dbus_message *_dbus_message_new_error(uint8_t =
version,
 						const char *name,
 						const char *error);
 =

-struct l_dbus_message *dbus_message_from_blob(const void *data, size_t siz=
e);
+struct l_dbus_message *dbus_message_from_blob(const void *data, size_t siz=
e,
+						int fds[], uint32_t num_fds);
 struct l_dbus_message *dbus_message_build(void *header, size_t header_size,
 						void *body, size_t body_size,
 						int fds[], uint32_t num_fds);
-- =

2.5.0


--===============1618343483340128798==--

