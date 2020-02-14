Content-Type: multipart/mixed; boundary="===============2983181165545248388=="
MIME-Version: 1.0
From: Daniel Wagner <wagi@monom.org>
Subject: [PATCH 2/2] rtnl: Rename l_rtnl_ifaddr{4|6|}_get to
 l_rntl_ifaddr{4|6}_dump
Date: Fri, 14 Feb 2020 19:23:37 +0100
Message-ID: <20200214182337.11132-3-wagi@monom.org>
In-Reply-To: <20200214182337.11132-1-wagi@monom.org>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2983181165545248388==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

These functions use NLM_F_DUMP so rename them accordingly.
---
 ell/rtnl.c       |  4 ++--
 ell/rtnl.h       |  4 ++--
 unit/test-rtnl.c | 24 ++++++++++++------------
 3 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/ell/rtnl.c b/ell/rtnl.c
index 2d3b8dc8e3c1..ced9baab66b9 100644
--- a/ell/rtnl.c
+++ b/ell/rtnl.c
@@ -192,7 +192,7 @@ void l_rtnl_ifaddr4_extract(const struct ifaddrmsg *ifa=
, int bytes,
 	}
 }
 =

-uint32_t l_rtnl_ifaddr4_get(struct l_netlink *rtnl, l_netlink_command_func=
_t cb,
+uint32_t l_rtnl_ifaddr4_dump(struct l_netlink *rtnl, l_netlink_command_fun=
c_t cb,
 					void *user_data,
 					l_netlink_destroy_func_t destroy)
 {
@@ -476,7 +476,7 @@ void l_rtnl_ifaddr6_extract(const struct ifaddrmsg *ifa=
, int len, char **ip)
 	}
 }
 =

-uint32_t l_rtnl_ifaddr6_get(struct l_netlink *rtnl,
+uint32_t l_rtnl_ifaddr6_dump(struct l_netlink *rtnl,
 				l_netlink_command_func_t cb, void *user_data,
 				l_netlink_destroy_func_t destroy)
 {
diff --git a/ell/rtnl.h b/ell/rtnl.h
index 5629eac20416..a6e6d1323015 100644
--- a/ell/rtnl.h
+++ b/ell/rtnl.h
@@ -48,7 +48,7 @@ uint32_t l_rtnl_set_powered(struct l_netlink *rtnl, int i=
findex, bool powered,
 =

 void l_rtnl_ifaddr4_extract(const struct ifaddrmsg *ifa, int bytes,
 				char **label, char **ip, char **broadcast);
-uint32_t l_rtnl_ifaddr4_get(struct l_netlink *rtnl, l_netlink_command_func=
_t cb,
+uint32_t l_rtnl_ifaddr4_dump(struct l_netlink *rtnl, l_netlink_command_fun=
c_t cb,
 				void *user_data,
 				l_netlink_destroy_func_t destroy);
 uint32_t l_rtnl_ifaddr4_add(struct l_netlink *rtnl, int ifindex,
@@ -84,7 +84,7 @@ uint32_t l_rtnl_route4_add_gateway(struct l_netlink *rtnl=
, int ifindex,
 =

 void l_rtnl_ifaddr6_extract(const struct ifaddrmsg *ifa, int bytes,
 								char **ip);
-uint32_t l_rtnl_ifaddr6_get(struct l_netlink *rtnl,
+uint32_t l_rtnl_ifaddr6_dump(struct l_netlink *rtnl,
 				l_netlink_command_func_t cb,
 				void *user_data,
 				l_netlink_destroy_func_t destroy);
diff --git a/unit/test-rtnl.c b/unit/test-rtnl.c
index 65f0d3ee2b7f..c0659c4378da 100644
--- a/unit/test-rtnl.c
+++ b/unit/test-rtnl.c
@@ -139,7 +139,7 @@ static void test_route4_dump(struct l_netlink *rtnl, vo=
id *user_data)
 					NULL, route4_dump_destroy_cb));
 }
 =

-static void ifaddr4_get_cb(int error,
+static void ifaddr4_dump_cb(int error,
 				uint16_t type, const void *data,
 				uint32_t len, void *user_data)
 {
@@ -158,18 +158,18 @@ static void ifaddr4_get_cb(int error,
 	l_free(broadcast);
 }
 =

-static void ifaddr4_get_destroy_cb(void *user_data)
+static void ifaddr4_dump_destroy_cb(void *user_data)
 {
 	test_next();
 }
 =

-static void test_ifaddr4_get(struct l_netlink *rntl, void *user_data)
+static void test_ifaddr4_dump(struct l_netlink *rntl, void *user_data)
 {
-	test_assert(l_rtnl_ifaddr4_get(rtnl, ifaddr4_get_cb,
-					NULL, ifaddr4_get_destroy_cb));
+	test_assert(l_rtnl_ifaddr4_dump(rtnl, ifaddr4_dump_cb,
+					NULL, ifaddr4_dump_destroy_cb));
 }
 =

-static void ifaddr6_get_cb(int error,
+static void ifaddr6_dump_cb(int error,
 				uint16_t type, const void *data,
 				uint32_t len, void *user_data)
 {
@@ -186,15 +186,15 @@ static void ifaddr6_get_cb(int error,
 	l_free(ip);
 }
 =

-static void ifaddr6_get_destroy_cb(void *user_data)
+static void ifaddr6_dump_destroy_cb(void *user_data)
 {
 	test_next();
 }
 =

-static void test_ifaddr6_get(struct l_netlink *rntl, void *user_data)
+static void test_ifaddr6_dump(struct l_netlink *rntl, void *user_data)
 {
-	test_assert(l_rtnl_ifaddr6_get(rtnl, ifaddr6_get_cb,
-					NULL, ifaddr6_get_destroy_cb));
+	test_assert(l_rtnl_ifaddr6_dump(rtnl, ifaddr6_dump_cb,
+					NULL, ifaddr6_dump_destroy_cb));
 }
 =

 static void test_run(void)
@@ -211,8 +211,8 @@ int main(int argc, char *argv[])
 		return -1;
 =

 	test_add("Dump IPv4 routing table", test_route4_dump, NULL);
-	test_add("Get IPv4 address", test_ifaddr4_get, NULL);
-	test_add("Get IPv6 address", test_ifaddr6_get, NULL);
+	test_add("Dump IPv4 addresses", test_ifaddr4_dump, NULL);
+	test_add("Dump IPv6 addresses", test_ifaddr6_dump, NULL);
 =

 	l_log_set_stderr();
 =

-- =

2.25.0
--===============2983181165545248388==--

