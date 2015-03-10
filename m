Content-Type: multipart/mixed; boundary="===============2519891167796481246=="
MIME-Version: 1.0
From: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>
Subject: [PATCH 3/4] genl: Add a function to grab the message's raw data for
 unit purpose
Date: Tue, 10 Mar 2015 13:14:29 +0200
Message-ID: <1425986070-8808-4-git-send-email-tomasz.bursztyka@linux.intel.com>
In-Reply-To: <1425986070-8808-1-git-send-email-tomasz.bursztyka@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2519891167796481246==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This is a private function only meant to be used in unit test.
---
 Makefile.am        |  1 +
 ell/genl-private.h | 25 +++++++++++++++++++++++++
 2 files changed, 26 insertions(+)
 create mode 100644 ell/genl-private.h

diff --git a/Makefile.am b/Makefile.am
index cea1b7a..ba3ea4f 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -60,6 +60,7 @@ ell_libell_la_SOURCES =3D $(linux_headers) \
 			ell/netlink-private.h \
 			ell/netlink.c \
 			ell/genl.c \
+			ell/genl-private.h \
 			ell/dbus-private.h \
 			ell/dbus.c \
 			ell/dbus-kernel.c \
diff --git a/ell/genl-private.h b/ell/genl-private.h
new file mode 100644
index 0000000..d1b769b
--- /dev/null
+++ b/ell/genl-private.h
@@ -0,0 +1,25 @@
+/*
+ *
+ *  Embedded Linux library
+ *
+ *  Copyright (C) 2015  Intel Corporation. All rights reserved.
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
+#include <ell/genl.h>
+
+const void *_genl_msg_get_as_raw_data(struct l_genl_msg *msg, uint32_t *le=
n);
-- =

2.0.5


--===============2519891167796481246==--

