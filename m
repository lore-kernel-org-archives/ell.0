Content-Type: multipart/mixed; boundary="===============4562628123414032505=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 2/3] dhcp: free rtnl address on error
Date: Mon, 08 Feb 2021 11:27:55 -0800
Message-ID: <20210208192756.580521-2-prestwoj@gmail.com>
In-Reply-To: <20210208192756.580521-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4562628123414032505==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/dhcp.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/ell/dhcp.c b/ell/dhcp.c
index f212e9b..d05ec70 100644
--- a/ell/dhcp.c
+++ b/ell/dhcp.c
@@ -740,8 +740,10 @@ static int dhcp_client_receive_ack(struct l_dhcp_clien=
t *client,
 						client, NULL);
 		if (client->rtnl_add_cmdid)
 			client->rtnl_configured_address =3D a;
-		else
+		else {
 			CLIENT_DEBUG("Configuring address via RTNL failed");
+			l_rtnl_address_free(a);
+		}
 	}
 =

 	return r;
-- =

2.26.2

--===============4562628123414032505==--

