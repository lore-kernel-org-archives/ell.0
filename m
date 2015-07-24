Content-Type: multipart/mixed; boundary="===============8841175917167571220=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 05/17] Add ASN.1 BER / DER decoding utilities as asn1-private.h
Date: Fri, 24 Jul 2015 05:26:46 +0200
Message-ID: <1437708410-28075-5-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1437708410-28075-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8841175917167571220==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This is a minimal set of utilities to allow parsing digital
certificate and RSA encryption related structures.  They work on
simple uint8_t arrays.  The same operations could be implemented
on top of a cleaner iterator-based API once that is added but since
the required operations are so simple adding that API to ell
didn't seem justified at this point.
One property of the structures used in X509 certificates is that
they use many levels of nested SEQUENCE and SET substructures, hence
the find_der_elem_by_path utility.
---
 Makefile.am        |   3 +-
 ell/asn1-private.h | 126 +++++++++++++++++++++++++++++++++++++++++++++++++=
++++
 2 files changed, 128 insertions(+), 1 deletion(-)
 create mode 100644 ell/asn1-private.h

diff --git a/Makefile.am b/Makefile.am
index 0861cec..fb2a35c 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -75,7 +75,8 @@ ell_libell_la_SOURCES =3D $(linux_headers) \
 			ell/hwdb.c \
 			ell/cipher.c \
 			ell/random.c \
-			ell/uintset.c
+			ell/uintset.c \
+			ell/asn1-private.h
 =

 ell_libell_la_LDFLAGS =3D -no-undefined \
 			-version-info $(ELL_CURRENT):$(ELL_REVISION):$(ELL_AGE)
diff --git a/ell/asn1-private.h b/ell/asn1-private.h
new file mode 100644
index 0000000..e439fd7
--- /dev/null
+++ b/ell/asn1-private.h
@@ -0,0 +1,126 @@
+/*
+ *  Embedded Linux library
+ *
+ *  Copyright (C) 2011-2014  Intel Corporation. All rights reserved.
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
+static inline void write_asn1_definite_length(uint8_t **buf, size_t len)
+{
+	int n;
+
+	if (len < 0x80) {
+		*(*buf)++ =3D len;
+
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
+/* Return index'th element in a DER SEQUENCE */
+static inline uint8_t *der_find_elem(uint8_t *buf, size_t len_in, int inde=
x,
+					uint8_t *tag, size_t *len_out)
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
-- =

2.1.4


--===============8841175917167571220==--

