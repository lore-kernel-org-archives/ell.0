Content-Type: multipart/mixed; boundary="===============2737734718716463745=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 7/7] examples: add acd client implementation
Date: Thu, 03 Dec 2020 12:41:44 -0800
Message-ID: <20201203204144.480090-7-prestwoj@gmail.com>
In-Reply-To: <20201203204144.480090-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2737734718716463745==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Very basic ACD client which takes an ifindex and IP and performs
ACD on the network.
---
 Makefile.am           |   3 +-
 examples/acd-client.c | 166 ++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 168 insertions(+), 1 deletion(-)
 create mode 100644 examples/acd-client.c

diff --git a/Makefile.am b/Makefile.am
index 9bb106b..df4bfff 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -335,7 +335,7 @@ unit_test_data_files =3D unit/settings.test unit/dbus.c=
onf
 examples =3D examples/dbus-service examples/https-client-test \
 		examples/https-server-test examples/dbus-client \
 		examples/dhcp-client examples/dhcp6-client \
-		examples/dhcp-server
+		examples/dhcp-server examples/acd-client
 =

 if GLIB
 examples +=3D examples/glib-eventloop
@@ -354,6 +354,7 @@ examples_glib_eventloop_LDADD =3D ell/libell-private.la=
 @GLIB_LIBS@
 examples_dhcp_client_LDADD =3D ell/libell-private.la
 examples_dhcp6_client_LDADD =3D ell/libell-private.la
 examples_dhcp_server_LDADD =3D ell/libell-private.la
+examples_acd_client_LDADD =3D ell/libell-private.la
 =

 noinst_PROGRAMS +=3D tools/certchain-verify tools/genl-discover \
 		   tools/genl-watch tools/genl-request tools/gpio
diff --git a/examples/acd-client.c b/examples/acd-client.c
new file mode 100644
index 0000000..e737288
--- /dev/null
+++ b/examples/acd-client.c
@@ -0,0 +1,166 @@
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
+#include <getopt.h>
+
+#include <ell/ell.h>
+
+static enum l_acd_defend_policy policy =3D L_ACD_DEFEND_POLICY_DEFEND;
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
+static void event_handler(enum l_acd_event event, void *user_data)
+{
+	char *ip =3D user_data;
+
+	switch (event) {
+	case L_ACD_EVENT_CONFLICT:
+		l_info("IP %s conflicts with another host", ip);
+		break;
+	case L_ACD_EVENT_AVAILABLE:
+		l_info("IP %s is available", ip);
+		break;
+	case L_ACD_EVENT_LOST:
+		l_info("IP %s has been lost", ip);
+		l_main_quit();
+		break;
+	}
+
+	if (policy =3D=3D L_ACD_DEFEND_POLICY_NONE)
+		l_main_quit();
+}
+
+static void usage(void)
+{
+	printf("acd-client usage\n"
+		"Usage:\n");
+	printf("\tacd-client <ifindex> <ip> [options]\n");
+	printf("Options:\n"
+		"\t-D, --defend [=3Dpolicy] Keep running to defend address, "
+			"optionally by policy:\n"
+			"\t\tnone: never defend\n"
+			"\t\tdefend: defend once (default)\n"
+			"\t\tinfinite: defend infinitely\n"
+		"\t-n, --no-probes       Disable initial probe stage\n"
+		"\t-d, --debug           Run with debugging on\n");
+}
+
+static const struct option main_options[] =3D {
+	{ "defend",	 optional_argument,	NULL, 'D' },
+	{ "no-probes",	 no_argument,		NULL, 'n' },
+	{ "debug",	 no_argument,		NULL, 'd' },
+	{ }
+};
+
+int main(int argc, char *argv[])
+{
+	struct l_acd *acd;
+	int ifindex;
+	bool debug =3D false;
+	bool no_probe =3D false;
+
+	l_log_set_stderr();
+	l_debug_enable("*");
+
+	if (argc < 3) {
+		usage();
+		exit(0);
+	}
+
+	for (;;) {
+		int opt;
+
+		opt =3D getopt_long(argc - 2, argv + 2, "ndD::",
+					main_options, NULL);
+		if (opt < 0)
+			break;
+
+		switch (opt) {
+		case 'D':
+			if (optarg) {
+				if (!strcmp(optarg, "infinite"))
+					policy =3D L_ACD_DEFEND_POLICY_INFINITE;
+				else if (!strcmp(optarg, "none"))
+					policy =3D L_ACD_DEFEND_POLICY_NONE;
+			}
+
+			break;
+		case 'n':
+			no_probe =3D true;
+			break;
+		case 'd':
+			debug =3D true;
+			break;
+		}
+	}
+
+	ifindex =3D atoi(argv[1]);
+
+	if (!l_main_init())
+		return -1;
+
+	acd =3D l_acd_new(ifindex);
+	l_acd_set_skip_probes(acd, no_probe);
+	l_acd_set_defend_policy(acd, policy);
+
+	if (debug) {
+		l_acd_set_debug(acd, do_debug, "[ACD] ", NULL);
+		l_info("Set debug");
+	}
+	l_acd_set_event_handler(acd, event_handler, argv[2], NULL);
+	l_acd_start(acd, argv[2]);
+
+	l_main_run_with_signal(signal_handler, NULL);
+
+	l_acd_destroy(acd);
+	l_main_exit();
+
+	return 0;
+}
-- =

2.26.2

--===============2737734718716463745==--

