Content-Type: multipart/mixed; boundary="===============0886104389011450551=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 04/12] dhcp6: Set lease expiry based on frame reception times
Date: Mon, 07 Mar 2022 15:55:35 +0100
Message-ID: <20220307145543.1558788-4-andrew.zaborowski@intel.com>
In-Reply-To: 20220307145543.1558788-1-andrew.zaborowski@intel.com

--===============0886104389011450551==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Use the SO_TIMESTAMP socket option to request the packet rx timestamps
from the kernel and pass those values from dhcp6-transport to
dhcp6-client to use in lease expiry time calculation.

Apparently linux has a few different variants of SO_TIMESTAMP, use the
most basic one.  Additionally the rx times can be obtained without
SO_TIMESTAMP using the SIOCGSTAMP ioctl on each packet.  The advantage
would be that we'd only parse the timestamps for the frames where we
actually care about timing.  The disadvantage would be an extra syscall
for those frames, which we don't incur with SO_TIMESTAMP.
---
 ell/dhcp6-private.h   |  2 +-
 ell/dhcp6-transport.c | 36 ++++++++++++++++++++++++++++++++----
 ell/dhcp6.c           | 11 +++++++----
 3 files changed, 40 insertions(+), 9 deletions(-)

diff --git a/ell/dhcp6-private.h b/ell/dhcp6-private.h
index 2bbd1d3..e27cb7e 100644
--- a/ell/dhcp6-private.h
+++ b/ell/dhcp6-private.h
@@ -80,7 +80,7 @@ struct dhcp6_option_iter {
 	uint16_t max;
 };
 =

-typedef void (*dhcp6_transport_rx_cb_t)(const void *, size_t, void *);
+typedef void (*dhcp6_transport_rx_cb_t)(const void *, size_t, uint64_t, vo=
id *);
 =

 struct dhcp6_transport {
 	int (*open)(struct dhcp6_transport *s);
diff --git a/ell/dhcp6-transport.c b/ell/dhcp6-transport.c
index feb890f..04bf4fb 100644
--- a/ell/dhcp6-transport.c
+++ b/ell/dhcp6-transport.c
@@ -39,6 +39,7 @@
 #include "private.h"
 #include "missing.h"
 #include "io.h"
+#include "time.h"
 #include "dhcp6-private.h"
 =

 struct dhcp6_default_transport {
@@ -56,14 +57,38 @@ static bool _dhcp6_default_transport_read_handler(struc=
t l_io *io,
 	int fd =3D l_io_get_fd(io);
 	char buf[2048];
 	ssize_t len;
-
-	len =3D read(fd, buf, sizeof(buf));
+	uint64_t timestamp =3D 0;
+	struct cmsghdr *cmsg;
+	struct iovec iov =3D { .iov_base =3D buf, .iov_len =3D sizeof(buf) };
+	struct msghdr msg =3D {};
+	unsigned char control[32];
+
+	msg.msg_iov =3D &iov;
+	msg.msg_iovlen =3D 1;
+	msg.msg_control =3D control;
+	msg.msg_controllen =3D sizeof(control);
+
+	len =3D recvmsg(fd, &msg, 0);
 	if (len < 0)
 		return false;
 =

-	if (transport->super.rx_cb)
-		transport->super.rx_cb(&buf, len, transport->super.rx_data);
+	if (!transport->super.rx_cb)
+		return true;
+
+	for (cmsg =3D CMSG_FIRSTHDR(&msg); cmsg !=3D NULL;
+					cmsg =3D CMSG_NXTHDR(&msg, cmsg)) {
+		if (cmsg->cmsg_level =3D=3D SOL_SOCKET &&
+				cmsg->cmsg_type =3D=3D SCM_TIMESTAMP) {
+			const struct timeval *tv =3D (void *) CMSG_DATA(cmsg);
+
+			timestamp =3D tv->tv_sec * L_USEC_PER_SEC + tv->tv_usec;
+		}
+	}
+
+	if (!timestamp)
+		timestamp =3D l_time_now();
 =

+	transport->super.rx_cb(&buf, len, timestamp, transport->super.rx_data);
 	return true;
 }
 =

@@ -146,6 +171,9 @@ static int kernel_raw_socket_open(uint32_t ifindex,
 			goto error;
 	}
 =

+	if (setsockopt(s, SOL_SOCKET, SO_TIMESTAMP, &yes, sizeof(yes)) < 0)
+		goto error;
+
 	if (bind(s, (struct sockaddr *) &addr, sizeof(addr)) < 0)
 		goto error;
 =

diff --git a/ell/dhcp6.c b/ell/dhcp6.c
index 40c6f3a..34635fe 100644
--- a/ell/dhcp6.c
+++ b/ell/dhcp6.c
@@ -962,13 +962,14 @@ static void dhcp6_client_address_add_cb(int error, ui=
nt16_t type,
 	}
 }
 =

-static void dhcp6_client_setup_lease(struct l_dhcp6_client *client)
+static void dhcp6_client_setup_lease(struct l_dhcp6_client *client,
+					uint64_t timestamp)
 {
 	uint32_t t1 =3D _dhcp6_lease_get_t1(client->lease);
 	uint32_t t2 =3D _dhcp6_lease_get_t2(client->lease);
 	enum l_dhcp6_client_event event;
 =

-	client->lease_start_t =3D l_time_now();
+	client->lease_start_t =3D timestamp;
 =

 	/* TODO: Emit IP_CHANGED if any addresses were removed / added */
 	if (client->state =3D=3D DHCP6_STATE_REQUESTING ||
@@ -1008,6 +1009,8 @@ static void dhcp6_client_setup_lease(struct l_dhcp6_c=
lient *client)
 		a =3D l_rtnl_address_new(ip, prefix_len);
 		l_rtnl_address_set_noprefixroute(a, true);
 		l_rtnl_address_set_lifetimes(a, p, v);
+		l_rtnl_address_set_expiry(a, timestamp + p * L_USEC_PER_SEC,
+						timestamp + v * L_USEC_PER_SEC);
 =

 		client->rtnl_add_cmdid =3D
 			l_rtnl_ifaddr_add(client->rtnl, client->ifindex, a,
@@ -1353,7 +1356,7 @@ bad_lease:
 }
 =

 static void dhcp6_client_rx_message(const void *data, size_t len,
-								void *userdata)
+					uint64_t timestamp, void *userdata)
 {
 	struct l_dhcp6_client *client =3D userdata;
 	const struct dhcp6_message *message =3D data;
@@ -1413,7 +1416,7 @@ static void dhcp6_client_rx_message(const void *data,=
 size_t len,
 	if (r =3D=3D DHCP6_STATE_BOUND) {
 		l_timeout_remove(client->timeout_send);
 		client->timeout_send =3D NULL;
-		dhcp6_client_setup_lease(client);
+		dhcp6_client_setup_lease(client, timestamp);
 		return;
 	}
 =

-- =

2.32.0

--===============0886104389011450551==--

