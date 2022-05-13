Content-Type: multipart/mixed; boundary="===============0096093948878143021=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 16/17] examples: Update netconfig method calls
Date: Fri, 13 May 2022 16:55:09 +0200
Message-ID: <20220513145510.1408510-16-andrew.zaborowski@intel.com>
In-Reply-To: 20220513145510.1408510-1-andrew.zaborowski@intel.com

--===============0096093948878143021==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 examples/netconfig-test.c | 49 ++++++++++++++++-----------------------
 1 file changed, 20 insertions(+), 29 deletions(-)

diff --git a/examples/netconfig-test.c b/examples/netconfig-test.c
index c9d02ab..77ad74c 100644
--- a/examples/netconfig-test.c
+++ b/examples/netconfig-test.c
@@ -40,7 +40,6 @@
 #include <ell/ell.h>
 =

 static bool apply;
-static struct l_netlink *rtnl;
 =

 static void do_debug(const char *str, void *user_data)
 {
@@ -61,16 +60,14 @@ static void signal_handler(uint32_t signo, void *user_d=
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

@@ -83,25 +80,26 @@ static void log_addresses(const char *af_str, const cha=
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
@@ -110,7 +108,7 @@ static void event_handler(struct l_netconfig *netconfig=
, uint8_t family,
 				enum l_netconfig_event event, void *user_data)
 {
 	const char *af_str =3D family =3D=3D AF_INET ? "v4" : "v6";
-	struct l_queue *added, *updated, *removed;
+	const struct l_queue_entry *added, *updated, *removed, *expired;
 =

 	switch (event) {
 	case L_NETCONFIG_EVENT_CONFIGURE:
@@ -128,18 +126,21 @@ static void event_handler(struct l_netconfig *netconf=
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
-		l_netconfig_apply_rtnl(netconfig, rtnl);
+		l_netconfig_apply_rtnl(netconfig);
 }
 =

 static const struct option main_options[] =3D {
@@ -181,14 +182,6 @@ int main(int argc, char *argv[])
 	if (!l_main_init())
 		return EXIT_FAILURE;
 =

-	if (apply) {
-		rtnl =3D l_netlink_new(NETLINK_ROUTE);
-		if (!rtnl) {
-			fprintf(stderr, "l_netlink_new(NETLINK_ROUTE) error\n");
-			return EXIT_FAILURE;
-		}
-	}
-
 	l_log_set_stderr();
 	l_debug_enable("*");
 =

@@ -203,7 +196,5 @@ int main(int argc, char *argv[])
 	l_netconfig_destroy(netconfig);
 	l_main_exit();
 =

-	l_netlink_destroy(rtnl);
-
 	return EXIT_SUCCESS;
 }
-- =

2.32.0

--===============0096093948878143021==--

