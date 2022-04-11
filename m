Content-Type: multipart/mixed; boundary="===============3309241760581898869=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 09/11] netconfig: Exit on errors in
 netconfig_dhcp_event_handler
Date: Mon, 11 Apr 2022 16:20:54 +0200
Message-ID: <20220411142056.817784-9-andrew.zaborowski@intel.com>
In-Reply-To: 20220411142056.817784-1-andrew.zaborowski@intel.com

--===============3309241760581898869==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Don't just warn on errors that could cause a crash later in the function
even though in theory they can't happen.
---
 ell/netconfig.c | 18 ++++++++++++------
 1 file changed, 12 insertions(+), 6 deletions(-)

diff --git a/ell/netconfig.c b/ell/netconfig.c
index 6641398..030b2e1 100644
--- a/ell/netconfig.c
+++ b/ell/netconfig.c
@@ -292,28 +292,34 @@ static void netconfig_dhcp_event_handler(struct l_dhc=
p_client *client,
 =

 	switch (event) {
 	case L_DHCP_CLIENT_EVENT_IP_CHANGED:
-		L_WARN_ON(!nc->v4_configured);
+		if (L_WARN_ON(!nc->v4_configured))
+			break;
+
 		netconfig_remove_dhcp_address_routes(nc);
 		netconfig_add_dhcp_address_routes(nc);
 		netconfig_set_dhcp_lifetimes(nc, false);
 		netconfig_emit_event(nc, AF_INET, L_NETCONFIG_EVENT_UPDATE);
 		break;
 	case L_DHCP_CLIENT_EVENT_LEASE_OBTAINED:
-	{
-		L_WARN_ON(nc->v4_configured);
+		if (L_WARN_ON(nc->v4_configured))
+			break;
+
 		netconfig_add_dhcp_address_routes(nc);
 		netconfig_set_dhcp_lifetimes(nc, false);
 		nc->v4_configured =3D true;
 		netconfig_emit_event(nc, AF_INET, L_NETCONFIG_EVENT_CONFIGURE);
 		break;
-	}
 	case L_DHCP_CLIENT_EVENT_LEASE_RENEWED:
-		L_WARN_ON(!nc->v4_configured);
+		if (L_WARN_ON(!nc->v4_configured))
+			break;
+
 		netconfig_set_dhcp_lifetimes(nc, true);
 		netconfig_emit_event(nc, AF_INET, L_NETCONFIG_EVENT_UPDATE);
 		break;
 	case L_DHCP_CLIENT_EVENT_LEASE_EXPIRED:
-		L_WARN_ON(!nc->v4_configured);
+		if (L_WARN_ON(!nc->v4_configured))
+			break;
+
 		netconfig_remove_dhcp_address_routes(nc);
 		nc->v4_configured =3D false;
 =

-- =

2.32.0

--===============3309241760581898869==--

