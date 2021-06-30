Content-Type: multipart/mixed; boundary="===============7117785408099419675=="
MIME-Version: 1.0
From: Michael Johnson <mjohnson459@gmail.com>
Subject: [PATCH] Add logging if bind function fails
Date: Wed, 30 Jun 2021 14:51:12 +0100
Message-ID: <20210630135112.47106-1-mjohnson459@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7117785408099419675==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The bind function returns any errors it encounters but they were
silently being discarded in this method. This at least logs this if
debug messages are enabled.

In the future it would be nice to have this log even if the debug output
isn't enabled as DHCP will not be working correctly.
---
 ell/dhcp.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/ell/dhcp.c b/ell/dhcp.c
index bd346cc..115325e 100644
--- a/ell/dhcp.c
+++ b/ell/dhcp.c
@@ -782,7 +782,7 @@ static void dhcp_client_rx_message(const void *data, si=
ze_t len, void *userdata)
 	uint8_t msg_type =3D 0;
 	uint8_t t, l;
 	const void *v;
-	int r;
+	int r, e;
 	struct in_addr ia;
 =

 	CLIENT_DEBUG("");
@@ -855,9 +855,14 @@ static void dhcp_client_rx_message(const void *data, s=
ize_t len, void *userdata)
 		l_timeout_remove(client->timeout_resend);
 		client->timeout_resend =3D NULL;
 =

-		if (client->transport->bind)
-			client->transport->bind(client->transport,
+		if (client->transport->bind) {
+			e =3D client->transport->bind(client->transport,
 						client->lease->address);
+			if (e < 0) {
+				CLIENT_DEBUG("Failed to bind dhcp socket. "
+					"Error %d: %s", e, strerror(-e));
+			}
+		}
 =

 		dhcp_client_event_notify(client, r);
 =

-- =

2.25.1

--===============7117785408099419675==--

