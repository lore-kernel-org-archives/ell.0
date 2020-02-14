Content-Type: multipart/mixed; boundary="===============1916524974034623094=="
MIME-Version: 1.0
From: Daniel Wagner <wagi@monom.org>
Subject: [PATCH 1/2] rtnl: Make IPv4 and IPv6 naming scheme consistent
Date: Fri, 14 Feb 2020 19:23:36 +0100
Message-ID: <20200214182337.11132-2-wagi@monom.org>
In-Reply-To: <20200214182337.11132-1-wagi@monom.org>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1916524974034623094==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add the protocol version into into the function names and drop the
infix 'ipv6' string. This makes it more consistent with the existing
APIs.
---
 ell/rtnl.c       | 52 ++++++++++++++++++++++++------------------------
 ell/rtnl.h       | 28 +++++++++++++-------------
 unit/test-rtnl.c | 42 +++++++++++++++++++-------------------
 3 files changed, 61 insertions(+), 61 deletions(-)

diff --git a/ell/rtnl.c b/ell/rtnl.c
index e4ead316a673..2d3b8dc8e3c1 100644
--- a/ell/rtnl.c
+++ b/ell/rtnl.c
@@ -157,7 +157,7 @@ uint32_t l_rtnl_set_powered(struct l_netlink *rtnl, int=
 ifindex, bool powered,
 	return id;
 }
 =

-void l_rtnl_ifaddr_extract(const struct ifaddrmsg *ifa, int bytes,
+void l_rtnl_ifaddr4_extract(const struct ifaddrmsg *ifa, int bytes,
 				char **label, char **ip, char **broadcast)
 {
 	struct in_addr in_addr;
@@ -192,7 +192,7 @@ void l_rtnl_ifaddr_extract(const struct ifaddrmsg *ifa,=
 int bytes,
 	}
 }
 =

-uint32_t l_rtnl_ifaddr_get(struct l_netlink *rtnl, l_netlink_command_func_=
t cb,
+uint32_t l_rtnl_ifaddr4_get(struct l_netlink *rtnl, l_netlink_command_func=
_t cb,
 					void *user_data,
 					l_netlink_destroy_func_t destroy)
 {
@@ -213,7 +213,7 @@ uint32_t l_rtnl_ifaddr_get(struct l_netlink *rtnl, l_ne=
tlink_command_func_t cb,
 	return id;
 }
 =

-static uint32_t l_rtnl_ifaddr_change(struct l_netlink *rtnl, uint16_t nlms=
g_type,
+static uint32_t l_rtnl_ifaddr4_change(struct l_netlink *rtnl, uint16_t nlm=
sg_type,
 					int ifindex, uint8_t prefix_len,
 					const char *ip, const char *broadcast,
 					l_netlink_command_func_t
@@ -270,27 +270,27 @@ static uint32_t l_rtnl_ifaddr_change(struct l_netlink=
 *rtnl, uint16_t nlmsg_type
 	return id;
 }
 =

-uint32_t l_rtnl_ifaddr_add(struct l_netlink *rtnl, int ifindex,
+uint32_t l_rtnl_ifaddr4_add(struct l_netlink *rtnl, int ifindex,
 				uint8_t prefix_len, const char *ip,
 				const char *broadcast,
 				l_netlink_command_func_t cb, void *user_data,
 				l_netlink_destroy_func_t destroy)
 {
-	return l_rtnl_ifaddr_change(rtnl, RTM_NEWADDR, ifindex, prefix_len, ip,
+	return l_rtnl_ifaddr4_change(rtnl, RTM_NEWADDR, ifindex, prefix_len, ip,
 					broadcast, cb, user_data, destroy);
 }
 =

-uint32_t l_rtnl_ifaddr_delete(struct l_netlink *rtnl, int ifindex,
+uint32_t l_rtnl_ifaddr4_delete(struct l_netlink *rtnl, int ifindex,
 				uint8_t prefix_len, const char *ip,
 				const char *broadcast,
 				l_netlink_command_func_t cb, void *user_data,
 				l_netlink_destroy_func_t destroy)
 {
-	return l_rtnl_ifaddr_change(rtnl, RTM_DELADDR, ifindex, prefix_len, ip,
+	return l_rtnl_ifaddr4_change(rtnl, RTM_DELADDR, ifindex, prefix_len, ip,
 					broadcast, cb, user_data, destroy);
 }
 =

-void l_rtnl_route_extract_ipv4(const struct rtmsg *rtmsg, uint32_t len,
+void l_rtnl_route4_extract(const struct rtmsg *rtmsg, uint32_t len,
 				uint32_t *ifindex, char **dst, char **gateway,
 				char **src)
 {
@@ -334,7 +334,7 @@ void l_rtnl_route_extract_ipv4(const struct rtmsg *rtms=
g, uint32_t len,
 	}
 }
 =

-uint32_t l_rtnl_route_dump_ipv4(struct l_netlink *rtnl,
+uint32_t l_rtnl_route4_dump(struct l_netlink *rtnl,
 				l_netlink_command_func_t cb, void *user_data,
 				l_netlink_destroy_func_t destroy)
 {
@@ -348,7 +348,7 @@ uint32_t l_rtnl_route_dump_ipv4(struct l_netlink *rtnl,
 					destroy);
 }
 =

-static uint32_t l_rtnl_route_add(struct l_netlink *rtnl, int ifindex,
+static uint32_t l_rtnl_route4_add(struct l_netlink *rtnl, int ifindex,
 					uint8_t scope, uint8_t dst_len,
 					const char *dst, const char *gateway,
 					const char *src,
@@ -422,18 +422,18 @@ static uint32_t l_rtnl_route_add(struct l_netlink *rt=
nl, int ifindex,
 								destroy);
 }
 =

-uint32_t l_rtnl_route_ipv4_add_connected(struct l_netlink *rtnl, int ifind=
ex,
+uint32_t l_rtnl_route4_add_connected(struct l_netlink *rtnl, int ifindex,
 					uint8_t dst_len, const char *dst,
 					const char *src, uint8_t proto,
 					l_netlink_command_func_t cb,
 					void *user_data,
 					l_netlink_destroy_func_t destroy)
 {
-	return l_rtnl_route_add(rtnl, ifindex, RT_SCOPE_LINK, dst_len, dst, NULL,
+	return l_rtnl_route4_add(rtnl, ifindex, RT_SCOPE_LINK, dst_len, dst, NULL,
 				src, 0, proto, cb, user_data, destroy);
 }
 =

-uint32_t l_rtnl_route_ipv4_add_gateway(struct l_netlink *rtnl, int ifindex,
+uint32_t l_rtnl_route4_add_gateway(struct l_netlink *rtnl, int ifindex,
 					const char *gateway, const char *src,
 					uint32_t priority_offset,
 					uint8_t proto,
@@ -441,12 +441,12 @@ uint32_t l_rtnl_route_ipv4_add_gateway(struct l_netli=
nk *rtnl, int ifindex,
 					void *user_data,
 					l_netlink_destroy_func_t destroy)
 {
-	return l_rtnl_route_add(rtnl, ifindex, RT_SCOPE_UNIVERSE, 0, NULL,
+	return l_rtnl_route4_add(rtnl, ifindex, RT_SCOPE_UNIVERSE, 0, NULL,
 				gateway, src, priority_offset, proto, cb,
 				user_data, destroy);
 }
 =

-void l_rtnl_ifaddr_ipv6_extract(const struct ifaddrmsg *ifa, int len, char=
 **ip)
+void l_rtnl_ifaddr6_extract(const struct ifaddrmsg *ifa, int len, char **i=
p)
 {
 	struct in6_addr in6_addr;
 	struct rtattr *attr;
@@ -476,7 +476,7 @@ void l_rtnl_ifaddr_ipv6_extract(const struct ifaddrmsg =
*ifa, int len, char **ip)
 	}
 }
 =

-uint32_t l_rtnl_ifaddr_ipv6_get(struct l_netlink *rtnl,
+uint32_t l_rtnl_ifaddr6_get(struct l_netlink *rtnl,
 				l_netlink_command_func_t cb, void *user_data,
 				l_netlink_destroy_func_t destroy)
 {
@@ -497,7 +497,7 @@ uint32_t l_rtnl_ifaddr_ipv6_get(struct l_netlink *rtnl,
 	return id;
 }
 =

-static uint32_t l_rtnl_ifaddr_ipv6_change(struct l_netlink *rtnl,
+static uint32_t l_rtnl_ifaddr6_change(struct l_netlink *rtnl,
 					uint16_t nlmsg_type,
 					int ifindex, uint8_t prefix_len,
 					const char *ip,
@@ -541,26 +541,26 @@ static uint32_t l_rtnl_ifaddr_ipv6_change(struct l_ne=
tlink *rtnl,
 	return id;
 }
 =

-uint32_t l_rtnl_ifaddr_ipv6_add(struct l_netlink *rtnl, int ifindex,
+uint32_t l_rtnl_ifaddr6_add(struct l_netlink *rtnl, int ifindex,
 				uint8_t prefix_len, const char *ip,
 				l_netlink_command_func_t cb, void *user_data,
 				l_netlink_destroy_func_t destroy)
 {
-	return l_rtnl_ifaddr_ipv6_change(rtnl, RTM_NEWADDR, ifindex, prefix_len,
+	return l_rtnl_ifaddr6_change(rtnl, RTM_NEWADDR, ifindex, prefix_len,
 						ip, cb, user_data, destroy);
 }
 =

-uint32_t l_rtnl_ifaddr_ipv6_delete(struct l_netlink *rtnl, int ifindex,
+uint32_t l_rtnl_ifaddr6_delete(struct l_netlink *rtnl, int ifindex,
 					uint8_t prefix_len, const char *ip,
 					l_netlink_command_func_t cb,
 					void *user_data,
 					l_netlink_destroy_func_t destroy)
 {
-	return l_rtnl_ifaddr_ipv6_change(rtnl, RTM_DELADDR, ifindex, prefix_len,
+	return l_rtnl_ifaddr6_change(rtnl, RTM_DELADDR, ifindex, prefix_len,
 						ip, cb, user_data, destroy);
 }
 =

-static uint32_t l_rtnl_route_ipv6_change(struct l_netlink *rtnl,
+static uint32_t l_rtnl_route6_change(struct l_netlink *rtnl,
 					uint16_t nlmsg_type, int ifindex,
 					const char *gateway,
 					uint32_t priority_offset,
@@ -614,7 +614,7 @@ static uint32_t l_rtnl_route_ipv6_change(struct l_netli=
nk *rtnl,
 								destroy);
 }
 =

-uint32_t l_rtnl_route_ipv6_add_gateway(struct l_netlink *rtnl, int ifindex,
+uint32_t l_rtnl_route6_add_gateway(struct l_netlink *rtnl, int ifindex,
 					const char *gateway,
 					uint32_t priority_offset,
 					uint8_t proto,
@@ -622,12 +622,12 @@ uint32_t l_rtnl_route_ipv6_add_gateway(struct l_netli=
nk *rtnl, int ifindex,
 					void *user_data,
 					l_netlink_destroy_func_t destroy)
 {
-	return l_rtnl_route_ipv6_change(rtnl, RTM_NEWROUTE, ifindex, gateway,
+	return l_rtnl_route6_change(rtnl, RTM_NEWROUTE, ifindex, gateway,
 					priority_offset, proto, cb,
 					user_data, destroy);
 }
 =

-uint32_t l_rtnl_route_ipv6_delete_gateway(struct l_netlink *rtnl, int ifin=
dex,
+uint32_t l_rtnl_route6_delete_gateway(struct l_netlink *rtnl, int ifindex,
 					const char *gateway,
 					uint32_t priority_offset,
 					uint8_t proto,
@@ -635,7 +635,7 @@ uint32_t l_rtnl_route_ipv6_delete_gateway(struct l_netl=
ink *rtnl, int ifindex,
 					void *user_data,
 					l_netlink_destroy_func_t destroy)
 {
-	return l_rtnl_route_ipv6_change(rtnl, RTM_DELROUTE, ifindex, gateway,
+	return l_rtnl_route6_change(rtnl, RTM_DELROUTE, ifindex, gateway,
 					priority_offset, proto, cb,
 					user_data, destroy);
 }
diff --git a/ell/rtnl.h b/ell/rtnl.h
index 14d933313db2..5629eac20416 100644
--- a/ell/rtnl.h
+++ b/ell/rtnl.h
@@ -46,35 +46,35 @@ uint32_t l_rtnl_set_powered(struct l_netlink *rtnl, int=
 ifindex, bool powered,
 				l_netlink_command_func_t cb, void *user_data,
 				l_netlink_destroy_func_t destroy);
 =

-void l_rtnl_ifaddr_extract(const struct ifaddrmsg *ifa, int bytes,
+void l_rtnl_ifaddr4_extract(const struct ifaddrmsg *ifa, int bytes,
 				char **label, char **ip, char **broadcast);
-uint32_t l_rtnl_ifaddr_get(struct l_netlink *rtnl, l_netlink_command_func_=
t cb,
+uint32_t l_rtnl_ifaddr4_get(struct l_netlink *rtnl, l_netlink_command_func=
_t cb,
 				void *user_data,
 				l_netlink_destroy_func_t destroy);
-uint32_t l_rtnl_ifaddr_add(struct l_netlink *rtnl, int ifindex,
+uint32_t l_rtnl_ifaddr4_add(struct l_netlink *rtnl, int ifindex,
 				uint8_t prefix_len, const char *ip,
 				const char *broadcast,
 				l_netlink_command_func_t cb, void *user_data,
 				l_netlink_destroy_func_t destroy);
-uint32_t l_rtnl_ifaddr_delete(struct l_netlink *rtnl, int ifindex,
+uint32_t l_rtnl_ifaddr4_delete(struct l_netlink *rtnl, int ifindex,
 				uint8_t prefix_len, const char *ip,
 				const char *broadcast,
 				l_netlink_command_func_t cb, void *user_data,
 				l_netlink_destroy_func_t destroy);
 =

-void l_rtnl_route_extract_ipv4(const struct rtmsg *rtmsg, uint32_t len,
+void l_rtnl_route4_extract(const struct rtmsg *rtmsg, uint32_t len,
 				uint32_t *ifindex, char **dst, char **gateway,
 				char **src);
-uint32_t l_rtnl_route_dump_ipv4(struct l_netlink *rtnl,
+uint32_t l_rtnl_route4_dump(struct l_netlink *rtnl,
 				l_netlink_command_func_t cb, void *user_data,
 				l_netlink_destroy_func_t destroy);
-uint32_t l_rtnl_route_ipv4_add_connected(struct l_netlink *rtnl, int ifind=
ex,
+uint32_t l_rtnl_route4_add_connected(struct l_netlink *rtnl, int ifindex,
 					uint8_t dst_len, const char *dst,
 					const char *src, uint8_t proto,
 					l_netlink_command_func_t cb,
 					void *user_data,
 					l_netlink_destroy_func_t destroy);
-uint32_t l_rtnl_route_ipv4_add_gateway(struct l_netlink *rtnl, int ifindex,
+uint32_t l_rtnl_route4_add_gateway(struct l_netlink *rtnl, int ifindex,
 					const char *gateway, const char *src,
 					uint32_t priority_offset,
 					uint8_t proto,
@@ -82,29 +82,29 @@ uint32_t l_rtnl_route_ipv4_add_gateway(struct l_netlink=
 *rtnl, int ifindex,
 					void *user_data,
 					l_netlink_destroy_func_t destroy);
 =

-void l_rtnl_ifaddr_ipv6_extract(const struct ifaddrmsg *ifa, int bytes,
+void l_rtnl_ifaddr6_extract(const struct ifaddrmsg *ifa, int bytes,
 								char **ip);
-uint32_t l_rtnl_ifaddr_ipv6_get(struct l_netlink *rtnl,
+uint32_t l_rtnl_ifaddr6_get(struct l_netlink *rtnl,
 				l_netlink_command_func_t cb,
 				void *user_data,
 				l_netlink_destroy_func_t destroy);
-uint32_t l_rtnl_ifaddr_ipv6_add(struct l_netlink *rtnl, int ifindex,
+uint32_t l_rtnl_ifaddr6_add(struct l_netlink *rtnl, int ifindex,
 				uint8_t prefix_len, const char *ip,
 				l_netlink_command_func_t cb, void *user_data,
 				l_netlink_destroy_func_t destroy);
-uint32_t l_rtnl_ifaddr_ipv6_delete(struct l_netlink *rtnl, int ifindex,
+uint32_t l_rtnl_ifaddr6_delete(struct l_netlink *rtnl, int ifindex,
 					uint8_t prefix_len, const char *ip,
 					l_netlink_command_func_t cb,
 					void *user_data,
 					l_netlink_destroy_func_t destroy);
-uint32_t l_rtnl_route_ipv6_add_gateway(struct l_netlink *rtnl, int ifindex,
+uint32_t l_rtnl_route6_add_gateway(struct l_netlink *rtnl, int ifindex,
 					const char *gateway,
 					uint32_t priority_offset,
 					uint8_t proto,
 					l_netlink_command_func_t cb,
 					void *user_data,
 					l_netlink_destroy_func_t destroy);
-uint32_t l_rtnl_route_ipv6_delete_gateway(struct l_netlink *rtnl, int ifin=
dex,
+uint32_t l_rtnl_route6_delete_gateway(struct l_netlink *rtnl, int ifindex,
 					const char *gateway,
 					uint32_t priority_offset,
 					uint8_t proto,
diff --git a/unit/test-rtnl.c b/unit/test-rtnl.c
index 454d0529fe7f..65f0d3ee2b7f 100644
--- a/unit/test-rtnl.c
+++ b/unit/test-rtnl.c
@@ -108,7 +108,7 @@ static void test_next()
 	} while (0)
 =

 =

-static void route_dump_ipv4_cb(int error,
+static void route4_dump_cb(int error,
 			uint16_t type, const void *data,
 			uint32_t len, void *user_data)
 {
@@ -119,7 +119,7 @@ static void route_dump_ipv4_cb(int error,
 	test_assert(!error);
 	test_assert(type =3D=3D RTM_NEWROUTE);
 =

-	l_rtnl_route_extract_ipv4(rtmsg, len, &idx, &dst, &gateway, &src);
+	l_rtnl_route4_extract(rtmsg, len, &idx, &dst, &gateway, &src);
 =

 	l_info("idx %d dst %s gateway %s src %s", idx, dst, gateway, src);
 =

@@ -128,18 +128,18 @@ static void route_dump_ipv4_cb(int error,
 	l_free(src);
 }
 =

-static void route_dump_ipv4_destroy_cb(void *user_data)
+static void route4_dump_destroy_cb(void *user_data)
 {
 	test_next();
 }
 =

-static void test_route_dump_ipv4(struct l_netlink *rtnl, void *user_data)
+static void test_route4_dump(struct l_netlink *rtnl, void *user_data)
 {
-	test_assert(l_rtnl_route_dump_ipv4(rtnl, route_dump_ipv4_cb,
-					NULL, route_dump_ipv4_destroy_cb));
+	test_assert(l_rtnl_route4_dump(rtnl, route4_dump_cb,
+					NULL, route4_dump_destroy_cb));
 }
 =

-static void ifaddr_get_cb(int error,
+static void ifaddr4_get_cb(int error,
 				uint16_t type, const void *data,
 				uint32_t len, void *user_data)
 {
@@ -149,7 +149,7 @@ static void ifaddr_get_cb(int error,
 	test_assert(!error);
 	test_assert(type =3D=3D RTM_NEWADDR);
 =

-	l_rtnl_ifaddr_extract(ifa, len, &label, &ip, &broadcast);
+	l_rtnl_ifaddr4_extract(ifa, len, &label, &ip, &broadcast);
 =

 	l_info("label %s ip %s broadcast %s", label, ip, broadcast);
 =

@@ -158,18 +158,18 @@ static void ifaddr_get_cb(int error,
 	l_free(broadcast);
 }
 =

-static void ifaddr_get_destroy_cb(void *user_data)
+static void ifaddr4_get_destroy_cb(void *user_data)
 {
 	test_next();
 }
 =

-static void test_ifaddr_get(struct l_netlink *rntl, void *user_data)
+static void test_ifaddr4_get(struct l_netlink *rntl, void *user_data)
 {
-	test_assert(l_rtnl_ifaddr_get(rtnl, ifaddr_get_cb,
-					NULL, ifaddr_get_destroy_cb));
+	test_assert(l_rtnl_ifaddr4_get(rtnl, ifaddr4_get_cb,
+					NULL, ifaddr4_get_destroy_cb));
 }
 =

-static void ifaddr_ipv6_get_cb(int error,
+static void ifaddr6_get_cb(int error,
 				uint16_t type, const void *data,
 				uint32_t len, void *user_data)
 {
@@ -179,22 +179,22 @@ static void ifaddr_ipv6_get_cb(int error,
 	test_assert(!error);
 	test_assert(type =3D=3D RTM_NEWADDR);
 =

-	l_rtnl_ifaddr_ipv6_extract(ifa, len, &ip);
+	l_rtnl_ifaddr6_extract(ifa, len, &ip);
 =

 	l_info("ip %s", ip);
 =

 	l_free(ip);
 }
 =

-static void ifaddr_ipv6_get_destroy_cb(void *user_data)
+static void ifaddr6_get_destroy_cb(void *user_data)
 {
 	test_next();
 }
 =

-static void test_ifaddr_ipv6_get(struct l_netlink *rntl, void *user_data)
+static void test_ifaddr6_get(struct l_netlink *rntl, void *user_data)
 {
-	test_assert(l_rtnl_ifaddr_ipv6_get(rtnl, ifaddr_ipv6_get_cb,
-					NULL, ifaddr_ipv6_get_destroy_cb));
+	test_assert(l_rtnl_ifaddr6_get(rtnl, ifaddr6_get_cb,
+					NULL, ifaddr6_get_destroy_cb));
 }
 =

 static void test_run(void)
@@ -210,9 +210,9 @@ int main(int argc, char *argv[])
 	if (!l_main_init())
 		return -1;
 =

-	test_add("Dump IPv4 routing table", test_route_dump_ipv4, NULL);
-	test_add("Get IPv4 address", test_ifaddr_get, NULL);
-	test_add("Get IPv6 address", test_ifaddr_ipv6_get, NULL);
+	test_add("Dump IPv4 routing table", test_route4_dump, NULL);
+	test_add("Get IPv4 address", test_ifaddr4_get, NULL);
+	test_add("Get IPv6 address", test_ifaddr6_get, NULL);
 =

 	l_log_set_stderr();
 =

-- =

2.25.0
--===============1916524974034623094==--

