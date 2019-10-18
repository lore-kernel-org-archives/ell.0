Content-Type: multipart/mixed; boundary="===============3135235234552983167=="
MIME-Version: 1.0
From: Tim Kourt <tim.a.kourt@linux.intel.com>
Subject: [PATCH] dhcp: Add domain name option handler
Date: Fri, 18 Oct 2019 15:29:19 -0700
Message-ID: <20191018222919.11454-1-tim.a.kourt@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3135235234552983167==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add parser and accessor for domain name lease option.
---
 ell/dhcp-lease.c   | 16 +++++++++++++++-
 ell/dhcp-private.h |  1 +
 ell/dhcp.h         |  1 +
 3 files changed, 17 insertions(+), 1 deletion(-)

diff --git a/ell/dhcp-lease.c b/ell/dhcp-lease.c
index a48cfa4..ba57322 100644
--- a/ell/dhcp-lease.c
+++ b/ell/dhcp-lease.c
@@ -45,6 +45,8 @@ void _dhcp_lease_free(struct l_dhcp_lease *lease)
 		return;
 =

 	l_free(lease->dns);
+	l_free(lease->domain_name);
+
 	l_free(lease);
 }
 =

@@ -99,6 +101,10 @@ struct l_dhcp_lease *_dhcp_lease_parse_options(struct d=
hcp_message_iter *iter)
 				}
 			}
 			break;
+		case L_DHCP_OPTION_DOMAIN_NAME:
+			if (l >=3D 1)
+				lease->domain_name =3D l_strdup(v);
+			break;
 		default:
 			break;
 		}
@@ -124,7 +130,7 @@ struct l_dhcp_lease *_dhcp_lease_parse_options(struct d=
hcp_message_iter *iter)
 =

 	return lease;
 error:
-	l_free(lease);
+	_dhcp_lease_free(lease);
 	return NULL;
 }
 =

@@ -201,6 +207,14 @@ LIB_EXPORT char **l_dhcp_lease_get_dns(const struct l_=
dhcp_lease *lease)
 	return dns_list;
 }
 =

+LIB_EXPORT char *l_dhcp_lease_get_domain_name(const struct l_dhcp_lease *l=
ease)
+{
+	if (unlikely(!lease))
+		return NULL;
+
+	return l_strdup(lease->domain_name);
+}
+
 LIB_EXPORT uint32_t l_dhcp_lease_get_t1(const struct l_dhcp_lease *lease)
 {
 	if (unlikely(!lease))
diff --git a/ell/dhcp-private.h b/ell/dhcp-private.h
index 6554fc6..a75bb8b 100644
--- a/ell/dhcp-private.h
+++ b/ell/dhcp-private.h
@@ -120,6 +120,7 @@ struct l_dhcp_lease {
 	uint32_t t2;
 	uint32_t router;
 	uint32_t *dns;
+	char *domain_name;
 };
 =

 struct l_dhcp_lease *_dhcp_lease_new(void);
diff --git a/ell/dhcp.h b/ell/dhcp.h
index c3a4988..b8a5b41 100644
--- a/ell/dhcp.h
+++ b/ell/dhcp.h
@@ -95,6 +95,7 @@ char *l_dhcp_lease_get_netmask(const struct l_dhcp_lease =
*lease);
 char *l_dhcp_lease_get_broadcast(const struct l_dhcp_lease *lease);
 char *l_dhcp_lease_get_server_id(const struct l_dhcp_lease *lease);
 char **l_dhcp_lease_get_dns(const struct l_dhcp_lease *lease);
+char *l_dhcp_lease_get_domain_name(const struct l_dhcp_lease *lease);
 =

 uint32_t l_dhcp_lease_get_t1(const struct l_dhcp_lease *lease);
 uint32_t l_dhcp_lease_get_t2(const struct l_dhcp_lease *lease);
-- =

2.13.6

--===============3135235234552983167==--

