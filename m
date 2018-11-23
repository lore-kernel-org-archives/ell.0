Content-Type: multipart/mixed; boundary="===============0390876384187758128=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/5] cert: Rewrite l_certchain_verify non-recursively
Date: Fri, 23 Nov 2018 10:44:26 +0100
Message-ID: <20181123094429.7190-2-andrew.zaborowski@intel.com>
In-Reply-To: <20181123094429.7190-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0390876384187758128==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Rewrite l_certchain_verify iterating over the certificates from root to
leaf using the double-linked list property and without using recursion to
simplify the logic.  At the same time make sure that while we link new
certificates to the keyring we also unlink the old ones, those that have
been used to verify previous certificates.   This should fix a long
standing issue where we didn't verify that each certificate in the chain
was trusted specifically by the immediately preceding one, only that it
was trusted by any CA whose certificate was already linked to keyring.
---
 ell/cert.c | 207 ++++++++++++++++++++++++++++++-----------------------
 1 file changed, 117 insertions(+), 90 deletions(-)

diff --git a/ell/cert.c b/ell/cert.c
index c1f4cc5..66433c2 100644
--- a/ell/cert.c
+++ b/ell/cert.c
@@ -306,84 +306,71 @@ LIB_EXPORT bool l_certchain_find(struct l_certchain *=
chain,
 	return false;
 }
 =

-static void cert_key_cleanup(struct l_key **p)
+static struct l_keyring *cert_set_to_keyring(struct l_queue *certs)
 {
-	l_key_free_norevoke(*p);
-}
+	struct l_keyring *ring;
+	const struct l_queue_entry *entry;
 =

-static bool certchain_verify_with_keyring(struct l_cert *cert,
-						struct l_keyring *ring,
-						struct l_queue *roots,
-						struct l_keyring *trusted)
-{
-	if (!cert)
-		return true;
+	ring =3D l_keyring_new();
+	if (!ring)
+		return NULL;
 =

-	if (cert->pubkey_type !=3D L_CERT_KEY_RSA)
-		return false;
+	for (entry =3D l_queue_get_entries(certs); entry; entry =3D entry->next) {
+		struct l_cert *cert =3D entry->data;
+		struct l_key *key =3D l_cert_get_pubkey(cert);
 =

-	/*
-	 * RFC5246 7.4.2:
-	 * "Because certificate validation requires that root keys be
-	 * distributed independently, the self-signed certificate that
-	 * specifies the root certificate authority MAY be omitted from
-	 * the chain, under the assumption that the remote end must
-	 * already possess it in order to validate it in any case."
-	 *
-	 * This is an optimization to skip adding the root cert if
-	 * it's already in the trusted keyring.  It also happens to
-	 * work around a kernel issue preventing self-signed certificates
-	 * missing the AKID extension from being linked.
-	 *
-	 * If 'roots' were supplied we assume the keyring is already
-	 * restricted.
-	 */
-	if (!cert->issuer && roots) {
-		const struct l_queue_entry *entry;
-
-		for (entry =3D l_queue_get_entries(roots); entry;
-				entry =3D entry->next) {
-			struct l_cert *root =3D entry->data;
+		if (!key)
+			goto cleanup;
 =

-			if (cert->asn1_len =3D=3D root->asn1_len &&
-					!memcmp(cert->asn1, root->asn1,
-						root->asn1_len))
-				return true;
+		if (!l_keyring_link(ring, key)) {
+			l_key_free(key);
+			goto cleanup;
 		}
+
+		l_key_free_norevoke(key);
 	}
 =

-	if (certchain_verify_with_keyring(cert->issuer, ring, roots, trusted)) {
-		L_AUTO_CLEANUP_VAR(struct l_key *, key, cert_key_cleanup);
+	return ring;
 =

-		key =3D l_key_new(L_KEY_RSA, cert->asn1, cert->asn1_len);
-		if (!key)
-			return false;
+cleanup:
+	l_keyring_free(ring);
+	return NULL;
+}
 =

-		if (!l_keyring_link(ring, key))
-			return false;
+static bool cert_is_in_set(struct l_cert *cert, struct l_queue *set)
+{
+	const struct l_queue_entry *entry;
+
+	for (entry =3D l_queue_get_entries(set); entry; entry =3D entry->next) {
+		struct l_cert *cert2 =3D entry->data;
 =

-		if (trusted || cert->issuer)
+		if (cert =3D=3D cert2)
 			return true;
 =

-		/*
-		 * If execution reaches this point, it's known that:
-		 *  * No trusted root key was supplied, so the chain is only
-		 *    being checked against its own root
-		 *  * The keyring 'ring' is not restricted yet
-		 *  * The chain's root cert was just linked in to the
-		 *    previously empty keyring 'ring'.
-		 *
-		 * By restricting 'ring' now, the rest of the certs in
-		 * the chain will have their signature validated using 'key'
-		 * as the root.
-		 */
-		return l_keyring_restrict(ring,	L_KEYRING_RESTRICT_ASYM_CHAIN,
-						trusted);
+		if (cert->asn1_len =3D=3D cert2->asn1_len &&
+				!memcmp(cert->asn1, cert2->asn1,
+					cert->asn1_len))
+			return true;
 	}
 =

 	return false;
 }
 =

+static struct l_key *cert_try_link(struct l_cert *cert, struct l_keyring *=
ring)
+{
+	struct l_key *key;
+
+	key =3D l_key_new(L_KEY_RSA, cert->asn1, cert->asn1_len);
+	if (!key)
+		return NULL;
+
+	if (l_keyring_link(ring, key))
+		return key;
+
+	l_key_free(key);
+	return NULL;
+}
+
 static void cert_keyring_cleanup(struct l_keyring **p)
 {
 	l_keyring_free(*p);
@@ -392,10 +379,11 @@ static void cert_keyring_cleanup(struct l_keyring **p)
 LIB_EXPORT bool l_certchain_verify(struct l_certchain *chain,
 					struct l_queue *ca_certs)
 {
-	L_AUTO_CLEANUP_VAR(struct l_keyring *, ca_ring,
-				cert_keyring_cleanup) =3D NULL;
+	struct l_keyring *ca_ring =3D NULL;
 	L_AUTO_CLEANUP_VAR(struct l_keyring *, verify_ring,
 				cert_keyring_cleanup) =3D NULL;
+	struct l_cert *cert;
+	struct l_key *prev_key =3D NULL;
 =

 	if (unlikely(!chain || !chain->leaf))
 		return false;
@@ -404,44 +392,83 @@ LIB_EXPORT bool l_certchain_verify(struct l_certchain=
 *chain,
 	if (!verify_ring)
 		return false;
 =

+	cert =3D chain->ca;
+
 	/*
-	 * If CA cert(s) were supplied, restrict verify_ring now so
-	 * everything else in certchain is validated against the CA(s).
-	 * Otherwise, verify_ring will be restricted after the root of
-	 * certchain is added to verify_ring by
-	 * certchain_verify_with_keyring().
+	 * For TLS compatibility the trusted root CA certificate is
+	 * optionally present in the chain.
+	 *
+	 * RFC5246 7.4.2:
+	 * "Because certificate validation requires that root keys be
+	 * distributed independently, the self-signed certificate that
+	 * specifies the root certificate authority MAY be omitted from
+	 * the chain, under the assumption that the remote end must
+	 * already possess it in order to validate it in any case."
+	 *
+	 * The following is an optimization to skip verifying the root
+	 * cert in the chain if it is identical to one of the trusted CA
+	 * certificates.  It also happens to work around a kernel issue
+	 * preventing self-signed certificates missing the AKID
+	 * extension from being linked to a keyring.
 	 */
-	if (ca_certs) {
-		const struct l_queue_entry *entry;
+	if (cert_is_in_set(cert, ca_certs)) {
+		cert =3D cert->issued;
+		if (!cert)
+			return true;
 =

-		ca_ring =3D l_keyring_new();
+		prev_key =3D cert_try_link(cert, verify_ring);
+	} else if (ca_certs) {
+		ca_ring =3D cert_set_to_keyring(ca_certs);
 		if (!ca_ring)
 			return false;
 =

-		for (entry =3D l_queue_get_entries(ca_certs); entry;
-				entry =3D entry->next) {
-			struct l_cert *ca =3D entry->data;
-			struct l_key *ca_key;
+		if (!l_keyring_link_nested(verify_ring, ca_ring)) {
+			l_keyring_free(ca_ring);
+			return false;
+		}
+	} else
+		prev_key =3D cert_try_link(cert, verify_ring);
+
+	/*
+	 * The top, unverified certificate(s) are linked to the keyring and
+	 * we can now force verification of any new certificates linked.
+	 */
+	if (!l_keyring_restrict(verify_ring, L_KEYRING_RESTRICT_ASYM_CHAIN,
+				NULL)) {
+		l_key_free(prev_key);
+		l_keyring_free(ca_ring);
+		return false;
+	}
 =

-			if (ca->pubkey_type !=3D L_CERT_KEY_RSA)
-				return false;
+	if (ca_ring) {
+		/*
+		 * Verify the first certificate outside of the loop, then
+		 * revoke the trusted CAs' keys so that only the newly
+		 * verified cert's public key remains in the ring.
+		 */
+		prev_key =3D cert_try_link(cert, verify_ring);
+		l_keyring_free(ca_ring);
+	}
 =

-			ca_key =3D l_cert_get_pubkey(ca);
-			if (!ca_key)
-				return false;
+	cert =3D cert->issued;
 =

-			if (!l_keyring_link(ca_ring, ca_key)) {
-				l_key_free(ca_key);
-				return false;
-			}
-		}
+	/* Verify the rest of the chain */
+	while (prev_key && cert) {
+		struct l_key *new_key =3D cert_try_link(cert, verify_ring);
 =

-		if (!l_keyring_restrict(verify_ring,
-					L_KEYRING_RESTRICT_ASYM_CHAIN,
-					ca_ring))
-			return false;
+		/*
+		 * Free and revoke the issuer's public key again leaving only
+		 * new_key in verify_ring to ensure the next certificate linked
+		 * is signed by the owner of this key.
+		 */
+		l_key_free(prev_key);
+		prev_key =3D new_key;
+		cert =3D cert->issued;
 	}
 =

-	return certchain_verify_with_keyring(chain->leaf, verify_ring, ca_certs,
-						ca_ring);
+	if (!prev_key)
+		return false;
+
+	l_key_free(prev_key);
+	return true;
 }
-- =

2.19.1


--===============0390876384187758128==--

