Content-Type: multipart/mixed; boundary="===============8256478294818410365=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 08/20] dhcp-lease: add mac member and getter
Date: Fri, 16 Oct 2020 08:36:23 -0700
Message-ID: <20201016153635.660391-8-prestwoj@gmail.com>
In-Reply-To: <20201016153635.660391-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8256478294818410365==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Added for server since it needs to track each clients
MAC address.
---
 ell/dhcp-lease.c   | 8 ++++++++
 ell/dhcp-private.h | 2 ++
 ell/dhcp.h         | 1 +
 3 files changed, 11 insertions(+)

diff --git a/ell/dhcp-lease.c b/ell/dhcp-lease.c
index ac90c6a..59de3e3 100644
--- a/ell/dhcp-lease.c
+++ b/ell/dhcp-lease.c
@@ -278,3 +278,11 @@ LIB_EXPORT uint32_t l_dhcp_lease_get_lifetime(const st=
ruct l_dhcp_lease *lease)
 =

 	return lease->lifetime;
 }
+
+LIB_EXPORT const uint8_t *l_dhcp_lease_get_mac(const struct l_dhcp_lease *=
lease)
+{
+	if (unlikely(!lease))
+		return NULL;
+
+	return lease->mac;
+}
diff --git a/ell/dhcp-private.h b/ell/dhcp-private.h
index a1e1155..ddc0662 100644
--- a/ell/dhcp-private.h
+++ b/ell/dhcp-private.h
@@ -138,6 +138,8 @@ struct l_dhcp_lease {
 	uint32_t router;
 	uint32_t *dns;
 	char *domain_name;
+	/* for server */
+	uint8_t mac[6];
 };
 =

 struct l_dhcp_lease *_dhcp_lease_new(void);
diff --git a/ell/dhcp.h b/ell/dhcp.h
index b8a5b41..c78b605 100644
--- a/ell/dhcp.h
+++ b/ell/dhcp.h
@@ -96,6 +96,7 @@ char *l_dhcp_lease_get_broadcast(const struct l_dhcp_leas=
e *lease);
 char *l_dhcp_lease_get_server_id(const struct l_dhcp_lease *lease);
 char **l_dhcp_lease_get_dns(const struct l_dhcp_lease *lease);
 char *l_dhcp_lease_get_domain_name(const struct l_dhcp_lease *lease);
+const uint8_t *l_dhcp_lease_get_mac(const struct l_dhcp_lease *lease);
 =

 uint32_t l_dhcp_lease_get_t1(const struct l_dhcp_lease *lease);
 uint32_t l_dhcp_lease_get_t2(const struct l_dhcp_lease *lease);
-- =

2.26.2

--===============8256478294818410365==--

