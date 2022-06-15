Content-Type: multipart/mixed; boundary="===============0425479823250752407=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 02/14] netconfig: Don't set prefsrc on gateway route for now
Date: Thu, 16 Jun 2022 00:47:27 +0200
Message-ID: <20220615224739.1936538-2-andrew.zaborowski@intel.com>
In-Reply-To: 20220615224739.1936538-1-andrew.zaborowski@intel.com

--===============0425479823250752407==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Avoid setting the prefsrc attribute on our gateway route until we have
at least a better handling of DAD on the IPv6 addresses, either by
leveraging the kernel implementation or adding our own.  The kernel
won't allow us to add a route with prefsrc containing a local address
that has been basically just added with RTM_NEWADDR because DAD would
still be running and if it works it's by luck.  We'll need to add those
routes asynchronously after the address has been confirmed.
---
 ell/netconfig.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/ell/netconfig.c b/ell/netconfig.c
index 5de5d74..c7251c2 100644
--- a/ell/netconfig.c
+++ b/ell/netconfig.c
@@ -235,7 +235,17 @@ static void netconfig_add_v6_static_routes(struct l_ne=
tconfig *nc,
 =

 	v6_default_route =3D l_rtnl_route_new_gateway(nc->v6_gateway_override);
 	l_rtnl_route_set_protocol(v6_default_route, RTPROT_STATIC);
-	L_WARN_ON(!l_rtnl_route_set_prefsrc(v6_default_route, ip));
+	/*
+	 * TODO: Optimally we'd set the prefsrc on the route with:
+	 * L_WARN_ON(!l_rtnl_route_set_prefsrc(v6_default_route, ip));
+	 *
+	 * but that means that we can only commit the route to the kernel
+	 * with an RTM_NEWROUTE command after the corresponding RTM_NEWADDR
+	 * has returned and the kernel has finished DAD for the address and
+	 * cleared IFA_F_TENTATIVE.  That will complicate
+	 * l_netconfig_apply_rtnl() significantly but may be inevitable.
+	 */
+
 	l_queue_push_tail(nc->routes.current, v6_default_route);
 	l_queue_push_tail(nc->routes.added, v6_default_route);
 }
-- =

2.34.1

--===============0425479823250752407==--

