Content-Type: multipart/mixed; boundary="===============7829541032027044763=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/2] unit: Remove dbus watch tests using old API
Date: Fri, 06 May 2016 12:18:53 +0200
Message-ID: <1462529934-6714-3-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1462529934-6714-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7829541032027044763==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-dbus-watch.c | 226 ---------------------------------------------=
----
 1 file changed, 226 deletions(-)

diff --git a/unit/test-dbus-watch.c b/unit/test-dbus-watch.c
index 46acf06..6b7bcda 100644
--- a/unit/test-dbus-watch.c
+++ b/unit/test-dbus-watch.c
@@ -24,12 +24,8 @@
 #include <config.h>
 #endif
 =

-#include <unistd.h>
 #include <stdlib.h>
-#include <sys/wait.h>
 #include <assert.h>
-#include <time.h>
-#include <stdio.h>
 =

 #include <ell/ell.h>
 #include "ell/dbus-private.h"
@@ -38,213 +34,6 @@
 #define DBUS_SERVICE_DBUS	"org.freedesktop.DBus"
 #define DBUS_PATH_DBUS		"/org/freedesktop/DBus"
 #define DBUS_INTERFACE_DBUS	"org.freedesktop.DBus"
-#define DBUS_MAXIMUM_MATCH_RULE_LENGTH	1024
-
-struct watch_test {
-	const char *name;
-	const char *service;
-	const char *path;
-	const char *interface;
-	const char *method;
-	const char *expected;
-};
-
-static const struct watch_test match_test_1 =3D {
-	.name =3D ":1.101",
-	.service =3D DBUS_SERVICE_DBUS,
-	.path =3D DBUS_PATH_DBUS,
-	.interface =3D DBUS_INTERFACE_DBUS,
-	.method =3D "NameOwnerChanged",
-	.expected =3D "type=3D'signal',"
-		"sender=3D'org.freedesktop.DBus',"
-		"path=3D'/org/freedesktop/DBus',"
-		"interface=3D'org.freedesktop.DBus',"
-		"member=3D'NameOwnerChanged',"
-		"arg0=3D':1.101'",
-};
-
-static const struct watch_test match_test_2 =3D {
-	.name =3D ":1.102",
-	.service =3D NULL,
-	.path =3D DBUS_PATH_DBUS,
-	.interface =3D DBUS_INTERFACE_DBUS,
-	.method =3D "NameOwnerChanged",
-	.expected =3D "type=3D'signal',"
-		"path=3D'/org/freedesktop/DBus',"
-		"interface=3D'org.freedesktop.DBus',"
-		"member=3D'NameOwnerChanged',"
-		"arg0=3D':1.102'",
-};
-
-static const struct watch_test match_test_3 =3D {
-	.name =3D ":1.102",
-	.service =3D DBUS_SERVICE_DBUS,
-	.path =3D NULL,
-	.interface =3D DBUS_INTERFACE_DBUS,
-	.method =3D "NameOwnerChanged",
-	.expected =3D "type=3D'signal',"
-		"sender=3D'org.freedesktop.DBus',"
-		"interface=3D'org.freedesktop.DBus',"
-		"member=3D'NameOwnerChanged',"
-		"arg0=3D':1.102'",
-};
-
-static const struct watch_test match_test_4 =3D {
-	.name =3D ":1.102",
-	.service =3D DBUS_SERVICE_DBUS,
-	.path =3D DBUS_PATH_DBUS,
-	.interface =3D NULL,
-	.method =3D "NameOwnerChanged",
-	.expected =3D "type=3D'signal',"
-		"sender=3D'org.freedesktop.DBus',"
-		"path=3D'/org/freedesktop/DBus',"
-		"member=3D'NameOwnerChanged',"
-		"arg0=3D':1.102'",
-};
-
-static const struct watch_test match_test_5 =3D {
-	.name =3D ":1.102",
-	.service =3D DBUS_SERVICE_DBUS,
-	.path =3D DBUS_PATH_DBUS,
-	.interface =3D DBUS_INTERFACE_DBUS,
-	.method =3D NULL,
-	.expected =3D "type=3D'signal',"
-		"sender=3D'org.freedesktop.DBus',"
-		"path=3D'/org/freedesktop/DBus',"
-		"interface=3D'org.freedesktop.DBus',"
-		"arg0=3D':1.102'",
-};
-
-static const struct watch_test match_test_6 =3D {
-	.name =3D NULL,
-	.service =3D DBUS_SERVICE_DBUS,
-	.path =3D DBUS_PATH_DBUS,
-	.interface =3D DBUS_INTERFACE_DBUS,
-	.method =3D "NameOwnerChanged",
-	.expected =3D "type=3D'signal',"
-		"sender=3D'org.freedesktop.DBus',"
-		"path=3D'/org/freedesktop/DBus',"
-		"interface=3D'org.freedesktop.DBus',"
-		"member=3D'NameOwnerChanged'",
-};
-
-static const struct watch_test match_test_7 =3D {
-	.name =3D ":1.101",
-	.service =3D NULL,
-	.path =3D NULL,
-	.interface =3D DBUS_INTERFACE_DBUS,
-	.method =3D "NameOwnerChanged",
-	.expected =3D "type=3D'signal',"
-		"interface=3D'org.freedesktop.DBus',"
-		"member=3D'NameOwnerChanged',"
-		"arg0=3D':1.101'",
-};
-
-static const struct watch_test match_test_8 =3D {
-	.name =3D ":1.101",
-	.service =3D NULL,
-	.path =3D NULL,
-	.interface =3D NULL,
-	.method =3D "NameOwnerChanged",
-	.expected =3D "type=3D'signal',"
-		"member=3D'NameOwnerChanged',"
-		"arg0=3D':1.101'",
-};
-
-static const struct watch_test match_test_9 =3D {
-	.name =3D NULL,
-	.service =3D NULL,
-	.path =3D NULL,
-	.interface =3D NULL,
-	.method =3D NULL,
-	.expected =3D "type=3D'signal'",
-};
-
-static struct watch_test disconnect_test =3D {
-	.name =3D ":101.1",
-	.service =3D DBUS_SERVICE_DBUS,
-	.path =3D DBUS_PATH_DBUS,
-	.interface =3D DBUS_INTERFACE_DBUS,
-	.method =3D "NameOwnerChanged",
-};
-
-static void test_match(const void *test_data)
-{
-	const struct watch_test *test =3D test_data;
-	struct dbus1_filter_data *data;
-	char rule[DBUS_MAXIMUM_MATCH_RULE_LENGTH];
-
-	data =3D _dbus1_filter_data_get(NULL,
-				NULL,
-				test->service,
-				test->path,
-				test->interface,
-				test->method,
-				test->name,
-				NULL,
-				NULL,
-				NULL);
-
-	_dbus1_filter_format_match(data, rule, sizeof(rule));
-
-	assert(strcmp(rule, test->expected) =3D=3D 0);
-
-	_dbus1_filter_data_destroy(data);
-}
-
-static void disconnect_cb(struct l_dbus *dbus, void *user_data)
-{
-	int *count =3D user_data;
-
-	(*count)++;
-}
-
-static void send_filter_signal(struct dbus1_filter_data *data,
-			const char *name, const char *old, const char *new)
-{
-	struct l_dbus_message *message;
-
-	message =3D _dbus_message_new_signal(2,
-					DBUS_PATH_DBUS,
-					DBUS_INTERFACE_DBUS,
-					"NameOwnerChanged");
-	l_dbus_message_set_arguments(message, "sss", name, old, new);
-	_dbus_message_set_sender(message, DBUS_SERVICE_DBUS);
-	_dbus1_signal_dispatcher(message, data);
-	l_dbus_message_unref(message);
-}
-
-static void test_disconnect_watch(const void *test_data)
-{
-	const struct watch_test *test =3D test_data;
-	struct dbus1_filter_data *data;
-	int count =3D 0;
-
-	data =3D _dbus1_filter_data_get(NULL,
-				_dbus1_name_owner_changed_filter,
-				test->service,
-				test->path,
-				test->interface,
-				test->method,
-				test->name,
-				disconnect_cb,
-				&count,
-				NULL);
-
-	send_filter_signal(data, ":0.1", ":0.1", "");
-	assert(count =3D=3D 0);
-
-	send_filter_signal(data, ":0.1", ":0.1", ":0.2");
-	assert(count =3D=3D 0);
-
-	send_filter_signal(data, ":101.1", ":101.1", ":101.1");
-	assert(count =3D=3D 0);
-
-	send_filter_signal(data, ":101.1", ":101.1", "");
-	assert(count =3D=3D 1);
-
-	_dbus1_filter_data_destroy(data);
-}
 =

 static void test_rule_to_str(const void *test_data)
 {
@@ -494,21 +283,6 @@ int main(int argc, char *argv[])
 {
 	l_test_init(&argc, &argv);
 =

-	l_test_add("DBus filter NameOwnerChanged", test_match, &match_test_1);
-	l_test_add("DBus filter NULL service", test_match, &match_test_2);
-	l_test_add("DBus filter NULL path", test_match, &match_test_3);
-	l_test_add("DBus filter NULL interface", test_match, &match_test_4);
-	l_test_add("DBus filter NULL method", test_match, &match_test_5);
-	l_test_add("DBus filter NULL argument", test_match, &match_test_6);
-	l_test_add("DBus filter NULL service and path", test_match,
-								&match_test_7);
-	l_test_add("DBus filter NULL service, path and interface", test_match,
-								&match_test_8);
-	l_test_add("DBus filter NULL all fields", test_match, &match_test_9);
-
-	l_test_add("DBus disconnect watch", test_disconnect_watch,
-						&disconnect_test);
-
 	l_test_add("_dbus_filter_rule_to_str", test_rule_to_str, NULL);
 =

 	l_test_add("DBus filter tree", test_filter_tree, NULL);
-- =

2.7.4


--===============7829541032027044763==--

