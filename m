Content-Type: multipart/mixed; boundary="===============5354171711587270403=="
MIME-Version: 1.0
From: Daniel Wagner <wagi@monom.org>
Subject: [PATCH 1/3] rtnl: Add l_rtnl_route6_dump() and l_rtnl_route6_extract()
Date: Fri, 14 Feb 2020 19:52:51 +0100
Message-ID: <20200214185253.32658-2-wagi@monom.org>
In-Reply-To: <20200214185253.32658-1-wagi@monom.org>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5354171711587270403==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add missing function for handling IPv6. Now we for both protocol
versions the same functionality.

While at it, factor out the l_rtnl_route4_extract to use inet_ntop
which can handle both address families.
---
 ell/rtnl.c | 104 +++++++++++++++++++++++++++++++++--------------------
 ell/rtnl.h |   6 ++++
 2 files changed, 72 insertions(+), 38 deletions(-)

diff --git a/ell/rtnl.c b/ell/rtnl.c
index ced9baab66b9..c94531144eb4 100644
--- a/ell/rtnl.c
+++ b/ell/rtnl.c
@@ -68,6 +68,50 @@ static size_t rta_add_data(void *rta_buf, unsigned short=
 type, void *data,
 	return RTA_SPACE(data_len);
 }
 =

+static void l_rtnl_route_extract(const struct rtmsg *rtmsg, uint32_t len,
+				int family, uint32_t *ifindex, char **dst,
+				char **gateway,	char **src)
+{
+	struct rtattr *attr;
+	char buf[INET6_ADDRSTRLEN];
+
+	for (attr =3D RTM_RTA(rtmsg); RTA_OK(attr, len);
+						attr =3D RTA_NEXT(attr, len)) {
+		switch (attr->rta_type) {
+		case RTA_DST:
+			if (!dst)
+				break;
+
+			inet_ntop(family, RTA_DATA(attr), buf, sizeof(buf));
+			*dst =3D l_strdup(buf);
+
+			break;
+		case RTA_GATEWAY:
+			if (!gateway)
+				break;
+
+			inet_ntop(family, RTA_DATA(attr), buf, sizeof(buf));
+			*gateway =3D l_strdup(buf);
+
+			break;
+		case RTA_PREFSRC:
+			if (!src)
+				break;
+
+			inet_ntop(family, RTA_DATA(attr), buf, sizeof(buf));
+			*src =3D l_strdup(buf);
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
 uint32_t l_rtnl_set_linkmode_and_operstate(struct l_netlink *rtnl, int ifi=
ndex,
 					uint8_t linkmode, uint8_t operstate,
 					l_netlink_command_func_t cb,
@@ -294,44 +338,7 @@ void l_rtnl_route4_extract(const struct rtmsg *rtmsg, =
uint32_t len,
 				uint32_t *ifindex, char **dst, char **gateway,
 				char **src)
 {
-	struct in_addr in_addr;
-	struct rtattr *attr;
-
-	for (attr =3D RTM_RTA(rtmsg); RTA_OK(attr, len);
-						attr =3D RTA_NEXT(attr, len)) {
-		switch (attr->rta_type) {
-		case RTA_DST:
-			if (!dst)
-				break;
-
-			in_addr =3D *((struct in_addr *) RTA_DATA(attr));
-			*dst =3D l_strdup(inet_ntoa(in_addr));
-
-			break;
-		case RTA_GATEWAY:
-			if (!gateway)
-				break;
-
-			in_addr =3D *((struct in_addr *) RTA_DATA(attr));
-			*gateway =3D l_strdup(inet_ntoa(in_addr));
-
-			break;
-		case RTA_PREFSRC:
-			if (!src)
-				break;
-
-			in_addr =3D *((struct in_addr *) RTA_DATA(attr));
-			*src =3D l_strdup(inet_ntoa(in_addr));
-
-			break;
-		case RTA_OIF:
-			if (!ifindex)
-				break;
-
-			*ifindex =3D *((uint32_t *) RTA_DATA(attr));
-			break;
-		}
-	}
+	l_rtnl_route_extract(rtmsg, len, AF_INET, ifindex, dst, gateway, src);
 }
 =

 uint32_t l_rtnl_route4_dump(struct l_netlink *rtnl,
@@ -560,6 +567,27 @@ uint32_t l_rtnl_ifaddr6_delete(struct l_netlink *rtnl,=
 int ifindex,
 						ip, cb, user_data, destroy);
 }
 =

+void l_rtnl_route6_extract(const struct rtmsg *rtmsg, uint32_t len,
+				uint32_t *ifindex, char **dst, char **gateway,
+				char **src)
+{
+	l_rtnl_route_extract(rtmsg, len, AF_INET6, ifindex, dst, gateway, src);
+}
+
+uint32_t l_rtnl_route6_dump(struct l_netlink *rtnl,
+				l_netlink_command_func_t cb, void *user_data,
+				l_netlink_destroy_func_t destroy)
+{
+	struct rtmsg rtmsg;
+
+	memset(&rtmsg, 0, sizeof(struct rtmsg));
+	rtmsg.rtm_family =3D AF_INET6;
+
+	return l_netlink_send(rtnl, RTM_GETROUTE, NLM_F_DUMP, &rtmsg,
+					sizeof(struct rtmsg), cb, user_data,
+					destroy);
+}
+
 static uint32_t l_rtnl_route6_change(struct l_netlink *rtnl,
 					uint16_t nlmsg_type, int ifindex,
 					const char *gateway,
diff --git a/ell/rtnl.h b/ell/rtnl.h
index a6e6d1323015..2be2eaee99e2 100644
--- a/ell/rtnl.h
+++ b/ell/rtnl.h
@@ -97,6 +97,12 @@ uint32_t l_rtnl_ifaddr6_delete(struct l_netlink *rtnl, i=
nt ifindex,
 					l_netlink_command_func_t cb,
 					void *user_data,
 					l_netlink_destroy_func_t destroy);
+void l_rtnl_route6_extract(const struct rtmsg *rtmsg, uint32_t len,
+				uint32_t *ifindex, char **dst, char **gateway,
+				char **src);
+uint32_t l_rtnl_route6_dump(struct l_netlink *rtnl,
+				l_netlink_command_func_t cb, void *user_data,
+				l_netlink_destroy_func_t destroy);
 uint32_t l_rtnl_route6_add_gateway(struct l_netlink *rtnl, int ifindex,
 					const char *gateway,
 					uint32_t priority_offset,
-- =

2.25.0
--===============5354171711587270403==--

