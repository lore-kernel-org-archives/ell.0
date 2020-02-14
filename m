Content-Type: multipart/mixed; boundary="===============4043083579587554229=="
MIME-Version: 1.0
From: Daniel Wagner <wagi@monom.org>
Subject: [PATCH 3/3] rtnl: Extract table, priority and pref
Date: Fri, 14 Feb 2020 19:52:53 +0100
Message-ID: <20200214185253.32658-4-wagi@monom.org>
In-Reply-To: <20200214185253.32658-1-wagi@monom.org>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4043083579587554229==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/rtnl.c       | 38 ++++++++++++++++++++++++++++++--------
 ell/rtnl.h       |  8 ++++----
 unit/test-rtnl.c | 16 ++++++++++------
 3 files changed, 44 insertions(+), 18 deletions(-)

diff --git a/ell/rtnl.c b/ell/rtnl.c
index c94531144eb4..4600a7e42001 100644
--- a/ell/rtnl.c
+++ b/ell/rtnl.c
@@ -69,12 +69,14 @@ static size_t rta_add_data(void *rta_buf, unsigned shor=
t type, void *data,
 }
 =

 static void l_rtnl_route_extract(const struct rtmsg *rtmsg, uint32_t len,
-				int family, uint32_t *ifindex, char **dst,
-				char **gateway,	char **src)
+				int family, uint32_t *table, uint32_t *ifindex,
+				uint32_t *priority, uint8_t *pref,
+				char **dst, char **gateway, char **src)
 {
 	struct rtattr *attr;
 	char buf[INET6_ADDRSTRLEN];
 =

+	/* Not extracted at the moment: RTA_CACHEINFO for IPv6 */
 	for (attr =3D RTM_RTA(rtmsg); RTA_OK(attr, len);
 						attr =3D RTA_NEXT(attr, len)) {
 		switch (attr->rta_type) {
@@ -101,6 +103,24 @@ static void l_rtnl_route_extract(const struct rtmsg *r=
tmsg, uint32_t len,
 			inet_ntop(family, RTA_DATA(attr), buf, sizeof(buf));
 			*src =3D l_strdup(buf);
 =

+			break;
+		case RTA_TABLE:
+			if (!table)
+				break;
+
+			*table =3D *((uint32_t *) RTA_DATA(attr));
+			break;
+		case RTA_PRIORITY:
+			if (!priority)
+				break;
+
+			*priority =3D *((uint32_t *) RTA_DATA(attr));
+			break;
+		case RTA_PREF:
+			if (!pref)
+				break;
+
+			*pref =3D *((uint8_t *) RTA_DATA(attr));
 			break;
 		case RTA_OIF:
 			if (!ifindex)
@@ -335,10 +355,11 @@ uint32_t l_rtnl_ifaddr4_delete(struct l_netlink *rtnl=
, int ifindex,
 }
 =

 void l_rtnl_route4_extract(const struct rtmsg *rtmsg, uint32_t len,
-				uint32_t *ifindex, char **dst, char **gateway,
-				char **src)
+				uint32_t *table, uint32_t *ifindex,
+				char **dst, char **gateway, char **src)
 {
-	l_rtnl_route_extract(rtmsg, len, AF_INET, ifindex, dst, gateway, src);
+	l_rtnl_route_extract(rtmsg, len, AF_INET, table, ifindex,
+				NULL, NULL, dst, gateway, src);
 }
 =

 uint32_t l_rtnl_route4_dump(struct l_netlink *rtnl,
@@ -568,10 +589,11 @@ uint32_t l_rtnl_ifaddr6_delete(struct l_netlink *rtnl=
, int ifindex,
 }
 =

 void l_rtnl_route6_extract(const struct rtmsg *rtmsg, uint32_t len,
-				uint32_t *ifindex, char **dst, char **gateway,
-				char **src)
+				uint32_t *table, uint32_t *ifindex,
+				char **dst, char **gateway, char **src)
 {
-	l_rtnl_route_extract(rtmsg, len, AF_INET6, ifindex, dst, gateway, src);
+	l_rtnl_route_extract(rtmsg, len, AF_INET6, table, ifindex,
+				NULL, NULL, dst, gateway, src);
 }
 =

 uint32_t l_rtnl_route6_dump(struct l_netlink *rtnl,
diff --git a/ell/rtnl.h b/ell/rtnl.h
index 2be2eaee99e2..ea283c1c5a6e 100644
--- a/ell/rtnl.h
+++ b/ell/rtnl.h
@@ -63,8 +63,8 @@ uint32_t l_rtnl_ifaddr4_delete(struct l_netlink *rtnl, in=
t ifindex,
 				l_netlink_destroy_func_t destroy);
 =

 void l_rtnl_route4_extract(const struct rtmsg *rtmsg, uint32_t len,
-				uint32_t *ifindex, char **dst, char **gateway,
-				char **src);
+				uint32_t *table, uint32_t *ifindex,
+				char **dst, char **gateway, char **src);
 uint32_t l_rtnl_route4_dump(struct l_netlink *rtnl,
 				l_netlink_command_func_t cb, void *user_data,
 				l_netlink_destroy_func_t destroy);
@@ -98,8 +98,8 @@ uint32_t l_rtnl_ifaddr6_delete(struct l_netlink *rtnl, in=
t ifindex,
 					void *user_data,
 					l_netlink_destroy_func_t destroy);
 void l_rtnl_route6_extract(const struct rtmsg *rtmsg, uint32_t len,
-				uint32_t *ifindex, char **dst, char **gateway,
-				char **src);
+				uint32_t *table, uint32_t *ifindex,
+				char **dst, char **gateway, char **src);
 uint32_t l_rtnl_route6_dump(struct l_netlink *rtnl,
 				l_netlink_command_func_t cb, void *user_data,
 				l_netlink_destroy_func_t destroy);
diff --git a/unit/test-rtnl.c b/unit/test-rtnl.c
index 37db73dc6f2f..107f69a76da1 100644
--- a/unit/test-rtnl.c
+++ b/unit/test-rtnl.c
@@ -114,14 +114,16 @@ static void route4_dump_cb(int error,
 {
 	const struct rtmsg *rtmsg =3D data;
 	char *dst =3D NULL, *gateway =3D NULL, *src =3D NULL;
-	uint32_t idx;
+	uint32_t table, ifindex;
 =

 	test_assert(!error);
 	test_assert(type =3D=3D RTM_NEWROUTE);
 =

-	l_rtnl_route4_extract(rtmsg, len, &idx, &dst, &gateway, &src);
+	l_rtnl_route4_extract(rtmsg, len, &table, &ifindex,
+				&dst, &gateway, &src);
 =

-	l_info("idx %d dst %s gateway %s src %s", idx, dst, gateway, src);
+	l_info("table %d ifindex %d dst %s gateway %s src %s",
+		table, ifindex, dst, gateway, src);
 =

 	l_free(dst);
 	l_free(gateway);
@@ -145,14 +147,16 @@ static void route6_dump_cb(int error,
 {
 	const struct rtmsg *rtmsg =3D data;
 	char *dst =3D NULL, *gateway =3D NULL, *src =3D NULL;
-	uint32_t idx;
+	uint32_t table, ifindex;
 =

 	test_assert(!error);
 	test_assert(type =3D=3D RTM_NEWROUTE);
 =

-	l_rtnl_route6_extract(rtmsg, len, &idx, &dst, &gateway, &src);
+	l_rtnl_route6_extract(rtmsg, len, &table, &ifindex,
+				&dst, &gateway, &src);
 =

-	l_info("idx %d dst %s gateway %s src %s", idx, dst, gateway, src);
+	l_info("table %d ifindex %d dst %s gateway %s src %s",
+		table, ifindex, dst, gateway, src);
 =

 	l_free(dst);
 	l_free(gateway);
-- =

2.25.0
--===============4043083579587554229==--

