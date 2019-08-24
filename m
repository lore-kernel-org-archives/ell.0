Content-Type: multipart/mixed; boundary="===============8433022996763910716=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/2] tls: Validate peer certificate's DNSNames against mask
Date: Sat, 24 Aug 2019 02:47:30 +0200
Message-ID: <20190824004731.24274-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8433022996763910716==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Also return success in the domain_mask check if any of the DNSNames in
the peer certificate's subjectAltName extension matches any of the mask
strings supplied.
---
 ell/tls.c | 70 ++++++++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 62 insertions(+), 8 deletions(-)

diff --git a/ell/tls.c b/ell/tls.c
index cbcdfa4..d0e2a66 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -673,26 +673,80 @@ ok_next:
 	}
 }
 =

+static const struct asn1_oid subject_alt_name_oid =3D
+	{ 3, { 0x55, 0x1d, 0x11 } };
 static const struct asn1_oid dn_common_name_oid =3D
 	{ 3, { 0x55, 0x04, 0x03 } };
 =

+#define SAN_DNS_NAME_ID ASN1_CONTEXT_IMPLICIT(2)
+
 static bool tls_cert_domains_match_mask(struct l_cert *cert, char **mask)
 {
-	const uint8_t *dn, *end;
-	size_t dn_size;
+	const uint8_t *san, *dn, *end;
+	size_t san_len, dn_len;
+	uint8_t san_tag;
 	const char *cn =3D NULL;
 	size_t cn_len;
+	char **i;
+	bool dns_name_present =3D false;
+
+	/*
+	 * Locate SubjectAltName (RFC5280 Section 4.2.1.6) and descend into
+	 * the sole SEQUENCE element, check if any DNSName matches.
+	 */
+	san =3D cert_get_extension(cert, &subject_alt_name_oid, NULL, &san_len);
+	if (san) {
+		san =3D asn1_der_find_elem(san, san_len, 0, &san_tag, &san_len);
+		if (unlikely(!san || san_tag !=3D ASN1_ID_SEQUENCE))
+			return false;
+
+		end =3D san + san_len;
+		while (san < end) {
+			const uint8_t *value;
+			uint8_t tag;
+			size_t len;
+
+			value =3D asn1_der_find_elem(san, end - san,
+							SAN_DNS_NAME_ID,
+							&tag, &len);
+			if (!value)
+				break;
+
+			/* Type is implicitly IA5STRING */
+
+			for (i =3D mask; *i; i++)
+				if (tls_domain_match_mask((const char *) value,
+							len, *i, strlen(*i)))
+					return true;
+
+			san =3D value + len;
+			dns_name_present =3D true;
+		}
+	}
 =

 	/*
 	 * Retrieve the Common Name from the Subject DN and check if it
-	 * matches.  TODO: possibly also look at SubjectAltName.
+	 * matches.
+	 *
+	 * We look at the Common Name only if no DNSNames were present in
+	 * the certificate, following Wi-Fi Alliance's Hotspot 2.0
+	 * Specification v3.1 section 7.3.3.2 step 2:
+	 * "Verify in the AAA server certificate that the domain name from
+	 * the FQDN [...] is a suffix match of the domain name in@least
+	 * one of the DNSName SubjectAltName extensions. If a SubjectAltName
+	 * of type DNSName is not present, then the domain name from the
+	 * FQDN shall be a suffix match to the CommonName portion of the
+	 * SubjectName. If neither of these conditions holds, then
+	 * verification fails."
 	 */
+	if (unlikely(dns_name_present))
+		return false;
 =

-	dn =3D l_cert_get_dn(cert, &dn_size);
+	dn =3D l_cert_get_dn(cert, &dn_len);
 	if (unlikely(!dn))
 		return false;
 =

-	end =3D dn + dn_size;
+	end =3D dn + dn_len;
 	while (dn < end) {
 		const uint8_t *set, *seq, *oid, *name;
 		uint8_t tag;
@@ -725,11 +779,11 @@ static bool tls_cert_domains_match_mask(struct l_cert=
 *cert, char **mask)
 		}
 	}
 =

-	if (!cn)
+	if (unlikely(!cn))
 		return false;
 =

-	for (; *mask; mask++)
-		if (tls_domain_match_mask(cn, cn_len, *mask, strlen(*mask)))
+	for (i =3D mask; *i; i++)
+		if (tls_domain_match_mask(cn, cn_len, *i, strlen(*i)))
 			return true;
 =

 	return false;
-- =

2.20.1


--===============8433022996763910716==--

