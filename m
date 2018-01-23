Content-Type: multipart/mixed; boundary="===============8276044455678484229=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 1/4] key: Add private API for key feature detection
Date: Tue, 23 Jan 2018 13:02:20 -0800
Message-ID: <20180123210223.28042-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8276044455678484229==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The Diffie-Hellman, keyring restrictions, and key crypto parts of the
l_key API depend on kernel features that were added relatively
recently. While the affected l_key calls fail gracefully when the kernel
doesn't implement the required feature, they do not fail in a way that
allows unit tests to differentiate between library bugs and kernel
support. l_key_is_supported() is a private API to check for kernel
support.
---
 ell/key-private.h | 27 +++++++++++++++++++++++++++
 ell/key.c         | 31 +++++++++++++++++++++++++++++++
 2 files changed, 58 insertions(+)
 create mode 100644 ell/key-private.h

diff --git a/ell/key-private.h b/ell/key-private.h
new file mode 100644
index 0000000..ea0012f
--- /dev/null
+++ b/ell/key-private.h
@@ -0,0 +1,27 @@
+/*
+ *
+ *  Embedded Linux library
+ *
+ *  Copyright (C) 2018  Intel Corporation. All rights reserved.
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
+#define L_KEY_FEATURE_DH	(1 << 0)
+#define L_KEY_FEATURE_RESTRICT	(1 << 1)
+#define L_KEY_FEATURE_CRYPTO	(1 << 2)
+
+bool l_key_is_supported(uint32_t features);
diff --git a/ell/key.c b/ell/key.c
index 5a73bbd..4093143 100644
--- a/ell/key.c
+++ b/ell/key.c
@@ -36,6 +36,7 @@
 #include "key.h"
 #include "string.h"
 #include "random.h"
+#include "key-private.h"
 =

 #ifndef KEYCTL_DH_COMPUTE
 #define KEYCTL_DH_COMPUTE 23
@@ -772,3 +773,33 @@ bool l_keyring_unlink(struct l_keyring *keyring, const=
 struct l_key *key)
 =

 	return error =3D=3D 0;
 }
+
+bool l_key_is_supported(uint32_t features)
+{
+	long result;
+
+	if (features & L_KEY_FEATURE_DH) {
+		result =3D syscall(__NR_keyctl, KEYCTL_DH_COMPUTE, NULL, "x", 1,
+					NULL);
+
+		if (result =3D=3D -1 && errno =3D=3D EOPNOTSUPP)
+			return false;
+	}
+
+	if (features & L_KEY_FEATURE_RESTRICT) {
+		result =3D syscall(__NR_keyctl, KEYCTL_RESTRICT_KEYRING, 0,
+					"asymmetric", "");
+
+		if (result =3D=3D -1 && errno =3D=3D EOPNOTSUPP)
+			return false;
+	}
+
+	if (features & L_KEY_FEATURE_CRYPTO) {
+		result =3D syscall(__NR_keyctl, KEYCTL_PKEY_QUERY, 0, 0, "", 0);
+
+		if (result =3D=3D -1 && errno =3D=3D EOPNOTSUPP)
+			return false;
+	}
+
+	return true;
+}
-- =

2.16.1


--===============8276044455678484229==--

