Content-Type: multipart/mixed; boundary="===============1163240320656566699=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/2] dhcp-server: Add API for manipulating leases
Date: Mon, 19 Jul 2021 16:00:19 +0200
Message-ID: <20210719140020.555503-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1163240320656566699==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add methods for obtaining and releasing DHCP leases.  There are four
methods that correspond to the DISCOVER, REQUEST, DECLINE and RELEASE
messages and two shortcut methods for releasing the leases.  This API is
useful for implementing mechanisms like the optional P2P IP Allocation
in the 802.11 4-Way Handshake and FILS IP Address Allocation in 802.11
Associate frames (both reduces the number of roundtrips in connection
setup).  Since there are multiple such mechanisms I decided to include
discover and request as separate methods to allow more flexibility.
---
 ell/dhcp-server.c | 106 +++++++++++++++++++++++++++++++++++++++++++++-
 ell/dhcp.h        |  15 +++++++
 ell/ell.sym       |   6 +++
 3 files changed, 125 insertions(+), 2 deletions(-)

diff --git a/ell/dhcp-server.c b/ell/dhcp-server.c
index ecdd612..fa5a7db 100644
--- a/ell/dhcp-server.c
+++ b/ell/dhcp-server.c
@@ -126,12 +126,14 @@ static struct l_dhcp_lease *find_lease_by_mac(struct =
l_dhcp_server *server,
 	return l_queue_find(server->lease_list, match_lease_mac, mac);
 }
 =

-static void remove_lease(struct l_dhcp_server *server,
+static bool remove_lease(struct l_dhcp_server *server,
 				struct l_dhcp_lease *lease)
 {
-	l_queue_remove(server->lease_list, lease);
+	if (!l_queue_remove(server->lease_list, lease))
+		return false;
 =

 	_dhcp_lease_free(lease);
+	return true;
 }
 =

 /* Clear the old lease and create the new one */
@@ -1042,3 +1044,103 @@ failed:
 	l_free(dns_list);
 	return false;
 }
+
+LIB_EXPORT struct l_dhcp_lease *l_dhcp_server_discover(
+						struct l_dhcp_server *server,
+						uint32_t requested_ip_opt,
+						const uint8_t *mac)
+{
+	struct l_dhcp_lease *lease;
+
+	SERVER_DEBUG("Requested IP " NIPQUAD_FMT " for " MAC,
+			NIPQUAD(requested_ip_opt), MAC_STR(mac));
+
+	if ((lease =3D find_lease_by_mac(server, mac)))
+		requested_ip_opt =3D lease->address;
+	else if (!check_requested_ip(server, requested_ip_opt)) {
+		requested_ip_opt =3D find_free_or_expired_ip(server, mac);
+
+		if (unlikely(!requested_ip_opt)) {
+			SERVER_DEBUG("Could not find any free addresses");
+			return NULL;
+		}
+	}
+
+	lease =3D add_lease(server, true, mac, requested_ip_opt);
+	if (unlikely(!lease)) {
+		SERVER_DEBUG("add_lease() failed");
+		return NULL;
+	}
+
+	SERVER_DEBUG("Offering " NIPQUAD_FMT " to " MAC,
+			NIPQUAD(requested_ip_opt), MAC_STR(mac));
+	return lease;
+}
+
+LIB_EXPORT bool l_dhcp_server_request(struct l_dhcp_server *server,
+					struct l_dhcp_lease *lease)
+{
+	if (unlikely(!lease))
+		return false;
+
+	SERVER_DEBUG("Requested IP " NIPQUAD_FMT " for " MAC,
+			NIPQUAD(lease->address), MAC_STR(lease->mac));
+
+	lease =3D add_lease(server, false, lease->mac, lease->address);
+
+	if (server->event_handler)
+		server->event_handler(server, L_DHCP_SERVER_EVENT_NEW_LEASE,
+					server->user_data, lease);
+
+	return true;
+}
+
+LIB_EXPORT bool l_dhcp_server_decline(struct l_dhcp_server *server,
+					struct l_dhcp_lease *lease)
+{
+	if (unlikely(!lease || !lease->offering))
+		return false;
+
+	SERVER_DEBUG("Declined IP " NIPQUAD_FMT " for " MAC,
+			NIPQUAD(lease->address), MAC_STR(lease->mac));
+
+	return remove_lease(server, lease);
+}
+
+LIB_EXPORT bool l_dhcp_server_release(struct l_dhcp_server *server,
+					struct l_dhcp_lease *lease)
+{
+	if (unlikely(!lease || lease->offering))
+		return false;
+
+	SERVER_DEBUG("Released IP " NIPQUAD_FMT " for " MAC,
+			NIPQUAD(lease->address), MAC_STR(lease->mac));
+
+	lease_release(server, lease);
+	return true;
+}
+
+/* Drop an offered, active or expired lease without moving it to expired_l=
ist */
+LIB_EXPORT bool l_dhcp_server_lease_remove(struct l_dhcp_server *server,
+						struct l_dhcp_lease *lease)
+{
+	if (unlikely(!lease))
+		return false;
+
+	if (unlikely(!l_queue_remove(server->lease_list, lease) &&
+			!l_queue_remove(server->expired_list, lease)))
+		return false;
+
+	_dhcp_lease_free(lease);
+	set_next_expire_timer(server, NULL);
+	return true;
+}
+
+LIB_EXPORT void l_dhcp_server_expire_by_mac(struct l_dhcp_server *server,
+						const uint8_t *mac)
+{
+	struct l_dhcp_lease *lease =3D find_lease_by_mac(server, mac);
+
+	if (likely(lease))
+		lease_release(server, lease);
+}
diff --git a/ell/dhcp.h b/ell/dhcp.h
index 2af75cc..2804c78 100644
--- a/ell/dhcp.h
+++ b/ell/dhcp.h
@@ -141,6 +141,21 @@ bool l_dhcp_server_set_ip_address(struct l_dhcp_server=
 *server,
 bool l_dhcp_server_set_netmask(struct l_dhcp_server *server, const char *m=
ask);
 bool l_dhcp_server_set_gateway(struct l_dhcp_server *server, const char *i=
p);
 bool l_dhcp_server_set_dns(struct l_dhcp_server *server, char **dns);
+
+struct l_dhcp_lease *l_dhcp_server_discover(struct l_dhcp_server *server,
+						uint32_t requested_ip_opt,
+						const uint8_t *mac);
+bool l_dhcp_server_request(struct l_dhcp_server *server,
+				struct l_dhcp_lease *lease);
+bool l_dhcp_server_decline(struct l_dhcp_server *server,
+				struct l_dhcp_lease *lease);
+bool l_dhcp_server_release(struct l_dhcp_server *server,
+				struct l_dhcp_lease *lease);
+
+bool l_dhcp_server_lease_remove(struct l_dhcp_server *server,
+				struct l_dhcp_lease *lease);
+void l_dhcp_server_expire_by_mac(struct l_dhcp_server *server,
+					const uint8_t *mac);
 #ifdef __cplusplus
 }
 #endif
diff --git a/ell/ell.sym b/ell/ell.sym
index e5eeefb..4d41448 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -259,6 +259,12 @@ global:
 	l_dhcp_server_set_netmask;
 	l_dhcp_server_set_gateway;
 	l_dhcp_server_set_dns;
+	l_dhcp_server_discover;
+	l_dhcp_server_request;
+	l_dhcp_server_decline;
+	l_dhcp_server_release;
+	l_dhcp_server_lease_remove;
+	l_dhcp_server_lease_expire_by_mac;
 	/* dhcp6 */
 	l_dhcp6_client_new;
 	l_dhcp6_client_destroy;
-- =

2.30.2

--===============1163240320656566699==--

