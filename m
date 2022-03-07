Content-Type: multipart/mixed; boundary="===============5809405179258444226=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 03/12] dhcp: Add l_dhcp_lease_get_start_time
Date: Mon, 07 Mar 2022 15:55:34 +0100
Message-ID: <20220307145543.1558788-3-andrew.zaborowski@intel.com>
In-Reply-To: 20220307145543.1558788-1-andrew.zaborowski@intel.com

--===============5809405179258444226==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add a getter for the rx timestamp of the lease ACK, i.e. the time from
which the lifetime period is counted.
---
 ell/dhcp-lease.c | 9 +++++++++
 ell/dhcp.h       | 1 +
 ell/ell.sym      | 1 +
 3 files changed, 11 insertions(+)

diff --git a/ell/dhcp-lease.c b/ell/dhcp-lease.c
index bc4ff74..b618f11 100644
--- a/ell/dhcp-lease.c
+++ b/ell/dhcp-lease.c
@@ -351,6 +351,15 @@ LIB_EXPORT uint32_t l_dhcp_lease_get_lifetime(const st=
ruct l_dhcp_lease *lease)
 	return lease->lifetime;
 }
 =

+LIB_EXPORT uint64_t l_dhcp_lease_get_start_time(
+					const struct l_dhcp_lease *lease)
+{
+	if (unlikely(!lease))
+		return 0;
+
+	return lease->bound_time;
+}
+
 LIB_EXPORT const uint8_t *l_dhcp_lease_get_mac(const struct l_dhcp_lease *=
lease)
 {
 	if (unlikely(!lease))
diff --git a/ell/dhcp.h b/ell/dhcp.h
index 4aa4a0a..946bf63 100644
--- a/ell/dhcp.h
+++ b/ell/dhcp.h
@@ -122,6 +122,7 @@ const uint8_t *l_dhcp_lease_get_mac(const struct l_dhcp=
_lease *lease);
 uint32_t l_dhcp_lease_get_t1(const struct l_dhcp_lease *lease);
 uint32_t l_dhcp_lease_get_t2(const struct l_dhcp_lease *lease);
 uint32_t l_dhcp_lease_get_lifetime(const struct l_dhcp_lease *lease);
+uint64_t l_dhcp_lease_get_start_time(const struct l_dhcp_lease *lease);
 =

 struct l_dhcp_server *l_dhcp_server_new(int ifindex);
 void l_dhcp_server_destroy(struct l_dhcp_server *server);
diff --git a/ell/ell.sym b/ell/ell.sym
index 1641506..2fb5c55 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -240,6 +240,7 @@ global:
 	l_dhcp_lease_get_t1;
 	l_dhcp_lease_get_t2;
 	l_dhcp_lease_get_lifetime;
+	l_dhcp_lease_get_start_time;
 	l_dhcp_client_new;
 	l_dhcp_client_destroy;
 	l_dhcp_client_add_request_option;
-- =

2.32.0

--===============5809405179258444226==--

