Content-Type: multipart/mixed; boundary="===============7122959426210059764=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 3/4] icmp6: Respect lifetime values in a RA
Date: Mon, 03 Jan 2022 15:18:29 +0100
Message-ID: <20220103141830.311011-3-andrew.zaborowski@intel.com>
In-Reply-To: 20220103141830.311011-1-andrew.zaborowski@intel.com

--===============7122959426210059764==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

If the router lifetime is 0 in a RA that router is not supposed to be
added to the Default Router List in RFC4861:

"A value of zero indicates that the router is not to be used as a
default router."

"A router might want to send Router Advertisements without advertising
itself as a default router.  For instance, a router might advertise
prefixes for stateless address autoconfiguration while not wishing to
forward packets.  Such a router sets the Router Lifetime field in
outgoing advertisements to zero."

Also set the lifetime values on the routes to those received so that the
user of, say, l_icmp6_client_get_router(), can also determine whether
there is a default router.
---
 ell/icmp6.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/ell/icmp6.c b/ell/icmp6.c
index 42fe67d..93c1701 100644
--- a/ell/icmp6.c
+++ b/ell/icmp6.c
@@ -299,9 +299,10 @@ static void icmp6_client_setup_routes(struct l_icmp6_c=
lient *client)
 	l_rtnl_route_set_protocol(rt, RTPROT_RA);
 	l_rtnl_route_set_mtu(rt, ra->mtu);
 	l_rtnl_route_set_priority(rt, client->route_priority);
+	l_rtnl_route_set_lifetime(rt, ra->lifetime);
 	l_queue_push_tail(client->routes, rt);
 =

-	if (client->rtnl)
+	if (client->rtnl && ra->lifetime)
 		l_rtnl_route_add(client->rtnl, client->ifindex, rt,
 					NULL, NULL, NULL);
 =

@@ -322,6 +323,7 @@ static void icmp6_client_setup_routes(struct l_icmp6_cl=
ient *client)
 		l_rtnl_route_set_protocol(rt, RTPROT_RA);
 		l_rtnl_route_set_mtu(rt, ra->mtu);
 		l_rtnl_route_set_priority(rt, client->route_priority);
+		l_rtnl_route_set_lifetime(rt, info->valid_lifetime);
 		l_queue_push_tail(client->routes, rt);
 =

 		if (client->rtnl)
-- =

2.32.0

--===============7122959426210059764==--

