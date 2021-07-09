Content-Type: multipart/mixed; boundary="===============7414228882269861192=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 3/3] dhcp-server: Add l_dhcp_server_{new,release}_lease
Date: Fri, 09 Jul 2021 13:47:43 +0200
Message-ID: <20210709114743.378521-3-andrew.zaborowski@intel.com>
In-Reply-To: <20210709114743.378521-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7414228882269861192==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add API for obtaining and releasing DHCP leases directly, as if by
sending the appropriate DISCOVER, REQUEST and RELEASE messages but with
just method calls.  This is useful for implementing mechanisms like the
optional 802.11 4-Way Handshake IP Allocation (reduces the number of
roundtrips in a P2P connection setup).
---
 ell/dhcp-server.c | 52 +++++++++++++++++++++++++++++++++++++++++++++--
 ell/dhcp.h        |  5 +++++
 ell/ell.sym       |  2 ++
 3 files changed, 57 insertions(+), 2 deletions(-)

diff --git a/ell/dhcp-server.c b/ell/dhcp-server.c
index 759276e..e392bb7 100644
--- a/ell/dhcp-server.c
+++ b/ell/dhcp-server.c
@@ -129,12 +129,14 @@ static struct l_dhcp_lease *find_lease_by_mac(struct =
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
@@ -1043,3 +1045,49 @@ failed:
 	l_free(dns_list);
 	return false;
 }
+
+/*
+ * Create a new lease, like by sending a DISCOVER and a REQUEST.  The lease
+ * stays valid until the server is destroyed, l_dhcp_server_release_lease =
is
+ * called or L_DHCP_SERVER_EVENT_LEASE_EXPIRED is emitted for it.
+ */
+LIB_EXPORT struct l_dhcp_lease *l_dhcp_server_new_lease(
+						struct l_dhcp_server *server,
+						const uint8_t *mac)
+{
+	struct l_dhcp_lease *lease;
+	uint32_t ip =3D find_free_or_expired_ip(server, mac);
+
+	if (!ip) {
+		SERVER_DEBUG("Could not find any free addresses");
+		return NULL;
+	}
+
+	lease =3D add_lease(server, false, mac, ip);
+	if (!lease) {
+		SERVER_DEBUG("add_lease() failed");
+		return NULL;
+	}
+
+	SERVER_DEBUG("Allocated %s to " MAC, IP_STR(ip), MAC_STR(mac));
+
+	if (server->event_handler)
+		server->event_handler(server, L_DHCP_SERVER_EVENT_NEW_LEASE,
+					server->user_data, lease);
+
+	return lease;
+}
+
+LIB_EXPORT bool l_dhcp_server_release_lease(struct l_dhcp_server *server,
+						struct l_dhcp_lease *lease)
+{
+	/*
+	 * Don't emit event or put the lease in the expired list because
+	 * the lease is not expiring.
+	 */
+	if (!remove_lease(server, lease))
+		return false;
+
+	set_next_expire_timer(server, NULL);
+	return true;
+}
diff --git a/ell/dhcp.h b/ell/dhcp.h
index 2af75cc..4b5cd52 100644
--- a/ell/dhcp.h
+++ b/ell/dhcp.h
@@ -141,6 +141,11 @@ bool l_dhcp_server_set_ip_address(struct l_dhcp_server=
 *server,
 bool l_dhcp_server_set_netmask(struct l_dhcp_server *server, const char *m=
ask);
 bool l_dhcp_server_set_gateway(struct l_dhcp_server *server, const char *i=
p);
 bool l_dhcp_server_set_dns(struct l_dhcp_server *server, char **dns);
+
+struct l_dhcp_lease *l_dhcp_server_new_lease(struct l_dhcp_server *server,
+						const uint8_t *mac);
+bool l_dhcp_server_release_lease(struct l_dhcp_server *server,
+					struct l_dhcp_lease *lease);
 #ifdef __cplusplus
 }
 #endif
diff --git a/ell/ell.sym b/ell/ell.sym
index 4391051..e487f72 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -259,6 +259,8 @@ global:
 	l_dhcp_server_set_netmask;
 	l_dhcp_server_set_gateway;
 	l_dhcp_server_set_dns;
+	l_dhcp_server_new_lease;
+	l_dhcp_server_release_lease;
 	/* dhcp6 */
 	l_dhcp6_client_new;
 	l_dhcp6_client_destroy;
-- =

2.30.2

--===============7414228882269861192==--

