Content-Type: multipart/mixed; boundary="===============1516150076757268437=="
MIME-Version: 1.0
From: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Subject: [PATCH v5 4/4] unit: dbus: Add test for disconnect watch API
Date: Mon, 23 Feb 2015 13:55:00 +0200
Message-ID: <1424692500-21681-5-git-send-email-jukka.rissanen@linux.intel.com>
In-Reply-To: <1424692500-21681-1-git-send-email-jukka.rissanen@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1516150076757268437==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Test the dbus disconnect watch support.
---
 unit/test-dbus-watch.c | 65 ++++++++++++++++++++++++++++++++++++++++++++++=
++++
 1 file changed, 65 insertions(+)

diff --git a/unit/test-dbus-watch.c b/unit/test-dbus-watch.c
index 3868c8f..104f432 100644
--- a/unit/test-dbus-watch.c
+++ b/unit/test-dbus-watch.c
@@ -159,6 +159,14 @@ static const struct watch_test match_test_9 =3D {
 	.expected =3D "type=3D'signal'",
 };
 =

+static struct watch_test disconnect_test =3D {
+	.name =3D ":101.1",
+	.service =3D DBUS_SERVICE_DBUS,
+	.path =3D DBUS_PATH_DBUS,
+	.interface =3D DBUS_INTERFACE_DBUS,
+	.method =3D "NameOwnerChanged",
+};
+
 static void test_match(const void *test_data)
 {
 	const struct watch_test *test =3D test_data;
@@ -183,6 +191,60 @@ static void test_match(const void *test_data)
 	_dbus1_filter_data_destroy(data);
 }
 =

+static void disconnect_cb(struct l_dbus *dbus, void *user_data)
+{
+	int *count =3D user_data;
+
+	(*count)++;
+}
+
+static void send_filter_signal(struct dbus1_filter_data *data,
+			const char *name, const char *old, const char *new)
+{
+	struct l_dbus_message *message;
+
+	message =3D _dbus_message_new_signal(2,
+					DBUS_PATH_DBUS,
+					DBUS_INTERFACE_DBUS,
+					"NameOwnerChanged");
+	l_dbus_message_set_arguments(message, "sss", name, old, new);
+	_dbus_message_set_sender(message, DBUS_SERVICE_DBUS);
+	_dbus1_signal_dispatcher(message, data);
+	l_dbus_message_unref(message);
+}
+
+static void test_disconnect_watch(const void *test_data)
+{
+	const struct watch_test *test =3D test_data;
+	struct dbus1_filter_data *data;
+	int count =3D 0;
+
+	data =3D _dbus1_filter_data_get(NULL,
+				_dbus1_name_owner_changed_filter,
+				test->service,
+				test->path,
+				test->interface,
+				test->method,
+				test->name,
+				disconnect_cb,
+				&count,
+				NULL);
+
+	send_filter_signal(data, ":0.1", ":0.1", "");
+	assert(count =3D=3D 0);
+
+	send_filter_signal(data, ":0.1", ":0.1", ":0.2");
+	assert(count =3D=3D 0);
+
+	send_filter_signal(data, ":101.1", ":101.1", ":101.1");
+	assert(count =3D=3D 0);
+
+	send_filter_signal(data, ":101.1", ":101.1", "");
+	assert(count =3D=3D 1);
+
+	_dbus1_filter_data_destroy(data);
+}
+
 int main(int argc, char *argv[])
 {
 	l_test_init(&argc, &argv);
@@ -199,5 +261,8 @@ int main(int argc, char *argv[])
 								&match_test_8);
 	l_test_add("DBus filter NULL all fields", test_match, &match_test_9);
 =

+	l_test_add("DBus disconnect watch", test_disconnect_watch,
+						&disconnect_test);
+
 	return l_test_run();
 }
-- =

2.1.0


--===============1516150076757268437==--

