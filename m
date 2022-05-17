Content-Type: multipart/mixed; boundary="===============2432579076522800431=="
MIME-Version: 1.0
From: Michael Johnson <mjohnson459 at gmail.com>
To: ell at lists.01.org
Subject: [PATCH 3/3] unit: Pass in max logging level for dhcp
Date: Tue, 17 May 2022 17:18:31 +0100
Message-ID: <20220517161831.126597-3-mjohnson459@gmail.com>
In-Reply-To: 20220517161831.126597-1-mjohnson459@gmail.com

--===============2432579076522800431==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-dhcp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/unit/test-dhcp.c b/unit/test-dhcp.c
index e734e03..3c340fc 100644
--- a/unit/test-dhcp.c
+++ b/unit/test-dhcp.c
@@ -811,7 +811,7 @@ static struct l_dhcp_client *client_init(const uint8_t =
*mac)
 				event_handler_lease_obtained, NULL, NULL));
 =

 	if (verbose)
-		l_dhcp_client_set_debug(client, do_debug, "[DHCP1] ", NULL);
+		l_dhcp_client_set_debug(client, do_debug, "[DHCP1] ", NULL, L_LOG_DEBUG);
 =

 	transport->send =3D fake_transport_send;
 	transport->l2_send =3D fake_transport_l2_send;
-- =

2.25.1

--===============2432579076522800431==--

