Content-Type: multipart/mixed; boundary="===============5465629344372461542=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH v2 4/9] dhcp-server: add private _dhcp_server_get_transport
Date: Mon, 23 Nov 2020 10:47:35 -0800
Message-ID: <20201123184740.4023017-4-prestwoj@gmail.com>
In-Reply-To: <20201123184740.4023017-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5465629344372461542==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

A convenience for unit tests so the server transport doesn't need
to be tracked.
---
 ell/dhcp-private.h | 1 +
 ell/dhcp-server.c  | 8 ++++++++
 2 files changed, 9 insertions(+)

diff --git a/ell/dhcp-private.h b/ell/dhcp-private.h
index 17d0574..11f8220 100644
--- a/ell/dhcp-private.h
+++ b/ell/dhcp-private.h
@@ -144,6 +144,7 @@ void _dhcp_client_override_xid(struct l_dhcp_client *cl=
ient, uint32_t xid);
 =

 bool _dhcp_server_set_transport(struct l_dhcp_server *server,
 					struct dhcp_transport *transport);
+struct dhcp_transport *_dhcp_server_get_transport(struct l_dhcp_server *se=
rver);
 =

 struct l_dhcp_lease {
 	uint32_t address;
diff --git a/ell/dhcp-server.c b/ell/dhcp-server.c
index c01aba2..e4d65b8 100644
--- a/ell/dhcp-server.c
+++ b/ell/dhcp-server.c
@@ -689,6 +689,14 @@ bool _dhcp_server_set_transport(struct l_dhcp_server *=
server,
 	return true;
 }
 =

+struct dhcp_transport *_dhcp_server_get_transport(struct l_dhcp_server *se=
rver)
+{
+	if (unlikely(!server))
+		return NULL;
+
+	return server->transport;
+}
+
 LIB_EXPORT struct l_dhcp_server *l_dhcp_server_new(int ifindex)
 {
 	struct l_dhcp_server *server =3D l_new(struct l_dhcp_server, 1);
-- =

2.26.2

--===============5465629344372461542==--

