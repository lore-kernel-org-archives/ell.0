Content-Type: multipart/mixed; boundary="===============8517490734704011143=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 18/20] examples: basic DHCP server example
Date: Fri, 16 Oct 2020 08:36:33 -0700
Message-ID: <20201016153635.660391-18-prestwoj@gmail.com>
In-Reply-To: <20201016153635.660391-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8517490734704011143==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 .gitignore             |   1 +
 Makefile.am            |   4 +-
 examples/dhcp-server.c | 129 +++++++++++++++++++++++++++++++++++++++++
 3 files changed, 133 insertions(+), 1 deletion(-)
 create mode 100644 examples/dhcp-server.c

diff --git a/.gitignore b/.gitignore
index c3d2790..e963359 100644
--- a/.gitignore
+++ b/.gitignore
@@ -76,6 +76,7 @@ examples/dbus-client
 examples/glib-eventloop
 examples/dhcp-client
 examples/dhcp6-client
+examples/dhcp-server
 test-suite.log
 tools/certchain-verify
 tools/genl-discover
diff --git a/Makefile.am b/Makefile.am
index 9bdf4dc..adedd1f 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -326,7 +326,8 @@ unit_test_data_files =3D unit/settings.test unit/dbus.c=
onf
 =

 examples =3D examples/dbus-service examples/https-client-test \
 		examples/https-server-test examples/dbus-client \
-		examples/dhcp-client examples/dhcp6-client
+		examples/dhcp-client examples/dhcp6-client \
+		examples/dhcp-server
 =

 if GLIB
 examples +=3D examples/glib-eventloop
@@ -344,6 +345,7 @@ examples_glib_eventloop_CFLAGS =3D @GLIB_CFLAGS@
 examples_glib_eventloop_LDADD =3D ell/libell-private.la @GLIB_LIBS@
 examples_dhcp_client_LDADD =3D ell/libell-private.la
 examples_dhcp6_client_LDADD =3D ell/libell-private.la
+examples_dhcp_server_LDADD =3D ell/libell-private.la
 =

 noinst_PROGRAMS +=3D tools/certchain-verify tools/genl-discover \
 		   tools/genl-watch tools/genl-request tools/gpio
diff --git a/examples/dhcp-server.c b/examples/dhcp-server.c
new file mode 100644
index 0000000..33c0983
--- /dev/null
+++ b/examples/dhcp-server.c
@@ -0,0 +1,129 @@
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
+#include <sys/socket.h>
+#include <linux/if_arp.h>
+#include <netinet/in.h>
+#include <arpa/inet.h>
+
+#include <ell/ell.h>
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
+static void destroy_handler(void *data)
+{
+	l_info("DHCP server destroyed");
+}
+
+static void event_handler(struct l_dhcp_server *server,
+					enum l_dhcp_server_event event,
+					void *userdata,
+					const struct l_dhcp_lease *lease)
+{
+	const uint8_t *mac;
+	char *ip;
+
+	switch (event) {
+	case L_DHCP_SERVER_EVENT_NEW_LEASE:
+		mac =3D l_dhcp_lease_get_mac(lease);
+		ip =3D l_dhcp_lease_get_address(lease);
+
+		l_info("New lease client %02x:%02x:%02x:%02x:%02x:%02x %s",
+				mac[0], mac[1], mac[2], mac[3], mac[4], mac[5],
+				ip);
+		l_free(ip);
+		break;
+	case L_DHCP_SERVER_EVENT_LEASE_EXPIRED:
+		break;
+	}
+}
+
+int main(int argc, char *argv[])
+{
+	struct l_dhcp_server *server;
+	int ifindex;
+	uint8_t mac[6];
+	char *dns[] =3D { "192.168.1.1", NULL };
+
+	if (argc < 2) {
+		printf("Usage: %s <interface index>\n", argv[0]);
+		exit(0);
+	}
+
+	ifindex =3D atoi(argv[1]);
+
+	if (!l_net_get_mac_address(ifindex, mac)) {
+		printf("Unable to get address from interface %d\n", ifindex);
+		exit(0);
+	}
+
+	if (!l_main_init())
+		return -1;
+
+	l_log_set_stderr();
+	l_debug_enable("*");
+
+	server =3D l_dhcp_server_new(ifindex);
+	l_dhcp_server_set_ip_range(server, "192.168.1.2", "192.168.1.100");
+	l_dhcp_server_set_netmask(server, "255.255.255.0");
+	l_dhcp_server_set_gateway(server, "192.168.1.1");
+	l_dhcp_server_set_dns(server, dns);
+	l_dhcp_server_set_lease_time(server, 10);
+	l_dhcp_server_set_debug(server, do_debug, "[DHCP SERV] ", NULL);
+	l_dhcp_server_set_event_handler(server, event_handler, NULL,
+						destroy_handler);
+	l_dhcp_server_start(server);
+
+	l_main_run_with_signal(signal_handler, NULL);
+
+	l_dhcp_server_stop(server);
+	l_dhcp_server_destroy(server);
+	l_main_exit();
+
+	return 0;
+}
-- =

2.26.2

--===============8517490734704011143==--

