Content-Type: multipart/mixed; boundary="===============5474598634376704056=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 08/13] netconfig: Add l_netconfig_get_{dhcp6,icmp6}_client
Date: Fri, 06 May 2022 01:15:34 +0200
Message-ID: <20220505231539.888792-8-andrew.zaborowski@intel.com>
In-Reply-To: 20220505231539.888792-1-andrew.zaborowski@intel.com

--===============5474598634376704056==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/ell.sym     |  2 ++
 ell/netconfig.c | 18 ++++++++++++++++++
 ell/netconfig.h |  4 ++++
 3 files changed, 24 insertions(+)

diff --git a/ell/ell.sym b/ell/ell.sym
index 60dd257..0f9f884 100644
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
index 19d49db..57b1a04 100644
--- a/ell/netconfig.c
+++ b/ell/netconfig.c
@@ -1268,6 +1268,24 @@ LIB_EXPORT struct l_dhcp_client *l_netconfig_get_dhc=
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
index cf11c67..69100a2 100644
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

--===============5474598634376704056==--

