Content-Type: multipart/mixed; boundary="===============8931651504295165490=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 05/14] dhcp-transport: remove XID from open()/BPF
Date: Thu, 15 Oct 2020 10:17:22 -0700
Message-ID: <20201015171731.396538-5-prestwoj@gmail.com>
In-Reply-To: <20201015171731.396538-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8931651504295165490==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

In preparation for dhcp server the XID portion of the BPF
needs to be remove as DHCP server packets will not have
the XID. In addition, the xid argument was removed from
open() since it was only needed for the BPF.

In addition, the OPCODE_BOOT_REQUEST portion of the BPF
was removed to handle both REQUEST and REPLY messages.
---
 ell/dhcp-private.h   |  2 +-
 ell/dhcp-transport.c | 18 +++---------------
 ell/dhcp.c           |  3 +--
 3 files changed, 5 insertions(+), 18 deletions(-)

diff --git a/ell/dhcp-private.h b/ell/dhcp-private.h
index 3aa89fb..bd2f01f 100644
--- a/ell/dhcp-private.h
+++ b/ell/dhcp-private.h
@@ -91,7 +91,7 @@ uint16_t _dhcp_checksumv(const struct iovec *iov, size_t =
iov_cnt);
 typedef void (*dhcp_transport_rx_cb_t)(const void *, size_t, void *);
 =

 struct dhcp_transport {
-	int (*open)(struct dhcp_transport *s, uint32_t xid);
+	int (*open)(struct dhcp_transport *s);
 	int (*broadcast)(struct dhcp_transport *transport,
 						uint32_t saddr, uint16_t sport,
 						uint32_t daddr, uint16_t dport,
diff --git a/ell/dhcp-transport.c b/ell/dhcp-transport.c
index e332f99..13e9953 100644
--- a/ell/dhcp-transport.c
+++ b/ell/dhcp-transport.c
@@ -328,7 +328,7 @@ static int _dhcp_default_transport_bind(struct dhcp_tra=
nsport *s,
 	return 0;
 }
 =

-static int kernel_raw_socket_open(uint32_t ifindex, uint16_t port, uint32_=
t xid)
+static int kernel_raw_socket_open(uint32_t ifindex, uint16_t port)
 {
 	int s;
 	struct sockaddr_ll addr;
@@ -382,11 +382,6 @@ static int kernel_raw_socket_open(uint32_t ifindex, ui=
nt16_t port, uint32_t xid)
 		/* A <- DHCP op */
 		BPF_STMT(BPF_LD + BPF_B + BPF_ABS,
 				offsetof(struct dhcp_packet, dhcp.op)),
-		/* op =3D=3D BOOTREPLY ? */
-		BPF_JUMP(BPF_JMP + BPF_JEQ + BPF_K,
-				DHCP_OP_CODE_BOOTREPLY, 1, 0),
-		/* ignore */
-		BPF_STMT(BPF_RET + BPF_K, 0),
 		/* A <- DHCP header type */
 		BPF_STMT(BPF_LD + BPF_B + BPF_ABS,
 				offsetof(struct dhcp_packet, dhcp.htype)),
@@ -394,13 +389,6 @@ static int kernel_raw_socket_open(uint32_t ifindex, ui=
nt16_t port, uint32_t xid)
 		BPF_JUMP(BPF_JMP + BPF_JEQ + BPF_K, ARPHRD_ETHER, 1, 0),
 		/* ignore */
 		BPF_STMT(BPF_RET + BPF_K, 0),
-		/* A <- client identifier */
-		BPF_STMT(BPF_LD + BPF_W + BPF_ABS,
-				offsetof(struct dhcp_packet, dhcp.xid)),
-		/* client identifier =3D=3D xid ? */
-		BPF_JUMP(BPF_JMP + BPF_JEQ + BPF_K, xid, 1, 0),
-		/* ignore */
-		BPF_STMT(BPF_RET + BPF_K, 0),
 		/* A <- MAC address length */
 		BPF_STMT(BPF_LD + BPF_B + BPF_ABS,
 				offsetof(struct dhcp_packet, dhcp.hlen)),
@@ -448,7 +436,7 @@ error:
 	return -errno;
 }
 =

-static int _dhcp_default_transport_open(struct dhcp_transport *s, uint32_t=
 xid)
+static int _dhcp_default_transport_open(struct dhcp_transport *s)
 {
 	struct dhcp_default_transport *transport =3D
 		l_container_of(s, struct dhcp_default_transport, super);
@@ -457,7 +445,7 @@ static int _dhcp_default_transport_open(struct dhcp_tra=
nsport *s, uint32_t xid)
 	if (transport->io)
 		return -EALREADY;
 =

-	fd =3D kernel_raw_socket_open(s->ifindex, transport->port, xid);
+	fd =3D kernel_raw_socket_open(s->ifindex, transport->port);
 	if (fd < 0)
 		return fd;
 =

diff --git a/ell/dhcp.c b/ell/dhcp.c
index b7b6263..aa9fe0f 100644
--- a/ell/dhcp.c
+++ b/ell/dhcp.c
@@ -972,8 +972,7 @@ LIB_EXPORT bool l_dhcp_client_start(struct l_dhcp_clien=
t *client)
 		l_getrandom(&client->xid, sizeof(client->xid));
 =

 	if (client->transport->open)
-		if (client->transport->open(client->transport,
-							client->xid) < 0)
+		if (client->transport->open(client->transport) < 0)
 			return false;
 =

 	_dhcp_transport_set_rx_callback(client->transport,
-- =

2.26.2

--===============8931651504295165490==--

