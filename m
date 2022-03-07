Content-Type: multipart/mixed; boundary="===============6771655916773417114=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 05/12] dhcp6: Expose lease lifetime & start time getters
Date: Mon, 07 Mar 2022 15:55:36 +0100
Message-ID: <20220307145543.1558788-5-andrew.zaborowski@intel.com>
In-Reply-To: 20220307145543.1558788-1-andrew.zaborowski@intel.com

--===============6771655916773417114==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/dhcp6-lease.c   | 33 +++++++++++++++++++++++++++------
 ell/dhcp6-private.h |  6 ++++--
 ell/dhcp6.c         | 11 +++++------
 ell/dhcp6.h         |  3 +++
 ell/ell.sym         |  3 +++
 5 files changed, 42 insertions(+), 14 deletions(-)

diff --git a/ell/dhcp6-lease.c b/ell/dhcp6-lease.c
index c30c02b..827c71e 100644
--- a/ell/dhcp6-lease.c
+++ b/ell/dhcp6-lease.c
@@ -408,14 +408,35 @@ uint32_t _dhcp6_lease_get_t2(struct l_dhcp6_lease *le=
ase)
 	return ia->info.valid_lifetime /  10 * 8;
 }
 =

-uint32_t _dhcp6_lease_get_valid_lifetime(struct l_dhcp6_lease *lease)
+LIB_EXPORT uint32_t l_dhcp6_lease_get_valid_lifetime(
+						struct l_dhcp6_lease *lease)
 {
-	PICK_IA();
-	return ia->info.valid_lifetime;
+	if (unlikely(!lease))
+		return 0;
+
+	{
+		PICK_IA();
+		return ia->info.valid_lifetime;
+	}
 }
 =

-uint32_t _dhcp6_lease_get_preferred_lifetime(struct l_dhcp6_lease *lease)
+LIB_EXPORT uint32_t l_dhcp6_lease_get_preferred_lifetime(
+						struct l_dhcp6_lease *lease)
 {
-	PICK_IA();
-	return ia->info.preferred_lifetime;
+	if (unlikely(!lease))
+		return 0;
+
+	{
+		PICK_IA();
+		return ia->info.preferred_lifetime;
+	}
+}
+
+/* Get the reception timestamp, i.e. when lifetimes are counted from */
+LIB_EXPORT uint64_t l_dhcp6_lease_get_start_time(struct l_dhcp6_lease *lea=
se)
+{
+	if (unlikely(!lease))
+		return 0;
+
+	return lease->start_time;
 }
diff --git a/ell/dhcp6-private.h b/ell/dhcp6-private.h
index e27cb7e..52f4002 100644
--- a/ell/dhcp6-private.h
+++ b/ell/dhcp6-private.h
@@ -130,6 +130,7 @@ struct l_dhcp6_lease {
 	uint8_t *server_id;
 	size_t server_id_len;
 	uint8_t preference;
+	uint64_t start_time;
 =

 	struct dhcp6_ia ia_na;
 	struct dhcp6_ia ia_pd;
@@ -149,5 +150,6 @@ struct l_dhcp6_lease *_dhcp6_lease_parse_options(
 					const uint8_t expected_iaid[static 4]);
 uint32_t _dhcp6_lease_get_t1(struct l_dhcp6_lease *lease);
 uint32_t _dhcp6_lease_get_t2(struct l_dhcp6_lease *lease);
-uint32_t _dhcp6_lease_get_valid_lifetime(struct l_dhcp6_lease *lease);
-uint32_t _dhcp6_lease_get_preferred_lifetime(struct l_dhcp6_lease *lease);
+uint32_t dhcp6_lease_get_valid_lifetime(struct l_dhcp6_lease *lease);
+uint32_t dhcp6_lease_get_preferred_lifetime(struct l_dhcp6_lease *lease);
+uint32_t dhcp6_lease_get_start_time(struct l_dhcp6_lease *lease);
diff --git a/ell/dhcp6.c b/ell/dhcp6.c
index 34635fe..424fad0 100644
--- a/ell/dhcp6.c
+++ b/ell/dhcp6.c
@@ -394,7 +394,6 @@ struct l_dhcp6_client {
 	struct l_timeout *timeout_send;
 	struct l_dhcp6_lease *lease;
 	struct l_timeout *timeout_lease;
-	uint64_t lease_start_t;
 =

 	struct l_icmp6_client *icmp6;
 =

@@ -901,8 +900,8 @@ static void dhcp6_client_t2_expired(struct l_timeout *t=
imeout, void *user_data)
 {
 	struct l_dhcp6_client *client =3D user_data;
 	uint32_t elapsed =3D
-		l_time_to_msecs(l_time_now() - client->lease_start_t);
-	uint32_t valid =3D _dhcp6_lease_get_valid_lifetime(client->lease) *
+		l_time_to_msecs(l_time_now() - client->lease->start_time);
+	uint32_t valid =3D l_dhcp6_lease_get_valid_lifetime(client->lease) *
 				L_MSEC_PER_SEC;
 =

 	CLIENT_DEBUG("");
@@ -969,7 +968,7 @@ static void dhcp6_client_setup_lease(struct l_dhcp6_cli=
ent *client,
 	uint32_t t2 =3D _dhcp6_lease_get_t2(client->lease);
 	enum l_dhcp6_client_event event;
 =

-	client->lease_start_t =3D timestamp;
+	client->lease->start_time =3D timestamp;
 =

 	/* TODO: Emit IP_CHANGED if any addresses were removed / added */
 	if (client->state =3D=3D DHCP6_STATE_REQUESTING ||
@@ -1003,8 +1002,8 @@ static void dhcp6_client_setup_lease(struct l_dhcp6_c=
lient *client,
 			l_dhcp6_lease_get_address(client->lease);
 		uint8_t prefix_len =3D
 			l_dhcp6_lease_get_prefix_length(client->lease);
-		uint32_t p =3D _dhcp6_lease_get_preferred_lifetime(client->lease);
-		uint32_t v =3D _dhcp6_lease_get_valid_lifetime(client->lease);
+		uint32_t p =3D l_dhcp6_lease_get_preferred_lifetime(client->lease);
+		uint32_t v =3D l_dhcp6_lease_get_valid_lifetime(client->lease);
 =

 		a =3D l_rtnl_address_new(ip, prefix_len);
 		l_rtnl_address_set_noprefixroute(a, true);
diff --git a/ell/dhcp6.h b/ell/dhcp6.h
index 8503a5e..9819fad 100644
--- a/ell/dhcp6.h
+++ b/ell/dhcp6.h
@@ -94,6 +94,9 @@ char *l_dhcp6_lease_get_address(const struct l_dhcp6_leas=
e *lease);
 char **l_dhcp6_lease_get_dns(const struct l_dhcp6_lease *lease);
 char **l_dhcp6_lease_get_domains(const struct l_dhcp6_lease *lease);
 uint8_t l_dhcp6_lease_get_prefix_length(const struct l_dhcp6_lease *lease);
+uint32_t l_dhcp6_lease_get_valid_lifetime(struct l_dhcp6_lease *lease);
+uint32_t l_dhcp6_lease_get_preferred_lifetime(struct l_dhcp6_lease *lease);
+uint64_t l_dhcp6_lease_get_start_time(struct l_dhcp6_lease *lease);
 =

 #ifdef __cplusplus
 }
diff --git a/ell/ell.sym b/ell/ell.sym
index 2fb5c55..db29d9a 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -296,6 +296,9 @@ global:
 	l_dhcp6_lease_get_dns;
 	l_dhcp6_lease_get_domains;
 	l_dhcp6_lease_get_prefix_length;
+	l_dhcp6_lease_get_valid_lifetime;
+	l_dhcp6_lease_get_preferred_lifetime;
+	l_dhcp6_lease_get_start_time;
 	/* dir */
 	l_dir_watch_new;
 	l_dir_watch_destroy;
-- =

2.32.0

--===============6771655916773417114==--

