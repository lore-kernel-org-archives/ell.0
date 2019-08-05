Content-Type: multipart/mixed; boundary="===============4389058556239736465=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/2] tls: Pass full Subject DN contents to "ready" callback
Date: Tue, 06 Aug 2019 00:28:28 +0200
Message-ID: <20190805222829.14494-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4389058556239736465==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Until now the ready callback would receive a displayable string as
peer_identity (if peer was authenticated) which was either the Common
Name or the Organization Name extracted from the subject DN in the
peer's certificate.

In order to implement functionality similat to wpa_supplicant's
substring_match=3D option for EAP-TLS, we need to look specifically at
Common Name although if we have the full contents of the Subject DN
that's even better as wpa_supplicant allows configurations to match
against any element in the Subject DN, so if we do that iwd and wpa_s
config files may be easier to convert in either direction.

We could also just pass the whole certificate struct to the callback but
then we'd need to also have utilities for parsing the DN so instead we
parse it in tls.c and convert it into the same string format that is
used by wpa_s, openssl, etc.  Parsing that string in user code is easier
than parsing the original DER struct.
---
 ell/asn1-private.h |  1 +
 ell/tls.c          | 76 ++++++++++++++++++++++++++++++++--------------
 2 files changed, 55 insertions(+), 22 deletions(-)

diff --git a/ell/asn1-private.h b/ell/asn1-private.h
index 53bba4c..71a4ae6 100644
--- a/ell/asn1-private.h
+++ b/ell/asn1-private.h
@@ -30,6 +30,7 @@
 #define ASN1_ID_OID		ASN1_ID(ASN1_CLASS_UNIVERSAL, 0, 0x06)
 #define ASN1_ID_UTF8STRING	ASN1_ID(ASN1_CLASS_UNIVERSAL, 0, 0x0c)
 #define ASN1_ID_PRINTABLESTRING	ASN1_ID(ASN1_CLASS_UNIVERSAL, 0, 0x13)
+#define ASN1_ID_IA5STRING	ASN1_ID(ASN1_CLASS_UNIVERSAL, 0, 0x16)
 =

 struct asn1_oid {
 	uint8_t asn1_len;
diff --git a/ell/tls.c b/ell/tls.c
index 89db73c..ba9f613 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -44,6 +44,7 @@
 #include "asn1-private.h"
 #include "strv.h"
 #include "missing.h"
+#include "string.h"
 =

 bool tls10_prf(const void *secret, size_t secret_len,
 		const char *label,
@@ -1990,17 +1991,41 @@ static void tls_handle_certificate_verify(struct l_=
tls *tls,
 	TLS_SET_STATE(TLS_HANDSHAKE_WAIT_CHANGE_CIPHER_SPEC);
 }
 =

-static const struct asn1_oid dn_organization_name_oid =3D
-	{ 3, { 0x55, 0x04, 0x0a } };
-static const struct asn1_oid dn_common_name_oid =3D
-	{ 3, { 0x55, 0x04, 0x03 } };
+struct dn_element_info {
+	const char *str;
+	const struct asn1_oid oid;
+};
+
+static const struct dn_element_info dn_elements[] =3D {
+	{ "CN", { 3, { 0x55, 0x04, 0x03 } } },
+	{ "SN", { 3, { 0x55, 0x04, 0x04 } } },
+	{ "serialNumber", { 3, { 0x55, 0x04, 0x05 } } },
+	{ "C", { 3, { 0x55, 0x04, 0x06 } } },
+	{ "ST", { 3, { 0x55, 0x04, 0x07 } } },
+	{ "L", { 3, { 0x55, 0x04, 0x08 } } },
+	{ "street", { 3, { 0x55, 0x04, 0x09 } } },
+	{ "O", { 3, { 0x55, 0x04, 0x0a } } },
+	{ "OU", { 3, { 0x55, 0x04, 0x0b } } },
+	{ "title", { 3, { 0x55, 0x04, 0x0c } } },
+	{ "telephoneNumber", { 3, { 0x55, 0x04, 0x14 } } },
+	{ "givenName", { 3, { 0x55, 0x04, 0x2a } } },
+	{ "initials", { 3, { 0x55, 0x04, 0x2b } } },
+	{ "emailAddress", {
+		9,
+		{ 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x09, 0x01 }
+	} },
+	{ "domainComponent", {
+		10,
+		{ 0x09, 0x92, 0x26, 0x89, 0x93, 0xf2, 0x2c, 0x64, 0x01, 0x19 }
+	} },
+	{}
+};
 =

 static char *tls_get_peer_identity_str(struct l_cert *cert)
 {
 	const uint8_t *dn, *end;
 	size_t dn_size;
-	const uint8_t *printable_str =3D NULL;
-	size_t printable_str_len;
+	struct l_string *id_str;
 =

 	if (!cert)
 		return NULL;
@@ -2009,45 +2034,52 @@ static char *tls_get_peer_identity_str(struct l_cer=
t *cert)
 	if (!dn)
 		return NULL;
 =

+	id_str =3D l_string_new(200);
+
 	end =3D dn + dn_size;
 	while (dn < end) {
 		const uint8_t *set, *seq, *oid, *name;
 		uint8_t tag;
 		size_t len, oid_len, name_len;
+		const struct dn_element_info *info;
 =

 		set =3D asn1_der_find_elem(dn, end - dn, 0, &tag, &len);
 		if (!set || tag !=3D ASN1_ID_SET)
-			return NULL;
+			goto error;
 =

 		dn =3D set + len;
 =

 		seq =3D asn1_der_find_elem(set, len, 0, &tag, &len);
 		if (!seq || tag !=3D ASN1_ID_SEQUENCE)
-			return NULL;
+			goto error;
 =

 		oid =3D asn1_der_find_elem(seq, len, 0, &tag, &oid_len);
 		if (!oid || tag !=3D ASN1_ID_OID)
-			return NULL;
+			goto error;
 =

 		name =3D asn1_der_find_elem(seq, len, 1, &tag, &name_len);
 		if (!oid || (tag !=3D ASN1_ID_PRINTABLESTRING &&
-					tag !=3D ASN1_ID_UTF8STRING))
+					tag !=3D ASN1_ID_UTF8STRING &&
+					tag !=3D ASN1_ID_IA5STRING))
 			continue;
 =

-		/* organizationName takes priority, commonName is second */
-		if (asn1_oid_eq(&dn_organization_name_oid, oid_len, oid) ||
-				(!printable_str &&
-				 asn1_oid_eq(&dn_common_name_oid,
-						oid_len, oid))) {
-			printable_str =3D name;
-			printable_str_len =3D name_len;
-		}
+		for (info =3D dn_elements; info->str; info++)
+			if (asn1_oid_eq(&info->oid, oid_len, oid))
+				break;
+		if (!info->str)
+			continue;
+
+		l_string_append_c(id_str, '/');
+		l_string_append(id_str, info->str);
+		l_string_append_c(id_str, '=3D');
+		l_string_append_fixed(id_str, (char *) name, name_len);
 	}
 =

-	if (printable_str)
-		return l_strndup((char *) printable_str, printable_str_len);
-	else
-		return NULL;
+	return l_string_unwrap(id_str);
+
+error:
+	l_string_free(id_str);
+	return NULL;
 }
 =

 static void tls_finished(struct l_tls *tls)
-- =

2.20.1


--===============4389058556239736465==--

