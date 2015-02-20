Content-Type: multipart/mixed; boundary="===============3758470831145131702=="
MIME-Version: 1.0
From: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Subject: [PATCH v4 6/6] unit: dbus: Add test for disconnect watch API
Date: Fri, 20 Feb 2015 14:16:41 +0200
Message-ID: <1424434601-2211-7-git-send-email-jukka.rissanen@linux.intel.com>
In-Reply-To: <1424434601-2211-1-git-send-email-jukka.rissanen@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3758470831145131702==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Test the dbus disconnect watch support.
---
 unit/test-dbus-watch.c | 57 ++++++++++++++++++++++++++++++++++++++++++++++=
++++
 1 file changed, 57 insertions(+)

diff --git a/unit/test-dbus-watch.c b/unit/test-dbus-watch.c
index e1d3f9d..1eeb6ea 100644
--- a/unit/test-dbus-watch.c
+++ b/unit/test-dbus-watch.c
@@ -67,6 +67,10 @@ static const struct watch_test match_test =3D {
 		"arg0=3D':1.101'",
 };
 =

+static struct watch_test disconnect_test =3D {
+	.name =3D ":101.1",
+};
+
 static void setup_data(struct dbus_filter_data *data, const char *name)
 {
 	data->sender =3D l_strdup(DBUS_SERVICE_DBUS);
@@ -99,11 +103,64 @@ static void test_match(const void *test_data)
 	clean_data(&data);
 }
 =

+static void disconnect_cb(struct l_dbus *dbus, void *user_data)
+{
+	int *count =3D user_data;
+
+	(*count)++;
+}
+
+static void send_filter_signal(struct dbus_filter_data *data,
+			const char *name, const char *old, const char *new)
+{
+	struct l_dbus_message *message;
+
+	message =3D _dbus_message_new_signal(2, DBUS_PATH_DBUS,
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
+	struct dbus_filter_data *data;
+	int count =3D 0;
+
+	data =3D _dbus1_filter_data_get(NULL, _dbus1_name_owner_changed_filter,
+				DBUS_SERVICE_DBUS, DBUS_PATH_DBUS,
+				DBUS_INTERFACE_DBUS, "NameOwnerChanged",
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
 =

 	l_test_add("DBus filter", test_match, &match_test);
 =

+	l_test_add("DBus disconnect watch", test_disconnect_watch,
+						&disconnect_test);
+
 	return l_test_run();
 }
-- =

2.1.0


--===============3758470831145131702==--

