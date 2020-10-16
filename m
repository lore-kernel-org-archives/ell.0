Content-Type: multipart/mixed; boundary="===============2664028374058831660=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 06/20] dhcp-transport: rename 'broadcast' op to 'l2_send'
Date: Fri, 16 Oct 2020 08:36:21 -0700
Message-ID: <20201016153635.660391-6-prestwoj@gmail.com>
In-Reply-To: <20201016153635.660391-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2664028374058831660==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The naming here was somewhat misleading. Functionally this was
being used as a broadcast only because the destination address
was a broadcast address. Really this operation was simply sending
out a packet on l2, which DHCP server requires except that it
needs to send to a specific MAC address, not broadcast to all.

The name was changed to better describe the API and a destination
mac argument was added to allow the server to use it. All client
code will remain nearly the same (just name changes) except
having to set the destination MAC to NULL indicating it is a
broadcast.
---
 ell/dhcp-private.h   |  3 ++-
 ell/dhcp-transport.c | 10 +++++++---
 ell/dhcp.c           |  7 ++++---
 3 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/ell/dhcp-private.h b/ell/dhcp-private.h
index 3aa89fb..a1e1155 100644
--- a/ell/dhcp-private.h
+++ b/ell/dhcp-private.h
@@ -92,9 +92,10 @@ typedef void (*dhcp_transport_rx_cb_t)(const void *, siz=
e_t, void *);
 =

 struct dhcp_transport {
 	int (*open)(struct dhcp_transport *s, uint32_t xid);
-	int (*broadcast)(struct dhcp_transport *transport,
+	int (*l2_send)(struct dhcp_transport *transport,
 						uint32_t saddr, uint16_t sport,
 						uint32_t daddr, uint16_t dport,
+						const uint8_t *dest_mac,
 						const void *data, size_t len);
 	int (*bind)(struct dhcp_transport *transport, uint32_t saddr);
 	int (*send)(struct dhcp_transport *transport,
diff --git a/ell/dhcp-transport.c b/ell/dhcp-transport.c
index b693530..8d890c6 100644
--- a/ell/dhcp-transport.c
+++ b/ell/dhcp-transport.c
@@ -194,9 +194,10 @@ static void dhcp_set_ip_udp_headers(struct iphdr *ip, =
struct udphdr *udp,
 	ip->check =3D _dhcp_checksumv(iov, 1);
 }
 =

-static int _dhcp_default_transport_broadcast(struct dhcp_transport *s,
+static int _dhcp_default_transport_l2_send(struct dhcp_transport *s,
 						uint32_t saddr, uint16_t sport,
 						uint32_t daddr, uint16_t dport,
+						const uint8_t *dest_mac,
 						const void *data, size_t len)
 {
 	struct dhcp_default_transport *transport =3D
@@ -221,7 +222,10 @@ static int _dhcp_default_transport_broadcast(struct dh=
cp_transport *s,
 	addr.sll_protocol =3D htons(ETH_P_IP);
 	addr.sll_ifindex =3D s->ifindex;
 	addr.sll_halen =3D ETH_ALEN;
-	memset(addr.sll_addr, 0xff, ETH_ALEN);
+	if (!dest_mac)
+		memset(addr.sll_addr, 0xff, ETH_ALEN);
+	else
+		memcpy(addr.sll_addr, dest_mac, ETH_ALEN);
 =

 	memset(&msg, 0, sizeof(msg));
 	msg.msg_name =3D &addr;
@@ -501,7 +505,7 @@ struct dhcp_transport *_dhcp_default_transport_new(uint=
32_t ifindex,
 	transport->super.bind =3D _dhcp_default_transport_bind;
 	transport->super.close =3D _dhcp_default_transport_close;
 	transport->super.send =3D _dhcp_default_transport_send;
-	transport->super.broadcast =3D _dhcp_default_transport_broadcast;
+	transport->super.l2_send =3D _dhcp_default_transport_l2_send;
 =

 	transport->super.ifindex =3D ifindex;
 	l_strlcpy(transport->ifname, ifname, IFNAMSIZ);
diff --git a/ell/dhcp.c b/ell/dhcp.c
index 12ed505..71a9ad9 100644
--- a/ell/dhcp.c
+++ b/ell/dhcp.c
@@ -368,9 +368,10 @@ static int dhcp_client_send_discover(struct l_dhcp_cli=
ent *client)
 =

 	_dhcp_message_builder_finalize(&builder, &len);
 =

-	return client->transport->broadcast(client->transport,
+	return client->transport->l2_send(client->transport,
 					INADDR_ANY, DHCP_PORT_CLIENT,
 					INADDR_BROADCAST, DHCP_PORT_SERVER,
+					NULL,
 					discover, len);
 }
 =

@@ -467,10 +468,10 @@ static int dhcp_client_send_request(struct l_dhcp_cli=
ent *client)
 							&si, request, len);
 	}
 =

-	return client->transport->broadcast(client->transport,
+	return client->transport->l2_send(client->transport,
 					INADDR_ANY, DHCP_PORT_CLIENT,
 					INADDR_BROADCAST, DHCP_PORT_SERVER,
-					request, len);
+					NULL, request, len);
 }
 =

 static void dhcp_client_timeout_resend(struct l_timeout *timeout,
-- =

2.26.2

--===============2664028374058831660==--

