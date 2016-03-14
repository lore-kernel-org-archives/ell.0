Content-Type: multipart/mixed; boundary="===============4530341888028266518=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 13/20] unit: Use the message filter API in dbus tests.
Date: Mon, 14 Mar 2016 04:41:29 +0100
Message-ID: <1457926896-9843-13-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1457926896-9843-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4530341888028266518==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-dbus-properties.c | 142 +++++++++++++++++++++-------------------=
----
 unit/test-kdbus.c           |   3 +-
 2 files changed, 69 insertions(+), 76 deletions(-)

diff --git a/unit/test-dbus-properties.c b/unit/test-dbus-properties.c
index f1aa406..be91dd3 100644
--- a/unit/test-dbus-properties.c
+++ b/unit/test-dbus-properties.c
@@ -665,56 +665,10 @@ static void signal_timeout_callback(struct l_timeout =
*timeout, void *user_data)
 static bool old_signal_received, new_signal_received;
 static bool signal_success;
 =

-static void test_signal_callback(struct l_dbus_message *message)
+static void test_check_signal_success(void)
 {
-	const char *interface, *member, *property, *value;
-	struct l_dbus_message_iter variant, changed, invalidated;
 	struct l_dbus_message *call;
 =

-	if (!signal_timeout)
-		return;
-
-	interface =3D l_dbus_message_get_interface(message);
-	member =3D l_dbus_message_get_member(message);
-
-	if (!strcmp(interface, "org.test") &&
-			!strcmp(member, "PropertyChanged")) {
-		test_assert(l_dbus_message_get_arguments(message, "sv",
-								&property,
-								&variant));
-		test_assert(!strcmp(property, "String"));
-		test_assert(l_dbus_message_iter_get_variant(&variant, "s",
-								&value));
-		test_assert(!strcmp(value, "foo"));
-
-		test_assert(!old_signal_received);
-		old_signal_received =3D true;
-	}
-
-	if (!strcmp(interface, "org.freedesktop.DBus.Properties") &&
-			!strcmp(member, "PropertiesChanged")) {
-		test_assert(l_dbus_message_get_arguments(message, "sa{sv}as",
-								&interface,
-								&changed,
-								&invalidated));
-		test_assert(!strcmp(interface, "org.test"));
-
-		test_assert(l_dbus_message_iter_next_entry(&changed, &property,
-								&variant));
-		test_assert(!strcmp(property, "String"));
-		test_assert(l_dbus_message_iter_get_variant(&variant, "s",
-								&value));
-		test_assert(!strcmp(value, "foo"));
-
-		test_assert(!l_dbus_message_iter_next_entry(&changed, &property,
-								&variant));
-		test_assert(!l_dbus_message_iter_next_entry(&invalidated,
-								&property));
-
-		test_assert(!new_signal_received);
-		new_signal_received =3D true;
-	}
-
 	if (!old_signal_received || !new_signal_received)
 		return;
 =

@@ -751,6 +705,57 @@ static void test_signal_callback(struct l_dbus_message=
 *message)
 	}
 }
 =

+static void test_old_signal_callback(struct l_dbus_message *message,
+					void *user_data)
+{
+	const char *property, *value;
+	struct l_dbus_message_iter variant;
+
+	if (!signal_timeout)
+		return;
+
+	test_assert(l_dbus_message_get_arguments(message, "sv",
+							&property, &variant));
+	test_assert(!strcmp(property, "String"));
+	test_assert(l_dbus_message_iter_get_variant(&variant, "s", &value));
+	test_assert(!strcmp(value, "foo"));
+
+	test_assert(!old_signal_received);
+	old_signal_received =3D true;
+
+	test_check_signal_success();
+}
+
+static void test_new_signal_callback(struct l_dbus_message *message,
+					void *user_data)
+{
+	const char *interface, *property, *value;
+	struct l_dbus_message_iter variant, changed, invalidated;
+
+	if (!signal_timeout)
+		return;
+
+	test_assert(l_dbus_message_get_arguments(message, "sa{sv}as",
+							&interface, &changed,
+							&invalidated));
+
+	test_assert(l_dbus_message_iter_next_entry(&changed, &property,
+							&variant));
+	test_assert(!strcmp(property, "String"));
+	test_assert(l_dbus_message_iter_get_variant(&variant, "s", &value));
+	test_assert(!strcmp(value, "foo"));
+
+	test_assert(!l_dbus_message_iter_next_entry(&changed, &property,
+							&variant));
+	test_assert(!l_dbus_message_iter_next_entry(&invalidated,
+							&property));
+
+	test_assert(!new_signal_received);
+	new_signal_received =3D true;
+
+	test_check_signal_success();
+}
+
 static void test_property_signals(struct l_dbus *dbus, void *test_data)
 {
 	old_signal_received =3D false;
@@ -837,7 +842,7 @@ static void om_signal_timeout_callback(struct l_timeout=
 *timeout,
 =

 static bool expect_interfaces_added;
 =

-static void root_signal_callback(struct l_dbus_message *message)
+static void om_signal_callback(struct l_dbus_message *message, void *user_=
data)
 {
 	const char *path, *interface, *member;
 	struct l_dbus_message_iter interfaces, properties;
@@ -845,12 +850,8 @@ static void root_signal_callback(struct l_dbus_message=
 *message)
 	if (!om_signal_timeout)
 		return;
 =

-	interface =3D l_dbus_message_get_interface(message);
 	member =3D l_dbus_message_get_member(message);
 =

-	if (strcmp(interface, "org.freedesktop.DBus.ObjectManager"))
-		return;
-
 	if (!strcmp(member, "InterfacesAdded"))
 		test_assert(expect_interfaces_added);
 	else if (!strcmp(member, "InterfacesRemoved"))
@@ -909,25 +910,11 @@ static void test_object_manager_signals(struct l_dbus=
 *dbus, void *test_data)
 						NULL));
 }
 =

-static void signal_message(struct l_dbus_message *message, void *user_data)
-{
-	const char *path;
-
-	path =3D l_dbus_message_get_path(message);
-
-	if (!strcmp(path, "/test"))
-		test_signal_callback(message);
-
-	if (!strcmp(path, "/"))
-		root_signal_callback(message);
-}
-
 int main(int argc, char *argv[])
 {
 	struct l_signal *signal;
 	sigset_t mask;
 	int i;
-	struct l_dbus_message *call;
 =

 	sigemptyset(&mask);
 	sigaddset(&mask, SIGINT);
@@ -951,15 +938,6 @@ int main(int argc, char *argv[])
 	l_dbus_set_ready_handler(dbus, ready_callback, dbus, NULL);
 	l_dbus_set_disconnect_handler(dbus, disconnect_callback, NULL, NULL);
 =

-	l_dbus_register(dbus, signal_message, NULL, NULL);
-
-	call =3D l_dbus_message_new_method_call(dbus, "org.freedesktop.DBus",
-						"/org/freedesktop/DBus",
-						"org.freedesktop.DBus",
-						"AddMatch");
-	l_dbus_message_set_arguments(call, "s", "type=3Dsignal,sender=3Dorg.test"=
);
-	l_dbus_send(dbus, call);
-
 	l_dbus_method_call(dbus, "org.freedesktop.DBus",
 				"/org/freedesktop/DBus",
 				"org.freedesktop.DBus", "RequestName",
@@ -983,11 +961,25 @@ int main(int argc, char *argv[])
 		goto done;
 	}
 =

+	l_dbus_add_signal_watch(dbus, "org.test", "/test", "org.test",
+				"PropertyChanged", L_DBUS_MATCH_NONE,
+				test_old_signal_callback, NULL);
+	l_dbus_add_signal_watch(dbus, "org.test", "/test",
+				"org.freedesktop.DBus.Properties",
+				"PropertiesChanged", L_DBUS_MATCH_ARGUMENT(0),
+				"org.test", L_DBUS_MATCH_NONE,
+				test_new_signal_callback, NULL);
+
 	if (!l_dbus_object_manager_enable(dbus)) {
 		l_info("Unable to enable Object Manager");
 		goto done;
 	}
 =

+	l_dbus_add_signal_watch(dbus, "org.test", "/",
+				"org.freedesktop.DBus.ObjectManager",
+				NULL, L_DBUS_MATCH_NONE,
+				om_signal_callback, NULL);
+
 	test_add("Legacy properties get", test_old_get, NULL);
 	test_add("Legacy properties set", test_old_set, NULL);
 	test_add("Legacy optional property", test_old_optional_get, NULL);
diff --git a/unit/test-kdbus.c b/unit/test-kdbus.c
index 3a6af3e..dde2596 100644
--- a/unit/test-kdbus.c
+++ b/unit/test-kdbus.c
@@ -174,7 +174,8 @@ int main(int argc, char *argv[])
 =

 	l_dbus_set_debug(client, do_debug, "[CLIENT] ", NULL);
 	l_dbus_set_ready_handler(client, client_ready_callback, client, NULL);
-	l_dbus_register(client, signal_message, NULL, NULL);
+	l_dbus_add_signal_watch(client, "org.test", NULL, NULL, NULL,
+				L_DBUS_MATCH_NONE, signal_message, NULL);
 =

 	l_main_run();
 =

-- =

2.5.0


--===============4530341888028266518==--

