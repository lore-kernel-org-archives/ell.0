Content-Type: multipart/mixed; boundary="===============3482705814768401003=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH] rtnl: Add neighbor discovery utilities
Date: Wed, 25 Aug 2021 02:40:03 +0200
Message-ID: <20210825004003.296590-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3482705814768401003==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add a few variants of RTNL utilities to look up addresses in the
kernel's neighbour table entries and to add new entries.  This is
basically the ARP (for IPv4) and NDP (for IPv6) tables, that map IP
addresses to hardware addresses.
---
There are three variants of each method, I currently only have a use
case for the ipv4 and ipv6 variants so I'm happy dropping the struct
l_rtnl_address variant.

 ell/ell.sym  |   6 ++
 ell/rtnl.c   | 194 +++++++++++++++++++++++++++++++++++++++++++++++++++
 ell/rtnl.h   |  36 ++++++++++
 ell/useful.h |   4 ++
 4 files changed, 240 insertions(+)

diff --git a/ell/ell.sym b/ell/ell.sym
index b29d98d..8760f2b 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -663,6 +663,12 @@ global:
 	l_rtnl_ifaddr_extract;
 	l_rtnl_ifaddr_add;
 	l_rtnl_ifaddr_delete;
+	l_rtnl_neighbour_get_ipv4_hwaddr;
+	l_rtnl_neighbour_get_ipv6_hwaddr;
+	l_rtnl_neighbour_get_addr_hwaddr;
+	l_rtnl_neighbour_set_ipv4_hwaddr;
+	l_rtnl_neighbour_set_ipv6_hwaddr;
+	l_rtnl_neighbour_set_addr_hwaddr;
 /* icmp6 */
 	l_icmp6_client_new;
 	l_icmp6_client_free;
diff --git a/ell/rtnl.c b/ell/rtnl.c
index 1061105..4d81c48 100644
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

@@ -1311,3 +1315,193 @@ LIB_EXPORT uint32_t l_rtnl_route_delete(struct l_ne=
tlink *rtnl, int ifindex,
 	return _rtnl_route_change(rtnl, RTM_DELROUTE, ifindex, rt,
 						cb, user_data, destroy);
 }
+
+struct rtnl_neighbour_get_data {
+	l_rtnl_neighbour_get_cb_t cb;
+	void *user_data;
+	l_netlink_destroy_func_t destroy;
+};
+
+static void rtnl_neighbour_get_cb(int error, uint16_t type, const void *da=
ta,
+					uint32_t len, void *user_data)
+{
+	struct rtnl_neighbour_get_data *cb_data =3D user_data;
+	const struct ndmsg *ndmsg =3D data;
+	struct rtattr *attr;
+	const uint8_t *hwaddr =3D NULL;
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
+			break;
+		}
+
+	if (!hwaddr)
+		error =3D -EIO;
+
+done:
+	if (cb_data->cb) {
+		cb_data->cb(error, hwaddr, cb_data->user_data);
+		cb_data->cb =3D NULL;
+	}
+}
+
+static void rtnl_neighbour_get_destroy_cb(void *user_data)
+{
+	struct rtnl_neighbour_get_data *cb_data =3D user_data;
+
+	if (cb_data->destroy)
+		cb_data->destroy(cb_data->user_data);
+
+	l_free(cb_data);
+}
+
+static uint32_t rtnl_neighbour_get_hwaddr(struct l_netlink *rtnl,
+					int ifindex, uint8_t family,
+					const void *addr,
+					l_rtnl_neighbour_get_cb_t cb,
+					void *user_data,
+					l_netlink_destroy_func_t destroy)
+{
+	size_t bufsize =3D NLMSG_ALIGN(sizeof(struct ndmsg)) +
+			RTA_SPACE(16); /* NDA_DST */
+	uint8_t buf[bufsize];
+	struct ndmsg *ndmsg =3D (struct ndmsg *) buf;
+	void *rta_buf =3D (void *) ndmsg + NLMSG_ALIGN(sizeof(struct ndmsg));
+	__auto_type cb_data =3D struct_alloc(rtnl_neighbour_get_data,
+						cb, user_data, destroy);
+	uint32_t ret;
+
+	memset(buf, 0, bufsize);
+	ndmsg->ndm_family =3D family;
+	ndmsg->ndm_ifindex =3D ifindex;
+	ndmsg->ndm_flags =3D 0;
+
+	rta_buf +=3D rta_add_address(rta_buf, NDA_DST, family, addr, addr);
+
+	ret =3D l_netlink_send(rtnl, RTM_GETNEIGH, 0, ndmsg,
+				rta_buf - (void *) ndmsg,
+				rtnl_neighbour_get_cb, cb_data,
+				rtnl_neighbour_get_destroy_cb);
+	if (ret)
+		return ret;
+
+	l_free(cb_data);
+	return 0;
+}
+
+LIB_EXPORT uint32_t l_rtnl_neighbour_get_ipv4_hwaddr(struct l_netlink *rtn=
l,
+					int ifindex, uint32_t addr,
+					l_rtnl_neighbour_get_cb_t cb,
+					void *user_data,
+					l_netlink_destroy_func_t destroy)
+{
+	return rtnl_neighbour_get_hwaddr(rtnl, ifindex, AF_INET, &addr,
+						cb, user_data, destroy);
+}
+
+LIB_EXPORT uint32_t l_rtnl_neighbour_get_ipv6_hwaddr(struct l_netlink *rtn=
l,
+					int ifindex, const uint8_t *addr,
+					l_rtnl_neighbour_get_cb_t cb,
+					void *user_data,
+					l_netlink_destroy_func_t destroy)
+{
+	return rtnl_neighbour_get_hwaddr(rtnl, ifindex, AF_INET6, addr,
+						cb, user_data, destroy);
+}
+
+LIB_EXPORT uint32_t l_rtnl_neighbour_get_addr_hwaddr(struct l_netlink *rtn=
l,
+					int ifindex,
+					const struct l_rtnl_address *addr,
+					l_rtnl_neighbour_get_cb_t cb,
+					void *user_data,
+					l_netlink_destroy_func_t destroy)
+{
+	const uint8_t *ip =3D addr->family =3D=3D AF_INET ?
+		(const void *) &addr->in_addr : (const void *) &addr->in6_addr;
+
+	return rtnl_neighbour_get_hwaddr(rtnl, ifindex, addr->family, ip,
+						cb, user_data, destroy);
+}
+
+static uint32_t rtnl_neighbour_set_hwaddr(struct l_netlink *rtnl,
+					int ifindex, uint8_t family,
+					const void *addr, const uint8_t *hwaddr,
+					l_netlink_command_func_t cb,
+					void *user_data,
+					l_netlink_destroy_func_t destroy)
+{
+	size_t bufsize =3D NLMSG_ALIGN(sizeof(struct ndmsg)) +
+			RTA_SPACE(16) +      /* NDA_DST */
+			RTA_SPACE(ETH_ALEN); /* NDA_LLADDR */
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
+	rta_buf +=3D rta_add_address(rta_buf, NDA_DST, family, addr, addr);
+	rta_buf +=3D rta_add_data(rta_buf, NDA_LLADDR, hwaddr, ETH_ALEN);
+
+	return l_netlink_send(rtnl, RTM_NEWNEIGH, NLM_F_CREATE | NLM_F_REPLACE,
+				ndmsg, rta_buf - (void *) ndmsg,
+				cb, user_data, destroy);
+}
+
+LIB_EXPORT uint32_t l_rtnl_neighbour_set_ipv4_hwaddr(struct l_netlink *rtn=
l,
+					int ifindex, uint32_t addr,
+					const uint8_t *hwaddr,
+					l_netlink_command_func_t cb,
+					void *user_data,
+					l_netlink_destroy_func_t destroy)
+{
+	return rtnl_neighbour_set_hwaddr(rtnl, ifindex, AF_INET, &addr,
+						hwaddr, cb, user_data, destroy);
+}
+
+LIB_EXPORT uint32_t l_rtnl_neighbour_set_ipv6_hwaddr(struct l_netlink *rtn=
l,
+					int ifindex, const uint8_t *addr,
+					const uint8_t *hwaddr,
+					l_netlink_command_func_t cb,
+					void *user_data,
+					l_netlink_destroy_func_t destroy)
+{
+	return rtnl_neighbour_set_hwaddr(rtnl, ifindex, AF_INET6, addr,
+						hwaddr, cb, user_data, destroy);
+}
+
+LIB_EXPORT uint32_t l_rtnl_neighbour_set_addr_hwaddr(struct l_netlink *rtn=
l,
+					int ifindex,
+					const struct l_rtnl_address *addr,
+					const uint8_t *hwaddr,
+					l_netlink_command_func_t cb,
+					void *user_data,
+					l_netlink_destroy_func_t destroy)
+{
+	const uint8_t *ip =3D addr->family =3D=3D AF_INET ?
+		(const void *) &addr->in_addr : (const void *) &addr->in6_addr;
+
+	return rtnl_neighbour_set_hwaddr(rtnl, ifindex, addr->family, ip,
+						hwaddr, cb, user_data, destroy);
+}
diff --git a/ell/rtnl.h b/ell/rtnl.h
index 9ea24f5..834cd14 100644
--- a/ell/rtnl.h
+++ b/ell/rtnl.h
@@ -33,6 +33,9 @@ extern "C" {
 struct l_rtnl_address;
 struct l_rtnl_route;
 =

+typedef void (*l_rtnl_neighbour_get_cb_t) (int error, const uint8_t *hwadd=
r,
+						void *user_data);
+
 struct l_rtnl_address *l_rtnl_address_new(const char *ip, uint8_t prefix_l=
en);
 struct l_rtnl_address *l_rtnl_address_clone(const struct l_rtnl_address *o=
rig);
 void l_rtnl_address_free(struct l_rtnl_address *addr);
@@ -191,6 +194,39 @@ uint32_t l_rtnl_route_delete(struct l_netlink *rtnl, i=
nt ifindex,
 					void *user_data,
 					l_netlink_destroy_func_t destroy);
 =

+uint32_t l_rtnl_neighbour_get_ipv4_hwaddr(struct l_netlink *rtnl, int ifin=
dex,
+					uint32_t addr,
+					l_rtnl_neighbour_get_cb_t cb,
+					void *user_data,
+					l_netlink_destroy_func_t destroy);
+uint32_t l_rtnl_neighbour_get_ipv6_hwaddr(struct l_netlink *rtnl, int ifin=
dex,
+					const uint8_t *addr,
+					l_rtnl_neighbour_get_cb_t cb,
+					void *user_data,
+					l_netlink_destroy_func_t destroy);
+uint32_t l_rtnl_neighbour_get_addr_hwaddr(struct l_netlink *rtnl, int ifin=
dex,
+					const struct l_rtnl_address *addr,
+					l_rtnl_neighbour_get_cb_t cb,
+					void *user_data,
+					l_netlink_destroy_func_t destroy);
+uint32_t l_rtnl_neighbour_set_ipv4_hwaddr(struct l_netlink *rtnl, int ifin=
dex,
+					uint32_t addr, const uint8_t *hwaddr,
+					l_netlink_command_func_t cb,
+					void *user_data,
+					l_netlink_destroy_func_t destroy);
+uint32_t l_rtnl_neighbour_set_ipv6_hwaddr(struct l_netlink *rtnl, int ifin=
dex,
+					const uint8_t *addr,
+					const uint8_t *hwaddr,
+					l_netlink_command_func_t cb,
+					void *user_data,
+					l_netlink_destroy_func_t destroy);
+uint32_t l_rtnl_neighbour_set_addr_hwaddr(struct l_netlink *rtnl, int ifin=
dex,
+					const struct l_rtnl_address *addr,
+					const uint8_t *hwaddr,
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

--===============3482705814768401003==--

