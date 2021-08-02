Content-Type: multipart/mixed; boundary="===============0059363245913124424=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 06/15] dhcp-server: Save lease mac before calling add_lease
Date: Mon, 02 Aug 2021 16:04:15 +0200
Message-ID: <20210802140424.170150-6-andrew.zaborowski@intel.com>
In-Reply-To: <20210802140424.170150-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0059363245913124424==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

add_lease will re-use the existing lease struct but will memzero it and
the fill in the data.  We can't pass lease->mac to add_lease() because
the mac will be zeroed together with the rest of the structure and will
be all-zeros when add_lease() tries to copy the new value from the
pointer we passed.
---
 ell/dhcp-server.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/ell/dhcp-server.c b/ell/dhcp-server.c
index 5c511f7..bdf43d7 100644
--- a/ell/dhcp-server.c
+++ b/ell/dhcp-server.c
@@ -1266,13 +1266,16 @@ LIB_EXPORT struct l_dhcp_lease *l_dhcp_server_disco=
ver(
 LIB_EXPORT bool l_dhcp_server_request(struct l_dhcp_server *server,
 					struct l_dhcp_lease *lease)
 {
+	uint8_t mac[ETH_ALEN];
+
 	if (unlikely(!lease))
 		return false;
 =

 	SERVER_DEBUG("Requested IP " NIPQUAD_FMT " for " MAC,
 			NIPQUAD(lease->address), MAC_STR(lease->mac));
 =

-	lease =3D add_lease(server, false, NULL, lease->mac, lease->address);
+	memcpy(mac, lease->mac, ETH_ALEN);
+	lease =3D add_lease(server, false, NULL, mac, lease->address);
 =

 	if (server->event_handler)
 		server->event_handler(server, L_DHCP_SERVER_EVENT_NEW_LEASE,
-- =

2.30.2

--===============0059363245913124424==--

