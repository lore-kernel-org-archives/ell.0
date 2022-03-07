Content-Type: multipart/mixed; boundary="===============8559139573762327135=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 07/12] icmp6: Add router lifetime and rx timestamp getters
Date: Mon, 07 Mar 2022 15:55:38 +0100
Message-ID: <20220307145543.1558788-7-andrew.zaborowski@intel.com>
In-Reply-To: 20220307145543.1558788-1-andrew.zaborowski@intel.com

--===============8559139573762327135==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add l_icmp6_router getters for the current lifetime and rx timestamp
(when lifetime is counted from) so that netconfig.c can build route
information from the l_icmp6 API.  Indent a comment in ell.sym
consistent with surrounding lines.
---
 ell/ell.sym |  4 +++-
 ell/icmp6.c | 17 +++++++++++++++++
 ell/icmp6.h |  2 ++
 3 files changed, 22 insertions(+), 1 deletion(-)

diff --git a/ell/ell.sym b/ell/ell.sym
index db29d9a..e2a278f 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -685,7 +685,7 @@ global:
 	l_rtnl_ifaddr_delete;
 	l_rtnl_neighbor_get_hwaddr;
 	l_rtnl_neighbor_set_hwaddr;
-/* icmp6 */
+	/* icmp6 */
 	l_icmp6_client_new;
 	l_icmp6_client_free;
 	l_icmp6_client_start;
@@ -700,6 +700,8 @@ global:
 	l_icmp6_router_get_address;
 	l_icmp6_router_get_managed;
 	l_icmp6_router_get_other;
+	l_icmp6_router_get_lifetime;
+	l_icmp6_router_get_start_time;
 	/* acd */
 	l_acd_new;
 	l_acd_start;
diff --git a/ell/icmp6.c b/ell/icmp6.c
index b0f8727..e74b6d6 100644
--- a/ell/icmp6.c
+++ b/ell/icmp6.c
@@ -815,3 +815,20 @@ LIB_EXPORT bool l_icmp6_router_get_other(const struct =
l_icmp6_router *r)
 =

 	return r->other;
 }
+
+LIB_EXPORT uint16_t l_icmp6_router_get_lifetime(const struct l_icmp6_route=
r *r)
+{
+	if (unlikely(!r))
+		return false;
+
+	return r->lifetime;
+}
+
+/* Get the reception timestamp, i.e. when lifetime is counted from */
+LIB_EXPORT uint64_t l_icmp6_router_get_start_time(const struct l_icmp6_rou=
ter *r)
+{
+	if (unlikely(!r))
+		return false;
+
+	return r->start_time;
+}
diff --git a/ell/icmp6.h b/ell/icmp6.h
index 9ce2e24..615dba4 100644
--- a/ell/icmp6.h
+++ b/ell/icmp6.h
@@ -69,6 +69,8 @@ bool l_icmp6_client_set_route_priority(struct l_icmp6_cli=
ent *client,
 char *l_icmp6_router_get_address(const struct l_icmp6_router *r);
 bool l_icmp6_router_get_managed(const struct l_icmp6_router *r);
 bool l_icmp6_router_get_other(const struct l_icmp6_router *r);
+uint16_t l_icmp6_router_get_lifetime(const struct l_icmp6_router *r);
+uint64_t l_icmp6_router_get_start_time(const struct l_icmp6_router *r);
 =

 #ifdef __cplusplus
 }
-- =

2.32.0

--===============8559139573762327135==--

