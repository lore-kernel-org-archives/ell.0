Content-Type: multipart/mixed; boundary="===============8607799069136229071=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/3] dhcp-server: Fix debug messages in send_offer
Date: Fri, 09 Jul 2021 13:47:41 +0200
Message-ID: <20210709114743.378521-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8607799069136229071==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

find_free_or_expired_ip() or check_requested_ip() should fail if no
addresses are left in the pool, rather than lease_add() so emit that
error message there.  The only thing lease_add() validates that has not
been validated before might be the origin MAC, treat the lease_add()
failure more as an internal error.
---
 ell/dhcp-server.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/ell/dhcp-server.c b/ell/dhcp-server.c
index 34512ae..b761833 100644
--- a/ell/dhcp-server.c
+++ b/ell/dhcp-server.c
@@ -451,13 +451,13 @@ static void send_offer(struct l_dhcp_server *server,
 							client_msg->chaddr);
 =

 	if (!reply->yiaddr) {
-		SERVER_DEBUG("Could not find lease or send offer");
+		SERVER_DEBUG("No free IP addresses, OFFER abandoned");
 		return;
 	}
 =

 	lease =3D add_lease(server, true, client_msg->chaddr, reply->yiaddr);
 	if (!lease) {
-		SERVER_DEBUG("No free IP addresses, OFFER abandoned");
+		SERVER_DEBUG("add_lease() failed");
 		return;
 	}
 =

-- =

2.30.2

--===============8607799069136229071==--

