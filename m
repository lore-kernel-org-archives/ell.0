Content-Type: multipart/mixed; boundary="===============3628183765222820078=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 14/14] netconfig: Add l_netconfig_reset_config
Date: Thu, 16 Jun 2022 00:47:39 +0200
Message-ID: <20220615224739.1936538-14-andrew.zaborowski@intel.com>
In-Reply-To: 20220615224739.1936538-1-andrew.zaborowski@intel.com

--===============3628183765222820078==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/ell.sym     |  1 +
 ell/netconfig.c | 20 ++++++++++++++++++++
 ell/netconfig.h |  1 +
 3 files changed, 22 insertions(+)

diff --git a/ell/ell.sym b/ell/ell.sym
index d74e8c9..8f4e59d 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -748,6 +748,7 @@ global:
 	l_netconfig_set_dns_override;
 	l_netconfig_set_domain_names_override;
 	l_netconfig_check_config;
+	l_netconfig_reset_config;
 	l_netconfig_start;
 	l_netconfig_stop;
 	l_netconfig_get_dhcp_client;
diff --git a/ell/netconfig.c b/ell/netconfig.c
index 7d4a97e..d593088 100644
--- a/ell/netconfig.c
+++ b/ell/netconfig.c
@@ -1292,6 +1292,26 @@ LIB_EXPORT bool l_netconfig_check_config(struct l_ne=
tconfig *netconfig)
 	return netconfig_check_config(netconfig);
 }
 =

+LIB_EXPORT bool l_netconfig_reset_config(struct l_netconfig *netconfig)
+{
+	if (unlikely(!netconfig || netconfig->started))
+		return false;
+
+	l_netconfig_set_hostname(netconfig, NULL);
+	l_netconfig_set_route_priority(netconfig, 0);
+	l_netconfig_set_family_enabled(netconfig, AF_INET, true);
+	l_netconfig_set_static_addr(netconfig, AF_INET, NULL);
+	l_netconfig_set_gateway_override(netconfig, AF_INET, NULL);
+	l_netconfig_set_dns_override(netconfig, AF_INET, NULL);
+	l_netconfig_set_domain_names_override(netconfig, AF_INET, NULL);
+	l_netconfig_set_family_enabled(netconfig, AF_INET6, false);
+	l_netconfig_set_static_addr(netconfig, AF_INET6, NULL);
+	l_netconfig_set_gateway_override(netconfig, AF_INET6, NULL);
+	l_netconfig_set_dns_override(netconfig, AF_INET6, NULL);
+	l_netconfig_set_domain_names_override(netconfig, AF_INET6, NULL);
+	return true;
+}
+
 static void netconfig_add_v4_static_address_routes(struct l_netconfig *nc)
 {
 	char ip[INET_ADDRSTRLEN];
diff --git a/ell/netconfig.h b/ell/netconfig.h
index 0b1182d..ac467b6 100644
--- a/ell/netconfig.h
+++ b/ell/netconfig.h
@@ -69,6 +69,7 @@ bool l_netconfig_set_dns_override(struct l_netconfig *net=
config, uint8_t family,
 bool l_netconfig_set_domain_names_override(struct l_netconfig *netconfig,
 						uint8_t family, char **names);
 bool l_netconfig_check_config(struct l_netconfig *netconfig);
+bool l_netconfig_reset_config(struct l_netconfig *netconfig);
 =

 bool l_netconfig_start(struct l_netconfig *netconfig);
 void l_netconfig_stop(struct l_netconfig *netconfig);
-- =

2.34.1

--===============3628183765222820078==--

