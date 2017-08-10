Content-Type: multipart/mixed; boundary="===============0150804681109281564=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 03/10] tls: Move DER / ASN.1 related definitions to
 asn1-private.h
Date: Fri, 11 Aug 2017 01:10:09 +0200
Message-ID: <20170810231016.29445-3-andrew.zaborowski@intel.com>
In-Reply-To: <20170810231016.29445-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0150804681109281564==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Extract those utilities that can be used by pem.c for decoding encrypted
certificates and possibly other mechanisms.  Introduce the asn1_oid_eq
macro for comparing OIDs.
---
 ell/asn1-private.h | 118 +++++++++++++++++++++++++++++++++++++++++++++++++=
++++
 ell/tls.c          | 102 ++-------------------------------------------
 2 files changed, 121 insertions(+), 99 deletions(-)
 create mode 100644 ell/asn1-private.h

diff --git a/ell/asn1-private.h b/ell/asn1-private.h
new file mode 100644
index 0000000..c1f1c5d
--- /dev/null
+++ b/ell/asn1-private.h
@@ -0,0 +1,118 @@
+/*
+ *  Embedded Linux library
+ *
+ *  Copyright (C) 2017  Intel Corporation. All rights reserved.
+ *
+ *  This library is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU Lesser General Public
+ *  License as published by the Free Software Foundation; either
+ *  version 2.1 of the License, or (at your option) any later version.
+ *
+ *  This library is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ *  Lesser General Public License for more details.
+ *
+ *  You should have received a copy of the GNU Lesser General Public
+ *  License along with this library; if not, write to the Free Software
+ *  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 =
 USA
+ */
+
+#define ASN1_ID(class, pc, tag)	(((class) << 6) | ((pc) << 5) | (tag))
+
+#define ASN1_CLASS_UNIVERSAL	0
+
+#define ASN1_ID_SEQUENCE	ASN1_ID(ASN1_CLASS_UNIVERSAL, 1, 0x10)
+#define ASN1_ID_SET		ASN1_ID(ASN1_CLASS_UNIVERSAL, 1, 0x11)
+#define ASN1_ID_INTEGER		ASN1_ID(ASN1_CLASS_UNIVERSAL, 0, 0x02)
+#define ASN1_ID_BIT_STRING	ASN1_ID(ASN1_CLASS_UNIVERSAL, 0, 0x03)
+#define ASN1_ID_OCTET_STRING	ASN1_ID(ASN1_CLASS_UNIVERSAL, 0, 0x04)
+#define ASN1_ID_OID		ASN1_ID(ASN1_CLASS_UNIVERSAL, 0, 0x06)
+#define ASN1_ID_UTF8STRING	ASN1_ID(ASN1_CLASS_UNIVERSAL, 0, 0x0c)
+#define ASN1_ID_PRINTABLESTRING	ASN1_ID(ASN1_CLASS_UNIVERSAL, 0, 0x13)
+
+struct asn1_oid {
+	uint8_t asn1_len;
+	uint8_t asn1[10];
+};
+
+#define asn1_oid_eq(oid1, oid2_len, oid2_string) \
+	((oid1)->asn1_len =3D=3D (oid2_len) && \
+	 !memcmp((oid1)->asn1, (oid2_string), (oid2_len)))
+
+static inline int parse_asn1_definite_length(const uint8_t **buf,
+						size_t *len)
+{
+	int n;
+	size_t result =3D 0;
+
+	(*len)--;
+
+	if (!(**buf & 0x80))
+		return *(*buf)++;
+
+	n =3D *(*buf)++ & 0x7f;
+	if ((size_t) n > *len)
+		return -1;
+
+	*len -=3D n;
+	while (n--)
+		result =3D (result << 8) | *(*buf)++;
+
+	return result;
+}
+
+/* Return index'th element in a DER SEQUENCE */
+static inline uint8_t *der_find_elem(uint8_t *buf, size_t len_in, int inde=
x,
+			uint8_t *tag, size_t *len_out)
+{
+	int tlv_len;
+
+	while (1) {
+		if (len_in < 2)
+			return NULL;
+
+		*tag =3D *buf++;
+		len_in--;
+
+		tlv_len =3D parse_asn1_definite_length((void *) &buf, &len_in);
+		if (tlv_len < 0 || (size_t) tlv_len > len_in)
+			return NULL;
+
+		if (index-- =3D=3D 0) {
+			*len_out =3D tlv_len;
+			return buf;
+		}
+
+		buf +=3D tlv_len;
+		len_in -=3D tlv_len;
+	}
+}
+
+/* Return an element in a DER SEQUENCE structure by path */
+static inline uint8_t *der_find_elem_by_path(uint8_t *buf, size_t len_in,
+						uint8_t tag, size_t *len_out,
+						...)
+{
+	uint8_t elem_tag;
+	int pos;
+	va_list vl;
+
+	va_start(vl, len_out);
+
+	pos =3D va_arg(vl, int);
+
+	while (pos !=3D -1) {
+		buf =3D der_find_elem(buf, len_in, pos, &elem_tag, &len_in);
+
+		pos =3D va_arg(vl, int);
+
+		if (!buf || elem_tag !=3D (pos =3D=3D -1 ? tag : ASN1_ID_SEQUENCE))
+			return NULL;
+	}
+
+	va_end(vl);
+
+	*len_out =3D len_in;
+	return buf;
+}
diff --git a/ell/tls.c b/ell/tls.c
index 6636fbf..75e3739 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -36,6 +36,7 @@
 #include "pem.h"
 #include "tls-private.h"
 #include "key.h"
+#include "asn1-private.h"
 =

 void tls10_prf(const uint8_t *secret, size_t secret_len,
 		const char *label,
@@ -2309,19 +2310,6 @@ LIB_EXPORT const char *l_tls_alert_to_str(enum l_tls=
_alert_desc desc)
 =

 /* X509 Certificates and Certificate Chains */
 =

-#define ASN1_ID(class, pc, tag)	(((class) << 6) | ((pc) << 5) | (tag))
-
-#define ASN1_CLASS_UNIVERSAL	0
-
-#define ASN1_ID_SEQUENCE	ASN1_ID(ASN1_CLASS_UNIVERSAL, 1, 0x10)
-#define ASN1_ID_SET		ASN1_ID(ASN1_CLASS_UNIVERSAL, 1, 0x11)
-#define ASN1_ID_INTEGER		ASN1_ID(ASN1_CLASS_UNIVERSAL, 0, 0x02)
-#define ASN1_ID_BIT_STRING	ASN1_ID(ASN1_CLASS_UNIVERSAL, 0, 0x03)
-#define ASN1_ID_OCTET_STRING	ASN1_ID(ASN1_CLASS_UNIVERSAL, 0, 0x04)
-#define ASN1_ID_OID		ASN1_ID(ASN1_CLASS_UNIVERSAL, 0, 0x06)
-#define ASN1_ID_UTF8STRING	ASN1_ID(ASN1_CLASS_UNIVERSAL, 0, 0x0c)
-#define ASN1_ID_PRINTABLESTRING	ASN1_ID(ASN1_CLASS_UNIVERSAL, 0, 0x13)
-
 #define X509_CERTIFICATE_POS			0
 #define   X509_TBSCERTIFICATE_POS		  0
 #define     X509_TBSCERT_VERSION_POS		    0
@@ -2341,83 +2329,6 @@ LIB_EXPORT const char *l_tls_alert_to_str(enum l_tls=
_alert_desc desc)
 #define   X509_SIGNATURE_ALGORITHM_POS		  1
 #define   X509_SIGNATURE_VALUE_POS		  2
 =

-static inline int parse_asn1_definite_length(const uint8_t **buf,
-						size_t *len)
-{
-	int n;
-	size_t result =3D 0;
-
-	(*len)--;
-
-	if (!(**buf & 0x80))
-		return *(*buf)++;
-
-	n =3D *(*buf)++ & 0x7f;
-	if ((size_t) n > *len)
-		return -1;
-
-	*len -=3D n;
-	while (n--)
-		result =3D (result << 8) | *(*buf)++;
-
-	return result;
-}
-
-/* Return index'th element in a DER SEQUENCE */
-static uint8_t *der_find_elem(uint8_t *buf, size_t len_in, int index,
-			uint8_t *tag, size_t *len_out)
-{
-	int tlv_len;
-
-	while (1) {
-		if (len_in < 2)
-			return NULL;
-
-		*tag =3D *buf++;
-		len_in--;
-
-		tlv_len =3D parse_asn1_definite_length((void *) &buf, &len_in);
-		if (tlv_len < 0 || (size_t) tlv_len > len_in)
-			return NULL;
-
-		if (index-- =3D=3D 0) {
-			*len_out =3D tlv_len;
-			return buf;
-		}
-
-		buf +=3D tlv_len;
-		len_in -=3D tlv_len;
-	}
-}
-
-/* Return an element in a DER SEQUENCE structure by path */
-static inline uint8_t *der_find_elem_by_path(uint8_t *buf, size_t len_in,
-						uint8_t tag, size_t *len_out,
-						...)
-{
-	uint8_t elem_tag;
-	int pos;
-	va_list vl;
-
-	va_start(vl, len_out);
-
-	pos =3D va_arg(vl, int);
-
-	while (pos !=3D -1) {
-		buf =3D der_find_elem(buf, len_in, pos, &elem_tag, &len_in);
-
-		pos =3D va_arg(vl, int);
-
-		if (!buf || elem_tag !=3D (pos =3D=3D -1 ? tag : ASN1_ID_SEQUENCE))
-			return NULL;
-	}
-
-	va_end(vl);
-
-	*len_out =3D len_in;
-	return buf;
-}
-
 struct tls_cert *tls_cert_load_file(const char *filename)
 {
 	uint8_t *der;
@@ -2449,11 +2360,6 @@ bool tls_cert_find_certchain(struct tls_cert *cert,
 	return true;
 }
 =

-struct asn1_oid {
-	uint8_t asn1_len;
-	uint8_t asn1[10];
-};
-
 static const struct pkcs1_encryption_oid {
 	enum tls_cert_key_type key_type;
 	struct asn1_oid oid;
@@ -2599,10 +2505,8 @@ enum tls_cert_key_type tls_cert_get_pubkey_type(stru=
ct tls_cert *cert)
 		return TLS_CERT_KEY_UNKNOWN;
 =

 	for (i =3D 0; i < (int) L_ARRAY_SIZE(pkcs1_encryption_oids); i++)
-		if (key_type_len =3D=3D pkcs1_encryption_oids[i].oid.asn1_len &&
-				!memcmp(key_type,
-					pkcs1_encryption_oids[i].oid.asn1,
-					key_type_len))
+		if (asn1_oid_eq(&pkcs1_encryption_oids[i].oid,
+					key_type_len, key_type))
 			break;
 =

 	if (i =3D=3D L_ARRAY_SIZE(pkcs1_encryption_oids))
-- =

2.11.0


--===============0150804681109281564==--

