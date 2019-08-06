Content-Type: multipart/mixed; boundary="===============7728800453739081207=="
MIME-Version: 1.0
From: James Prestwood <james.prestwood@linux.intel.com>
Subject: [PATCH] dhcp: fix T1 timeout crash
Date: Tue, 06 Aug 2019 13:46:28 -0700
Message-ID: <20190806204628.17351-1-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7728800453739081207==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The timeout user data was being passed as the address to the
client object, not the client object itself.
---
 ell/dhcp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/dhcp.c b/ell/dhcp.c
index ca81311..22d903e 100644
--- a/ell/dhcp.c
+++ b/ell/dhcp.c
@@ -985,7 +985,7 @@ static void dhcp_client_rx_message(const void *data, si=
ze_t len, void *userdata)
 		client->timeout_lease =3D
 			l_timeout_create_ms(dhcp_fuzz_secs(client->lease->t1),
 						dhcp_client_t1_expired,
-						&client, NULL);
+						client, NULL);
 =

 		break;
 	case DHCP_STATE_INIT_REBOOT:
-- =

2.17.1


--===============7728800453739081207==--

