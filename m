Content-Type: multipart/mixed; boundary="===============1629909683713422548=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 01/17] net: Add l_net_mask_prefix utility
Date: Fri, 13 May 2022 16:54:54 +0200
Message-ID: <20220513145510.1408510-1-andrew.zaborowski@intel.com>

--===============1629909683713422548==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add function that zeros bits after prefix_len'th bit in an address.  Put
it in net.h so it can be use by both netconfig.c and icmp6.c,
potentially others.
---
 ell/net.h | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/ell/net.h b/ell/net.h
index 0521d75..bc9ba12 100644
--- a/ell/net.h
+++ b/ell/net.h
@@ -61,6 +61,20 @@ static inline bool l_net_prefix_matches(const void *a, c=
onst void *b,
 	return !bits || ((left ^ right) & (0xff00u >> bits)) =3D=3D 0;
 }
 =

+static inline void l_net_mask_prefix(uint8_t *address, uint8_t prefix_len,
+					uint8_t address_bytes)
+{
+	uint8_t last_byte =3D prefix_len / 8;
+	uint8_t bits =3D prefix_len & 7;
+
+	if (prefix_len & 7) {
+		address[last_byte] &=3D 0xff00 >> bits;
+		last_byte++;
+	}
+
+	memset(address + last_byte, 0, address_bytes - last_byte);
+}
+
 #ifdef __cplusplus
 }
 #endif
-- =

2.32.0

--===============1629909683713422548==--

