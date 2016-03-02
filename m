Content-Type: multipart/mixed; boundary="===============7799685735778749114=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 2/2] key: Add keystore unit test
Date: Tue, 01 Mar 2016 16:23:30 -0800
Message-ID: <1456878210-17519-2-git-send-email-mathew.j.martineau@linux.intel.com>
In-Reply-To: <1456878210-17519-1-git-send-email-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7799685735778749114==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 .gitignore      |  1 +
 Makefile.am     |  5 +++-
 unit/test-key.c | 88 +++++++++++++++++++++++++++++++++++++++++++++++++++++=
++++
 3 files changed, 93 insertions(+), 1 deletion(-)
 create mode 100644 unit/test-key.c

diff --git a/.gitignore b/.gitignore
index 8a20ffe..6e35752 100644
--- a/.gitignore
+++ b/.gitignore
@@ -52,6 +52,7 @@ unit/test-base64
 unit/test-tls
 unit/test-pem
 unit/test-uuid
+unit/test-key
 unit/*.log
 unit/*.trs
 examples/dbus-service
diff --git a/Makefile.am b/Makefile.am
index e5a8f94..256b163 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -131,7 +131,8 @@ unit_tests =3D unit/test-unit \
 			unit/test-base64 \
 			unit/test-pem \
 			unit/test-tls \
-			unit/test-uuid
+			unit/test-uuid \
+			unit/test-key
 =

 dbus_tests =3D unit/test-kdbus \
 			unit/test-dbus \
@@ -215,6 +216,8 @@ unit_test_tls_LDADD =3D ell/libell-private.la
 =

 unit_test_uuid_LDADD =3D ell/libell-private.la
 =

+unit_test_key_LDADD =3D ell/libell-private.la
+
 if MAINTAINER_MODE
 noinst_LTLIBRARIES +=3D unit/example-plugin.la
 endif
diff --git a/unit/test-key.c b/unit/test-key.c
new file mode 100644
index 0000000..a803166
--- /dev/null
+++ b/unit/test-key.c
@@ -0,0 +1,88 @@
+/*
+ *
+ *  Embedded Linux library
+ *
+ *  Copyright (C) 2016  Intel Corporation. All rights reserved.
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
+#include <assert.h>
+
+#include <ell/ell.h>
+
+#define KEY1_STR "This key has exactly _32_ bytes!"
+#define KEY1_LEN (strlen(KEY1_STR))
+#define KEY2_STR "This key is longer than 32 bytes, just to be different."
+#define KEY2_LEN (strlen(KEY2_STR))
+
+static void test_unsupported(const void *data)
+{
+	struct l_key *key;
+
+	key =3D l_key_new(42, KEY1_STR, KEY1_LEN);
+	assert(!key);
+}
+
+static void test_user(const void *data)
+{
+	struct l_key *key;
+	bool ok;
+	char buf[64] =3D { 0 };
+	size_t len;
+
+	assert(KEY1_LEN < KEY2_LEN);
+	assert(KEY2_LEN < sizeof(buf));
+
+	key =3D l_key_new(L_KEY_USER, KEY1_STR, KEY1_LEN);
+	assert(key);
+
+	len =3D KEY1_LEN - 1;
+	ok =3D l_key_get_payload(key, buf, &len);
+	assert(!ok);
+
+	len =3D sizeof(buf);
+	ok =3D l_key_get_payload(key, buf, &len);
+	assert(ok);
+	assert(len =3D=3D KEY1_LEN);
+	assert(!strcmp(buf, KEY1_STR));
+
+	ok =3D l_key_set_payload(key, KEY2_STR, KEY2_LEN);
+	assert(ok);
+
+	len =3D sizeof(buf);
+	ok =3D l_key_get_payload(key, buf, &len);
+	assert(ok);
+	assert(len =3D=3D KEY2_LEN);
+	assert(!strcmp(buf, KEY2_STR));
+
+	l_key_free(key);
+}
+
+int main(int argc, char *argv[])
+{
+	l_test_init(&argc, &argv);
+
+	l_test_add("unsupported", test_unsupported, NULL);
+
+	l_test_add("user key", test_user, NULL);
+
+	return l_test_run();
+}
-- =

2.7.2


--===============7799685735778749114==--

