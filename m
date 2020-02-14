Content-Type: multipart/mixed; boundary="===============3296841087535591439=="
MIME-Version: 1.0
From: Daniel Wagner <wagi@monom.org>
Subject: [PATCH 2/2] unit: Add l_rtnl_* unit tests
Date: Fri, 14 Feb 2020 17:33:28 +0100
Message-ID: <20200214163328.17647-3-wagi@monom.org>
In-Reply-To: <20200214163328.17647-1-wagi@monom.org>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3296841087535591439==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Test the get and dump functions because these don't need special
permissions to run.

For testing the other functions we need first setup a test environment
so we don't disturb the hosts routing or IP configuration.
---
 .gitignore       |   1 +
 Makefile.am      |   3 +
 unit/test-rtnl.c | 236 +++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 240 insertions(+)
 create mode 100644 unit/test-rtnl.c

diff --git a/.gitignore b/.gitignore
index 372f0e7d3885..fca4b423678c 100644
--- a/.gitignore
+++ b/.gitignore
@@ -32,6 +32,7 @@ unit/test-checksum
 unit/test-settings
 unit/test-netlink
 unit/test-genl-msg
+unit/test-rtnl
 unit/test-dbus
 unit/test-dbus-message
 unit/test-dbus-message-fds
diff --git a/Makefile.am b/Makefile.am
index 453f0d1b42d0..22b8f3daf5bb 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -167,6 +167,7 @@ unit_tests =3D unit/test-unit \
 			unit/test-settings \
 			unit/test-netlink \
 			unit/test-genl-msg \
+			unit/test-rtnl \
 			unit/test-siphash \
 			unit/test-cipher \
 			unit/test-random \
@@ -249,6 +250,8 @@ unit_test_netlink_LDADD =3D ell/libell-private.la
 =

 unit_test_genl_msg_LDADD =3D ell/libell-private.la
 =

+unit_test_rtnl_LDADD =3D ell/libell-private.la
+
 unit_test_dbus_LDADD =3D ell/libell-private.la
 =

 unit_test_dbus_message_LDADD =3D ell/libell-private.la
diff --git a/unit/test-rtnl.c b/unit/test-rtnl.c
new file mode 100644
index 000000000000..454d0529fe7f
--- /dev/null
+++ b/unit/test-rtnl.c
@@ -0,0 +1,236 @@
+/*
+ *
+ *  Embedded Linux library
+ *
+ *  Copyright (C) 2011-2014  Intel Corporation. All rights reserved.
+ *  Copyright (C) 2020  Daniel Wagner <dwagner@suse.de>
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
+#include <stdio.h>
+#include <unistd.h>
+#include <stdlib.h>
+#include <signal.h>
+#include <sys/wait.h>
+
+#include <ell/ell.h>
+#include "ell/dbus-private.h"
+
+static void signal_handler(uint32_t signo, void *user_data)
+{
+	switch (signo) {
+	case SIGINT:
+	case SIGTERM:
+		l_info("Terminate");
+		l_main_quit();
+		break;
+	}
+}
+
+static struct l_netlink *rtnl;
+
+struct rtnl_test {
+	const char *name;
+	void (*start)(struct l_netlink *rtnl, void *);
+	void *data;
+};
+
+static bool success;
+static struct l_queue *tests;
+static const struct l_queue_entry *current;
+
+static void test_add(const char *name,
+			void (*start)(struct l_netlink *rtnl, void *),
+			void *user_data)
+{
+	struct rtnl_test *test =3D l_new(struct rtnl_test, 1);
+
+	test->name =3D name;
+	test->start =3D start;
+	test->data =3D user_data;
+
+	if (!tests)
+		tests =3D l_queue_new();
+
+	l_queue_push_tail(tests, test);
+}
+
+static void test_next()
+{
+	struct rtnl_test *test;
+
+	if (current)
+		current =3D current->next;
+	else
+		current =3D l_queue_get_entries(tests);
+
+	if (!current) {
+		success =3D true;
+		l_main_quit();
+		return;
+	}
+
+	test =3D current->data;
+
+	l_info("TEST: %s", test->name);
+
+	test->start(rtnl, test->data);
+}
+
+#define test_assert(cond)	\
+	do {	\
+		if (!(cond)) {	\
+			l_info("TEST FAILED in %s at %s:%i: %s",	\
+				__func__, __FILE__, __LINE__,	\
+				L_STRINGIFY(cond));	\
+			l_main_quit();	\
+			return;	\
+		}	\
+	} while (0)
+
+
+static void route_dump_ipv4_cb(int error,
+			uint16_t type, const void *data,
+			uint32_t len, void *user_data)
+{
+	const struct rtmsg *rtmsg =3D data;
+	char *dst =3D NULL, *gateway =3D NULL, *src =3D NULL;
+	uint32_t idx;
+
+	test_assert(!error);
+	test_assert(type =3D=3D RTM_NEWROUTE);
+
+	l_rtnl_route_extract_ipv4(rtmsg, len, &idx, &dst, &gateway, &src);
+
+	l_info("idx %d dst %s gateway %s src %s", idx, dst, gateway, src);
+
+	l_free(dst);
+	l_free(gateway);
+	l_free(src);
+}
+
+static void route_dump_ipv4_destroy_cb(void *user_data)
+{
+	test_next();
+}
+
+static void test_route_dump_ipv4(struct l_netlink *rtnl, void *user_data)
+{
+	test_assert(l_rtnl_route_dump_ipv4(rtnl, route_dump_ipv4_cb,
+					NULL, route_dump_ipv4_destroy_cb));
+}
+
+static void ifaddr_get_cb(int error,
+				uint16_t type, const void *data,
+				uint32_t len, void *user_data)
+{
+	const struct ifaddrmsg *ifa =3D data;
+	char *label =3D NULL, *ip =3D NULL, *broadcast =3D NULL;
+
+	test_assert(!error);
+	test_assert(type =3D=3D RTM_NEWADDR);
+
+	l_rtnl_ifaddr_extract(ifa, len, &label, &ip, &broadcast);
+
+	l_info("label %s ip %s broadcast %s", label, ip, broadcast);
+
+	l_free(label);
+	l_free(ip);
+	l_free(broadcast);
+}
+
+static void ifaddr_get_destroy_cb(void *user_data)
+{
+	test_next();
+}
+
+static void test_ifaddr_get(struct l_netlink *rntl, void *user_data)
+{
+	test_assert(l_rtnl_ifaddr_get(rtnl, ifaddr_get_cb,
+					NULL, ifaddr_get_destroy_cb));
+}
+
+static void ifaddr_ipv6_get_cb(int error,
+				uint16_t type, const void *data,
+				uint32_t len, void *user_data)
+{
+	const struct ifaddrmsg *ifa =3D data;
+	char *ip =3D NULL;
+
+	test_assert(!error);
+	test_assert(type =3D=3D RTM_NEWADDR);
+
+	l_rtnl_ifaddr_ipv6_extract(ifa, len, &ip);
+
+	l_info("ip %s", ip);
+
+	l_free(ip);
+}
+
+static void ifaddr_ipv6_get_destroy_cb(void *user_data)
+{
+	test_next();
+}
+
+static void test_ifaddr_ipv6_get(struct l_netlink *rntl, void *user_data)
+{
+	test_assert(l_rtnl_ifaddr_ipv6_get(rtnl, ifaddr_ipv6_get_cb,
+					NULL, ifaddr_ipv6_get_destroy_cb));
+}
+
+static void test_run(void)
+{
+	success =3D false;
+
+	l_idle_oneshot(test_next, NULL, NULL);
+	l_main_run_with_signal(signal_handler, NULL);
+}
+
+int main(int argc, char *argv[])
+{
+	if (!l_main_init())
+		return -1;
+
+	test_add("Dump IPv4 routing table", test_route_dump_ipv4, NULL);
+	test_add("Get IPv4 address", test_ifaddr_get, NULL);
+	test_add("Get IPv6 address", test_ifaddr_ipv6_get, NULL);
+
+	l_log_set_stderr();
+
+	rtnl =3D l_netlink_new(NETLINK_ROUTE);
+	if (!rtnl)
+		goto done;
+
+	test_run();
+
+	l_netlink_destroy(rtnl);
+
+done:
+	l_queue_destroy(tests, l_free);
+
+	l_main_exit();
+
+	if (!success)
+		abort();
+
+	return 0;
+}
-- =

2.25.0
--===============3296841087535591439==--

