Content-Type: multipart/mixed; boundary="===============7834867806321878959=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 09/15] netconfig: Add getters for DNS addresses and domain
 names
Date: Fri, 20 May 2022 17:43:32 +0200
Message-ID: <20220520154338.2056273-9-andrew.zaborowski@intel.com>
In-Reply-To: 20220520154338.2056273-1-andrew.zaborowski@intel.com

--===============7834867806321878959==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/ell.sym     |  2 ++
 ell/netconfig.c | 64 +++++++++++++++++++++++++++++++++++++++++++++++++
 ell/netconfig.h |  2 ++
 3 files changed, 68 insertions(+)

diff --git a/ell/ell.sym b/ell/ell.sym
index ea4d06c..3b11f41 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -757,6 +757,8 @@ global:
 	l_netconfig_apply_rtnl;
 	l_netconfig_get_addresses;
 	l_netconfig_get_routes;
+	l_netconfig_get_dns_list;
+	l_netconfig_get_domain_names;
 local:
 	*;
 };
diff --git a/ell/netconfig.c b/ell/netconfig.c
index 77af8c9..63ad154 100644
--- a/ell/netconfig.c
+++ b/ell/netconfig.c
@@ -1422,3 +1422,67 @@ LIB_EXPORT const struct l_queue_entry *l_netconfig_g=
et_routes(
 =

 	return l_queue_get_entries(netconfig->routes.current);
 }
+
+/* Returns a new strv array to be freed by the caller */
+LIB_EXPORT char **l_netconfig_get_dns_list(struct l_netconfig *netconfig)
+{
+	char **ret =3D NULL;
+	const struct l_dhcp_lease *v4_lease;
+	const struct l_dhcp6_lease *v6_lease;
+
+#define CONCAT(dest, src, free)		\
+	do {				\
+		char **tmp =3D src;	\
+		tmp =3D free ? tmp : l_strv_copy(tmp);	\
+		if (!dest)		\
+			dest =3D tmp;	\
+		else if (tmp) {		\
+			unsigned int destlen =3D l_strv_length(dest);	\
+			unsigned int srclen =3D l_strv_length(tmp);	\
+			dest =3D l_realloc(dest, sizeof(char *) *	\
+				(destlen + srclen + 1));	\
+			memcpy(dest + destlen, tmp, sizeof(char *) *	\
+					(srclen + 1));	\
+			l_free(tmp);	\
+		}			\
+	} while (0)
+
+	if (netconfig->v4_dns_override)
+		CONCAT(ret, netconfig->v4_dns_override, false);
+	else if ((v4_lease =3D
+			l_dhcp_client_get_lease(netconfig->dhcp_client)))
+		CONCAT(ret, l_dhcp_lease_get_dns(v4_lease), true);
+
+	if (netconfig->v6_dns_override)
+		CONCAT(ret, netconfig->v6_dns_override, false);
+	else if ((v6_lease =3D
+			l_dhcp6_client_get_lease(netconfig->dhcp6_client)))
+		CONCAT(ret, l_dhcp6_lease_get_dns(v6_lease), true);
+
+	return ret;
+}
+
+/* Returns a new strv array to be freed by the caller */
+LIB_EXPORT char **l_netconfig_get_domain_names(struct l_netconfig *netconf=
ig)
+{
+	char **ret =3D NULL;
+	const struct l_dhcp_lease *v4_lease;
+	const struct l_dhcp6_lease *v6_lease;
+
+	if (netconfig->v4_domain_names_override)
+		CONCAT(ret, netconfig->v4_domain_names_override, false);
+	else if ((v4_lease =3D
+			l_dhcp_client_get_lease(netconfig->dhcp_client)) &&
+			l_dhcp_lease_get_domain_name(v4_lease)) {
+		ret =3D l_new(char *, 2);
+		ret[0] =3D l_dhcp_lease_get_domain_name(v4_lease);
+	}
+
+	if (netconfig->v6_dns_override)
+		CONCAT(ret, netconfig->v6_domain_names_override, false);
+	else if ((v6_lease =3D
+			l_dhcp6_client_get_lease(netconfig->dhcp6_client)))
+		CONCAT(ret, l_dhcp6_lease_get_domains(v6_lease), true);
+
+	return ret;
+}
diff --git a/ell/netconfig.h b/ell/netconfig.h
index 69100a2..0b1182d 100644
--- a/ell/netconfig.h
+++ b/ell/netconfig.h
@@ -98,6 +98,8 @@ const struct l_queue_entry *l_netconfig_get_routes(
 				const struct l_queue_entry **out_updated,
 				const struct l_queue_entry **out_removed,
 				const struct l_queue_entry **out_expired);
+char **l_netconfig_get_dns_list(struct l_netconfig *netconfig);
+char **l_netconfig_get_domain_names(struct l_netconfig *netconfig);
 =

 #ifdef __cplusplus
 }
-- =

2.32.0

--===============7834867806321878959==--

