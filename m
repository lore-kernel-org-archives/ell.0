Content-Type: multipart/mixed; boundary="===============8300187753124276858=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 3/5] unit: Update _dbus_filter usage in test-dbus-watch
Date: Mon, 18 Apr 2016 16:31:15 +0200
Message-ID: <1460989877-20113-8-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1460989877-20113-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8300187753124276858==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Also fix what seems to be incorrect use of l_dbus_message_set_arguments
---
 unit/test-dbus-watch.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/unit/test-dbus-watch.c b/unit/test-dbus-watch.c
index 684ac34..1d8f94c 100644
--- a/unit/test-dbus-watch.c
+++ b/unit/test-dbus-watch.c
@@ -387,7 +387,7 @@ static void test_filter_tree(const void *test_data)
 		{ L_DBUS_MATCH_PATH, DBUS_PATH_DBUS },
 		{ L_DBUS_MATCH_INTERFACE, DBUS_INTERFACE_DBUS },
 		{ L_DBUS_MATCH_MEMBER, "NameOwnerChanged" },
-		{ L_DBUS_MATCH_ARGUMENT(0), ":1.101" }
+		{ L_DBUS_MATCH_ARGUMENT(0), "org.test" }
 	};
 	static struct _dbus_filter_condition rule4[] =3D {
 		{ L_DBUS_MATCH_TYPE, "signal" },
@@ -396,7 +396,7 @@ static void test_filter_tree(const void *test_data)
 	unsigned int id1, id2, id3, id4, internal_id1, internal_id4;
 	struct l_dbus_message *message;
 =

-	filter =3D _dbus_filter_new(&test.dbus, &filter_ops);
+	filter =3D _dbus_filter_new(&test.dbus, &filter_ops, NULL);
 	assert(filter);
 =

 	test.expected_rule =3D rule123;
@@ -423,7 +423,8 @@ static void test_filter_tree(const void *test_data)
 	message =3D _dbus_message_new_signal(2, DBUS_PATH_DBUS,
 						DBUS_INTERFACE_DBUS,
 						"NameOwnerChanged");
-	l_dbus_message_set_arguments(message, "sss", ":1.101", "", ":1.101");
+	l_dbus_message_set_arguments(message, "sss", "org.test",
+					":1.101", "", ":1.101");
 	_dbus_message_set_sender(message, DBUS_SERVICE_DBUS);
 	_dbus_filter_dispatch(message, filter);
 	l_dbus_message_unref(message);
-- =

2.5.0


--===============8300187753124276858==--

