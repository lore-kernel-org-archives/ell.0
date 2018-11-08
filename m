Content-Type: multipart/mixed; boundary="===============1751837078322875400=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: Re: [PATCH 2/5] tls: Update tls, pem to use the l_cert type,
 drop local code
Date: Thu, 08 Nov 2018 15:20:01 -0800
Message-ID: <alpine.OSX.2.21.1811081518470.6689@dbdavenp-mobl.amr.corp.intel.com>
In-Reply-To: <20181108120651.32521-2-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1751837078322875400==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Andrew -

On Thu, 8 Nov 2018, Andrew Zaborowski wrote:

> Drop the struct tls_cert utilities and use the l_cert type for all the
> certificate operations.  tls_cert_from_certificate_list is renamed to
> tls_parse_certificate_list and moved up in the file.  l_tls_set_cacert
> return type is changed to bool so that errors in loading CA certificate
> are returned immediately instead of failing the handshake later on.
> Since this just changes a void to a bool it shouldn't break ell user
> builds.  l_pem_load_certificate is changed to return the l_cert object
> instead of a byte buffer so there's no longer to call the l_cert
> constructor separately.
> ---
> ell/pem.c         |   8 +-
> ell/pem.h         |   4 +-
> ell/tls-private.h |  38 +---
> ell/tls-record.c  |   1 +
> ell/tls.c         | 455 +++++++++++++---------------------------------
> ell/tls.h         |   2 +-
> 6 files changed, 138 insertions(+), 370 deletions(-)
>
> diff --git a/ell/pem.c b/ell/pem.c
> index e24dd7d..f4aa7e2 100644
> --- a/ell/pem.c
> +++ b/ell/pem.c
> @@ -213,13 +213,13 @@ LIB_EXPORT uint8_t *l_pem_load_file(const char *fil=
ename, int index,
> 	return result;
> }
>
> -LIB_EXPORT uint8_t *l_pem_load_certificate(const char *filename, size_t =
*len)
> +LIB_EXPORT struct l_cert *l_pem_load_certificate(const char *filename)
> {
> 	uint8_t *content;
> 	char *label;
> +	size_t len;
>
> -	content =3D l_pem_load_file(filename, 0, &label, len);
> -
> +	content =3D l_pem_load_file(filename, 0, &label, &len);
> 	if (!content)
> 		return NULL;
>
> @@ -230,7 +230,7 @@ LIB_EXPORT uint8_t *l_pem_load_certificate(const char=
 *filename, size_t *len)
>
> 	l_free(label);
>
> -	return content;
> +	return l_cert_new_from_der(content, len);

Valgrind complains about test-key (with the full series applied) - looks =

like you need to free 'content' before returning.

Mat


> }
>
> /**
> diff --git a/ell/pem.h b/ell/pem.h
> index 93282a3..9629ef2 100644
> --- a/ell/pem.h
> +++ b/ell/pem.h
> @@ -27,12 +27,14 @@
> extern "C" {
> #endif
>
> +#include <ell/cert.h>
> +
> uint8_t *l_pem_load_buffer(const uint8_t *buf, size_t buf_len,
> 				int index, char **type_label, size_t *out_len);
> uint8_t *l_pem_load_file(const char *filename, int index,
> 				char **type_label, size_t *len);
>
> -uint8_t *l_pem_load_certificate(const char *filename, size_t *len);
> +struct l_cert *l_pem_load_certificate(const char *filename);
>
> uint8_t *l_pem_load_private_key(const char *filename, const char *passphr=
ase,
> 				bool *encrypted, size_t *len);
> diff --git a/ell/tls-private.h b/ell/tls-private.h
> index 4f680a0..2257041 100644
> --- a/ell/tls-private.h
> +++ b/ell/tls-private.h
> @@ -28,8 +28,6 @@
> #define TLS_VERSION	TLS_V12
> #define TLS_MIN_VERSION	TLS_V10
>
> -struct tls_cert;
> -
> enum tls_cipher_type {
> 	TLS_CIPHER_STREAM,
> 	TLS_CIPHER_BLOCK,
> @@ -60,7 +58,7 @@ struct tls_key_exchange_algorithm {
>
> 	bool certificate_check;
>
> -	bool (*validate_cert_key_type)(struct tls_cert *cert);
> +	bool (*validate_cert_key_type)(struct l_cert *cert);
>
> 	bool (*send_client_key_exchange)(struct l_tls *tls);
> 	void (*handle_client_key_exchange)(struct l_tls *tls,
> @@ -142,8 +140,8 @@ struct l_tls {
> 	l_tls_destroy_cb_t debug_destroy;
> 	void *debug_data;
>
> -	char *ca_cert_path;
> -	char *cert_path;
> +	struct l_cert *ca_cert;
> +	struct l_cert *cert;
> 	struct l_key *priv_key;
> 	size_t priv_key_size;
>
> @@ -169,7 +167,7 @@ struct l_tls {
> 	uint16_t negotiated_version;
> 	bool cert_requested, cert_sent;
> 	bool peer_authenticated;
> -	struct tls_cert *peer_cert;
> +	struct l_cert *peer_cert;
> 	struct l_key *peer_pubkey;
> 	size_t peer_pubkey_size;
> 	enum handshake_hash_type signature_hash;
> @@ -226,32 +224,8 @@ void tls_tx_record(struct l_tls *tls, enum tls_conte=
nt_type type,
> bool tls_handle_message(struct l_tls *tls, const uint8_t *message,
> 			int len, enum tls_content_type type, uint16_t version);
>
> -/* X509 Certificates and Certificate Chains */
> -
> -struct tls_cert {
> -	size_t size;
> -	struct tls_cert *issuer;
> -	uint8_t asn1[0];
> -};
> -
> -enum tls_cert_key_type {
> -	TLS_CERT_KEY_RSA,
> -	TLS_CERT_KEY_UNKNOWN,
> -};
> -
> -struct tls_cert *tls_cert_load_file(const char *filename);
> -int tls_cert_from_certificate_list(const void *data, size_t len,
> -					struct tls_cert **out_certchain);
> -
> -bool tls_cert_find_certchain(struct tls_cert *cert,
> -				const char *cacert_filename);
> -
> -bool tls_cert_verify_certchain(struct tls_cert *certchain,
> -				struct tls_cert *ca_cert);
> -
> -void tls_cert_free_certchain(struct tls_cert *cert);
> -
> -enum tls_cert_key_type tls_cert_get_pubkey_type(struct tls_cert *cert);
> +int tls_parse_certificate_list(const void *data, size_t len,
> +				struct l_cert **out_certchain);
>
> void tls_prf_get_bytes(struct l_tls *tls,
> 				enum l_checksum_type type, size_t hash_len,
> diff --git a/ell/tls-record.c b/ell/tls-record.c
> index 8038049..410f194 100644
> --- a/ell/tls-record.c
> +++ b/ell/tls-record.c
> @@ -29,6 +29,7 @@
> #include "tls.h"
> #include "checksum.h"
> #include "cipher.h"
> +#include "cert.h"
> #include "tls-private.h"
> #include "random.h"
>
> diff --git a/ell/tls.c b/ell/tls.c
> index 4b37785..6bea5dc 100644
> --- a/ell/tls.c
> +++ b/ell/tls.c
> @@ -35,6 +35,7 @@
> #include "cipher.h"
> #include "random.h"
> #include "pem.h"
> +#include "cert.h"
> #include "tls-private.h"
> #include "key.h"
> #include "asn1-private.h"
> @@ -176,7 +177,7 @@ static void tls_reset_handshake(struct l_tls *tls)
>
> 	memset(tls->pending.key_block, 0, sizeof(tls->pending.key_block));
>
> -	l_free(tls->peer_cert);
> +	l_cert_free(tls->peer_cert);
> 	l_key_free(tls->peer_pubkey);
>
> 	tls->peer_cert =3D NULL;
> @@ -336,9 +337,9 @@ static ssize_t tls_rsa_sign(struct l_tls *tls, uint8_=
t *out, size_t len,
> static bool tls_rsa_verify(struct l_tls *tls, const uint8_t *in, size_t l=
en,
> 				tls_get_hash_t get_hash);
>
> -static bool tls_rsa_validate_cert_key(struct tls_cert *cert)
> +static bool tls_rsa_validate_cert_key(struct l_cert *cert)
> {
> -	return tls_cert_get_pubkey_type(cert) =3D=3D TLS_CERT_KEY_RSA;
> +	return l_cert_get_pubkey_type(cert) =3D=3D L_CERT_KEY_RSA;
> }
>
> static struct tls_key_exchange_algorithm tls_rsa =3D {
> @@ -611,6 +612,55 @@ static void pkcs1_write_digest_info(enum l_checksum_=
type type,
> 	*out_len +=3D hash_len;
> }
>
> +int tls_parse_certificate_list(const void *data, size_t len,
> +				struct l_cert **out_certchain)
> +{
> +	const uint8_t *buf =3D data;
> +	struct l_cert *certchain =3D NULL, *tail;
> +
> +	while (len) {
> +		struct l_cert *cert;
> +		size_t cert_len;
> +
> +		if (len < 3)
> +			goto decode_error;
> +
> +		cert_len =3D *buf++ << 16;
> +		cert_len |=3D *buf++ << 8;
> +		cert_len |=3D *buf++ << 0;
> +
> +		if (cert_len + 3 > len)
> +			goto decode_error;
> +
> +		cert =3D l_cert_new_from_der(buf, cert_len);
> +		if (!cert)
> +			goto decode_error;
> +
> +		if (!certchain)
> +			certchain =3D cert;
> +		else if (!l_cert_link_issuer(tail, cert)) {
> +			l_cert_free(cert);
> +			goto decode_error;
> +		}
> +
> +		tail =3D cert;
> +
> +		buf +=3D cert_len;
> +		len -=3D cert_len + 3;
> +	}
> +
> +	if (out_certchain)
> +		*out_certchain =3D certchain;
> +	else
> +		l_cert_free(certchain);
> +
> +	return 0;
> +
> +decode_error:
> +	l_cert_free(certchain);
> +	return -EBADMSG;
> +}
> +
> static void tls_send_alert(struct l_tls *tls, bool fatal,
> 				enum l_tls_alert_desc alert_desc)
> {
> @@ -743,36 +793,25 @@ static void tls_send_server_hello(struct l_tls *tls)
> static bool tls_send_certificate(struct l_tls *tls)
> {
> 	uint8_t *buf, *ptr;
> -	struct tls_cert *cert, *i;
> +	struct l_cert *i;
> 	size_t total;
>
> -	if (tls->cert_path)
> -		cert =3D tls_cert_load_file(tls->cert_path);
> -	else
> -		cert =3D NULL;
> -
> -	if (tls->server && !cert) {
> +	if (tls->server && !tls->cert) {
> 		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, TLS_ALERT_BAD_CERT,
> -				"Loading server certificate %s failed",
> -				tls->cert_path);
> +				"Certificate needed in server mode");
> 		return false;
> 	}
>
> -	if (cert && !tls_cert_find_certchain(cert, tls->ca_cert_path)) {
> -		if (tls->server) {
> -			TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR,
> -					TLS_ALERT_UNKNOWN_CA,
> -					"Can't find certificate chain local "
> -					"CA cert %s", tls->ca_cert_path);
> -
> -			return false;
> -		} else
> -			cert =3D NULL;
> +	if (tls->cert && !l_cert_find_certchain(tls->cert, tls->ca_cert)) {
> +		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, TLS_ALERT_UNKNOWN_CA,
> +				"Can't find certificate chain to local "
> +				"CA cert");
> +		return false;
> 	}
>
> 	/* TODO: might want check this earlier and exclude the cipher suite */
> -	if (cert && !tls->pending.cipher_suite->key_xchg->
> -			validate_cert_key_type(cert)) {
> +	if (tls->cert && !tls->pending.cipher_suite->key_xchg->
> +			validate_cert_key_type(tls->cert)) {
> 		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, TLS_ALERT_CERT_UNKNOWN,
> 				"Local certificate has key type incompatible "
> 				"with pending cipher suite %s",
> @@ -799,8 +838,12 @@ static bool tls_send_certificate(struct l_tls *tls)
> 	 */
>
> 	total =3D 0;
> -	for (i =3D cert; i; i =3D i->issuer)
> -		total +=3D 3 + i->size;
> +	for (i =3D tls->cert; i; i =3D l_cert_get_issuer(i)) {
> +		size_t der_len;
> +
> +		l_cert_get_der_data(i, &der_len);
> +		total +=3D 3 + der_len;
> +	}
>
> 	buf =3D l_malloc(128 + total);
> 	ptr =3D buf + TLS_HANDSHAKE_HEADER_SIZE;
> @@ -811,24 +854,26 @@ static bool tls_send_certificate(struct l_tls *tls)
> 	*ptr++ =3D total >>  8;
> 	*ptr++ =3D total >>  0;
>
> -	for (i =3D cert; i; i =3D i->issuer) {
> -		*ptr++ =3D i->size >> 16;
> -		*ptr++ =3D i->size >>  8;
> -		*ptr++ =3D i->size >>  0;
> +	for (i =3D tls->cert; i; i =3D l_cert_get_issuer(i)) {
> +		const uint8_t *der;
> +		size_t der_len;
>
> -		memcpy(ptr, i->asn1, i->size);
> -		ptr +=3D i->size;
> +		der =3D l_cert_get_der_data(i, &der_len);
> +		*ptr++ =3D der_len >> 16;
> +		*ptr++ =3D der_len >>  8;
> +		*ptr++ =3D der_len >>  0;
> +
> +		memcpy(ptr, der, der_len);
> +		ptr +=3D der_len;
> 	}
>
> 	tls_tx_handshake(tls, TLS_CERTIFICATE, buf, ptr - buf);
>
> 	l_free(buf);
>
> -	if (cert)
> +	if (tls->cert)
> 		tls->cert_sent =3D true;
>
> -	l_free(cert);
> -
> 	return true;
> }
>
> @@ -1413,7 +1458,7 @@ static void tls_handle_client_hello(struct l_tls *t=
ls,
> 		 * TODO: filter supported cipher suites by the certificate/key
> 		 * type that was submitted by tls_set_auth_data() if any.
> 		 * Perhaps just call cipher_suite->verify_cert_type() on each
> -		 * cipher suite passing a pre-parsed certificate ASN.1 struct.
> +		 * cipher suite passing tls->cert.
> 		 */
> 		tls->pending.cipher_suite =3D
> 					tls_find_cipher_suite(cipher_suites);
> @@ -1457,21 +1502,20 @@ static void tls_handle_client_hello(struct l_tls =
*tls,
>
> 	tls_send_server_hello(tls);
>
> -	if (tls->pending.cipher_suite->key_xchg->certificate_check &&
> -			tls->cert_path)
> +	if (tls->pending.cipher_suite->key_xchg->certificate_check && tls->cert)
> 		if (!tls_send_certificate(tls))
> 			return;
>
> 	/* TODO: don't bother if configured to not authenticate client */
> 	if (tls->pending.cipher_suite->key_xchg->certificate_check &&
> -			tls->ca_cert_path)
> +			tls->ca_cert)
> 		if (!tls_send_certificate_request(tls))
> 			return;
>
> 	tls_send_server_hello_done(tls);
>
> 	if (tls->pending.cipher_suite->key_xchg->certificate_check &&
> -			tls->ca_cert_path)
> +			tls->ca_cert)
> 		TLS_SET_STATE(TLS_HANDSHAKE_WAIT_CERTIFICATE);
> 	else
> 		TLS_SET_STATE(TLS_HANDSHAKE_WAIT_KEY_EXCHANGE);
> @@ -1570,8 +1614,7 @@ static void tls_handle_certificate(struct l_tls *tl=
s,
> 					const uint8_t *buf, size_t len)
> {
> 	size_t total;
> -	struct tls_cert *certchain =3D NULL;
> -	struct tls_cert *ca_cert =3D NULL;
> +	struct l_cert *certchain =3D NULL;
> 	bool dummy;
>
> 	if (len < 3)
> @@ -1584,7 +1627,7 @@ static void tls_handle_certificate(struct l_tls *tl=
s,
> 	if (total + 3 !=3D len)
> 		goto decode_error;
>
> -	if (tls_cert_from_certificate_list(buf, total, &certchain) < 0) {
> +	if (tls_parse_certificate_list(buf, total, &certchain) < 0) {
> 		TLS_DISCONNECT(TLS_ALERT_DECODE_ERROR, 0,
> 				"Error decoding peer certificate chain");
>
> @@ -1616,22 +1659,11 @@ static void tls_handle_certificate(struct l_tls *=
tls,
> 	 * Validate the certificate chain's consistency and validate it
> 	 * against our CA if we have any.
> 	 */
> -
> -	if (tls->ca_cert_path) {
> -		ca_cert =3D tls_cert_load_file(tls->ca_cert_path);
> -		if (!ca_cert) {
> -			TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR,
> -					TLS_ALERT_BAD_CERT,
> -					"Can't load %s", tls->ca_cert_path);
> -
> -			goto done;
> -		}
> -	}
> -
> -	if (!tls_cert_verify_certchain(certchain, ca_cert)) {
> +	if (!l_cert_verify_certchain(certchain, tls->ca_cert)) {
> 		TLS_DISCONNECT(TLS_ALERT_BAD_CERT, 0,
> -				"Peer certchain verification failed against "
> -				"CA cert %s", tls->ca_cert_path);
> +				"Peer certchain verification failed "
> +				"consistency check%s",
> +				tls->ca_cert ? " or against local CA cert" : "");
>
> 		goto done;
> 	}
> @@ -1654,13 +1686,11 @@ static void tls_handle_certificate(struct l_tls *=
tls,
>
> 	/* Save the end-entity cert and free the rest of the chain */
> 	tls->peer_cert =3D certchain;
> -	tls_cert_free_certchain(certchain->issuer);
> -	certchain->issuer =3D NULL;
> -	certchain =3D NULL;
> -
> -	tls->peer_pubkey =3D l_key_new(L_KEY_RSA, tls->peer_cert->asn1,
> -					tls->peer_cert->size);
> +	certchain =3D l_cert_get_issuer(certchain);
> +	if (certchain)
> +		l_cert_link_issuer(tls->peer_cert, NULL);
>
> +	tls->peer_pubkey =3D l_cert_get_pubkey(tls->peer_cert);
> 	if (!tls->peer_pubkey) {
> 		TLS_DISCONNECT(TLS_ALERT_UNSUPPORTED_CERT, 0,
> 				"Error loading peer public key to kernel");
> @@ -1691,10 +1721,7 @@ decode_error:
> 			"TLS_CERTIFICATE decode error");
>
> done:
> -	if (ca_cert)
> -		l_free(ca_cert);
> -
> -	tls_cert_free_certchain(certchain);
> +	l_cert_free(certchain);
> }
>
> static void tls_handle_certificate_request(struct l_tls *tls,
> @@ -1946,8 +1973,8 @@ static void tls_handle_certificate_verify(struct l_=
tls *tls,
> 	 *   - If we received an (expected) Certificate Verify, we must have
> 	 *     sent a Certificate Request.
> 	 *   - If we sent a Certificate Request that's because
> -	 *     tls->ca_cert_path is non-NULL.
> -	 *   - If tls->ca_cert_path is non-NULL then tls_handle_certificate
> +	 *     tls->ca_cert is non-NULL.
> +	 *   - If tls->ca_cert is non-NULL then tls_handle_certificate
> 	 *     will have checked the whole certificate chain to be valid and
> 	 *     additionally trusted by our CA if known.
> 	 *   - Additionally cipher_suite->key_xchg->verify has just confirmed
> @@ -2159,7 +2186,7 @@ static void tls_handle_handshake(struct l_tls *tls,=
 int type,
> 		/*
> 		 * On the client, the server's certificate is only now
> 		 * verified, based on the following logic:
> -		 *  - tls->ca_cert_path is non-NULL so tls_handle_certificate
> +		 *  - tls->ca_cert is non-NULL so tls_handle_certificate
> 		 *    (always called on the client) must have veritifed the
> 		 *    server's certificate chain to be valid and additionally
> 		 *    trusted by our CA.
> @@ -2172,8 +2199,7 @@ static void tls_handle_handshake(struct l_tls *tls,=
 int type,
> 		 *    message (either should be enough).
> 		 */
> 		if (!tls->server && tls->cipher_suite[0]->key_xchg->
> -				certificate_check &&
> -				tls->ca_cert_path)
> +				certificate_check && tls->ca_cert)
> 			tls->peer_authenticated =3D true;
>
> 		tls_finished(tls);
> @@ -2400,17 +2426,24 @@ LIB_EXPORT void l_tls_close(struct l_tls *tls)
> 	TLS_DISCONNECT(TLS_ALERT_CLOSE_NOTIFY, 0, "Closing session");
> }
>
> -LIB_EXPORT void l_tls_set_cacert(struct l_tls *tls, const char *ca_cert_=
path)
> +LIB_EXPORT bool l_tls_set_cacert(struct l_tls *tls, const char *ca_cert_=
path)
> {
> 	TLS_DEBUG("ca-cert-path=3D%s", ca_cert_path);
>
> -	if (tls->ca_cert_path) {
> -		l_free(tls->ca_cert_path);
> -		tls->ca_cert_path =3D NULL;
> +	if (tls->ca_cert) {
> +		l_cert_free(tls->ca_cert);
> +		tls->ca_cert =3D NULL;
> 	}
>
> -	if (ca_cert_path)
> -		tls->ca_cert_path =3D l_strdup(ca_cert_path);
> +	if (ca_cert_path) {
> +		tls->ca_cert =3D l_pem_load_certificate(ca_cert_path);
> +		if (!tls->ca_cert) {
> +			TLS_DEBUG("Error loading %s", ca_cert_path);
> +			return false;
> +		}
> +	}
> +
> +	return true;
> }
>
> LIB_EXPORT bool l_tls_set_auth_data(struct l_tls *tls, const char *cert_p=
ath,
> @@ -2420,9 +2453,9 @@ LIB_EXPORT bool l_tls_set_auth_data(struct l_tls *t=
ls, const char *cert_path,
> 	TLS_DEBUG("cert-path=3D%s priv-key-path=3D%s priv-key-passphrase=3D%p",
> 			cert_path, priv_key_path, priv_key_passphrase);
>
> -	if (tls->cert_path) {
> -		l_free(tls->cert_path);
> -		tls->cert_path =3D NULL;
> +	if (tls->cert) {
> +		l_cert_free(tls->cert);
> +		tls->cert =3D NULL;
> 	}
>
> 	if (tls->priv_key) {
> @@ -2431,6 +2464,14 @@ LIB_EXPORT bool l_tls_set_auth_data(struct l_tls *=
tls, const char *cert_path,
> 		tls->priv_key_size =3D 0;
> 	}
>
> +	if (cert_path) {
> +		tls->cert =3D l_pem_load_certificate(cert_path);
> +		if (!tls->cert) {
> +			TLS_DEBUG("Error loading %s", cert_path);
> +			return false;
> +		}
> +	}
> +
> 	if (priv_key_path) {
> 		uint8_t *priv_key;
> 		bool is_public =3D true;
> @@ -2463,9 +2504,6 @@ LIB_EXPORT bool l_tls_set_auth_data(struct l_tls *t=
ls, const char *cert_path,
> 		tls->priv_key_size /=3D 8;
> 	}
>
> -	if (cert_path)
> -		tls->cert_path =3D l_strdup(cert_path);
> -
> 	return true;
> }
>
> @@ -2546,253 +2584,6 @@ const char *tls_handshake_state_to_str(enum tls_h=
andshake_state state)
> 	return buf;
> }
>
> -/* X509 Certificates and Certificate Chains */
> -
> -#define X509_CERTIFICATE_POS			0
> -#define   X509_TBSCERTIFICATE_POS		  0
> -#define     X509_TBSCERT_VERSION_POS		    0
> -#define     X509_TBSCERT_SERIAL_POS		    1
> -#define     X509_TBSCERT_SIGNATURE_POS		    2
> -#define       X509_ALGORITHM_ID_ALGORITHM_POS	      0
> -#define       X509_ALGORITHM_ID_PARAMS_POS	      1
> -#define     X509_TBSCERT_ISSUER_DN_POS		    3
> -#define     X509_TBSCERT_VALIDITY_POS		    4
> -#define     X509_TBSCERT_SUBJECT_DN_POS		    5
> -#define     X509_TBSCERT_SUBJECT_KEY_POS	    6
> -#define       X509_SUBJECT_KEY_ALGORITHM_POS	      0
> -#define       X509_SUBJECT_KEY_VALUE_POS	      1
> -#define     X509_TBSCERT_ISSUER_UID_POS		    7
> -#define     X509_TBSCERT_SUBJECT_UID_POS	    8
> -#define     X509_TBSCERT_EXTENSIONS_POS		    9
> -#define   X509_SIGNATURE_ALGORITHM_POS		  1
> -#define   X509_SIGNATURE_VALUE_POS		  2
> -
> -struct tls_cert *tls_cert_load_file(const char *filename)
> -{
> -	uint8_t *der;
> -	size_t len;
> -	struct tls_cert *cert;
> -
> -	der =3D l_pem_load_certificate(filename, &len);
> -	if (!der)
> -		return NULL;
> -
> -	if (!len || der[0] !=3D ASN1_ID_SEQUENCE) {
> -		l_free(der);
> -		return NULL;
> -	}
> -
> -	cert =3D l_malloc(sizeof(struct tls_cert) + len);
> -	cert->size =3D len;
> -	cert->issuer =3D NULL;
> -	memcpy(cert->asn1, der, len);
> -
> -	l_free(der);
> -
> -	return cert;
> -}
> -
> -int tls_cert_from_certificate_list(const void *data, size_t len,
> -					struct tls_cert **out_certchain)
> -{
> -	const uint8_t *buf =3D data;
> -	struct tls_cert *certchain =3D NULL, **tail =3D &certchain;
> -
> -	while (len) {
> -		size_t cert_len;
> -
> -		if (len < 3)
> -			goto decode_error;
> -
> -		cert_len =3D *buf++ << 16;
> -		cert_len |=3D *buf++ << 8;
> -		cert_len |=3D *buf++ << 0;
> -
> -		if (cert_len + 3 > len)
> -			goto decode_error;
> -
> -		*tail =3D l_malloc(sizeof(struct tls_cert) + cert_len);
> -		(*tail)->size =3D cert_len;
> -		(*tail)->issuer =3D NULL;
> -		memcpy((*tail)->asn1, buf, cert_len);
> -
> -		tail =3D &(*tail)->issuer;
> -
> -		buf +=3D cert_len;
> -		len -=3D cert_len + 3;
> -	}
> -
> -	if (out_certchain)
> -		*out_certchain =3D certchain;
> -
> -	return 0;
> -
> -decode_error:
> -	tls_cert_free_certchain(certchain);
> -	return -EBADMSG;
> -}
> -
> -bool tls_cert_find_certchain(struct tls_cert *cert,
> -				const char *cacert_filename)
> -{
> -	return true;
> -}
> -
> -static const struct pkcs1_encryption_oid {
> -	enum tls_cert_key_type key_type;
> -	struct asn1_oid oid;
> -} pkcs1_encryption_oids[] =3D {
> -	{ /* rsaEncryption */
> -		TLS_CERT_KEY_RSA,
> -		{ 9, { 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01, 0x01 } },
> -	},
> -};
> -
> -static void tls_key_cleanup(struct l_key **p)
> -{
> -	l_key_free_norevoke(*p);
> -}
> -
> -static bool tls_cert_verify_with_keyring(struct tls_cert *cert,
> -						struct l_keyring *ring,
> -						struct tls_cert *root,
> -						struct l_keyring *trusted)
> -{
> -	if (!cert)
> -		return true;
> -
> -	/*
> -	 * RFC5246 7.4.2:
> -	 * "Because certificate validation requires that root keys be
> -	 * distributed independently, the self-signed certificate that
> -	 * specifies the root certificate authority MAY be omitted from
> -	 * the chain, under the assumption that the remote end must
> -	 * already possess it in order to validate it in any case."
> -	 */
> -	if (!cert->issuer && root && cert->size =3D=3D root->size &&
> -			!memcmp(cert->asn1, root->asn1, root->size))
> -		return true;
> -
> -	if (tls_cert_verify_with_keyring(cert->issuer, ring, root, trusted)) {
> -		L_AUTO_CLEANUP_VAR(struct l_key *, key, tls_key_cleanup);
> -
> -		key =3D l_key_new(L_KEY_RSA, cert->asn1, cert->size);
> -		if (!key)
> -			return false;
> -
> -		if (!l_keyring_link(ring, key))
> -			return false;
> -
> -		if (trusted || cert->issuer)
> -			return true;
> -
> -		/*
> -		 * If execution reaches this point, it's known that:
> -		 *  * No trusted root key was supplied, so the chain is only
> -		 *    being checked against its own root
> -		 *  * The keyring 'ring' is not restricted yet
> -		 *  * The chain's root cert was just linked in to the
> -		 *    previously empty keyring 'ring'.
> -		 *
> -		 *  By restricting 'ring' now, the rest of the certs in
> -		 *  the chain will have their signature validated using 'key'
> -		 *  as the root.
> -		 */
> -		return l_keyring_restrict(ring,	L_KEYRING_RESTRICT_ASYM_CHAIN,
> -						trusted);
> -	}
> -
> -	return false;
> -}
> -
> -static void tls_keyring_cleanup(struct l_keyring **p)
> -{
> -	l_keyring_free(*p);
> -}
> -
> -bool tls_cert_verify_certchain(struct tls_cert *certchain,
> -				struct tls_cert *ca_cert)
> -{
> -	L_AUTO_CLEANUP_VAR(struct l_keyring *, ca_ring, tls_keyring_cleanup);
> -	L_AUTO_CLEANUP_VAR(struct l_keyring *, verify_ring,
> -				tls_keyring_cleanup);
> -
> -	ca_ring =3D NULL;
> -	verify_ring =3D NULL;
> -
> -	if (ca_cert) {
> -		L_AUTO_CLEANUP_VAR(struct l_key *, ca_key, tls_key_cleanup);
> -		ca_key =3D NULL;
> -
> -		ca_ring =3D l_keyring_new();
> -		if (!ca_ring)
> -			return false;
> -
> -		ca_key =3D l_key_new(L_KEY_RSA, ca_cert->asn1, ca_cert->size);
> -		if (!ca_key || !l_keyring_link(ca_ring, ca_key))
> -			return false;
> -	}
> -
> -	verify_ring =3D l_keyring_new();
> -	if (!verify_ring)
> -		return false;
> -
> -	/*
> -	 * If a CA cert was supplied, restrict verify_ring now so
> -	 * everything else in certchain is validated against the CA.
> -	 * Otherwise, verify_ring will be restricted after the root of
> -	 * certchain is added to verify_ring by
> -	 * tls_cert_verify_with_keyring().
> -	 */
> -	if (ca_ring && !l_keyring_restrict(verify_ring,
> -						L_KEYRING_RESTRICT_ASYM_CHAIN,
> -						ca_ring)) {
> -		return false;
> -	}
> -
> -	return tls_cert_verify_with_keyring(certchain, verify_ring, ca_cert,
> -						ca_ring);
> -}
> -
> -void tls_cert_free_certchain(struct tls_cert *cert)
> -{
> -	struct tls_cert *next;
> -
> -	while (cert) {
> -		next =3D cert->issuer;
> -		l_free(cert);
> -		cert =3D next;
> -	}
> -}
> -
> -enum tls_cert_key_type tls_cert_get_pubkey_type(struct tls_cert *cert)
> -{
> -	const uint8_t *key_type;
> -	size_t key_type_len;
> -	int i;
> -
> -	key_type =3D asn1_der_find_elem_by_path(cert->asn1, cert->size,
> -						ASN1_ID_OID, &key_type_len,
> -						X509_CERTIFICATE_POS,
> -						X509_TBSCERTIFICATE_POS,
> -						X509_TBSCERT_SUBJECT_KEY_POS,
> -						X509_SUBJECT_KEY_ALGORITHM_POS,
> -						X509_ALGORITHM_ID_ALGORITHM_POS,
> -						-1);
> -	if (!key_type)
> -		return TLS_CERT_KEY_UNKNOWN;
> -
> -	for (i =3D 0; i < (int) L_ARRAY_SIZE(pkcs1_encryption_oids); i++)
> -		if (asn1_oid_eq(&pkcs1_encryption_oids[i].oid,
> -					key_type_len, key_type))
> -			break;
> -
> -	if (i =3D=3D L_ARRAY_SIZE(pkcs1_encryption_oids))
> -		return TLS_CERT_KEY_UNKNOWN;
> -
> -	return pkcs1_encryption_oids[i].key_type;
> -}
> -
> LIB_EXPORT bool l_tls_set_debug(struct l_tls *tls, l_tls_debug_cb_t funct=
ion,
> 				void *user_data, l_tls_destroy_cb_t destroy)
> {
> diff --git a/ell/tls.h b/ell/tls.h
> index 893fd63..5008200 100644
> --- a/ell/tls.h
> +++ b/ell/tls.h
> @@ -87,7 +87,7 @@ void l_tls_write(struct l_tls *tls, const uint8_t *data=
, size_t len);
> void l_tls_handle_rx(struct l_tls *tls, const uint8_t *data, size_t len);
>
> /* If peer is to be authenticated, supply the CA certificate */
> -void l_tls_set_cacert(struct l_tls *tls, const char *ca_cert_path);
> +bool l_tls_set_cacert(struct l_tls *tls, const char *ca_cert_path);
>
> /*
>  * If we are to be authenticated, supply our certificate, private key and
> -- =

> 2.19.1
>
> _______________________________________________
> ell mailing list
> ell(a)lists.01.org
> https://lists.01.org/mailman/listinfo/ell
>

--
Mat Martineau
Intel OTC

--===============1751837078322875400==--

