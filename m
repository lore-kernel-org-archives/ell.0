Content-Type: multipart/mixed; boundary="===============4462309068062053809=="
MIME-Version: 1.0
From: Tim Kourt <tim.a.kourt@linux.intel.com>
Subject: [PATCH 1/2] dhcp: Stop client before notifying owner
Date: Wed, 16 Oct 2019 15:14:57 -0700
Message-ID: <20191016221458.3175-1-tim.a.kourt@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4462309068062053809==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This enables the owner of the client object to restart it.
---
 ell/dhcp.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/ell/dhcp.c b/ell/dhcp.c
index 22d903e..132d973 100644
--- a/ell/dhcp.c
+++ b/ell/dhcp.c
@@ -950,9 +950,11 @@ static void dhcp_client_rx_message(const void *data, s=
ize_t len, void *userdata)
 	case DHCP_STATE_RENEWING:
 	case DHCP_STATE_REBINDING:
 		if (msg_type =3D=3D DHCP_MESSAGE_TYPE_NAK) {
+			l_dhcp_client_stop(client);
+
 			dhcp_client_event_notify(client,
 					L_DHCP_CLIENT_EVENT_NO_LEASE);
-			goto error;
+			return;
 		}
 =

 		if (msg_type !=3D DHCP_MESSAGE_TYPE_ACK)
-- =

2.13.6

--===============4462309068062053809==--

