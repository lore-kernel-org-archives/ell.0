Content-Type: multipart/mixed; boundary="===============6297835392868498307=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 15/17] netconfig: Set a limit on number of routes from ICMPv6
Date: Fri, 13 May 2022 16:55:08 +0200
Message-ID: <20220513145510.1408510-15-andrew.zaborowski@intel.com>
In-Reply-To: 20220513145510.1408510-1-andrew.zaborowski@intel.com

--===============6297835392868498307==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

While some networks can be configured in a way that prevents rogue
Router Advertisements from reaching clients, add a very basic mechanism
to avoid a denial-of-service in such a case by limiting the number of
routes we track from RAs.  This won't prevent loss of connectivity but
might prevent a crash or slowdowns.
---
 ell/netconfig.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/ell/netconfig.c b/ell/netconfig.c
index 023bcc3..35dea29 100644
--- a/ell/netconfig.c
+++ b/ell/netconfig.c
@@ -134,6 +134,8 @@ static unsigned int rtnl_use_count;
 static struct l_queue *addr_wait_list;
 static unsigned int rtnl_id;
 =

+static const unsigned int max_icmp6_routes =3D 100;
+
 static void netconfig_update_cleanup(struct l_netconfig *nc)
 {
 	l_queue_clear(nc->addresses.added, NULL);
@@ -731,6 +733,9 @@ static struct netconfig_route_data *netconfig_add_icmp6=
_route(
 	struct netconfig_route_data *rd;
 	struct l_rtnl_route *rt;
 =

+	if (l_queue_length(nc->icmp_route_data) >=3D max_icmp6_routes)
+		return NULL;	/* TODO: log a warning the first time */
+
 	rt =3D netconfig_route_new(nc, AF_INET6, dst->address, dst->prefix_len,
 					gateway, RTPROT_RA);
 	if (L_WARN_ON(!rt))
-- =

2.32.0

--===============6297835392868498307==--

