Content-Type: multipart/mixed; boundary="===============4104253662361311400=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/4] tls: Print only one tls_cert_domains_match_mask debug msg
Date: Thu, 17 Dec 2020 02:32:22 +0100
Message-ID: <20201217013225.821303-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4104253662361311400==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Change tls_cert_domains_match_mask to compile one error message string
instead of printing messages at different step.  The rest of the TLS debug
log tries to be concise when there's no errors so try to be concise here
too.
---
This is the tls_cert_domains_match_mask version I had in my tree and
thought I might just send it.

 ell/tls.c | 71 +++++++++++++++++++++++++++++++++++--------------------
 1 file changed, 45 insertions(+), 26 deletions(-)

diff --git a/ell/tls.c b/ell/tls.c
index 5bf6573..1452909 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -679,8 +679,8 @@ static const struct asn1_oid dn_common_name_oid =3D
 =

 #define SAN_DNS_NAME_ID ASN1_CONTEXT_IMPLICIT(2)
 =

-static bool tls_cert_domains_match_mask(struct l_tls *tls, struct l_cert *=
cert,
-						char **mask)
+static bool tls_cert_domains_match_mask(struct l_cert *cert, char **mask,
+					char **error_msg)
 {
 	const uint8_t *san, *dn, *end;
 	size_t san_len, dn_len;
@@ -688,7 +688,8 @@ static bool tls_cert_domains_match_mask(struct l_tls *t=
ls, struct l_cert *cert,
 	const char *cn =3D NULL;
 	size_t cn_len;
 	char **i;
-	bool dns_name_present =3D false;
+	struct l_string *dns_names =3D NULL;
+	int dns_name_count =3D 0;
 =

 	/*
 	 * Locate SubjectAltName (RFC5280 Section 4.2.1.6) and descend into
@@ -698,7 +699,7 @@ static bool tls_cert_domains_match_mask(struct l_tls *t=
ls, struct l_cert *cert,
 	if (san) {
 		san =3D asn1_der_find_elem(san, san_len, 0, &san_tag, &san_len);
 		if (unlikely(!san || san_tag !=3D ASN1_ID_SEQUENCE))
-			return false;
+			goto parse_error;
 =

 		end =3D san + san_len;
 		while (san < end) {
@@ -714,18 +715,26 @@ static bool tls_cert_domains_match_mask(struct l_tls =
*tls, struct l_cert *cert,
 =

 			/* Type is implicitly IA5STRING */
 =

-			for (i =3D mask; *i; i++) {
-				TLS_DEBUG("Trying to match DNSName: '%.*s'"
-						" against mask: '%s'",
-						(int) len, value, *i);
-
+			for (i =3D mask; *i; i++)
 				if (tls_domain_match_mask((const char *) value,
-							len, *i, strlen(*i)))
+							len, *i, strlen(*i))) {
+					l_string_free(dns_names);
 					return true;
+				}
+
+			if (!dns_names) {
+				dns_names =3D l_string_new(128);
+				l_string_append(dns_names, "tried DNSName(s) ");
+				l_string_append_fixed(dns_names,
+							(char *) value, len);
+			} else if (dns_name_count < 20) {
+				l_string_append(dns_names, ", ");
+				l_string_append_fixed(dns_names,
+							(char *) value, len);
 			}
 =

 			san =3D value + len;
-			dns_name_present =3D true;
+			dns_name_count++;
 		}
 	}
 =

@@ -744,12 +753,17 @@ static bool tls_cert_domains_match_mask(struct l_tls =
*tls, struct l_cert *cert,
 	 * SubjectName. If neither of these conditions holds, then
 	 * verification fails."
 	 */
-	if (unlikely(dns_name_present))
-		return false;
+	if (dns_name_count) {
+		if (dns_name_count > 20)
+			l_string_append_printf(dns_names, " and %i other",
+						dns_name_count - 20);
+
+		*error_msg =3D l_string_unwrap(dns_names);
+	}
 =

 	dn =3D l_cert_get_dn(cert, &dn_len);
 	if (unlikely(!dn))
-		return false;
+		goto parse_error;
 =

 	end =3D dn + dn_len;
 	while (dn < end) {
@@ -759,17 +773,17 @@ static bool tls_cert_domains_match_mask(struct l_tls =
*tls, struct l_cert *cert,
 =

 		set =3D asn1_der_find_elem(dn, end - dn, 0, &tag, &len);
 		if (unlikely(!set || tag !=3D ASN1_ID_SET))
-			return false;
+			goto parse_error;
 =

 		dn =3D set + len;
 =

 		seq =3D asn1_der_find_elem(set, len, 0, &tag, &len);
 		if (unlikely(!seq || tag !=3D ASN1_ID_SEQUENCE))
-			return false;
+			goto parse_error;
 =

 		oid =3D asn1_der_find_elem(seq, len, 0, &tag, &oid_len);
 		if (unlikely(!oid || tag !=3D ASN1_ID_OID))
-			return false;
+			goto parse_error;
 =

 		name =3D asn1_der_find_elem(seq, len, 1, &tag, &name_len);
 		if (unlikely(!name || (tag !=3D ASN1_ID_PRINTABLESTRING &&
@@ -785,15 +799,17 @@ static bool tls_cert_domains_match_mask(struct l_tls =
*tls, struct l_cert *cert,
 	}
 =

 	if (unlikely(!cn))
-		return false;
-
-	for (i =3D mask; *i; i++) {
-		TLS_DEBUG("Trying to match CN: '%.*s' against mask: '%s'",
-				(int) cn_len, cn, *i);
+		goto parse_error;
 =

+	for (i =3D mask; *i; i++)
 		if (tls_domain_match_mask(cn, cn_len, *i, strlen(*i)))
 			return true;
-	}
+
+	*error_msg =3D l_strdup_printf("tried CommonName %.*s", (int) cn_len, cn);
+	return false;
+
+parse_error:
+	*error_msg =3D l_strdup("couldn't locate DNSName or CommonName");
 =

 	return false;
 }
@@ -1886,6 +1902,7 @@ static void tls_handle_certificate(struct l_tls *tls,
 	const uint8_t *der;
 	bool dummy;
 	const char *error_str;
+	char *subject_str;
 =

 	if (len < 3)
 		goto decode_error;
@@ -1955,14 +1972,16 @@ static void tls_handle_certificate(struct l_tls *tl=
s,
 		goto done;
 	}
 =

-	if (tls->subject_mask && !tls_cert_domains_match_mask(tls, leaf,
-							tls->subject_mask)) {
+	if (tls->subject_mask && !tls_cert_domains_match_mask(leaf,
+							tls->subject_mask,
+							&subject_str)) {
 		char *mask =3D l_strjoinv(tls->subject_mask, '|');
 =

 		TLS_DISCONNECT(TLS_ALERT_BAD_CERT, 0,
 				"Peer certificate's subject domain "
-				"doesn't match %s", mask);
+				"doesn't match mask %s: %s", mask, subject_str);
 		l_free(mask);
+		l_free(subject_str);
 =

 		goto done;
 	}
-- =

2.27.0

--===============4104253662361311400==--

