Content-Type: multipart/mixed; boundary="===============2802962405526535012=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH] unit: Clean up leaks in test-dbus-watch
Date: Wed, 12 Jul 2017 12:49:34 -0700
Message-ID: <20170712194934.23933-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2802962405526535012==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Use of the internal _dbus_message_set_sender() function in
test-dbus-watch resulted in message structures that were not completely
freed, which caused error reports when ELL was configured with
--enable-asan. Manually clearing the message sender resolves the
problem.
---
 unit/test-dbus-watch.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/unit/test-dbus-watch.c b/unit/test-dbus-watch.c
index 6b7bcda..c6e4a92 100644
--- a/unit/test-dbus-watch.c
+++ b/unit/test-dbus-watch.c
@@ -228,6 +228,7 @@ static void test_filter_tree(const void *test_data)
 					"", ":1.101");
 	_dbus_message_set_sender(message, DBUS_SERVICE_DBUS);
 	_dbus_filter_dispatch(message, filter);
+	_dbus_message_set_sender(message, NULL);
 	l_dbus_message_unref(message);
 =

 	message =3D _dbus_message_new_signal(2, DBUS_PATH_DBUS,
@@ -236,12 +237,14 @@ static void test_filter_tree(const void *test_data)
 	l_dbus_message_set_arguments(message, "");
 	_dbus_message_set_sender(message, DBUS_SERVICE_DBUS);
 	_dbus_filter_dispatch(message, filter);
+	_dbus_message_set_sender(message, NULL);
 	l_dbus_message_unref(message);
 =

 	message =3D _dbus_message_new_signal(2, DBUS_PATH_DBUS, "foo", "Bar");
 	l_dbus_message_set_arguments(message, "");
 	_dbus_message_set_sender(message, DBUS_SERVICE_DBUS);
 	_dbus_filter_dispatch(message, filter);
+	_dbus_message_set_sender(message, NULL);
 	l_dbus_message_unref(message);
 =

 	message =3D _dbus_message_new_signal(2, "/", "foo", "Bar");
@@ -251,6 +254,7 @@ static void test_filter_tree(const void *test_data)
 =

 	_dbus_message_set_sender(message, "org.bar");
 	_dbus_filter_dispatch(message, filter);
+	_dbus_message_set_sender(message, NULL);
 	l_dbus_message_unref(message);
 =

 	assert(test.calls[0] =3D=3D 3 && test.calls[1] =3D=3D 2 &&
-- =

2.13.2


--===============2802962405526535012==--

