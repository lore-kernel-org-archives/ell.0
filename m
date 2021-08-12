Content-Type: multipart/mixed; boundary="===============1921208907639953004=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 4/4] dhcp: Optimize dhcp_client_address_add sligtly
Date: Thu, 12 Aug 2021 22:51:12 +0200
Message-ID: <20210812205112.86584-4-andrew.zaborowski@intel.com>
In-Reply-To: <20210812205112.86584-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1921208907639953004==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Don't allocate/build a netmask string when we can use
client->lease->subnet_mask directly -- we access client->lease fields
directly in most of this file.
---
 ell/dhcp.c | 13 ++-----------
 1 file changed, 2 insertions(+), 11 deletions(-)

diff --git a/ell/dhcp.c b/ell/dhcp.c
index 49398d5..7878f0c 100644
--- a/ell/dhcp.c
+++ b/ell/dhcp.c
@@ -685,22 +685,13 @@ static void dhcp_client_address_add_cb(int error, uin=
t16_t type,
 =

 static void dhcp_client_address_add(struct l_dhcp_client *client)
 {
-	struct l_rtnl_address *a;
 	L_AUTO_FREE_VAR(char *, ip) =3D l_dhcp_lease_get_address(client->lease);
-	uint8_t prefix_len;
+	uint8_t prefix_len =3D __builtin_popcountl(client->lease->subnet_mask);
+	struct l_rtnl_address *a =3D l_rtnl_address_new(ip, prefix_len);
 	uint32_t l =3D l_dhcp_lease_get_lifetime(client->lease);
-	L_AUTO_FREE_VAR(char *, netmask) =3D
-			l_dhcp_lease_get_netmask(client->lease);
 	L_AUTO_FREE_VAR(char *, broadcast) =3D
 			l_dhcp_lease_get_broadcast(client->lease);
-	struct in_addr in_addr;
 =

-	if (inet_pton(AF_INET, netmask, &in_addr) > 0)
-		prefix_len =3D __builtin_popcountl(in_addr.s_addr);
-	else
-		prefix_len =3D 24;
-
-	a =3D l_rtnl_address_new(ip, prefix_len);
 	l_rtnl_address_set_noprefixroute(a, true);
 	l_rtnl_address_set_lifetimes(a, l, l);
 	l_rtnl_address_set_broadcast(a, broadcast);
-- =

2.30.2

--===============1921208907639953004==--

