Content-Type: multipart/mixed; boundary="===============0229537928794950898=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 02/11] icmp6: Parse extra options
Date: Thu, 21 Apr 2022 00:10:15 +0200
Message-ID: <20220420221024.1276317-2-andrew.zaborowski@intel.com>
In-Reply-To: 20220420221024.1276317-1-andrew.zaborowski@intel.com

--===============0229537928794950898==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Parse Route Information and New Advertisement Interval options.  Route
Information options (RIOs) are supported by radvd and a few clients that
I checked.
---
 ell/icmp6-private.h |   6 ++-
 ell/icmp6.c         | 118 +++++++++++++++++++++++++++++++++++++++-----
 2 files changed, 110 insertions(+), 14 deletions(-)

diff --git a/ell/icmp6-private.h b/ell/icmp6-private.h
index 2433087..77df0b8 100644
--- a/ell/icmp6-private.h
+++ b/ell/icmp6-private.h
@@ -22,6 +22,7 @@
 =

 struct route_info {
 	uint8_t address[16];
+	bool onlink : 1;
 	uint8_t prefix_len;
 	uint8_t preference;
 	uint32_t preferred_lifetime;
@@ -36,8 +37,9 @@ struct l_icmp6_router {
 	uint64_t start_time;
 	uint16_t lifetime;
 	uint32_t mtu;
-	uint32_t n_prefixes;
-	struct route_info *prefixes;
+	uint32_t max_rtr_adv_interval_ms;
+	uint32_t n_routes;
+	struct route_info *routes;
 };
 =

 struct l_icmp6_router *_icmp6_router_new();
diff --git a/ell/icmp6.c b/ell/icmp6.c
index 0422a59..93b30f9 100644
--- a/ell/icmp6.c
+++ b/ell/icmp6.c
@@ -51,6 +51,11 @@
 #include "icmp6.h"
 #include "icmp6-private.h"
 =

+/* RFC4191 */
+#ifndef ND_OPT_ROUTE_INFORMATION
+#define ND_OPT_ROUTE_INFORMATION	24
+#endif
+
 #define CLIENT_DEBUG(fmt, args...)					\
 	l_util_debug(client->debug_handler, client->debug_data,		\
 			"%s:%i " fmt, __func__, __LINE__, ## args)
@@ -328,16 +333,24 @@ static void icmp6_client_setup_routes(struct l_icmp6_=
client *client)
 		l_rtnl_route_add(client->rtnl, client->ifindex, rt,
 					NULL, NULL, NULL);
 =

-	for (i =3D 0; i < ra->n_prefixes; i++) {
-		struct route_info *info =3D &ra->prefixes[i];
+	for (i =3D 0; i < ra->n_routes; i++) {
+		char prefix_buf[INET6_ADDRSTRLEN];
+		struct route_info *info =3D &ra->routes[i];
 =

 		if (info->valid_lifetime =3D=3D 0)
 			continue;
 =

-		if (!inet_ntop(AF_INET6, info->address, buf, sizeof(buf)))
+		if (!inet_ntop(AF_INET6, info->address, prefix_buf,
+				sizeof(prefix_buf)))
 			continue;
 =

-		rt =3D l_rtnl_route_new_prefix(buf, info->prefix_len);
+		if (info->onlink)
+			rt =3D l_rtnl_route_new_prefix(prefix_buf,
+							info->prefix_len);
+		else
+			rt =3D l_rtnl_route_new_static(buf, prefix_buf,
+							info->prefix_len);
+
 		if (!rt)
 			continue;
 =

@@ -669,7 +682,7 @@ struct l_icmp6_router *_icmp6_router_new()
 =

 void _icmp6_router_free(struct l_icmp6_router *r)
 {
-	l_free(r->prefixes);
+	l_free(r->routes);
 	l_free(r);
 }
 =

@@ -681,7 +694,7 @@ struct l_icmp6_router *_icmp6_router_parse(const struct=
 nd_router_advert *ra,
 	struct l_icmp6_router *r;
 	const uint8_t *opts;
 	uint32_t opts_len;
-	uint32_t n_prefixes =3D 0;
+	uint32_t n_routes =3D 0;
 =

 	if (ra->nd_ra_type !=3D ND_ROUTER_ADVERT)
 		return NULL;
@@ -718,7 +731,35 @@ struct l_icmp6_router *_icmp6_router_parse(const struc=
t nd_router_advert *ra,
 				return NULL;
 =

 			if (opts[3] & ND_OPT_PI_FLAG_ONLINK)
-				n_prefixes +=3D 1;
+				n_routes +=3D 1;
+			break;
+		case ND_OPT_ROUTE_INFORMATION:
+			if (l < 8)
+				return NULL;
+
+			if (opts[2] > 128 || opts[2] > (l - 8) * 8)
+				return NULL;
+
+			/*
+			 * RFC 4191 Section 2.3:
+			 * "If the Reserved (10) value is received, the Route
+			 * Information Option MUST be ignored."
+			 */
+			if (bit_field(opts[3], 3, 2) =3D=3D 2)
+				break;
+
+			/*
+			 * RFC 4191 Section 3.1:
+			 * "The Router Preference and Lifetime values in a ::/0
+			 * Route Information Option override the preference and
+			 * lifetime values in the Router Advertisement header."
+			 *
+			 * Don't count ::/0 routes.
+			 */
+			if (opts[2] =3D=3D 0)
+				break;
+
+			n_routes +=3D 1;
 			break;
 		}
 =

@@ -728,8 +769,8 @@ struct l_icmp6_router *_icmp6_router_parse(const struct=
 nd_router_advert *ra,
 =

 	r =3D _icmp6_router_new();
 	memcpy(r->address, src, sizeof(r->address));
-	r->prefixes =3D l_new(struct route_info, n_prefixes);
-	r->n_prefixes =3D n_prefixes;
+	r->routes =3D l_new(struct route_info, n_routes);
+	r->n_routes =3D n_routes;
 =

 	if (ra->nd_ra_flags_reserved & ND_RA_FLAG_MANAGED)
 		r->managed =3D true;
@@ -746,7 +787,7 @@ struct l_icmp6_router *_icmp6_router_parse(const struct=
 nd_router_advert *ra,
 =

 	opts =3D (uint8_t *) (ra + 1);
 	opts_len =3D len - sizeof(struct nd_router_advert);
-	n_prefixes =3D 0;
+	n_routes =3D 0;
 =

 	while (opts_len) {
 		uint8_t t =3D opts[0];
@@ -764,17 +805,70 @@ struct l_icmp6_router *_icmp6_router_parse(const stru=
ct nd_router_advert *ra,
 			break;
 		case ND_OPT_PREFIX_INFORMATION:
 		{
-			struct route_info *i =3D &r->prefixes[n_prefixes];
+			struct route_info *i =3D &r->routes[n_routes];
 =

 			if (!(opts[3] & ND_OPT_PI_FLAG_ONLINK))
 				break;
 =

 			i->prefix_len =3D opts[2];
+			i->onlink =3D true;
 			i->valid_lifetime =3D l_get_be32(opts + 4);
 			i->preferred_lifetime =3D l_get_be32(opts + 8);
 			memcpy(i->address, opts + 16, 16);
 =

-			n_prefixes +=3D 1;
+			n_routes +=3D 1;
+			break;
+		}
+		case ND_OPT_RTR_ADV_INTERVAL:
+			if (l < 8)
+				break;
+
+			r->max_rtr_adv_interval_ms =3D l_get_be32(opts + 4);
+			break;
+		case ND_OPT_ROUTE_INFORMATION:
+		{
+			struct route_info *i =3D &r->routes[n_routes++];
+			uint8_t preference =3D bit_field(opts[3], 3, 2);
+
+			if (preference =3D=3D 2)
+				break;
+
+			/*
+			 * RFC 4191 Section 3.1:
+			 * "The Router Preference and Lifetime values in a ::/0
+			 * Route Information Option override the preference and
+			 * lifetime values in the Router Advertisement header."
+			 */
+			if (opts[2] =3D=3D 0) {
+				if (r->lifetime =3D=3D 0 && l_get_be32(opts + 4)) {
+					/*
+					 * A ::/0 route received from a
+					 * non-default router?  Should issue
+					 * a warning?
+					 */
+					break;
+				}
+
+				r->pref =3D preference;
+				r->lifetime =3D l_get_be16(opts + 4) ? 0xffff :
+					l_get_be16(opts + 6);
+				break;
+			}
+
+			/*
+			 * Don't check or warn if the route lifetime is longer
+			 * than the router lifetime because that refers to its
+			 * time as the default router.  It may be configured to
+			 * route packets for us for specific prefixes without
+			 * being a default router.
+			 */
+			i->prefix_len =3D opts[2];
+			i->onlink =3D false;
+			i->preference =3D preference;
+			i->valid_lifetime =3D l_get_be32(opts + 4);
+			memcpy(i->address, opts + 8, (i->prefix_len + 7) / 8);
+
+			n_routes +=3D 1;
 			break;
 		}
 		}
-- =

2.32.0

--===============0229537928794950898==--

