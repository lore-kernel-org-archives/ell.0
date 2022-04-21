Content-Type: multipart/mixed; boundary="===============3365917667815424063=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 01/12] net: Rename l_net_subnet_matches to l_net_prefix_matches
Date: Thu, 21 Apr 2022 17:45:14 +0200
Message-ID: <20220421154525.1416984-1-andrew.zaborowski@intel.com>

--===============3365917667815424063==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/net.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/net.h b/ell/net.h
index eaaf14c..0521d75 100644
--- a/ell/net.h
+++ b/ell/net.h
@@ -41,7 +41,7 @@ bool l_net_hostname_is_localhost(const char *hostname);
 bool l_net_get_address(int ifindex, struct in_addr *out);
 bool l_net_get_link_local_address(int ifindex, struct in6_addr *out);
 =

-static inline bool l_net_subnet_matches(const void *a, const void *b,
+static inline bool l_net_prefix_matches(const void *a, const void *b,
 					uint8_t prefix_len)
 {
 	uint8_t bytes =3D prefix_len / 8;
-- =

2.32.0

--===============3365917667815424063==--

