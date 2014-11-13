Content-Type: multipart/mixed; boundary="===============3653345267772963259=="
MIME-Version: 1.0
From: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>
Subject: [PATCH 01/21] dbus: Add a utility function to check an message iter
 signature
Date: Thu, 13 Nov 2014 12:36:05 +0200
Message-ID: <1415874985-13034-2-git-send-email-tomasz.bursztyka@linux.intel.com>
In-Reply-To: <1415874985-13034-1-git-send-email-tomasz.bursztyka@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3653345267772963259==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

It will be useful sometime to verify the signature of a message iter
before doing anything with it. It will be useful when one knows the
signature and wants to defer the parsing to another part if only the
signature matches.
---
 ell/dbus-message.c | 13 +++++++++++++
 ell/dbus.h         |  2 ++
 2 files changed, 15 insertions(+)

diff --git a/ell/dbus-message.c b/ell/dbus-message.c
index 159df82..79e9e26 100644
--- a/ell/dbus-message.c
+++ b/ell/dbus-message.c
@@ -1331,6 +1331,19 @@ LIB_EXPORT bool l_dbus_message_iter_get_variant(
 	return result;
 }
 =

+LIB_EXPORT bool l_dbus_message_iter_has_signature(
+					struct l_dbus_message_iter *iter,
+					const char *signature)
+{
+	if (unlikely(!iter))
+		return false;
+
+	 if (!iter->sig_start || strcmp(iter->sig_start, signature))
+		 return false;
+
+	return true;
+}
+
 void _dbus_message_set_sender(struct l_dbus_message *message,
 					const char *sender)
 {
diff --git a/ell/dbus.h b/ell/dbus.h
index a6ad109..6dc9fc6 100644
--- a/ell/dbus.h
+++ b/ell/dbus.h
@@ -148,6 +148,8 @@ bool l_dbus_message_iter_is_valid(struct l_dbus_message=
_iter *iter);
 bool l_dbus_message_iter_next_entry(struct l_dbus_message_iter *iter, ...);
 bool l_dbus_message_iter_get_variant(struct l_dbus_message_iter *iter,
 						const char *signature, ...);
+bool l_dbus_message_iter_has_signature(struct l_dbus_message_iter *iter,
+							const char *signature);
 =

 bool l_dbus_message_set_arguments(struct l_dbus_message *message,
 						const char *signature, ...);
-- =

2.0.4


--===============3653345267772963259==--

