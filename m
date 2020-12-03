Content-Type: multipart/mixed; boundary="===============0675134289977386015=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 1/7] acd: ACD skeleton
Date: Thu, 03 Dec 2020 12:41:38 -0800
Message-ID: <20201203204144.480090-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0675134289977386015==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Initial skeleton APIs
---
 Makefile.am |   6 ++-
 ell/acd.c   | 116 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 ell/acd.h   |  56 +++++++++++++++++++++++++
 ell/ell.h   |   1 +
 ell/ell.sym |   7 ++++
 5 files changed, 184 insertions(+), 2 deletions(-)
 create mode 100644 ell/acd.c
 create mode 100644 ell/acd.h

diff --git a/Makefile.am b/Makefile.am
index 28082aa..9bb106b 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -58,7 +58,8 @@ pkginclude_HEADERS =3D ell/ell.h \
 			ell/time.h \
 			ell/gpio.h \
 			ell/path.h \
-			ell/icmp6.h
+			ell/icmp6.h \
+			ell/acd.h
 =

 lib_LTLIBRARIES =3D ell/libell.la
 =

@@ -141,7 +142,8 @@ ell_libell_la_SOURCES =3D $(linux_headers) \
 			ell/gpio.c \
 			ell/path.c \
 			ell/icmp6.c \
-			ell/icmp6-private.h
+			ell/icmp6-private.h \
+			ell/acd.c
 =

 ell_libell_la_LDFLAGS =3D -Wl,--no-undefined \
 			-Wl,--version-script=3D$(top_srcdir)/ell/ell.sym \
diff --git a/ell/acd.c b/ell/acd.c
new file mode 100644
index 0000000..11bee06
--- /dev/null
+++ b/ell/acd.c
@@ -0,0 +1,116 @@
+/*
+ *  Embedded Linux library
+ *
+ *  Copyright (C) 2020  Intel Corporation. All rights reserved.
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
+#include <sys/socket.h>
+#include <arpa/inet.h>
+
+#include "private.h"
+#include "acd.h"
+#include "util.h"
+
+struct l_acd {
+	int ifindex;
+
+	uint32_t ip;
+
+	l_acd_event_func_t event_func;
+	l_acd_destroy_func_t destroy;
+	void *user_data;
+
+	l_acd_debug_cb_t debug_handler;
+	l_acd_destroy_func_t debug_destroy;
+	void *debug_data;
+};
+
+LIB_EXPORT struct l_acd *l_acd_new(int ifindex)
+{
+	struct l_acd *acd =3D l_new(struct l_acd, 1);
+
+	acd->ifindex =3D ifindex;
+
+	return acd;
+}
+
+LIB_EXPORT bool l_acd_start(struct l_acd *acd, const char *ip)
+{
+	struct in_addr ia;
+
+	if (unlikely(!acd || !ip))
+		return false;
+
+	if (inet_pton(AF_INET, ip, &ia) !=3D 1)
+		return false;
+
+	acd->ip =3D ntohl(ia.s_addr);
+
+	return true;
+}
+
+LIB_EXPORT bool l_acd_set_event_handler(struct l_acd *acd,
+					l_acd_event_func_t cb,
+					void *user_data,
+					l_acd_destroy_func_t destroy)
+{
+	if (unlikely(!acd))
+		return false;
+
+	acd->event_func =3D cb;
+	acd->destroy =3D destroy;
+	acd->user_data =3D user_data;
+
+	return true;
+}
+
+LIB_EXPORT bool l_acd_stop(struct l_acd *acd)
+{
+	if (unlikely(!acd))
+		return false;
+
+	return true;
+}
+
+LIB_EXPORT void l_acd_destroy(struct l_acd *acd)
+{
+	if (unlikely(!acd))
+		return;
+
+	if (acd->destroy)
+		acd->destroy(acd->user_data);
+
+	l_free(acd);
+}
+
+LIB_EXPORT bool l_acd_set_debug(struct l_acd *acd,
+				l_acd_debug_cb_t function,
+				void *user_data, l_acd_destroy_func_t destory)
+{
+	if (unlikely(!acd))
+		return false;
+
+	acd->debug_handler =3D function;
+	acd->debug_data =3D user_data;
+	acd->debug_destroy =3D destory;
+
+	return true;
+}
diff --git a/ell/acd.h b/ell/acd.h
new file mode 100644
index 0000000..121d119
--- /dev/null
+++ b/ell/acd.h
@@ -0,0 +1,56 @@
+/*
+ *
+ *  Embedded Linux library
+ *
+ *  Copyright (C) 2020  Intel Corporation. All rights reserved.
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
+#ifndef __ELL_ACD_H
+#define __ELL_ACD_H
+
+#ifdef __cplusplus
+extern "C" {
+#endif
+
+#include <stdbool.h>
+
+struct l_acd;
+
+enum l_acd_event {
+	L_ACD_EVENT_AVAILABLE,
+	L_ACD_EVENT_CONFLICT,
+};
+
+typedef void (*l_acd_event_func_t)(enum l_acd_event event, void *user_data=
);
+typedef void (*l_acd_destroy_func_t)(void *user_data);
+
+typedef void (*l_acd_debug_cb_t)(const char *str, void *user_data);
+
+struct l_acd *l_acd_new(int ifindex);
+bool l_acd_start(struct l_acd *acd, const char *ip);
+bool l_acd_set_event_handler(struct l_acd *acd, l_acd_event_func_t cb,
+				void *user_data, l_acd_destroy_func_t destroy);
+bool l_acd_stop(struct l_acd *acd);
+void l_acd_destroy(struct l_acd *acd);
+bool l_acd_set_debug(struct l_acd *acd, l_acd_debug_cb_t function,
+			void *user_data, l_acd_destroy_func_t destory);
+#ifdef __cplusplus
+}
+#endif
+
+#endif /* __ELL_CERT_H */
diff --git a/ell/ell.h b/ell/ell.h
index ef5d83b..6662ad5 100644
--- a/ell/ell.h
+++ b/ell/ell.h
@@ -64,3 +64,4 @@
 #include <ell/time.h>
 #include <ell/gpio.h>
 #include <ell/path.h>
+#include <ell/acd.h>
diff --git a/ell/ell.sym b/ell/ell.sym
index 49689d1..b029b8c 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -654,6 +654,13 @@ global:
 	l_icmp6_client_set_route_priority;
 	l_icmp6_router_get_managed;
 	l_icmp6_router_get_other;
+	/* acd */
+	l_acd_new;
+	l_acd_start;
+	l_acd_set_event_handler;
+	l_acd_stop;
+	l_acd_destroy;
+	l_acd_set_debug;
 local:
 	*;
 };
-- =

2.26.2

--===============0675134289977386015==--

