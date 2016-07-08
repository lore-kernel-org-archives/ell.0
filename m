Content-Type: multipart/mixed; boundary="===============1562598218024189592=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 3/3] unit: Update the uses of dbus property setter api
Date: Fri, 08 Jul 2016 17:55:18 +0200
Message-ID: <1467993318-11918-3-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1467993318-11918-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1562598218024189592==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-dbus-properties.c | 53 +++++++++++++++++++++++++++--------------=
----
 unit/test-dbus-service.c    |  3 ++-
 2 files changed, 34 insertions(+), 22 deletions(-)

diff --git a/unit/test-dbus-properties.c b/unit/test-dbus-properties.c
index b11d1d5..08916b3 100644
--- a/unit/test-dbus-properties.c
+++ b/unit/test-dbus-properties.c
@@ -220,20 +220,26 @@ static bool test_string_getter(struct l_dbus *dbus,
 static bool setter_called;
 static bool int_optional;
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
 =

-	test_assert(l_dbus_message_iter_get_variant(new_value, "s", &strvalue));
-	test_assert(!strcmp(strvalue, "bar"));
+	if (!l_dbus_message_iter_get_variant(new_value, "s", &strvalue))
+		goto done;
+
+	if (strcmp(strvalue, "bar"))
+		goto done;
 =

 	setter_called =3D true;
 =

+done:
 	complete(dbus, message, NULL);
+
+	return NULL;
 }
 =

 static bool test_int_getter(struct l_dbus *dbus,
@@ -251,32 +257,37 @@ static bool test_int_getter(struct l_dbus *dbus,
 	return l_dbus_message_builder_append_basic(builder, 'u', &u);
 }
 =

-static void test_int_setter(struct l_dbus *dbus,
-				struct l_dbus_message *message,
-				struct l_dbus_message_iter *new_value,
-				l_dbus_property_complete_cb_t complete,
-				void *user_data)
+static struct l_dbus_message *test_int_setter(struct l_dbus *dbus,
+					struct l_dbus_message *message,
+					struct l_dbus_message_iter *new_value,
+					l_dbus_property_complete_cb_t complete,
+					void *user_data)
 {
 	uint32_t u;
 =

-	test_assert(l_dbus_message_iter_get_variant(new_value, "u", &u));
-	test_assert(u =3D=3D 42);
+	if (!l_dbus_message_iter_get_variant(new_value, "u", &u))
+		goto done;
+
+	if (u !=3D 42)
+		goto done;
 =

 	setter_called =3D true;
 =

+done:
 	complete(dbus, message, NULL);
+
+	return NULL;
 }
 =

-static void test_error_setter(struct l_dbus *dbus,
-				struct l_dbus_message *message,
-				struct l_dbus_message_iter *new_value,
-				l_dbus_property_complete_cb_t complete,
-				void *user_data)
+static struct l_dbus_message *test_error_setter(struct l_dbus *dbus,
+					struct l_dbus_message *message,
+					struct l_dbus_message_iter *new_value,
+					l_dbus_property_complete_cb_t complete,
+					void *user_data)
 {
 	setter_called =3D true;
 =

-	complete(dbus, message, l_dbus_message_new_error(message,
-						"org.test.Error", "Error"));
+	return l_dbus_message_new_error(message, "org.test.Error", "Error");
 }
 =

 static bool test_path_getter(struct l_dbus *dbus,
diff --git a/unit/test-dbus-service.c b/unit/test-dbus-service.c
index 8a395b1..c27869b 100644
--- a/unit/test-dbus-service.c
+++ b/unit/test-dbus-service.c
@@ -399,12 +399,13 @@ static bool test_property_getter(struct l_dbus *dbus,
 	return true;
 }
 =

-static void test_property_setter(struct l_dbus *dbus,
+static struct l_dbus_message *test_property_setter(struct l_dbus *dbus,
 					struct l_dbus_message *message,
 					struct l_dbus_message_iter *new_value,
 					l_dbus_property_complete_cb_t complete,
 					void *user_data)
 {
+	return NULL;
 }
 =

 int main(int argc, char *argv[])
-- =

2.7.4


--===============1562598218024189592==--

