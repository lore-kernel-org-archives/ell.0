Content-Type: multipart/mixed; boundary="===============2143659019212409354=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 3/7] pkcs5: Implement PKCS#5 key derivation functions
Date: Mon, 14 Aug 2017 16:57:46 +0200
Message-ID: <20170814145750.6683-3-andrew.zaborowski@intel.com>
In-Reply-To: <20170814145750.6683-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2143659019212409354==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Implement the PBKDF1 and PBKDF2 functions from PKCS#4 - RFC8018.  This
a dependency for the pkcs5_cipher_from_alg_id but is export publically
so that iwd can switch to this implementation and drop its own.
---
 Makefile.am |   6 ++-
 ell/ell.h   |   1 +
 ell/pkcs5.c | 161 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++=
++++
 ell/pkcs5.h |  47 ++++++++++++++++++
 4 files changed, 213 insertions(+), 2 deletions(-)
 create mode 100644 ell/pkcs5.c
 create mode 100644 ell/pkcs5.h

diff --git a/Makefile.am b/Makefile.am
index 603b692..7f680b9 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -40,7 +40,8 @@ pkginclude_HEADERS =3D ell/ell.h \
 			ell/pem.h \
 			ell/tls.h \
 			ell/uuid.h \
-			ell/key.h
+			ell/key.h \
+			ell/pkcs5.h
 =

 lib_LTLIBRARIES =3D ell/libell.la
 =

@@ -89,7 +90,8 @@ ell_libell_la_SOURCES =3D $(linux_headers) \
 			ell/tls.c \
 			ell/tls-record.c \
 			ell/uuid.c \
-			ell/key.c
+			ell/key.c \
+			ell/pkcs5.c
 =

 ell_libell_la_LDFLAGS =3D -no-undefined \
 			-version-info $(ELL_CURRENT):$(ELL_REVISION):$(ELL_AGE)
diff --git a/ell/ell.h b/ell/ell.h
index 390743f..b43804d 100644
--- a/ell/ell.h
+++ b/ell/ell.h
@@ -44,6 +44,7 @@
 #include <ell/tls.h>
 #include <ell/uuid.h>
 #include <ell/key.h>
+#include <ell/pkcs5.h>
 =

 #include <ell/netlink.h>
 #include <ell/genl.h>
diff --git a/ell/pkcs5.c b/ell/pkcs5.c
new file mode 100644
index 0000000..f75b840
--- /dev/null
+++ b/ell/pkcs5.c
@@ -0,0 +1,161 @@
+/*
+ *
+ *  Embedded Linux library
+ *
+ *  Copyright (C) 2017  Intel Corporation. All rights reserved.
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
+#include "checksum.h"
+#include "private.h"
+#include "pkcs5.h"
+
+/* RFC8018 section 5.1 */
+LIB_EXPORT bool l_pkcs5_pbkdf1(enum l_checksum_type type, const char *pass=
word,
+				const uint8_t *salt, size_t salt_len,
+				unsigned int iter_count,
+				uint8_t *out_dk, size_t dk_len)
+{
+	size_t hash_len, t_len;
+	uint8_t t[20 + salt_len + strlen(password)];
+	struct l_checksum *checksum;
+
+	switch (type) {
+	case L_CHECKSUM_MD5:
+		hash_len =3D 16;
+		break;
+	case L_CHECKSUM_SHA1:
+		hash_len =3D 20;
+		break;
+	default:
+		return false;
+	}
+
+	if (dk_len > hash_len)
+		return false;
+
+	checksum =3D l_checksum_new(type);
+	if (!checksum)
+		return false;
+
+	memcpy(t, password, strlen(password));
+	memcpy(t + strlen(password), salt, salt_len);
+	t_len =3D strlen(password) + salt_len;
+
+	while (iter_count) {
+		l_checksum_reset(checksum);
+
+		if (!l_checksum_update(checksum, t, t_len))
+			break;
+
+		if (l_checksum_get_digest(checksum, t, hash_len) !=3D
+				(ssize_t) hash_len)
+			break;
+
+		t_len =3D hash_len;
+		iter_count--;
+	}
+
+	l_checksum_free(checksum);
+
+	if (iter_count)
+		return false;
+
+	memcpy(out_dk, t, dk_len);
+	return true;
+}
+
+/* RFC8018 section 5.2 */
+LIB_EXPORT bool l_pkcs5_pbkdf2(enum l_checksum_type type, const char *pass=
word,
+				const uint8_t *salt, size_t salt_len,
+				unsigned int iter_count,
+				uint8_t *out_dk, size_t dk_len)
+{
+	size_t h_len;
+	struct l_checksum *checksum;
+	unsigned int i;
+
+	switch (type) {
+	case L_CHECKSUM_SHA1:
+		h_len =3D 20;
+		break;
+	case L_CHECKSUM_SHA224:
+		h_len =3D 28;
+		break;
+	case L_CHECKSUM_SHA256:
+		h_len =3D 32;
+		break;
+	case L_CHECKSUM_SHA384:
+		h_len =3D 48;
+		break;
+	case L_CHECKSUM_SHA512:
+		h_len =3D 64;
+		break;
+	default:
+		return false;
+	}
+
+	checksum =3D l_checksum_new_hmac(type, password, strlen(password));
+	if (!checksum)
+		return false;
+
+	for (i =3D 1; dk_len; i++) {
+		unsigned int j, k;
+		uint8_t u[salt_len + 64];
+		size_t u_len;
+		size_t block_len =3D h_len;
+
+		if (block_len > dk_len)
+			block_len =3D dk_len;
+
+		memset(out_dk, 0, block_len);
+
+		memcpy(u, salt, salt_len);
+		l_put_be32(i, u + salt_len);
+		u_len =3D salt_len + 4;
+
+		for (j =3D 0; j < iter_count; j++) {
+			l_checksum_reset(checksum);
+
+			if (!l_checksum_update(checksum, u, u_len))
+				break;
+
+			if (l_checksum_get_digest(checksum, u, h_len) !=3D
+					(ssize_t) h_len)
+				break;
+
+			u_len =3D h_len;
+
+			for (k =3D 0; k < block_len; k++)
+				out_dk[k] ^=3D u[k];
+		}
+
+		if (j < iter_count)
+			break;
+
+		out_dk +=3D block_len;
+		dk_len -=3D block_len;
+	}
+
+	l_checksum_free(checksum);
+
+	return !dk_len;
+}
diff --git a/ell/pkcs5.h b/ell/pkcs5.h
new file mode 100644
index 0000000..ff7bdfd
--- /dev/null
+++ b/ell/pkcs5.h
@@ -0,0 +1,47 @@
+/*
+ *
+ *  Embedded Linux library
+ *
+ *  Copyright (C) 2017  Intel Corporation. All rights reserved.
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
+#ifndef __ELL_PKCS5_H
+#define __ELL_PKCS5_H
+
+#ifdef __cplusplus
+extern "C" {
+#endif
+
+#include <stdbool.h>
+#include <stdint.h>
+
+bool l_pkcs5_pbkdf1(enum l_checksum_type type, const char *password,
+			const uint8_t *salt, size_t salt_len,
+			unsigned int iter_count,
+			uint8_t *out_dk, size_t dk_len);
+
+bool l_pkcs5_pbkdf2(enum l_checksum_type type, const char *password,
+			const uint8_t *salt, size_t salt_len,
+			unsigned int iter_count,
+			uint8_t *out_dk, size_t dk_len);
+
+#ifdef __cplusplus
+}
+#endif
+
+#endif /* __ELL_PKCS5_H */
-- =

2.11.0


--===============2143659019212409354==--

