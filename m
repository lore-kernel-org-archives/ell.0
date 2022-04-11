Content-Type: multipart/mixed; boundary="===============6166744591686483082=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 11/11] netconfig: Add l_netconfig_get_{dhcp6,icmp6}_client
Date: Mon, 11 Apr 2022 16:20:56 +0200
Message-ID: <20220411142056.817784-11-andrew.zaborowski@intel.com>
In-Reply-To: 20220411142056.817784-1-andrew.zaborowski@intel.com

--===============6166744591686483082==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/ell.sym     |  2 ++
 ell/netconfig.c | 18 ++++++++++++++++++
 ell/netconfig.h |  4 ++++
 3 files changed, 24 insertions(+)

diff --git a/ell/ell.sym b/ell/ell.sym
index 9b3a6e1..f35bf82 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -749,6 +749,8 @@ global:
 	l_netconfig_start;
 	l_netconfig_stop;
 	l_netconfig_get_dhcp_client;
+	l_netconfig_get_dhcp6_client;
+	l_netconfig_get_icmp6_client;
 	l_netconfig_set_event_handler;
 	l_netconfig_apply_rtnl;
 	l_netconfig_get_addresses;
diff --git a/ell/netconfig.c b/ell/netconfig.c
index 15eb4ed..72495ec 100644
--- a/ell/netconfig.c
+++ b/ell/netconfig.c
@@ -1062,6 +1062,24 @@ LIB_EXPORT struct l_dhcp_client *l_netconfig_get_dhc=
p_client(
 	return netconfig->dhcp_client;
 }
 =

+LIB_EXPORT struct l_dhcp6_client *l_netconfig_get_dhcp6_client(
+						struct l_netconfig *netconfig)
+{
+	if (unlikely(!netconfig))
+		return NULL;
+
+	return netconfig->dhcp6_client;
+}
+
+LIB_EXPORT struct l_icmp6_client *l_netconfig_get_icmp6_client(
+						struct l_netconfig *netconfig)
+{
+	if (unlikely(!netconfig))
+		return NULL;
+
+	return netconfig->icmp6_client;
+}
+
 LIB_EXPORT void l_netconfig_set_event_handler(struct l_netconfig *netconfi=
g,
 					l_netconfig_event_cb_t handler,
 					void *user_data,
diff --git a/ell/netconfig.h b/ell/netconfig.h
index aab9d3f..dc56bcb 100644
--- a/ell/netconfig.h
+++ b/ell/netconfig.h
@@ -75,6 +75,10 @@ void l_netconfig_stop(struct l_netconfig *netconfig);
 =

 struct l_dhcp_client *l_netconfig_get_dhcp_client(
 						struct l_netconfig *netconfig);
+struct l_dhcp6_client *l_netconfig_get_dhcp6_client(
+						struct l_netconfig *netconfig);
+struct l_icmp6_client *l_netconfig_get_icmp6_client(
+						struct l_netconfig *netconfig);
 =

 void l_netconfig_set_event_handler(struct l_netconfig *netconfig,
 					l_netconfig_event_cb_t handler,
-- =

2.32.0

--===============6166744591686483082==--

