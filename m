Content-Type: multipart/mixed; boundary="===============4083760846336574960=="
MIME-Version: 1.0
From: Tim Kourt <tim.a.kourt@linux.intel.com>
Subject: [PATCH v2] dbus: Add message variable argument setter
Date: Wed, 08 Mar 2017 17:08:44 -0500
Message-ID: <20170308220844.19553-1-tim.a.kourt@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4083760846336574960==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/dbus-message.c | 17 +++++++++++++++++
 ell/dbus.h         |  2 ++
 2 files changed, 19 insertions(+)

diff --git a/ell/dbus-message.c b/ell/dbus-message.c
index ef5dd22..b5c9222 100644
--- a/ell/dbus-message.c
+++ b/ell/dbus-message.c
@@ -1414,6 +1414,23 @@ LIB_EXPORT bool l_dbus_message_set_arguments(struct =
l_dbus_message *message,
 	return result;
 }
 =

+LIB_EXPORT bool l_dbus_message_set_arguments_valist(
+					struct l_dbus_message *message,
+					const char *signature, va_list args)
+{
+	bool result;
+
+	if (unlikely(!message))
+		return false;
+
+	if (!signature)
+		return true;
+
+	result =3D append_arguments(message, signature, args);
+
+	return result;
+}
+
 LIB_EXPORT const char *l_dbus_message_get_path(struct l_dbus_message *mess=
age)
 {
 	if (unlikely(!message))
diff --git a/ell/dbus.h b/ell/dbus.h
index b096ed3..9d3416c 100644
--- a/ell/dbus.h
+++ b/ell/dbus.h
@@ -174,6 +174,8 @@ bool l_dbus_message_iter_get_variant(struct l_dbus_mess=
age_iter *iter,
 =

 bool l_dbus_message_set_arguments(struct l_dbus_message *message,
 						const char *signature, ...);
+bool l_dbus_message_set_arguments_valist(struct l_dbus_message *message,
+					 const char *signature, va_list args);
 =

 struct l_dbus_message_builder *l_dbus_message_builder_new(
 						struct l_dbus_message *message);
-- =

2.9.3


--===============4083760846336574960==--

