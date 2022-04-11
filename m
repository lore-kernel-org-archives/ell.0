Content-Type: multipart/mixed; boundary="===============7113989042423392373=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 01/11] net: Add l_net_subnet_matches
Date: Mon, 11 Apr 2022 16:20:46 +0200
Message-ID: <20220411142056.817784-1-andrew.zaborowski@intel.com>

--===============7113989042423392373==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add inline function to check if two IP addresses are in the same subnet.
---
 ell/net.h | 21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/ell/net.h b/ell/net.h
index c97d9c9..837209c 100644
--- a/ell/net.h
+++ b/ell/net.h
@@ -25,6 +25,7 @@
 =

 #include <stdbool.h>
 #include <stdint.h>
+#include <string.h>
 =

 struct in_addr;
 struct in6_addr;
@@ -40,6 +41,26 @@ bool l_net_hostname_is_localhost(const char *hostname);
 bool l_net_get_address(int ifindex, struct in_addr *out);
 bool l_net_get_link_local_address(int ifindex, struct in6_addr *out);
 =

+static inline bool l_net_subnet_matches(const void *a, const void *b,
+					uint8_t prefix_len)
+{
+	uint8_t bytes =3D prefix_len / 8;
+	uint8_t bits =3D prefix_len & 7;
+
+	/*
+	 * @a and @b are network byte order IPv4 or IPv6 addresses.
+	 * We want to check if the initial (top) @prefix_len bits match.
+	 * memcmp the whole bytes, then compare the final byte's top
+	 * bits by anding with a mask.
+	 */
+	if (bytes && memcmp(a, b, bytes))
+		return false;
+
+	return !bits ||
+		((((const uint8_t *) a)[bytes] ^ ((const uint8_t *) b)[bytes]) &
+		 (0xff00u >> bits)) =3D=3D 0;
+}
+
 #ifdef __cplusplus
 }
 #endif
-- =

2.32.0

--===============7113989042423392373==--

