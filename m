Content-Type: multipart/mixed; boundary="===============1558197195315805388=="
MIME-Version: 1.0
From: James Prestwood <james.prestwood@linux.intel.com>
Subject: [PATCH v2 3/3] unit: test-genl: Reworked genl tests after
 restructuring
Date: Wed, 31 Oct 2018 13:31:45 -0700
Message-ID: <20181031203145.5637-3-james.prestwood@linux.intel.com>
In-Reply-To: <20181031203145.5637-1-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1558197195315805388==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-genl.c | 351 ++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 270 insertions(+), 81 deletions(-)

diff --git a/unit/test-genl.c b/unit/test-genl.c
index a381e25..c05c55c 100644
--- a/unit/test-genl.c
+++ b/unit/test-genl.c
@@ -2,7 +2,7 @@
  *
  *  Embedded Linux library
  *
- *  Copyright (C) 2011-2014  Intel Corporation. All rights reserved.
+ *  Copyright (C) 2011-2018  Intel Corporation. All rights reserved.
  *
  *  This library is free software; you can redistribute it and/or
  *  modify it under the terms of the GNU Lesser General Public
@@ -32,10 +32,13 @@
 struct test_data
 {
 	struct l_genl_family *appeared_family;
-	struct l_genl_family *vanished_family;
 =

-	unsigned int group_id;
-	bool vanished_called;
+	bool destroyed_called;
+	bool appeared_called;
+	bool genl_destroyed;
+	int message_destroy;
+
+	int idle_count;
 };
 =

 static void do_debug(const char *str, void *user_data)
@@ -45,138 +48,324 @@ static void do_debug(const char *str, void *user_data)
 	l_info("%s%s", prefix, str);
 }
 =

-static void notify_callback(struct l_genl_msg *msg, void *user_data)
-{
-}
-
-static void family_appeared(void *user_data)
+static void family_appeared(struct l_genl_family *family, void *user_data)
 {
 	struct test_data *data =3D user_data;
 =

-	data->group_id =3D l_genl_family_register(data->appeared_family,
-						"notify",
-						notify_callback,
-						NULL,
-						NULL);
+	data->appeared_called =3D true;
+	data->appeared_family =3D family;
 }
 =

-static void family_vanished(void *user_data)
+static void family_destroyed(void *user_data)
 {
-	struct test_data *data =3D user_data;
+	struct test_data *td =3D user_data;
 =

-	data->vanished_called =3D true;
+	td->destroyed_called =3D true;
 }
 =

-static bool prep_family_appeared(struct l_genl *genl,
-					struct test_data *data)
+static void idle_callback(struct l_idle *idle, void *user_data)
 {
+	struct test_data *data =3D user_data;
+
 	/*
-	 * Set a family_appeared watch for the "nlctrl" family.
+	 * Exit the event loop if the desired results have been
+	 * obtained, but limit the number of iterations to prevent the
+	 * loop from running indefinitely if the conditions for
+	 * success are never reached.
 	 *
-	 * The "nlctrl" generic netlink family always exists in the
-	 * kernel so it is a suitable family to use for testing
-	 * the family_appeared watch and related family registration
-	 * operations.
+	 * Allow the main loop to iterate at least four times to allow
+	 * the generic netlink watches and family registration to be
+	 * called and completed, respectively.
 	 */
-	data->appeared_family =3D l_genl_family_new(genl, "nlctrl");
-
-	return l_genl_family_set_watches(data->appeared_family,
-						family_appeared, NULL,
-						data, NULL);
+	if (++data->idle_count > 3)
+		l_main_quit();
 }
 =

-static bool prep_family_vanished(struct l_genl *genl,
-					struct test_data *data)
+static void test_basic(const void *user_data)
 {
-	/*
-	 * Use a bogus family name to trigger the vanished watch to
-	 * be called during the ELL event loop run.
-	 */
-	static const char BOGUS_GENL_NAME[] =3D "bogusgenlfamily";
+	struct l_genl *genl;
+	struct l_idle *idle;
+	struct test_data td1 =3D { 0 };
+	struct test_data td2 =3D { 0 };
 =

-	data->vanished_family =3D l_genl_family_new(genl, BOGUS_GENL_NAME);
-	return l_genl_family_set_watches(data->vanished_family,
-						NULL, family_vanished,
-						data, NULL);
-}
+	if (!l_main_init()) {
+		assert(false);
+		return;
+	}
 =

-static bool name_too_long(struct l_genl *genl, struct test_data *data)
-{
-	static const char LONG_GENL_NAME[] =3D "long_genl_family_name";
+	l_log_set_stderr();
+
+	genl =3D l_genl_new_default();
+
+	l_genl_set_debug(genl, do_debug, "[GENL] ", NULL);
 =

-	assert(!l_genl_family_new(genl, LONG_GENL_NAME));
+	assert(l_genl_get_family(genl, "nlctrl", family_appeared,
+					&td1, family_destroyed));
+	assert(l_genl_get_family(genl, "bogusgenlfamily", family_appeared,
+					&td2, family_destroyed));
+	assert(!l_genl_get_family(genl, "long_genl_family_name",
+					family_appeared, NULL,
+					family_destroyed));
+
+	idle =3D l_idle_create(idle_callback, &td1, NULL);
+
+	l_main_run();
+
+	l_idle_remove(idle);
+
+	assert(td1.appeared_called && td1.appeared_family);
+	assert(td2.destroyed_called);
+
+	l_genl_family_destroy(td1.appeared_family);
+
+	l_genl_unref(genl);
 =

-	return true;
+	l_main_exit();
 }
 =

-static bool check_test_data(struct test_data *data)
+static void test_gets_before_lookup(const void *user_data)
 {
-    return data->group_id !=3D 0 && data->vanished_called;
+	struct l_genl *genl;
+	struct l_idle *idle;
+	struct test_data td1 =3D { 0 };
+	struct test_data td2 =3D { 0 };
+
+	if (!l_main_init()) {
+		assert(false);
+		return;
+	}
+
+	l_log_set_stderr();
+
+	genl =3D l_genl_new_default();
+
+	l_genl_set_debug(genl, do_debug, "[GENL] ", NULL);
+
+	assert(l_genl_get_family(genl, "nlctrl", family_appeared, &td1,
+					family_destroyed));
+	assert(l_genl_get_family(genl, "nlctrl", family_appeared, &td2,
+					family_destroyed));
+
+	idle =3D l_idle_create(idle_callback, &td1, NULL);
+
+	l_main_run();
+
+	l_idle_remove(idle);
+
+	assert(td1.appeared_called && td1.appeared_family);
+	assert(td1.appeared_called && td1.appeared_family);
+
+	l_genl_family_destroy(td1.appeared_family);
+	l_genl_family_destroy(td2.appeared_family);
+
+	l_genl_unref(genl);
+
+	l_main_exit();
 }
 =

-static void idle_callback(struct l_idle *idle, void *user_data)
+static void test_destroy_before_lookup(const void *user_data)
 {
-	struct test_data *data =3D user_data;
-	static int count =3D 0;
+	struct l_genl *genl;
+	struct test_data td1 =3D { 0 };
+	struct test_data td2 =3D { 0 };
+
+	if (!l_main_init()) {
+		assert(false);
+		return;
+	}
+
+	l_log_set_stderr();
+
+	genl =3D l_genl_new_default();
+
+	l_genl_set_debug(genl, do_debug, "[GENL] ", NULL);
+
+	assert(l_genl_get_family(genl, "nlctrl", family_appeared, &td1,
+					family_destroyed));
+	assert(l_genl_get_family(genl, "nlctrl", family_appeared, &td2,
+					family_destroyed));
 =

 	/*
-	 * Exit the event loop if the desired results have been
-	 * obtained, but limit the number of iterations to prevent the
-	 * loop from running indefinitely if the conditions for
-	 * success are never reached.
-	 *
-	 * Allow the main loop to iterate at least four times to allow
-	 * the generic netlink watches and family registration to be
-	 * called and completed, respectively.
+	 * In practice you would never do this. But it effectively simulates
+	 * the genl transport disappearing while you have family lookups
+	 * pending.
 	 */
-	if (check_test_data(data) || ++count > 3)
-		l_main_quit();
+	l_genl_unref(genl);
+	l_genl_unref(genl);
+
+	assert(td1.destroyed_called);
+	assert(td2.destroyed_called);
+
+	l_main_exit();
 }
 =

-static bool destroy_test_data(struct test_data *data)
+static void test_family_after_lookup(const void *user_data)
 {
-	bool unregistered =3D
-			l_genl_family_unregister(data->appeared_family,
-							data->group_id);
+	struct l_genl *genl;
+	struct l_idle *idle;
+	struct test_data td1 =3D { 0 };
+	struct test_data td2 =3D { 0 };
+
+	if (!l_main_init()) {
+		assert(false);
+		return;
+	}
+
+	l_log_set_stderr();
+
+	genl =3D l_genl_new_default();
+
+	l_genl_set_debug(genl, do_debug, "[GENL] ", NULL);
+
+	assert(l_genl_get_family(genl, "nlctrl", family_appeared, &td1,
+					family_destroyed));
+
+	idle =3D l_idle_create(idle_callback, &td1, NULL);
+
+	l_main_run();
+
+	l_idle_remove(idle);
+
+	assert(td1.appeared_called);
+
+	l_main_exit();
+
+	if (!l_main_init()) {
+		assert(false);
+		return;
+	}
+
+	assert(l_genl_get_family(genl, "nlctrl", family_appeared, &td2,
+					family_destroyed));
+
+	idle =3D l_idle_create(idle_callback, &td2, NULL);
+
+	l_main_run();
+
+	l_idle_remove(idle);
+
+	assert(td2.appeared_called);
+
+	l_genl_family_destroy(td1.appeared_family);
+	l_genl_family_destroy(td2.appeared_family);
 =

-	l_genl_family_unref(data->vanished_family);
-	l_genl_family_unref(data->appeared_family);
+	l_genl_unref(genl);
 =

-	return unregistered;
+	l_main_exit();
 }
 =

-int main(int argc, char *argv[])
+static void message_destroy(void *user_data)
+{
+	struct test_data *td =3D user_data;
+
+	td->message_destroy++;
+}
+
+static void test_cancel_all_request(const void *user_data)
 {
 	struct l_genl *genl;
+	struct l_genl_msg *msg1, *msg2, *msg3, *msg4;
+	unsigned int msg3_id;
 	struct l_idle *idle;
-	struct test_data data =3D { .group_id =3D 0 };
 =

-	if (!l_main_init())
-		return -1;
+	struct test_data td1 =3D { 0 };
+	struct test_data td2 =3D { 0 };
 =

-	l_log_set_stderr();
+	if (!l_main_init()) {
+		assert(false);
+		return;
+	}
 =

 	genl =3D l_genl_new_default();
 =

 	l_genl_set_debug(genl, do_debug, "[GENL] ", NULL);
 =

-	assert(prep_family_appeared(genl, &data));
-	assert(prep_family_vanished(genl, &data));
+	assert(l_genl_get_family(genl, "nlctrl", family_appeared, &td1,
+					family_destroyed));
+	assert(l_genl_get_family(genl, "nlctrl", family_appeared, &td2,
+					family_destroyed));
 =

-	assert(name_too_long(genl, &data));
-
-	idle =3D l_idle_create(idle_callback, &data, NULL);
+	idle =3D l_idle_create(idle_callback, &td1, NULL);
 =

 	l_main_run();
 =

 	l_idle_remove(idle);
 =

-	assert(check_test_data(&data));
-	assert(destroy_test_data(&data));
+	assert(td1.appeared_called);
+	assert(td2.appeared_called);
+
+	/* create some dummy messages to send on both families */
+	msg1 =3D l_genl_msg_new(1);
+	msg2 =3D l_genl_msg_new(1);
+	msg3 =3D l_genl_msg_new(1);
+	msg4 =3D l_genl_msg_new(1);
+
+	l_genl_family_send(td1.appeared_family, msg1, NULL, &td1,
+					message_destroy);
+	l_genl_family_send(td1.appeared_family, msg2, NULL, &td1,
+					message_destroy);
+	msg3_id =3D l_genl_family_send(td2.appeared_family, msg3, NULL, &td2,
+					message_destroy);
+	l_genl_family_send(td2.appeared_family, msg4, NULL, &td2,
+					message_destroy);
+
+	/* this should cancel msg1 and msg2 */
+	l_genl_family_destroy(td1.appeared_family);
+
+	assert(td1.message_destroy =3D=3D 2);
+	assert(td2.message_destroy =3D=3D 0);
+
+	/* cancel just message 3 */
+	l_genl_family_cancel(td2.appeared_family, msg3_id);
+	assert(td2.message_destroy =3D=3D 1);
+
+	/* cancel all remaining (just message 4) */
+	l_genl_family_destroy(td2.appeared_family);
+	assert(td2.message_destroy =3D=3D 2);
 =

 	l_genl_unref(genl);
 =

 	l_main_exit();
+}
+
+static void genl_destroyed(void *user_data)
+{
+	struct test_data *td =3D user_data;
+
+	td->genl_destroyed =3D true;
+}
+
+static void test_genl_disappearing(const void *user_data)
+{
+	struct l_genl *genl;
+	struct test_data td =3D { 0 };
+
+	if (!l_main_init()) {
+		assert(false);
+		return;
+	}
+
+	genl =3D l_genl_new_default();
+
+	l_genl_add_destroy_watch(genl, genl_destroyed, &td);
+
+	l_genl_unref(genl);
+
+	assert(td.genl_destroyed);
+
+	l_main_exit();
+}
+
+int main(int argc, char *argv[])
+{
+	l_test_init(&argc, &argv);
+
+	l_test_add("Basic", test_basic, NULL);
+	l_test_add("Gets before lookup", test_gets_before_lookup, NULL);
+	l_test_add("Destroy before lookup", test_destroy_before_lookup, NULL);
+	l_test_add("New family after lookup", test_family_after_lookup, NULL);
+	l_test_add("Cancel all family requests", test_cancel_all_request, NULL);
+	l_test_add("Genl disappearing", test_genl_disappearing, NULL);
 =

-	return 0;
+	return l_test_run();
 }
-- =

2.17.1


--===============1558197195315805388==--

