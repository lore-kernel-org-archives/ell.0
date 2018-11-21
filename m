Content-Type: multipart/mixed; boundary="===============6922843771320641117=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 02/16] cert: Accept lists of CA certificates instead of one
Date: Wed, 21 Nov 2018 16:08:49 +0100
Message-ID: <20181121150903.24437-2-andrew.zaborowski@intel.com>
In-Reply-To: <20181121150903.24437-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6922843771320641117==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

In l_certchain_find and l_certchain_verify accept an l_queue with
potentially more than one CA certifcate so the user doesn't need to call
these functions multiple times if multiple CAs are configured.
---
 ell/cert.c | 91 +++++++++++++++++++++++++++++++++++-------------------
 ell/cert.h |  6 ++--
 2 files changed, 63 insertions(+), 34 deletions(-)

diff --git a/ell/cert.c b/ell/cert.c
index 8ce9da0..1c95d0c 100644
--- a/ell/cert.c
+++ b/ell/cert.c
@@ -285,20 +285,20 @@ LIB_EXPORT bool l_certchain_foreach_from_ca(struct l_=
certchain *chain,
 }
 =

 LIB_EXPORT bool l_certchain_find(struct l_certchain *chain,
-					struct l_cert *ca_cert)
+					struct l_queue *ca_certs)
 {
 	if (unlikely(!chain || !chain->leaf))
 		return false;
 =

 	/* Nothing to do if no CA certificates supplied */
-	if (!ca_cert)
+	if (!ca_certs)
 		return true;
 =

 	/*
 	 * Also nothing to do if the user already supplied a working
 	 * certificate chain.
 	 */
-	if (l_certchain_verify(chain, ca_cert))
+	if (l_certchain_verify(chain, ca_certs))
 		return true;
 =

 	/* Actual search for a chain to the CA cert is unimplemented, fail */
@@ -312,7 +312,7 @@ static void cert_key_cleanup(struct l_key **p)
 =

 static bool certchain_verify_with_keyring(struct l_cert *cert,
 						struct l_keyring *ring,
-						struct l_cert *root,
+						struct l_queue *roots,
 						struct l_keyring *trusted)
 {
 	if (!cert)
@@ -328,12 +328,30 @@ static bool certchain_verify_with_keyring(struct l_ce=
rt *cert,
 	 * specifies the root certificate authority MAY be omitted from
 	 * the chain, under the assumption that the remote end must
 	 * already possess it in order to validate it in any case."
+	 *
+	 * This is an optimization to skip adding the root cert if
+	 * it's already in the trusted keyring.  It also happens to
+	 * work around a kernel issue preventing self-signed certificates
+	 * missing the AKID extension from being linked.
+	 *
+	 * If 'roots' were supplied we assume the keyring is already
+	 * restricted.
 	 */
-	if (!cert->issuer && root && cert->asn1_len =3D=3D root->asn1_len &&
-			!memcmp(cert->asn1, root->asn1, root->asn1_len))
-		return true;
+	if (!cert->issuer && roots) {
+		const struct l_queue_entry *entry;
+
+		for (entry =3D l_queue_get_entries(roots); entry;
+				entry =3D entry->next) {
+			struct l_cert *root =3D entry->data;
+
+			if (cert->asn1_len =3D=3D root->asn1_len &&
+					!memcmp(cert->asn1, root->asn1,
+						root->asn1_len))
+				return true;
+		}
+	}
 =

-	if (certchain_verify_with_keyring(cert->issuer, ring, root, trusted)) {
+	if (certchain_verify_with_keyring(cert->issuer, ring, roots, trusted)) {
 		L_AUTO_CLEANUP_VAR(struct l_key *, key, cert_key_cleanup);
 =

 		key =3D l_key_new(L_KEY_RSA, cert->asn1, cert->asn1_len);
@@ -371,7 +389,7 @@ static void cert_keyring_cleanup(struct l_keyring **p)
 }
 =

 LIB_EXPORT bool l_certchain_verify(struct l_certchain *chain,
-					struct l_cert *ca_cert)
+					struct l_queue *ca_certs)
 {
 	L_AUTO_CLEANUP_VAR(struct l_keyring *, ca_ring,
 				cert_keyring_cleanup) =3D NULL;
@@ -381,39 +399,48 @@ LIB_EXPORT bool l_certchain_verify(struct l_certchain=
 *chain,
 	if (unlikely(!chain || !chain->leaf))
 		return false;
 =

-	if (ca_cert && ca_cert->pubkey_type !=3D L_CERT_KEY_RSA)
+	verify_ring =3D l_keyring_new();
+	if (!verify_ring)
 		return false;
 =

-	if (ca_cert) {
-		L_AUTO_CLEANUP_VAR(struct l_key *, ca_key, cert_key_cleanup);
-		ca_key =3D NULL;
+	/*
+	 * If CA cert(s) were supplied, restrict verify_ring now so
+	 * everything else in certchain is validated against the CA(s).
+	 * Otherwise, verify_ring will be restricted after the root of
+	 * certchain is added to verify_ring by
+	 * certchain_verify_with_keyring().
+	 */
+	if (ca_certs) {
+		const struct l_queue_entry *entry;
 =

 		ca_ring =3D l_keyring_new();
 		if (!ca_ring)
 			return false;
 =

-		ca_key =3D l_cert_get_pubkey(ca_cert);
-		if (!ca_key || !l_keyring_link(ca_ring, ca_key))
-			return false;
-	}
+		for (entry =3D l_queue_get_entries(ca_certs); entry;
+				entry =3D entry->next) {
+			struct l_cert *ca =3D entry->data;
+			struct l_key *ca_key;
 =

-	verify_ring =3D l_keyring_new();
-	if (!verify_ring)
-		return false;
+			if (ca->pubkey_type !=3D L_CERT_KEY_RSA)
+				return false;
 =

-	/*
-	 * If a CA cert was supplied, restrict verify_ring now so
-	 * everything else in certchain is validated against the CA.
-	 * Otherwise, verify_ring will be restricted after the root of
-	 * certchain is added to verify_ring by
-	 * cert_verify_with_keyring().
-	 */
-	if (ca_ring && !l_keyring_restrict(verify_ring,
-						L_KEYRING_RESTRICT_ASYM_CHAIN,
-						ca_ring)) {
-		return false;
+			ca_key =3D l_cert_get_pubkey(ca);
+			if (!ca_key)
+				return false;
+
+			if (!l_keyring_link(ca_ring, ca_key)) {
+				l_key_free(ca_key);
+				return false;
+			}
+		}
+
+		if (!l_keyring_restrict(verify_ring,
+					L_KEYRING_RESTRICT_ASYM_CHAIN,
+					ca_ring))
+			return false;
 	}
 =

-	return certchain_verify_with_keyring(chain->leaf, verify_ring, ca_cert,
+	return certchain_verify_with_keyring(chain->leaf, verify_ring, ca_certs,
 						ca_ring);
 }
diff --git a/ell/cert.h b/ell/cert.h
index 915ad5f..dc733a0 100644
--- a/ell/cert.h
+++ b/ell/cert.h
@@ -29,6 +29,8 @@ extern "C" {
 =

 #include <stddef.h>
 =

+#include <ell/queue.h>
+
 struct l_cert;
 struct l_certchain;
 =

@@ -57,8 +59,8 @@ bool l_certchain_foreach_from_ca(struct l_certchain *chai=
n,
 					l_cert_foreach_cb_t cb,
 					void *user_data);
 =

-bool l_certchain_find(struct l_certchain *chain, struct l_cert *ca_cert);
-bool l_certchain_verify(struct l_certchain *chain, struct l_cert *ca_cert);
+bool l_certchain_find(struct l_certchain *chain, struct l_queue *ca_certs);
+bool l_certchain_verify(struct l_certchain *chain, struct l_queue *ca_cert=
s);
 =

 #ifdef __cplusplus
 }
-- =

2.19.1


--===============6922843771320641117==--

