Content-Type: multipart/mixed; boundary="===============1754965114806961086=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 01/14] netconfig: Reset {v4,
 v6}_configured to false on netconfig stop
Date: Thu, 16 Jun 2022 00:47:26 +0200
Message-ID: <20220615224739.1936538-1-andrew.zaborowski@intel.com>

--===============1754965114806961086==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/netconfig.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/ell/netconfig.c b/ell/netconfig.c
index 2a1b3ed..5de5d74 100644
--- a/ell/netconfig.c
+++ b/ell/netconfig.c
@@ -1163,6 +1163,8 @@ LIB_EXPORT void l_netconfig_stop(struct l_netconfig *=
netconfig)
 	netconfig->v4_subnet_route =3D NULL;
 	netconfig->v4_default_route =3D NULL;
 	netconfig->v6_address =3D NULL;
+	netconfig->v4_configured =3D false;
+	netconfig->v6_configured =3D false;
 =

 	l_dhcp_client_stop(netconfig->dhcp_client);
 	l_dhcp6_client_stop(netconfig->dhcp6_client);
-- =

2.34.1

--===============1754965114806961086==--

