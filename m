Content-Type: multipart/mixed; boundary="===============0767466823034342903=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 07/15] dhcp-server: Ensure broadcast address is not selected
Date: Mon, 02 Aug 2021 16:04:16 +0200
Message-ID: <20210802140424.170150-7-andrew.zaborowski@intel.com>
In-Reply-To: <20210802140424.170150-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0767466823034342903==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

In find_free_or_expired_ip, get_lease and check_requested_ip we'd allow
addresses up to and including server->end_ip meaning that in some
situations the broadcast address might have been allowed as a valid
client address.  find_free_or_expired_ip would check that the address
didn't end in .255 but that is only correct for a 24-bit netmask.  Now
set start_ip to be at least one address above the subnet address and
end_ip to be at lesat one address below the broadcast address.
---
 ell/dhcp-server.c | 34 +++++++++++++++++++++++-----------
 1 file changed, 23 insertions(+), 11 deletions(-)

diff --git a/ell/dhcp-server.c b/ell/dhcp-server.c
index bdf43d7..a4e7002 100644
--- a/ell/dhcp-server.c
+++ b/ell/dhcp-server.c
@@ -971,8 +971,8 @@ LIB_EXPORT bool l_dhcp_server_start(struct l_dhcp_serve=
r *server)
 	 */
 	if (!server->start_ip) {
 		server->start_ip =3D ntohl(server->address) + 1;
-		server->end_ip =3D ntohl(server->address) |
-			(~ntohl(server->netmask));
+		server->end_ip =3D (ntohl(server->address) |
+			(~ntohl(server->netmask))) - 1;
 	} else {
 		if ((server->start_ip ^ ntohl(server->address)) &
 				ntohl(server->netmask))
@@ -981,17 +981,29 @@ LIB_EXPORT bool l_dhcp_server_start(struct l_dhcp_ser=
ver *server)
 		if ((server->end_ip ^ ntohl(server->address)) &
 				ntohl(server->netmask))
 			return false;
-	}
 =

-	/*
-	 * We skip over IPs ending in 0 or 255 when selecting a free address
-	 * later on but make sure end_ip is not 0xffffffff so we can use
-	 * "<=3D server->end_ip" safely in the loop condition.
-	 */
-	if ((server->end_ip & 0xff) =3D=3D 255)
-		server->end_ip--;
+		/*
+		 * Directly ensure the [start_ip, end_ip] range doesn't
+		 * include the subnet address or the broadcast address so that
+		 * we have fewer checks to make when selecting a free address
+		 * from that range.  Additionally this ensures end_ip is not
+		 * 0xffffffff so we can use the condition "<=3D server->end_ip"
+		 * safely on uint32_t values.
+		 * In find_free_or_expired_ip we skip over IPs ending in .0 or
+		 * .255 even for netmasks other than 24-bit just to avoid
+		 * generating addresses that could look suspicious even if
+		 * they're legal.  We don't exclude these addresses when
+		 * explicitly requested by the client, i.e. in
+		 * check_requested_ip.
+		 */
+		if ((server->start_ip & (~ntohl(server->netmask))) =3D=3D 0)
+			server->start_ip++;
+
+		if ((server->end_ip | ntohl(server->netmask)) =3D=3D 0xffffffff)
+			server->end_ip--;
+	}
 =

-	if (server->start_ip > server->end_ip)
+	if (server->start_ip >=3D server->end_ip)
 		return false;
 =

 	if (!server->ifname) {
-- =

2.30.2

--===============0767466823034342903==--

