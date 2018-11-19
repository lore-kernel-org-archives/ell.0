Content-Type: multipart/mixed; boundary="===============8954928244917867859=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 4/7] tls: Move certchain utilities to cert.c
Date: Mon, 19 Nov 2018 19:23:45 +0100
Message-ID: <20181119182348.4562-4-andrew.zaborowski@intel.com>
In-Reply-To: <20181119182348.4562-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8954928244917867859==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Move and adapt tls_cert_verify_certchain and tls_cert_find_certchain
to the new cert.c classes and drop tls_cert_free_certchain and
tls_cert_get_pubkey_type because these functions are already provided by
cert.c.  For clarity there's no attempt to improve any of the functions
here but further certchain_verify work is pending.
---
 ell/cert.c        | 134 ++++++++++++++++++++++++++++++++++++++
 ell/cert.h        |   3 +
 ell/ell.sym       |   2 +
 ell/tls-private.h |  10 ---
 ell/tls.c         | 161 ----------------------------------------------
 5 files changed, 139 insertions(+), 171 deletions(-)

diff --git a/ell/cert.c b/ell/cert.c
index 7d0c0b5..8ce9da0 100644
--- a/ell/cert.c
+++ b/ell/cert.c
@@ -283,3 +283,137 @@ LIB_EXPORT bool l_certchain_foreach_from_ca(struct l_=
certchain *chain,
 =

 	return false;
 }
+
+LIB_EXPORT bool l_certchain_find(struct l_certchain *chain,
+					struct l_cert *ca_cert)
+{
+	if (unlikely(!chain || !chain->leaf))
+		return false;
+
+	/* Nothing to do if no CA certificates supplied */
+	if (!ca_cert)
+		return true;
+
+	/*
+	 * Also nothing to do if the user already supplied a working
+	 * certificate chain.
+	 */
+	if (l_certchain_verify(chain, ca_cert))
+		return true;
+
+	/* Actual search for a chain to the CA cert is unimplemented, fail */
+	return false;
+}
+
+static void cert_key_cleanup(struct l_key **p)
+{
+	l_key_free_norevoke(*p);
+}
+
+static bool certchain_verify_with_keyring(struct l_cert *cert,
+						struct l_keyring *ring,
+						struct l_cert *root,
+						struct l_keyring *trusted)
+{
+	if (!cert)
+		return true;
+
+	if (cert->pubkey_type !=3D L_CERT_KEY_RSA)
+		return false;
+
+	/*
+	 * RFC5246 7.4.2:
+	 * "Because certificate validation requires that root keys be
+	 * distributed independently, the self-signed certificate that
+	 * specifies the root certificate authority MAY be omitted from
+	 * the chain, under the assumption that the remote end must
+	 * already possess it in order to validate it in any case."
+	 */
+	if (!cert->issuer && root && cert->asn1_len =3D=3D root->asn1_len &&
+			!memcmp(cert->asn1, root->asn1, root->asn1_len))
+		return true;
+
+	if (certchain_verify_with_keyring(cert->issuer, ring, root, trusted)) {
+		L_AUTO_CLEANUP_VAR(struct l_key *, key, cert_key_cleanup);
+
+		key =3D l_key_new(L_KEY_RSA, cert->asn1, cert->asn1_len);
+		if (!key)
+			return false;
+
+		if (!l_keyring_link(ring, key))
+			return false;
+
+		if (trusted || cert->issuer)
+			return true;
+
+		/*
+		 * If execution reaches this point, it's known that:
+		 *  * No trusted root key was supplied, so the chain is only
+		 *    being checked against its own root
+		 *  * The keyring 'ring' is not restricted yet
+		 *  * The chain's root cert was just linked in to the
+		 *    previously empty keyring 'ring'.
+		 *
+		 * By restricting 'ring' now, the rest of the certs in
+		 * the chain will have their signature validated using 'key'
+		 * as the root.
+		 */
+		return l_keyring_restrict(ring,	L_KEYRING_RESTRICT_ASYM_CHAIN,
+						trusted);
+	}
+
+	return false;
+}
+
+static void cert_keyring_cleanup(struct l_keyring **p)
+{
+	l_keyring_free(*p);
+}
+
+LIB_EXPORT bool l_certchain_verify(struct l_certchain *chain,
+					struct l_cert *ca_cert)
+{
+	L_AUTO_CLEANUP_VAR(struct l_keyring *, ca_ring,
+				cert_keyring_cleanup) =3D NULL;
+	L_AUTO_CLEANUP_VAR(struct l_keyring *, verify_ring,
+				cert_keyring_cleanup) =3D NULL;
+
+	if (unlikely(!chain || !chain->leaf))
+		return false;
+
+	if (ca_cert && ca_cert->pubkey_type !=3D L_CERT_KEY_RSA)
+		return false;
+
+	if (ca_cert) {
+		L_AUTO_CLEANUP_VAR(struct l_key *, ca_key, cert_key_cleanup);
+		ca_key =3D NULL;
+
+		ca_ring =3D l_keyring_new();
+		if (!ca_ring)
+			return false;
+
+		ca_key =3D l_cert_get_pubkey(ca_cert);
+		if (!ca_key || !l_keyring_link(ca_ring, ca_key))
+			return false;
+	}
+
+	verify_ring =3D l_keyring_new();
+	if (!verify_ring)
+		return false;
+
+	/*
+	 * If a CA cert was supplied, restrict verify_ring now so
+	 * everything else in certchain is validated against the CA.
+	 * Otherwise, verify_ring will be restricted after the root of
+	 * certchain is added to verify_ring by
+	 * cert_verify_with_keyring().
+	 */
+	if (ca_ring && !l_keyring_restrict(verify_ring,
+						L_KEYRING_RESTRICT_ASYM_CHAIN,
+						ca_ring)) {
+		return false;
+	}
+
+	return certchain_verify_with_keyring(chain->leaf, verify_ring, ca_cert,
+						ca_ring);
+}
diff --git a/ell/cert.h b/ell/cert.h
index 81a8b43..915ad5f 100644
--- a/ell/cert.h
+++ b/ell/cert.h
@@ -57,6 +57,9 @@ bool l_certchain_foreach_from_ca(struct l_certchain *chai=
n,
 					l_cert_foreach_cb_t cb,
 					void *user_data);
 =

+bool l_certchain_find(struct l_certchain *chain, struct l_cert *ca_cert);
+bool l_certchain_verify(struct l_certchain *chain, struct l_cert *ca_cert);
+
 #ifdef __cplusplus
 }
 #endif
diff --git a/ell/ell.sym b/ell/ell.sym
index 414df53..c2aafee 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -443,6 +443,8 @@ global:
 	l_certchain_get_leaf;
 	l_certchain_foreach_from_leaf;
 	l_certchain_foreach_from_ca;
+	l_certchain_find;
+	l_certchain_verify;
 local:
 	*;
 };
diff --git a/ell/tls-private.h b/ell/tls-private.h
index 0d8592a..7dfbd6c 100644
--- a/ell/tls-private.h
+++ b/ell/tls-private.h
@@ -255,16 +255,6 @@ struct tls_cert *tls_cert_load_file(const char *filena=
me);
 int tls_cert_from_certificate_list(const void *data, size_t len,
 					struct tls_cert **out_certchain);
 =

-bool tls_cert_find_certchain(struct tls_cert *cert,
-				const char *cacert_filename);
-
-bool tls_cert_verify_certchain(struct tls_cert *certchain,
-				struct tls_cert *ca_cert);
-
-void tls_cert_free_certchain(struct tls_cert *cert);
-
-enum tls_cert_key_type tls_cert_get_pubkey_type(struct tls_cert *cert);
-
 #define TLS_DEBUG(fmt, args...)	\
 	l_util_debug(tls->debug_handler, tls->debug_data, "%s:%i " fmt,	\
 			__func__, __LINE__, ## args)
diff --git a/ell/tls.c b/ell/tls.c
index 92b8f68..c0a2516 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -2845,167 +2845,6 @@ decode_error:
 	return -EBADMSG;
 }
 =

-bool tls_cert_find_certchain(struct tls_cert *cert,
-				const char *cacert_filename)
-{
-	return true;
-}
-
-static const struct pkcs1_encryption_oid {
-	enum tls_cert_key_type key_type;
-	struct asn1_oid oid;
-} pkcs1_encryption_oids[] =3D {
-	{ /* rsaEncryption */
-		TLS_CERT_KEY_RSA,
-		{ 9, { 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01, 0x01 } },
-	},
-};
-
-static void tls_key_cleanup(struct l_key **p)
-{
-	l_key_free_norevoke(*p);
-}
-
-static bool tls_cert_verify_with_keyring(struct tls_cert *cert,
-						struct l_keyring *ring,
-						struct tls_cert *root,
-						struct l_keyring *trusted)
-{
-	if (!cert)
-		return true;
-
-	/*
-	 * RFC5246 7.4.2:
-	 * "Because certificate validation requires that root keys be
-	 * distributed independently, the self-signed certificate that
-	 * specifies the root certificate authority MAY be omitted from
-	 * the chain, under the assumption that the remote end must
-	 * already possess it in order to validate it in any case."
-	 */
-	if (!cert->issuer && root && cert->size =3D=3D root->size &&
-			!memcmp(cert->asn1, root->asn1, root->size))
-		return true;
-
-	if (tls_cert_verify_with_keyring(cert->issuer, ring, root, trusted)) {
-		L_AUTO_CLEANUP_VAR(struct l_key *, key, tls_key_cleanup);
-
-		key =3D l_key_new(L_KEY_RSA, cert->asn1, cert->size);
-		if (!key)
-			return false;
-
-		if (!l_keyring_link(ring, key))
-			return false;
-
-		if (trusted || cert->issuer)
-			return true;
-
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
-
-	return false;
-}
-
-static void tls_keyring_cleanup(struct l_keyring **p)
-{
-	l_keyring_free(*p);
-}
-
-bool tls_cert_verify_certchain(struct tls_cert *certchain,
-				struct tls_cert *ca_cert)
-{
-	L_AUTO_CLEANUP_VAR(struct l_keyring *, ca_ring, tls_keyring_cleanup);
-	L_AUTO_CLEANUP_VAR(struct l_keyring *, verify_ring,
-				tls_keyring_cleanup);
-
-	ca_ring =3D NULL;
-	verify_ring =3D NULL;
-
-	if (ca_cert) {
-		L_AUTO_CLEANUP_VAR(struct l_key *, ca_key, tls_key_cleanup);
-		ca_key =3D NULL;
-
-		ca_ring =3D l_keyring_new();
-		if (!ca_ring)
-			return false;
-
-		ca_key =3D l_key_new(L_KEY_RSA, ca_cert->asn1, ca_cert->size);
-		if (!ca_key || !l_keyring_link(ca_ring, ca_key))
-			return false;
-	}
-
-	verify_ring =3D l_keyring_new();
-	if (!verify_ring)
-		return false;
-
-	/*
-	 * If a CA cert was supplied, restrict verify_ring now so
-	 * everything else in certchain is validated against the CA.
-	 * Otherwise, verify_ring will be restricted after the root of
-	 * certchain is added to verify_ring by
-	 * tls_cert_verify_with_keyring().
-	 */
-	if (ca_ring && !l_keyring_restrict(verify_ring,
-						L_KEYRING_RESTRICT_ASYM_CHAIN,
-						ca_ring)) {
-		return false;
-	}
-
-	return tls_cert_verify_with_keyring(certchain, verify_ring, ca_cert,
-						ca_ring);
-}
-
-void tls_cert_free_certchain(struct tls_cert *cert)
-{
-	struct tls_cert *next;
-
-	while (cert) {
-		next =3D cert->issuer;
-		l_free(cert);
-		cert =3D next;
-	}
-}
-
-enum tls_cert_key_type tls_cert_get_pubkey_type(struct tls_cert *cert)
-{
-	const uint8_t *key_type;
-	size_t key_type_len;
-	int i;
-
-	key_type =3D asn1_der_find_elem_by_path(cert->asn1, cert->size,
-						ASN1_ID_OID, &key_type_len,
-						X509_CERTIFICATE_POS,
-						X509_TBSCERTIFICATE_POS,
-						X509_TBSCERT_SUBJECT_KEY_POS,
-						X509_SUBJECT_KEY_ALGORITHM_POS,
-						X509_ALGORITHM_ID_ALGORITHM_POS,
-						-1);
-	if (!key_type)
-		return TLS_CERT_KEY_UNKNOWN;
-
-	for (i =3D 0; i < (int) L_ARRAY_SIZE(pkcs1_encryption_oids); i++)
-		if (asn1_oid_eq(&pkcs1_encryption_oids[i].oid,
-					key_type_len, key_type))
-			break;
-
-	if (i =3D=3D L_ARRAY_SIZE(pkcs1_encryption_oids))
-		return TLS_CERT_KEY_UNKNOWN;
-
-	return pkcs1_encryption_oids[i].key_type;
-}
-
 LIB_EXPORT bool l_tls_set_debug(struct l_tls *tls, l_tls_debug_cb_t functi=
on,
 				void *user_data, l_tls_destroy_cb_t destroy)
 {
-- =

2.19.1


--===============8954928244917867859==--

