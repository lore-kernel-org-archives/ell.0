Content-Type: multipart/mixed; boundary="===============4649032693048075222=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 6/6] examples: Add a netconfig API example/test utility
Date: Mon, 07 Feb 2022 16:07:17 +0100
Message-ID: <20220207150717.60511-6-andrew.zaborowski@intel.com>
In-Reply-To: 20220207150717.60511-1-andrew.zaborowski@intel.com

--===============4649032693048075222==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

A test utility that simply starts netconfig on a given interface and
prints events that occur.  DNS/mdns changes aren't committed to the
system.
---
 Makefile.am               |   4 +-
 examples/netconfig-test.c | 210 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 213 insertions(+), 1 deletion(-)
 create mode 100644 examples/netconfig-test.c

diff --git a/Makefile.am b/Makefile.am
index 8aaefdf..8ccb35e 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -347,7 +347,8 @@ unit_test_data_files =3D unit/settings.test unit/dbus.c=
onf
 examples =3D examples/dbus-service examples/https-client-test \
 		examples/https-server-test examples/dbus-client \
 		examples/dhcp-client examples/dhcp6-client \
-		examples/dhcp-server examples/acd-client
+		examples/dhcp-server examples/acd-client \
+		examples/netconfig-test
 =

 if GLIB
 examples +=3D examples/glib-eventloop
@@ -367,6 +368,7 @@ examples_dhcp_client_LDADD =3D ell/libell-private.la
 examples_dhcp6_client_LDADD =3D ell/libell-private.la
 examples_dhcp_server_LDADD =3D ell/libell-private.la
 examples_acd_client_LDADD =3D ell/libell-private.la
+examples_netconfig_test_LDADD =3D ell/libell-private.la
 =

 noinst_PROGRAMS +=3D tools/certchain-verify tools/genl-discover \
 		   tools/genl-watch tools/genl-request tools/gpio
diff --git a/examples/netconfig-test.c b/examples/netconfig-test.c
new file mode 100644
index 0000000..ee3b4a3
--- /dev/null
+++ b/examples/netconfig-test.c
@@ -0,0 +1,210 @@
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
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif
+
+#define _GNU_SOURCE
+#include <stdio.h>
+#include <unistd.h>
+#include <stdlib.h>
+#include <assert.h>
+#include <signal.h>
+#include <net/if.h>
+#include <sys/socket.h>
+#include <linux/if_arp.h>
+#include <arpa/inet.h>
+#include <getopt.h>
+#include <errno.h>
+
+#include <ell/ell.h>
+
+static bool apply;
+static struct l_netlink *rtnl;
+
+static void do_debug(const char *str, void *user_data)
+{
+	const char *prefix =3D user_data;
+
+	l_info("%s%s", prefix, str);
+}
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
+static void log_addresses(const char *af_str, const char *action,
+				struct l_queue *list)
+{
+	const struct l_queue_entry *entry;
+	uint64_t now =3D l_time_now();
+
+	if (l_queue_isempty(list))
+		return;
+
+	l_info("[netconfig%s] Addresses %s:", af_str, action);
+
+	for (entry =3D l_queue_get_entries(list); entry; entry =3D entry->next) {
+		struct l_rtnl_address *addr =3D entry->data;
+		char ip_str[INET6_ADDRSTRLEN];
+
+		l_rtnl_address_get_address(addr, ip_str);
+		l_info("[netconfig%s] \t%s/%i, lifetime %i s", af_str, ip_str,
+			l_rtnl_address_get_prefix_length(addr),
+			l_rtnl_address_get_valid_lifetime(addr, now));
+	}
+}
+
+static void log_routes(const char *af_str, const char *action,
+			struct l_queue *list)
+{
+	const struct l_queue_entry *entry;
+	uint64_t now =3D l_time_now();
+
+	if (l_queue_isempty(list))
+		return;
+
+	l_info("[netconfig%s] Routes %s:", af_str, action);
+
+	for (entry =3D l_queue_get_entries(list); entry; entry =3D entry->next) {
+		struct l_rtnl_route *rt =3D entry->data;
+		char subnet_str[INET6_ADDRSTRLEN];
+		char gateway_str[INET6_ADDRSTRLEN];
+		uint8_t prefix_len;
+
+		l_rtnl_route_get_dst(rt, subnet_str, &prefix_len);
+		l_rtnl_route_get_gateway(rt, gateway_str);
+		l_info("[netconfig%s] \t%s/%i, gateway %s, lifetime %i s",
+			af_str, subnet_str, prefix_len, gateway_str,
+			l_rtnl_route_get_lifetime(rt, now));
+	}
+}
+
+static void event_handler(struct l_netconfig *netconfig, uint8_t family,
+				enum l_netconfig_event event, void *user_data)
+{
+	const char *af_str =3D family =3D=3D AF_INET ? "v4" : "v6";
+	struct l_queue *added, *updated, *removed;
+
+	switch (event) {
+	case L_NETCONFIG_EVENT_CONFIGURED:
+		l_info("[netconfig%s] Configured", af_str);
+		break;
+	case L_NETCONFIG_EVENT_UPDATED:
+		l_info("[netconfig%s] Updated", af_str);
+		break;
+	case L_NETCONFIG_EVENT_UNCONFIGURED:
+		l_info("[netconfig%s] Unconfigured", af_str);
+		break;
+	case L_NETCONFIG_EVENT_FAILED:
+		l_info("[netconfig%s] Failed", af_str);
+		l_main_quit();
+		return;
+	}
+
+	l_netconfig_get_addresses(netconfig, &added, &updated, &removed);
+	log_addresses(af_str, "added", added);
+	log_addresses(af_str, "updated", updated);
+	log_addresses(af_str, "removed", removed);
+
+	l_netconfig_get_routes(netconfig, &added, &updated, &removed);
+	log_routes(af_str, "added", added);
+	log_routes(af_str, "updated", updated);
+	log_routes(af_str, "removed", removed);
+
+	if (apply)
+		l_netconfig_apply_rtnl(netconfig, rtnl);
+}
+
+static const struct option main_options[] =3D {
+	{ "apply",	 no_argument,		NULL, 'a' },
+	{ }
+};
+
+int main(int argc, char *argv[])
+{
+	struct l_netconfig *netconfig;
+	int ifindex;
+
+	if (argc < 2) {
+                printf("Usage: %s <interface> [options]\n", argv[0]);
+		return EXIT_SUCCESS;
+        }
+
+	ifindex =3D if_nametoindex(argv[1]);
+	if (!ifindex) {
+		fprintf(stderr, "if_nametoindex(%s): %s\n", argv[1],
+			strerror(errno));
+		return EXIT_FAILURE;
+	}
+
+	for (;;) {
+		int opt =3D getopt_long(argc - 2, argv + 2, "a", main_options,
+					NULL);
+
+		if (opt < 0)
+			break;
+
+		switch (opt) {
+		case 'a':
+			apply =3D true;
+			break;
+		}
+	}
+
+	if (!l_main_init())
+		return EXIT_FAILURE;
+
+	if (apply) {
+		rtnl =3D l_netlink_new(NETLINK_ROUTE);
+		if (!rtnl) {
+			fprintf(stderr, "l_netlink_new(NETLINK_ROUTE) error\n");
+			return EXIT_FAILURE;
+		}
+	}
+
+	l_log_set_stderr();
+	l_debug_enable("*");
+
+	netconfig =3D l_netconfig_new(ifindex);
+	l_netconfig_set_event_handler(netconfig, event_handler, NULL, NULL);
+	l_dhcp_client_set_debug(l_netconfig_get_dhcp_client(netconfig),
+				do_debug, "[DHCPv4] ", NULL);
+	l_netconfig_start(netconfig);
+
+	l_main_run_with_signal(signal_handler, NULL);
+
+	l_netconfig_destroy(netconfig);
+	l_main_exit();
+
+	l_netlink_destroy(rtnl);
+
+	return EXIT_SUCCESS;
+}
-- =

2.32.0

--===============4649032693048075222==--

