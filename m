Content-Type: multipart/mixed; boundary="===============1439564489737133799=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 14/15] netconfig: Set a limit on number of routes from ICMPv6
Date: Fri, 20 May 2022 17:43:37 +0200
Message-ID: <20220520154338.2056273-14-andrew.zaborowski@intel.com>
In-Reply-To: 20220520154338.2056273-1-andrew.zaborowski@intel.com

--===============1439564489737133799==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

While some networks can be configured in a way that prevents rogue
Router Advertisements from reaching clients, add a very basic mechanism
to avoid a denial-of-service in such a case by limiting the number of
routes we track from RAs.  This won't prevent the loss of routing but
might prevent OOM crashes or slowdowns.
---
 ell/netconfig.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/ell/netconfig.c b/ell/netconfig.c
index af85f71..f86fcfb 100644
--- a/ell/netconfig.c
+++ b/ell/netconfig.c
@@ -134,6 +134,8 @@ union netconfig_addr {
 static struct l_queue *addr_wait_list;
 static unsigned int rtnl_id;
 =

+static const unsigned int max_icmp6_routes =3D 100;
+
 static void netconfig_update_cleanup(struct l_netconfig *nc)
 {
 	l_queue_clear(nc->addresses.added, NULL);
@@ -734,6 +736,9 @@ static struct netconfig_route_data *netconfig_add_icmp6=
_route(
 	struct netconfig_route_data *rd;
 	struct l_rtnl_route *rt;
 =

+	if (l_queue_length(nc->icmp_route_data) >=3D max_icmp6_routes)
+		return NULL;	/* TODO: log a warning the first time */
+
 	rt =3D netconfig_route_new(nc, AF_INET6, dst ? dst->address : NULL,
 					dst ? dst->prefix_len : 0, gateway,
 					RTPROT_RA);
-- =

2.32.0

--===============1439564489737133799==--

