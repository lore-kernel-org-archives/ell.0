Content-Type: multipart/mixed; boundary="===============0702166471690474272=="
MIME-Version: 1.0
From: James Prestwood <prestwoj at gmail.com>
To: ell at lists.01.org
Subject: [PATCH 4/5] util: add l_secure_select_byte
Date: Fri, 04 Feb 2022 09:06:01 -0800
Message-ID: <20220204170603.216439-4-prestwoj@gmail.com>
In-Reply-To: 20220204170603.216439-1-prestwoj@gmail.com

--===============0702166471690474272==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This was taken from IWD and modified slightly to act off a boolean
rather than a 0xff/0x00 byte to stay consistent with l_secure_select
---
 ell/util.h | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/ell/util.h b/ell/util.h
index 9d4e36c..d390d27 100644
--- a/ell/util.h
+++ b/ell/util.h
@@ -425,6 +425,21 @@ static inline void l_secure_select(bool select_left,
 		o[i] =3D r[i] ^ ((l[i] ^ r[i]) & mask);
 }
 =

+/*
+ * Returns either true_value or false_value (depending if mask is 0xFF or =
0x00
+ * respectively).
+ * This constant time selection method allows to keep an identical memory
+ * access pattern.
+ */
+static inline uint8_t l_secure_select_byte(bool select_true,
+					const uint8_t true_value,
+					const uint8_t false_value)
+{
+	uint8_t mask =3D -(!!select_true);
+
+	return (mask & true_value) | (~mask & false_value);
+}
+
 #ifdef __cplusplus
 }
 #endif
-- =

2.31.1

--===============0702166471690474272==--

