Content-Type: multipart/mixed; boundary="===============5103681056342299239=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 06/11] dbus: Add utility to get FD array for a message
Date: Fri, 29 Apr 2016 05:32:03 +0200
Message-ID: <1461900728-20662-11-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1461900728-20662-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5103681056342299239==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/dbus-message.c | 7 +++++++
 ell/dbus-private.h | 1 +
 2 files changed, 8 insertions(+)

diff --git a/ell/dbus-message.c b/ell/dbus-message.c
index 628f994..755dcf5 100644
--- a/ell/dbus-message.c
+++ b/ell/dbus-message.c
@@ -126,6 +126,13 @@ void *_dbus_message_get_footer(struct l_dbus_message *=
msg, size_t *out_size)
 	return msg->body;
 }
 =

+int *_dbus_message_get_fds(struct l_dbus_message *msg, uint32_t *num_fds)
+{
+	*num_fds =3D msg->num_fds;
+
+	return msg->fds;
+}
+
 void _dbus_message_set_serial(struct l_dbus_message *msg, uint32_t serial)
 {
 	struct dbus_header *hdr =3D msg->header;
diff --git a/ell/dbus-private.h b/ell/dbus-private.h
index e8dbce7..88bea3c 100644
--- a/ell/dbus-private.h
+++ b/ell/dbus-private.h
@@ -116,6 +116,7 @@ bool _dbus1_builder_rewind(struct dbus_builder *builder=
);
 void *_dbus_message_get_body(struct l_dbus_message *msg, size_t *out_size);
 void *_dbus_message_get_header(struct l_dbus_message *msg, size_t *out_siz=
e);
 void *_dbus_message_get_footer(struct l_dbus_message *msg, size_t *out_siz=
e);
+int *_dbus_message_get_fds(struct l_dbus_message *msg, uint32_t *num_fds);
 void _dbus_message_set_serial(struct l_dbus_message *msg, uint32_t serial);
 uint32_t _dbus_message_get_serial(struct l_dbus_message *msg);
 uint32_t _dbus_message_get_reply_serial(struct l_dbus_message *message);
-- =

2.5.0


--===============5103681056342299239==--

