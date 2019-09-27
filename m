Content-Type: multipart/mixed; boundary="===============4549857785711775271=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 3/5] pem: expose is_{start,end}_boundary
Date: Fri, 27 Sep 2019 12:30:07 -0700
Message-ID: <20190927193009.30262-4-prestwoj@gmail.com>
In-Reply-To: <20190927193009.30262-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4549857785711775271==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Added a new file pem-private.h which exposes these two APIs as
pem_is_start_boundary and pem_is_end_boundary. These will be
used in settings.c for extended group PEM parsing.
---
 ell/pem.c     | 11 +++++++----
 pem-private.h | 33 +++++++++++++++++++++++++++++++++
 2 files changed, 40 insertions(+), 4 deletions(-)
 create mode 100644 pem-private.h

diff --git a/ell/pem.c b/ell/pem.c
index e268f50..7040cd4 100644
--- a/ell/pem.c
+++ b/ell/pem.c
@@ -45,11 +45,12 @@
 #include "cipher.h"
 #include "cert-private.h"
 #include "missing.h"
+#include "pem-private.h"
 =

 #define PEM_START_BOUNDARY	"-----BEGIN "
 #define PEM_END_BOUNDARY	"-----END "
 =

-static const uint8_t *is_start_boundary(const uint8_t *buf, size_t buf_len,
+const uint8_t *pem_is_start_boundary(const uint8_t *buf, size_t buf_len,
 					size_t *label_len)
 {
 	const uint8_t *start, *end, *ptr;
@@ -102,7 +103,7 @@ static const uint8_t *is_start_boundary(const uint8_t *=
buf, size_t buf_len,
 	return start;
 }
 =

-static bool is_end_boundary(const uint8_t *buf, size_t buf_len,
+bool pem_is_end_boundary(const uint8_t *buf, size_t buf_len,
 				const uint8_t *label, size_t label_len)
 {
 	size_t len =3D strlen(PEM_END_BOUNDARY) + label_len + 5;
@@ -144,11 +145,13 @@ static uint8_t *pem_load_buffer(const uint8_t *buf, s=
ize_t buf_len, int index,
 				break;
 =

 		if (!base64_data) {
-			label =3D is_start_boundary(buf, eol - buf, &label_len);
+			label =3D pem_is_start_boundary(buf, eol - buf,
+							&label_len);
 =

 			if (label)
 				base64_data =3D eol;
-		} else if (is_end_boundary(buf, eol - buf, label, label_len)) {
+		} else if (pem_is_end_boundary(buf, eol - buf, label,
+							label_len)) {
 			if (index =3D=3D 0) {
 				data =3D l_base64_decode(
 						(const char *) base64_data,
diff --git a/pem-private.h b/pem-private.h
new file mode 100644
index 0000000..9203881
--- /dev/null
+++ b/pem-private.h
@@ -0,0 +1,33 @@
+/*
+ *
+ *  Embedded Linux library
+ *
+ *  Copyright (C) 2019  Intel Corporation. All rights reserved.
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
+#include <sys/types.h>
+
+const uint8_t *pem_is_start_boundary(const uint8_t *buf, size_t buf_len,
+					size_t *label_len);
+bool pem_is_end_boundary(const uint8_t *buf, size_t buf_len,
+				const uint8_t *label, size_t label_len);
-- =

2.17.1


--===============4549857785711775271==--

