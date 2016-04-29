Content-Type: multipart/mixed; boundary="===============4465475867894097567=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 03/11] dbus: Validate the size of fd list in dbus_message_build
Date: Fri, 29 Apr 2016 05:32:00 +0200
Message-ID: <1461900728-20662-8-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1461900728-20662-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4465475867894097567==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Trim the list of fds if too big rather than error out to be consistent
with how we handle invalid FDs in message_iter_next_entry_valist and
how kdbus allows messages with invalid FDs to still be delivered.
---
 ell/dbus-message.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/ell/dbus-message.c b/ell/dbus-message.c
index 9fe2a59..8151c69 100644
--- a/ell/dbus-message.c
+++ b/ell/dbus-message.c
@@ -784,6 +784,7 @@ struct l_dbus_message *dbus_message_build(void *header,=
 size_t header_size,
 {
 	const struct dbus_header *hdr =3D header;
 	struct l_dbus_message *message;
+	unsigned int i;
 =

 	if (unlikely(header_size < DBUS_HEADER_SIZE))
 		return NULL;
@@ -806,6 +807,13 @@ struct l_dbus_message *dbus_message_build(void *header=
, size_t header_size,
 	message->body_size =3D body_size;
 	message->body =3D body;
 =

+	if (num_fds > L_ARRAY_SIZE(message->fds)) {
+		for (i =3D L_ARRAY_SIZE(message->fds); i < num_fds; i++)
+			close(fds[i]);
+
+		num_fds =3D L_ARRAY_SIZE(message->fds);
+	}
+
 	message->num_fds =3D num_fds;
 	memcpy(message->fds, fds, num_fds * sizeof(int));
 =

-- =

2.5.0


--===============4465475867894097567==--

