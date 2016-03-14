Content-Type: multipart/mixed; boundary="===============3549006975720511549=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 06/20] unit: Add dbus message filter tests.
Date: Mon, 14 Mar 2016 04:41:22 +0100
Message-ID: <1457926896-9843-6-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1457926896-9843-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3549006975720511549==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-dbus-watch.c | 230 +++++++++++++++++++++++++++++++++++++++++++++=
++++
 1 file changed, 230 insertions(+)

diff --git a/unit/test-dbus-watch.c b/unit/test-dbus-watch.c
index 104f432..dce7c4b 100644
--- a/unit/test-dbus-watch.c
+++ b/unit/test-dbus-watch.c
@@ -33,6 +33,7 @@
 =

 #include <ell/ell.h>
 #include "ell/dbus-private.h"
+#include "ell/private.h"
 =

 #define DBUS_SERVICE_DBUS	"org.freedesktop.DBus"
 #define DBUS_PATH_DBUS		"/org/freedesktop/DBus"
@@ -245,6 +246,231 @@ static void test_disconnect_watch(const void *test_da=
ta)
 	_dbus1_filter_data_destroy(data);
 }
 =

+static void test_rule_to_str(const void *test_data)
+{
+	static const struct _dbus_filter_condition rule1[] =3D {
+		{ L_DBUS_MATCH_TYPE, "signal" },
+		{ L_DBUS_MATCH_SENDER, DBUS_SERVICE_DBUS },
+		{ L_DBUS_MATCH_PATH, DBUS_PATH_DBUS },
+		{ L_DBUS_MATCH_INTERFACE, DBUS_INTERFACE_DBUS },
+		{ L_DBUS_MATCH_MEMBER, "NameOwnerChanged" },
+		{ L_DBUS_MATCH_ARGUMENT(0), ":1.101" }
+	};
+	static const char *expected1 =3D "type=3D'signal',"
+		"sender=3D'org.freedesktop.DBus',"
+		"path=3D'/org/freedesktop/DBus',"
+		"interface=3D'org.freedesktop.DBus',"
+		"member=3D'NameOwnerChanged',"
+		"arg0=3D':1.101'";
+	static const struct _dbus_filter_condition rule2[] =3D {
+		{ L_DBUS_MATCH_ARGUMENT(0), "'" },
+		{ L_DBUS_MATCH_ARGUMENT(1), "\\" },
+		{ L_DBUS_MATCH_ARGUMENT(2), "," },
+		{ L_DBUS_MATCH_ARGUMENT(3), "\\\\" }
+	};
+	static const char *expected2 =3D
+		"arg0=3D''\\''',arg1=3D'\\',arg2=3D',',arg3=3D'\\\\'";
+	char *str;
+
+	str =3D _dbus_filter_rule_to_str(rule1, L_ARRAY_SIZE(rule1));
+	assert(str && !strcmp(str, expected1));
+	l_free(str);
+
+	str =3D _dbus_filter_rule_to_str(rule2, L_ARRAY_SIZE(rule2));
+	assert(str && !strcmp(str, expected2));
+	l_free(str);
+}
+
+struct l_dbus {
+};
+
+struct filter_test_state {
+	struct l_dbus dbus;
+	const struct _dbus_filter_condition *expected_rule;
+	int expected_rule_len;
+	unsigned int expected_id, new_id;
+	int calls[4];
+};
+
+static void rule_compare(const struct _dbus_filter_condition *a, int len_a,
+			const struct _dbus_filter_condition *b, int len_b)
+{
+	int i, j;
+	bool matched[len_a];
+
+	assert(len_a =3D=3D len_b);
+
+	for (i =3D 0; i < len_a; i++)
+		matched[i] =3D false;
+
+	for (i =3D 0; i < len_a; i++) {
+		for (j =3D 0; j < len_a; j++)
+			if (!matched[j] && a[i].type =3D=3D b[j].type &&
+					!strcmp(a[i].value, b[j].value))
+				break;
+
+		assert(j < len_a);
+		matched[j] =3D true;
+	}
+}
+
+static bool test_add_match(struct l_dbus *dbus, unsigned int id,
+				const struct _dbus_filter_condition *rule,
+				int rule_len)
+{
+	struct filter_test_state *test =3D
+		container_of(dbus, struct filter_test_state, dbus);
+
+	assert(test->expected_rule);
+
+	rule_compare(test->expected_rule, test->expected_rule_len,
+			rule, rule_len);
+
+	test->new_id =3D id;
+	test->expected_rule =3D NULL;
+
+	return true;
+}
+
+static bool test_remove_match(struct l_dbus *dbus, unsigned int id)
+{
+	struct filter_test_state *test =3D
+		container_of(dbus, struct filter_test_state, dbus);
+
+	assert(test->expected_id =3D=3D id && id);
+
+	test->expected_id =3D 0;
+
+	return true;
+}
+
+static void test_rule1_cb(struct l_dbus_message *message, void *user_data)
+{
+	struct filter_test_state *test =3D user_data;
+
+	test->calls[0]++;
+}
+
+static void test_rule2_cb(struct l_dbus_message *message, void *user_data)
+{
+	struct filter_test_state *test =3D user_data;
+
+	test->calls[1]++;
+}
+
+static void test_rule3_cb(struct l_dbus_message *message, void *user_data)
+{
+	struct filter_test_state *test =3D user_data;
+
+	test->calls[2]++;
+}
+
+static void test_rule4_cb(struct l_dbus_message *message, void *user_data)
+{
+	struct filter_test_state *test =3D user_data;
+
+	test->calls[3]++;
+}
+
+static void test_filter_tree(const void *test_data)
+{
+	struct _dbus_filter *filter;
+	struct filter_test_state test =3D { .calls =3D { 0, 0, 0, 0 } };
+	static const struct _dbus_filter_ops filter_ops =3D {
+		.track_name_owner_change =3D false,
+		.skip_register =3D true,
+		.add_match =3D test_add_match,
+		.remove_match =3D test_remove_match,
+	};
+	static struct _dbus_filter_condition rule123[] =3D {
+		{ L_DBUS_MATCH_TYPE, "signal" },
+		{ L_DBUS_MATCH_SENDER, DBUS_SERVICE_DBUS },
+		{ L_DBUS_MATCH_PATH, DBUS_PATH_DBUS },
+		{ L_DBUS_MATCH_INTERFACE, DBUS_INTERFACE_DBUS },
+		{ L_DBUS_MATCH_MEMBER, "NameOwnerChanged" },
+		{ L_DBUS_MATCH_ARGUMENT(0), ":1.101" }
+	};
+	static struct _dbus_filter_condition rule4[] =3D {
+		{ L_DBUS_MATCH_TYPE, "signal" },
+		{ L_DBUS_MATCH_SENDER, "foo" },
+	};
+	unsigned int id1, id2, id3, id4, internal_id1, internal_id4;
+	struct l_dbus_message *message;
+
+	filter =3D _dbus_filter_new(&test.dbus, &filter_ops);
+	assert(filter);
+
+	test.expected_rule =3D rule123;
+	test.expected_rule_len =3D 2;
+	id1 =3D _dbus_filter_add_rule(filter, rule123, 2, test_rule1_cb, &test);
+	assert(id1);
+	assert(!test.expected_rule);
+	internal_id1 =3D test.new_id;
+
+	id2 =3D _dbus_filter_add_rule(filter, rule123, 4, test_rule2_cb, &test);
+	id3 =3D _dbus_filter_add_rule(filter, rule123, 6, test_rule3_cb, &test);
+	assert(id2 && id3 && id2 !=3D id1 && id3 !=3D id1 && id3 !=3D id2);
+
+	test.expected_rule =3D rule4;
+	test.expected_rule_len =3D 2;
+	id4 =3D _dbus_filter_add_rule(filter, rule4, 2, test_rule4_cb, &test);
+	assert(id4 && id4 !=3D id1 && id4 !=3D id2 && id4 !=3D id3);
+	assert(!test.expected_rule);
+	internal_id4 =3D test.new_id;
+
+	assert(test.calls[0] =3D=3D 0 && test.calls[1] =3D=3D 0 &&
+			test.calls[2] =3D=3D 0 && test.calls[3] =3D=3D 0);
+
+	message =3D _dbus_message_new_signal(2, DBUS_PATH_DBUS,
+						DBUS_INTERFACE_DBUS,
+						"NameOwnerChanged");
+	l_dbus_message_set_arguments(message, "sss", ":1.101", "", ":1.101");
+	_dbus_message_set_sender(message, DBUS_SERVICE_DBUS);
+	_dbus_filter_dispatch(message, filter);
+	l_dbus_message_unref(message);
+
+	message =3D _dbus_message_new_signal(2, DBUS_PATH_DBUS,
+						DBUS_INTERFACE_DBUS,
+						"NameOwnerChanged");
+	l_dbus_message_set_arguments(message, "");
+	_dbus_message_set_sender(message, DBUS_SERVICE_DBUS);
+	_dbus_filter_dispatch(message, filter);
+	l_dbus_message_unref(message);
+
+	message =3D _dbus_message_new_signal(2, DBUS_PATH_DBUS, "foo", "Bar");
+	l_dbus_message_set_arguments(message, "");
+	_dbus_message_set_sender(message, DBUS_SERVICE_DBUS);
+	_dbus_filter_dispatch(message, filter);
+
+	_dbus_message_set_sender(message, "foo");
+	_dbus_filter_dispatch(message, filter);
+
+	_dbus_message_set_sender(message, "bar");
+	_dbus_filter_dispatch(message, filter);
+	l_dbus_message_unref(message);
+
+	assert(test.calls[0] =3D=3D 3 && test.calls[1] =3D=3D 2 &&
+			test.calls[2] =3D=3D 1 && test.calls[3] =3D=3D 1);
+
+	test.expected_id =3D 0;
+	assert(_dbus_filter_remove_rule(filter, id2));
+
+	assert(_dbus_filter_remove_rule(filter, id1));
+
+	test.expected_id =3D internal_id4;
+	assert(_dbus_filter_remove_rule(filter, id4));
+	assert(!test.expected_id);
+
+	test.expected_id =3D internal_id1;
+	assert(_dbus_filter_remove_rule(filter, id3));
+	assert(!test.expected_id);
+
+	_dbus_filter_free(filter);
+
+	assert(test.calls[0] =3D=3D 3 && test.calls[1] =3D=3D 2 &&
+			test.calls[2] =3D=3D 1 && test.calls[3] =3D=3D 1);
+}
+
 int main(int argc, char *argv[])
 {
 	l_test_init(&argc, &argv);
@@ -264,5 +490,9 @@ int main(int argc, char *argv[])
 	l_test_add("DBus disconnect watch", test_disconnect_watch,
 						&disconnect_test);
 =

+	l_test_add("_dbus_filter_rule_to_str", test_rule_to_str, NULL);
+
+	l_test_add("DBus filter tree", test_filter_tree, NULL);
+
 	return l_test_run();
 }
-- =

2.5.0


--===============3549006975720511549==--

