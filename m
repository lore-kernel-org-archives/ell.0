Content-Type: multipart/mixed; boundary="===============2397013780567560295=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/2] unit: test a filter tree scenario with unordered paths
Date: Fri, 29 Apr 2016 05:31:54 +0200
Message-ID: <1461900728-20662-2-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1461900728-20662-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2397013780567560295==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Test a scenario in which some paths in the filter tree are not ordered
by the match type.
---
 unit/test-dbus-watch.c | 43 +++++++++++++++++++++++++++++++------------
 1 file changed, 31 insertions(+), 12 deletions(-)

diff --git a/unit/test-dbus-watch.c b/unit/test-dbus-watch.c
index c7e78a5..46acf06 100644
--- a/unit/test-dbus-watch.c
+++ b/unit/test-dbus-watch.c
@@ -289,7 +289,7 @@ struct filter_test_state {
 	const struct _dbus_filter_condition *expected_rule;
 	int expected_rule_len;
 	unsigned int expected_id, new_id;
-	int calls[4];
+	int calls[5];
 };
 =

 static void rule_compare(const struct _dbus_filter_condition *a, int len_a,
@@ -372,6 +372,13 @@ static void test_rule4_cb(struct l_dbus_message *messa=
ge, void *user_data)
 	test->calls[3]++;
 }
 =

+static void test_rule5_cb(struct l_dbus_message *message, void *user_data)
+{
+	struct filter_test_state *test =3D user_data;
+
+	test->calls[4]++;
+}
+
 static void test_filter_tree(const void *test_data)
 {
 	struct _dbus_filter *filter;
@@ -381,7 +388,7 @@ static void test_filter_tree(const void *test_data)
 		.add_match =3D test_add_match,
 		.remove_match =3D test_remove_match,
 	};
-	static struct _dbus_filter_condition rule123[] =3D {
+	static const struct _dbus_filter_condition rule123[] =3D {
 		{ L_DBUS_MATCH_TYPE, "signal" },
 		{ L_DBUS_MATCH_SENDER, DBUS_SERVICE_DBUS },
 		{ L_DBUS_MATCH_PATH, DBUS_PATH_DBUS },
@@ -389,11 +396,12 @@ static void test_filter_tree(const void *test_data)
 		{ L_DBUS_MATCH_MEMBER, "NameOwnerChanged" },
 		{ L_DBUS_MATCH_ARGUMENT(0), "org.test" }
 	};
-	static struct _dbus_filter_condition rule4[] =3D {
+	static const struct _dbus_filter_condition rule45[] =3D {
 		{ L_DBUS_MATCH_TYPE, "signal" },
-		{ L_DBUS_MATCH_SENDER, "foo" },
+		{ L_DBUS_MATCH_PATH, "/" },
+		{ L_DBUS_MATCH_SENDER, "org.foo" },
 	};
-	unsigned int id1, id2, id3, id4, internal_id1, internal_id4;
+	unsigned int id1, id2, id3, id4, id5, internal_id1, internal_id4;
 	struct l_dbus_message *message;
 =

 	filter =3D _dbus_filter_new(&test.dbus, &filter_ops, NULL);
@@ -410,15 +418,19 @@ static void test_filter_tree(const void *test_data)
 	id3 =3D _dbus_filter_add_rule(filter, rule123, 6, test_rule3_cb, &test);
 	assert(id2 && id3 && id2 !=3D id1 && id3 !=3D id1 && id3 !=3D id2);
 =

-	test.expected_rule =3D rule4;
+	test.expected_rule =3D rule45;
 	test.expected_rule_len =3D 2;
-	id4 =3D _dbus_filter_add_rule(filter, rule4, 2, test_rule4_cb, &test);
+	id4 =3D _dbus_filter_add_rule(filter, rule45, 2, test_rule4_cb, &test);
 	assert(id4 && id4 !=3D id1 && id4 !=3D id2 && id4 !=3D id3);
 	assert(!test.expected_rule);
 	internal_id4 =3D test.new_id;
 =

+	id5 =3D _dbus_filter_add_rule(filter, rule45, 3, test_rule5_cb, &test);
+	assert(id5 && id5 !=3D id1 && id5 !=3D id2 && id5 !=3D id3 && id5 !=3D id=
4);
+
 	assert(test.calls[0] =3D=3D 0 && test.calls[1] =3D=3D 0 &&
-			test.calls[2] =3D=3D 0 && test.calls[3] =3D=3D 0);
+			test.calls[2] =3D=3D 0 && test.calls[3] =3D=3D 0 &&
+			test.calls[4] =3D=3D 0);
 =

 	message =3D _dbus_message_new_signal(2, DBUS_PATH_DBUS,
 						DBUS_INTERFACE_DBUS,
@@ -441,22 +453,28 @@ static void test_filter_tree(const void *test_data)
 	l_dbus_message_set_arguments(message, "");
 	_dbus_message_set_sender(message, DBUS_SERVICE_DBUS);
 	_dbus_filter_dispatch(message, filter);
+	l_dbus_message_unref(message);
 =

-	_dbus_message_set_sender(message, "foo");
+	message =3D _dbus_message_new_signal(2, "/", "foo", "Bar");
+	l_dbus_message_set_arguments(message, "");
+	_dbus_message_set_sender(message, "org.foo");
 	_dbus_filter_dispatch(message, filter);
 =

-	_dbus_message_set_sender(message, "bar");
+	_dbus_message_set_sender(message, "org.bar");
 	_dbus_filter_dispatch(message, filter);
 	l_dbus_message_unref(message);
 =

 	assert(test.calls[0] =3D=3D 3 && test.calls[1] =3D=3D 2 &&
-			test.calls[2] =3D=3D 1 && test.calls[3] =3D=3D 1);
+			test.calls[2] =3D=3D 1 && test.calls[3] =3D=3D 2 &&
+			test.calls[4] =3D=3D 1);
 =

 	test.expected_id =3D 0;
 	assert(_dbus_filter_remove_rule(filter, id2));
 =

 	assert(_dbus_filter_remove_rule(filter, id1));
 =

+	assert(_dbus_filter_remove_rule(filter, id5));
+
 	test.expected_id =3D internal_id4;
 	assert(_dbus_filter_remove_rule(filter, id4));
 	assert(!test.expected_id);
@@ -468,7 +486,8 @@ static void test_filter_tree(const void *test_data)
 	_dbus_filter_free(filter);
 =

 	assert(test.calls[0] =3D=3D 3 && test.calls[1] =3D=3D 2 &&
-			test.calls[2] =3D=3D 1 && test.calls[3] =3D=3D 1);
+			test.calls[2] =3D=3D 1 && test.calls[3] =3D=3D 2 &&
+			test.calls[4] =3D=3D 1);
 }
 =

 int main(int argc, char *argv[])
-- =

2.5.0


--===============2397013780567560295==--

