Content-Type: multipart/mixed; boundary="===============6903566083940969950=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 3/4] dhcp: Add l_dhcp_client_set_lease
Date: Thu, 12 Aug 2021 22:51:11 +0200
Message-ID: <20210812205112.86584-3-andrew.zaborowski@intel.com>
In-Reply-To: <20210812205112.86584-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6903566083940969950==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This method can be used when the DHCP server sends us a new lease
through an alternative protocol/transport such as when a lower layer's
(e.g. 802.11) initial handshake frames are reused to send the server's
IP assignment for faster connection setup.  If the lease has a defined
lifetime the user will want to use l_dhcp_client to track the expiry and
renewal of the leases.  The user will build an l_dhcp_lease object
using the data that was included in the handshake frames and call
l_dhcp_client_set_lease() and then the l_dhcp_client_start() as normal
once the ethernet link is setup.  The L_DHCP_CLIENT_EVENT_LEASE_OBTAINED
event will be sent inside the later l_dhcp_client_start() call.

With more work this method could be used for restoring the DHCP client
state from an older instance.
---
 ell/dhcp-lease.c   |  26 ++++
 ell/dhcp-private.h |   1 +
 ell/dhcp.c         | 311 ++++++++++++++++++++++++++++-----------------
 ell/dhcp.h         |   2 +
 ell/ell.sym        |   1 +
 5 files changed, 226 insertions(+), 115 deletions(-)

diff --git a/ell/dhcp-lease.c b/ell/dhcp-lease.c
index 40dba83..81d0943 100644
--- a/ell/dhcp-lease.c
+++ b/ell/dhcp-lease.c
@@ -54,6 +54,32 @@ LIB_EXPORT void l_dhcp_lease_free(struct l_dhcp_lease *l=
ease)
 	l_free(lease);
 }
 =

+struct l_dhcp_lease *_dhcp_lease_clone(const struct l_dhcp_lease *orig)
+{
+	struct l_dhcp_lease *lease;
+
+	if (unlikely(!orig))
+		return NULL;
+
+	lease =3D l_memdup(orig, sizeof(*lease));
+
+	if (lease->dns) {
+		unsigned int n;
+
+		for (n =3D 0; lease->dns[n]; n++);
+		lease->dns =3D l_memdup(lease->dns, (n + 1) * 4);
+	}
+
+	if (lease->domain_name)
+		lease->domain_name =3D l_strdup(lease->domain_name);
+
+	if (lease->client_id)
+		lease->client_id =3D l_memdup(lease->client_id,
+						lease->client_id[0] + 1);
+
+	return lease;
+}
+
 struct l_dhcp_lease *_dhcp_lease_parse_options(struct dhcp_message_iter *i=
ter)
 {
 	struct l_dhcp_lease *lease =3D l_dhcp_lease_new();
diff --git a/ell/dhcp-private.h b/ell/dhcp-private.h
index 5864dc3..5b27e7e 100644
--- a/ell/dhcp-private.h
+++ b/ell/dhcp-private.h
@@ -175,6 +175,7 @@ struct l_dhcp_lease {
 	bool offering : 1;
 };
 =

+struct l_dhcp_lease *_dhcp_lease_clone(const struct l_dhcp_lease *orig);
 struct l_dhcp_lease *_dhcp_lease_parse_options(struct dhcp_message_iter *i=
ter);
 =

 struct dhcp_message_builder {
diff --git a/ell/dhcp.c b/ell/dhcp.c
index e06ab05..49398d5 100644
--- a/ell/dhcp.c
+++ b/ell/dhcp.c
@@ -422,7 +422,8 @@ static int dhcp_client_send_request(struct l_dhcp_clien=
t *client)
 		 *
 		 * NOTE: 'SELECTING' is meant to be 'REQUESTING' in the RFC
 		 */
-		if (!_dhcp_message_builder_append(&builder,
+		if (client->lease->server_address &&
+				!_dhcp_message_builder_append(&builder,
 					L_DHCP_OPTION_SERVER_IDENTIFIER,
 					4, &client->lease->server_address)) {
 			CLIENT_DEBUG("Failed to append server ID");
@@ -468,7 +469,8 @@ static int dhcp_client_send_request(struct l_dhcp_clien=
t *client)
 	 * 'server identifier' option for any unicast requests to the DHCP
 	 * server.
 	 */
-	if (client->state =3D=3D DHCP_STATE_RENEWING)
+	if (client->state =3D=3D DHCP_STATE_RENEWING &&
+			client->lease->server_address)
 		return dhcp_client_send_unicast(client, request, len);
 =

 	return client->transport->l2_send(client->transport,
@@ -504,7 +506,8 @@ static void dhcp_client_send_release(struct l_dhcp_clie=
nt *client)
 =

 	request->ciaddr =3D client->lease->address;
 =

-	if (!_dhcp_message_builder_append(&builder,
+	if (client->lease->server_address &&
+			!_dhcp_message_builder_append(&builder,
 					L_DHCP_OPTION_SERVER_IDENTIFIER,
 					4, &client->lease->server_address)) {
 		CLIENT_DEBUG("Failed to append server ID");
@@ -513,7 +516,15 @@ static void dhcp_client_send_release(struct l_dhcp_cli=
ent *client)
 =

 	_dhcp_message_builder_finalize(&builder, &len);
 =

-	dhcp_client_send_unicast(client, request, len);
+	if (client->lease->server_address) {
+		dhcp_client_send_unicast(client, request, len);
+		return;
+	}
+
+	client->transport->l2_send(client->transport,
+					INADDR_ANY, DHCP_PORT_CLIENT,
+					INADDR_BROADCAST, DHCP_PORT_SERVER,
+					NULL, request, len);
 }
 =

 static void dhcp_client_timeout_resend(struct l_timeout *timeout,
@@ -672,6 +683,40 @@ static void dhcp_client_address_add_cb(int error, uint=
16_t type,
 	}
 }
 =

+static void dhcp_client_address_add(struct l_dhcp_client *client)
+{
+	struct l_rtnl_address *a;
+	L_AUTO_FREE_VAR(char *, ip) =3D l_dhcp_lease_get_address(client->lease);
+	uint8_t prefix_len;
+	uint32_t l =3D l_dhcp_lease_get_lifetime(client->lease);
+	L_AUTO_FREE_VAR(char *, netmask) =3D
+			l_dhcp_lease_get_netmask(client->lease);
+	L_AUTO_FREE_VAR(char *, broadcast) =3D
+			l_dhcp_lease_get_broadcast(client->lease);
+	struct in_addr in_addr;
+
+	if (inet_pton(AF_INET, netmask, &in_addr) > 0)
+		prefix_len =3D __builtin_popcountl(in_addr.s_addr);
+	else
+		prefix_len =3D 24;
+
+	a =3D l_rtnl_address_new(ip, prefix_len);
+	l_rtnl_address_set_noprefixroute(a, true);
+	l_rtnl_address_set_lifetimes(a, l, l);
+	l_rtnl_address_set_broadcast(a, broadcast);
+
+	client->rtnl_add_cmdid =3D
+		l_rtnl_ifaddr_add(client->rtnl, client->ifindex, a,
+					dhcp_client_address_add_cb,
+					client, NULL);
+	if (client->rtnl_add_cmdid)
+		client->rtnl_configured_address =3D a;
+	else {
+		CLIENT_DEBUG("Configuring address via RTNL failed");
+		l_rtnl_address_free(a);
+	}
+}
+
 static int dhcp_client_receive_ack(struct l_dhcp_client *client,
 					const struct dhcp_message *ack,
 					size_t len)
@@ -715,39 +760,8 @@ static int dhcp_client_receive_ack(struct l_dhcp_clien=
t *client,
 			client->state =3D=3D DHCP_STATE_REBOOTING)
 		r =3D L_DHCP_CLIENT_EVENT_LEASE_OBTAINED;
 =

-	if (client->rtnl) {
-		struct l_rtnl_address *a;
-		L_AUTO_FREE_VAR(char *, ip) =3D
-			l_dhcp_lease_get_address(client->lease);
-		uint8_t prefix_len;
-		uint32_t l =3D l_dhcp_lease_get_lifetime(client->lease);
-		L_AUTO_FREE_VAR(char *, netmask) =3D
-				l_dhcp_lease_get_netmask(client->lease);
-		L_AUTO_FREE_VAR(char *, broadcast) =3D
-				l_dhcp_lease_get_broadcast(client->lease);
-		struct in_addr in_addr;
-
-		if (inet_pton(AF_INET, netmask, &in_addr) > 0)
-			prefix_len =3D __builtin_popcountl(in_addr.s_addr);
-		else
-			prefix_len =3D 24;
-
-		a =3D l_rtnl_address_new(ip, prefix_len);
-		l_rtnl_address_set_noprefixroute(a, true);
-		l_rtnl_address_set_lifetimes(a, l, l);
-		l_rtnl_address_set_broadcast(a, broadcast);
-
-		client->rtnl_add_cmdid =3D
-			l_rtnl_ifaddr_add(client->rtnl, client->ifindex, a,
-						dhcp_client_address_add_cb,
-						client, NULL);
-		if (client->rtnl_add_cmdid)
-			client->rtnl_configured_address =3D a;
-		else {
-			CLIENT_DEBUG("Configuring address via RTNL failed");
-			l_rtnl_address_free(a);
-		}
-	}
+	if (client->rtnl)
+		dhcp_client_address_add(client);
 =

 	return r;
 }
@@ -775,18 +789,93 @@ static int dhcp_client_receive_offer(struct l_dhcp_cl=
ient *client,
 	return 0;
 }
 =

+static void dhcp_client_bound(struct l_dhcp_client *client)
+{
+	char buf[INET_ADDRSTRLEN];
+	struct in_addr ia;
+
+	CLIENT_ENTER_STATE(DHCP_STATE_BOUND);
+	l_timeout_remove(client->timeout_resend);
+	client->timeout_resend =3D NULL;
+
+	if (client->transport->bind) {
+		int e =3D client->transport->bind(client->transport,
+						client->lease->address);
+
+		if (e < 0) {
+			CLIENT_DEBUG("Failed to bind dhcp socket. "
+				"Error %d: %s", e, strerror(-e));
+		}
+	}
+
+	client->lease->bound_time =3D l_time_now();
+
+	/*
+	 * Start T1, once it expires we will start the T2 timer.  If
+	 * we renew the lease, we will end up back here.
+	 *
+	 * RFC2131, Section 4.4.5 states:
+	 * "Times T1 and T2 SHOULD be chosen with some random "fuzz"
+	 * around a fixed value, to avoid synchronization of client
+	 * reacquisition."
+	 */
+	l_timeout_remove(client->timeout_lease);
+	client->timeout_lease =3D NULL;
+
+	/* Infinite lease, no need to start t1 */
+	if (client->lease->lifetime !=3D 0xffffffffu) {
+		uint32_t next_timeout =3D dhcp_fuzz_secs(client->lease->t1);
+
+		CLIENT_DEBUG("T1 expiring in %u ms", next_timeout);
+		client->timeout_lease =3D l_timeout_create_ms(next_timeout,
+							dhcp_client_t1_expired,
+							client, NULL);
+	}
+
+	/* ACD is already running, no need to re-announce */
+	if (client->acd)
+		return;
+
+	client->acd =3D l_acd_new(client->ifindex);
+
+	if (client->debug_handler)
+		l_acd_set_debug(client->acd, client->debug_handler,
+				client->debug_data,
+				client->debug_destroy);
+
+	/*
+	 * TODO: There is no mechanism yet to deal with IPs leased by
+	 * the DHCP server which conflict with other devices. For now
+	 * the ACD object is being initialized to defend infinitely
+	 * which is effectively no different than the non-ACD behavior
+	 * (ignore conflicts and continue using address). The only
+	 * change is that announcements will be sent if conflicts are
+	 * found.
+	 */
+	l_acd_set_defend_policy(client->acd, L_ACD_DEFEND_POLICY_INFINITE);
+	l_acd_set_skip_probes(client->acd, true);
+
+	ia.s_addr =3D client->lease->address;
+	inet_ntop(AF_INET, &ia, buf, INET_ADDRSTRLEN);
+
+	/* For unit testing we don't want this to be a fatal error */
+	if (!l_acd_start(client->acd, buf)) {
+		CLIENT_DEBUG("Failed to start ACD on %s, continuing", buf);
+		l_acd_destroy(client->acd);
+		client->acd =3D NULL;
+	}
+}
+
 static void dhcp_client_rx_message(const void *data, size_t len, void *use=
rdata,
 					const uint8_t *saddr)
 {
 	struct l_dhcp_client *client =3D userdata;
 	const struct dhcp_message *message =3D data;
 	struct dhcp_message_iter iter;
-	char buf[INET_ADDRSTRLEN];
 	uint8_t msg_type =3D 0;
 	uint8_t t, l;
 	const void *v;
-	int r, e;
-	struct in_addr ia;
+	int r;
 =

 	CLIENT_DEBUG("");
 =

@@ -866,82 +955,8 @@ static void dhcp_client_rx_message(const void *data, s=
ize_t len, void *userdata,
 		if (r < 0)
 			return;
 =

-		CLIENT_ENTER_STATE(DHCP_STATE_BOUND);
-		l_timeout_remove(client->timeout_resend);
-		client->timeout_resend =3D NULL;
-
-		if (client->transport->bind) {
-			e =3D client->transport->bind(client->transport,
-						client->lease->address);
-			if (e < 0) {
-				CLIENT_DEBUG("Failed to bind dhcp socket. "
-					"Error %d: %s", e, strerror(-e));
-			}
-		}
-
+		dhcp_client_bound(client);
 		dhcp_client_event_notify(client, r);
-
-		client->lease->bound_time =3D l_time_now();
-
-		/*
-		 * Start T1, once it expires we will start the T2 timer.  If
-		 * we renew the lease, we will end up back here.
-		 *
-		 * RFC2131, Section 4.4.5 states:
-		 * "Times T1 and T2 SHOULD be chosen with some random "fuzz"
-		 * around a fixed value, to avoid synchronization of client
-		 * reacquisition."
-		 */
-		l_timeout_remove(client->timeout_lease);
-		client->timeout_lease =3D NULL;
-
-		/* Infinite lease, no need to start t1 */
-		if (client->lease->lifetime !=3D 0xffffffffu) {
-			uint32_t next_timeout =3D
-					dhcp_fuzz_secs(client->lease->t1);
-
-			CLIENT_DEBUG("T1 expiring in %u ms", next_timeout);
-			client->timeout_lease =3D
-				l_timeout_create_ms(next_timeout,
-							dhcp_client_t1_expired,
-							client, NULL);
-		}
-
-		/* ACD is already running, no need to re-announce */
-		if (client->acd)
-			break;
-
-		client->acd =3D l_acd_new(client->ifindex);
-
-		if (client->debug_handler)
-			l_acd_set_debug(client->acd, client->debug_handler,
-					client->debug_data,
-					client->debug_destroy);
-
-		/*
-		 * TODO: There is no mechanism yet to deal with IPs leased by
-		 * the DHCP server which conflict with other devices. For now
-		 * the ACD object is being initialized to defend infinitely
-		 * which is effectively no different than the non-ACD behavior
-		 * (ignore conflicts and continue using address). The only
-		 * change is that announcements will be sent if conflicts are
-		 * found.
-		 */
-		l_acd_set_defend_policy(client->acd,
-						L_ACD_DEFEND_POLICY_INFINITE);
-		l_acd_set_skip_probes(client->acd, true);
-
-		ia.s_addr =3D client->lease->address;
-		inet_ntop(AF_INET, &ia, buf, INET_ADDRSTRLEN);
-
-		/* For unit testing we don't want this to be a fatal error */
-		if (!l_acd_start(client->acd, buf)) {
-			CLIENT_DEBUG("Failed to start ACD on %s, continuing",
-						buf);
-			l_acd_destroy(client->acd);
-			client->acd =3D NULL;
-		}
-
 		break;
 	case DHCP_STATE_INIT_REBOOT:
 	case DHCP_STATE_REBOOTING:
@@ -1114,6 +1129,62 @@ LIB_EXPORT const struct l_dhcp_lease *l_dhcp_client_=
get_lease(
 	return client->lease;
 }
 =

+/*
+ * This is mainly to be used when the DHCP lease has been assigned by the
+ * server and communicated to the client through an alternative protocol,
+ * or to restore a saved state.
+ */
+LIB_EXPORT void l_dhcp_client_set_lease(struct l_dhcp_client *client,
+					const struct l_dhcp_lease *lease)
+{
+	int r =3D L_DHCP_CLIENT_EVENT_LEASE_OBTAINED;
+
+	if (unlikely(!client || !lease))
+		return;
+
+	l_dhcp_lease_free(client->lease);
+	client->lease =3D _dhcp_lease_clone(lease);
+
+	if (!client->lease->broadcast)
+		client->lease->broadcast =3D client->lease->address |
+			~client->lease->subnet_mask;
+
+	if (!client->lease->lifetime)
+		client->lease->lifetime =3D 0xffffffffu;
+
+	if (client->lease->lifetime !=3D 0xffffffffu) {
+		if (!client->lease->t1)
+			client->lease->t1 =3D client->lease->lifetime / 2;
+
+		if (!client->lease->t2)
+			client->lease->t2 =3D client->lease->lifetime / 8 * 7;
+	}
+
+	/*
+	 * If l_dhcp_client_start() hasn't happened yet, everything else
+	 * will be done there.
+	 */
+	if (client->state =3D=3D DHCP_STATE_INIT)
+		return;
+
+	if (client->rtnl_configured_address) {
+		l_rtnl_ifaddr_delete(client->rtnl, client->ifindex,
+					client->rtnl_configured_address,
+					NULL, NULL, NULL);
+		l_rtnl_address_free(client->rtnl_configured_address);
+		client->rtnl_configured_address =3D NULL;
+
+		r =3D L_DHCP_CLIENT_EVENT_IP_CHANGED;
+	}
+
+	if (client->rtnl)
+		dhcp_client_address_add(client);
+
+	dhcp_client_bound(client);
+	dhcp_client_event_notify(client, r);
+	return;
+}
+
 LIB_EXPORT bool l_dhcp_client_start(struct l_dhcp_client *client)
 {
 	int err;
@@ -1164,6 +1235,16 @@ LIB_EXPORT bool l_dhcp_client_start(struct l_dhcp_cl=
ient *client)
 =

 	client->start_t =3D l_time_now();
 =

+	if (client->lease) {
+		if (client->rtnl)
+			dhcp_client_address_add(client);
+
+		dhcp_client_bound(client);
+		dhcp_client_event_notify(client,
+					L_DHCP_CLIENT_EVENT_LEASE_OBTAINED);
+		return true;
+	}
+
 	err =3D dhcp_client_send_discover(client);
 	if (err < 0)
 		return false;
diff --git a/ell/dhcp.h b/ell/dhcp.h
index 4406cd2..36a693c 100644
--- a/ell/dhcp.h
+++ b/ell/dhcp.h
@@ -91,6 +91,8 @@ bool l_dhcp_client_set_rtnl(struct l_dhcp_client *client,
 =

 const struct l_dhcp_lease *l_dhcp_client_get_lease(
 					const struct l_dhcp_client *client);
+void l_dhcp_client_set_lease(struct l_dhcp_client *client,
+					const struct l_dhcp_lease *lease);
 =

 bool l_dhcp_client_start(struct l_dhcp_client *client);
 bool l_dhcp_client_stop(struct l_dhcp_client *client);
diff --git a/ell/ell.sym b/ell/ell.sym
index f96a52d..860f4fc 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -250,6 +250,7 @@ global:
 	l_dhcp_client_set_rtnl;
 	l_dhcp_client_set_hostname;
 	l_dhcp_client_get_lease;
+	l_dhcp_client_set_lease;
 	l_dhcp_client_start;
 	l_dhcp_client_stop;
 	l_dhcp_client_set_event_handler;
-- =

2.30.2

--===============6903566083940969950==--

