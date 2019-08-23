Content-Type: multipart/mixed; boundary="===============9098004736197319371=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 4/8] cert: Implement l_cert_get_extension
Date: Fri, 23 Aug 2019 02:41:34 +0200
Message-ID: <20190823004138.5480-4-andrew.zaborowski@intel.com>
In-Reply-To: <20190823004138.5480-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============9098004736197319371==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add a utility to find the contents of a given extension.  It is internal
only because asn1_oid is currently internal.
---
 ell/asn1-private.h |  1 +
 ell/cert-private.h |  6 +++++
 ell/cert.c         | 66 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 73 insertions(+)

diff --git a/ell/asn1-private.h b/ell/asn1-private.h
index 7c382ec..90c8913 100644
--- a/ell/asn1-private.h
+++ b/ell/asn1-private.h
@@ -25,6 +25,7 @@
 =

 #define ASN1_ID_SEQUENCE	ASN1_ID(ASN1_CLASS_UNIVERSAL, 1, 0x10)
 #define ASN1_ID_SET		ASN1_ID(ASN1_CLASS_UNIVERSAL, 1, 0x11)
+#define ASN1_ID_BOOLEAN		ASN1_ID(ASN1_CLASS_UNIVERSAL, 0, 0x01)
 #define ASN1_ID_INTEGER		ASN1_ID(ASN1_CLASS_UNIVERSAL, 0, 0x02)
 #define ASN1_ID_BIT_STRING	ASN1_ID(ASN1_CLASS_UNIVERSAL, 0, 0x03)
 #define ASN1_ID_OCTET_STRING	ASN1_ID(ASN1_CLASS_UNIVERSAL, 0, 0x04)
diff --git a/ell/cert-private.h b/ell/cert-private.h
index f89e216..ba9a513 100644
--- a/ell/cert-private.h
+++ b/ell/cert-private.h
@@ -20,5 +20,11 @@
  *
  */
 =

+struct asn1_oid;
+
 struct l_certchain *certchain_new_from_leaf(struct l_cert *leaf);
 void certchain_link_issuer(struct l_certchain *chain, struct l_cert *issue=
r);
+
+const uint8_t *cert_get_extension(struct l_cert *cert,
+					const struct asn1_oid *ext_id,
+					bool *out_critical, size_t *out_len);
diff --git a/ell/cert.c b/ell/cert.c
index 950e562..cf7799c 100644
--- a/ell/cert.c
+++ b/ell/cert.c
@@ -171,6 +171,72 @@ LIB_EXPORT const uint8_t *l_cert_get_dn(struct l_cert =
*cert, size_t *out_len)
 						-1);
 }
 =

+const uint8_t *cert_get_extension(struct l_cert *cert,
+					const struct asn1_oid *ext_id,
+					bool *out_critical, size_t *out_len)
+{
+	const uint8_t *ext, *end;
+	size_t ext_len;
+
+	if (unlikely(!cert))
+		return NULL;
+
+	ext =3D asn1_der_find_elem_by_path(cert->asn1, cert->asn1_len,
+						ASN1_ID_SEQUENCE, &ext_len,
+						X509_CERTIFICATE_POS,
+						X509_TBSCERTIFICATE_POS,
+						X509_TBSCERT_EXTENSIONS_POS,
+						-1);
+	if (unlikely(!ext))
+		return NULL;
+
+	end =3D ext + ext_len;
+	while (ext < end) {
+		const uint8_t *seq, *oid, *data;
+		uint8_t tag;
+		size_t len, oid_len, data_len;
+		bool critical;
+
+		seq =3D asn1_der_find_elem(ext, end - ext, 0, &tag, &len);
+		if (unlikely(!seq || tag !=3D ASN1_ID_SEQUENCE))
+			return false;
+
+		ext =3D seq + len;
+
+		oid =3D asn1_der_find_elem(seq, len, 0, &tag, &oid_len);
+		if (unlikely(!oid || tag !=3D ASN1_ID_OID))
+			return false;
+
+		if (!asn1_oid_eq(ext_id, oid_len, oid))
+			continue;
+
+		data =3D asn1_der_find_elem(seq, len, 1, &tag, &data_len);
+		critical =3D false;
+
+		if (data && tag =3D=3D ASN1_ID_BOOLEAN) {
+			if (data_len !=3D 1)
+				return false;
+
+			critical =3D *data !=3D 0;	/* Tolerate BER booleans */
+
+			data =3D asn1_der_find_elem(seq, len, 2, &tag, &data_len);
+		}
+
+		if (unlikely(!data || tag !=3D ASN1_ID_OCTET_STRING))
+			return false;
+
+		if (out_critical)
+			*out_critical =3D critical;
+
+		if (out_len)
+			*out_len =3D data_len;
+
+		return data;
+	}
+
+	return NULL;
+}
+
 LIB_EXPORT enum l_cert_key_type l_cert_get_pubkey_type(struct l_cert *cert)
 {
 	if (unlikely(!cert))
-- =

2.20.1


--===============9098004736197319371==--

