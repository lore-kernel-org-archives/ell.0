Content-Type: multipart/mixed; boundary="===============7177148810032243359=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 1/2] dhcp: add ACD to DHCP client
Date: Thu, 10 Dec 2020 09:39:57 -0800
Message-ID: <20201210173958.873756-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7177148810032243359==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This starts the ACD client once DHCP binds to an address.
The ACD client is (for now) configured to defend its address
infinitely. This maintains existing behavior except that
ACD announcements are now sent if conflicts are detected.
---
 ell/dhcp.c | 43 +++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 43 insertions(+)

diff --git a/ell/dhcp.c b/ell/dhcp.c
index e104845..f212e9b 100644
--- a/ell/dhcp.c
+++ b/ell/dhcp.c
@@ -41,6 +41,7 @@
 #include "dhcp-private.h"
 #include "netlink.h"
 #include "rtnl.h"
+#include "acd.h"
 =

 #define CLIENT_DEBUG(fmt, args...)					\
 	l_util_debug(client->debug_handler, client->debug_data,		\
@@ -190,6 +191,7 @@ struct l_dhcp_client {
 	l_dhcp_destroy_cb_t event_destroy;
 	l_dhcp_debug_cb_t debug_handler;
 	l_dhcp_destroy_cb_t debug_destroy;
+	struct l_acd *acd;
 	void *debug_data;
 	bool have_addr : 1;
 	bool override_xid : 1;
@@ -777,6 +779,7 @@ static void dhcp_client_rx_message(const void *data, si=
ze_t len, void *userdata)
 	uint8_t t, l;
 	const void *v;
 	int r;
+	struct in_addr ia;
 =

 	CLIENT_DEBUG("");
 =

@@ -877,6 +880,41 @@ static void dhcp_client_rx_message(const void *data, s=
ize_t len, void *userdata)
 							dhcp_client_t1_expired,
 							client, NULL);
 		}
+
+		/* ACD is already running, no need to re-announce */
+		if (client->acd)
+			break;
+
+		client->acd =3D l_acd_new(client->ifindex);
+
+		if (client->debug_handler)
+			l_acd_set_debug(client->acd, client->debug_handler,
+					client->debug_data,
+					client->debug_destroy);
+
+		/*
+		 * TODO: There is no mechanism yet to deal with IPs leased by
+		 * the DHCP server which conflict with other devices. For now
+		 * the ACD object is being initialized to defend infinitely
+		 * which is effectively no different than the non-ACD behavior
+		 * (ignore conflicts and continue using address). The only
+		 * change is that announcements will be sent if conflicts are
+		 * found.
+		 */
+		l_acd_set_defend_policy(client->acd,
+						L_ACD_DEFEND_POLICY_INFINITE);
+		l_acd_set_skip_probes(client->acd, true);
+
+		ia.s_addr =3D client->lease->address;
+
+		/* For unit testing we don't want this to be a fatal error */
+		if (!l_acd_start(client->acd, inet_ntoa(ia))) {
+			CLIENT_DEBUG("Failed to start ACD on %s, continuing",
+						inet_ntoa(ia));
+			l_acd_destroy(client->acd);
+			client->acd =3D NULL;
+		}
+
 		break;
 	case DHCP_STATE_INIT_REBOOT:
 	case DHCP_STATE_REBOOTING:
@@ -1156,6 +1194,11 @@ LIB_EXPORT bool l_dhcp_client_stop(struct l_dhcp_cli=
ent *client)
 	_dhcp_lease_free(client->lease);
 	client->lease =3D NULL;
 =

+	if (client->acd) {
+		l_acd_destroy(client->acd);
+		client->acd =3D NULL;
+	}
+
 	return true;
 }
 =

-- =

2.26.2

--===============7177148810032243359==--

