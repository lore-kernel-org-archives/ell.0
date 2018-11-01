Content-Type: multipart/mixed; boundary="===============1412207936928383130=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 5/7] tls: Support loading multiple root CAs
Date: Thu, 01 Nov 2018 03:12:18 +0100
Message-ID: <20181101021220.19073-5-andrew.zaborowski@intel.com>
In-Reply-To: <20181101021220.19073-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1412207936928383130==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

If a file with multiple concatenated certificates is supplied to
set_auth_data, load all of them and verify received certificate chains
aginst any of them instead of just the first one.  This is also what
wpa_supplicant does for files supplied with the ca_cert=3D setting and
it's actually useful.  Some enterprise CAs have multiple root
certificates and provision clients with a file that contains all of them
concatenated and it does happen that they switch from a certificate
chain using one root to a new chain with a different root for their wifi
in which case our network config files break while wpa_supplicant
configs keep working.

Also simplify tls_cert_verify_certchain slightly.
---
 ell/tls-private.h |   3 +-
 ell/tls.c         | 137 ++++++++++++++++++++++++++++++++--------------
 ell/tls.h         |   2 +-
 3 files changed, 100 insertions(+), 42 deletions(-)

diff --git a/ell/tls-private.h b/ell/tls-private.h
index 4f680a0..95b8c65 100644
--- a/ell/tls-private.h
+++ b/ell/tls-private.h
@@ -240,6 +240,7 @@ enum tls_cert_key_type {
 };
 =

 struct tls_cert *tls_cert_load_file(const char *filename);
+struct l_queue *tls_cert_list_load_file(const char *filename);
 int tls_cert_from_certificate_list(const void *data, size_t len,
 					struct tls_cert **out_certchain);
 =

@@ -247,7 +248,7 @@ bool tls_cert_find_certchain(struct tls_cert *cert,
 				const char *cacert_filename);
 =

 bool tls_cert_verify_certchain(struct tls_cert *certchain,
-				struct tls_cert *ca_cert);
+				struct l_queue *ca_certs);
 =

 void tls_cert_free_certchain(struct tls_cert *cert);
 =

diff --git a/ell/tls.c b/ell/tls.c
index 4b37785..fbbc1bf 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -38,6 +38,7 @@
 #include "tls-private.h"
 #include "key.h"
 #include "asn1-private.h"
+#include "queue.h"
 =

 void tls10_prf(const void *secret, size_t secret_len,
 		const char *label,
@@ -1571,7 +1572,7 @@ static void tls_handle_certificate(struct l_tls *tls,
 {
 	size_t total;
 	struct tls_cert *certchain =3D NULL;
-	struct tls_cert *ca_cert =3D NULL;
+	struct l_queue *ca_certs =3D NULL;
 	bool dummy;
 =

 	if (len < 3)
@@ -1614,12 +1615,12 @@ static void tls_handle_certificate(struct l_tls *tl=
s,
 =

 	/*
 	 * Validate the certificate chain's consistency and validate it
-	 * against our CA if we have any.
+	 * against our CAs if we have any.
 	 */
 =

 	if (tls->ca_cert_path) {
-		ca_cert =3D tls_cert_load_file(tls->ca_cert_path);
-		if (!ca_cert) {
+		ca_certs =3D tls_cert_list_load_file(tls->ca_cert_path);
+		if (!ca_certs) {
 			TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR,
 					TLS_ALERT_BAD_CERT,
 					"Can't load %s", tls->ca_cert_path);
@@ -1628,10 +1629,10 @@ static void tls_handle_certificate(struct l_tls *tl=
s,
 		}
 	}
 =

-	if (!tls_cert_verify_certchain(certchain, ca_cert)) {
+	if (!tls_cert_verify_certchain(certchain, ca_certs)) {
 		TLS_DISCONNECT(TLS_ALERT_BAD_CERT, 0,
 				"Peer certchain verification failed against "
-				"CA cert %s", tls->ca_cert_path);
+				"CA cert(s) in %s", tls->ca_cert_path);
 =

 		goto done;
 	}
@@ -1691,8 +1692,8 @@ decode_error:
 			"TLS_CERTIFICATE decode error");
 =

 done:
-	if (ca_cert)
-		l_free(ca_cert);
+	if (ca_certs)
+		l_queue_destroy(ca_certs, l_free);
 =

 	tls_cert_free_certchain(certchain);
 }
@@ -2592,6 +2593,44 @@ struct tls_cert *tls_cert_load_file(const char *file=
name)
 	return cert;
 }
 =

+struct l_queue *tls_cert_list_load_file(const char *filename)
+{
+	struct l_queue *pem_list;
+	struct l_queue *cert_list;
+	bool error =3D false;
+
+	pem_list =3D l_pem_load_certificate_list(filename);
+	if (!pem_list)
+		return NULL;
+
+	cert_list =3D l_queue_new();
+
+	while (!l_queue_isempty(pem_list)) {
+		struct tls_cert *cert;
+		struct l_pem_list_element *elem =3D l_queue_pop_head(pem_list);
+		uint8_t *der =3D elem->content;
+
+		if (!elem->len || der[0] !=3D ASN1_ID_SEQUENCE)
+			error =3D true;
+
+		cert =3D l_malloc(sizeof(struct tls_cert) + elem->len);
+		cert->size =3D elem->len;
+		cert->issuer =3D NULL;
+		memcpy(cert->asn1, der, cert->size);
+		l_queue_push_tail(cert_list, cert);
+		l_free(elem->content);
+		l_free(elem);
+	}
+
+	l_queue_destroy(pem_list, NULL);
+
+	if (!error)
+		return cert_list;
+
+	l_queue_destroy(cert_list, l_free);
+	return NULL;
+}
+
 int tls_cert_from_certificate_list(const void *data, size_t len,
 					struct tls_cert **out_certchain)
 {
@@ -2653,9 +2692,18 @@ static void tls_key_cleanup(struct l_key **p)
 	l_key_free_norevoke(*p);
 }
 =

+static bool tls_cert_link(struct tls_cert *cert, struct l_keyring *ring)
+{
+	L_AUTO_CLEANUP_VAR(struct l_key *, key, tls_key_cleanup) =3D NULL;
+
+	key =3D l_key_new(L_KEY_RSA, cert->asn1, cert->size);
+
+	return key && l_keyring_link(ring, key);
+}
+
 static bool tls_cert_verify_with_keyring(struct tls_cert *cert,
 						struct l_keyring *ring,
-						struct tls_cert *root,
+						struct l_queue *roots,
 						struct l_keyring *trusted)
 {
 	if (!cert)
@@ -2668,19 +2716,30 @@ static bool tls_cert_verify_with_keyring(struct tls=
_cert *cert,
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
-	if (!cert->issuer && root && cert->size =3D=3D root->size &&
-			!memcmp(cert->asn1, root->asn1, root->size))
-		return true;
+	if (!cert->issuer && roots) {
+		const struct l_queue_entry *entry;
 =

-	if (tls_cert_verify_with_keyring(cert->issuer, ring, root, trusted)) {
-		L_AUTO_CLEANUP_VAR(struct l_key *, key, tls_key_cleanup);
+		for (entry =3D l_queue_get_entries(roots); entry;
+				entry =3D entry->next) {
+			const struct tls_cert *root =3D entry->data;
 =

-		key =3D l_key_new(L_KEY_RSA, cert->asn1, cert->size);
-		if (!key)
-			return false;
+			if (cert->size =3D=3D root->size && !memcmp(cert->asn1,
+						root->asn1, root->size))
+				return true;
+		}
+	}
 =

-		if (!l_keyring_link(ring, key))
+	if (tls_cert_verify_with_keyring(cert->issuer, ring, roots, trusted)) {
+		if (!tls_cert_link(cert, ring))
 			return false;
 =

 		if (trusted || cert->issuer)
@@ -2711,46 +2770,44 @@ static void tls_keyring_cleanup(struct l_keyring **=
p)
 }
 =

 bool tls_cert_verify_certchain(struct tls_cert *certchain,
-				struct tls_cert *ca_cert)
+				struct l_queue *ca_certs)
 {
 	L_AUTO_CLEANUP_VAR(struct l_keyring *, ca_ring, tls_keyring_cleanup);
 	L_AUTO_CLEANUP_VAR(struct l_keyring *, verify_ring,
 				tls_keyring_cleanup);
 =

 	ca_ring =3D NULL;
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
 =

 	verify_ring =3D l_keyring_new();
 	if (!verify_ring)
 		return false;
 =

 	/*
-	 * If a CA cert was supplied, restrict verify_ring now so
-	 * everything else in certchain is validated against the CA.
+	 * If CA cert(s) were supplied, restrict verify_ring now so
+	 * everything else in certchain is validated against the CA(s).
 	 * Otherwise, verify_ring will be restricted after the root of
 	 * certchain is added to verify_ring by
 	 * tls_cert_verify_with_keyring().
 	 */
-	if (ca_ring && !l_keyring_restrict(verify_ring,
-						L_KEYRING_RESTRICT_ASYM_CHAIN,
-						ca_ring)) {
-		return false;
+	if (ca_certs) {
+		const struct l_queue_entry *entry;
+
+		ca_ring =3D l_keyring_new();
+		if (!ca_ring)
+			return false;
+
+		for (entry =3D l_queue_get_entries(ca_certs); entry;
+				entry =3D entry->next)
+			if (!tls_cert_link(entry->data, ca_ring))
+				return false;
+
+		if (!l_keyring_restrict(verify_ring,
+					L_KEYRING_RESTRICT_ASYM_CHAIN,
+					ca_ring))
+			return false;
 	}
 =

-	return tls_cert_verify_with_keyring(certchain, verify_ring, ca_cert,
+	return tls_cert_verify_with_keyring(certchain, verify_ring, ca_certs,
 						ca_ring);
 }
 =

diff --git a/ell/tls.h b/ell/tls.h
index 893fd63..8eec360 100644
--- a/ell/tls.h
+++ b/ell/tls.h
@@ -86,7 +86,7 @@ void l_tls_write(struct l_tls *tls, const uint8_t *data, =
size_t len);
 /* Submit TLS payload from underlying transport to be decrypted */
 void l_tls_handle_rx(struct l_tls *tls, const uint8_t *data, size_t len);
 =

-/* If peer is to be authenticated, supply the CA certificate */
+/* If peer is to be authenticated, supply the CA certificate(s) */
 void l_tls_set_cacert(struct l_tls *tls, const char *ca_cert_path);
 =

 /*
-- =

2.19.1


--===============1412207936928383130==--

