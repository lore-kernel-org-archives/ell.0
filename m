Content-Type: multipart/mixed; boundary="===============3549026691900700612=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 03/17] rtnl: Move l_rtnl_route declaration to private header
Date: Fri, 13 May 2022 16:54:56 +0200
Message-ID: <20220513145510.1408510-3-andrew.zaborowski@intel.com>
In-Reply-To: 20220513145510.1408510-1-andrew.zaborowski@intel.com

--===============3549026691900700612==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Move struct l_rtnl_route declaration to new file ell/rtnl-private.h so
the members can be accessed directly from ell files to save address to
string conversions.
---
 Makefile.am        |  1 +
 ell/rtnl-private.h | 45 +++++++++++++++++++++++++++++++++++++++++++++
 ell/rtnl.c         | 25 +------------------------
 3 files changed, 47 insertions(+), 24 deletions(-)
 create mode 100644 ell/rtnl-private.h

diff --git a/Makefile.am b/Makefile.am
index 8ccb35e..d8ba99c 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -90,6 +90,7 @@ ell_libell_la_SOURCES =3D $(linux_headers) \
 			ell/netlink-private.h \
 			ell/netlink.c \
 			ell/genl.c \
+			ell/rtnl-private.h \
 			ell/rtnl.c \
 			ell/dbus-private.h \
 			ell/dbus.c \
diff --git a/ell/rtnl-private.h b/ell/rtnl-private.h
new file mode 100644
index 0000000..4f1ee4a
--- /dev/null
+++ b/ell/rtnl-private.h
@@ -0,0 +1,45 @@
+/*
+ *
+ *  Embedded Linux library
+ *
+ *  Copyright (C) 2022  Intel Corporation. All rights reserved.
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
+struct l_rtnl_route {
+	uint8_t family;
+	uint8_t scope;
+	uint8_t protocol;
+	union {
+		struct in6_addr in6_addr;
+		struct in_addr in_addr;
+	} gw;
+	union {
+		struct in6_addr in6_addr;
+		struct in_addr in_addr;
+	} dst;
+	uint8_t dst_prefix_len;
+	union {
+		struct in6_addr in6_addr;
+		struct in_addr in_addr;
+	} prefsrc;
+	uint32_t lifetime;
+	uint64_t expiry_time;
+	uint32_t mtu;
+	uint32_t priority;
+	uint8_t preference;
+};
diff --git a/ell/rtnl.c b/ell/rtnl.c
index 690fe7c..b53d049 100644
--- a/ell/rtnl.c
+++ b/ell/rtnl.c
@@ -39,6 +39,7 @@
 #include "log.h"
 #include "util.h"
 #include "time.h"
+#include "rtnl-private.h"
 #include "rtnl.h"
 #include "private.h"
 =

@@ -333,30 +334,6 @@ LIB_EXPORT bool l_rtnl_address_set_scope(struct l_rtnl=
_address *addr,
 	return true;
 }
 =

-struct l_rtnl_route {
-	uint8_t family;
-	uint8_t scope;
-	uint8_t protocol;
-	union {
-		struct in6_addr in6_addr;
-		struct in_addr in_addr;
-	} gw;
-	union {
-		struct in6_addr in6_addr;
-		struct in_addr in_addr;
-	} dst;
-	uint8_t dst_prefix_len;
-	union {
-		struct in6_addr in6_addr;
-		struct in_addr in_addr;
-	} prefsrc;
-	uint32_t lifetime;
-	uint64_t expiry_time;
-	uint32_t mtu;
-	uint32_t priority;
-	uint8_t preference;
-};
-
 LIB_EXPORT struct l_rtnl_route *l_rtnl_route_new_gateway(const char *gw)
 {
 	struct in_addr in_addr;
-- =

2.32.0

--===============3549026691900700612==--

