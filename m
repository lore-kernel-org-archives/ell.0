Content-Type: multipart/mixed; boundary="===============4838242342085278848=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 03/15] examples: Update netconfig method calls
Date: Fri, 20 May 2022 17:43:26 +0200
Message-ID: <20220520154338.2056273-3-andrew.zaborowski@intel.com>
In-Reply-To: 20220520154338.2056273-1-andrew.zaborowski@intel.com

--===============4838242342085278848==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 examples/netconfig-test.c | 29 ++++++++++++++---------------
 1 file changed, 14 insertions(+), 15 deletions(-)

diff --git a/examples/netconfig-test.c b/examples/netconfig-test.c
index d75e4ad..aba63f9 100644
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
+	const struct l_queue_entry *added, *updated, *removed;
 =

 	switch (event) {
 	case L_NETCONFIG_EVENT_CONFIGURE:
-- =

2.32.0

--===============4838242342085278848==--

