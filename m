Content-Type: multipart/mixed; boundary="===============6582328271207130069=="
MIME-Version: 1.0
From: James Prestwood <james.prestwood@linux.intel.com>
Subject: [PATCH 2/2] unit: test-genl:
Date: Wed, 24 Oct 2018 13:52:14 -0700
Message-ID: <20181024205214.8376-2-james.prestwood@linux.intel.com>
In-Reply-To: <20181024205214.8376-1-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6582328271207130069==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Added more unit tests to exercise new parent/child structure in genl
---
 unit/test-genl.c | 247 +++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 240 insertions(+), 7 deletions(-)

diff --git a/unit/test-genl.c b/unit/test-genl.c
index a381e25..5b53ba8 100644
--- a/unit/test-genl.c
+++ b/unit/test-genl.c
@@ -36,6 +36,11 @@ struct test_data
 =

 	unsigned int group_id;
 	bool vanished_called;
+	bool destroyed_called;
+	bool appeared_called;
+	int message_destroy;
+
+	int idle_count;
 };
 =

 static void do_debug(const char *str, void *user_data)
@@ -117,7 +122,6 @@ static bool check_test_data(struct test_data *data)
 static void idle_callback(struct l_idle *idle, void *user_data)
 {
 	struct test_data *data =3D user_data;
-	static int count =3D 0;
 =

 	/*
 	 * Exit the event loop if the desired results have been
@@ -129,7 +133,7 @@ static void idle_callback(struct l_idle *idle, void *us=
er_data)
 	 * the generic netlink watches and family registration to be
 	 * called and completed, respectively.
 	 */
-	if (check_test_data(data) || ++count > 3)
+	if (check_test_data(data) || ++data->idle_count > 3)
 		l_main_quit();
 }
 =

@@ -138,21 +142,22 @@ static bool destroy_test_data(struct test_data *data)
 	bool unregistered =3D
 			l_genl_family_unregister(data->appeared_family,
 							data->group_id);
-
 	l_genl_family_unref(data->vanished_family);
 	l_genl_family_unref(data->appeared_family);
 =

 	return unregistered;
 }
 =

-int main(int argc, char *argv[])
+static void test_basic(const void *user_data)
 {
 	struct l_genl *genl;
 	struct l_idle *idle;
 	struct test_data data =3D { .group_id =3D 0 };
 =

-	if (!l_main_init())
-		return -1;
+	if (!l_main_init()) {
+		assert(false);
+		return;
+	}
 =

 	l_log_set_stderr();
 =

@@ -177,6 +182,234 @@ int main(int argc, char *argv[])
 	l_genl_unref(genl);
 =

 	l_main_exit();
+}
+
+static void test_vanished_called(void *user_data)
+{
+	struct test_data *td =3D user_data;
+
+	td->vanished_called =3D true;
+}
+
+static void test_destroyed_called(void *user_data)
+{
+	struct test_data *td =3D user_data;
+
+	td->destroyed_called =3D true;
+}
+
+static void test_appeared_called(void *user_data)
+{
+	struct test_data *td =3D user_data;
+
+	td->appeared_called =3D true;
+}
+
+static void test_ref_unref(const void *user_data)
+{
+	struct l_genl *genl;
+	struct l_genl_family *family;
+	struct l_idle *idle;
+	struct test_data td =3D { 0 };
+
+	if (!l_main_init()) {
+		assert(false);
+		return;
+	}
+
+	genl =3D l_genl_new_default();
+
+	l_genl_set_debug(genl, do_debug, "[GENL] ", NULL);
+
+	family =3D l_genl_family_new(genl, "nlctrl");
+
+	l_genl_family_set_watches(family, NULL, test_vanished_called,
+					&td, test_destroyed_called);
+
+	idle =3D l_idle_create(idle_callback, &td, NULL);
+
+	l_main_run();
+
+	l_idle_remove(idle);
+
+	l_genl_family_ref(family);
+	l_genl_family_ref(family);
+	/* family is returned ref'ed, so we need an extra unref */
+	l_genl_family_unref(family);
+	l_genl_family_unref(family);
+	l_genl_family_unref(family);
+
+	assert(td.vanished_called);
+	assert(td.destroyed_called);
+
+	l_genl_unref(genl);
+
+	l_main_exit();
+}
+
+static void test_cleanup_before_lookup(const void *user_data)
+{
+	struct l_genl *genl;
+	struct l_genl_family *family;
+	struct test_data td =3D { 0 };
+
+	genl =3D l_genl_new_default();
+
+	l_genl_set_debug(genl, do_debug, "[GENL] ", NULL);
+
+	family =3D l_genl_family_new(genl, "nlctrl");
+
+	l_genl_family_set_watches(family, NULL, test_vanished_called,
+					&td, test_destroyed_called);
+	/* family is returned immediately but not yet looked up */
+	l_genl_family_unref(family);
+
+	/* vanished only called if 'appeared' (i.e. lookup completed) */
+	assert(!td.vanished_called);
+	assert(td.destroyed_called);
+
+	l_genl_unref(genl);
+}
+
+static void test_family_after_lookup(const void *user_data)
+{
+	struct l_genl *genl;
+	struct l_genl_family *family1;
+	struct l_genl_family *family2;
+	struct l_idle *idle;
+	struct test_data td1 =3D { 0 };
+	struct test_data td2 =3D { 0 };
+
+	if (!l_main_init()) {
+		assert(false);
+		return;
+	}
+
+	genl =3D l_genl_new_default();
+
+	l_genl_set_debug(genl, do_debug, "[GENL] ", NULL);
+
+	family1 =3D l_genl_family_new(genl, "nlctrl");
+
+	l_genl_family_set_watches(family1, test_appeared_called,
+					test_vanished_called,
+					&td1, test_destroyed_called);
+
+	idle =3D l_idle_create(idle_callback, &td1, NULL);
+
+	l_main_run();
+
+	l_idle_remove(idle);
+
+	assert(td1.appeared_called);
+
+	/* now that family has been looked up, it should appear immediately */
+	family2 =3D l_genl_family_new(genl, "nlctrl");
+	l_genl_family_set_watches(family2, test_appeared_called,
+					test_vanished_called,
+					&td2, test_destroyed_called);
+	assert(td2.appeared_called);
+
+	l_genl_unref(genl);
+
+	/* unref'ing genl should trigger removal of both families */
+	assert(td1.vanished_called && td1.destroyed_called);
+	assert(td2.vanished_called && td2.destroyed_called);
+
+	l_main_exit();
+}
+
+static void message_destroy(void *user_data)
+{
+	struct test_data *td =3D user_data;
+
+	td->message_destroy++;
+}
+
+static void test_cancel_all_request(const void *user_data)
+{
+	struct l_genl *genl;
+	struct l_genl_family *family1;
+	struct l_genl_family *family2;
+	struct l_genl_msg *msg1, *msg2, *msg3, *msg4;
+	unsigned int msg3_id;
+	struct l_idle *idle;
+
+	struct test_data td1 =3D { 0 };
+	struct test_data td2 =3D { 0 };
+
+	if (!l_main_init()) {
+		assert(false);
+		return;
+	}
+
+	genl =3D l_genl_new_default();
+
+	l_genl_set_debug(genl, do_debug, "[GENL] ", NULL);
+
+	family1 =3D l_genl_family_new(genl, "nlctrl");
+	family2 =3D l_genl_family_new(genl, "nlctrl");
+
+	l_genl_family_set_watches(family1, test_appeared_called,
+					test_vanished_called,
+					&td1, test_destroyed_called);
+	l_genl_family_set_watches(family2, test_appeared_called,
+					test_vanished_called,
+					&td2, test_destroyed_called);
+
+	idle =3D l_idle_create(idle_callback, &td1, NULL);
+
+	l_main_run();
+
+	l_idle_remove(idle);
+
+	assert(td1.appeared_called);
+	assert(td2.appeared_called);
+
+	/* create some dummy messages to send on both families */
+	msg1 =3D l_genl_msg_new(1);
+	msg2 =3D l_genl_msg_new(1);
+	msg3 =3D l_genl_msg_new(1);
+	msg4 =3D l_genl_msg_new(1);
+
+	l_genl_family_send(family1, msg1, NULL, &td1, message_destroy);
+	l_genl_family_send(family1, msg2, NULL, &td1, message_destroy);
+	msg3_id =3D l_genl_family_send(family2, msg3, NULL, &td2,
+					message_destroy);
+	l_genl_family_send(family2, msg4, NULL, &td2, message_destroy);
+
+	/* this should cancel msg1 and msg2 */
+	l_genl_family_unref(family1);
+
+	assert(td1.vanished_called);
+	assert(td1.destroyed_called);
+	assert(td1.message_destroy =3D=3D 2);
+	assert(td2.message_destroy =3D=3D 0);
+
+	/* cancel just message 3 */
+	l_genl_family_cancel(family2, msg3_id);
+	assert(td2.message_destroy =3D=3D 1);
+
+	/* cancel all remaining (just message 4) */
+	l_genl_family_unref(family2);
+	assert(td2.vanished_called);
+	assert(td2.destroyed_called);
+	assert(td2.message_destroy =3D=3D 2);
+
+	l_genl_unref(genl);
+
+	l_main_exit();
+}
+
+int main(int argc, char *argv[])
+{
+	l_test_init(&argc, &argv);
+
+	l_test_add("Basic", test_basic, NULL);
+	l_test_add("Ref/Unref", test_ref_unref, NULL);
+	l_test_add("Cleaup before lookup", test_cleanup_before_lookup, NULL);
+	l_test_add("New family after lookup", test_family_after_lookup, NULL);
+	l_test_add("Cancel all family requests", test_cancel_all_request, NULL);
 =

-	return 0;
+	return l_test_run();
 }
-- =

2.17.1


--===============6582328271207130069==--

