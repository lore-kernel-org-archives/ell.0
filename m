Content-Type: multipart/mixed; boundary="===============4200234812539191890=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 19/20] unit: Use l_dbus_name_acquire to acquire well-known
 name.
Date: Mon, 14 Mar 2016 04:41:35 +0100
Message-ID: <1457926896-9843-19-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1457926896-9843-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4200234812539191890==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-dbus-properties.c | 36 ++++++------------------------------
 unit/test-kdbus.c           | 14 +++++++++-----
 2 files changed, 15 insertions(+), 35 deletions(-)

diff --git a/unit/test-dbus-properties.c b/unit/test-dbus-properties.c
index be91dd3..c7ed384 100644
--- a/unit/test-dbus-properties.c
+++ b/unit/test-dbus-properties.c
@@ -152,32 +152,11 @@ static void test_next()
 		}	\
 	} while (0)
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
-					void *user_data)
-{
-	const char *error, *text;
-	uint32_t result;
-
-	if (l_dbus_message_get_error(message, &error, &text)) {
-		l_error("error=3D%s", error);
-		l_error("message=3D%s", text);
-		l_main_quit();
-		return;
-	}
-
-	if (!l_dbus_message_get_arguments(message, "u", &result)) {
-		l_main_quit();
-		return;
-	}
-
-	l_info("request name result=3D%d", result);
+	l_info("request name result=3D%s",
+		success ? (queued ? "queued" : "success") : "failed");
 =

 	test_next();
 }
@@ -938,11 +917,8 @@ int main(int argc, char *argv[])
 	l_dbus_set_ready_handler(dbus, ready_callback, dbus, NULL);
 	l_dbus_set_disconnect_handler(dbus, disconnect_callback, NULL, NULL);
 =

-	l_dbus_method_call(dbus, "org.freedesktop.DBus",
-				"/org/freedesktop/DBus",
-				"org.freedesktop.DBus", "RequestName",
-				request_name_setup,
-				request_name_callback, NULL, NULL);
+	l_dbus_name_acquire(dbus, "org.test", false, false, false,
+				request_name_callback, NULL);
 =

 	if (!l_dbus_register_interface(dbus, "org.test", setup_test_interface,
 					NULL, true)) {
diff --git a/unit/test-kdbus.c b/unit/test-kdbus.c
index dde2596..8cac761 100644
--- a/unit/test-kdbus.c
+++ b/unit/test-kdbus.c
@@ -97,16 +97,20 @@ static void client_ready_callback(void *user_data)
 				NULL, NULL, NULL);
 }
 =

+static void service_name_acquire_callback(struct l_dbus *dbus, bool succes=
s,
+						bool queued, void *user_data)
+{
+	if (!success)
+		l_info("Failed to acquire name");
+}
+
 static void service_ready_callback(void *user_data)
 {
 	struct l_dbus *dbus =3D user_data;
 	struct l_dbus_message *message;
-	int fd =3D _dbus_get_fd(dbus);
-	int r;
 =

-	r =3D _dbus_kernel_name_acquire(fd, "org.test");
-	if (r < 0)
-		l_info("Failed to acquire name: %s", strerror(-r));
+	l_dbus_name_acquire(dbus, "org.test", false, false, false,
+				service_name_acquire_callback, NULL);
 =

 	l_info("service ready");
 =

-- =

2.5.0


--===============4200234812539191890==--

