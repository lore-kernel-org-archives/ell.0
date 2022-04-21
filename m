Content-Type: multipart/mixed; boundary="===============8913646090403639293=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 11/12] examples: Update l_netconfig_get_{addresses,
 routes} calls
Date: Thu, 21 Apr 2022 17:45:24 +0200
Message-ID: <20220421154525.1416984-11-andrew.zaborowski@intel.com>
In-Reply-To: 20220421154525.1416984-1-andrew.zaborowski@intel.com

--===============8913646090403639293==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 examples/netconfig-test.c | 36 +++++++++++++++++++-----------------
 1 file changed, 19 insertions(+), 17 deletions(-)

diff --git a/examples/netconfig-test.c b/examples/netconfig-test.c
index c9d02ab..573bf86 100644
--- a/examples/netconfig-test.c
+++ b/examples/netconfig-test.c
@@ -61,16 +61,14 @@ static void signal_handler(uint32_t signo, void *user_d=
ata)
 }
 =

 static void log_addresses(const char *af_str, const char *action,
-				struct l_queue *list)
+				const struct l_queue_entry *entry)
 {
-	const struct l_queue_entry *entry;
-
-	if (l_queue_isempty(list))
+	if (!entry)
 		return;
 =

 	l_info("[netconfig%s] Addresses %s:", af_str, action);
 =

-	for (entry =3D l_queue_get_entries(list); entry; entry =3D entry->next) {
+	for (; entry; entry =3D entry->next) {
 		struct l_rtnl_address *addr =3D entry->data;
 		char ip_str[INET6_ADDRSTRLEN];
 =

@@ -83,25 +81,26 @@ static void log_addresses(const char *af_str, const cha=
r *action,
 }
 =

 static void log_routes(const char *af_str, const char *action,
-			struct l_queue *list)
+			const struct l_queue_entry *entry)
 {
-	const struct l_queue_entry *entry;
-
-	if (l_queue_isempty(list))
+	if (!entry)
 		return;
 =

 	l_info("[netconfig%s] Routes %s:", af_str, action);
 =

-	for (entry =3D l_queue_get_entries(list); entry; entry =3D entry->next) {
+	for (; entry; entry =3D entry->next) {
 		struct l_rtnl_route *rt =3D entry->data;
-		char subnet_str[INET6_ADDRSTRLEN];
+		char subnet_str[INET6_ADDRSTRLEN] =3D "unknown";
 		char gateway_str[INET6_ADDRSTRLEN];
 		uint8_t prefix_len;
+		bool onlink;
 =

 		l_rtnl_route_get_dst(rt, subnet_str, &prefix_len);
-		l_rtnl_route_get_gateway(rt, gateway_str);
-		l_info("[netconfig%s] \t%s/%i, gateway %s, orig lifetime %i s",
-			af_str, subnet_str, prefix_len, gateway_str,
+		onlink =3D !l_rtnl_route_get_gateway(rt, gateway_str);
+		l_info("[netconfig%s] \t%s/%i, %s%s, orig lifetime %i s",
+			af_str, subnet_str, prefix_len,
+			onlink ? "onlink" : "next-hop ",
+			onlink ? "" : gateway_str,
 			l_rtnl_route_get_lifetime(rt));
 	}
 }
@@ -110,7 +109,7 @@ static void event_handler(struct l_netconfig *netconfig=
, uint8_t family,
 				enum l_netconfig_event event, void *user_data)
 {
 	const char *af_str =3D family =3D=3D AF_INET ? "v4" : "v6";
-	struct l_queue *added, *updated, *removed;
+	const struct l_queue_entry *added, *updated, *removed, *expired;
 =

 	switch (event) {
 	case L_NETCONFIG_EVENT_CONFIGURE:
@@ -128,15 +127,18 @@ static void event_handler(struct l_netconfig *netconf=
ig, uint8_t family,
 		return;
 	}
 =

-	l_netconfig_get_addresses(netconfig, &added, &updated, &removed);
+	l_netconfig_get_addresses(netconfig, &added, &updated,
+					&removed, &expired);
 	log_addresses(af_str, "added", added);
 	log_addresses(af_str, "updated", updated);
 	log_addresses(af_str, "removed", removed);
+	log_addresses(af_str, "expired", expired);
 =

-	l_netconfig_get_routes(netconfig, &added, &updated, &removed);
+	l_netconfig_get_routes(netconfig, &added, &updated, &removed, &expired);
 	log_routes(af_str, "added", added);
 	log_routes(af_str, "updated", updated);
 	log_routes(af_str, "removed", removed);
+	log_routes(af_str, "expired", expired);
 =

 	if (apply)
 		l_netconfig_apply_rtnl(netconfig, rtnl);
-- =

2.32.0

--===============8913646090403639293==--

