Content-Type: multipart/mixed; boundary="===============2096194444250475066=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH v2 5/9] dhcp: add private _dhcp_client_get_transport
Date: Mon, 23 Nov 2020 10:47:36 -0800
Message-ID: <20201123184740.4023017-5-prestwoj@gmail.com>
In-Reply-To: <20201123184740.4023017-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2096194444250475066==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

A convenience for unit tests so the client transport doesn't need
to be tracked.
---
 ell/dhcp-private.h | 1 +
 ell/dhcp.c         | 9 +++++++++
 2 files changed, 10 insertions(+)

diff --git a/ell/dhcp-private.h b/ell/dhcp-private.h
index 11f8220..379792c 100644
--- a/ell/dhcp-private.h
+++ b/ell/dhcp-private.h
@@ -140,6 +140,7 @@ int _dhcp_option_append(uint8_t **buf, size_t *buflen, =
uint8_t code,
 =

 bool _dhcp_client_set_transport(struct l_dhcp_client *client,
 					struct dhcp_transport *transport);
+struct dhcp_transport *_dhcp_client_get_transport(struct l_dhcp_client *cl=
ient);
 void _dhcp_client_override_xid(struct l_dhcp_client *client, uint32_t xid);
 =

 bool _dhcp_server_set_transport(struct l_dhcp_server *server,
diff --git a/ell/dhcp.c b/ell/dhcp.c
index dc4e73b..e104845 100644
--- a/ell/dhcp.c
+++ b/ell/dhcp.c
@@ -1025,6 +1025,15 @@ bool _dhcp_client_set_transport(struct l_dhcp_client=
 *client,
 	return true;
 }
 =

+struct dhcp_transport *_dhcp_client_get_transport(struct l_dhcp_client *cl=
ient)
+{
+	if (unlikely(!client))
+		return NULL;
+
+	return client->transport;
+}
+
+
 void _dhcp_client_override_xid(struct l_dhcp_client *client, uint32_t xid)
 {
 	client->override_xid =3D true;
-- =

2.26.2

--===============2096194444250475066==--

