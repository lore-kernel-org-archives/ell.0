Content-Type: multipart/mixed; boundary="===============4331646290469909893=="
MIME-Version: 1.0
From: Tim Kourt <tim.a.kourt@linux.intel.com>
Subject: [PATCH] dhcp: Reset lease on client stop
Date: Thu, 20 Jun 2019 13:48:14 -0700
Message-ID: <20190620204814.24577-1-tim.a.kourt@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4331646290469909893==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The un-reset lease variable used to be freed multiple times
when the client is explicitly stopped before being destroyed.

=3D=3D12374=3D=3D Invalid read of size 8
=3D=3D12374=3D=3D    at 0x46C889: _dhcp_lease_free (dhcp-lease.c:47)
=3D=3D12374=3D=3D    by 0x46B5F2: l_dhcp_client_stop (dhcp.c:1220)
=3D=3D12374=3D=3D    by 0x46B61D: l_dhcp_client_destroy (dhcp.c:1011)
---
 ell/dhcp.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/ell/dhcp.c b/ell/dhcp.c
index f57f13b..57d5ae2 100644
--- a/ell/dhcp.c
+++ b/ell/dhcp.c
@@ -1218,6 +1218,8 @@ LIB_EXPORT bool l_dhcp_client_stop(struct l_dhcp_clie=
nt *client)
 	CLIENT_ENTER_STATE(DHCP_STATE_INIT);
 =

 	_dhcp_lease_free(client->lease);
+	client->lease =3D NULL;
+
 	return true;
 }
 =

-- =

2.13.6


--===============4331646290469909893==--

