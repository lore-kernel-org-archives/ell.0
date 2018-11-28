Content-Type: multipart/mixed; boundary="===============4626238603132841707=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 4/9] tls: Pass the verified peer identity to "ready" callback
Date: Wed, 28 Nov 2018 03:38:30 +0100
Message-ID: <20181128023835.2081-4-andrew.zaborowski@intel.com>
In-Reply-To: <20181128023835.2081-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4626238603132841707==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Extract a human-readable peer identity string from the supplied
certificate and pass it to the ready callback provided by API user to
indicate that the peer has actually been authenticated.  For some users
it will only really matter whether the value is non-NULL meaning that
the peer is trusted by the locally configured CA, while for others,
such as web browsers it's useful to display a human-readable peer
identity to the user so they can see if a website is served by who they
think it belongs to.  If we got a peer certificate but user supplied no
CAs or peer couldn't be authenticated, don't bother to extract the
identity string and pass NULL.

Until now we'd always pass NULL (there was a TODO comment) because
we'd hoped we could at some point leverage the kernel's certificate
parser to extract the subject name.  The newly added
tls_get_peer_identity_str might also fit in cert.c instead of tls.c.
---
 ell/tls.c | 70 ++++++++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 67 insertions(+), 3 deletions(-)

diff --git a/ell/tls.c b/ell/tls.c
index cfdcdfa..b13f551 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -2151,10 +2151,76 @@ static void tls_handle_certificate_verify(struct l_=
tls *tls,
 	TLS_SET_STATE(TLS_HANDSHAKE_WAIT_CHANGE_CIPHER_SPEC);
 }
 =

+static const struct asn1_oid dn_organization_name_oid =3D
+	{ 3, { 0x55, 0x04, 0x0a } };
+static const struct asn1_oid dn_common_name_oid =3D
+	{ 3, { 0x55, 0x04, 0x03 } };
+
+static char *tls_get_peer_identity_str(struct l_cert *cert)
+{
+	const uint8_t *dn, *end;
+	size_t dn_size;
+	const uint8_t *printable_str =3D NULL;
+	size_t printable_str_len;
+
+	if (!cert)
+		return NULL;
+
+	dn =3D l_cert_get_dn(cert, &dn_size);
+	if (!dn)
+		return NULL;
+
+	end =3D dn + dn_size;
+	while (dn < end) {
+		const uint8_t *set, *seq, *oid, *name;
+		uint8_t tag;
+		size_t len, oid_len, name_len;
+
+		set =3D asn1_der_find_elem(dn, end - dn, 0, &tag, &len);
+		if (!set || tag !=3D ASN1_ID_SET)
+			return NULL;
+
+		dn =3D set + len;
+
+		seq =3D asn1_der_find_elem(set, len, 0, &tag, &len);
+		if (!seq || tag !=3D ASN1_ID_SEQUENCE)
+			return NULL;
+
+		oid =3D asn1_der_find_elem(seq, len, 0, &tag, &oid_len);
+		if (!oid || tag !=3D ASN1_ID_OID)
+			return NULL;
+
+		name =3D asn1_der_find_elem(seq, len, 1, &tag, &name_len);
+		if (!oid || (tag !=3D ASN1_ID_PRINTABLESTRING &&
+					tag !=3D ASN1_ID_UTF8STRING))
+			continue;
+
+		/* organizationName takes priority, commonName is second */
+		if (asn1_oid_eq(&dn_organization_name_oid, oid_len, oid) ||
+				(!printable_str &&
+				 asn1_oid_eq(&dn_common_name_oid,
+						oid_len, oid))) {
+			printable_str =3D name;
+			printable_str_len =3D name_len;
+		}
+	}
+
+	if (printable_str)
+		return l_strndup((char *) printable_str, printable_str_len);
+	else
+		return NULL;
+}
+
 static void tls_finished(struct l_tls *tls)
 {
 	char *peer_identity =3D NULL;
 =

+	if (tls->peer_authenticated) {
+		peer_identity =3D tls_get_peer_identity_str(tls->peer_cert);
+		if (!peer_identity)
+			TLS_DEBUG("tls_get_peer_identity_str failed");
+	}
+
 	/* Free up the resources used in the handshake */
 	tls_reset_handshake(tls);
 =

@@ -2162,11 +2228,9 @@ static void tls_finished(struct l_tls *tls)
 	tls->ready =3D true;
 =

 	tls->ready_handle(peer_identity, tls->user_data);
+	l_free(peer_identity);
 =

 	tls_cleanup_handshake(tls);
-
-	if (peer_identity)
-		l_free(peer_identity);
 }
 =

 static void tls_handle_handshake(struct l_tls *tls, int type,
-- =

2.19.1


--===============4626238603132841707==--

