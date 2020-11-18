Content-Type: multipart/mixed; boundary="===============8347743481452507409=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 6/6] dhcp-server: print actual lifetime for new lease
Date: Wed, 18 Nov 2020 11:00:56 -0800
Message-ID: <20201118190056.3584080-6-prestwoj@gmail.com>
In-Reply-To: <20201118190056.3584080-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8347743481452507409==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The leases expiration time was being printed, which is an
offset off the current time rather than the actual lease
time.
---
 ell/dhcp-server.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/dhcp-server.c b/ell/dhcp-server.c
index f418ed5..c51ebf3 100644
--- a/ell/dhcp-server.c
+++ b/ell/dhcp-server.c
@@ -293,7 +293,7 @@ static struct l_dhcp_lease *add_lease(struct l_dhcp_ser=
ver *server,
 =

 	SERVER_DEBUG("added lease IP %s for "MAC " lifetime=3D%u",
 			IP_STR(yiaddr), MAC_STR(chaddr),
-			lease->lifetime);
+			server->lease_seconds);
 =

 	return lease;
 }
-- =

2.26.2

--===============8347743481452507409==--

