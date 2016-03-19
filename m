Content-Type: multipart/mixed; boundary="===============6727295252878519042=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH] dbus: More complete buffer size check in
 dbus_message_from_blob
Date: Sat, 19 Mar 2016 07:00:39 +0100
Message-ID: <1458367247-14607-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6727295252878519042==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/dbus-message.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/ell/dbus-message.c b/ell/dbus-message.c
index 84d42d4..f9e13e2 100644
--- a/ell/dbus-message.c
+++ b/ell/dbus-message.c
@@ -643,9 +643,14 @@ struct l_dbus_message *dbus_message_from_blob(const vo=
id *data, size_t size)
 =

 	message->header_size =3D align_len(DBUS_HEADER_SIZE +
 						hdr->field_length, 8);
-	message->header =3D l_malloc(message->header_size);
-
 	message->body_size =3D hdr->body_length;
+
+	if (message->header_size + message->body_size < size) {
+		l_free(message);
+		return NULL;
+	}
+
+	message->header =3D l_malloc(message->header_size);
 	message->body =3D l_malloc(message->body_size);
 =

 	memcpy(message->header, data, message->header_size);
-- =

2.5.0


--===============6727295252878519042==--

