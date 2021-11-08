Content-Type: multipart/mixed; boundary="===============7501656408228120631=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH] dhcp6: Switch to BOUND before LEASE_OBTAINED
Date: Mon, 08 Nov 2021 12:29:01 +0100
Message-ID: <20211108112901.372486-1-andrew.zaborowski@intel.com>

--===============7501656408228120631==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Reorder actions so that when we obtain the lease, we first switch to
DHCP6_STATE_BOUND and configure the address + emit
L_DHCP6_CLIENT_EVENT_LEASE_OBTAINED after that.  This allows the event
handler to use l_dhcp6_client_get_lease().  l_dhcp6_client_get_lease is
hardwired to return NULL in DHCP6_STATE_REQUESTING.

Issue reported by T=C3=A9rence Clastres.
---
 ell/dhcp6.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/dhcp6.c b/ell/dhcp6.c
index 67d4628..7dfc664 100644
--- a/ell/dhcp6.c
+++ b/ell/dhcp6.c
@@ -1401,8 +1401,8 @@ static void dhcp6_client_rx_message(const void *data,=
 size_t len,
 	if (r =3D=3D DHCP6_STATE_BOUND) {
 		l_timeout_remove(client->timeout_send);
 		client->timeout_send =3D NULL;
-		dhcp6_client_setup_lease(client);
 		dhcp6_client_new_transaction(client, r);
+		dhcp6_client_setup_lease(client);
 		return;
 	}
 =

-- =

2.32.0

--===============7501656408228120631==--

