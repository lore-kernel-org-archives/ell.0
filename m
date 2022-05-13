Content-Type: multipart/mixed; boundary="===============1888143957049693707=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 01/17] net: Add net_prefix_from_ipv6 utility
Date: Sat, 14 May 2022 00:46:57 +0200
Message-ID: <20220513224713.1447773-1-andrew.zaborowski@intel.com>

--===============1888143957049693707==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add function that zeroes bits after prefix_len'th bit in an address.  Put
it in net-private.h so it can be used by both netconfig.c and icmp6.c,
potentially others.
---
 ell/net-private.h | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/ell/net-private.h b/ell/net-private.h
index cc395bb..39d4d98 100644
--- a/ell/net-private.h
+++ b/ell/net-private.h
@@ -22,3 +22,21 @@
 =

 char *net_domain_name_parse(const uint8_t *raw, size_t raw_len);
 char **net_domain_list_parse(const uint8_t *raw, size_t raw_len);
+
+static inline const void *net_prefix_from_ipv6(const uint8_t *address,
+						uint8_t prefix_len)
+{
+	uint8_t last_byte =3D prefix_len / 8;
+	uint8_t bits =3D prefix_len & 7;
+	static uint8_t prefix[16];
+
+	memcpy(prefix, address, last_byte);
+
+	if (prefix_len & 7) {
+		prefix[last_byte] =3D address[last_byte] & (0xff00 >> bits);
+		last_byte++;
+	}
+
+	memset(prefix + last_byte, 0, 16 - last_byte);
+	return prefix;
+}
-- =

2.32.0

--===============1888143957049693707==--

