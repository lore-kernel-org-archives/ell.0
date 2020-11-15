Content-Type: multipart/mixed; boundary="===============1637140095209062751=="
MIME-Version: 1.0
From: Jonathan Liu <net147@gmail.com>
Subject: [PATCH] ell.sym: Fix l_dhcp_server_set_netmask symbol
Date: Sun, 15 Nov 2020 15:30:31 +1100
Message-ID: <20201115043031.163742-1-net147@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1637140095209062751==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Fixes: 958b8b2cac54 ("dhcp-server: basic DHCP server skeleton")
---
 ell/ell.sym | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/ell.sym b/ell/ell.sym
index 1a27fce..b02c60e 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -253,7 +253,7 @@ global:
 	l_dhcp_server_set_event_handler;
 	l_dhcp_server_set_ip_address;
 	l_dhcp_server_set_interface_name;
-	l_dhcp_server_set_netmaks;
+	l_dhcp_server_set_netmask;
 	l_dhcp_server_set_gateway;
 	l_dhcp_server_set_dns;
 	/* dhcp6 */
-- =

2.29.2

--===============1637140095209062751==--

