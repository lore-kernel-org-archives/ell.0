Content-Type: multipart/mixed; boundary="===============9012581571682427030=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 07/20] unit: update test-dhcp to use l2_send
Date: Fri, 16 Oct 2020 08:36:22 -0700
Message-ID: <20201016153635.660391-7-prestwoj@gmail.com>
In-Reply-To: <20201016153635.660391-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============9012581571682427030==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-dhcp.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/unit/test-dhcp.c b/unit/test-dhcp.c
index d825401..6ae8d71 100644
--- a/unit/test-dhcp.c
+++ b/unit/test-dhcp.c
@@ -673,9 +673,10 @@ static int fake_transport_send(struct dhcp_transport *=
transport,
 	return len;
 }
 =

-static int fake_transport_broadcast(struct dhcp_transport *transprot,
+static int fake_transport_l2_send(struct dhcp_transport *transprot,
 					uint32_t saddr, uint16_t sport,
 					uint32_t daddr, uint16_t dport,
+					const uint8_t *dest_mac,
 					const void *data, size_t len)
 {
 	assert(len <=3D sizeof(client_packet));
@@ -702,7 +703,7 @@ static void test_discover(const void *data)
 	const struct l_dhcp_lease *lease;
 =

 	transport->send =3D fake_transport_send;
-	transport->broadcast =3D fake_transport_broadcast;
+	transport->l2_send =3D fake_transport_l2_send;
 	transport->ifindex =3D 42;
 =

 	client =3D l_dhcp_client_new(42);
-- =

2.26.2

--===============9012581571682427030==--

