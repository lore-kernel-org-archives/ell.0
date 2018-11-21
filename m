Content-Type: multipart/mixed; boundary="===============3623288055694157720=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 07/16] asn1: Implement asn1_write_definite_length
Date: Wed, 21 Nov 2018 16:08:54 +0100
Message-ID: <20181121150903.24437-7-andrew.zaborowski@intel.com>
In-Reply-To: <20181121150903.24437-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3623288055694157720==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/asn1-private.h | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/ell/asn1-private.h b/ell/asn1-private.h
index 0c5897a..bea9ea9 100644
--- a/ell/asn1-private.h
+++ b/ell/asn1-private.h
@@ -68,6 +68,22 @@ static inline int asn1_parse_definite_length(const uint8=
_t **buf,
 	return result;
 }
 =

+static inline void asn1_write_definite_length(uint8_t **buf, size_t len)
+{
+	int n;
+
+	if (len < 0x80) {
+		*(*buf)++ =3D len;
+		return;
+	}
+
+	for (n =3D 1; len >> (n * 8); n++);
+	*(*buf)++ =3D 0x80 | n;
+
+	while (n--)
+		*(*buf)++ =3D len >> (n * 8);
+}
+
 /* Return index'th element in a DER SEQUENCE */
 static inline const uint8_t *asn1_der_find_elem(const uint8_t *buf,
 						size_t len_in, int index,
-- =

2.19.1


--===============3623288055694157720==--

