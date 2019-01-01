Content-Type: multipart/mixed; boundary="===============1805291447951312207=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 04/17] tls: Implement the Supported Elliptic Curves extension
Date: Tue, 01 Jan 2019 20:49:26 +0100
Message-ID: <20190101194939.5974-4-andrew.zaborowski@intel.com>
In-Reply-To: <20190101194939.5974-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1805291447951312207==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Defined in RFC 8422 5.1.1
---
 Makefile.am          |   1 +
 ell/tls-extensions.c | 108 +++++++++++++++++++++++++++++++++++++++++++
 ell/tls-private.h    |  10 ++++
 ell/tls.c            |   3 +-
 4 files changed, 120 insertions(+), 2 deletions(-)
 create mode 100644 ell/tls-extensions.c

diff --git a/Makefile.am b/Makefile.am
index 8401972..297c395 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -102,6 +102,7 @@ ell_libell_la_SOURCES =3D $(linux_headers) \
 			ell/tls-private.h \
 			ell/tls.c \
 			ell/tls-record.c \
+			ell/tls-extensions.c \
 			ell/uuid.c \
 			ell/key.c \
 			ell/pkcs5-private.h \
diff --git a/ell/tls-extensions.c b/ell/tls-extensions.c
new file mode 100644
index 0000000..749b8e6
--- /dev/null
+++ b/ell/tls-extensions.c
@@ -0,0 +1,108 @@
+/*
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
+ */
+
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif
+
+#include <errno.h>
+
+#include "util.h"
+#include "tls.h"
+#include "cipher.h"
+#include "checksum.h"
+#include "cert.h"
+#include "tls-private.h"
+
+static const struct tls_named_curve tls_curve_pref[] =3D {
+	{ "secp256r1", 23, 19, 64 },
+	{ "secp384r1", 24, 20, 96 },
+};
+
+/* RFC 8422, Section 5.1 */
+static ssize_t tls_elliptic_curves_client_write(struct l_tls *tls,
+						uint8_t *buf, size_t len)
+{
+	uint8_t *ptr =3D buf;
+	unsigned int i;
+
+	if (len < 2 + L_ARRAY_SIZE(tls_curve_pref) * 2)
+		return -ENOMEM;
+
+	l_put_be16(L_ARRAY_SIZE(tls_curve_pref) * 2, ptr);
+	ptr +=3D 2;
+
+	for (i =3D 0; i < L_ARRAY_SIZE(tls_curve_pref); i++) {
+		l_put_be16(tls_curve_pref[i].id, ptr);
+		ptr +=3D 2;
+	}
+
+	return ptr - buf;
+}
+
+static bool tls_elliptic_curves_client_handle(struct l_tls *tls,
+						const uint8_t *buf, size_t len)
+{
+	if (len < 2)
+		return false;
+
+	if (l_get_be16(buf) !=3D len - 2 || (len & 1))
+		return false;
+
+	buf +=3D 2;
+	len -=3D 2;
+
+	while (len) {
+		unsigned int i;
+		uint16_t id;
+
+		id =3D l_get_be16(buf);
+		buf +=3D 2;
+		len -=3D 2;
+
+		for (i =3D 0; i < L_ARRAY_SIZE(tls_curve_pref); i++)
+			if (tls_curve_pref[i].id =3D=3D id) {
+				tls->negotiated_curve =3D &tls_curve_pref[i];
+				TLS_DEBUG("Negotiated %s",
+						tls_curve_pref[i].name);
+				return true;
+			}
+	}
+
+	TLS_DEBUG("non-fatal: No common supported elliptic curves");
+	return true;
+}
+
+static bool tls_elliptic_curves_client_absent(struct l_tls *tls)
+{
+	tls->negotiated_curve =3D &tls_curve_pref[0];
+	return true;
+}
+
+const struct tls_hello_extension tls_extensions[] =3D {
+	{
+		"Supported Elliptic Curves", "elliptic_curves", 10,
+		tls_elliptic_curves_client_write,
+		tls_elliptic_curves_client_handle,
+		tls_elliptic_curves_client_absent,
+		NULL, NULL, NULL,
+	},
+	{}
+};
diff --git a/ell/tls-private.h b/ell/tls-private.h
index 5ea8208..d1cfcac 100644
--- a/ell/tls-private.h
+++ b/ell/tls-private.h
@@ -117,6 +117,15 @@ struct tls_hello_extension {
 	bool (*server_handle_absent)(struct l_tls *tls);
 };
 =

+extern const struct tls_hello_extension tls_extensions[];
+
+struct tls_named_curve {
+	const char *name;
+	uint16_t id;
+	unsigned int l_group;
+	size_t point_bytes;
+};
+
 enum tls_handshake_state {
 	TLS_HANDSHAKE_WAIT_START,
 	TLS_HANDSHAKE_WAIT_HELLO,
@@ -198,6 +207,7 @@ struct l_tls {
 	size_t peer_pubkey_size;
 	enum handshake_hash_type signature_hash;
 	const struct tls_hash_algorithm *prf_hmac;
+	const struct tls_named_curve *negotiated_curve;
 =

 	/* SecurityParameters current and pending */
 =

diff --git a/ell/tls.c b/ell/tls.c
index f8ba3d0..ed7f0c7 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -191,6 +191,7 @@ static void tls_reset_handshake(struct l_tls *tls)
 	tls->peer_cert =3D NULL;
 	tls->peer_pubkey =3D NULL;
 	tls->peer_pubkey_size =3D 0;
+	tls->negotiated_curve =3D NULL;
 =

 	for (hash =3D 0; hash < __HANDSHAKE_HASH_COUNT; hash++)
 		tls_drop_handshake_hash(tls, hash);
@@ -709,8 +710,6 @@ static const struct tls_hash_algorithm *tls_set_prf_hma=
c(struct l_tls *tls)
 	return NULL;
 }
 =

-static const struct tls_hello_extension tls_extensions[] =3D {};
-
 enum tls_handshake_type {
 	TLS_HELLO_REQUEST	=3D 0,
 	TLS_CLIENT_HELLO	=3D 1,
-- =

2.19.1


--===============1805291447951312207==--

