Content-Type: multipart/mixed; boundary="===============6862601625958990130=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman@intel.com>
Subject: [PATCH v4] unit: Added generic netlink family unit test
Date: Tue, 21 Mar 2017 14:15:45 -0700
Message-ID: <1490130945-15382-1-git-send-email-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6862601625958990130==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-genl.c | 43 ++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 40 insertions(+), 3 deletions(-)

diff --git a/unit/test-genl.c b/unit/test-genl.c
index d15d92c..dce9a41 100644
--- a/unit/test-genl.c
+++ b/unit/test-genl.c
@@ -25,6 +25,7 @@
 #endif
 =

 #include <sys/socket.h>
+#include <assert.h>
 =

 #include <ell/ell.h>
 =

@@ -35,14 +36,38 @@ static void do_debug(const char *str, void *user_data)
 	l_info("%s%s", prefix, str);
 }
 =

-static void idle_callback(void *user_data)
+static void family_vanished(void *user_data)
 {
-	l_main_quit();
+	bool *vanished_called =3D user_data;
+
+	*vanished_called =3D true;
+}
+
+static void idle_callback(struct l_idle *idle, void *user_data)
+{
+	static int count =3D 0;
+
+	/*
+	 * Allow the main loop to iterate at least twice to allow the
+	 * generic netlink watches to be called.
+	 */
+	if (++count > 1)
+		l_main_quit();
 }
 =

 int main(int argc, char *argv[])
 {
 	struct l_genl *genl;
+	struct l_genl_family *family;
+	struct l_idle *idle;
+
+	/*
+	 * Use a bogus family name to trigger the vanished watch to
+	 * be called.
+	 */
+	static const char BOGUS_GENL_NAME[] =3D "bogus_genl_family";
+
+	bool vanished_called =3D false;
 =

 	if (!l_main_init())
 		return -1;
@@ -53,13 +78,25 @@ int main(int argc, char *argv[])
 =

 	l_genl_set_debug(genl, do_debug, "[GENL] ", NULL);
 =

-	l_idle_oneshot(idle_callback, NULL, NULL);
+	family =3D l_genl_family_new(genl, BOGUS_GENL_NAME);
+	l_genl_family_set_watches(family,
+				  NULL,
+				  family_vanished,
+				  &vanished_called,
+				  NULL);
+
+	idle =3D l_idle_create(idle_callback, NULL, NULL);
 =

 	l_main_run();
 =

+	l_idle_remove(idle);
+
+	l_genl_family_unref(family);
 	l_genl_unref(genl);
 =

 	l_main_exit();
 =

+	assert(vanished_called);
+
 	return 0;
 }
-- =

2.7.4


--===============6862601625958990130==--

