Content-Type: multipart/mixed; boundary="===============0470120285024265512=="
MIME-Version: 1.0
From: Daniel Wagner <wagi@monom.org>
Subject: [PATCH 1/2] rtnl: Add initial rtnl support
Date: Fri, 14 Feb 2020 17:33:27 +0100
Message-ID: <20200214163328.17647-2-wagi@monom.org>
In-Reply-To: <20200214163328.17647-1-wagi@monom.org>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0470120285024265512==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Import from iwd the rtnlutil helper code. There are no changes expect
prefix the name of the functions.
---
 Makefile.am |   2 +
 ell/ell.h   |   1 +
 ell/rtnl.c  | 641 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 ell/rtnl.h  | 119 ++++++++++
 4 files changed, 763 insertions(+)
 create mode 100644 ell/rtnl.c
 create mode 100644 ell/rtnl.h

diff --git a/Makefile.am b/Makefile.am
index 3ead678ff194..453f0d1b42d0 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -34,6 +34,7 @@ pkginclude_HEADERS =3D ell/ell.h \
 			ell/checksum.h \
 			ell/netlink.h \
 			ell/genl.h \
+			ell/rtnl.h \
 			ell/dbus.h \
 			ell/dbus-service.h \
 			ell/dbus-client.h \
@@ -85,6 +86,7 @@ ell_libell_la_SOURCES =3D $(linux_headers) \
 			ell/netlink.c \
 			ell/genl-private.h \
 			ell/genl.c \
+			ell/rtnl.c \
 			ell/dbus-private.h \
 			ell/dbus.c \
 			ell/dbus-message.c \
diff --git a/ell/ell.h b/ell/ell.h
index 3bb91851fe94..d16d1b2044be 100644
--- a/ell/ell.h
+++ b/ell/ell.h
@@ -52,6 +52,7 @@
 #include <ell/net.h>
 #include <ell/netlink.h>
 #include <ell/genl.h>
+#include <ell/rtnl.h>
 #include <ell/dbus.h>
 #include <ell/dbus-service.h>
 #include <ell/dbus-client.h>
diff --git a/ell/rtnl.c b/ell/rtnl.c
new file mode 100644
index 000000000000..e4ead316a673
--- /dev/null
+++ b/ell/rtnl.c
@@ -0,0 +1,641 @@
+/*
+ *
+ *  Embedded Linux library
+ *
+ *  Copyright (C) 2019  Intel Corporation. All rights reserved.
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
+#include <linux/if.h>
+#include <sys/socket.h>
+#include <arpa/inet.h>
+
+#include "util.h"
+#include "netlink.h"
+#include "log.h"
+#include "rtnl.h"
+
+static size_t rta_add_u8(void *rta_buf, unsigned short type, uint8_t value)
+{
+	struct rtattr *rta =3D rta_buf;
+
+	rta->rta_len =3D RTA_LENGTH(sizeof(uint8_t));
+	rta->rta_type =3D type;
+	*((uint8_t *) RTA_DATA(rta)) =3D value;
+
+	return RTA_SPACE(sizeof(uint8_t));
+}
+
+static size_t rta_add_u32(void *rta_buf, unsigned short type, uint32_t val=
ue)
+{
+	struct rtattr *rta =3D rta_buf;
+
+	rta->rta_len =3D RTA_LENGTH(sizeof(uint32_t));
+	rta->rta_type =3D type;
+	*((uint32_t *) RTA_DATA(rta)) =3D value;
+
+	return RTA_SPACE(sizeof(uint32_t));
+}
+
+static size_t rta_add_data(void *rta_buf, unsigned short type, void *data,
+								size_t data_len)
+{
+	struct rtattr *rta =3D rta_buf;
+
+	rta->rta_len =3D RTA_LENGTH(data_len);
+	rta->rta_type =3D type;
+	memcpy(RTA_DATA(rta), data, data_len);
+
+	return RTA_SPACE(data_len);
+}
+
+uint32_t l_rtnl_set_linkmode_and_operstate(struct l_netlink *rtnl, int ifi=
ndex,
+					uint8_t linkmode, uint8_t operstate,
+					l_netlink_command_func_t cb,
+					void *user_data,
+					l_netlink_destroy_func_t destroy)
+{
+	struct ifinfomsg *rtmmsg;
+	void *rta_buf;
+	size_t bufsize;
+	uint32_t id;
+
+	bufsize =3D NLMSG_ALIGN(sizeof(struct ifinfomsg)) +
+		RTA_SPACE(sizeof(uint8_t)) + RTA_SPACE(sizeof(uint8_t));
+
+	rtmmsg =3D l_malloc(bufsize);
+	memset(rtmmsg, 0, bufsize);
+
+	rtmmsg->ifi_family =3D AF_UNSPEC;
+	rtmmsg->ifi_index =3D ifindex;
+
+	rta_buf =3D (void *) rtmmsg + NLMSG_ALIGN(sizeof(struct ifinfomsg));
+
+	rta_buf +=3D rta_add_u8(rta_buf, IFLA_LINKMODE, linkmode);
+	rta_buf +=3D rta_add_u8(rta_buf, IFLA_OPERSTATE, operstate);
+
+	id =3D l_netlink_send(rtnl, RTM_SETLINK, 0, rtmmsg,
+					rta_buf - (void *) rtmmsg,
+					cb, user_data, destroy);
+	l_free(rtmmsg);
+
+	return id;
+}
+
+uint32_t l_rtnl_set_mac(struct l_netlink *rtnl, int ifindex,
+					const uint8_t addr[static 6],
+					l_netlink_command_func_t cb,
+					void *user_data,
+					l_netlink_destroy_func_t destroy)
+{
+	struct ifinfomsg *rtmmsg;
+	void *rta_buf;
+	size_t bufsize;
+	uint32_t id;
+
+	bufsize =3D NLMSG_ALIGN(sizeof(struct ifinfomsg)) + RTA_SPACE(6);
+
+	rtmmsg =3D l_malloc(bufsize);
+	memset(rtmmsg, 0, bufsize);
+
+	rtmmsg->ifi_family =3D AF_UNSPEC;
+	rtmmsg->ifi_index =3D ifindex;
+
+	rta_buf =3D (void *) rtmmsg + NLMSG_ALIGN(sizeof(struct ifinfomsg));
+
+	rta_buf +=3D rta_add_data(rta_buf, IFLA_ADDRESS, (void *) addr, 6);
+
+	id =3D l_netlink_send(rtnl, RTM_SETLINK, 0, rtmmsg,
+					rta_buf - (void *) rtmmsg,
+					cb, user_data, destroy);
+	l_free(rtmmsg);
+
+	return id;
+}
+
+uint32_t l_rtnl_set_powered(struct l_netlink *rtnl, int ifindex, bool powe=
red,
+				l_netlink_command_func_t cb, void *user_data,
+				l_netlink_destroy_func_t destroy)
+{
+	struct ifinfomsg *rtmmsg;
+	size_t bufsize;
+	uint32_t id;
+
+	bufsize =3D NLMSG_ALIGN(sizeof(struct ifinfomsg));
+
+	rtmmsg =3D l_malloc(bufsize);
+	memset(rtmmsg, 0, bufsize);
+
+	rtmmsg->ifi_family =3D AF_UNSPEC;
+	rtmmsg->ifi_index =3D ifindex;
+	rtmmsg->ifi_change =3D IFF_UP;
+	rtmmsg->ifi_flags =3D powered ? IFF_UP : 0;
+
+	id =3D l_netlink_send(rtnl, RTM_SETLINK, 0, rtmmsg, bufsize,
+					cb, user_data, destroy);
+	l_free(rtmmsg);
+
+	return id;
+}
+
+void l_rtnl_ifaddr_extract(const struct ifaddrmsg *ifa, int bytes,
+				char **label, char **ip, char **broadcast)
+{
+	struct in_addr in_addr;
+	struct rtattr *attr;
+
+	for (attr =3D IFA_RTA(ifa); RTA_OK(attr, bytes);
+						attr =3D RTA_NEXT(attr, bytes)) {
+		switch (attr->rta_type) {
+		case IFA_LOCAL:
+			if (!ip)
+				break;
+
+			in_addr =3D *((struct in_addr *) RTA_DATA(attr));
+			*ip =3D l_strdup(inet_ntoa(in_addr));
+
+			break;
+		case IFA_BROADCAST:
+			if (!broadcast)
+				break;
+
+			in_addr =3D *((struct in_addr *) RTA_DATA(attr));
+			*broadcast =3D l_strdup(inet_ntoa(in_addr));
+
+			break;
+		case IFA_LABEL:
+			if (!label)
+				break;
+
+			*label =3D l_strdup(RTA_DATA(attr));
+			break;
+		}
+	}
+}
+
+uint32_t l_rtnl_ifaddr_get(struct l_netlink *rtnl, l_netlink_command_func_=
t cb,
+					void *user_data,
+					l_netlink_destroy_func_t destroy)
+{
+	struct ifaddrmsg *rtmmsg;
+	uint32_t id;
+
+	rtmmsg =3D l_malloc(sizeof(struct ifaddrmsg));
+	memset(rtmmsg, 0, sizeof(struct ifaddrmsg));
+
+	rtmmsg->ifa_family =3D AF_INET;
+
+	id =3D l_netlink_send(rtnl, RTM_GETADDR, NLM_F_DUMP, rtmmsg,
+				sizeof(struct ifaddrmsg), cb, user_data,
+				destroy);
+
+	l_free(rtmmsg);
+
+	return id;
+}
+
+static uint32_t l_rtnl_ifaddr_change(struct l_netlink *rtnl, uint16_t nlms=
g_type,
+					int ifindex, uint8_t prefix_len,
+					const char *ip, const char *broadcast,
+					l_netlink_command_func_t
+					cb, void *user_data,
+					l_netlink_destroy_func_t destroy)
+{
+	struct ifaddrmsg *rtmmsg;
+	struct in_addr in_addr;
+	void *rta_buf;
+	size_t bufsize;
+	uint32_t id;
+
+	bufsize =3D NLMSG_ALIGN(sizeof(struct ifaddrmsg)) +
+					RTA_SPACE(sizeof(struct in_addr)) +
+					RTA_SPACE(sizeof(struct in_addr));
+
+	rtmmsg =3D l_malloc(bufsize);
+	memset(rtmmsg, 0, bufsize);
+
+	rtmmsg->ifa_index =3D ifindex;
+	rtmmsg->ifa_family =3D AF_INET;
+	rtmmsg->ifa_flags =3D IFA_F_PERMANENT;
+	rtmmsg->ifa_scope =3D RT_SCOPE_UNIVERSE;
+	rtmmsg->ifa_prefixlen =3D prefix_len;
+
+	rta_buf =3D (void *) rtmmsg + NLMSG_ALIGN(sizeof(struct ifaddrmsg));
+
+	if (inet_pton(AF_INET, ip, &in_addr) < 1) {
+		l_free(rtmmsg);
+		return 0;
+	}
+
+	rta_buf +=3D rta_add_data(rta_buf, IFA_LOCAL, &in_addr,
+							sizeof(struct in_addr));
+
+	if (broadcast) {
+		if (inet_pton(AF_INET, broadcast, &in_addr) < 1) {
+			l_free(rtmmsg);
+			return 0;
+		}
+	} else {
+		in_addr.s_addr =3D in_addr.s_addr |
+					htonl(0xFFFFFFFFLU >> prefix_len);
+	}
+
+	rta_buf +=3D rta_add_data(rta_buf, IFA_BROADCAST, &in_addr,
+							sizeof(struct in_addr));
+
+	id =3D l_netlink_send(rtnl, nlmsg_type, 0, rtmmsg,
+						rta_buf - (void *) rtmmsg, cb,
+						user_data, destroy);
+	l_free(rtmmsg);
+
+	return id;
+}
+
+uint32_t l_rtnl_ifaddr_add(struct l_netlink *rtnl, int ifindex,
+				uint8_t prefix_len, const char *ip,
+				const char *broadcast,
+				l_netlink_command_func_t cb, void *user_data,
+				l_netlink_destroy_func_t destroy)
+{
+	return l_rtnl_ifaddr_change(rtnl, RTM_NEWADDR, ifindex, prefix_len, ip,
+					broadcast, cb, user_data, destroy);
+}
+
+uint32_t l_rtnl_ifaddr_delete(struct l_netlink *rtnl, int ifindex,
+				uint8_t prefix_len, const char *ip,
+				const char *broadcast,
+				l_netlink_command_func_t cb, void *user_data,
+				l_netlink_destroy_func_t destroy)
+{
+	return l_rtnl_ifaddr_change(rtnl, RTM_DELADDR, ifindex, prefix_len, ip,
+					broadcast, cb, user_data, destroy);
+}
+
+void l_rtnl_route_extract_ipv4(const struct rtmsg *rtmsg, uint32_t len,
+				uint32_t *ifindex, char **dst, char **gateway,
+				char **src)
+{
+	struct in_addr in_addr;
+	struct rtattr *attr;
+
+	for (attr =3D RTM_RTA(rtmsg); RTA_OK(attr, len);
+						attr =3D RTA_NEXT(attr, len)) {
+		switch (attr->rta_type) {
+		case RTA_DST:
+			if (!dst)
+				break;
+
+			in_addr =3D *((struct in_addr *) RTA_DATA(attr));
+			*dst =3D l_strdup(inet_ntoa(in_addr));
+
+			break;
+		case RTA_GATEWAY:
+			if (!gateway)
+				break;
+
+			in_addr =3D *((struct in_addr *) RTA_DATA(attr));
+			*gateway =3D l_strdup(inet_ntoa(in_addr));
+
+			break;
+		case RTA_PREFSRC:
+			if (!src)
+				break;
+
+			in_addr =3D *((struct in_addr *) RTA_DATA(attr));
+			*src =3D l_strdup(inet_ntoa(in_addr));
+
+			break;
+		case RTA_OIF:
+			if (!ifindex)
+				break;
+
+			*ifindex =3D *((uint32_t *) RTA_DATA(attr));
+			break;
+		}
+	}
+}
+
+uint32_t l_rtnl_route_dump_ipv4(struct l_netlink *rtnl,
+				l_netlink_command_func_t cb, void *user_data,
+				l_netlink_destroy_func_t destroy)
+{
+	struct rtmsg rtmsg;
+
+	memset(&rtmsg, 0, sizeof(struct rtmsg));
+	rtmsg.rtm_family =3D AF_INET;
+
+	return l_netlink_send(rtnl, RTM_GETROUTE, NLM_F_DUMP, &rtmsg,
+					sizeof(struct rtmsg), cb, user_data,
+					destroy);
+}
+
+static uint32_t l_rtnl_route_add(struct l_netlink *rtnl, int ifindex,
+					uint8_t scope, uint8_t dst_len,
+					const char *dst, const char *gateway,
+					const char *src,
+					uint32_t priority_offset, uint8_t proto,
+					l_netlink_command_func_t cb,
+					void *user_data,
+					l_netlink_destroy_func_t destroy)
+{
+	L_AUTO_FREE_VAR(struct rtmsg *, rtmmsg) =3D NULL;
+	struct in_addr in_addr;
+	size_t bufsize;
+	void *rta_buf;
+	uint16_t flags;
+
+	if (!dst && !gateway)
+		return 0;
+
+	bufsize =3D NLMSG_ALIGN(sizeof(struct rtmsg)) +
+			RTA_SPACE(sizeof(uint32_t)) +
+			(priority_offset ? RTA_SPACE(sizeof(uint32_t)) : 0) +
+			(gateway ? RTA_SPACE(sizeof(struct in_addr)) : 0) +
+			(src ? RTA_SPACE(sizeof(struct in_addr)) : 0) +
+			(dst ? RTA_SPACE(sizeof(struct in_addr)) : 0);
+
+	rtmmsg =3D l_malloc(bufsize);
+	memset(rtmmsg, 0, bufsize);
+
+	rtmmsg->rtm_family =3D AF_INET;
+	rtmmsg->rtm_table =3D RT_TABLE_MAIN;
+	rtmmsg->rtm_protocol =3D proto;
+	rtmmsg->rtm_type =3D RTN_UNICAST;
+	rtmmsg->rtm_scope =3D scope;
+
+	flags =3D NLM_F_CREATE | NLM_F_REPLACE;
+
+	rta_buf =3D (void *) rtmmsg + NLMSG_ALIGN(sizeof(struct rtmsg));
+	rta_buf +=3D rta_add_u32(rta_buf, RTA_OIF, ifindex);
+
+	if (priority_offset)
+		rta_buf +=3D rta_add_u32(rta_buf, RTA_PRIORITY,
+						priority_offset + ifindex);
+
+	if (dst) {
+		if (inet_pton(AF_INET, dst, &in_addr) < 1)
+			return 0;
+
+		rtmmsg->rtm_dst_len =3D dst_len;
+		rta_buf +=3D rta_add_data(rta_buf, RTA_DST, &in_addr,
+							sizeof(struct in_addr));
+	}
+
+	if (gateway) {
+		if (inet_pton(AF_INET, gateway, &in_addr) < 1)
+			return 0;
+
+		rta_buf +=3D rta_add_data(rta_buf, RTA_GATEWAY, &in_addr,
+							sizeof(struct in_addr));
+	}
+
+	if (src) {
+		if (inet_pton(AF_INET, src, &in_addr) < 1)
+			return 0;
+
+		rtmmsg->rtm_src_len =3D 32;
+		rta_buf +=3D rta_add_data(rta_buf, RTA_PREFSRC, &in_addr,
+							sizeof(struct in_addr));
+	}
+
+	return l_netlink_send(rtnl, RTM_NEWROUTE, flags, rtmmsg,
+				rta_buf - (void *) rtmmsg, cb, user_data,
+								destroy);
+}
+
+uint32_t l_rtnl_route_ipv4_add_connected(struct l_netlink *rtnl, int ifind=
ex,
+					uint8_t dst_len, const char *dst,
+					const char *src, uint8_t proto,
+					l_netlink_command_func_t cb,
+					void *user_data,
+					l_netlink_destroy_func_t destroy)
+{
+	return l_rtnl_route_add(rtnl, ifindex, RT_SCOPE_LINK, dst_len, dst, NULL,
+				src, 0, proto, cb, user_data, destroy);
+}
+
+uint32_t l_rtnl_route_ipv4_add_gateway(struct l_netlink *rtnl, int ifindex,
+					const char *gateway, const char *src,
+					uint32_t priority_offset,
+					uint8_t proto,
+					l_netlink_command_func_t cb,
+					void *user_data,
+					l_netlink_destroy_func_t destroy)
+{
+	return l_rtnl_route_add(rtnl, ifindex, RT_SCOPE_UNIVERSE, 0, NULL,
+				gateway, src, priority_offset, proto, cb,
+				user_data, destroy);
+}
+
+void l_rtnl_ifaddr_ipv6_extract(const struct ifaddrmsg *ifa, int len, char=
 **ip)
+{
+	struct in6_addr in6_addr;
+	struct rtattr *attr;
+	char address[128];
+
+	for (attr =3D IFA_RTA(ifa); RTA_OK(attr, len);
+						attr =3D RTA_NEXT(attr, len)) {
+		switch (attr->rta_type) {
+		case IFA_ADDRESS:
+			if (!ip)
+				break;
+
+			memcpy(&in6_addr.s6_addr, RTA_DATA(attr),
+						sizeof(in6_addr.s6_addr));
+
+			if (!inet_ntop(AF_INET6, &in6_addr, address,
+							INET6_ADDRSTRLEN)) {
+
+				l_error("rtnl: Failed to extract IPv6 address");
+				break;
+			}
+
+			*ip =3D l_strdup(address);
+
+			break;
+		}
+	}
+}
+
+uint32_t l_rtnl_ifaddr_ipv6_get(struct l_netlink *rtnl,
+				l_netlink_command_func_t cb, void *user_data,
+				l_netlink_destroy_func_t destroy)
+{
+	struct ifaddrmsg *rtmmsg;
+	uint32_t id;
+
+	rtmmsg =3D l_malloc(sizeof(struct ifaddrmsg));
+	memset(rtmmsg, 0, sizeof(struct ifaddrmsg));
+
+	rtmmsg->ifa_family =3D AF_INET6;
+
+	id =3D l_netlink_send(rtnl, RTM_GETADDR, NLM_F_DUMP, rtmmsg,
+				sizeof(struct ifaddrmsg), cb, user_data,
+				destroy);
+
+	l_free(rtmmsg);
+
+	return id;
+}
+
+static uint32_t l_rtnl_ifaddr_ipv6_change(struct l_netlink *rtnl,
+					uint16_t nlmsg_type,
+					int ifindex, uint8_t prefix_len,
+					const char *ip,
+					l_netlink_command_func_t cb,
+					void *user_data,
+					l_netlink_destroy_func_t destroy)
+{
+	struct ifaddrmsg *rtmmsg;
+	struct in6_addr in6_addr;
+	void *rta_buf;
+	size_t bufsize;
+	uint32_t id;
+
+	bufsize =3D NLMSG_ALIGN(sizeof(struct ifaddrmsg)) +
+					RTA_SPACE(sizeof(struct in6_addr));
+
+	rtmmsg =3D l_malloc(bufsize);
+	memset(rtmmsg, 0, bufsize);
+
+	rtmmsg->ifa_index =3D ifindex;
+	rtmmsg->ifa_family =3D AF_INET6;
+	rtmmsg->ifa_flags =3D IFA_F_PERMANENT;
+	rtmmsg->ifa_scope =3D RT_SCOPE_UNIVERSE;
+	rtmmsg->ifa_prefixlen =3D prefix_len;
+
+	rta_buf =3D (void *) rtmmsg + NLMSG_ALIGN(sizeof(struct ifaddrmsg));
+
+	if (inet_pton(AF_INET6, ip, &in6_addr) < 1) {
+		l_free(rtmmsg);
+		return 0;
+	}
+
+	rta_buf +=3D rta_add_data(rta_buf, IFA_LOCAL, &in6_addr,
+						sizeof(struct in6_addr));
+
+	id =3D l_netlink_send(rtnl, nlmsg_type, 0, rtmmsg,
+						rta_buf - (void *) rtmmsg, cb,
+						user_data, destroy);
+	l_free(rtmmsg);
+
+	return id;
+}
+
+uint32_t l_rtnl_ifaddr_ipv6_add(struct l_netlink *rtnl, int ifindex,
+				uint8_t prefix_len, const char *ip,
+				l_netlink_command_func_t cb, void *user_data,
+				l_netlink_destroy_func_t destroy)
+{
+	return l_rtnl_ifaddr_ipv6_change(rtnl, RTM_NEWADDR, ifindex, prefix_len,
+						ip, cb, user_data, destroy);
+}
+
+uint32_t l_rtnl_ifaddr_ipv6_delete(struct l_netlink *rtnl, int ifindex,
+					uint8_t prefix_len, const char *ip,
+					l_netlink_command_func_t cb,
+					void *user_data,
+					l_netlink_destroy_func_t destroy)
+{
+	return l_rtnl_ifaddr_ipv6_change(rtnl, RTM_DELADDR, ifindex, prefix_len,
+						ip, cb, user_data, destroy);
+}
+
+static uint32_t l_rtnl_route_ipv6_change(struct l_netlink *rtnl,
+					uint16_t nlmsg_type, int ifindex,
+					const char *gateway,
+					uint32_t priority_offset,
+					uint8_t proto,
+					l_netlink_command_func_t cb,
+					void *user_data,
+					l_netlink_destroy_func_t destroy)
+{
+	L_AUTO_FREE_VAR(struct rtmsg *, rtmmsg) =3D NULL;
+	struct in6_addr in6_addr;
+	size_t bufsize;
+	void *rta_buf;
+	uint16_t flags;
+
+	if (!gateway)
+		return 0;
+
+	bufsize =3D NLMSG_ALIGN(sizeof(struct rtmsg)) +
+			RTA_SPACE(sizeof(uint32_t)) +
+			(priority_offset ? RTA_SPACE(sizeof(uint32_t)) : 0) +
+			RTA_SPACE(sizeof(struct in6_addr));
+
+	rtmmsg =3D l_malloc(bufsize);
+	memset(rtmmsg, 0, bufsize);
+
+	rtmmsg->rtm_family =3D AF_INET6;
+	rtmmsg->rtm_table =3D RT_TABLE_MAIN;
+	rtmmsg->rtm_protocol =3D proto;
+	rtmmsg->rtm_type =3D RTN_UNICAST;
+	rtmmsg->rtm_scope =3D RT_SCOPE_UNIVERSE;
+
+	flags =3D NLM_F_CREATE | NLM_F_REPLACE;
+
+	rta_buf =3D (void *) rtmmsg + NLMSG_ALIGN(sizeof(struct rtmsg));
+	rta_buf +=3D rta_add_u32(rta_buf, RTA_OIF, ifindex);
+
+	if (priority_offset)
+		rta_buf +=3D rta_add_u32(rta_buf, RTA_PRIORITY,
+						priority_offset + ifindex);
+
+	if (gateway) {
+		if (inet_pton(AF_INET6, gateway, &in6_addr) < 1)
+			return 0;
+
+		rta_buf +=3D rta_add_data(rta_buf, RTA_GATEWAY, &in6_addr,
+						sizeof(struct in6_addr));
+	}
+
+	return l_netlink_send(rtnl, nlmsg_type, flags, rtmmsg,
+				rta_buf - (void *) rtmmsg, cb, user_data,
+								destroy);
+}
+
+uint32_t l_rtnl_route_ipv6_add_gateway(struct l_netlink *rtnl, int ifindex,
+					const char *gateway,
+					uint32_t priority_offset,
+					uint8_t proto,
+					l_netlink_command_func_t cb,
+					void *user_data,
+					l_netlink_destroy_func_t destroy)
+{
+	return l_rtnl_route_ipv6_change(rtnl, RTM_NEWROUTE, ifindex, gateway,
+					priority_offset, proto, cb,
+					user_data, destroy);
+}
+
+uint32_t l_rtnl_route_ipv6_delete_gateway(struct l_netlink *rtnl, int ifin=
dex,
+					const char *gateway,
+					uint32_t priority_offset,
+					uint8_t proto,
+					l_netlink_command_func_t cb,
+					void *user_data,
+					l_netlink_destroy_func_t destroy)
+{
+	return l_rtnl_route_ipv6_change(rtnl, RTM_DELROUTE, ifindex, gateway,
+					priority_offset, proto, cb,
+					user_data, destroy);
+}
diff --git a/ell/rtnl.h b/ell/rtnl.h
new file mode 100644
index 000000000000..14d933313db2
--- /dev/null
+++ b/ell/rtnl.h
@@ -0,0 +1,119 @@
+/*
+ *
+ *  Embedded Linux library
+ *
+ *  Copyright (C) 2019  Intel Corporation. All rights reserved.
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
+#ifndef __ELL_RTNL_H
+#define __ELL_RTNL_H
+
+#include <stdint.h>
+#include <linux/rtnetlink.h>
+
+#ifdef __cplusplus
+extern "C" {
+#endif
+
+uint32_t l_rtnl_set_linkmode_and_operstate(struct l_netlink *rtnl, int ifi=
ndex,
+					uint8_t linkmode, uint8_t operstate,
+					l_netlink_command_func_t cb,
+					void *user_data,
+					l_netlink_destroy_func_t destroy);
+
+uint32_t l_rtnl_set_mac(struct l_netlink *rtnl, int ifindex,
+					const uint8_t addr[static 6],
+					l_netlink_command_func_t cb,
+					void *user_data,
+					l_netlink_destroy_func_t destroy);
+
+uint32_t l_rtnl_set_powered(struct l_netlink *rtnl, int ifindex, bool powe=
red,
+				l_netlink_command_func_t cb, void *user_data,
+				l_netlink_destroy_func_t destroy);
+
+void l_rtnl_ifaddr_extract(const struct ifaddrmsg *ifa, int bytes,
+				char **label, char **ip, char **broadcast);
+uint32_t l_rtnl_ifaddr_get(struct l_netlink *rtnl, l_netlink_command_func_=
t cb,
+				void *user_data,
+				l_netlink_destroy_func_t destroy);
+uint32_t l_rtnl_ifaddr_add(struct l_netlink *rtnl, int ifindex,
+				uint8_t prefix_len, const char *ip,
+				const char *broadcast,
+				l_netlink_command_func_t cb, void *user_data,
+				l_netlink_destroy_func_t destroy);
+uint32_t l_rtnl_ifaddr_delete(struct l_netlink *rtnl, int ifindex,
+				uint8_t prefix_len, const char *ip,
+				const char *broadcast,
+				l_netlink_command_func_t cb, void *user_data,
+				l_netlink_destroy_func_t destroy);
+
+void l_rtnl_route_extract_ipv4(const struct rtmsg *rtmsg, uint32_t len,
+				uint32_t *ifindex, char **dst, char **gateway,
+				char **src);
+uint32_t l_rtnl_route_dump_ipv4(struct l_netlink *rtnl,
+				l_netlink_command_func_t cb, void *user_data,
+				l_netlink_destroy_func_t destroy);
+uint32_t l_rtnl_route_ipv4_add_connected(struct l_netlink *rtnl, int ifind=
ex,
+					uint8_t dst_len, const char *dst,
+					const char *src, uint8_t proto,
+					l_netlink_command_func_t cb,
+					void *user_data,
+					l_netlink_destroy_func_t destroy);
+uint32_t l_rtnl_route_ipv4_add_gateway(struct l_netlink *rtnl, int ifindex,
+					const char *gateway, const char *src,
+					uint32_t priority_offset,
+					uint8_t proto,
+					l_netlink_command_func_t cb,
+					void *user_data,
+					l_netlink_destroy_func_t destroy);
+
+void l_rtnl_ifaddr_ipv6_extract(const struct ifaddrmsg *ifa, int bytes,
+								char **ip);
+uint32_t l_rtnl_ifaddr_ipv6_get(struct l_netlink *rtnl,
+				l_netlink_command_func_t cb,
+				void *user_data,
+				l_netlink_destroy_func_t destroy);
+uint32_t l_rtnl_ifaddr_ipv6_add(struct l_netlink *rtnl, int ifindex,
+				uint8_t prefix_len, const char *ip,
+				l_netlink_command_func_t cb, void *user_data,
+				l_netlink_destroy_func_t destroy);
+uint32_t l_rtnl_ifaddr_ipv6_delete(struct l_netlink *rtnl, int ifindex,
+					uint8_t prefix_len, const char *ip,
+					l_netlink_command_func_t cb,
+					void *user_data,
+					l_netlink_destroy_func_t destroy);
+uint32_t l_rtnl_route_ipv6_add_gateway(struct l_netlink *rtnl, int ifindex,
+					const char *gateway,
+					uint32_t priority_offset,
+					uint8_t proto,
+					l_netlink_command_func_t cb,
+					void *user_data,
+					l_netlink_destroy_func_t destroy);
+uint32_t l_rtnl_route_ipv6_delete_gateway(struct l_netlink *rtnl, int ifin=
dex,
+					const char *gateway,
+					uint32_t priority_offset,
+					uint8_t proto,
+					l_netlink_command_func_t cb,
+					void *user_data,
+					l_netlink_destroy_func_t destroy);
+
+#ifdef __cplusplus
+}
+#endif
+
+#endif /* __ELL_RTNL_H */
-- =

2.25.0
--===============0470120285024265512==--

