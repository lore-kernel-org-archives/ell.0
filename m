Content-Type: multipart/mixed; boundary="===============9170799691516482811=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 08/11] tls: Stricter certificate chain verification
Date: Thu, 01 Nov 2018 12:54:50 +0100
Message-ID: <20181101115453.10373-8-andrew.zaborowski@intel.com>
In-Reply-To: <20181101115453.10373-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============9170799691516482811==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Rewrite tls_cert_verify_certchain to fix a long standing issue where it
didn't verify that each certificate in the chain was trusted by the next
one.  Since certificates were only being added to the two keyrings and
never removed the order in the chain was not being verified.  Now use a
single ring and remove the previously added certificates from it once
they've been used to show that the next certificate was signed with one
of them.  Add lots of comments.
---
 ell/tls.c | 206 +++++++++++++++++++++++++++++++++---------------------
 1 file changed, 125 insertions(+), 81 deletions(-)

diff --git a/ell/tls.c b/ell/tls.c
index fbbc1bf..7f42240 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -2687,27 +2687,99 @@ static const struct pkcs1_encryption_oid {
 	},
 };
 =

+static struct l_key *tls_cert_verify_root(struct l_key *key,
+						struct l_keyring *ring,
+						struct l_queue *roots)
+{
+	const struct l_queue_entry *entry;
+	unsigned int i, n =3D l_queue_length(roots);
+	struct l_key *root_keys[n];
+	bool success =3D true;
+
+	/*
+	 * Check that @key is trusted by one of @roots by linking it
+	 * to a restricted ring containing only the roots.  If successful
+	 * return @key leaving only @key in the keyring.
+	 */
+
+	for (entry =3D l_queue_get_entries(roots), i =3D 0; i < n;
+			entry =3D entry->next, i++) {
+		const struct tls_cert *root =3D entry->data;
+
+		root_keys[i] =3D l_key_new(L_KEY_RSA, root->asn1, root->size);
+		if (!root_keys[i] || !l_keyring_link(ring, root_keys[i]))
+			success =3D false;
+	}
+
+	if (!l_keyring_restrict(ring, L_KEYRING_RESTRICT_ASYM_CHAIN, NULL) ||
+			!l_keyring_link(ring, key))
+		success =3D false;
+
+	for (i =3D 0; i < n; i++)
+		l_key_free(root_keys[i]);
+
+	if (success)
+		return key;
+
+	l_key_free(key);
+	return NULL;
+}
+
 static void tls_key_cleanup(struct l_key **p)
 {
-	l_key_free_norevoke(*p);
+	l_key_free(*p);
 }
 =

-static bool tls_cert_link(struct tls_cert *cert, struct l_keyring *ring)
+static struct l_key *tls_cert_verify_with_keyring(struct tls_cert *cert,
+							struct l_keyring *ring,
+							struct l_queue *roots)
 {
-	L_AUTO_CLEANUP_VAR(struct l_key *, key, tls_key_cleanup) =3D NULL;
+	struct l_key *key;
+	const struct l_queue_entry *entry;
 =

-	key =3D l_key_new(L_KEY_RSA, cert->asn1, cert->size);
+	if (cert->issuer) {
+		L_AUTO_CLEANUP_VAR(struct l_key *, trusted, tls_key_cleanup);
 =

-	return key && l_keyring_link(ring, key);
-}
+		/*
+		 * Since we have the issuer, this is neither the root
+		 * certificate nor the closest-to-the-root certificate in
+		 * this chain, which may not contain the actual root.  Call
+		 * ourselves to verify that the chain is valid down to this
+		 * certificate's issuer.
+		 */
+		trusted =3D tls_cert_verify_with_keyring(cert->issuer,
+							ring, roots);
+		if (!trusted)
+			return NULL;
 =

-static bool tls_cert_verify_with_keyring(struct tls_cert *cert,
-						struct l_keyring *ring,
-						struct l_queue *roots,
-						struct l_keyring *trusted)
-{
-	if (!cert)
-		return true;
+		/*
+		 * The issuer is trusted, at this point we only have to
+		 * verify the issuer trusts this certificate and we will
+		 * know the whole chain is trusted.  After the call @ring
+		 * conveniently contains only the issuer certificate and
+		 * is restricted so that only certificates trusted by it
+		 * can be linked.
+		 */
+		key =3D l_key_new(L_KEY_RSA, cert->asn1, cert->size);
+		if (!key)
+			return NULL;
+
+		if (!l_keyring_link(ring, key))
+			goto free_key;
+
+		/*
+		 * The chain is valid down to @cert and @ring now
+		 * contains both the @trusted and @key.  However @trusted
+		 * is autofreed and will be revoked by l_key_free so
+		 * the caller will get a ring with only @key in it and
+		 * can try to link further certificates and unlink @key.
+		 */
+		return key;
+	}
+
+	key =3D l_key_new(L_KEY_RSA, cert->asn1, cert->size);
+	if (!key)
+		return NULL;
 =

 	/*
 	 * RFC5246 7.4.2:
@@ -2717,51 +2789,47 @@ static bool tls_cert_verify_with_keyring(struct tls=
_cert *cert,
 	 * the chain, under the assumption that the remote end must
 	 * already possess it in order to validate it in any case."
 	 *
-	 * This is an optimization to skip adding the root cert if
-	 * it's already in the trusted keyring.  It also happens to
-	 * work around a kernel issue preventing self-signed certificates
-	 * missing the AKID extension from being linked.
-	 *
-	 * If 'roots' were supplied we assume the keyring is already
-	 * restricted.
+	 * This is either the root cert or the closest-to-the-root
+	 * certificate in the chain.  If @roots were supplied we have
+	 * to verify it is either one of the roots or is trusted by one
+	 * of the roots.  If @roots is NULL, we only have to link it
+	 * to the keyring and restrict the keyring.
 	 */
-	if (!cert->issuer && roots) {
-		const struct l_queue_entry *entry;
+	if (!roots)
+		goto link_and_restrict;
 =

-		for (entry =3D l_queue_get_entries(roots); entry;
-				entry =3D entry->next) {
-			const struct tls_cert *root =3D entry->data;
+	/*
+	 * This is an optimization to skip verifying the root cert if
+	 * it's identical to one of the supplied roots.  If it is, we just
+	 * have to add it to the keyring and restrict the keyring.
+	 * This also happens to work around a kernel issue preventing
+	 * self-signed certificates missing the AKID extension from being
+	 * linked.
+	 */
+	for (entry =3D l_queue_get_entries(roots); entry;
+			entry =3D entry->next) {
+		const struct tls_cert *root =3D entry->data;
 =

-			if (cert->size =3D=3D root->size && !memcmp(cert->asn1,
-						root->asn1, root->size))
-				return true;
-		}
+		if (cert->size =3D=3D root->size && !memcmp(cert->asn1,
+					root->asn1, root->size))
+			goto link_and_restrict;
 	}
 =

-	if (tls_cert_verify_with_keyring(cert->issuer, ring, roots, trusted)) {
-		if (!tls_cert_link(cert, ring))
-			return false;
+	return tls_cert_verify_root(key, ring, roots);
 =

-		if (trusted || cert->issuer)
-			return true;
+link_and_restrict:
+	if (!l_keyring_link(ring, key))
+		goto free_key;
 =

-		/*
-		 * If execution reaches this point, it's known that:
-		 *  * No trusted root key was supplied, so the chain is only
-		 *    being checked against its own root
-		 *  * The keyring 'ring' is not restricted yet
-		 *  * The chain's root cert was just linked in to the
-		 *    previously empty keyring 'ring'.
-		 *
-		 *  By restricting 'ring' now, the rest of the certs in
-		 *  the chain will have their signature validated using 'key'
-		 *  as the root.
-		 */
-		return l_keyring_restrict(ring,	L_KEYRING_RESTRICT_ASYM_CHAIN,
-						trusted);
-	}
+	if (!l_keyring_restrict(ring, L_KEYRING_RESTRICT_ASYM_CHAIN,
+				NULL))
+		goto free_key;
 =

-	return false;
+	return key;
+
+free_key:
+	l_key_free(key);
+	return NULL;
 }
 =

 static void tls_keyring_cleanup(struct l_keyring **p)
@@ -2772,43 +2840,19 @@ static void tls_keyring_cleanup(struct l_keyring **=
p)
 bool tls_cert_verify_certchain(struct tls_cert *certchain,
 				struct l_queue *ca_certs)
 {
-	L_AUTO_CLEANUP_VAR(struct l_keyring *, ca_ring, tls_keyring_cleanup);
 	L_AUTO_CLEANUP_VAR(struct l_keyring *, verify_ring,
-				tls_keyring_cleanup);
+				tls_keyring_cleanup) =3D l_keyring_new();
+	struct l_key *trusted;
 =

-	ca_ring =3D NULL;
-
-	verify_ring =3D l_keyring_new();
 	if (!verify_ring)
 		return false;
 =

-	/*
-	 * If CA cert(s) were supplied, restrict verify_ring now so
-	 * everything else in certchain is validated against the CA(s).
-	 * Otherwise, verify_ring will be restricted after the root of
-	 * certchain is added to verify_ring by
-	 * tls_cert_verify_with_keyring().
-	 */
-	if (ca_certs) {
-		const struct l_queue_entry *entry;
-
-		ca_ring =3D l_keyring_new();
-		if (!ca_ring)
-			return false;
-
-		for (entry =3D l_queue_get_entries(ca_certs); entry;
-				entry =3D entry->next)
-			if (!tls_cert_link(entry->data, ca_ring))
-				return false;
-
-		if (!l_keyring_restrict(verify_ring,
-					L_KEYRING_RESTRICT_ASYM_CHAIN,
-					ca_ring))
-			return false;
-	}
+	trusted =3D tls_cert_verify_with_keyring(certchain, verify_ring, ca_certs=
);
+	if (!trusted)
+		return false;
 =

-	return tls_cert_verify_with_keyring(certchain, verify_ring, ca_certs,
-						ca_ring);
+	l_key_free(trusted);
+	return true;
 }
 =

 void tls_cert_free_certchain(struct tls_cert *cert)
-- =

2.19.1


--===============9170799691516482811==--

