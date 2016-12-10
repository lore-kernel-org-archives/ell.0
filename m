Content-Type: multipart/mixed; boundary="===============3225953018075497649=="
MIME-Version: 1.0
From: Markus Ongyerth <ongy@ongy.net>
Subject: [PATCH] Add a timing safe bcmp function
Date: Sat, 10 Dec 2016 21:05:21 +0100
Message-ID: <20161210200521.25603-1-ongy@ongy.net>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3225953018075497649==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

From: Markus Ongyerth <ell@ongy.net>

For comparing cryptographically relevant memory area, a constant time
comparison function is required to prevent timing side channel attacks.
The timingsafe_bcmp function taken from openbsd is such a function.
The l_util_timingsafe_bcmp function exports it for ell.
---
 Makefile.am                   |  4 +++-
 ell/timingsafe-bcmp-private.h | 24 ++++++++++++++++++++++++
 ell/timingsafe-bcmp.c         | 34 ++++++++++++++++++++++++++++++++++
 ell/util.c                    | 12 ++++++++++++
 ell/util.h                    |  2 ++
 5 files changed, 75 insertions(+), 1 deletion(-)
 create mode 100644 ell/timingsafe-bcmp-private.h
 create mode 100644 ell/timingsafe-bcmp.c

diff --git a/Makefile.am b/Makefile.am
index d6863ba..c1892ac 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -91,7 +91,9 @@ ell_libell_la_SOURCES =3D $(linux_headers) \
 			ell/tls.c \
 			ell/tls-record.c \
 			ell/uuid.c \
-			ell/key.c
+			ell/key.c \
+			ell/timingsafe-bcmp.c \
+			ell/timingsafe-bcmp-private.h
 =

 ell_libell_la_LDFLAGS =3D -no-undefined \
 			-version-info $(ELL_CURRENT):$(ELL_REVISION):$(ELL_AGE)
diff --git a/ell/timingsafe-bcmp-private.h b/ell/timingsafe-bcmp-private.h
new file mode 100644
index 0000000..20ccace
--- /dev/null
+++ b/ell/timingsafe-bcmp-private.h
@@ -0,0 +1,24 @@
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
+#include <stdlib.h>
+int timingsafe_bcmp(const void *b1, const void *b2, size_t n);
diff --git a/ell/timingsafe-bcmp.c b/ell/timingsafe-bcmp.c
new file mode 100644
index 0000000..5f686f1
--- /dev/null
+++ b/ell/timingsafe-bcmp.c
@@ -0,0 +1,34 @@
+/*	$OpenBSD: timingsafe_bcmp.c,v 1.3 2015/08/31 02:53:57 guenther Exp $	*/
+/*
+ * Copyright (c) 2010 Damien Miller.  All rights reserved.
+ *
+ * Permission to use, copy, modify, and distribute this software for any
+ * purpose with or without fee is hereby granted, provided that the above
+ * copyright notice and this permission notice appear in all copies.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
+ * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
+ * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
+ * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
+ * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
+ * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
+ * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
+ */
+
+/*
+ * This file is taken from [1] and only modified to fit into the ell
+ * [1] http://cvsweb.openbsd.org/cgi-bin/cvsweb/~checkout~/src/lib/libc/st=
ring/timingsafe_bcmp.c?rev=3D1.3&content-type=3Dtext/plain
+ */
+
+#include "timingsafe-bcmp-private.h"
+
+int
+timingsafe_bcmp(const void *b1, const void *b2, size_t n)
+{
+	const unsigned char *p1 =3D b1, *p2 =3D b2;
+	int ret =3D 0;
+
+	for (; n > 0; n--)
+		ret |=3D *p1++ ^ *p2++;
+	return (ret !=3D 0);
+}
diff --git a/ell/util.c b/ell/util.c
index 98916e5..838c1fd 100644
--- a/ell/util.c
+++ b/ell/util.c
@@ -33,6 +33,7 @@
 =

 #include "util.h"
 #include "private.h"
+#include "timingsafe-bcmp-private.h"
 =

 /**
  * SECTION:util
@@ -681,3 +682,14 @@ LIB_EXPORT const char *l_util_get_debugfs_path(void)
 =

 	return path;
 }
+
+/**
+ * l_util_timingsafe_bcmp:
+ *
+ * A utility function to compare memory areas in time proportional to size.
+ * This should be used to prevent timing attacks when comparing e.g. hashes
+ **/
+LIB_EXPORT int l_util_timingsafe_bcmp(void *m1, void *m2, size_t n)
+{
+	return timingsafe_bcmp(m1, m2, n);
+}
diff --git a/ell/util.h b/ell/util.h
index a77c0b8..748ac57 100644
--- a/ell/util.h
+++ b/ell/util.h
@@ -237,6 +237,8 @@ void l_util_debug(l_util_hexdump_func_t function, void =
*user_data,
 =

 const char *l_util_get_debugfs_path(void);
 =

+int l_util_timingsafe_bcmp(void *m1, void *m2, size_t n);
+
 #ifdef __cplusplus
 }
 #endif
-- =

2.10.2


--===============3225953018075497649==--

