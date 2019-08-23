Content-Type: multipart/mixed; boundary="===============6993113689471138768=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 3/8] asn1-private: Handle Context-specific tag class
Date: Fri, 23 Aug 2019 02:41:33 +0200
Message-ID: <20190823004138.5480-3-andrew.zaborowski@intel.com>
In-Reply-To: <20190823004138.5480-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6993113689471138768==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

In asn1_der_find_elem(_by_path) add a way to properly handle the
optional elements in x509 certificates.  Until now we were lucky we
never needed to handle the parts of certificates where some
OPTIONAL/DEFAULT element was absent (such as Version in
v1 certificates) but we would be misparsing the certificates in
those cases.

In the general case an asn1 parser will need the full syntax
definition to locate an element inside the structure.  To avoid adding
a lot of .asn1 files like those contained in the kernel, and a parser
compiler, assume that OPTIONAL/DEFAULT elements use Context-specific
tags which is mostly the case in the x509 syntax (this is evens noted
in ftp://ftp.rsasecurity.com/pub/pkcs/ascii/layman.asc).  This way we
can handle Univeral tags that are always present and optional elements
that use Context-specific tags and get by with the same few #defines
we had regarding the x509 structure.
---
 ell/asn1-private.h | 74 ++++++++++++++++++++++++++++++++++++++--------
 ell/cert.c         | 20 ++++++-------
 2 files changed, 72 insertions(+), 22 deletions(-)

diff --git a/ell/asn1-private.h b/ell/asn1-private.h
index 71a4ae6..7c382ec 100644
--- a/ell/asn1-private.h
+++ b/ell/asn1-private.h
@@ -21,6 +21,7 @@
 #define ASN1_ID(class, pc, tag)	(((class) << 6) | ((pc) << 5) | (tag))
 =

 #define ASN1_CLASS_UNIVERSAL	0
+#define ASN1_CLASS_CONTEXT	2
 =

 #define ASN1_ID_SEQUENCE	ASN1_ID(ASN1_CLASS_UNIVERSAL, 1, 0x10)
 #define ASN1_ID_SET		ASN1_ID(ASN1_CLASS_UNIVERSAL, 1, 0x11)
@@ -89,14 +90,24 @@ static inline void asn1_write_definite_length(uint8_t *=
*buf, size_t len)
 		*(*buf)++ =3D len >> (n * 8);
 }
 =

-/* Return index'th element in a DER SEQUENCE */
+#define ASN1_CONTEXT_IMPLICIT(tag) (0x1000 | (tag))
+#define ASN1_CONTEXT_EXPLICIT(tag) (0x2000 | (tag))
+
+/*
+ * Return the tag, length and value of the @index'th
+ * non-context-specific-tagged element in a DER SEQUENCE or one who's
+ * ASN1_CONTEXT_IMPLICIT(tag) matches @index or the inner element of
+ * the one who's ASN1_CONTEXT_EXPLICIT(tag) matches @index.
+ */
 static inline const uint8_t *asn1_der_find_elem(const uint8_t *buf,
 						size_t len_in, int index,
 						uint8_t *tag, size_t *len_out)
 {
-	int tlv_len;
+	int n =3D 0;
 =

 	while (1) {
+		int tlv_len;
+
 		if (len_in < 2)
 			return NULL;
 =

@@ -107,9 +118,36 @@ static inline const uint8_t *asn1_der_find_elem(const =
uint8_t *buf,
 		if (tlv_len < 0 || (size_t) tlv_len > len_in)
 			return NULL;
 =

-		if (index-- =3D=3D 0) {
-			*len_out =3D tlv_len;
-			return buf;
+		if (*tag >> 6 !=3D ASN1_CLASS_CONTEXT) {
+			if (n++ =3D=3D index) {
+				*len_out =3D tlv_len;
+				return buf;
+			}
+		} else if ((*tag & 0x1f) =3D=3D (index & 0xfff)) {
+			/* Context-specific tag */
+			if (index & 0x1000) {		/* Implicit */
+				*len_out =3D tlv_len;
+				return buf;
+			} else if (index & 0x2000) {	/* Explicit */
+				const uint8_t *outer =3D buf;
+				int inner_len;
+
+				if (!(*tag & 0x20))	/* Primitive */
+					return NULL;
+
+				if (unlikely(tlv_len < 2))
+					return NULL;
+
+				*tag =3D *buf++;
+
+				inner_len =3D asn1_parse_definite_length(
+							(void *) &buf, &len_in);
+				if (outer + tlv_len !=3D buf + inner_len)
+					return NULL;
+
+				*len_out =3D inner_len;
+				return buf;
+			}
 		}
 =

 		buf +=3D tlv_len;
@@ -122,20 +160,32 @@ static inline const uint8_t *asn1_der_find_elem_by_pa=
th(const uint8_t *buf,
 						size_t len_in, uint8_t tag,
 						size_t *len_out, ...)
 {
-	uint8_t elem_tag;
-	int pos;
+	int index;
 	va_list vl;
 =

 	va_start(vl, len_out);
 =

-	pos =3D va_arg(vl, int);
+	index =3D va_arg(vl, int);
+
+	while (index !=3D -1) {
+		uint8_t elem_tag;
+		uint8_t expect_tag;
+		int prev_index =3D index;
+
+		buf =3D asn1_der_find_elem(buf, len_in, index,
+						&elem_tag, &len_in);
 =

-	while (pos !=3D -1) {
-		buf =3D asn1_der_find_elem(buf, len_in, pos, &elem_tag, &len_in);
+		index =3D va_arg(vl, int);
 =

-		pos =3D va_arg(vl, int);
+		if (prev_index & 0x1000)
+			expect_tag =3D ASN1_ID(ASN1_CLASS_CONTEXT,
+						index !=3D -1 ? 1 :
+						((elem_tag >> 5) & 1),
+						prev_index & 0xfff);
+		else
+			expect_tag =3D (index =3D=3D -1) ? tag : ASN1_ID_SEQUENCE;
 =

-		if (!buf || elem_tag !=3D (pos =3D=3D -1 ? tag : ASN1_ID_SEQUENCE)) {
+		if (!buf || elem_tag !=3D expect_tag) {
 			va_end(vl);
 			return NULL;
 		}
diff --git a/ell/cert.c b/ell/cert.c
index d52bfd0..950e562 100644
--- a/ell/cert.c
+++ b/ell/cert.c
@@ -34,20 +34,20 @@
 =

 #define X509_CERTIFICATE_POS			0
 #define   X509_TBSCERTIFICATE_POS		  0
-#define     X509_TBSCERT_VERSION_POS		    0
-#define     X509_TBSCERT_SERIAL_POS		    1
-#define     X509_TBSCERT_SIGNATURE_POS		    2
+#define     X509_TBSCERT_VERSION_POS		    ASN1_CONTEXT_EXPLICIT(0)
+#define     X509_TBSCERT_SERIAL_POS		    0
+#define     X509_TBSCERT_SIGNATURE_POS		    1
 #define       X509_ALGORITHM_ID_ALGORITHM_POS	      0
 #define       X509_ALGORITHM_ID_PARAMS_POS	      1
-#define     X509_TBSCERT_ISSUER_DN_POS		    3
-#define     X509_TBSCERT_VALIDITY_POS		    4
-#define     X509_TBSCERT_SUBJECT_DN_POS		    5
-#define     X509_TBSCERT_SUBJECT_KEY_POS	    6
+#define     X509_TBSCERT_ISSUER_DN_POS		    2
+#define     X509_TBSCERT_VALIDITY_POS		    3
+#define     X509_TBSCERT_SUBJECT_DN_POS		    4
+#define     X509_TBSCERT_SUBJECT_KEY_POS	    5
 #define       X509_SUBJECT_KEY_ALGORITHM_POS	      0
 #define       X509_SUBJECT_KEY_VALUE_POS	      1
-#define     X509_TBSCERT_ISSUER_UID_POS		    7
-#define     X509_TBSCERT_SUBJECT_UID_POS	    8
-#define     X509_TBSCERT_EXTENSIONS_POS		    9
+#define     X509_TBSCERT_ISSUER_UID_POS		    ASN1_CONTEXT_IMPLICIT(1)
+#define     X509_TBSCERT_SUBJECT_UID_POS	    ASN1_CONTEXT_IMPLICIT(2)
+#define     X509_TBSCERT_EXTENSIONS_POS		    ASN1_CONTEXT_EXPLICIT(3)
 #define   X509_SIGNATURE_ALGORITHM_POS		  1
 #define   X509_SIGNATURE_VALUE_POS		  2
 =

-- =

2.20.1


--===============6993113689471138768==--

