Content-Type: multipart/mixed; boundary="===============1084340746057407005=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 1/2] tls: Move DER code to the TLS module and make static
Date: Wed, 05 Oct 2016 11:25:51 -0700
Message-ID: <20161005182552.8850-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1084340746057407005==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/cipher-private.h | 37 ------------------------------
 ell/cipher.c         | 50 -----------------------------------------
 ell/tls.c            | 63 ++++++++++++++++++++++++++++++++++++++++++++++++=
+++-
 3 files changed, 62 insertions(+), 88 deletions(-)
 delete mode 100644 ell/cipher-private.h

diff --git a/ell/cipher-private.h b/ell/cipher-private.h
deleted file mode 100644
index 77ddd06..0000000
--- a/ell/cipher-private.h
+++ /dev/null
@@ -1,37 +0,0 @@
-/*
- *
- *  Embedded Linux library
- *
- *  Copyright (C) 2015  Intel Corporation. All rights reserved.
- *
- *  This library is free software; you can redistribute it and/or
- *  modify it under the terms of the GNU Lesser General Public
- *  License as published by the Free Software Foundation; either
- *  version 2.1 of the License, or (at your option) any later version.
- *
- *  This library is distributed in the hope that it will be useful,
- *  but WITHOUT ANY WARRANTY; without even the implied warranty of
- *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- *  Lesser General Public License for more details.
- *
- *  You should have received a copy of the GNU Lesser General Public
- *  License along with this library; if not, write to the Free Software
- *  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 =
 USA
- *
- */
-
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
-uint8_t *der_find_elem(uint8_t *buf, size_t len_in, int index,
-			uint8_t *tag, size_t *len_out);
diff --git a/ell/cipher.c b/ell/cipher.c
index 0af0b4b..8312451 100644
--- a/ell/cipher.c
+++ b/ell/cipher.c
@@ -31,7 +31,6 @@
 =

 #include "util.h"
 #include "cipher.h"
-#include "cipher-private.h"
 #include "private.h"
 #include "random.h"
 =

@@ -292,52 +291,3 @@ LIB_EXPORT bool l_cipher_set_iv(struct l_cipher *ciphe=
r, const uint8_t *iv,
 =

 	return true;
 }
-
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
-uint8_t *der_find_elem(uint8_t *buf, size_t len_in, int index,
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
diff --git a/ell/tls.c b/ell/tls.c
index 9b33ffb..bc4c210 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -35,7 +35,6 @@
 #include "random.h"
 #include "pem.h"
 #include "tls-private.h"
-#include "cipher-private.h"
 #include "key.h"
 =

 void tls10_prf(const uint8_t *secret, size_t secret_len,
@@ -2310,6 +2309,19 @@ LIB_EXPORT const char *l_tls_alert_to_str(enum l_tls=
_alert_desc desc)
 =

 /* X509 Certificates and Certificate Chains */
 =

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
 #define X509_CERTIFICATE_POS			0
 #define   X509_TBSCERTIFICATE_POS		  0
 #define     X509_TBSCERT_VERSION_POS		    0
@@ -2329,6 +2341,55 @@ LIB_EXPORT const char *l_tls_alert_to_str(enum l_tls=
_alert_desc desc)
 #define   X509_SIGNATURE_ALGORITHM_POS		  1
 #define   X509_SIGNATURE_VALUE_POS		  2
 =

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
+static uint8_t *der_find_elem(uint8_t *buf, size_t len_in, int index,
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
 /* Return an element in a DER SEQUENCE structure by path */
 static inline uint8_t *der_find_elem_by_path(uint8_t *buf, size_t len_in,
 						uint8_t tag, size_t *len_out,
-- =

2.10.1


--===============1084340746057407005==--

