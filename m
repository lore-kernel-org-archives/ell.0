Content-Type: multipart/mixed; boundary="===============3602463872369489616=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 01/13] net: Add l_net_clear_host_bits utility
Date: Fri, 06 May 2022 01:15:27 +0200
Message-ID: <20220505231539.888792-1-andrew.zaborowski@intel.com>

--===============3602463872369489616==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add function that zeros bits after prefix_len'th bit in an address.  Put
it in net.h so it can be use by both netconfig.c and icmp6.c,
potentially others.
---
 ell/net.h | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/ell/net.h b/ell/net.h
index 0521d75..e193eef 100644
--- a/ell/net.h
+++ b/ell/net.h
@@ -61,6 +61,19 @@ static inline bool l_net_prefix_matches(const void *a, c=
onst void *b,
 	return !bits || ((left ^ right) & (0xff00u >> bits)) =3D=3D 0;
 }
 =

+static inline void l_net_clear_host_bits(uint8_t *address, uint8_t prefix_=
len,
+						uint8_t bytes)
+{
+	uint8_t last_byte =3D prefix_len / 8;
+
+	if (prefix_len & 7) {
+		address[last_byte] &=3D 0xff00 >> (prefix_len & 7);
+		last_byte++;
+	}
+
+	memset(address + last_byte, 0, bytes - last_byte);
+}
+
 #ifdef __cplusplus
 }
 #endif
-- =

2.32.0

--===============3602463872369489616==--

