Content-Type: multipart/mixed; boundary="===============0904249675756439944=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 08/15] examples: Update netconfig method calls
Date: Fri, 20 May 2022 17:43:31 +0200
Message-ID: <20220520154338.2056273-8-andrew.zaborowski@intel.com>
In-Reply-To: 20220520154338.2056273-1-andrew.zaborowski@intel.com

--===============0904249675756439944==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 examples/netconfig-test.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/examples/netconfig-test.c b/examples/netconfig-test.c
index 39b6fa4..45455dc 100644
--- a/examples/netconfig-test.c
+++ b/examples/netconfig-test.c
@@ -108,7 +108,7 @@ static void event_handler(struct l_netconfig *netconfig=
, uint8_t family,
 				enum l_netconfig_event event, void *user_data)
 {
 	const char *af_str =3D family =3D=3D AF_INET ? "v4" : "v6";
-	const struct l_queue_entry *added, *updated, *removed;
+	const struct l_queue_entry *added, *updated, *removed, *expired;
 =

 	switch (event) {
 	case L_NETCONFIG_EVENT_CONFIGURE:
@@ -126,15 +126,18 @@ static void event_handler(struct l_netconfig *netconf=
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
 		l_netconfig_apply_rtnl(netconfig);
-- =

2.32.0

--===============0904249675756439944==--

