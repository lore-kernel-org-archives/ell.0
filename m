Content-Type: multipart/mixed; boundary="===============5291038375470389068=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH v2 6/9] dhcp-server: add private setter for max expired clients
Date: Mon, 23 Nov 2020 10:47:37 -0800
Message-ID: <20201123184740.4023017-6-prestwoj@gmail.com>
In-Reply-To: <20201123184740.4023017-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5291038375470389068==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Convenience for unit tests so the max expired clients can be
set artificially low.
---
 ell/dhcp-private.h |  3 +++
 ell/dhcp-server.c  | 11 +++++++++++
 2 files changed, 14 insertions(+)

diff --git a/ell/dhcp-private.h b/ell/dhcp-private.h
index 379792c..204e54e 100644
--- a/ell/dhcp-private.h
+++ b/ell/dhcp-private.h
@@ -147,6 +147,9 @@ bool _dhcp_server_set_transport(struct l_dhcp_server *s=
erver,
 					struct dhcp_transport *transport);
 struct dhcp_transport *_dhcp_server_get_transport(struct l_dhcp_server *se=
rver);
 =

+bool _dhcp_server_set_max_expired_clients(struct l_dhcp_server *server,
+						unsigned int max_expired);
+
 struct l_dhcp_lease {
 	uint32_t address;
 	uint32_t server_address;
diff --git a/ell/dhcp-server.c b/ell/dhcp-server.c
index e4d65b8..78b6b47 100644
--- a/ell/dhcp-server.c
+++ b/ell/dhcp-server.c
@@ -676,6 +676,17 @@ static void listener_event(const void *data, size_t le=
n, void *user_data)
 	}
 }
 =

+bool _dhcp_server_set_max_expired_clients(struct l_dhcp_server *server,
+						unsigned int max_expired)
+{
+	if (unlikely(!server))
+		return false;
+
+	server->max_expired =3D max_expired;
+
+	return true;
+}
+
 bool _dhcp_server_set_transport(struct l_dhcp_server *server,
 					struct dhcp_transport *transport)
 {
-- =

2.26.2

--===============5291038375470389068==--

