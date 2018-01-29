Content-Type: multipart/mixed; boundary="===============5879625568601759250=="
MIME-Version: 1.0
From: James Prestwood <james.prestwood@linux.intel.com>
Subject: [PATCH] dbus: added l_dbus_message_iter_get_fixed_array
Date: Mon, 29 Jan 2018 15:48:46 -0800
Message-ID: <1517269726-12151-1-git-send-email-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5879625568601759250==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Returns pointer and length of dbus array in place so no copying
is needed.
---
 ell/dbus-message.c | 14 ++++++++++++++
 ell/dbus.h         |  3 ++-
 2 files changed, 16 insertions(+), 1 deletion(-)

diff --git a/ell/dbus-message.c b/ell/dbus-message.c
index f4f6b42..7a24f5b 100644
--- a/ell/dbus-message.c
+++ b/ell/dbus-message.c
@@ -1414,6 +1414,20 @@ LIB_EXPORT bool l_dbus_message_iter_get_variant(
 	return result;
 }
 =

+LIB_EXPORT bool l_dbus_message_iter_get_fixed_array(
+					struct l_dbus_message_iter *iter,
+					const void **a, uint32_t *len)
+{
+	if (iter->container_type !=3D 'a')
+		return false;
+
+	*a =3D iter->data + iter->pos;
+	*len =3D iter->len - 4;
+
+	return true;
+}
+
+
 void _dbus_message_set_sender(struct l_dbus_message *message,
 					const char *sender)
 {
diff --git a/ell/dbus.h b/ell/dbus.h
index 1b1ec2b..4eb579c 100644
--- a/ell/dbus.h
+++ b/ell/dbus.h
@@ -170,7 +170,8 @@ bool l_dbus_message_get_arguments_valist(struct l_dbus_=
message *message,
 bool l_dbus_message_iter_next_entry(struct l_dbus_message_iter *iter, ...);
 bool l_dbus_message_iter_get_variant(struct l_dbus_message_iter *iter,
 						const char *signature, ...);
-
+bool l_dbus_message_iter_get_fixed_array(struct l_dbus_message_iter *iter,
+						const void **a, uint32_t *len);
 bool l_dbus_message_set_arguments(struct l_dbus_message *message,
 						const char *signature, ...);
 bool l_dbus_message_set_arguments_valist(struct l_dbus_message *message,
-- =

2.7.4


--===============5879625568601759250==--

