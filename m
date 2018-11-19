Content-Type: multipart/mixed; boundary="===============6700474125392746183=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 5/7] tls: Update l_tls to use the l_cert type, drop local code
Date: Mon, 19 Nov 2018 19:23:46 +0100
Message-ID: <20181119182348.4562-5-andrew.zaborowski@intel.com>
In-Reply-To: <20181119182348.4562-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6700474125392746183==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Drop the remaining struct tls_cert code and use the l_cert type for all the
certificate operations.  tls_cert_load_file is temporarily left in tls.c but
my idea is to replace it with two new pem.c functions, although test-key.c
will still need it.  tls_cert_from_certificate_list is only renamed to
tls_parse_certificate_list as it is TLS-specific.
---
 ell/tls-private.h |  29 ++----
 ell/tls-record.c  |   1 +
 ell/tls.c         | 244 +++++++++++++++++++++-------------------------
 3 files changed, 119 insertions(+), 155 deletions(-)

diff --git a/ell/tls-private.h b/ell/tls-private.h
index 7dfbd6c..9c909e1 100644
--- a/ell/tls-private.h
+++ b/ell/tls-private.h
@@ -28,8 +28,6 @@
 #define TLS_VERSION	TLS_V12
 #define TLS_MIN_VERSION	TLS_V10
 =

-struct tls_cert;
-
 enum tls_cipher_type {
 	TLS_CIPHER_STREAM,
 	TLS_CIPHER_BLOCK,
@@ -65,7 +63,7 @@ struct tls_key_exchange_algorithm {
 =

 	bool certificate_check;
 =

-	bool (*validate_cert_key_type)(struct tls_cert *cert);
+	bool (*validate_cert_key_type)(struct l_cert *cert);
 =

 	bool (*send_client_key_exchange)(struct l_tls *tls);
 	void (*handle_client_key_exchange)(struct l_tls *tls,
@@ -147,8 +145,8 @@ struct l_tls {
 	l_tls_destroy_cb_t debug_destroy;
 	void *debug_data;
 =

-	char *ca_cert_path;
-	char *cert_path;
+	struct l_cert *ca_cert;
+	struct l_certchain *cert;
 	struct l_key *priv_key;
 	size_t priv_key_size;
 =

@@ -174,7 +172,7 @@ struct l_tls {
 	uint16_t negotiated_version;
 	bool cert_requested, cert_sent;
 	bool peer_authenticated;
-	struct tls_cert *peer_cert;
+	struct l_cert *peer_cert;
 	struct l_key *peer_pubkey;
 	size_t peer_pubkey_size;
 	enum handshake_hash_type signature_hash;
@@ -238,22 +236,9 @@ void tls_tx_record(struct l_tls *tls, enum tls_content=
_type type,
 bool tls_handle_message(struct l_tls *tls, const uint8_t *message,
 			int len, enum tls_content_type type, uint16_t version);
 =

-/* X509 Certificates and Certificate Chains */
-
-struct tls_cert {
-	size_t size;
-	struct tls_cert *issuer;
-	uint8_t asn1[0];
-};
-
-enum tls_cert_key_type {
-	TLS_CERT_KEY_RSA,
-	TLS_CERT_KEY_UNKNOWN,
-};
-
-struct tls_cert *tls_cert_load_file(const char *filename);
-int tls_cert_from_certificate_list(const void *data, size_t len,
-					struct tls_cert **out_certchain);
+struct l_cert *tls_cert_load_file(const char *filename);
+int tls_parse_certificate_list(const void *data, size_t len,
+				struct l_certchain **out_certchain);
 =

 #define TLS_DEBUG(fmt, args...)	\
 	l_util_debug(tls->debug_handler, tls->debug_data, "%s:%i " fmt,	\
diff --git a/ell/tls-record.c b/ell/tls-record.c
index a8ff696..73be1a4 100644
--- a/ell/tls-record.c
+++ b/ell/tls-record.c
@@ -29,6 +29,7 @@
 #include "tls.h"
 #include "checksum.h"
 #include "cipher.h"
+#include "cert.h"
 #include "tls-private.h"
 #include "random.h"
 =

diff --git a/ell/tls.c b/ell/tls.c
index c0a2516..72d9b3e 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -35,9 +35,10 @@
 #include "cipher.h"
 #include "random.h"
 #include "pem.h"
+#include "cert.h"
+#include "cert-private.h"
 #include "tls-private.h"
 #include "key.h"
-#include "asn1-private.h"
 =

 void tls10_prf(const void *secret, size_t secret_len,
 		const char *label,
@@ -172,7 +173,7 @@ static void tls_reset_handshake(struct l_tls *tls)
 =

 	memset(tls->pending.key_block, 0, sizeof(tls->pending.key_block));
 =

-	l_free(tls->peer_cert);
+	l_cert_free(tls->peer_cert);
 	l_key_free(tls->peer_pubkey);
 =

 	tls->peer_cert =3D NULL;
@@ -372,9 +373,9 @@ static ssize_t tls_rsa_sign(struct l_tls *tls, uint8_t =
*out, size_t len,
 static bool tls_rsa_verify(struct l_tls *tls, const uint8_t *in, size_t le=
n,
 				tls_get_hash_t get_hash);
 =

-static bool tls_rsa_validate_cert_key(struct tls_cert *cert)
+static bool tls_rsa_validate_cert_key(struct l_cert *cert)
 {
-	return tls_cert_get_pubkey_type(cert) =3D=3D TLS_CERT_KEY_RSA;
+	return l_cert_get_pubkey_type(cert) =3D=3D L_CERT_KEY_RSA;
 }
 =

 static struct tls_key_exchange_algorithm tls_rsa =3D {
@@ -919,39 +920,56 @@ static void tls_send_server_hello(struct l_tls *tls)
 	tls_tx_handshake(tls, TLS_SERVER_HELLO, buf, ptr - buf);
 }
 =

+static bool tls_cert_list_add_size(struct l_cert *cert, void *user_data)
+{
+	size_t *total =3D user_data;
+	size_t der_len;
+
+	l_cert_get_der_data(cert, &der_len);
+	*total +=3D 3 + der_len;
+
+	return false;
+}
+
+static bool tls_cert_list_append(struct l_cert *cert, void *user_data)
+{
+	uint8_t **ptr =3D user_data;
+	const uint8_t *der;
+	size_t der_len;
+
+	der =3D l_cert_get_der_data(cert, &der_len);
+	*(*ptr)++ =3D der_len >> 16;
+	*(*ptr)++ =3D der_len >>  8;
+	*(*ptr)++ =3D der_len >>  0;
+	memcpy(*ptr, der, der_len);
+	*ptr +=3D der_len;
+
+	return false;
+}
+
 static bool tls_send_certificate(struct l_tls *tls)
 {
 	uint8_t *buf, *ptr;
-	struct tls_cert *cert, *i;
 	size_t total;
+	struct l_cert *leaf;
 =

-	if (tls->cert_path)
-		cert =3D tls_cert_load_file(tls->cert_path);
-	else
-		cert =3D NULL;
-
-	if (tls->server && !cert) {
+	if (tls->server && !tls->cert) {
 		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, TLS_ALERT_BAD_CERT,
-				"Loading server certificate %s failed",
-				tls->cert_path);
+				"Certificate needed in server mode");
 		return false;
 	}
 =

-	if (cert && !tls_cert_find_certchain(cert, tls->ca_cert_path)) {
-		if (tls->server) {
-			TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR,
-					TLS_ALERT_UNKNOWN_CA,
-					"Can't find certificate chain local "
-					"CA cert %s", tls->ca_cert_path);
-
-			return false;
-		} else
-			cert =3D NULL;
+	if (tls->cert && !l_certchain_find(tls->cert, tls->ca_cert)) {
+		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, TLS_ALERT_UNKNOWN_CA,
+				"Can't find certificate chain to local "
+				"CA cert");
+		return false;
 	}
 =

 	/* TODO: might want check this earlier and exclude the cipher suite */
-	if (cert && !tls->pending.cipher_suite->key_xchg->
-			validate_cert_key_type(cert)) {
+	leaf =3D l_certchain_get_leaf(tls->cert);
+	if (leaf && !tls->pending.cipher_suite->key_xchg->
+			validate_cert_key_type(leaf)) {
 		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, TLS_ALERT_CERT_UNKNOWN,
 				"Local certificate has key type incompatible "
 				"with pending cipher suite %s",
@@ -978,8 +996,7 @@ static bool tls_send_certificate(struct l_tls *tls)
 	 */
 =

 	total =3D 0;
-	for (i =3D cert; i; i =3D i->issuer)
-		total +=3D 3 + i->size;
+	l_certchain_foreach_from_leaf(tls->cert, tls_cert_list_add_size, &total);
 =

 	buf =3D l_malloc(128 + total);
 	ptr =3D buf + TLS_HANDSHAKE_HEADER_SIZE;
@@ -989,25 +1006,15 @@ static bool tls_send_certificate(struct l_tls *tls)
 	*ptr++ =3D total >> 16;
 	*ptr++ =3D total >>  8;
 	*ptr++ =3D total >>  0;
-
-	for (i =3D cert; i; i =3D i->issuer) {
-		*ptr++ =3D i->size >> 16;
-		*ptr++ =3D i->size >>  8;
-		*ptr++ =3D i->size >>  0;
-
-		memcpy(ptr, i->asn1, i->size);
-		ptr +=3D i->size;
-	}
+	l_certchain_foreach_from_leaf(tls->cert, tls_cert_list_append, &ptr);
 =

 	tls_tx_handshake(tls, TLS_CERTIFICATE, buf, ptr - buf);
 =

 	l_free(buf);
 =

-	if (cert)
+	if (tls->cert)
 		tls->cert_sent =3D true;
 =

-	l_free(cert);
-
 	return true;
 }
 =

@@ -1644,21 +1651,20 @@ static void tls_handle_client_hello(struct l_tls *t=
ls,
 =

 	tls_send_server_hello(tls);
 =

-	if (tls->pending.cipher_suite->key_xchg->certificate_check &&
-			tls->cert_path)
+	if (tls->pending.cipher_suite->key_xchg->certificate_check && tls->cert)
 		if (!tls_send_certificate(tls))
 			return;
 =

 	/* TODO: don't bother if configured to not authenticate client */
 	if (tls->pending.cipher_suite->key_xchg->certificate_check &&
-			tls->ca_cert_path)
+			tls->ca_cert)
 		if (!tls_send_certificate_request(tls))
 			return;
 =

 	tls_send_server_hello_done(tls);
 =

 	if (tls->pending.cipher_suite->key_xchg->certificate_check &&
-			tls->ca_cert_path)
+			tls->ca_cert)
 		TLS_SET_STATE(TLS_HANDSHAKE_WAIT_CERTIFICATE);
 	else
 		TLS_SET_STATE(TLS_HANDSHAKE_WAIT_KEY_EXCHANGE);
@@ -1772,8 +1778,10 @@ static void tls_handle_certificate(struct l_tls *tls,
 					const uint8_t *buf, size_t len)
 {
 	size_t total;
-	struct tls_cert *certchain =3D NULL;
-	struct tls_cert *ca_cert =3D NULL;
+	struct l_certchain *certchain =3D NULL;
+	struct l_cert *leaf;
+	size_t der_len;
+	const uint8_t *der;
 	bool dummy;
 =

 	if (len < 3)
@@ -1786,7 +1794,7 @@ static void tls_handle_certificate(struct l_tls *tls,
 	if (total + 3 !=3D len)
 		goto decode_error;
 =

-	if (tls_cert_from_certificate_list(buf, total, &certchain) < 0) {
+	if (tls_parse_certificate_list(buf, total, &certchain) < 0) {
 		TLS_DISCONNECT(TLS_ALERT_DECODE_ERROR, 0,
 				"Error decoding peer certificate chain");
 =

@@ -1818,22 +1826,11 @@ static void tls_handle_certificate(struct l_tls *tl=
s,
 	 * Validate the certificate chain's consistency and validate it
 	 * against our CA if we have any.
 	 */
-
-	if (tls->ca_cert_path) {
-		ca_cert =3D tls_cert_load_file(tls->ca_cert_path);
-		if (!ca_cert) {
-			TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR,
-					TLS_ALERT_BAD_CERT,
-					"Can't load %s", tls->ca_cert_path);
-
-			goto done;
-		}
-	}
-
-	if (!tls_cert_verify_certchain(certchain, ca_cert)) {
+	if (!l_certchain_verify(certchain, tls->ca_cert)) {
 		TLS_DISCONNECT(TLS_ALERT_BAD_CERT, 0,
-				"Peer certchain verification failed against "
-				"CA cert %s", tls->ca_cert_path);
+				"Peer certchain verification failed "
+				"consistency check%s",
+				tls->ca_cert ? " or against local CA cert" : "");
 =

 		goto done;
 	}
@@ -1844,8 +1841,9 @@ static void tls_handle_certificate(struct l_tls *tls,
 	 * restrictions) MUST be compatible with the selected key exchange
 	 * algorithm."
 	 */
+	leaf =3D l_certchain_get_leaf(certchain);
 	if (!tls->pending.cipher_suite->key_xchg->
-			validate_cert_key_type(certchain)) {
+			validate_cert_key_type(leaf)) {
 		TLS_DISCONNECT(TLS_ALERT_UNSUPPORTED_CERT, 0,
 				"Peer certificate key type incompatible with "
 				"pending cipher suite %s",
@@ -1854,15 +1852,11 @@ static void tls_handle_certificate(struct l_tls *tl=
s,
 		goto done;
 	}
 =

-	/* Save the end-entity cert and free the rest of the chain */
-	tls->peer_cert =3D certchain;
-	tls_cert_free_certchain(certchain->issuer);
-	certchain->issuer =3D NULL;
-	certchain =3D NULL;
-
-	tls->peer_pubkey =3D l_key_new(L_KEY_RSA, tls->peer_cert->asn1,
-					tls->peer_cert->size);
+	/* Save the end-entity certificate and free the chain */
+	der =3D l_cert_get_der_data(leaf, &der_len);
+	tls->peer_cert =3D l_cert_new_from_der(der, der_len);
 =

+	tls->peer_pubkey =3D l_cert_get_pubkey(tls->peer_cert);
 	if (!tls->peer_pubkey) {
 		TLS_DISCONNECT(TLS_ALERT_UNSUPPORTED_CERT, 0,
 				"Error loading peer public key to kernel");
@@ -1893,10 +1887,7 @@ decode_error:
 			"TLS_CERTIFICATE decode error");
 =

 done:
-	if (ca_cert)
-		l_free(ca_cert);
-
-	tls_cert_free_certchain(certchain);
+	l_certchain_free(certchain);
 }
 =

 static void tls_handle_certificate_request(struct l_tls *tls,
@@ -2148,8 +2139,8 @@ static void tls_handle_certificate_verify(struct l_tl=
s *tls,
 	 *   - If we received an (expected) Certificate Verify, we must have
 	 *     sent a Certificate Request.
 	 *   - If we sent a Certificate Request that's because
-	 *     tls->ca_cert_path is non-NULL.
-	 *   - If tls->ca_cert_path is non-NULL then tls_handle_certificate
+	 *     tls->ca_cert is non-NULL.
+	 *   - If tls->ca_cert is non-NULL then tls_handle_certificate
 	 *     will have checked the whole certificate chain to be valid and
 	 *     additionally trusted by our CA if known.
 	 *   - Additionally cipher_suite->key_xchg->verify has just confirmed
@@ -2361,7 +2352,7 @@ static void tls_handle_handshake(struct l_tls *tls, i=
nt type,
 		/*
 		 * On the client, the server's certificate is only now
 		 * verified, based on the following logic:
-		 *  - tls->ca_cert_path is non-NULL so tls_handle_certificate
+		 *  - tls->ca_cert is non-NULL so tls_handle_certificate
 		 *    (always called on the client) must have veritifed the
 		 *    server's certificate chain to be valid and additionally
 		 *    trusted by our CA.
@@ -2374,8 +2365,7 @@ static void tls_handle_handshake(struct l_tls *tls, i=
nt type,
 		 *    message (either should be enough).
 		 */
 		if (!tls->server && tls->cipher_suite[0]->key_xchg->
-				certificate_check &&
-				tls->ca_cert_path)
+				certificate_check && tls->ca_cert)
 			tls->peer_authenticated =3D true;
 =

 		tls_finished(tls);
@@ -2608,9 +2598,9 @@ LIB_EXPORT bool l_tls_set_cacert(struct l_tls *tls, c=
onst char *ca_cert_path)
 {
 	TLS_DEBUG("ca-cert-path=3D%s", ca_cert_path);
 =

-	if (tls->ca_cert_path) {
-		l_free(tls->ca_cert_path);
-		tls->ca_cert_path =3D NULL;
+	if (tls->ca_cert) {
+		l_cert_free(tls->ca_cert);
+		tls->ca_cert =3D NULL;
 	}
 =

 	if (ca_cert_path) {
@@ -2620,7 +2610,11 @@ LIB_EXPORT bool l_tls_set_cacert(struct l_tls *tls, =
const char *ca_cert_path)
 			return false;
 		}
 =

-		tls->ca_cert_path =3D l_strdup(ca_cert_path);
+		tls->ca_cert =3D tls_cert_load_file(ca_cert_path);
+		if (!tls->ca_cert) {
+			TLS_DEBUG("Error loading %s", ca_cert_path);
+			return false;
+		}
 	}
 =

 	return true;
@@ -2633,9 +2627,9 @@ LIB_EXPORT bool l_tls_set_auth_data(struct l_tls *tls=
, const char *cert_path,
 	TLS_DEBUG("cert-path=3D%s priv-key-path=3D%s priv-key-passphrase=3D%p",
 			cert_path, priv_key_path, priv_key_passphrase);
 =

-	if (tls->cert_path) {
-		l_free(tls->cert_path);
-		tls->cert_path =3D NULL;
+	if (tls->cert) {
+		l_certchain_free(tls->cert);
+		tls->cert =3D NULL;
 	}
 =

 	if (tls->priv_key) {
@@ -2644,6 +2638,17 @@ LIB_EXPORT bool l_tls_set_auth_data(struct l_tls *tl=
s, const char *cert_path,
 		tls->priv_key_size =3D 0;
 	}
 =

+	if (cert_path) {
+		struct l_cert *cert =3D tls_cert_load_file(cert_path);
+
+		if (!cert) {
+			TLS_DEBUG("Error loading %s", cert_path);
+			return false;
+		}
+
+		tls->cert =3D certchain_new_from_leaf(cert);
+	}
+
 	if (priv_key_path) {
 		uint8_t *priv_key;
 		bool is_public =3D true;
@@ -2676,9 +2681,6 @@ LIB_EXPORT bool l_tls_set_auth_data(struct l_tls *tls=
, const char *cert_path,
 		tls->priv_key_size /=3D 8;
 	}
 =

-	if (cert_path)
-		tls->cert_path =3D l_strdup(cert_path);
-
 	return true;
 }
 =

@@ -2759,59 +2761,29 @@ const char *tls_handshake_state_to_str(enum tls_han=
dshake_state state)
 	return buf;
 }
 =

-/* X509 Certificates and Certificate Chains */
-
-#define X509_CERTIFICATE_POS			0
-#define   X509_TBSCERTIFICATE_POS		  0
-#define     X509_TBSCERT_VERSION_POS		    0
-#define     X509_TBSCERT_SERIAL_POS		    1
-#define     X509_TBSCERT_SIGNATURE_POS		    2
-#define       X509_ALGORITHM_ID_ALGORITHM_POS	      0
-#define       X509_ALGORITHM_ID_PARAMS_POS	      1
-#define     X509_TBSCERT_ISSUER_DN_POS		    3
-#define     X509_TBSCERT_VALIDITY_POS		    4
-#define     X509_TBSCERT_SUBJECT_DN_POS		    5
-#define     X509_TBSCERT_SUBJECT_KEY_POS	    6
-#define       X509_SUBJECT_KEY_ALGORITHM_POS	      0
-#define       X509_SUBJECT_KEY_VALUE_POS	      1
-#define     X509_TBSCERT_ISSUER_UID_POS		    7
-#define     X509_TBSCERT_SUBJECT_UID_POS	    8
-#define     X509_TBSCERT_EXTENSIONS_POS		    9
-#define   X509_SIGNATURE_ALGORITHM_POS		  1
-#define   X509_SIGNATURE_VALUE_POS		  2
-
-struct tls_cert *tls_cert_load_file(const char *filename)
+struct l_cert *tls_cert_load_file(const char *filename)
 {
 	uint8_t *der;
 	size_t len;
-	struct tls_cert *cert;
+	struct l_cert *cert;
 =

 	der =3D l_pem_load_certificate(filename, &len);
 	if (!der)
 		return NULL;
 =

-	if (!len || der[0] !=3D ASN1_ID_SEQUENCE) {
-		l_free(der);
-		return NULL;
-	}
-
-	cert =3D l_malloc(sizeof(struct tls_cert) + len);
-	cert->size =3D len;
-	cert->issuer =3D NULL;
-	memcpy(cert->asn1, der, len);
-
+	cert =3D l_cert_new_from_der(der, len);
 	l_free(der);
-
 	return cert;
 }
 =

-int tls_cert_from_certificate_list(const void *data, size_t len,
-					struct tls_cert **out_certchain)
+int tls_parse_certificate_list(const void *data, size_t len,
+				struct l_certchain **out_certchain)
 {
 	const uint8_t *buf =3D data;
-	struct tls_cert *certchain =3D NULL, **tail =3D &certchain;
+	struct l_certchain *chain =3D NULL;
 =

 	while (len) {
+		struct l_cert *cert;
 		size_t cert_len;
 =

 		if (len < 3)
@@ -2824,24 +2796,30 @@ int tls_cert_from_certificate_list(const void *data=
, size_t len,
 		if (cert_len + 3 > len)
 			goto decode_error;
 =

-		*tail =3D l_malloc(sizeof(struct tls_cert) + cert_len);
-		(*tail)->size =3D cert_len;
-		(*tail)->issuer =3D NULL;
-		memcpy((*tail)->asn1, buf, cert_len);
+		cert =3D l_cert_new_from_der(buf, cert_len);
+		if (!cert)
+			goto decode_error;
 =

-		tail =3D &(*tail)->issuer;
+		if (!chain) {
+			chain =3D certchain_new_from_leaf(cert);
+			if (!chain)
+				goto decode_error;
+		} else
+			certchain_link_issuer(chain, cert);
 =

 		buf +=3D cert_len;
 		len -=3D cert_len + 3;
 	}
 =

 	if (out_certchain)
-		*out_certchain =3D certchain;
+		*out_certchain =3D chain;
+	else
+		l_certchain_free(chain);
 =

 	return 0;
 =

 decode_error:
-	tls_cert_free_certchain(certchain);
+	l_certchain_free(chain);
 	return -EBADMSG;
 }
 =

-- =

2.19.1


--===============6700474125392746183==--

