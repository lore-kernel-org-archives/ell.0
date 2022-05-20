Content-Type: multipart/mixed; boundary="===============7295200322220041886=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 04/15] rtnl: Keep one global RTNL connection
Date: Fri, 20 May 2022 17:43:27 +0200
Message-ID: <20220520154338.2056273-4-andrew.zaborowski@intel.com>
In-Reply-To: 20220520154338.2056273-1-andrew.zaborowski@intel.com

--===============7295200322220041886==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

To avoid keeping multiple RTNL sockets open, have a singleton l_netlink
rtnl object managed by rtnl.c and available for anyone who needs it to
request a reference.
---
In this version l_rtnl_get() and l_rtnl_put() take an optional rtnl
pointer to save the reference to, but I'm happy to drop the parameter
or use a different style API.  The parameter allows the user to easily
request the rtnl object lazily as in patch 5.

 ell/ell.sym |  2 ++
 ell/rtnl.c  | 41 +++++++++++++++++++++++++++++++++++++++++
 ell/rtnl.h  |  3 +++
 3 files changed, 46 insertions(+)

diff --git a/ell/ell.sym b/ell/ell.sym
index 0f9f884..ea4d06c 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -688,6 +688,8 @@ global:
 	l_rtnl_ifaddr_delete;
 	l_rtnl_neighbor_get_hwaddr;
 	l_rtnl_neighbor_set_hwaddr;
+	l_rtnl_get;
+	l_rtnl_put;
 	/* icmp6 */
 	l_icmp6_client_new;
 	l_icmp6_client_free;
diff --git a/ell/rtnl.c b/ell/rtnl.c
index b53d049..fe00b25 100644
--- a/ell/rtnl.c
+++ b/ell/rtnl.c
@@ -43,6 +43,9 @@
 #include "rtnl.h"
 #include "private.h"
 =

+static struct l_netlink *rtnl;
+static unsigned int rtnl_use_count;
+
 struct l_rtnl_address {
 	uint8_t family;
 	uint8_t prefix_len;
@@ -1556,3 +1559,41 @@ LIB_EXPORT uint32_t l_rtnl_neighbor_set_hwaddr(struc=
t l_netlink *rtnl,
 				ndmsg, rta_buf - (void *) ndmsg,
 				cb, user_data, destroy);
 }
+
+LIB_EXPORT struct l_netlink *l_rtnl_get(struct l_netlink **ptr)
+
+{
+	if (ptr && *ptr)
+		return *ptr;
+
+	if (!rtnl) {
+		rtnl =3D l_netlink_new(NETLINK_ROUTE);
+
+		if (unlikely(!rtnl))
+			return NULL;
+	}
+
+	if (ptr)
+		*ptr =3D rtnl;
+
+	rtnl_use_count++;
+	return rtnl;
+}
+
+LIB_EXPORT void l_rtnl_put(struct l_netlink **ptr)
+{
+	if (ptr) {
+		if (!*ptr)
+			return;
+
+		*ptr =3D NULL;
+	}
+
+	if (L_WARN_ON(!rtnl_use_count))
+		return;
+
+	--rtnl_use_count;
+
+	if (!rtnl_use_count)
+		l_netlink_destroy(l_steal_ptr(rtnl));
+}
diff --git a/ell/rtnl.h b/ell/rtnl.h
index 2617b1c..4409339 100644
--- a/ell/rtnl.h
+++ b/ell/rtnl.h
@@ -226,6 +226,9 @@ uint32_t l_rtnl_neighbor_set_hwaddr(struct l_netlink *r=
tnl, int ifindex,
 					void *user_data,
 					l_netlink_destroy_func_t destroy);
 =

+struct l_netlink *l_rtnl_get(struct l_netlink **ptr);
+void l_rtnl_put(struct l_netlink **ptr);
+
 #ifdef __cplusplus
 }
 #endif
-- =

2.32.0

--===============7295200322220041886==--

