Content-Type: multipart/mixed; boundary="===============0401954771112693941=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman@intel.com>
Subject: [PATCH] unit: Added generic netlink family unit test
Date: Tue, 21 Mar 2017 12:37:59 -0700
Message-ID: <1490125079-10438-1-git-send-email-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0401954771112693941==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 Makefile.am             |  3 ++
 unit/test-genl-family.c | 99 +++++++++++++++++++++++++++++++++++++++++++++=
++++
 2 files changed, 102 insertions(+)
 create mode 100644 unit/test-genl-family.c

diff --git a/Makefile.am b/Makefile.am
index d2e33de..39ebe66 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -119,6 +119,7 @@ unit_tests =3D unit/test-unit \
 			unit/test-settings \
 			unit/test-netlink \
 			unit/test-genl \
+			unit/test-genl-family \
 			unit/test-genl-msg \
 			unit/test-siphash \
 			unit/test-hwdb \
@@ -174,6 +175,8 @@ unit_test_netlink_LDADD =3D ell/libell-private.la
 =

 unit_test_genl_LDADD =3D ell/libell-private.la
 =

+unit_test_genl_family_LDADD =3D ell/libell-private.la
+
 unit_test_genl_msg_LDADD =3D ell/libell-private.la
 =

 unit_test_dbus_LDADD =3D ell/libell-private.la
diff --git a/unit/test-genl-family.c b/unit/test-genl-family.c
new file mode 100644
index 0000000..5109fad
--- /dev/null
+++ b/unit/test-genl-family.c
@@ -0,0 +1,99 @@
+/*
+ *
+ *  Embedded Linux library
+ *
+ *  Copyright (C) 2011-2017  Intel Corporation. All rights reserved.
+ *
+ *  This library is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU Lesser General Public
+ *  License as published by the Free Software Foundation; either
+ *  version 2.1 of the License, or (at your option) any later version.
+ *
+ *  This library is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ *  Lesser General Public License for more details.
+ *
+ *  You should have received a copy of the GNU Lesser General Public
+ *  License along with this library; if not, write to the Free Software
+ *  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 =
 USA
+ *
+ */
+
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif
+
+#include <sys/socket.h>
+
+#include <ell/ell.h>
+
+static void do_debug(const char *str, void *user_data)
+{
+	const char *prefix =3D user_data;
+
+	l_info("%s%s", prefix, str);
+}
+
+static void family_vanished(void *user_data)
+{
+	bool *vanished_called =3D user_data;
+
+	*vanished_called =3D true;
+}
+
+static void idle_handler(struct l_idle *idle, void *user_data)
+{
+	static int count =3D 0;
+
+	/*
+	 * Allow the main loop to iterate at least once.  Otherwise
+	 * the generic netlink watches won't be called.
+	 */
+	if (count++ =3D=3D 1)
+		l_main_quit();
+}
+
+int main(int argc, char *argv[])
+{
+	struct l_genl *genl;
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
+
+	if (!l_main_init())
+		return -1;
+
+	l_log_set_stderr();
+
+	genl =3D l_genl_new_default();
+
+	l_genl_set_debug(genl, do_debug, "[GENL] ", NULL);
+
+	family =3D l_genl_family_new(genl, BOGUS_GENL_NAME);
+	l_genl_family_set_watches(family,
+				  NULL,
+				  family_vanished,
+				  &vanished_called,
+				  NULL);
+
+	idle =3D l_idle_create(idle_handler, NULL, NULL);
+
+	l_main_run();
+
+	l_idle_remove(idle);
+
+	l_genl_family_unref(family);
+	l_genl_unref(genl);
+
+	l_main_exit();
+
+	return vanished_called ? 0 : -1;
+}
-- =

2.7.4


--===============0401954771112693941==--

