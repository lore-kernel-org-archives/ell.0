Content-Type: multipart/mixed; boundary="===============8875901376462354844=="
MIME-Version: 1.0
From: Davide Caratti <davide.caratti@gmail.com>
Subject: [PATCH 2/2] avoid using inet_aton()
Date: Thu, 03 Jun 2021 11:50:03 +0200
Message-ID: <febf75f8dd0a4a97e4d650a8655752aef0aa685e.1622713571.git.davide.caratti@gmail.com>
In-Reply-To: <cover.1622713571.git.davide.caratti@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8875901376462354844==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

use inet_pton(AF_INET,...), like it's done elsewhere for IPv6.

Signed-off-by: Davide Caratti <davide.caratti@gmail.com>
---
 ell/dhcp-server.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/ell/dhcp-server.c b/ell/dhcp-server.c
index 43f06b3..e39e456 100644
--- a/ell/dhcp-server.c
+++ b/ell/dhcp-server.c
@@ -773,7 +773,7 @@ LIB_EXPORT bool l_dhcp_server_start(struct l_dhcp_serve=
r *server)
 =

 	/* Assign a default netmask if not already */
 	if (!server->netmask) {
-		if (inet_aton("255.255.255.0", &ia) < 0)
+		if (inet_pton(AF_INET,"255.255.255.0", &ia) !=3D 1)
 			return false;
 =

 		server->netmask =3D ia.s_addr;
@@ -890,12 +890,12 @@ LIB_EXPORT bool l_dhcp_server_set_ip_range(struct l_d=
hcp_server *server,
 	if (unlikely(!server || !start_ip || !end_ip))
 		return false;
 =

-	if (inet_aton(start_ip, &_host_addr) =3D=3D 0)
+	if (inet_pton(AF_INET, start_ip, &_host_addr) !=3D 1)
 		return false;
 =

 	start =3D ntohl(_host_addr.s_addr);
 =

-	if (inet_aton((const char *) end_ip, &_host_addr) =3D=3D 0)
+	if (inet_pton(AF_INET, (const char *) end_ip, &_host_addr) !=3D 1)
 		return false;
 =

 	server->start_ip =3D start;
@@ -952,7 +952,7 @@ LIB_EXPORT bool l_dhcp_server_set_ip_address(struct l_d=
hcp_server *server,
 	if (unlikely(!server))
 		return false;
 =

-	if (inet_aton(ip, &ia) < 0)
+	if (inet_pton(AF_INET, ip, &ia) !=3D 1)
 		return false;
 =

 	server->address =3D ia.s_addr;
@@ -980,7 +980,7 @@ LIB_EXPORT bool l_dhcp_server_set_netmask(struct l_dhcp=
_server *server,
 	if (unlikely(!server || !mask))
 		return false;
 =

-	if (inet_aton(mask, &ia) < 0)
+	if (inet_pton(AF_INET, mask, &ia) !=3D 1)
 		return false;
 =

 	server->netmask =3D ia.s_addr;
@@ -996,7 +996,7 @@ LIB_EXPORT bool l_dhcp_server_set_gateway(struct l_dhcp=
_server *server,
 	if (unlikely(!server || !ip))
 		return false;
 =

-	if (inet_aton(ip, &ia) < 0)
+	if (inet_pton(AF_INET, ip, &ia) !=3D 1)
 		return false;
 =

 	server->gateway =3D ia.s_addr;
@@ -1017,7 +1017,7 @@ LIB_EXPORT bool l_dhcp_server_set_dns(struct l_dhcp_s=
erver *server, char **dns)
 	for (i =3D 0; dns[i]; i++) {
 		struct in_addr ia;
 =

-		if (inet_aton(dns[i], &ia) < 0)
+		if (inet_pton(AF_INET, dns[i], &ia) !=3D 1)
 			goto failed;
 =

 		dns_list[i] =3D ia.s_addr;
-- =

2.31.1

--===============8875901376462354844==--

