Content-Type: multipart/mixed; boundary="===============5042634837251832058=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/3] examples: Update dbus-service example use of setter api
Date: Fri, 08 Jul 2016 17:55:17 +0200
Message-ID: <1467993318-11918-2-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1467993318-11918-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5042634837251832058==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 examples/dbus-service.c | 36 ++++++++++++++++++------------------
 1 file changed, 18 insertions(+), 18 deletions(-)

diff --git a/examples/dbus-service.c b/examples/dbus-service.c
index 19b17a0..2a53ab8 100644
--- a/examples/dbus-service.c
+++ b/examples/dbus-service.c
@@ -106,27 +106,27 @@ static bool test_string_getter(struct l_dbus *dbus,
 	return true;
 }
 =

-static void test_string_setter(struct l_dbus *dbus,
-				struct l_dbus_message *message,
-				struct l_dbus_message_iter *new_value,
-				l_dbus_property_complete_cb_t complete,
-				void *user_data)
+static struct l_dbus_message *test_string_setter(struct l_dbus *dbus,
+					struct l_dbus_message *message,
+					struct l_dbus_message_iter *new_value,
+					l_dbus_property_complete_cb_t complete,
+					void *user_data)
 {
 	const char *strvalue;
 	struct test_data *test =3D user_data;
 =

-	if (!l_dbus_message_iter_get_variant(new_value, "s", &strvalue)) {
-		complete(dbus, message, l_dbus_message_new_error(message,
-					"org.test.InvalidArguments",
-					"String value expected"));
-		return;
-	}
+	if (!l_dbus_message_iter_get_variant(new_value, "s", &strvalue))
+		return l_dbus_message_new_error(message,
+						"org.test.InvalidArguments",
+						"String value expected");
 =

 	l_info("New String value: %s", strvalue);
 	l_free(test->string);
 	test->string =3D l_strdup(strvalue);
 =

 	complete(dbus, message, NULL);
+
+	return NULL;
 }
 =

 static bool test_int_getter(struct l_dbus *dbus,
@@ -141,7 +141,7 @@ static bool test_int_getter(struct l_dbus *dbus,
 	return true;
 }
 =

-static void test_int_setter(struct l_dbus *dbus,
+static struct l_dbus_message *test_int_setter(struct l_dbus *dbus,
 				struct l_dbus_message *message,
 				struct l_dbus_message_iter *new_value,
 				l_dbus_property_complete_cb_t complete,
@@ -150,17 +150,17 @@ static void test_int_setter(struct l_dbus *dbus,
 	uint32_t u;
 	struct test_data *test =3D user_data;
 =

-	if (!l_dbus_message_iter_get_variant(new_value, "u", &u)) {
-		complete(dbus, message, l_dbus_message_new_error(message,
-					"org.test.InvalidArguments",
-					"Integer value expected"));
-		return;
-	}
+	if (!l_dbus_message_iter_get_variant(new_value, "u", &u))
+		return l_dbus_message_new_error(message,
+						"org.test.InvalidArguments",
+						"Integer value expected");
 =

 	l_info("New Integer value: %u", u);
 	test->integer =3D u;
 =

 	complete(dbus, message, NULL);
+
+	return NULL;
 }
 =

 static void setup_test_interface(struct l_dbus_interface *interface)
-- =

2.7.4


--===============5042634837251832058==--

