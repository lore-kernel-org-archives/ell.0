Content-Type: multipart/mixed; boundary="===============7108150736932336852=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/2] dhcp-server: Stricter start_ip/end_ip checks
Date: Wed, 03 Mar 2021 22:35:35 +0100
Message-ID: <20210303213536.808395-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7108150736932336852==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add basic checks that start_ip/end_ip are in the subnet defined by
server->address and server->netmask.  Exclude server->address from
allowed client addresses since we don't prohibit a start_ip/end_ip
combination that contains server->address (and that's Ok).  Slightly
modify how the default end_ip is derived from server->address to work
with any prefix_length -- that seems to have been the only place that
made assumptions about the prefix length.
---
 ell/dhcp-server.c | 34 ++++++++++++++++++++++++++++++----
 1 file changed, 30 insertions(+), 4 deletions(-)

diff --git a/ell/dhcp-server.c b/ell/dhcp-server.c
index 3bc1eac..68b6f13 100644
--- a/ell/dhcp-server.c
+++ b/ell/dhcp-server.c
@@ -323,7 +323,10 @@ static bool check_requested_ip(struct l_dhcp_server *s=
erver,
 	if (ntohl(requested_nip) < server->start_ip)
 		return false;
 =

-	if (htonl(requested_nip) > server->end_ip)
+	if (ntohl(requested_nip) > server->end_ip)
+		return false;
+
+	if (requested_nip =3D=3D server->address)
 		return false;
 =

 	lease =3D find_lease_by_ip(server->lease_list, requested_nip);
@@ -361,6 +364,9 @@ static uint32_t find_free_or_expired_ip(struct l_dhcp_s=
erver *server,
 		if ((ip_addr & 0xff) =3D=3D 0xff)
 			continue;
 =

+		if (ip_nl =3D=3D server->address)
+			continue;
+
 		/*
 		 * Search both active and expired leases. If this exausts all
 		 * IP's in the range pop the expired list (oldest expired lease)
@@ -778,13 +784,33 @@ LIB_EXPORT bool l_dhcp_server_start(struct l_dhcp_ser=
ver *server)
 =

 	/*
 	 * Assign a default ip range if not already. This will default to
-	 * server->address + 1 ... 254
+	 * server->address + 1 ... subnet end address - 1
 	 */
 	if (!server->start_ip) {
-		server->start_ip =3D L_BE32_TO_CPU(server->address) + 1;
-		server->end_ip =3D (server->start_ip & 0xffffff00) | 0xfe;
+		server->start_ip =3D ntohl(server->address) + 1;
+		server->end_ip =3D ntohl(server->address) |
+			(~ntohl(server->netmask));
+	} else {
+		if ((server->start_ip ^ ntohl(server->address)) &
+				ntohl(server->netmask))
+			return false;
+
+		if ((server->end_ip ^ ntohl(server->address)) &
+				ntohl(server->netmask))
+			return false;
 	}
 =

+	/*
+	 * We skip over IPs ending in 0 or 255 when selecting a free address
+	 * later on but make sure end_ip is not 0xffffffff so we can use
+	 * "<=3D server->end_ip" safely in the loop condition.
+	 */
+	if ((server->end_ip & 0xff) =3D=3D 255)
+		server->end_ip--;
+
+	if (server->start_ip > server->end_ip)
+		return false;
+
 	if (!server->ifname) {
 		server->ifname =3D l_net_get_name(server->ifindex);
 =

-- =

2.27.0

--===============7108150736932336852==--

