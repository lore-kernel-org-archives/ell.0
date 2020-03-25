Content-Type: multipart/mixed; boundary="===============6434268046948093581=="
MIME-Version: 1.0
From: Daniel Wagner <wagi@monom.org>
Subject: [PATCH] rtnl: Annotate global functions with LIB_EXPORT
Date: Wed, 25 Mar 2020 15:20:42 +0100
Message-ID: <20200325142042.23058-1-wagi@monom.org>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6434268046948093581==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/rtnl.c | 47 ++++++++++++++++++++++++++++-------------------
 1 file changed, 28 insertions(+), 19 deletions(-)

diff --git a/ell/rtnl.c b/ell/rtnl.c
index 7611e82f9843..dc83937b99d1 100644
--- a/ell/rtnl.c
+++ b/ell/rtnl.c
@@ -33,6 +33,7 @@
 #include "netlink.h"
 #include "log.h"
 #include "rtnl.h"
+#include "private.h"
 =

 static size_t rta_add_u8(void *rta_buf, unsigned short type, uint8_t value)
 {
@@ -132,7 +133,8 @@ static void l_rtnl_route_extract(const struct rtmsg *rt=
msg, uint32_t len,
 	}
 }
 =

-uint32_t l_rtnl_set_linkmode_and_operstate(struct l_netlink *rtnl, int ifi=
ndex,
+LIB_EXPORT uint32_t l_rtnl_set_linkmode_and_operstate(struct l_netlink *rt=
nl,
+					int ifindex,
 					uint8_t linkmode, uint8_t operstate,
 					l_netlink_command_func_t cb,
 					void *user_data,
@@ -165,7 +167,7 @@ uint32_t l_rtnl_set_linkmode_and_operstate(struct l_net=
link *rtnl, int ifindex,
 	return id;
 }
 =

-uint32_t l_rtnl_set_mac(struct l_netlink *rtnl, int ifindex,
+LIB_EXPORT uint32_t l_rtnl_set_mac(struct l_netlink *rtnl, int ifindex,
 					const uint8_t addr[static 6],
 					bool power_up,
 					l_netlink_command_func_t cb,
@@ -202,7 +204,8 @@ uint32_t l_rtnl_set_mac(struct l_netlink *rtnl, int ifi=
ndex,
 	return id;
 }
 =

-uint32_t l_rtnl_set_powered(struct l_netlink *rtnl, int ifindex, bool powe=
red,
+LIB_EXPORT uint32_t l_rtnl_set_powered(struct l_netlink *rtnl, int ifindex,
+				bool powered,
 				l_netlink_command_func_t cb, void *user_data,
 				l_netlink_destroy_func_t destroy)
 {
@@ -227,7 +230,7 @@ uint32_t l_rtnl_set_powered(struct l_netlink *rtnl, int=
 ifindex, bool powered,
 	return id;
 }
 =

-void l_rtnl_ifaddr4_extract(const struct ifaddrmsg *ifa, int bytes,
+LIB_EXPORT void l_rtnl_ifaddr4_extract(const struct ifaddrmsg *ifa, int by=
tes,
 				char **label, char **ip, char **broadcast)
 {
 	struct in_addr in_addr;
@@ -262,7 +265,8 @@ void l_rtnl_ifaddr4_extract(const struct ifaddrmsg *ifa=
, int bytes,
 	}
 }
 =

-uint32_t l_rtnl_ifaddr4_dump(struct l_netlink *rtnl, l_netlink_command_fun=
c_t cb,
+LIB_EXPORT uint32_t l_rtnl_ifaddr4_dump(struct l_netlink *rtnl,
+					l_netlink_command_func_t cb,
 					void *user_data,
 					l_netlink_destroy_func_t destroy)
 {
@@ -340,7 +344,7 @@ static uint32_t l_rtnl_ifaddr4_change(struct l_netlink =
*rtnl, uint16_t nlmsg_typ
 	return id;
 }
 =

-uint32_t l_rtnl_ifaddr4_add(struct l_netlink *rtnl, int ifindex,
+LIB_EXPORT uint32_t l_rtnl_ifaddr4_add(struct l_netlink *rtnl, int ifindex,
 				uint8_t prefix_len, const char *ip,
 				const char *broadcast,
 				l_netlink_command_func_t cb, void *user_data,
@@ -350,7 +354,7 @@ uint32_t l_rtnl_ifaddr4_add(struct l_netlink *rtnl, int=
 ifindex,
 					broadcast, cb, user_data, destroy);
 }
 =

-uint32_t l_rtnl_ifaddr4_delete(struct l_netlink *rtnl, int ifindex,
+LIB_EXPORT uint32_t l_rtnl_ifaddr4_delete(struct l_netlink *rtnl, int ifin=
dex,
 				uint8_t prefix_len, const char *ip,
 				const char *broadcast,
 				l_netlink_command_func_t cb, void *user_data,
@@ -360,7 +364,7 @@ uint32_t l_rtnl_ifaddr4_delete(struct l_netlink *rtnl, =
int ifindex,
 					broadcast, cb, user_data, destroy);
 }
 =

-void l_rtnl_route4_extract(const struct rtmsg *rtmsg, uint32_t len,
+LIB_EXPORT void l_rtnl_route4_extract(const struct rtmsg *rtmsg, uint32_t =
len,
 				uint32_t *table, uint32_t *ifindex,
 				char **dst, char **gateway, char **src)
 {
@@ -368,7 +372,7 @@ void l_rtnl_route4_extract(const struct rtmsg *rtmsg, u=
int32_t len,
 				NULL, NULL, dst, gateway, src);
 }
 =

-uint32_t l_rtnl_route4_dump(struct l_netlink *rtnl,
+LIB_EXPORT uint32_t l_rtnl_route4_dump(struct l_netlink *rtnl,
 				l_netlink_command_func_t cb, void *user_data,
 				l_netlink_destroy_func_t destroy)
 {
@@ -456,7 +460,8 @@ static uint32_t l_rtnl_route4_add(struct l_netlink *rtn=
l, int ifindex,
 								destroy);
 }
 =

-uint32_t l_rtnl_route4_add_connected(struct l_netlink *rtnl, int ifindex,
+LIB_EXPORT uint32_t l_rtnl_route4_add_connected(struct l_netlink *rtnl,
+					int ifindex,
 					uint8_t dst_len, const char *dst,
 					const char *src, uint8_t proto,
 					l_netlink_command_func_t cb,
@@ -467,7 +472,8 @@ uint32_t l_rtnl_route4_add_connected(struct l_netlink *=
rtnl, int ifindex,
 				src, 0, proto, cb, user_data, destroy);
 }
 =

-uint32_t l_rtnl_route4_add_gateway(struct l_netlink *rtnl, int ifindex,
+LIB_EXPORT uint32_t l_rtnl_route4_add_gateway(struct l_netlink *rtnl,
+					int ifindex,
 					const char *gateway, const char *src,
 					uint32_t priority_offset,
 					uint8_t proto,
@@ -480,7 +486,8 @@ uint32_t l_rtnl_route4_add_gateway(struct l_netlink *rt=
nl, int ifindex,
 				user_data, destroy);
 }
 =

-void l_rtnl_ifaddr6_extract(const struct ifaddrmsg *ifa, int len, char **i=
p)
+LIB_EXPORT void l_rtnl_ifaddr6_extract(const struct ifaddrmsg *ifa, int le=
n,
+					char **ip)
 {
 	struct in6_addr in6_addr;
 	struct rtattr *attr;
@@ -510,7 +517,7 @@ void l_rtnl_ifaddr6_extract(const struct ifaddrmsg *ifa=
, int len, char **ip)
 	}
 }
 =

-uint32_t l_rtnl_ifaddr6_dump(struct l_netlink *rtnl,
+LIB_EXPORT uint32_t l_rtnl_ifaddr6_dump(struct l_netlink *rtnl,
 				l_netlink_command_func_t cb, void *user_data,
 				l_netlink_destroy_func_t destroy)
 {
@@ -575,7 +582,7 @@ static uint32_t l_rtnl_ifaddr6_change(struct l_netlink =
*rtnl,
 	return id;
 }
 =

-uint32_t l_rtnl_ifaddr6_add(struct l_netlink *rtnl, int ifindex,
+LIB_EXPORT uint32_t l_rtnl_ifaddr6_add(struct l_netlink *rtnl, int ifindex,
 				uint8_t prefix_len, const char *ip,
 				l_netlink_command_func_t cb, void *user_data,
 				l_netlink_destroy_func_t destroy)
@@ -584,7 +591,7 @@ uint32_t l_rtnl_ifaddr6_add(struct l_netlink *rtnl, int=
 ifindex,
 						ip, cb, user_data, destroy);
 }
 =

-uint32_t l_rtnl_ifaddr6_delete(struct l_netlink *rtnl, int ifindex,
+LIB_EXPORT uint32_t l_rtnl_ifaddr6_delete(struct l_netlink *rtnl, int ifin=
dex,
 					uint8_t prefix_len, const char *ip,
 					l_netlink_command_func_t cb,
 					void *user_data,
@@ -594,7 +601,7 @@ uint32_t l_rtnl_ifaddr6_delete(struct l_netlink *rtnl, =
int ifindex,
 						ip, cb, user_data, destroy);
 }
 =

-void l_rtnl_route6_extract(const struct rtmsg *rtmsg, uint32_t len,
+LIB_EXPORT void l_rtnl_route6_extract(const struct rtmsg *rtmsg, uint32_t =
len,
 				uint32_t *table, uint32_t *ifindex,
 				char **dst, char **gateway, char **src)
 {
@@ -602,7 +609,7 @@ void l_rtnl_route6_extract(const struct rtmsg *rtmsg, u=
int32_t len,
 				NULL, NULL, dst, gateway, src);
 }
 =

-uint32_t l_rtnl_route6_dump(struct l_netlink *rtnl,
+LIB_EXPORT uint32_t l_rtnl_route6_dump(struct l_netlink *rtnl,
 				l_netlink_command_func_t cb, void *user_data,
 				l_netlink_destroy_func_t destroy)
 {
@@ -670,7 +677,8 @@ static uint32_t l_rtnl_route6_change(struct l_netlink *=
rtnl,
 								destroy);
 }
 =

-uint32_t l_rtnl_route6_add_gateway(struct l_netlink *rtnl, int ifindex,
+LIB_EXPORT uint32_t l_rtnl_route6_add_gateway(struct l_netlink *rtnl,
+					int ifindex,
 					const char *gateway,
 					uint32_t priority_offset,
 					uint8_t proto,
@@ -683,7 +691,8 @@ uint32_t l_rtnl_route6_add_gateway(struct l_netlink *rt=
nl, int ifindex,
 					user_data, destroy);
 }
 =

-uint32_t l_rtnl_route6_delete_gateway(struct l_netlink *rtnl, int ifindex,
+LIB_EXPORT uint32_t l_rtnl_route6_delete_gateway(struct l_netlink *rtnl,
+					int ifindex,
 					const char *gateway,
 					uint32_t priority_offset,
 					uint8_t proto,
-- =

2.25.1
--===============6434268046948093581==--

