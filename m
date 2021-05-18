Content-Type: multipart/mixed; boundary="===============0528857468637137089=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH] rtnl: Add l_rtnl_ifaddr_extract
Date: Wed, 19 May 2021 00:20:35 +0200
Message-ID: <20210518222035.836352-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0528857468637137089==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Extracts information from struct ifaddrmsg directly into an
l_rtnl_address object.
---
 ell/ell.sym |  1 +
 ell/rtnl.c  | 53 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 ell/rtnl.h  |  2 ++
 3 files changed, 56 insertions(+)

diff --git a/ell/ell.sym b/ell/ell.sym
index 5568ac2..ec44d3a 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -641,6 +641,7 @@ global:
 	l_rtnl_route6_delete_gateway;
 	l_rtnl_route_add;
 	l_rtnl_route_delete;
+	l_rtnl_ifaddr_extract;
 	l_rtnl_ifaddr_add;
 	l_rtnl_ifaddr_delete;
 /* icmp6 */
diff --git a/ell/rtnl.c b/ell/rtnl.c
index c5b479b..e2996a6 100644
--- a/ell/rtnl.c
+++ b/ell/rtnl.c
@@ -1126,6 +1126,59 @@ done:
 	return id;
 }
 =

+LIB_EXPORT struct l_rtnl_address *l_rtnl_ifaddr_extract(
+						const struct ifaddrmsg *ifa,
+						int bytes)
+{
+	struct rtattr *attr;
+	struct ifa_cacheinfo *cinfo;
+	struct l_rtnl_address *addr;
+
+	if (unlikely(!ifa))
+		return NULL;
+
+	if (!L_IN_SET(ifa->ifa_family, AF_INET, AF_INET6))
+		return NULL;
+
+	addr =3D l_new(struct l_rtnl_address, 1);
+	addr->prefix_len =3D ifa->ifa_prefixlen;
+	addr->family =3D ifa->ifa_family;
+	addr->flags =3D ifa->ifa_flags;
+	addr->scope =3D ifa->ifa_scope;
+
+	for (attr =3D IFA_RTA(ifa); RTA_OK(attr, bytes);
+						attr =3D RTA_NEXT(attr, bytes)) {
+		switch (attr->rta_type) {
+		case IFA_LOCAL:
+			if (ifa->ifa_family =3D=3D AF_INET)
+				addr->in_addr =3D
+					*((struct in_addr *) RTA_DATA(attr));
+
+			break;
+		case IFA_ADDRESS:
+			if (ifa->ifa_family =3D=3D AF_INET6)
+				addr->in6_addr =3D
+					*((struct in6_addr *) RTA_DATA(attr));
+
+			break;
+		case IFA_BROADCAST:
+			addr->broadcast =3D *((struct in_addr *) RTA_DATA(attr));
+			break;
+		case IFA_LABEL:
+			l_strlcpy(addr->label, RTA_DATA(attr),
+					sizeof(addr->label));
+			break;
+		case IFA_CACHEINFO:
+			cinfo =3D RTA_DATA(attr);
+			addr->preferred_lifetime =3D cinfo->ifa_prefered;
+			addr->valid_lifetime =3D cinfo->ifa_valid;
+			break;
+		}
+	}
+
+	return addr;
+}
+
 LIB_EXPORT uint32_t l_rtnl_ifaddr_add(struct l_netlink *rtnl, int ifindex,
 					const struct l_rtnl_address *addr,
 					l_netlink_command_func_t cb,
diff --git a/ell/rtnl.h b/ell/rtnl.h
index c54a287..adabcfe 100644
--- a/ell/rtnl.h
+++ b/ell/rtnl.h
@@ -164,6 +164,8 @@ uint32_t l_rtnl_route6_delete_gateway(struct l_netlink =
*rtnl, int ifindex,
 					void *user_data,
 					l_netlink_destroy_func_t destroy);
 =

+struct l_rtnl_address *l_rtnl_ifaddr_extract(const struct ifaddrmsg *ifa, =
int bytes);
+
 uint32_t l_rtnl_ifaddr_add(struct l_netlink *rtnl, int ifindex,
 					const struct l_rtnl_address *addr,
 					l_netlink_command_func_t cb,
-- =

2.27.0

--===============0528857468637137089==--

