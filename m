Content-Type: multipart/mixed; boundary="===============2953971531823872896=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 17/17] icmp6: Ignore bad prefixes per RFC4862
Date: Fri, 13 May 2022 16:55:10 +0200
Message-ID: <20220513145510.1408510-17-andrew.zaborowski@intel.com>
In-Reply-To: 20220513145510.1408510-1-andrew.zaborowski@intel.com

--===============2953971531823872896==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

"Silently ignore" Prefix Information options with a preferred time
longer than valid time and those matching the link-local prefix as
mandated by RFC4862 Section 5.5.3.  These prefixes are also invalid
according to RFC4861.
---
 ell/icmp6.c | 27 +++++++++++++++++++++++++++
 1 file changed, 27 insertions(+)

diff --git a/ell/icmp6.c b/ell/icmp6.c
index ab2fe9c..57cdd1b 100644
--- a/ell/icmp6.c
+++ b/ell/icmp6.c
@@ -819,6 +819,26 @@ struct l_icmp6_router *_icmp6_router_parse(const struc=
t nd_router_advert *ra,
 			i->preferred_lifetime =3D l_get_be32(opts + 8);
 			memcpy(i->address, opts + 16, 16);
 =

+			/*
+			 * Only the initial Prefix Length bits of the prefix
+			 * are valid.  The remaining bits "MUST" be ignored
+			 * by the receiver.
+			 */
+			l_net_mask_prefix(i->address, i->prefix_len, 16);
+
+			/*
+			 * For SLAAC (RFC4862) we need to "silently ignore"
+			 * routes with a preferred lifetime longer than valid
+			 * lifetime, and those with the link-local prefix.
+			 * Since it makes sense, do it regardless of SLAAC.
+			 */
+			if (i->preferred_lifetime > i->valid_lifetime)
+				break;
+
+			if (i->prefix_len >=3D 10 &&
+					IN6_IS_ADDR_LINKLOCAL(i->address))
+				break;
+
 			n_routes +=3D 1;
 			break;
 		}
@@ -871,6 +891,13 @@ struct l_icmp6_router *_icmp6_router_parse(const struc=
t nd_router_advert *ra,
 			i->valid_lifetime =3D l_get_be32(opts + 4);
 			memcpy(i->address, opts + 8, (i->prefix_len + 7) / 8);
 =

+			/*
+			 * Only the initial Prefix Length bits of the prefix
+			 * are valid.  The remaining bits "MUST" be ignored
+			 * by the receiver.
+			 */
+			l_net_clear_host_bits(i->address, i->prefix_len, 16);
+
 			n_routes +=3D 1;
 			break;
 		}
-- =

2.32.0

--===============2953971531823872896==--

