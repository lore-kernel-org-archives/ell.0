Content-Type: multipart/mixed; boundary="===============2113511045673550570=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH] dhcp-server: Fill in DNS info in lease objects
Date: Sat, 28 Aug 2021 05:06:32 +0200
Message-ID: <20210828030632.28287-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2113511045673550570==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Copy the DNS info that we send to the client also to the lease object
that we keep on our side for our own tracking, same as we copy the IP,
the gateway, the netmask etc.
---
 ell/dhcp-server.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/ell/dhcp-server.c b/ell/dhcp-server.c
index 05f9b73..9c0628a 100644
--- a/ell/dhcp-server.c
+++ b/ell/dhcp-server.c
@@ -316,6 +316,13 @@ static struct l_dhcp_lease *add_lease(struct l_dhcp_se=
rver *server,
 	lease->subnet_mask =3D server->netmask;
 	lease->router =3D server->gateway;
 =

+	if (server->dns_list) {
+		unsigned int i;
+
+		for (i =3D 0; server->dns_list[i]; i++);
+		lease->dns =3D l_memdup(server->dns_list, (i + 1) * 4);
+	}
+
 	if (client_id)
 		lease->client_id =3D l_memdup(client_id, client_id[0] + 1);
 =

-- =

2.30.2

--===============2113511045673550570==--

