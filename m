Content-Type: multipart/mixed; boundary="===============3209894977591818461=="
MIME-Version: 1.0
From: James Prestwood <james.prestwood@linux.intel.com>
Subject: [PATCH v2 1/2] time: basic utility for getting the system time
Date: Wed, 23 Jan 2019 14:11:58 -0800
Message-ID: <20190123221159.24449-1-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3209894977591818461==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Timeouts are sometimes overkill for long timeouts, or timeouts that
don't require being immediately serviced once expired. For this
reason the 'time' module was added which allows you to get the system
clock time, as well as some basic APIs to check if two time values are
before/after one another, calculating an offset from a start time, and
finding the diff between two time values. This allows an application
to handle its own timeouts lazily with no tie to the main loop.

The APIs were modeled after the kernel APIs in jiffies.h
---
 Makefile.am |  6 +++--
 ell/ell.h   |  1 +
 ell/ell.sym |  7 ++++++
 ell/time.c  | 72 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 ell/time.h  | 67 +++++++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 151 insertions(+), 2 deletions(-)
 create mode 100644 ell/time.c
 create mode 100644 ell/time.h

diff --git a/Makefile.am b/Makefile.am
index 3eecbe0..1c089ec 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -51,7 +51,8 @@ pkginclude_HEADERS =3D ell/ell.h \
 			ell/dhcp.h \
 			ell/cert.h \
 			ell/ecc.h \
-			ell/ecdh.h
+			ell/ecdh.h \
+			ell/time.h
 =

 lib_LTLIBRARIES =3D ell/libell.la
 =

@@ -121,7 +122,8 @@ ell_libell_la_SOURCES =3D $(linux_headers) \
 			ell/ecc.h \
 			ell/ecc-external.c \
 			ell/ecc.c \
-			ell/ecdh.c
+			ell/ecdh.c \
+			ell/time.c
 =

 ell_libell_la_LDFLAGS =3D -no-undefined \
 			-Wl,--version-script=3D$(top_srcdir)/ell/ell.sym \
diff --git a/ell/ell.h b/ell/ell.h
index aab6417..691bdb2 100644
--- a/ell/ell.h
+++ b/ell/ell.h
@@ -59,3 +59,4 @@
 #include <ell/cert.h>
 #include <ell/ecc.h>
 #include <ell/ecdh.h>
+#include <ell/time.h>
diff --git a/ell/ell.sym b/ell/ell.sym
index 7643a25..d1fb2ff 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -485,6 +485,13 @@ global:
 	/* ecdh */
 	l_ecdh_generate_key_pair;
 	l_ecdh_generate_shared_secret;
+
+	/* time */
+	l_time_now;
+	l_time_after;
+	l_time_before;
+	l_time_offset;
+	l_time_diff;
 local:
 	*;
 };
diff --git a/ell/time.c b/ell/time.c
new file mode 100644
index 0000000..d49478c
--- /dev/null
+++ b/ell/time.c
@@ -0,0 +1,72 @@
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
+#include <time.h>
+
+#include "time.h"
+#include "private.h"
+
+/**
+ * l_time_now:
+ *
+ * Get the running clocktime in microseconds
+ *
+ * Returns: Current clock time in microseconds
+ **/
+LIB_EXPORT uint64_t l_time_now(void)
+{
+	struct timespec now;
+
+	clock_gettime(CLOCK_BOOTTIME, &now);
+
+	return now.tv_sec * 1000000 + now.tv_nsec / 1000;
+}
+
+/**
+ * l_time_after
+ *
+ * Returns: True if time a is after time b
+ **/
+
+/**
+ * l_time_before
+ *
+ * Returns: True if time a is before time b
+ **/
+
+/**
+ * l_time_offset
+ *
+ * @time: Start time to calculate offset
+ * @offset: Amount of time to add to 'time'
+ *
+ * Adds an offset to a time value. This checks for overflow, and if detect=
ed
+ * returns ULONG_MAX.
+ *
+ * Returns: A time value 'time' + 'offset'. Or ULONG_MAX if time + offset
+ * exceeds ULONG_MAX.
+ **/
+
diff --git a/ell/time.h b/ell/time.h
new file mode 100644
index 0000000..227da91
--- /dev/null
+++ b/ell/time.h
@@ -0,0 +1,67 @@
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
+#ifndef __ELL_TIME_H
+#define __ELL_TIME_H
+
+#ifdef __cplusplus
+extern "C" {
+#endif
+
+#include <stdint.h>
+#include <stdbool.h>
+#include <limits.h>
+
+uint64_t l_time_now(void);
+
+static inline bool l_time_after(uint64_t a, uint64_t b)
+{
+	if ((int64_t)(b - a) < 0)
+		return true;
+
+	return false;
+}
+
+static inline bool l_time_before(uint64_t a, uint64_t b)
+{
+	return l_time_after(b, a);
+}
+
+static inline uint64_t l_time_offset(uint64_t time, uint64_t offset)
+{
+	/* check overflow */
+	if ((int64_t)(time + offset) <=3D 0)
+		return ULONG_MAX;
+
+	return time + offset;
+}
+
+static inline uint64_t l_time_diff(uint64_t a, uint64_t b)
+{
+	return (a < b) ? b - a : a - b;
+}
+
+#ifdef __cplusplus
+}
+#endif
+
+#endif /* __ELL_TIME_H */
-- =

2.17.1


--===============3209894977591818461==--

