Content-Type: multipart/mixed; boundary="===============7348261069234028059=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/3] dhcp-server: Validate chaddr against source MAC
Date: Sat, 07 Aug 2021 01:52:58 +0200
Message-ID: <20210806235259.304436-2-andrew.zaborowski@intel.com>
In-Reply-To: <20210806235259.304436-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7348261069234028059==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

In DHCP over ethernet -- the only thing we currently support -- the
chaddr in a DHCP message should always match the client's address, i.e.
the source address in messages from client to server.  On wifi, where
the client's frame source can't be easily spoofed, validating chaddr
may add a little security.  Some other DHCP servers support this too,
either on or off by default.
---
 ell/dhcp-private.h   |  3 ++-
 ell/dhcp-server.c    |  6 +++++-
 ell/dhcp-transport.c | 16 +++++++++++++---
 ell/dhcp.c           |  3 ++-
 4 files changed, 22 insertions(+), 6 deletions(-)

diff --git a/ell/dhcp-private.h b/ell/dhcp-private.h
index 5a09f5e..bc10765 100644
--- a/ell/dhcp-private.h
+++ b/ell/dhcp-private.h
@@ -107,7 +107,8 @@ const char *_dhcp_option_to_string(uint8_t option);
 uint16_t _dhcp_checksum(const void *buf, size_t len);
 uint16_t _dhcp_checksumv(const struct iovec *iov, size_t iov_cnt);
 =

-typedef void (*dhcp_transport_rx_cb_t)(const void *, size_t, void *);
+typedef void (*dhcp_transport_rx_cb_t)(const void *, size_t, void *,
+					const uint8_t *);
 =

 struct dhcp_transport {
 	int (*open)(struct dhcp_transport *s, uint32_t xid);
diff --git a/ell/dhcp-server.c b/ell/dhcp-server.c
index 84dc41d..05f9b73 100644
--- a/ell/dhcp-server.c
+++ b/ell/dhcp-server.c
@@ -705,7 +705,8 @@ static void send_ack(struct l_dhcp_server *server,
 					server->user_data, lease);
 }
 =

-static void listener_event(const void *data, size_t len, void *user_data)
+static void listener_event(const void *data, size_t len, void *user_data,
+				const uint8_t *saddr)
 {
 	struct l_dhcp_server *server =3D user_data;
 	const struct dhcp_message *message =3D data;
@@ -722,6 +723,9 @@ static void listener_event(const void *data, size_t len=
, void *user_data)
 =

 	SERVER_DEBUG("");
 =

+	if (saddr && memcmp(saddr, message->chaddr, ETH_ALEN))
+		return;
+
 	if (!_dhcp_message_iter_init(&iter, message, len))
 		return;
 =

diff --git a/ell/dhcp-transport.c b/ell/dhcp-transport.c
index 68108e2..7c73fee 100644
--- a/ell/dhcp-transport.c
+++ b/ell/dhcp-transport.c
@@ -111,8 +111,11 @@ static bool _dhcp_default_transport_read_handler(struc=
t l_io *io,
 	ssize_t len;
 	struct dhcp_packet *p;
 	uint16_t c;
+	struct sockaddr_ll saddr;
+	socklen_t saddr_len =3D sizeof(saddr);
 =

-	len =3D read(fd, buf, sizeof(buf));
+	len =3D recvfrom(fd, buf, sizeof(buf), 0, (struct sockaddr *) &saddr,
+			&saddr_len);
 	if (len < 0)
 		return false;
 =

@@ -148,8 +151,15 @@ static bool _dhcp_default_transport_read_handler(struc=
t l_io *io,
 =

 	len -=3D sizeof(struct udphdr) - sizeof(struct iphdr);
 =

-	if (transport->super.rx_cb)
-		transport->super.rx_cb(&p->dhcp, len, transport->super.rx_data);
+	if (transport->super.rx_cb) {
+		const uint8_t *src_mac =3D NULL;
+
+		if (saddr_len >=3D sizeof(saddr) && saddr.sll_halen =3D=3D ETH_ALEN)
+			src_mac =3D saddr.sll_addr;
+
+		transport->super.rx_cb(&p->dhcp, len, transport->super.rx_data,
+					src_mac);
+	}
 =

 	return true;
 }
diff --git a/ell/dhcp.c b/ell/dhcp.c
index 2efbf39..32e4a7c 100644
--- a/ell/dhcp.c
+++ b/ell/dhcp.c
@@ -775,7 +775,8 @@ static int dhcp_client_receive_offer(struct l_dhcp_clie=
nt *client,
 	return 0;
 }
 =

-static void dhcp_client_rx_message(const void *data, size_t len, void *use=
rdata)
+static void dhcp_client_rx_message(const void *data, size_t len, void *use=
rdata,
+					const uint8_t *saddr)
 {
 	struct l_dhcp_client *client =3D userdata;
 	const struct dhcp_message *message =3D data;
-- =

2.30.2

--===============7348261069234028059==--

