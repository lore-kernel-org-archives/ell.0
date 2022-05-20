Content-Type: multipart/mixed; boundary="===============5431484233120587147=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 11/15] netconfig: Write /proc/sys/net files to enable IPv6
Date: Fri, 20 May 2022 17:43:34 +0200
Message-ID: <20220520154338.2056273-11-andrew.zaborowski@intel.com>
In-Reply-To: 20220520154338.2056273-1-andrew.zaborowski@intel.com

--===============5431484233120587147==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Write the accept_ra setting to 0.  On l_netconfig_start if the existing
address dump command finds no link-local address then also try resetting
disable_ipv6 and toggling addr_gen_mode to trigger the kernel to
generate a link-local address.
---
 ell/netconfig.c | 66 ++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 63 insertions(+), 3 deletions(-)

diff --git a/ell/netconfig.c b/ell/netconfig.c
index e3ca85a..ef3227b 100644
--- a/ell/netconfig.c
+++ b/ell/netconfig.c
@@ -28,6 +28,12 @@
 #include <netinet/ip.h>
 #include <arpa/inet.h>
 #include <netinet/icmp6.h>
+#include <net/if.h>
+#include <errno.h>
+#include <sys/types.h>
+#include <sys/stat.h>
+#include <fcntl.h>
+#include <unistd.h>
 =

 #include "private.h"
 #include "useful.h"
@@ -849,6 +855,30 @@ static void netconfig_icmp6_event_handler(struct l_icm=
p6_client *client,
 		netconfig_emit_event(nc, AF_INET6, L_NETCONFIG_EVENT_UPDATE);
 }
 =

+static int netconfig_proc_write_ipv6_setting(struct l_netconfig *nc,
+						const char *setting,
+						const char *value)
+{
+	char ifname[IF_NAMESIZE];
+	_auto_(l_free) char *filename =3D NULL;
+	int fd;
+	int r;
+
+	if (unlikely(!if_indextoname(nc->ifindex, ifname)))
+		return -errno;
+
+	filename =3D l_strdup_printf("/proc/sys/net/ipv6/conf/%s/%s",
+					ifname, setting);
+
+	fd =3D L_TFR(open(filename, O_WRONLY));
+	if (unlikely(fd < 0))
+		return -errno;
+
+	r =3D L_TFR(write(fd, value, strlen(value)));
+	L_TFR(close(fd));
+	return r;
+}
+
 LIB_EXPORT struct l_netconfig *l_netconfig_new(uint32_t ifindex)
 {
 	struct l_netconfig *nc;
@@ -881,6 +911,9 @@ LIB_EXPORT struct l_netconfig *l_netconfig_new(uint32_t=
 ifindex)
 					netconfig_icmp6_event_handler,
 					nc, NULL);
 =

+	/* Disable in-kernel autoconfiguration for the interface */
+	netconfig_proc_write_ipv6_setting(nc, "accept_ra", "0");
+
 	return nc;
 }
 =

@@ -1317,6 +1350,32 @@ static void netconfig_ifaddr_ipv6_dump_cb(int error,=
 uint16_t type,
 	netconfig_ifaddr_ipv6_notify(type, data, len, user_data);
 }
 =

+static void netconfig_ifaddr_ipv6_dump_done_cb(void *user_data)
+{
+	struct l_netconfig *nc =3D user_data;
+
+	/*
+	 * Handle the case of no link-local address having been found during
+	 * the dump.  If nc->ifaddr6_dump_cmd_id is 0, we have found one or
+	 * the dump is being cancelled.  Otherwise try disabing the
+	 * "disable_ipv6" setting for the interface since it may have been
+	 * enabled.  Also write "addr_gen_mode" which triggers regerating
+	 * the link-local addresss on the interface in the kernel if it
+	 * was previously removed.
+	 */
+	if (!nc->ifaddr6_dump_cmd_id || !nc->started)
+		return;
+
+	nc->ifaddr6_dump_cmd_id =3D 0;
+
+	/* "do no generate a link-local address" */
+	netconfig_proc_write_ipv6_setting(nc, "addr_gen_mode", "1");
+	/* "generate address based on EUI64 (default)" */
+	netconfig_proc_write_ipv6_setting(nc, "addr_gen_mode", "0");
+	/* "enable IPv6 operation" */
+	netconfig_proc_write_ipv6_setting(nc, "disable_ipv6", "0");
+}
+
 LIB_EXPORT bool l_netconfig_start(struct l_netconfig *netconfig)
 {
 	if (unlikely(!netconfig || netconfig->started))
@@ -1378,9 +1437,10 @@ configure_ipv6:
 	}
 =

 	netconfig->ifaddr6_dump_cmd_id =3D l_rtnl_ifaddr6_dump(
-						l_rtnl_get(&netconfig->rtnl),
-						netconfig_ifaddr_ipv6_dump_cb,
-						netconfig, NULL);
+					l_rtnl_get(&netconfig->rtnl),
+					netconfig_ifaddr_ipv6_dump_cb,
+					netconfig,
+					netconfig_ifaddr_ipv6_dump_done_cb);
 	if (!netconfig->ifaddr6_dump_cmd_id)
 		goto unregister;
 =

-- =

2.32.0

--===============5431484233120587147==--

