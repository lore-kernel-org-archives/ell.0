Content-Type: multipart/mixed; boundary="===============8806432159394042725=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/3] icmp6: Add l_icmp6_router_get_address
Date: Wed, 30 Jun 2021 20:51:06 +0200
Message-ID: <20210630185108.263533-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8806432159394042725==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add a getter for the router's address and make a small formatting change
while there.
---
 ell/ell.sym |  1 +
 ell/icmp6.c | 15 ++++++++++++++-
 ell/icmp6.h |  1 +
 3 files changed, 16 insertions(+), 1 deletion(-)

diff --git a/ell/ell.sym b/ell/ell.sym
index 1fbd98c..d7027e3 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -657,6 +657,7 @@ global:
 	l_icmp6_client_set_nodelay;
 	l_icmp6_client_set_rtnl;
 	l_icmp6_client_set_route_priority;
+	l_icmp6_router_get_address;
 	l_icmp6_router_get_managed;
 	l_icmp6_router_get_other;
 	/* acd */
diff --git a/ell/icmp6.c b/ell/icmp6.c
index fe8a506..ebdcabd 100644
--- a/ell/icmp6.c
+++ b/ell/icmp6.c
@@ -728,12 +728,25 @@ struct l_icmp6_router *_icmp6_router_parse(const stru=
ct nd_router_advert *ra,
 		}
 =

 		opts +=3D l;
-		opts_len -=3D l ;
+		opts_len -=3D l;
 	}
 =

 	return r;
 }
 =

+LIB_EXPORT char *l_icmp6_router_get_address(const struct l_icmp6_router *r)
+{
+	char buf[INET6_ADDRSTRLEN];
+
+	if (unlikely(!r))
+		return NULL;
+
+	if (!inet_ntop(AF_INET6, r->address, buf, sizeof(buf)))
+		return NULL;
+
+	return l_strdup(buf);
+}
+
 LIB_EXPORT bool l_icmp6_router_get_managed(const struct l_icmp6_router *r)
 {
 	if (unlikely(!r))
diff --git a/ell/icmp6.h b/ell/icmp6.h
index a6b1265..b2231c9 100644
--- a/ell/icmp6.h
+++ b/ell/icmp6.h
@@ -66,6 +66,7 @@ bool l_icmp6_client_set_rtnl(struct l_icmp6_client *clien=
t,
 bool l_icmp6_client_set_route_priority(struct l_icmp6_client *client,
 						uint32_t priority);
 =

+char *l_icmp6_router_get_address(const struct l_icmp6_router *r);
 bool l_icmp6_router_get_managed(const struct l_icmp6_router *r);
 bool l_icmp6_router_get_other(const struct l_icmp6_router *r);
 =

-- =

2.30.2

--===============8806432159394042725==--

