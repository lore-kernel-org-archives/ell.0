Content-Type: multipart/mixed; boundary="===============0398577080057716356=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 4/4] icmp6: Respect the on-link bit in RA prefixes
Date: Mon, 03 Jan 2022 15:18:30 +0100
Message-ID: <20220103141830.311011-4-andrew.zaborowski@intel.com>
In-Reply-To: 20220103141830.311011-1-andrew.zaborowski@intel.com

--===============0398577080057716356==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

When the on-link bit is not 1 in a prefix option, the packets addressed
to that prefix should go through the router who sent the RA.
---
 ell/icmp6-private.h | 1 +
 ell/icmp6.c         | 9 +++++++--
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/ell/icmp6-private.h b/ell/icmp6-private.h
index 3846bad..38d640f 100644
--- a/ell/icmp6-private.h
+++ b/ell/icmp6-private.h
@@ -23,6 +23,7 @@
 struct route_info {
 	uint8_t address[16];
 	uint8_t prefix_len;
+	bool onlink : 1;
 	uint8_t preference;
 	uint32_t preferred_lifetime;
 	uint32_t valid_lifetime;
diff --git a/ell/icmp6.c b/ell/icmp6.c
index 93c1701..197aa4a 100644
--- a/ell/icmp6.c
+++ b/ell/icmp6.c
@@ -285,11 +285,11 @@ static void icmp6_client_setup_routes(struct l_icmp6_=
client *client)
 {
 	struct l_icmp6_router *ra =3D client->ra;
 	struct l_rtnl_route *rt;
-	char buf[INET6_ADDRSTRLEN];
+	char gw_buf[INET6_ADDRSTRLEN];
 	unsigned int i;
 =

 	rt =3D l_rtnl_route_new_gateway(inet_ntop(AF_INET6, ra->address,
-							buf, sizeof(buf)));
+						gw_buf, sizeof(gw_buf)));
 	if (!rt) {
 		CLIENT_DEBUG("Unable to parse RA 'from' address");
 		return;
@@ -308,6 +308,7 @@ static void icmp6_client_setup_routes(struct l_icmp6_cl=
ient *client)
 =

 	for (i =3D 0; i < ra->n_prefixes; i++) {
 		struct route_info *info =3D &ra->prefixes[i];
+		char buf[INET6_ADDRSTRLEN];
 =

 		if (info->valid_lifetime =3D=3D 0)
 			continue;
@@ -319,6 +320,9 @@ static void icmp6_client_setup_routes(struct l_icmp6_cl=
ient *client)
 		if (!rt)
 			continue;
 =

+		if (!info->onlink)
+			l_rtnl_route_set_gateway(rt, gw_buf);
+
 		l_rtnl_route_set_preference(rt, info->preference);
 		l_rtnl_route_set_protocol(rt, RTPROT_RA);
 		l_rtnl_route_set_mtu(rt, ra->mtu);
@@ -729,6 +733,7 @@ struct l_icmp6_router *_icmp6_router_parse(const struct=
 nd_router_advert *ra,
 				break;
 =

 			i->prefix_len =3D opts[2];
+			i->onlink =3D opts[3] & 1;
 			i->valid_lifetime =3D l_get_be32(opts + 4);
 			i->preferred_lifetime =3D l_get_be32(opts + 8);
 			memcpy(i->address, opts + 16, 16);
-- =

2.32.0

--===============0398577080057716356==--

