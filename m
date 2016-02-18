Content-Type: multipart/mixed; boundary="===============8387475504322836150=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 5/5] unit: Update PropertyChanged value check.
Date: Thu, 18 Feb 2016 04:20:12 +0100
Message-ID: <1455765612-6577-5-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1455765612-6577-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8387475504322836150==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Don't expect that the value given in the PropertyChanged events is that
taken from the Set or SetProperty call, it's now the value returned by
the getter after the operation which seems more correct too although
in real life they should be the same.
---
 unit/test-dbus-properties.c | 14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

diff --git a/unit/test-dbus-properties.c b/unit/test-dbus-properties.c
index 73172c5..cc9efa3 100644
--- a/unit/test-dbus-properties.c
+++ b/unit/test-dbus-properties.c
@@ -624,7 +624,7 @@ static void signal_timeout_callback(struct l_timeout *t=
imeout, void *user_data)
 }
 =

 static bool old_signal_received, new_signal_received;
-static const char *signal_string_value;
+static bool signal_success;
 =

 static void test_signal_callback(struct l_dbus_message *message)
 {
@@ -646,7 +646,7 @@ static void test_signal_callback(struct l_dbus_message =
*message)
 		test_assert(!strcmp(property, "String"));
 		test_assert(l_dbus_message_iter_get_variant(&variant, "s",
 								&value));
-		test_assert(!strcmp(value, signal_string_value));
+		test_assert(!strcmp(value, "foo"));
 =

 		test_assert(!old_signal_received);
 		old_signal_received =3D true;
@@ -665,7 +665,7 @@ static void test_signal_callback(struct l_dbus_message =
*message)
 		test_assert(!strcmp(property, "String"));
 		test_assert(l_dbus_message_iter_get_variant(&variant, "s",
 								&value));
-		test_assert(!strcmp(value, signal_string_value));
+		test_assert(!strcmp(value, "foo"));
 =

 		test_assert(!l_dbus_message_iter_next_entry(&changed, &property,
 								&variant));
@@ -682,7 +682,9 @@ static void test_signal_callback(struct l_dbus_message =
*message)
 	l_timeout_remove(signal_timeout);
 	signal_timeout =3D NULL;
 =

-	if (!strcmp(signal_string_value, "foo")) {
+	if (!signal_success) {
+		signal_success =3D true;
+
 		/* Now repeat the test for the signal triggered by Set */
 =

 		old_signal_received =3D false;
@@ -692,8 +694,6 @@ static void test_signal_callback(struct l_dbus_message =
*message)
 							NULL, NULL);
 		test_assert(signal_timeout);
 =

-		signal_string_value =3D "bar";
-
 		call =3D l_dbus_message_new_method_call(dbus, "org.test", "/test",
 					"org.freedesktop.DBus.Properties",
 					"Set");
@@ -721,8 +721,6 @@ static void test_property_signals(struct l_dbus *dbus, =
void *test_data)
 						NULL, NULL);
 	test_assert(signal_timeout);
 =

-	signal_string_value =3D "foo";
-
 	test_assert(l_dbus_property_changed(dbus, "/test",
 						"org.test", "String"));
 }
-- =

2.5.0


--===============8387475504322836150==--

