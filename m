Content-Type: multipart/mixed; boundary="===============3265160452600854316=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: [PATCH] dhcp-transport: Do not leak fds during bind
Date: Mon, 16 May 2022 14:55:33 -0500
Message-ID: <20220516195533.31106-1-denkenz@gmail.com>

--===============3265160452600854316==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

When a lease is renewed, the transport bind operation is called.  This
can be done multiple times by dhcp_client, whenever a lease has been
obtained or renewed.  This can result in fds being leaked.

If bind operation has previously succeeded, simply return and reuse the
already created fd.
---
 ell/dhcp-transport.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/ell/dhcp-transport.c b/ell/dhcp-transport.c
index 52da2db04f49..b466f136972c 100644
--- a/ell/dhcp-transport.c
+++ b/ell/dhcp-transport.c
@@ -361,6 +361,9 @@ static int _dhcp_default_transport_bind(struct dhcp_tra=
nsport *s,
 	if (!transport->io)
 		return -EIO;
 =

+	if (transport->udp_fd >=3D 0)
+		return 0;
+
 	fd =3D kernel_udp_socket_open(transport->ifname, saddr, transport->port);
 	if (fd < 0)
 		return fd;
@@ -552,6 +555,7 @@ struct dhcp_transport *_dhcp_default_transport_new(uint=
32_t ifindex,
 	transport->super.ifindex =3D ifindex;
 	l_strlcpy(transport->ifname, ifname, IFNAMSIZ);
 	transport->port =3D port;
+	transport->udp_fd =3D -1;
 =

 	return &transport->super;
 }
-- =

2.32.0

--===============3265160452600854316==--

