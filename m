Content-Type: multipart/mixed; boundary="===============6767294237199726112=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/4] dbus: Close unused file descriptors when creating message
Date: Wed, 04 May 2016 13:03:10 +0200
Message-ID: <1462359793-18789-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6767294237199726112==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/dbus-message.c | 22 ++++++++++------------
 1 file changed, 10 insertions(+), 12 deletions(-)

diff --git a/ell/dbus-message.c b/ell/dbus-message.c
index 0fe76de..89aaacc 100644
--- a/ell/dbus-message.c
+++ b/ell/dbus-message.c
@@ -765,7 +765,7 @@ struct l_dbus_message *dbus_message_from_blob(const voi=
d *data, size_t size,
 					'g', &message->signature);
 =

 	if (num_fds) {
-		uint32_t unix_fds;
+		uint32_t unix_fds, orig_fds =3D num_fds;
 =

 		if (!get_header_field(message, DBUS_MESSAGE_FIELD_UNIX_FDS,
 					'u', &unix_fds))
@@ -774,12 +774,11 @@ struct l_dbus_message *dbus_message_from_blob(const v=
oid *data, size_t size,
 		if (num_fds > unix_fds)
 			num_fds =3D unix_fds;
 =

-		if (num_fds > L_ARRAY_SIZE(message->fds)) {
-			for (i =3D L_ARRAY_SIZE(message->fds); i < num_fds; i++)
-				close(fds[i]);
-
+		if (num_fds > L_ARRAY_SIZE(message->fds))
 			num_fds =3D L_ARRAY_SIZE(message->fds);
-		}
+
+		for (i =3D num_fds; i < orig_fds; i++)
+			close(fds[i]);
 	}
 =

 	message->num_fds =3D num_fds;
@@ -824,7 +823,7 @@ struct l_dbus_message *dbus_message_build(void *header,=
 size_t header_size,
 	message->sealed =3D true;
 =

 	if (num_fds) {
-		uint32_t unix_fds;
+		uint32_t unix_fds, orig_fds =3D num_fds;
 =

 		if (!get_header_field(message, DBUS_MESSAGE_FIELD_UNIX_FDS,
 					'u', &unix_fds)) {
@@ -835,12 +834,11 @@ struct l_dbus_message *dbus_message_build(void *heade=
r, size_t header_size,
 		if (num_fds > unix_fds)
 			num_fds =3D unix_fds;
 =

-		if (num_fds > L_ARRAY_SIZE(message->fds)) {
-			for (i =3D L_ARRAY_SIZE(message->fds); i < num_fds; i++)
-				close(fds[i]);
-
+		if (num_fds > L_ARRAY_SIZE(message->fds))
 			num_fds =3D L_ARRAY_SIZE(message->fds);
-		}
+
+		for (i =3D num_fds; i < orig_fds; i++)
+			close(fds[i]);
 	}
 =

 	message->num_fds =3D num_fds;
-- =

2.7.4


--===============6767294237199726112==--

