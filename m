Content-Type: multipart/mixed; boundary="===============2906253415034033269=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 2/6] dhcp-server: fix incorrect setting of lease OFFER_TIME
Date: Wed, 18 Nov 2020 11:00:52 -0800
Message-ID: <20201118190056.3584080-2-prestwoj@gmail.com>
In-Reply-To: <20201118190056.3584080-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2906253415034033269==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

When in the offer stage the lease expiration was being set to
OFFER_TIME, rather than the current time plus OFFER_TIME.
---
 ell/dhcp-server.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/ell/dhcp-server.c b/ell/dhcp-server.c
index 4a7e8e3..fc6bdbf 100644
--- a/ell/dhcp-server.c
+++ b/ell/dhcp-server.c
@@ -350,8 +350,8 @@ static void send_offer(struct l_dhcp_server *server,
 		return;
 	}
 =

-	lease =3D add_lease(server, OFFER_TIME, client_msg->chaddr,
-				reply->yiaddr);
+	lease =3D add_lease(server, l_time_to_secs(l_time_now()) + OFFER_TIME,
+				client_msg->chaddr, reply->yiaddr);
 	if (!lease) {
 		SERVER_DEBUG("No free IP addresses, OFFER abandoned");
 		return;
-- =

2.26.2

--===============2906253415034033269==--

