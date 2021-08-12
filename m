Content-Type: multipart/mixed; boundary="===============6011562806430737815=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/4] dhcp: Add some setters for struct l_dhcp_lease
Date: Thu, 12 Aug 2021 22:51:10 +0200
Message-ID: <20210812205112.86584-2-andrew.zaborowski@intel.com>
In-Reply-To: <20210812205112.86584-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6011562806430737815==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/dhcp-lease.c | 107 +++++++++++++++++++++++++++++++++++++++++++++++
 ell/dhcp.h       |   8 ++++
 ell/ell.sym      |   6 +++
 3 files changed, 121 insertions(+)

diff --git a/ell/dhcp-lease.c b/ell/dhcp-lease.c
index a28a3f3..40dba83 100644
--- a/ell/dhcp-lease.c
+++ b/ell/dhcp-lease.c
@@ -300,3 +300,110 @@ LIB_EXPORT const uint8_t *l_dhcp_lease_get_mac(const =
struct l_dhcp_lease *lease)
 =

 	return lease->mac;
 }
+
+LIB_EXPORT bool l_dhcp_lease_set_address(struct l_dhcp_lease *lease,
+						const char *address_str)
+{
+	struct in_addr in_addr;
+
+	if (unlikely(!lease || !address_str))
+		return false;
+
+	if (unlikely(inet_pton(AF_INET, address_str, &in_addr) !=3D 1))
+		return false;
+
+	lease->address =3D in_addr.s_addr;
+	return true;
+}
+
+LIB_EXPORT bool l_dhcp_lease_set_gateway(struct l_dhcp_lease *lease,
+						const char *gateway_str)
+{
+	struct in_addr in_addr;
+
+	if (unlikely(!lease))
+		return false;
+
+	if (!gateway_str) {
+		lease->router =3D 0;
+		return true;
+	}
+
+	if (unlikely(inet_pton(AF_INET, gateway_str, &in_addr) !=3D 1))
+		return false;
+
+	lease->router =3D in_addr.s_addr;
+	return true;
+}
+
+LIB_EXPORT bool l_dhcp_lease_set_mac(struct l_dhcp_lease *lease,
+					const uint8_t *mac)
+{
+	if (unlikely(!lease || !mac))
+		return false;
+
+	memcpy(lease->mac, mac, 6);
+	return true;
+}
+
+LIB_EXPORT bool l_dhcp_lease_set_dns(struct l_dhcp_lease *lease,
+					const char **dns_str_list)
+{
+	unsigned int n;
+	L_AUTO_FREE_VAR(uint32_t *, new_list) =3D NULL;
+
+	if (unlikely(!lease))
+		return false;
+
+	if (!dns_str_list) {
+		l_free(l_steal_ptr(lease->dns));
+		return true;
+	}
+
+	for (n =3D 0; dns_str_list[n]; n++);
+	new_list =3D l_new(uint32_t, n + 1);
+
+	for (n =3D 0; dns_str_list[n]; n++) {
+		struct in_addr in_addr;
+
+		if (unlikely(inet_pton(AF_INET, dns_str_list[n],
+					&in_addr) !=3D 1))
+			return false;
+
+		new_list[n] =3D in_addr.s_addr;
+	}
+
+	l_free(lease->dns);
+	lease->dns =3D l_steal_ptr(new_list);
+	return true;
+}
+
+LIB_EXPORT bool l_dhcp_lease_set_lifetime(struct l_dhcp_lease *lease,
+						uint32_t lifetime)
+{
+	if (unlikely(!lease))
+		return false;
+
+	lease->lifetime =3D lifetime;
+	return true;
+}
+
+LIB_EXPORT bool l_dhcp_lease_set_server_id(struct l_dhcp_lease *lease,
+						const char *server_id_str)
+{
+	struct in_addr in_addr;
+
+	if (unlikely(!lease))
+		return false;
+
+	if (!server_id_str) {
+		lease->server_address =3D 0;
+		return true;
+	}
+
+	if (unlikely(inet_pton(AF_INET, server_id_str, &in_addr) !=3D 1))
+		return false;
+
+	lease->server_address =3D in_addr.s_addr;
+	return true;
+}
diff --git a/ell/dhcp.h b/ell/dhcp.h
index 4f18f01..4406cd2 100644
--- a/ell/dhcp.h
+++ b/ell/dhcp.h
@@ -120,6 +120,14 @@ uint32_t l_dhcp_lease_get_t1(const struct l_dhcp_lease=
 *lease);
 uint32_t l_dhcp_lease_get_t2(const struct l_dhcp_lease *lease);
 uint32_t l_dhcp_lease_get_lifetime(const struct l_dhcp_lease *lease);
 =

+bool l_dhcp_lease_set_address(struct l_dhcp_lease *lease, const char *addr=
ess);
+bool l_dhcp_lease_set_gateway(struct l_dhcp_lease *lease, const char *gate=
way);
+bool l_dhcp_lease_set_mac(struct l_dhcp_lease *lease, const uint8_t *mac);
+bool l_dhcp_lease_set_dns(struct l_dhcp_lease *lease, const char **dns);
+bool l_dhcp_lease_set_lifetime(struct l_dhcp_lease *lease, uint32_t lifeti=
me);
+bool l_dhcp_lease_set_server_id(struct l_dhcp_lease *lease,
+				const char *address);
+
 struct l_dhcp_server *l_dhcp_server_new(int ifindex);
 void l_dhcp_server_destroy(struct l_dhcp_server *server);
 bool l_dhcp_server_start(struct l_dhcp_server *server);
diff --git a/ell/ell.sym b/ell/ell.sym
index 66ebf46..f96a52d 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -236,6 +236,12 @@ global:
 	l_dhcp_lease_get_t1;
 	l_dhcp_lease_get_t2;
 	l_dhcp_lease_get_lifetime;
+	l_dhcp_lease_set_address;
+	l_dhcp_lease_set_gateway;
+	l_dhcp_lease_set_mac;
+	l_dhcp_lease_set_dns;
+	l_dhcp_lease_set_lifetime;
+	l_dhcp_lease_set_server_id;
 	l_dhcp_client_new;
 	l_dhcp_client_destroy;
 	l_dhcp_client_add_request_option;
-- =

2.30.2

--===============6011562806430737815==--

