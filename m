Content-Type: multipart/mixed; boundary="===============3798184631935047095=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman@intel.com>
Subject: [PATCH] unit: Test generic netlink family registration
Date: Wed, 12 Apr 2017 13:04:17 -0700
Message-ID: <1492027457-28188-1-git-send-email-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3798184631935047095==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Verify that genl family registration works by attempting to set a
family_appeared watch for the "nlctrl" family, and registering a
callback for it.  The "nlctrl" generic netlink family always exists in
the kernel so it is a suitable family to use for testing the
family_appeared watch and related family registration operations.
---
 unit/test-genl.c | 114 +++++++++++++++++++++++++++++++++++++++++++++------=
----
 1 file changed, 93 insertions(+), 21 deletions(-)

diff --git a/unit/test-genl.c b/unit/test-genl.c
index 44fbbb0..632eceb 100644
--- a/unit/test-genl.c
+++ b/unit/test-genl.c
@@ -29,6 +29,15 @@
 =

 #include <ell/ell.h>
 =

+struct test_data
+{
+	struct l_genl_family *appeared_family;
+	struct l_genl_family *vanished_family;
+
+	unsigned int group_id;
+	bool vanished_called;
+};
+
 static void do_debug(const char *str, void *user_data)
 {
 	const char *prefix =3D user_data;
@@ -36,38 +45,102 @@ static void do_debug(const char *str, void *user_data)
 	l_info("%s%s", prefix, str);
 }
 =

+static void notify_callback(struct l_genl_msg * msg, void * user_data)
+{
+}
+
+static void family_appeared(void *user_data)
+{
+	struct test_data *data =3D user_data;
+
+	data->group_id =3D l_genl_family_register(data->appeared_family,
+						"notify",
+						notify_callback,
+						NULL,
+						NULL);
+}
+
 static void family_vanished(void *user_data)
 {
-	bool *vanished_called =3D user_data;
+	struct test_data *data =3D user_data;
+
+	data->vanished_called =3D true;
+}
+
+static bool prep_family_appeared(struct l_genl *genl,
+					struct test_data *data)
+{
+	/*
+	 * Set a family_appeared watch for the "nlctrl" family.
+	 *
+	 * The "nlctrl" generic netlink family always exists in the
+	 * kernel so it is a suitable family to use for testing
+	 * the family_appeared watch and related family registration
+	 * operations.
+	 */
+	data->appeared_family =3D l_genl_family_new(genl, "nlctrl");
+
+	return l_genl_family_set_watches(data->appeared_family,
+						family_appeared, NULL,
+						data, NULL);
+}
+
+static bool prep_family_vanished(struct l_genl *genl,
+					struct test_data *data)
+{
+	/*
+	 * Use a bogus family name to trigger the vanished watch to
+	 * be called during the ELL event loop run.
+	 */
+	static const char BOGUS_GENL_NAME[] =3D "bogus_genl_family";
+
+	data->vanished_family =3D l_genl_family_new(genl, BOGUS_GENL_NAME);
+	return l_genl_family_set_watches(data->vanished_family,
+						NULL, family_vanished,
+						data, NULL);
+}
 =

-	*vanished_called =3D true;
+static bool check_test_data(struct test_data *data)
+{
+    return data->group_id !=3D 0 && data->vanished_called;
 }
 =

 static void idle_callback(struct l_idle *idle, void *user_data)
 {
+	struct test_data *data =3D user_data;
 	static int count =3D 0;
 =

 	/*
-	 * Allow the main loop to iterate at least twice to allow the
-	 * generic netlink watches to be called.
+	 * Exit the event loop if the desired results have been
+	 * obtained, but limit the number of iterations to prevent the
+	 * loop from running indefinetely if the conditions for
+	 * success are never reached.
+	 *
+	 * Allow the main loop to iterate at least four times to allow
+	 * the generic netlink watches and family registration to be
+	 * called and completed, respectively.
 	 */
-	if (++count > 1)
+	if (check_test_data(data) || ++count > 3)
 		l_main_quit();
 }
 =

+static bool destroy_test_data(struct test_data *data)
+{
+	bool unregistered =3D
+	    l_genl_family_unregister(data->appeared_family,
+					data->group_id);
+
+	l_genl_family_unref(data->vanished_family);
+	l_genl_family_unref(data->appeared_family);
+
+	return unregistered;
+}
+
 int main(int argc, char *argv[])
 {
 	struct l_genl *genl;
-	struct l_genl_family *family;
 	struct l_idle *idle;
-
-	/*
-	 * Use a bogus family name to trigger the vanished watch to
-	 * be called.
-	 */
-	static const char BOGUS_GENL_NAME[] =3D "bogus_genl_family";
-
-	bool vanished_called =3D false;
+	struct test_data data =3D { .group_id =3D 0 };
 =

 	if (!l_main_init())
 		return -1;
@@ -78,22 +151,21 @@ int main(int argc, char *argv[])
 =

 	l_genl_set_debug(genl, do_debug, "[GENL] ", NULL);
 =

-	family =3D l_genl_family_new(genl, BOGUS_GENL_NAME);
-	l_genl_family_set_watches(family, NULL, family_vanished,
-					&vanished_called, NULL);
+	assert(prep_family_appeared(genl, &data));
+	assert(prep_family_vanished(genl, &data));
 =

-	idle =3D l_idle_create(idle_callback, NULL, NULL);
+	idle =3D l_idle_create(idle_callback, &data, NULL);
 =

 	l_main_run();
 =

 	l_idle_remove(idle);
 =

-	l_genl_family_unref(family);
+	assert(check_test_data(&data));
+	assert(destroy_test_data(&data));
+
 	l_genl_unref(genl);
 =

 	l_main_exit();
 =

-	assert(vanished_called);
-
 	return 0;
 }
-- =

2.7.4


--===============3798184631935047095==--

