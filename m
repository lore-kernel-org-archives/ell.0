Content-Type: multipart/mixed; boundary="===============5531014439110884525=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 2/2] dhcp-server: add ACD client
Date: Thu, 10 Dec 2020 09:39:58 -0800
Message-ID: <20201210173958.873756-2-prestwoj@gmail.com>
In-Reply-To: <20201210173958.873756-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5531014439110884525==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Starts ACD on the servers IP address. This address will be
defended indefinitely.
---
 ell/dhcp-server.c | 23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

diff --git a/ell/dhcp-server.c b/ell/dhcp-server.c
index 144e83e..3bc1eac 100644
--- a/ell/dhcp-server.c
+++ b/ell/dhcp-server.c
@@ -39,6 +39,7 @@
 #include "util.h"
 #include "strv.h"
 #include "timeout.h"
+#include "acd.h"
 =

 /* 8 hours */
 #define DEFAULT_DHCP_LEASE_SEC (8*60*60)
@@ -80,6 +81,8 @@ struct l_dhcp_server {
 	l_dhcp_destroy_cb_t event_destroy;
 =

 	struct dhcp_transport *transport;
+
+	struct l_acd *acd;
 };
 =

 #define MAC "%02x:%02x:%02x:%02x:%02x:%02x"
@@ -807,6 +810,21 @@ LIB_EXPORT bool l_dhcp_server_start(struct l_dhcp_serv=
er *server)
 =

 	server->started =3D true;
 =

+	server->acd =3D l_acd_new(server->ifindex);
+	l_acd_set_skip_probes(server->acd, true);
+	l_acd_set_defend_policy(server->acd, L_ACD_DEFEND_POLICY_INFINITE);
+
+	ia.s_addr =3D server->address;
+
+	/* In case of unit testing we don't want this to be a fatal error */
+	if (!l_acd_start(server->acd, inet_ntoa(ia))) {
+		SERVER_DEBUG("Failed to start ACD on %s, continuing without",
+				IP_STR(server->address));
+
+		l_acd_destroy(server->acd);
+		server->acd =3D NULL;
+	}
+
 	return true;
 }
 =

@@ -828,6 +846,11 @@ LIB_EXPORT bool l_dhcp_server_stop(struct l_dhcp_serve=
r *server)
 		server->next_expire =3D NULL;
 	}
 =

+	if (server->acd) {
+		l_acd_destroy(server->acd);
+		server->acd =3D NULL;
+	}
+
 	/* TODO: Add ability to save leases */
 =

 	return true;
-- =

2.26.2

--===============5531014439110884525==--

