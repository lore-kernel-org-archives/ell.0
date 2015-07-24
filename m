Content-Type: multipart/mixed; boundary="===============0234412146145502381=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 14/17] tls: TLS 1.2 Handshake implementation.
Date: Fri, 24 Jul 2015 05:27:49 +0200
Message-ID: <1437708472-28124-5-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1437708472-28124-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0234412146145502381==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The Handshake Protocol (RFC5246 section 7) runs on top of the Record
protocol and carries out the cryptographic negotiation.  Only version
1.2 is implemented here.  It distinguishes server and client roles.
I have tested both the client and server roles against OpenSSL as
server and client and ell against ell.  I've also now tested the server
against Firefox as https client and the client against a few popular
https websites.
---
 ell/tls.c | 1078 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++=
++++
 1 file changed, 1078 insertions(+)

diff --git a/ell/tls.c b/ell/tls.c
index 312a42b..8d88ea4 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -76,6 +76,13 @@ void tls12_prf(enum l_checksum_type type, size_t hash_le=
n,
 	l_checksum_free(hmac);
 }
 =

+static void tls_write_random(uint8_t *buf)
+{
+	l_put_be32(time(NULL), buf);
+
+	l_getrandom(buf + 4, 28);
+}
+
 static void tls_reset_handshake(struct l_tls *tls)
 {
 	memset(tls->pending.master_secret, 0, 48);
@@ -249,6 +256,283 @@ static struct tls_compression_method *tls_find_compre=
ssion_method(
 	return NULL;
 }
 =

+static uint8_t tls_cert_type_pref[] =3D {
+};
+
+struct tls_signature_hash_algorithms {
+	uint8_t hash_id;
+	uint8_t signature_id;
+};
+
+static struct tls_signature_hash_algorithms tls_signature_hash_pref[] =3D {
+};
+
+enum tls_handshake_type {
+	TLS_HELLO_REQUEST	=3D 0,
+	TLS_CLIENT_HELLO	=3D 1,
+	TLS_SERVER_HELLO	=3D 2,
+	TLS_CERTIFICATE		=3D 11,
+	TLS_SERVER_KEY_EXCHANGE	=3D 12,
+	TLS_CERTIFICATE_REQUEST	=3D 13,
+	TLS_SERVER_HELLO_DONE	=3D 14,
+	TLS_CERTIFICATE_VERIFY	=3D 15,
+	TLS_CLIENT_KEY_EXCHANGE	=3D 16,
+	TLS_FINISHED		=3D 20,
+};
+
+#define TLS_HANDSHAKE_HEADER_SIZE	4
+
+static void tls_tx_handshake(struct l_tls *tls, int type, uint8_t *buf,
+				size_t length)
+{
+	/* Fill in the handshake header */
+
+	buf[0] =3D type;
+	buf[1] =3D (length - TLS_HANDSHAKE_HEADER_SIZE) >> 16;
+	buf[2] =3D (length - TLS_HANDSHAKE_HEADER_SIZE) >>  8;
+	buf[3] =3D (length - TLS_HANDSHAKE_HEADER_SIZE) >>  0;
+
+	l_checksum_update(tls->handshake_hash, buf, length);
+
+	tls_tx_record(tls, TLS_CT_HANDSHAKE, buf, length);
+}
+
+static void tls_send_client_hello(struct l_tls *tls)
+{
+	uint8_t buf[128 + L_ARRAY_SIZE(tls_compression_pref) +
+			2 * L_ARRAY_SIZE(tls_cipher_suite_pref)];
+	uint8_t *ptr =3D buf + TLS_HANDSHAKE_HEADER_SIZE;
+	int i;
+
+	/* Fill in the Client Hello body */
+
+	*ptr++ =3D (uint8_t) (TLS_VERSION >> 8);
+	*ptr++ =3D (uint8_t) (TLS_VERSION >> 0);
+
+	tls_write_random(tls->pending.client_random);
+	memcpy(ptr, tls->pending.client_random, 32);
+	ptr +=3D 32;
+
+	*ptr++ =3D 0; /* No SessionID */
+
+	/*
+	 * We can list all supported key exchange mechanisms regardless of the
+	 * certificate type we are actually presenting (if any).
+	 *
+	 * TODO: perhaps scan /proc/crypto for supported ciphers so we don't
+	 * include ones that will cause an internal error later in the
+	 * handshake.  We can add camellia whan this is done.
+	 */
+	l_put_be16(L_ARRAY_SIZE(tls_cipher_suite_pref) * 2, ptr);
+	ptr +=3D 2;
+	for (i =3D 0; i < (int) L_ARRAY_SIZE(tls_cipher_suite_pref); i++) {
+		*ptr++ =3D tls_cipher_suite_pref[i].id[0];
+		*ptr++ =3D tls_cipher_suite_pref[i].id[1];
+	}
+
+	*ptr++ =3D L_ARRAY_SIZE(tls_compression_pref);
+	for (i =3D 0; i < (int) L_ARRAY_SIZE(tls_compression_pref); i++)
+		*ptr++ =3D tls_compression_pref[i].id;
+
+	tls_tx_handshake(tls, TLS_CLIENT_HELLO, buf, ptr - buf);
+}
+
+static void tls_send_server_hello(struct l_tls *tls)
+{
+	uint8_t buf[128];
+	uint8_t *ptr =3D buf + TLS_HANDSHAKE_HEADER_SIZE;
+
+	/* Fill in the Server Hello body */
+
+	*ptr++ =3D tls->negotiated_version >> 8;
+	*ptr++ =3D tls->negotiated_version >> 0;
+
+	tls_write_random(tls->pending.server_random);
+	memcpy(ptr, tls->pending.server_random, 32);
+	ptr +=3D 32;
+
+	*ptr++ =3D 0; /* Sessions are not cached */
+
+	*ptr++ =3D tls->pending.cipher_suite->id[0];
+	*ptr++ =3D tls->pending.cipher_suite->id[1];
+
+	*ptr++ =3D tls->pending.compression_method->id;
+
+	tls_tx_handshake(tls, TLS_SERVER_HELLO, buf, ptr - buf);
+}
+
+static bool tls_send_certificate(struct l_tls *tls)
+{
+	uint8_t *buf, *ptr;
+	struct l_cert *cert, *i;
+	size_t total;
+
+	if (tls->cert_path) {
+		cert =3D l_cert_load_file(tls->cert_path);
+
+		if (tls->server && !cert) {
+			tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR,
+					TLS_ALERT_BAD_CERT);
+
+			return false;
+		}
+	} else
+		cert =3D NULL;
+
+	if (cert && !l_cert_find_certchain(cert, tls->ca_cert_path)) {
+		if (tls->server) {
+			tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR,
+					TLS_ALERT_UNKNOWN_CA);
+
+			return false;
+		} else
+			cert =3D NULL;
+	}
+
+	/* TODO: might want check this earlier and exclude the cipher suite */
+	if (cert && !tls->pending.cipher_suite->key_xchg->
+			validate_cert_key_type(cert)) {
+		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR,
+				TLS_ALERT_CERT_UNKNOWN);
+
+		return false;
+	}
+
+	/*
+	 * TODO: check that the certificate is compatible with hash and
+	 * signature algorithms lists supplied to us in the Client Hello
+	 * extensions (if we're a server) or in the Certificate Request
+	 * (if we act as a 1.2+ client).
+	 *
+	 *  - for the hash and signature_algorithms list, check all
+	 *    certs in the cert chain.
+	 *
+	 *  - also if !cipher_suite->key_xchg->key_exchange_msg, check that the
+	 *    end entity certificate's key type matches and is usable with some
+	 *    hash/signature pair.
+	 *
+	 *  - on client check if any of the supplied DNs (if any) match
+	 *    anything in our cert chain.
+	 */
+
+	total =3D 0;
+	for (i =3D cert; i; i =3D i->issuer)
+		total +=3D 3 + i->size;
+
+	buf =3D l_malloc(128 + total);
+	ptr =3D buf + TLS_HANDSHAKE_HEADER_SIZE;
+
+	/* Fill in the Certificate body */
+
+	*ptr++ =3D total >> 16;
+	*ptr++ =3D total >>  8;
+	*ptr++ =3D total >>  0;
+
+	for (i =3D cert; i; i =3D i->issuer) {
+		*ptr++ =3D i->size >> 16;
+		*ptr++ =3D i->size >>  8;
+		*ptr++ =3D i->size >>  0;
+
+		memcpy(ptr, i->asn1, i->size);
+		ptr +=3D i->size;
+	}
+
+	tls_tx_handshake(tls, TLS_CERTIFICATE, buf, ptr - buf);
+
+	l_free(buf);
+
+	if (cert)
+		tls->cert_sent =3D true;
+
+	return true;
+}
+
+static bool tls_send_certificate_request(struct l_tls *tls)
+{
+	uint8_t *buf, *ptr, *dn_ptr;
+	int i;
+	struct l_cert *ca_cert;
+	uint8_t *ca_name;
+	int ca_name_len;
+
+	/* TODO: support multiple CAs if directory path given */
+	ca_cert =3D l_cert_load_file(tls->ca_cert_path);
+	if (!ca_cert) {
+		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR,
+				TLS_ALERT_BAD_CERT);
+
+		return false;
+	}
+
+	ca_name =3D l_cert_find_dn(ca_cert, false, &ca_name_len);
+	if (!ca_name) {
+		l_free(ca_cert);
+		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR,
+				TLS_ALERT_BAD_CERT);
+
+		return false;
+	}
+
+	buf =3D l_malloc(128 + L_ARRAY_SIZE(tls_cert_type_pref) +
+			2 * L_ARRAY_SIZE(tls_signature_hash_pref) +
+			strlen((char *) ca_name));
+	ptr =3D buf + TLS_HANDSHAKE_HEADER_SIZE;
+
+	/* Fill in the Certificate Request body */
+
+	*ptr++ =3D L_ARRAY_SIZE(tls_cert_type_pref);
+	for (i =3D 0; i < (int) L_ARRAY_SIZE(tls_cert_type_pref); i++)
+		*ptr++ =3D tls_cert_type_pref[i];
+
+	/*
+	 * This only makes sense as a variable-length field, assume there's
+	 * a typo in RFC5246 7.4.4 here.
+	 *
+	 * TODO: we support the full list of hash algorithms when used
+	 * in the client certificate chain but we can only verify the
+	 * Certificate Verify signature when the hash algorithm matches
+	 * HANDSHAKE_HASH_TYPE_TLS.  The values we include here will
+	 * affect both of these steps so revisit which set we're passing
+	 * here.
+	 *
+	 * TODO: not present in TLS 1.0
+	 */
+	l_put_be16(L_ARRAY_SIZE(tls_signature_hash_pref) * 2, ptr);
+	ptr +=3D 2;
+	for (i =3D 0; i < (int) L_ARRAY_SIZE(tls_signature_hash_pref); i++) {
+		*ptr++ =3D tls_signature_hash_pref[i].hash_id;
+		*ptr++ =3D tls_signature_hash_pref[i].signature_id;
+	}
+
+	dn_ptr =3D ptr;
+	ptr +=3D 4;				/* Leave space for sizes */
+	*ptr++ =3D ASN1_ID_SEQUENCE;		/* DER outer SEQUENCE tag */
+	write_asn1_definite_length(&ptr, ca_name_len); /* length */
+	memcpy(ptr, ca_name, ca_name_len);	/* value */
+	ptr +=3D ca_name_len;
+
+	ca_name_len =3D ptr - dn_ptr - 4;
+	l_put_be16(ca_name_len + 2, dn_ptr);	/* DistinguishedNames size */
+	l_put_be16(ca_name_len, dn_ptr + 2);	/* DistinguishedName[0] size */
+
+	tls_tx_handshake(tls, TLS_CERTIFICATE_REQUEST, buf, ptr - buf);
+
+	l_free(ca_cert);
+	l_free(buf);
+
+	return true;
+}
+
+static void tls_send_server_hello_done(struct l_tls *tls)
+{
+	uint8_t buf[32];
+
+	/* No body */
+
+	tls_tx_handshake(tls, TLS_SERVER_HELLO_DONE, buf,
+				TLS_HANDSHAKE_HEADER_SIZE);
+}
+
 static void tls_generate_master_secret(struct l_tls *tls,
 					const uint8_t *pre_master_secret,
 					int pre_master_secret_len)
@@ -295,6 +579,710 @@ static void tls_get_handshake_hash(struct l_tls *tls,=
 uint8_t *out)
 	l_checksum_free(hash);
 }
 =

+static bool tls_send_certificate_verify(struct l_tls *tls)
+{
+	uint8_t buf[2048];
+	uint8_t *ptr =3D buf + TLS_HANDSHAKE_HEADER_SIZE;
+	uint8_t hash[HANDSHAKE_HASH_SIZE];
+
+	/* Fill in the Certificate Verify body */
+
+	tls_get_handshake_hash(tls, hash);
+
+	if (!tls->pending.cipher_suite->key_xchg->sign(tls, &ptr, hash))
+		return false;
+
+	tls_tx_handshake(tls, TLS_CERTIFICATE_VERIFY, buf, ptr - buf);
+
+	return true;
+}
+
+static void tls_send_change_cipher_spec(struct l_tls *tls)
+{
+	uint8_t buf =3D 1;
+
+	tls_tx_record(tls, TLS_CT_CHANGE_CIPHER_SPEC, &buf, 1);
+}
+
+static void tls_send_finished(struct l_tls *tls)
+{
+	uint8_t buf[512];
+	uint8_t *ptr =3D buf + TLS_HANDSHAKE_HEADER_SIZE;
+	uint8_t seed[HANDSHAKE_HASH_SIZE];
+
+	/*
+	 * Same hash type as that used for the PRF, i.e. SHA256 unless an
+	 * exotic cipher suite was negotiated that dictates a different
+	 * hash for the PRF and for the Finished hash.  We don't support
+	 * any such ciphers so it's always SHA256.
+	 */
+	tls_get_handshake_hash(tls, seed);
+
+	tls12_prf(L_CHECKSUM_SHA256, 32, tls->pending.master_secret, 48,
+			tls->server ? "server finished" : "client finished",
+			seed, sizeof(seed),
+			ptr, tls->cipher_suite[1]->verify_data_length);
+	ptr +=3D tls->cipher_suite[1]->verify_data_length;
+
+	tls_tx_handshake(tls, TLS_FINISHED, buf, ptr - buf);
+}
+
+static bool tls_verify_finished(struct l_tls *tls, const uint8_t *received,
+				size_t len)
+{
+	uint8_t expected[tls->cipher_suite[0]->verify_data_length];
+
+	if (len !=3D (size_t) tls->cipher_suite[0]->verify_data_length) {
+		tls_disconnect(tls, TLS_ALERT_DECODE_ERROR, 0);
+
+		return false;
+	}
+
+	tls12_prf(L_CHECKSUM_SHA256, 32, tls->pending.master_secret, 48,
+			tls->server ? "client finished" : "server finished",
+			tls->prev_digest, HANDSHAKE_HASH_SIZE,
+			expected, tls->cipher_suite[0]->verify_data_length);
+
+	if (memcmp(received, expected, len)) {
+		tls_disconnect(tls, TLS_ALERT_DECRYPT_ERROR, 0);
+
+		return false;
+	}
+
+	return true;
+}
+
+static void tls_handle_client_hello(struct l_tls *tls,
+					const uint8_t *buf, size_t len)
+{
+	uint16_t cipher_suites_size;
+	uint8_t session_id_size, compression_methods_size;
+	const uint8_t *cipher_suites;
+	const uint8_t *compression_methods;
+
+	/* Length checks */
+
+	if (len < 2 + 32 + 1)
+		goto decode_error;
+	memcpy(tls->pending.client_random, buf + 2, 32);
+	session_id_size =3D buf[34];
+	len -=3D 35;
+
+	if (len < (size_t) session_id_size + 4)
+		goto decode_error;
+	len -=3D session_id_size + 2;
+
+	cipher_suites_size =3D l_get_be16(buf + 35 + session_id_size);
+	cipher_suites =3D buf + 37 + session_id_size;
+	if (len < (size_t) cipher_suites_size + 2 ||
+			(cipher_suites_size & 1) || cipher_suites_size =3D=3D 0)
+		goto decode_error;
+	len -=3D cipher_suites_size + 1;
+
+	compression_methods_size =3D cipher_suites[cipher_suites_size];
+	compression_methods =3D cipher_suites + cipher_suites_size + 1;
+	if (len < (size_t) compression_methods_size ||
+			compression_methods =3D=3D 0)
+		goto decode_error;
+	len -=3D compression_methods_size;
+
+	if (len) {
+		uint16_t extensions_size;
+
+		if (len < 2 || len > 2 + 65535)
+			goto decode_error;
+
+		extensions_size =3D l_get_be16(compression_methods +
+						compression_methods_size);
+		len -=3D 2;
+
+		if (len !=3D extensions_size)
+			goto decode_error;
+
+		/* TODO: validate each extension in the vector, 7.4.1.4 */
+		/* TODO: check for duplicates? */
+	}
+
+	/*
+	 * Note: if the client is supplying a SessionID we know it is false
+	 * because our server implementation never generates any SessionIDs
+	 * yet so either the client is attempting something strange or was
+	 * trying to connect somewhere else.  We might want to throw an error.
+	 */
+
+	/*
+	 * TODO: Obligatory in 1.2: check for signature_algorithms extension,
+	 * store the list of algorithms for later checking in
+	 * tls_send_certificate on both server and client sides.  If not
+	 * present assume only SHA1+RSA (7.4.1.4.1).
+	 */
+
+	/* Save client_version for Premaster Secret verification */
+	tls->client_version =3D l_get_be16(buf);
+
+	if (tls->client_version < TLS_MIN_VERSION) {
+		tls_disconnect(tls, TLS_ALERT_PROTOCOL_VERSION, 0);
+		return;
+	}
+	tls->negotiated_version =3D TLS_VERSION < tls->client_version ?
+		TLS_VERSION : tls->client_version;
+
+	/* Select a cipher suite according to client's preference list */
+
+	while (cipher_suites_size) {
+		/*
+		 * TODO: filter supported cipher suites by the certificate/key
+		 * type that was submitted by tls_set_auth_data() if any.
+		 * Perhaps just call cipher_suite->verify_cert_type() on each
+		 * cipher suite passing a pre-parsed certificate ASN.1 struct.
+		 */
+		tls->pending.cipher_suite =3D
+			tls_find_cipher_suite(cipher_suites);
+		if (tls->pending.cipher_suite)
+			break;
+
+		cipher_suites +=3D 2;
+		cipher_suites_size -=3D 2;
+	}
+	if (!cipher_suites_size) {
+		tls_disconnect(tls, TLS_ALERT_HANDSHAKE_FAIL, 0);
+		return;
+	}
+
+	/* Select a compression method */
+
+	/* CompressionMethod.null must be present in the vector */
+	if (!memchr(compression_methods, 0, compression_methods_size))
+		goto decode_error;
+
+	while (compression_methods_size) {
+		tls->pending.compression_method =3D
+			tls_find_compression_method(*compression_methods);
+		if (tls->pending.compression_method)
+			break;
+
+		compression_methods++;
+		compression_methods_size--;
+	}
+
+	tls_send_server_hello(tls);
+
+	if (tls->pending.cipher_suite->key_xchg->certificate_check &&
+			tls->cert_path)
+		if (!tls_send_certificate(tls))
+			return;
+
+	if (tls->pending.cipher_suite->key_xchg->key_exchange_msg)
+		if (!tls->pending.cipher_suite->key_xchg->
+				send_server_key_exchange(tls))
+			return;
+
+	/* TODO: don't bother if configured to not authenticate client */
+	if (tls->pending.cipher_suite->key_xchg->certificate_check &&
+			tls->ca_cert_path)
+		if (!tls_send_certificate_request(tls))
+			return;
+
+	tls_send_server_hello_done(tls);
+
+	if (tls->pending.cipher_suite->key_xchg->certificate_check &&
+			tls->ca_cert_path)
+		tls->state =3D TLS_HANDSHAKE_WAIT_CERTIFICATE;
+	else
+		tls->state =3D TLS_HANDSHAKE_WAIT_KEY_EXCHANGE;
+
+	return;
+
+decode_error:
+	tls_disconnect(tls, TLS_ALERT_DECODE_ERROR, 0);
+}
+
+static void tls_handle_server_hello(struct l_tls *tls,
+					const uint8_t *buf, size_t len)
+{
+	uint8_t session_id_size, cipher_suite_id[2], compression_method_id;
+
+	/* Length checks */
+
+	if (len < 2 + 32 + 1)
+		goto decode_error;
+	memcpy(tls->pending.server_random, buf + 2, 32);
+	session_id_size =3D buf[34];
+	len -=3D 35;
+
+	if (len < (size_t) session_id_size + 2 + 1)
+		goto decode_error;
+	cipher_suite_id[0] =3D buf[35 + session_id_size + 0];
+	cipher_suite_id[1] =3D buf[35 + session_id_size + 1];
+	compression_method_id =3D buf[35 + session_id_size + 2];
+	len -=3D session_id_size + 2 + 1;
+
+	if (len !=3D 0) { /* We know we haven't solicited any extensions */
+		tls_disconnect(tls, TLS_ALERT_UNSUPPORTED_EXTENSION, 0);
+		return;
+	}
+
+	tls->negotiated_version =3D l_get_be16(buf);
+
+	if (tls->negotiated_version < TLS_MIN_VERSION ||
+			tls->negotiated_version > TLS_VERSION) {
+		tls_disconnect(tls, tls->negotiated_version < TLS_MIN_VERSION ?
+				TLS_ALERT_PROTOCOL_VERSION :
+				TLS_ALERT_ILLEGAL_PARAM, 0);
+		return;
+	}
+
+	/* Set the new cipher suite and compression method structs */
+
+	tls->pending.cipher_suite =3D tls_find_cipher_suite(cipher_suite_id);
+	if (!tls->pending.cipher_suite) {
+		tls_disconnect(tls, TLS_ALERT_HANDSHAKE_FAIL, 0);
+		return;
+	}
+
+	tls->pending.compression_method =3D
+		tls_find_compression_method(compression_method_id);
+	if (!tls->pending.compression_method) {
+		tls_disconnect(tls, TLS_ALERT_HANDSHAKE_FAIL, 0);
+		return;
+	}
+
+	if (tls->pending.cipher_suite->key_xchg->certificate_check)
+		tls->state =3D TLS_HANDSHAKE_WAIT_CERTIFICATE;
+	else
+		tls->state =3D TLS_HANDSHAKE_WAIT_KEY_EXCHANGE;
+
+	return;
+
+decode_error:
+	tls_disconnect(tls, TLS_ALERT_DECODE_ERROR, 0);
+}
+
+static void tls_handle_certificate(struct l_tls *tls,
+					const uint8_t *buf, size_t len)
+{
+	int total, cert_len, pubkey_len;
+	struct l_cert *certchain =3D NULL, **tail =3D &certchain;
+	struct l_cert *ca_cert =3D NULL;
+	uint8_t *pubkey;
+
+	/* Length checks */
+
+	total =3D *buf++ << 16;
+	total |=3D *buf++ << 8;
+	total |=3D *buf++ << 0;
+	if ((size_t) total + 3 !=3D len)
+		goto decode_error;
+
+	while (total) {
+		cert_len =3D *buf++ << 16;
+		cert_len |=3D *buf++ << 8;
+		cert_len |=3D *buf++ << 0;
+
+		if (cert_len + 3 > total)
+			goto decode_error;
+
+		*tail =3D l_cert_decode(buf, cert_len);
+		if (!*tail)
+			goto decode_error;
+
+		tail =3D &(*tail)->issuer;
+
+		buf +=3D cert_len;
+		total -=3D cert_len + 3;
+	}
+
+	/*
+	 * "Note that a client MAY send no certificates if it does not have any
+	 * appropriate certificate to send in response to the server's
+	 * authentication request." -- for now we unconditionally accept
+	 * an empty certificate chain from the client.  Later on we need to
+	 * make this configurable, if we don't want to authenticate the
+	 * client then also don't bother sending a Certificate Request.
+	 */
+	if (!certchain) {
+		if (!tls->server) {
+			tls_disconnect(tls, TLS_ALERT_HANDSHAKE_FAIL, 0);
+
+			goto done;
+		}
+
+		tls->state =3D TLS_HANDSHAKE_WAIT_KEY_EXCHANGE;
+
+		goto done;
+	}
+
+	/*
+	 * Validate the certificate chain's consistency and validate it
+	 * against our CA if we have any.
+	 */
+
+	if (ca_cert) {
+		ca_cert =3D l_cert_load_file(tls->ca_cert_path);
+		if (!ca_cert) {
+			tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR,
+					TLS_ALERT_BAD_CERT);
+
+			goto done;
+		}
+	}
+
+	if (!l_cert_verify_certchain(certchain, ca_cert)) {
+		tls_disconnect(tls, TLS_ALERT_BAD_CERT, 0);
+
+		goto done;
+	}
+
+	/*
+	 * RFC5246 7.4.2:
+	 * "The end entity certificate's public key (and associated
+	 * restrictions) MUST be compatible with the selected key exchange
+	 * algorithm."
+	 */
+	if (!tls->pending.cipher_suite->key_xchg->
+			validate_cert_key_type(certchain)) {
+		tls_disconnect(tls, TLS_ALERT_UNSUPPORTED_CERT, 0);
+
+		goto done;
+	}
+
+	/*
+	 * Save the public key from the certificate for use in premaster
+	 * secret encryption.
+	 */
+	pubkey =3D l_cert_find_pubkey(certchain, &pubkey_len);
+	if (!pubkey && !tls->pending.cipher_suite->key_xchg->key_exchange_msg) {
+		tls_disconnect(tls, TLS_ALERT_UNSUPPORTED_CERT, 0);
+
+		goto done;
+	}
+
+	if (pubkey) {
+		/* Save the end-entity cert and free the rest of the chain */
+		tls->peer_cert =3D certchain;
+		l_cert_free_certchain(certchain->issuer);
+		certchain->issuer =3D NULL;
+		certchain =3D NULL;
+
+		tls->peer_pubkey =3D pubkey;
+		tls->peer_pubkey_length =3D pubkey_len;
+	}
+
+	if (tls->server)
+		tls->state =3D TLS_HANDSHAKE_WAIT_KEY_EXCHANGE;
+	else {
+		if (tls->pending.cipher_suite->key_xchg->key_exchange_msg)
+			tls->state =3D TLS_HANDSHAKE_WAIT_KEY_EXCHANGE;
+		else
+			tls->state =3D TLS_HANDSHAKE_WAIT_HELLO_DONE;
+	}
+
+	goto done;
+
+decode_error:
+	tls_disconnect(tls, TLS_ALERT_DECODE_ERROR, 0);
+
+done:
+	if (ca_cert)
+		l_free(ca_cert);
+
+	l_cert_free_certchain(certchain);
+}
+
+static void tls_handle_certificate_request(struct l_tls *tls,
+						const uint8_t *buf, size_t len)
+{
+	tls->cert_requested =3D 1;
+
+	/*
+	 * TODO: parse and save key type, signature algorithms and DNs list
+	 * for use in tls_send_certificate.
+	 */
+}
+
+static void tls_handle_server_hello_done(struct l_tls *tls,
+						const uint8_t *buf, size_t len)
+{
+	if (len) {
+		tls_disconnect(tls, TLS_ALERT_DECODE_ERROR, 0);
+
+		return;
+	}
+
+	if (tls->cert_requested)
+		if (!tls_send_certificate(tls))
+			return;
+	if (!tls->pending.cipher_suite->key_xchg->send_client_key_exchange(tls))
+		return;
+	if (tls->cert_sent)
+		if (!tls_send_certificate_verify(tls))
+			return;
+	tls_send_change_cipher_spec(tls);
+	if (!tls_change_cipher_spec(tls, 1)) {
+		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR, 0);
+		return;
+	}
+	tls_send_finished(tls);
+
+	tls->state =3D TLS_HANDSHAKE_WAIT_CHANGE_CIPHER_SPEC;
+}
+
+static void tls_handle_certificate_verify(struct l_tls *tls,
+						const uint8_t *buf, size_t len)
+{
+	if (!tls->pending.cipher_suite->key_xchg->verify(tls, buf, len,
+							tls->prev_digest))
+		return;
+
+	/*
+	 * The client's certificate is now verified based on the following
+	 * logic:
+	 *   - If we received an (expected) Certificate Verify, we must have
+	 *     sent a Certificate Request.
+	 *   - If we sent a Certificate Request that's because
+	 *     tls->ca_cert_path is non-NULL.
+	 *   - If tls->ca_cert_path is non-NULL then tls_handle_certificate
+	 *     will have checked the whole certificate chain to be valid and
+	 *     additionally trusted by our CA if known.
+	 *   - Additionally cipher_suite->key_xchg->verify has just confirmed
+	 *     that the peer owns the end-entity certificate because it was
+	 *     able to sign the contents of the handshake messages and that
+	 *     signature could be verified with the public key from that
+	 *     certificate.
+	 */
+	tls->peer_authenticated =3D true;
+
+	tls->state =3D TLS_HANDSHAKE_WAIT_CHANGE_CIPHER_SPEC;
+}
+
+static void tls_finished(struct l_tls *tls)
+{
+	uint8_t *subject_name =3D NULL;
+	int subject_name_len;
+	uint8_t *printable_name =3D NULL;
+	int printable_name_len;
+	char *peer_identity =3D NULL;
+
+	if (tls->peer_authenticated && tls->peer_cert)
+		subject_name =3D l_cert_find_dn(tls->peer_cert, false,
+						&subject_name_len);
+	if (subject_name)
+		printable_name =3D l_cert_dn_find_printable_name(subject_name,
+							subject_name_len,
+							&printable_name_len);
+	if (printable_name)
+		peer_identity =3D l_strndup((char *) printable_name,
+						printable_name_len);
+
+	/* Free up the resources used in the handshake */
+	tls_reset_handshake(tls);
+
+	tls->state =3D TLS_HANDSHAKE_DONE;
+	tls->ready =3D true;
+
+	tls->ready_handle(tls->user_data, peer_identity);
+
+	if (peer_identity)
+		l_free(peer_identity);
+}
+
+static void tls_handle_handshake(struct l_tls *tls, int type,
+					const uint8_t *buf, size_t len)
+{
+	switch (type) {
+	case TLS_HELLO_REQUEST:
+		if (tls->server) {
+			tls_disconnect(tls, TLS_ALERT_UNEXPECTED_MESSAGE, 0);
+			break;
+		}
+
+		if (len !=3D 0) {
+			tls_disconnect(tls, TLS_ALERT_DECODE_ERROR, 0);
+			break;
+		}
+
+		/*
+		 * May be sent by the server at any time but "SHOULD be ignored
+		 * by the client if it arrives in the middle of a handshake"
+		 * and "MAY be ignored by the client if it does not wish to
+		 * renegotiate a session".
+		 */
+
+		break;
+
+	case TLS_CLIENT_HELLO:
+		if (!tls->server) {
+			tls_disconnect(tls, TLS_ALERT_UNEXPECTED_MESSAGE, 0);
+			break;
+		}
+
+		if (tls->state !=3D TLS_HANDSHAKE_WAIT_HELLO &&
+				tls->state !=3D TLS_HANDSHAKE_DONE) {
+			tls_disconnect(tls, TLS_ALERT_UNEXPECTED_MESSAGE, 0);
+			break;
+		}
+
+		tls_handle_client_hello(tls, buf, len);
+
+		break;
+
+	case TLS_SERVER_HELLO:
+		if (tls->server) {
+			tls_disconnect(tls, TLS_ALERT_UNEXPECTED_MESSAGE, 0);
+			break;
+		}
+
+		if (tls->state !=3D TLS_HANDSHAKE_WAIT_HELLO) {
+			tls_disconnect(tls, TLS_ALERT_UNEXPECTED_MESSAGE, 0);
+			break;
+		}
+
+		tls_handle_server_hello(tls, buf, len);
+
+		break;
+
+	case TLS_CERTIFICATE:
+		if (tls->state !=3D TLS_HANDSHAKE_WAIT_CERTIFICATE) {
+			tls_disconnect(tls, TLS_ALERT_UNEXPECTED_MESSAGE, 0);
+			break;
+		}
+
+		tls_handle_certificate(tls, buf, len);
+
+		break;
+
+	case TLS_SERVER_KEY_EXCHANGE:
+		if (tls->server) {
+			tls_disconnect(tls, TLS_ALERT_UNEXPECTED_MESSAGE, 0);
+			break;
+		}
+
+		if (tls->state !=3D TLS_HANDSHAKE_WAIT_KEY_EXCHANGE) {
+			tls_disconnect(tls, TLS_ALERT_UNEXPECTED_MESSAGE, 0);
+			break;
+		}
+
+		if (!tls->pending.cipher_suite->key_xchg->
+				handle_server_key_exchange(tls, buf, len))
+			break;
+
+		tls->state =3D TLS_HANDSHAKE_WAIT_HELLO_DONE;
+
+		break;
+
+	case TLS_CERTIFICATE_REQUEST:
+		/*
+		 * Server sends this optionally so in the WAIT_HELLO_DONE
+		 * state we accept either this or a Server Hello Done (below).
+		 */
+		if (tls->state !=3D TLS_HANDSHAKE_WAIT_HELLO_DONE ||
+				tls->cert_requested ||
+				!tls->pending.cipher_suite->key_xchg->
+				certificate_check) {
+			tls_disconnect(tls, TLS_ALERT_UNEXPECTED_MESSAGE, 0);
+			break;
+		}
+
+		tls_handle_certificate_request(tls, buf, len);
+
+		break;
+
+	case TLS_SERVER_HELLO_DONE:
+		if (tls->state !=3D TLS_HANDSHAKE_WAIT_HELLO_DONE) {
+			tls_disconnect(tls, TLS_ALERT_UNEXPECTED_MESSAGE, 0);
+			break;
+		}
+
+		tls_handle_server_hello_done(tls, buf, len);
+
+		break;
+
+	case TLS_CERTIFICATE_VERIFY:
+		if (tls->state !=3D TLS_HANDSHAKE_WAIT_CERTIFICATE_VERIFY) {
+			tls_disconnect(tls, TLS_ALERT_UNEXPECTED_MESSAGE, 0);
+			break;
+		}
+
+		tls_handle_certificate_verify(tls, buf, len);
+
+		break;
+
+	case TLS_CLIENT_KEY_EXCHANGE:
+		if (!tls->server) {
+			tls_disconnect(tls, TLS_ALERT_UNEXPECTED_MESSAGE, 0);
+			break;
+		}
+
+		if (tls->state !=3D TLS_HANDSHAKE_WAIT_KEY_EXCHANGE) {
+			tls_disconnect(tls, TLS_ALERT_UNEXPECTED_MESSAGE, 0);
+			break;
+		}
+
+		tls->pending.cipher_suite->key_xchg->handle_client_key_exchange(
+								tls, buf, len);
+
+		/*
+		 * If we accepted a client Certificate message with a
+		 * certificate that has signing capability (TODO: check
+		 * usage bitmask), Certiifcate Verify is received next.  It
+		 * sounds as if this is mandatory for the client although
+		 * this isn't 100% clear.
+		 */
+		if (tls->peer_pubkey)
+			tls->state =3D TLS_HANDSHAKE_WAIT_CERTIFICATE_VERIFY;
+		else
+			tls->state =3D TLS_HANDSHAKE_WAIT_CHANGE_CIPHER_SPEC;
+
+		break;
+
+	case TLS_FINISHED:
+		if (tls->state !=3D TLS_HANDSHAKE_WAIT_FINISHED) {
+			tls_disconnect(tls, TLS_ALERT_UNEXPECTED_MESSAGE, 0);
+			break;
+		}
+
+		if (!tls_verify_finished(tls, buf, len))
+			break;
+
+		if (tls->server) {
+			tls_send_change_cipher_spec(tls);
+			if (!tls_change_cipher_spec(tls, 1)) {
+				tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR,
+						0);
+				break;
+			}
+			tls_send_finished(tls);
+		}
+
+		/*
+		 * On the client, the server's certificate is only now
+		 * verified, based on the following logic:
+		 *  - tls->ca_cert_path is non-NULL so tls_handle_certificate
+		 *    (always called on the client) must have veritifed the
+		 *    server's certificate chain to be valid and additionally
+		 *    trusted by our CA.
+		 *  - the correct receival of this Finished message confirms
+		 *    that the peer owns the end-entity certificate because
+		 *    it was able to decrypt the master secret which we had
+		 *    encrypted with the public key from that certificate, and
+		 *    the posession of the master secret in turn is verified
+		 *    by both the successful decryption and the MAC of this
+		 *    message (either should be enough).
+		 */
+		if (!tls->server && tls->cipher_suite[0]->key_xchg->
+				certificate_check &&
+				tls->ca_cert_path)
+			tls->peer_authenticated =3D true;
+
+		tls_finished(tls);
+
+		break;
+
+	default:
+		tls_disconnect(tls, TLS_ALERT_UNEXPECTED_MESSAGE, 0);
+	}
+}
+
 LIB_EXPORT struct l_tls *l_tls_new(bool server,
 				l_tls_write_cb_t app_data_handler,
 				l_tls_write_cb_t tx_handler,
@@ -362,6 +1350,96 @@ LIB_EXPORT void l_tls_write(struct l_tls *tls, const =
uint8_t *data, size_t len)
 	tls_tx_record(tls, TLS_CT_APPLICATION_DATA, data, len);
 }
 =

+bool tls_handle_message(struct l_tls *tls, const uint8_t *message,
+			int len, uint8_t type, uint16_t version)
+{
+	switch (type) {
+	case TLS_CT_CHANGE_CIPHER_SPEC:
+		if (len !=3D 1 || message[0] !=3D 0x01) {
+			tls_disconnect(tls, TLS_ALERT_DECODE_ERROR, 0);
+
+			return false;
+		}
+
+		if (tls->state !=3D TLS_HANDSHAKE_WAIT_CHANGE_CIPHER_SPEC) {
+			tls_disconnect(tls, TLS_ALERT_UNEXPECTED_MESSAGE, 0);
+
+			return false;
+		}
+
+		if (!tls_change_cipher_spec(tls, 0)) {
+			tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR, 0);
+
+			return false;
+		}
+
+		tls->state =3D TLS_HANDSHAKE_WAIT_FINISHED;
+
+		break;
+
+	case TLS_CT_ALERT:
+		/* Verify AlertLevel */
+		if (message[0] !=3D 0x01 && message[0] !=3D 0x02) {
+			tls_disconnect(tls, TLS_ALERT_DECODE_ERROR, 0);
+
+			return false;
+		}
+
+		/*
+		 * On a fatal alert we are obligated to respond with a
+		 * fatal alert and disconnect but also not complain if
+		 * the connection has been torn down by the peer before
+		 * we were able to send our alert.  However on a non-fatal
+		 * alert (warning) we're also allowed to panic and send
+		 * a fatal alert, then disconnect, so we do that
+		 * regardless of the alert level.
+		 */
+		tls_disconnect(tls, TLS_ALERT_CLOSE_NOTIFY, message[1]);
+
+		return false;
+
+	case TLS_CT_HANDSHAKE:
+		/*
+		 * Corner case: When handling a Certificate Verify or a
+		 * Finished message we need access to the messages hash from
+		 * before this message was transmitted on the Tx side so we
+		 * can verify it matches the hash the sender included in the
+		 * message.  We save it here for that purpose.  Everywhere
+		 * else we need to update the hash before handling the new
+		 * message because 1. we may need the new hash to build our
+		 * own Certificate Verify or Finished messages, and 2. we
+		 * update the message hash with newly transmitted messages
+		 * inside tls_tx_handshake which may be called as part of
+		 * handling incoming message, and if we didn't call
+		 * l_checksum_update before, the calls would end up being
+		 * out of order.
+		 */
+		if (message[0] =3D=3D TLS_CERTIFICATE_VERIFY ||
+				message[0] =3D=3D TLS_FINISHED)
+			tls_get_handshake_hash(tls, tls->prev_digest);
+		l_checksum_update(tls->handshake_hash, message, len);
+
+		tls_handle_handshake(tls, message[0],
+					message + TLS_HANDSHAKE_HEADER_SIZE,
+					len - TLS_HANDSHAKE_HEADER_SIZE);
+
+		break;
+
+	case TLS_CT_APPLICATION_DATA:
+		if (!tls->ready) {
+			tls_disconnect(tls, TLS_ALERT_UNEXPECTED_MESSAGE, 0);
+
+			return false;
+		}
+
+		tls->rx(tls->user_data, message, len);
+
+		break;
+	}
+
+	return true;
+}
+
 LIB_EXPORT void l_tls_close(struct l_tls *tls)
 {
 	tls_disconnect(tls, TLS_ALERT_CLOSE_NOTIFY, 0);
-- =

2.1.4


--===============0234412146145502381==--

