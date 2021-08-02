Content-Type: multipart/mixed; boundary="===============0206842267240294402=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 09/15] dhcp-server: Refactor lease lookup
Date: Mon, 02 Aug 2021 16:04:18 +0200
Message-ID: <20210802140424.170150-9-andrew.zaborowski@intel.com>
In-Reply-To: <20210802140424.170150-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0206842267240294402==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

A few places in the code assume that there can be only one lease per
client MAC address (or recently client ID).  The spec doesn't actually
say this and says that a lease is identified by the client-id/mac plus
the IP:

"The combination of 'client identifier' or 'chaddr' and assigned network
address constitute a unique identifier for the client's lease and are
used by both the client and server to identify a lease referred to in
any DHCP messages."

Start identifying leases this way.  Don't actually add any way for a
client to obtain a second lease -- we still ignore the 'requested IP'
option in DHCPDISCOVER if the client already has a lease.

This currently solves an unrelated problem: there was no upper bound
on server->expired_list size.  When handling DHCPDISCOVER we'd free the
oldest lease in server->expired_list only under some conditions,
otherwise we might have been allocating an IP that was already in the
expired list and once that new lease expired there would be duplicate IP
addresses in server->expired_list and it could keep growing.  Now when
we try to re-use a struct l_dhcp_lease in get_lease() we look up by IP
instead of by the MAC and we look at both server->lease_list and
server->expired_list.  This guarantees IPs are unique across the two
lists and their sizes are bounded by the pool size.
---
 ell/dhcp-server.c | 98 +++++++++++++++++++++++++++++++++++------------
 1 file changed, 74 insertions(+), 24 deletions(-)

diff --git a/ell/dhcp-server.c b/ell/dhcp-server.c
index eb8fcd7..0183c20 100644
--- a/ell/dhcp-server.c
+++ b/ell/dhcp-server.c
@@ -131,15 +131,49 @@ static bool match_lease_mac(const void *data, const v=
oid *user_data)
 	return !memcmp(lease->mac, mac, 6);
 }
 =

-static struct l_dhcp_lease *find_lease_by_id(struct l_dhcp_server *server,
+static bool match_lease_ip(const void *data, const void *user_data)
+{
+	const struct l_dhcp_lease *lease =3D data;
+
+	return lease->address =3D=3D L_PTR_TO_UINT(user_data);
+}
+
+static struct l_dhcp_lease *find_lease_by_ip(struct l_queue *lease_list,
+						uint32_t nip)
+{
+	return l_queue_find(lease_list, match_lease_ip, L_UINT_TO_PTR(nip));
+}
+
+static struct l_dhcp_lease *find_lease_by_id(struct l_queue *lease_list,
 						const uint8_t *client_id,
 						const uint8_t *mac)
 {
 	if (client_id)
-		return l_queue_find(server->lease_list, match_lease_client_id,
+		return l_queue_find(lease_list, match_lease_client_id,
 					client_id);
 =

-	return l_queue_find(server->lease_list, match_lease_mac, mac);
+	return l_queue_find(lease_list, match_lease_mac, mac);
+}
+
+static struct l_dhcp_lease *find_lease_by_id_and_ip(struct l_queue *lease_=
list,
+						const uint8_t *client_id,
+						const uint8_t *mac,
+						uint32_t ip)
+{
+	struct l_dhcp_lease *lease =3D find_lease_by_ip(lease_list, ip);
+
+	if (!lease)
+		return NULL;
+
+	if (client_id) {
+		if (!match_lease_client_id(lease, client_id))
+			return NULL;
+	} else {
+		if (!match_lease_mac(lease, mac))
+			return NULL;
+	}
+
+	return lease;
 }
 =

 /* Clear the old lease and create the new one */
@@ -164,13 +198,17 @@ static int get_lease(struct l_dhcp_server *server, ui=
nt32_t yiaddr,
 	if (l_memeqzero(mac, ETH_ALEN))
 		return -ENXIO;
 =

-	lease =3D find_lease_by_id(server, client_id, mac);
-
+	lease =3D find_lease_by_ip(server->lease_list, yiaddr);
 	if (lease) {
 		l_queue_remove(server->lease_list, lease);
-
 		*lease_out =3D lease;
+		return 0;
+	}
 =

+	lease =3D find_lease_by_ip(server->expired_list, yiaddr);
+	if (lease && lease->address =3D=3D yiaddr) {
+		l_queue_remove(server->expired_list, lease);
+		*lease_out =3D lease;
 		return 0;
 	}
 =

@@ -332,19 +370,6 @@ static void lease_release(struct l_dhcp_server *server,
 	set_next_expire_timer(server, lease);
 }
 =

-static bool match_lease_ip(const void *data, const void *user_data)
-{
-	const struct l_dhcp_lease *lease =3D data;
-
-	return lease->address =3D=3D L_PTR_TO_UINT(user_data);
-}
-
-static struct l_dhcp_lease *find_lease_by_ip(struct l_queue *lease_list,
-						uint32_t nip)
-{
-	return l_queue_find(lease_list, match_lease_ip, L_UINT_TO_PTR(nip));
-}
-
 static bool check_requested_ip(struct l_dhcp_server *server,
 				uint32_t requested_nip)
 {
@@ -726,7 +751,15 @@ static void listener_event(const void *data, size_t le=
n, void *user_data)
 	if (type =3D=3D 0)
 		return;
 =

-	lease =3D find_lease_by_id(server, client_id_opt, message->chaddr);
+	if (requested_ip_opt)
+		lease =3D find_lease_by_id_and_ip(server->lease_list,
+						client_id_opt, message->chaddr,
+						requested_ip_opt);
+
+	if (!requested_ip_opt || !lease)
+		lease =3D find_lease_by_id(server->lease_list, client_id_opt,
+						message->chaddr);
+
 	if (!lease)
 		SERVER_DEBUG("No lease found for "MAC,
 					MAC_STR(message->chaddr));
@@ -1253,7 +1286,7 @@ LIB_EXPORT struct l_dhcp_lease *l_dhcp_server_discove=
r(
 	SERVER_DEBUG("Requested IP " NIPQUAD_FMT " for " MAC,
 			NIPQUAD(requested_ip_opt), MAC_STR(mac));
 =

-	if ((lease =3D find_lease_by_id(server, client_id, mac)))
+	if ((lease =3D find_lease_by_id(server->lease_list, client_id, mac)))
 		requested_ip_opt =3D lease->address;
 	else if (!check_requested_ip(server, requested_ip_opt)) {
 		requested_ip_opt =3D find_free_or_expired_ip(server, mac);
@@ -1337,11 +1370,28 @@ LIB_EXPORT bool l_dhcp_server_lease_remove(struct l=
_dhcp_server *server,
 	return true;
 }
 =

+struct dhcp_expire_by_mac_data {
+	struct l_dhcp_server *server;
+	const uint8_t *mac;
+};
+
+static bool dhcp_expire_by_mac(void *data, void *user_data)
+{
+	struct l_dhcp_lease *lease =3D data;
+	struct dhcp_expire_by_mac_data *expire_data =3D user_data;
+
+	if (!match_lease_mac(lease, expire_data->mac))
+		return false;
+
+	lease_release(expire_data->server, lease);
+	return true;
+}
+
 LIB_EXPORT void l_dhcp_server_expire_by_mac(struct l_dhcp_server *server,
 						const uint8_t *mac)
 {
-	struct l_dhcp_lease *lease =3D find_lease_by_id(server, NULL, mac);
+	struct dhcp_expire_by_mac_data expire_data =3D { server, mac };
 =

-	if (likely(lease))
-		lease_release(server, lease);
+	l_queue_foreach_remove(server->lease_list, dhcp_expire_by_mac,
+				&expire_data);
 }
-- =

2.30.2

--===============0206842267240294402==--

