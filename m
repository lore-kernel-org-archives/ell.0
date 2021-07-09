Content-Type: multipart/mixed; boundary="===============9176236632484746752=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/3] dhcp-server: Fill in netmask & gateway in lease objects
Date: Fri, 09 Jul 2021 13:47:42 +0200
Message-ID: <20210709114743.378521-2-andrew.zaborowski@intel.com>
In-Reply-To: <20210709114743.378521-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============9176236632484746752==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

When creating new l_dhcp_lease objects for client leases, also fill in
the netmask and the gateway fields for the benefit of the users of those
lease objects outside dhcp-server.c.
---
 ell/dhcp-server.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/ell/dhcp-server.c b/ell/dhcp-server.c
index b761833..759276e 100644
--- a/ell/dhcp-server.c
+++ b/ell/dhcp-server.c
@@ -262,6 +262,8 @@ static struct l_dhcp_lease *add_lease(struct l_dhcp_ser=
ver *server,
 =

 	memcpy(lease->mac, chaddr, ETH_ALEN);
 	lease->address =3D yiaddr;
+	lease->subnet_mask =3D server->netmask;
+	lease->router =3D server->gateway;
 =

 	lease->offering =3D offering;
 	lease->bound_time =3D l_time_now();
-- =

2.30.2

--===============9176236632484746752==--

