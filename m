Content-Type: multipart/mixed; boundary="===============8820010986052706862=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH v2 1/2] key: Add basic keystore support
Date: Fri, 04 Mar 2016 10:18:00 -0800
Message-ID: <1457115481-20440-1-git-send-email-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8820010986052706862==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 Makefile.am |   6 ++-
 ell/ell.h   |   1 +
 ell/key.c   | 154 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++=
++++
 ell/key.h   |  55 ++++++++++++++++++++++
 4 files changed, 214 insertions(+), 2 deletions(-)
 create mode 100644 ell/key.c
 create mode 100644 ell/key.h

diff --git a/Makefile.am b/Makefile.am
index 55ab8e6..e5a8f94 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -41,7 +41,8 @@ pkginclude_HEADERS =3D ell/ell.h \
 			ell/base64.h \
 			ell/pem.h \
 			ell/tls.h \
-			ell/uuid.h
+			ell/uuid.h \
+			ell/key.h
 =

 lib_LTLIBRARIES =3D ell/libell.la
 =

@@ -88,7 +89,8 @@ ell_libell_la_SOURCES =3D $(linux_headers) \
 			ell/tls-private.h \
 			ell/tls.c \
 			ell/tls-record.c \
-			ell/uuid.c
+			ell/uuid.c \
+			ell/key.c
 =

 ell_libell_la_LDFLAGS =3D -no-undefined \
 			-version-info $(ELL_CURRENT):$(ELL_REVISION):$(ELL_AGE)
diff --git a/ell/ell.h b/ell/ell.h
index 8cec756..390743f 100644
--- a/ell/ell.h
+++ b/ell/ell.h
@@ -43,6 +43,7 @@
 #include <ell/pem.h>
 #include <ell/tls.h>
 #include <ell/uuid.h>
+#include <ell/key.h>
 =

 #include <ell/netlink.h>
 #include <ell/genl.h>
diff --git a/ell/key.c b/ell/key.c
new file mode 100644
index 0000000..6ec8541
--- /dev/null
+++ b/ell/key.c
@@ -0,0 +1,154 @@
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
+#define _GNU_SOURCE
+#include <unistd.h>
+#include <stdint.h>
+#include <sys/syscall.h>
+#include <linux/keyctl.h>
+
+#include "private.h"
+#include "util.h"
+#include "key.h"
+
+static int32_t keyring_base;
+
+struct l_key {
+	int type;
+	int32_t serial;
+};
+
+static const char * const key_type_names[] =3D {
+	[L_KEY_RAW] =3D "user",
+	[L_KEY_ASYMMETRIC] =3D "asymmetric",
+};
+
+static long kernel_add_key(const char *type, const char *description,
+				const void *payload, size_t len, int32_t keyring)
+{
+	return syscall(__NR_add_key, type, description, payload, len, keyring);
+}
+
+static long kernel_read_key(int32_t serial, const void *payload, size_t le=
n)
+{
+	return syscall(__NR_keyctl, KEYCTL_READ, serial, payload, len);
+}
+
+static long kernel_update_key(int32_t serial, const void *payload, size_t =
len)
+{
+	return syscall(__NR_keyctl, KEYCTL_UPDATE, serial, payload, len);
+}
+
+static long kernel_revoke_key(int32_t serial)
+{
+	return syscall(__NR_keyctl, KEYCTL_REVOKE, serial);
+}
+
+static bool setup_keyring_base(void)
+{
+	keyring_base =3D kernel_add_key("keyring", "ell", 0, 0,
+					KEY_SPEC_THREAD_KEYRING);
+
+	if (keyring_base <=3D 0) {
+		keyring_base =3D 0;
+		return false;
+	}
+
+	return true;
+}
+
+LIB_EXPORT struct l_key *l_key_new(enum l_key_type type, const void *paylo=
ad,
+					size_t payload_length)
+{
+	struct l_key *key;
+
+	if (unlikely(!payload))
+		return NULL;
+
+	if (unlikely((size_t)type >=3D L_ARRAY_SIZE(key_type_names)))
+		return NULL;
+
+	if (!keyring_base && !setup_keyring_base()) {
+		return NULL;
+	}
+
+	key =3D l_new(struct l_key, 1);
+	key->type =3D type;
+	key->serial =3D kernel_add_key(key_type_names[type], "ell", payload,
+					payload_length, keyring_base);
+
+	if (key->serial < 0) {
+		l_free(key);
+		key =3D NULL;
+	}
+
+	return key;
+}
+
+LIB_EXPORT void l_key_free(struct l_key *key)
+{
+	if (unlikely(!key))
+		return;
+
+	kernel_revoke_key(key->serial);
+
+	l_free(key);
+}
+
+LIB_EXPORT bool l_key_update(struct l_key *key, const void *payload, size_=
t len)
+{
+	long error;
+
+	if (unlikely(!key))
+		return false;
+
+	error =3D kernel_update_key(key->serial, payload, len);
+
+	return error =3D=3D 0;
+}
+
+LIB_EXPORT bool l_key_extract(struct l_key *key, void *payload, size_t *le=
n)
+{
+	long keylen;
+
+	if (unlikely(!key))
+		return false;
+
+	keylen =3D kernel_read_key(key->serial, payload, *len);
+
+	if (keylen < 0 || (size_t)keylen > *len) {
+		memset(payload, 0, *len);
+		return false;
+	}
+
+	*len =3D keylen;
+	return true;
+}
+
+LIB_EXPORT ssize_t l_key_get_size(struct l_key *key)
+{
+	return kernel_read_key(key->serial, NULL, 0);
+}
diff --git a/ell/key.h b/ell/key.h
new file mode 100644
index 0000000..73c2c97
--- /dev/null
+++ b/ell/key.h
@@ -0,0 +1,55 @@
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
+#ifndef __ELL_KEY_H
+#define __ELL_KEY_H
+
+#ifdef __cplusplus
+extern "C" {
+#endif
+
+#include <stddef.h>
+#include <stdbool.h>
+
+struct l_key;
+
+enum l_key_type {
+	L_KEY_RAW =3D 0,
+	L_KEY_ASYMMETRIC
+};
+
+struct l_key *l_key_new(enum l_key_type type, const void *payload,
+			size_t payload_length);
+
+void l_key_free(struct l_key *key);
+
+bool l_key_update(struct l_key *key, const void *payload, size_t len);
+
+bool l_key_extract(struct l_key *key, void *payload, size_t *len);
+
+ssize_t l_key_get_size(struct l_key *key);
+
+#ifdef __cplusplus
+}
+#endif
+
+#endif /* __ELL_KEY_H */
-- =

2.7.2


--===============8820010986052706862==--

