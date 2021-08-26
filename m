Content-Type: multipart/mixed; boundary="===============6683412223761170697=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH] rtnl: Add neighbor discovery utilities
Date: Fri, 27 Aug 2021 00:47:59 +0200
Message-ID: <20210826224759.334624-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6683412223761170697==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add a few variants of RTNL utilities to look up addresses in the
kernel's neighbour table entries and to add new entries.  This is
basically the ARP (for IPv4) and NDP (for IPv6) tables, that map IP
addresses to hardware addresses.
---
 ell/ell.sym  |   2 +
 ell/rtnl.c   | 127 +++++++++++++++++++++++++++++++++++++++++++++++++++
 ell/rtnl.h   |  17 +++++++
 ell/useful.h |   4 ++
 4 files changed, 150 insertions(+)

diff --git a/ell/ell.sym b/ell/ell.sym
index b29d98d..9fcf334 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -663,6 +663,8 @@ global:
 	l_rtnl_ifaddr_extract;
 	l_rtnl_ifaddr_add;
 	l_rtnl_ifaddr_delete;
+	l_rtnl_neighbor_get_hwaddr;
+	l_rtnl_neighbor_set_hwaddr;
 /* icmp6 */
 	l_icmp6_client_new;
 	l_icmp6_client_free;
diff --git a/ell/rtnl.c b/ell/rtnl.c
index 1061105..4a1a248 100644
--- a/ell/rtnl.c
+++ b/ell/rtnl.c
@@ -27,6 +27,9 @@
 #define _GNU_SOURCE
 #include <linux/if.h>
 #include <linux/icmpv6.h>
+#include <linux/neighbour.h>
+#include <linux/if_ether.h>
+#include <net/if_arp.h>
 #include <sys/socket.h>
 #include <arpa/inet.h>
 #include <errno.h>
@@ -34,6 +37,7 @@
 #include "useful.h"
 #include "netlink.h"
 #include "log.h"
+#include "util.h"
 #include "rtnl.h"
 #include "private.h"
 =

@@ -1311,3 +1315,126 @@ LIB_EXPORT uint32_t l_rtnl_route_delete(struct l_ne=
tlink *rtnl, int ifindex,
 	return _rtnl_route_change(rtnl, RTM_DELROUTE, ifindex, rt,
 						cb, user_data, destroy);
 }
+
+struct rtnl_neighbor_get_data {
+	l_rtnl_neighbor_get_cb_t cb;
+	void *user_data;
+	l_netlink_destroy_func_t destroy;
+};
+
+static void rtnl_neighbor_get_cb(int error, uint16_t type, const void *dat=
a,
+					uint32_t len, void *user_data)
+{
+	struct rtnl_neighbor_get_data *cb_data =3D user_data;
+	const struct ndmsg *ndmsg =3D data;
+	struct rtattr *attr;
+	const uint8_t *hwaddr =3D NULL;
+	size_t hwaddr_len =3D 0;
+
+	if (error !=3D 0)
+		goto done;
+
+	if (type !=3D RTM_NEWNEIGH || len < NLMSG_ALIGN(sizeof(*ndmsg))) {
+		error =3D -EIO;
+		goto done;
+	}
+
+	if (!(ndmsg->ndm_state & (NUD_PERMANENT | NUD_NOARP | NUD_REACHABLE))) {
+		error =3D -ENOENT;
+		goto done;
+	}
+
+	attr =3D (void *) ndmsg + NLMSG_ALIGN(sizeof(*ndmsg));
+	len -=3D NLMSG_ALIGN(sizeof(*ndmsg));
+
+	for (; RTA_OK(attr, len); attr =3D RTA_NEXT(attr, len))
+		switch (attr->rta_type) {
+		case NDA_LLADDR:
+			hwaddr =3D RTA_DATA(attr);
+			hwaddr_len =3D RTA_PAYLOAD(attr);
+			break;
+		}
+
+	if (!hwaddr)
+		error =3D -EIO;
+
+done:
+	if (cb_data->cb) {
+		cb_data->cb(error, hwaddr, hwaddr_len, cb_data->user_data);
+		cb_data->cb =3D NULL;
+	}
+}
+
+static void rtnl_neighbor_get_destroy_cb(void *user_data)
+{
+	struct rtnl_neighbor_get_data *cb_data =3D user_data;
+
+	if (cb_data->destroy)
+		cb_data->destroy(cb_data->user_data);
+
+	l_free(cb_data);
+}
+
+LIB_EXPORT uint32_t l_rtnl_neighbor_get_hwaddr(struct l_netlink *rtnl,
+					int ifindex, int family,
+					const void *ip,
+					l_rtnl_neighbor_get_cb_t cb,
+					void *user_data,
+					l_netlink_destroy_func_t destroy)
+{
+	size_t bufsize =3D NLMSG_ALIGN(sizeof(struct ndmsg)) +
+			RTA_SPACE(16); /* NDA_DST */
+	uint8_t buf[bufsize];
+	struct ndmsg *ndmsg =3D (struct ndmsg *) buf;
+	void *rta_buf =3D (void *) ndmsg + NLMSG_ALIGN(sizeof(struct ndmsg));
+	__auto_type cb_data =3D struct_alloc(rtnl_neighbor_get_data,
+						cb, user_data, destroy);
+	uint32_t ret;
+
+	memset(buf, 0, bufsize);
+	ndmsg->ndm_family =3D family;
+	ndmsg->ndm_ifindex =3D ifindex;
+	ndmsg->ndm_flags =3D 0;
+
+	rta_buf +=3D rta_add_address(rta_buf, NDA_DST, family, ip, ip);
+
+	ret =3D l_netlink_send(rtnl, RTM_GETNEIGH, 0, ndmsg,
+				rta_buf - (void *) ndmsg,
+				rtnl_neighbor_get_cb, cb_data,
+				rtnl_neighbor_get_destroy_cb);
+	if (ret)
+		return ret;
+
+	l_free(cb_data);
+	return 0;
+}
+
+LIB_EXPORT uint32_t l_rtnl_neighbor_set_hwaddr(struct l_netlink *rtnl,
+					int ifindex, int family,
+					const void *ip,
+					const uint8_t *hwaddr,
+					size_t hwaddr_len,
+					l_netlink_command_func_t cb,
+					void *user_data,
+					l_netlink_destroy_func_t destroy)
+{
+	size_t bufsize =3D NLMSG_ALIGN(sizeof(struct ndmsg)) +
+			RTA_SPACE(16) +        /* NDA_DST */
+			RTA_SPACE(hwaddr_len); /* NDA_LLADDR */
+	uint8_t buf[bufsize];
+	struct ndmsg *ndmsg =3D (struct ndmsg *) buf;
+	void *rta_buf =3D (void *) ndmsg + NLMSG_ALIGN(sizeof(struct ndmsg));
+
+	memset(buf, 0, bufsize);
+	ndmsg->ndm_family =3D family;
+	ndmsg->ndm_ifindex =3D ifindex;
+	ndmsg->ndm_flags =3D 0;
+	ndmsg->ndm_state =3D NUD_REACHABLE;
+
+	rta_buf +=3D rta_add_address(rta_buf, NDA_DST, family, ip, ip);
+	rta_buf +=3D rta_add_data(rta_buf, NDA_LLADDR, hwaddr, hwaddr_len);
+
+	return l_netlink_send(rtnl, RTM_NEWNEIGH, NLM_F_CREATE | NLM_F_REPLACE,
+				ndmsg, rta_buf - (void *) ndmsg,
+				cb, user_data, destroy);
+}
diff --git a/ell/rtnl.h b/ell/rtnl.h
index 9ea24f5..85b1370 100644
--- a/ell/rtnl.h
+++ b/ell/rtnl.h
@@ -33,6 +33,10 @@ extern "C" {
 struct l_rtnl_address;
 struct l_rtnl_route;
 =

+typedef void (*l_rtnl_neighbor_get_cb_t) (int error, const uint8_t *hwaddr,
+						size_t hwaddr_len,
+						void *user_data);
+
 struct l_rtnl_address *l_rtnl_address_new(const char *ip, uint8_t prefix_l=
en);
 struct l_rtnl_address *l_rtnl_address_clone(const struct l_rtnl_address *o=
rig);
 void l_rtnl_address_free(struct l_rtnl_address *addr);
@@ -191,6 +195,19 @@ uint32_t l_rtnl_route_delete(struct l_netlink *rtnl, i=
nt ifindex,
 					void *user_data,
 					l_netlink_destroy_func_t destroy);
 =

+uint32_t l_rtnl_neighbor_get_hwaddr(struct l_netlink *rtnl, int ifindex,
+					int family, const void *ip,
+					l_rtnl_neighbor_get_cb_t cb,
+					void *user_data,
+					l_netlink_destroy_func_t destroy);
+uint32_t l_rtnl_neighbor_set_hwaddr(struct l_netlink *rtnl, int ifindex,
+					int family, const void *ip,
+					const uint8_t *hwaddr,
+					size_t hwaddr_len,
+					l_netlink_command_func_t cb,
+					void *user_data,
+					l_netlink_destroy_func_t destroy);
+
 #ifdef __cplusplus
 }
 #endif
diff --git a/ell/useful.h b/ell/useful.h
index d696bc3..b4783ce 100644
--- a/ell/useful.h
+++ b/ell/useful.h
@@ -83,3 +83,7 @@ static inline int secure_select(int select_left, int l, i=
nt r)
 =

 	return r ^ ((l ^ r) & mask);
 }
+
+#define struct_alloc(structname, ...) \
+	(struct structname *) l_memdup(&(struct structname) { __VA_ARGS__ }, \
+					sizeof(struct structname))
-- =

2.30.2

--===============6683412223761170697==--

