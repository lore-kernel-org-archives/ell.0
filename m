Content-Type: multipart/mixed; boundary="===============1176329670474757869=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 5/5] examples: Use l_dbus_name_acquire to acquire well-known
 name
Date: Tue, 29 Mar 2016 00:09:23 +0200
Message-ID: <1459202963-12390-5-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1459202963-12390-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1176329670474757869==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 examples/dbus-service.c | 33 ++++++---------------------------
 1 file changed, 6 insertions(+), 27 deletions(-)

diff --git a/examples/dbus-service.c b/examples/dbus-service.c
index 347faae..51b7e4f 100644
--- a/examples/dbus-service.c
+++ b/examples/dbus-service.c
@@ -50,29 +50,11 @@ static void signal_handler(struct l_signal *signal, uin=
t32_t signo,
 	}
 }
 =

-static void request_name_setup(struct l_dbus_message *message, void *user_=
data)
+static void request_name_callback(struct l_dbus *dbus, bool success,
+					bool queued, void *user_data)
 {
-	const char *name =3D "org.test";
-
-	l_dbus_message_set_arguments(message, "su", name, 0);
-}
-
-static void request_name_callback(struct l_dbus_message *message,
-							void *user_data)
-{
-	const char *error, *text;
-	uint32_t result;
-
-	if (l_dbus_message_get_error(message, &error, &text)) {
-		l_error("error=3D%s", error);
-		l_error("message=3D%s", text);
-		return;
-	}
-
-	if (!l_dbus_message_get_arguments(message, "u", &result))
-		return;
-
-	l_info("request name result=3D%d", result);
+	l_info("request name result=3D%s",
+		success ? (queued ? "queued" : "success") : "failed");
 }
 =

 static void ready_callback(void *user_data)
@@ -211,11 +193,8 @@ int main(int argc, char *argv[])
 	l_dbus_set_ready_handler(dbus, ready_callback, dbus, NULL);
 	l_dbus_set_disconnect_handler(dbus, disconnect_callback, NULL, NULL);
 =

-	l_dbus_method_call(dbus, "org.freedesktop.DBus",
-				"/org/freedesktop/DBus",
-				L_DBUS_INTERFACE_DBUS, "RequestName",
-				request_name_setup,
-				request_name_callback, NULL, NULL);
+	l_dbus_name_acquire(dbus, "org.test", false, false, false,
+				request_name_callback, NULL);
 =

 	if (!l_dbus_object_manager_enable(dbus)) {
 		l_info("Unable to enable Object Manager");
-- =

2.5.0


--===============1176329670474757869==--

