Content-Type: multipart/mixed; boundary="===============0830790037433366641=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/2] tls: Separate signature algorithm and key exchange
 algorithm
Date: Fri, 11 Jan 2019 14:14:30 +0100
Message-ID: <20190111131430.12428-2-andrew.zaborowski@intel.com>
In-Reply-To: <20190111131430.12428-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0830790037433366641==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Separate definitions of the key exchange algorithms from the signature
algorithm.  DHE and ECDHE can be used with different signature
algorithms hopefully without any changes.
---
 ell/tls-private.h |  24 +--
 ell/tls-suites.c  | 369 +++++++++++++++++++++++++---------------------
 ell/tls.c         |  44 +++---
 3 files changed, 238 insertions(+), 199 deletions(-)

diff --git a/ell/tls-private.h b/ell/tls-private.h
index 134203f..10f25c5 100644
--- a/ell/tls-private.h
+++ b/ell/tls-private.h
@@ -63,15 +63,23 @@ typedef bool (*tls_get_hash_t)(struct l_tls *tls, uint8=
_t tls_id,
 				uint8_t *out, size_t *len,
 				enum l_checksum_type *type);
 =

-struct tls_key_exchange_algorithm {
+struct tls_signature_algorithm {
 	uint8_t id;
 =

-	bool certificate_check;
+	bool (*validate_cert_key_type)(struct l_cert *cert);
+
+	ssize_t (*sign)(struct l_tls *tls, uint8_t *out, size_t len,
+			const uint8_t *data, size_t data_len,
+			tls_get_hash_t get_hash);
+	bool (*verify)(struct l_tls *tls, const uint8_t *in, size_t len,
+			const uint8_t *data, size_t data_len,
+			tls_get_hash_t get_hash);
+};
+
+struct tls_key_exchange_algorithm {
 	bool need_ecc;
 	bool need_ffdh;
 =

-	bool (*validate_cert_key_type)(struct l_cert *cert);
-
 	bool (*send_server_key_exchange)(struct l_tls *tls);
 	void (*handle_server_key_exchange)(struct l_tls *tls,
 						const uint8_t *buf, size_t len);
@@ -80,13 +88,6 @@ struct tls_key_exchange_algorithm {
 	void (*handle_client_key_exchange)(struct l_tls *tls,
 						const uint8_t *buf, size_t len);
 =

-	ssize_t (*sign)(struct l_tls *tls, uint8_t *out, size_t len,
-			const uint8_t *data, size_t data_len,
-			tls_get_hash_t get_hash);
-	bool (*verify)(struct l_tls *tls, const uint8_t *in, size_t len,
-			const uint8_t *data, size_t data_len,
-			tls_get_hash_t get_hash);
-
 	void (*free_params)(struct l_tls *tls);
 };
 =

@@ -102,6 +103,7 @@ struct tls_cipher_suite {
 	int verify_data_length;
 =

 	struct tls_bulk_encryption_algorithm *encryption;
+	struct tls_signature_algorithm *signature;
 	struct tls_key_exchange_algorithm *key_xchg;
 	struct tls_mac_algorithm *mac;
 	enum l_checksum_type prf_hmac;
diff --git a/ell/tls-suites.c b/ell/tls-suites.c
index d3c7f8f..56d8795 100644
--- a/ell/tls-suites.c
+++ b/ell/tls-suites.c
@@ -42,120 +42,6 @@ static bool tls_rsa_validate_cert_key(struct l_cert *ce=
rt)
 	return l_cert_get_pubkey_type(cert) =3D=3D L_CERT_KEY_RSA;
 }
 =

-static bool tls_send_rsa_client_key_xchg(struct l_tls *tls)
-{
-	uint8_t buf[1024 + 32];
-	uint8_t *ptr =3D buf + TLS_HANDSHAKE_HEADER_SIZE;
-	uint8_t pre_master_secret[48];
-	ssize_t bytes_encrypted;
-
-	if (!tls->peer_pubkey) {
-		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
-				"Peer public key not received");
-
-		return false;
-	}
-
-	/* Must match the version in tls_send_client_hello */
-	pre_master_secret[0] =3D (uint8_t) (TLS_VERSION >> 8);
-	pre_master_secret[1] =3D (uint8_t) (TLS_VERSION >> 0);
-
-	l_getrandom(pre_master_secret + 2, 46);
-
-	if (tls->peer_pubkey_size + 32 > (int) sizeof(buf)) {
-		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
-				"Peer public key too big: %zi",
-				tls->peer_pubkey_size);
-
-		return false;
-	}
-
-	l_put_be16(tls->peer_pubkey_size, ptr);
-	bytes_encrypted =3D l_key_encrypt(tls->peer_pubkey,
-					L_KEY_RSA_PKCS1_V1_5, L_CHECKSUM_NONE,
-					pre_master_secret, ptr + 2, 48,
-					tls->peer_pubkey_size);
-	ptr +=3D tls->peer_pubkey_size + 2;
-
-	if (bytes_encrypted !=3D (ssize_t) tls->peer_pubkey_size) {
-		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
-				"Encrypting PreMasterSecret failed: %s",
-				strerror(-bytes_encrypted));
-
-		return false;
-	}
-
-	tls_tx_handshake(tls, TLS_CLIENT_KEY_EXCHANGE, buf, ptr - buf);
-
-	tls_generate_master_secret(tls, pre_master_secret, 48);
-	memset(pre_master_secret, 0, 48);
-
-	return true;
-}
-
-static void tls_handle_rsa_client_key_xchg(struct l_tls *tls,
-						const uint8_t *buf, size_t len)
-{
-	uint8_t pre_master_secret[48], random_secret[46];
-	ssize_t bytes_decrypted;
-
-	if (!tls->priv_key || !tls->priv_key_size) {
-		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, TLS_ALERT_BAD_CERT,
-				"No private key");
-
-		return;
-	}
-
-	if (len !=3D tls->priv_key_size + 2) {
-		TLS_DISCONNECT(TLS_ALERT_DECODE_ERROR, 0,
-				"ClientKeyExchange len %zi not %zi", len,
-				tls->priv_key_size + 2);
-
-		return;
-	}
-
-	len =3D l_get_be16(buf);
-
-	if (len !=3D tls->priv_key_size) {
-		TLS_DISCONNECT(TLS_ALERT_DECODE_ERROR, 0,
-				"EncryptedPreMasterSecret len %zi not %zi",
-				len, tls->priv_key_size);
-
-		return;
-	}
-
-	bytes_decrypted =3D l_key_decrypt(tls->priv_key, L_KEY_RSA_PKCS1_V1_5,
-					L_CHECKSUM_NONE, buf + 2,
-					pre_master_secret, tls->priv_key_size,
-					48);
-
-	/*
-	 * Assume correct premaster secret client version which according
-	 * to the TLS1.2 spec is unlikely in client implementations SSLv3
-	 * and prior.  Spec suggests either not supporting them or adding
-	 * a configurable override for <=3D SSLv3 clients.  For now we have
-	 * no need to support them.
-	 *
-	 * On any decode error randomise the Pre Master Secret as per the
-	 * countermeasures in 7.4.7.1 and don't generate any alerts.
-	 */
-	l_getrandom(random_secret, 46);
-
-	pre_master_secret[0] =3D tls->client_version >> 8;
-	pre_master_secret[1] =3D tls->client_version >> 0;
-
-	if (bytes_decrypted !=3D 48) {
-		memcpy(pre_master_secret + 2, random_secret, 46);
-
-		TLS_DEBUG("Error decrypting PreMasterSecret: %s",
-				strerror(-bytes_decrypted));
-	}
-
-	tls_generate_master_secret(tls, pre_master_secret, 48);
-	memset(pre_master_secret, 0, 48);
-	memset(random_secret, 0, 46);
-}
-
 static ssize_t tls_rsa_sign(struct l_tls *tls, uint8_t *out, size_t len,
 				const uint8_t *data, size_t data_len,
 				tls_get_hash_t get_hash)
@@ -319,16 +205,132 @@ static bool tls_rsa_verify(struct l_tls *tls, const =
uint8_t *in, size_t len,
 	return success;
 }
 =

-static struct tls_key_exchange_algorithm tls_rsa =3D {
+static struct tls_signature_algorithm tls_rsa_signature =3D {
 	.id =3D 1, /* RSA_sign */
-	.certificate_check =3D true,
 	.validate_cert_key_type =3D tls_rsa_validate_cert_key,
-	.send_client_key_exchange =3D tls_send_rsa_client_key_xchg,
-	.handle_client_key_exchange =3D tls_handle_rsa_client_key_xchg,
 	.sign =3D tls_rsa_sign,
 	.verify =3D tls_rsa_verify,
 };
 =

+static bool tls_send_rsa_client_key_xchg(struct l_tls *tls)
+{
+	uint8_t buf[1024 + 32];
+	uint8_t *ptr =3D buf + TLS_HANDSHAKE_HEADER_SIZE;
+	uint8_t pre_master_secret[48];
+	ssize_t bytes_encrypted;
+
+	if (!tls->peer_pubkey) {
+		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
+				"Peer public key not received");
+
+		return false;
+	}
+
+	/* Must match the version in tls_send_client_hello */
+	pre_master_secret[0] =3D (uint8_t) (TLS_VERSION >> 8);
+	pre_master_secret[1] =3D (uint8_t) (TLS_VERSION >> 0);
+
+	l_getrandom(pre_master_secret + 2, 46);
+
+	if (tls->peer_pubkey_size + 32 > (int) sizeof(buf)) {
+		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
+				"Peer public key too big: %zi",
+				tls->peer_pubkey_size);
+
+		return false;
+	}
+
+	l_put_be16(tls->peer_pubkey_size, ptr);
+	bytes_encrypted =3D l_key_encrypt(tls->peer_pubkey,
+					L_KEY_RSA_PKCS1_V1_5, L_CHECKSUM_NONE,
+					pre_master_secret, ptr + 2, 48,
+					tls->peer_pubkey_size);
+	ptr +=3D tls->peer_pubkey_size + 2;
+
+	if (bytes_encrypted !=3D (ssize_t) tls->peer_pubkey_size) {
+		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
+				"Encrypting PreMasterSecret failed: %s",
+				strerror(-bytes_encrypted));
+
+		return false;
+	}
+
+	tls_tx_handshake(tls, TLS_CLIENT_KEY_EXCHANGE, buf, ptr - buf);
+
+	tls_generate_master_secret(tls, pre_master_secret, 48);
+	memset(pre_master_secret, 0, 48);
+
+	return true;
+}
+
+static void tls_handle_rsa_client_key_xchg(struct l_tls *tls,
+						const uint8_t *buf, size_t len)
+{
+	uint8_t pre_master_secret[48], random_secret[46];
+	ssize_t bytes_decrypted;
+
+	if (!tls->priv_key || !tls->priv_key_size) {
+		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, TLS_ALERT_BAD_CERT,
+				"No private key");
+
+		return;
+	}
+
+	if (len !=3D tls->priv_key_size + 2) {
+		TLS_DISCONNECT(TLS_ALERT_DECODE_ERROR, 0,
+				"ClientKeyExchange len %zi not %zi", len,
+				tls->priv_key_size + 2);
+
+		return;
+	}
+
+	len =3D l_get_be16(buf);
+
+	if (len !=3D tls->priv_key_size) {
+		TLS_DISCONNECT(TLS_ALERT_DECODE_ERROR, 0,
+				"EncryptedPreMasterSecret len %zi not %zi",
+				len, tls->priv_key_size);
+
+		return;
+	}
+
+	bytes_decrypted =3D l_key_decrypt(tls->priv_key, L_KEY_RSA_PKCS1_V1_5,
+					L_CHECKSUM_NONE, buf + 2,
+					pre_master_secret, tls->priv_key_size,
+					48);
+
+	/*
+	 * Assume correct premaster secret client version which according
+	 * to the TLS1.2 spec is unlikely in client implementations SSLv3
+	 * and prior.  Spec suggests either not supporting them or adding
+	 * a configurable override for <=3D SSLv3 clients.  For now we have
+	 * no need to support them.
+	 *
+	 * On any decode error randomise the Pre Master Secret as per the
+	 * countermeasures in 7.4.7.1 and don't generate any alerts.
+	 */
+	l_getrandom(random_secret, 46);
+
+	pre_master_secret[0] =3D tls->client_version >> 8;
+	pre_master_secret[1] =3D tls->client_version >> 0;
+
+	if (bytes_decrypted !=3D 48) {
+		memcpy(pre_master_secret + 2, random_secret, 46);
+
+		TLS_DEBUG("Error decrypting PreMasterSecret: %s",
+				strerror(-bytes_decrypted));
+	}
+
+	tls_generate_master_secret(tls, pre_master_secret, 48);
+	memset(pre_master_secret, 0, 48);
+	memset(random_secret, 0, 46);
+}
+
+static struct tls_key_exchange_algorithm tls_rsa_key_xchg =3D {
+	.send_client_key_exchange =3D tls_send_rsa_client_key_xchg,
+	.handle_client_key_exchange =3D tls_handle_rsa_client_key_xchg,
+};
+
 /* Used by both DHE and ECDHE */
 static bool tls_get_dh_params_hash(struct l_tls *tls, uint8_t tls_id,
 					const uint8_t *data, size_t data_len,
@@ -447,15 +449,17 @@ static bool tls_send_ecdhe_server_key_xchg(struct l_t=
ls *tls)
 	server_ecdh_params_ptr =3D ptr;
 	ptr +=3D tls_write_server_ecdh_params(tls, ptr);
 =

-	sign_len =3D tls->pending.cipher_suite->key_xchg->sign(tls, ptr,
+	if (tls->pending.cipher_suite->signature) {
+		sign_len =3D tls->pending.cipher_suite->signature->sign(tls, ptr,
 						buf + sizeof(buf) - ptr,
 						server_ecdh_params_ptr,
 						ptr - server_ecdh_params_ptr,
 						tls_get_dh_params_hash);
-	if (sign_len < 0)
-		return false;
+		if (sign_len < 0)
+			return false;
 =

-	ptr +=3D sign_len;
+		ptr +=3D sign_len;
+	}
 =

 	tls_tx_handshake(tls, TLS_SERVER_KEY_EXCHANGE, buf, ptr - buf);
 =

@@ -534,11 +538,16 @@ static void tls_handle_ecdhe_server_key_xchg(struct l=
_tls *tls,
 		return;
 	}
 =

-	if (!tls->pending.cipher_suite->key_xchg->verify(tls, buf, len,
+	if (tls->pending.cipher_suite->signature) {
+		if (!tls->pending.cipher_suite->signature->verify(tls, buf, len,
 						server_ecdh_params_ptr,
 						buf - server_ecdh_params_ptr,
 						tls_get_dh_params_hash))
-		return;
+			return;
+	} else {
+		if (len)
+			goto decode_error;
+	}
 =

 	TLS_SET_STATE(TLS_HANDSHAKE_WAIT_HELLO_DONE);
 =

@@ -687,18 +696,13 @@ decode_error:
 			"ClientKeyExchange decode error");
 }
 =

-static struct tls_key_exchange_algorithm tls_ecdhe_rsa =3D {
-	.id =3D 1, /* RSA_sign */
-	.certificate_check =3D true,
+static struct tls_key_exchange_algorithm tls_ecdhe =3D {
 	.need_ecc =3D true,
-	.validate_cert_key_type =3D tls_rsa_validate_cert_key,
 	.send_server_key_exchange =3D tls_send_ecdhe_server_key_xchg,
 	.handle_server_key_exchange =3D tls_handle_ecdhe_server_key_xchg,
 	.send_client_key_exchange =3D tls_send_ecdhe_client_key_xchg,
 	.handle_client_key_exchange =3D tls_handle_ecdhe_client_key_xchg,
 	.free_params =3D tls_free_ecdhe_params,
-	.sign =3D tls_rsa_sign,
-	.verify =3D tls_rsa_verify,
 };
 =

 /* Maximum FF DH prime modulus size in bytes */
@@ -789,15 +793,18 @@ static bool tls_send_dhe_server_key_xchg(struct l_tls=
 *tls)
 	memcpy(ptr + 2, public_buf + zeros, public_len - zeros);
 	ptr +=3D 2 + public_len - zeros;
 =

-	sign_len =3D tls->pending.cipher_suite->key_xchg->sign(tls, ptr,
+	if (tls->pending.cipher_suite->signature) {
+		sign_len =3D tls->pending.cipher_suite->signature->sign(tls, ptr,
 						buf + sizeof(buf) - ptr,
 						server_dh_params_ptr,
 						ptr - server_dh_params_ptr,
 						tls_get_dh_params_hash);
-	if (sign_len < 0)
-		goto free_params;
+		if (sign_len < 0)
+			goto free_params;
+
+		ptr +=3D sign_len;
+	}
 =

-	ptr +=3D sign_len;
 	tls->pending.key_xchg_params =3D params;
 =

 	tls_tx_handshake(tls, TLS_SERVER_KEY_EXCHANGE, buf, ptr - buf);
@@ -925,11 +932,16 @@ static void tls_handle_dhe_server_key_xchg(struct l_t=
ls *tls,
 =

 	tls->pending.key_xchg_params =3D params;
 =

-	if (!tls->pending.cipher_suite->key_xchg->verify(tls, buf, len,
-						server_dh_params_ptr,
-						buf - server_dh_params_ptr,
-						tls_get_dh_params_hash))
-		return;
+	if (tls->pending.cipher_suite->signature) {
+		if (!tls->pending.cipher_suite->signature->verify(tls, buf, len,
+							server_dh_params_ptr,
+							buf - server_dh_params_ptr,
+							tls_get_dh_params_hash))
+			return;
+	} else {
+		if (len)
+			goto decode_error;
+	}
 =

 	TLS_SET_STATE(TLS_HANDSHAKE_WAIT_HELLO_DONE);
 	return;
@@ -1063,18 +1075,13 @@ decode_error:
 			"ClientKeyExchange decode error");
 }
 =

-static struct tls_key_exchange_algorithm tls_dhe_rsa =3D {
-	.id =3D 1, /* RSA_sign */
-	.certificate_check =3D true,
+static struct tls_key_exchange_algorithm tls_dhe =3D {
 	.need_ecc =3D true,
-	.validate_cert_key_type =3D tls_rsa_validate_cert_key,
 	.send_server_key_exchange =3D tls_send_dhe_server_key_xchg,
 	.handle_server_key_exchange =3D tls_handle_dhe_server_key_xchg,
 	.send_client_key_exchange =3D tls_send_dhe_client_key_xchg,
 	.handle_client_key_exchange =3D tls_handle_dhe_client_key_xchg,
 	.free_params =3D tls_free_dhe_params,
-	.sign =3D tls_rsa_sign,
-	.verify =3D tls_rsa_verify,
 };
 =

 static struct tls_bulk_encryption_algorithm tls_rc4 =3D {
@@ -1139,145 +1146,166 @@ static struct tls_cipher_suite tls_rsa_with_rc4_1=
28_md5 =3D {
 	.verify_data_length =3D 12,
 	.encryption =3D &tls_rc4,
 	.mac =3D &tls_md5,
-	.key_xchg =3D &tls_rsa,
+	.signature =3D &tls_rsa_signature,
+	.key_xchg =3D &tls_rsa_key_xchg,
 }, tls_rsa_with_rc4_128_sha =3D {
 	.id =3D { 0x00, 0x05 },
 	.name =3D "TLS_RSA_WITH_RC4_128_SHA",
 	.verify_data_length =3D 12,
 	.encryption =3D &tls_rc4,
 	.mac =3D &tls_sha,
-	.key_xchg =3D &tls_rsa,
+	.signature =3D &tls_rsa_signature,
+	.key_xchg =3D &tls_rsa_key_xchg,
 }, tls_rsa_with_3des_ede_cbc_sha =3D {
 	.id =3D { 0x00, 0x0a },
 	.name =3D "TLS_RSA_WITH_3DES_EDE_CBC_SHA",
 	.verify_data_length =3D 12,
 	.encryption =3D &tls_3des_ede,
 	.mac =3D &tls_sha,
-	.key_xchg =3D &tls_rsa,
+	.signature =3D &tls_rsa_signature,
+	.key_xchg =3D &tls_rsa_key_xchg,
 }, tls_dhe_rsa_with_3des_ede_cbc_sha =3D {
 	.id =3D { 0x00, 0x16 },
 	.name =3D "TLS_DHE_RSA_WITH_3DES_EDE_CBC_SHA",
 	.verify_data_length =3D 12,
 	.encryption =3D &tls_3des_ede,
 	.mac =3D &tls_sha,
-	.key_xchg =3D &tls_dhe_rsa,
+	.signature =3D &tls_rsa_signature,
+	.key_xchg =3D &tls_dhe,
 }, tls_rsa_with_aes_128_cbc_sha =3D {
 	.id =3D { 0x00, 0x2f },
 	.name =3D "TLS_RSA_WITH_AES_128_CBC_SHA",
 	.verify_data_length =3D 12,
 	.encryption =3D &tls_aes128,
 	.mac =3D &tls_sha,
-	.key_xchg =3D &tls_rsa,
+	.signature =3D &tls_rsa_signature,
+	.key_xchg =3D &tls_rsa_key_xchg,
 }, tls_dhe_rsa_with_aes_128_cbc_sha =3D {
 	.id =3D { 0x00, 0x33 },
 	.name =3D "TLS_DHE_RSA_WITH_AES_128_CBC_SHA",
 	.verify_data_length =3D 12,
 	.encryption =3D &tls_aes128,
 	.mac =3D &tls_sha,
-	.key_xchg =3D &tls_dhe_rsa,
+	.signature =3D &tls_rsa_signature,
+	.key_xchg =3D &tls_dhe,
 }, tls_rsa_with_aes_256_cbc_sha =3D {
 	.id =3D { 0x00, 0x35 },
 	.name =3D "TLS_RSA_WITH_AES_256_CBC_SHA",
 	.verify_data_length =3D 12,
 	.encryption =3D &tls_aes256,
 	.mac =3D &tls_sha,
-	.key_xchg =3D &tls_rsa,
+	.signature =3D &tls_rsa_signature,
+	.key_xchg =3D &tls_rsa_key_xchg,
 }, tls_dhe_rsa_with_aes_256_cbc_sha =3D {
 	.id =3D { 0x00, 0x39 },
 	.name =3D "TLS_DHE_RSA_WITH_AES_256_CBC_SHA",
 	.verify_data_length =3D 12,
 	.encryption =3D &tls_aes256,
 	.mac =3D &tls_sha,
-	.key_xchg =3D &tls_dhe_rsa,
+	.signature =3D &tls_rsa_signature,
+	.key_xchg =3D &tls_dhe,
 }, tls_rsa_with_aes_128_cbc_sha256 =3D {
 	.id =3D { 0x00, 0x3c },
 	.name =3D "TLS_RSA_WITH_AES_128_CBC_SHA256",
 	.verify_data_length =3D 12,
 	.encryption =3D &tls_aes128,
 	.mac =3D &tls_sha256,
-	.key_xchg =3D &tls_rsa,
+	.signature =3D &tls_rsa_signature,
+	.key_xchg =3D &tls_rsa_key_xchg,
 }, tls_rsa_with_aes_256_cbc_sha256 =3D {
 	.id =3D { 0x00, 0x3d },
 	.name =3D "TLS_RSA_WITH_AES_256_CBC_SHA256",
 	.verify_data_length =3D 12,
 	.encryption =3D &tls_aes256,
 	.mac =3D &tls_sha256,
-	.key_xchg =3D &tls_rsa,
+	.signature =3D &tls_rsa_signature,
+	.key_xchg =3D &tls_rsa_key_xchg,
 }, tls_dhe_rsa_with_aes_128_cbc_sha256 =3D {
 	.id =3D { 0x00, 0x67 },
 	.name =3D "TLS_DHE_RSA_WITH_AES_128_CBC_SHA256",
 	.verify_data_length =3D 12,
 	.encryption =3D &tls_aes128,
 	.mac =3D &tls_sha256,
-	.key_xchg =3D &tls_dhe_rsa,
+	.signature =3D &tls_rsa_signature,
+	.key_xchg =3D &tls_dhe,
 }, tls_dhe_rsa_with_aes_256_cbc_sha256 =3D {
 	.id =3D { 0x00, 0x6b },
 	.name =3D "TLS_DHE_RSA_WITH_AES_256_CBC_SHA256",
 	.verify_data_length =3D 12,
 	.encryption =3D &tls_aes256,
 	.mac =3D &tls_sha256,
-	.key_xchg =3D &tls_dhe_rsa,
+	.signature =3D &tls_rsa_signature,
+	.key_xchg =3D &tls_dhe,
 }, tls_rsa_with_aes_128_gcm_sha256 =3D {
 	.id =3D { 0x00, 0x9c },
 	.name =3D "TLS_RSA_WITH_AES_128_GCM_SHA256",
 	.verify_data_length =3D 12,
 	.encryption =3D &tls_aes128_gcm,
-	.key_xchg =3D &tls_rsa,
+	.signature =3D &tls_rsa_signature,
+	.key_xchg =3D &tls_rsa_key_xchg,
 }, tls_rsa_with_aes_256_gcm_sha384 =3D {
 	.id =3D { 0x00, 0x9d },
 	.name =3D "TLS_RSA_WITH_AES_256_GCM_SHA384",
 	.verify_data_length =3D 12,
 	.encryption =3D &tls_aes256_gcm,
 	.prf_hmac =3D L_CHECKSUM_SHA384,
-	.key_xchg =3D &tls_rsa,
+	.signature =3D &tls_rsa_signature,
+	.key_xchg =3D &tls_rsa_key_xchg,
 }, tls_dhe_rsa_with_aes_128_gcm_sha256 =3D {
 	.id =3D { 0x00, 0x9e },
 	.name =3D "TLS_DHE_RSA_WITH_AES_128_GCM_SHA256",
 	.verify_data_length =3D 12,
 	.encryption =3D &tls_aes128_gcm,
-	.key_xchg =3D &tls_dhe_rsa,
+	.signature =3D &tls_rsa_signature,
+	.key_xchg =3D &tls_dhe,
 }, tls_dhe_rsa_with_aes_256_gcm_sha384 =3D {
 	.id =3D { 0x00, 0x9f },
 	.name =3D "TLS_DHE_RSA_WITH_AES_256_GCM_SHA384",
 	.verify_data_length =3D 12,
 	.encryption =3D &tls_aes256_gcm,
 	.prf_hmac =3D L_CHECKSUM_SHA384,
-	.key_xchg =3D &tls_dhe_rsa,
+	.signature =3D &tls_rsa_signature,
+	.key_xchg =3D &tls_dhe,
 }, tls_ecdhe_rsa_with_rc4_128_sha =3D {
 	.id =3D { 0xc0, 0x11 },
 	.name =3D "TLS_ECDHE_RSA_WITH_RC4_128_SHA",
 	.verify_data_length =3D 12,
 	.encryption =3D &tls_rc4,
 	.mac =3D &tls_sha,
-	.key_xchg =3D &tls_ecdhe_rsa,
+	.signature =3D &tls_rsa_signature,
+	.key_xchg =3D &tls_ecdhe,
 }, tls_ecdhe_rsa_with_3des_ede_cbc_sha =3D {
 	.id =3D { 0xc0, 0x12 },
 	.name =3D "TLS_ECDHE_RSA_WITH_3DES_EDE_CBC_SHA",
 	.verify_data_length =3D 12,
 	.encryption =3D &tls_3des_ede,
 	.mac =3D &tls_sha,
-	.key_xchg =3D &tls_ecdhe_rsa,
+	.signature =3D &tls_rsa_signature,
+	.key_xchg =3D &tls_ecdhe,
 }, tls_ecdhe_rsa_with_aes_128_cbc_sha =3D {
 	.id =3D { 0xc0, 0x13 },
 	.name =3D "TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA",
 	.verify_data_length =3D 12,
 	.encryption =3D &tls_aes128,
 	.mac =3D &tls_sha,
-	.key_xchg =3D &tls_ecdhe_rsa,
+	.signature =3D &tls_rsa_signature,
+	.key_xchg =3D &tls_ecdhe,
 }, tls_ecdhe_rsa_with_aes_256_cbc_sha =3D {
 	.id =3D { 0xc0, 0x14 },
 	.name =3D "TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA",
 	.verify_data_length =3D 12,
 	.encryption =3D &tls_aes256,
 	.mac =3D &tls_sha,
-	.key_xchg =3D &tls_ecdhe_rsa,
+	.signature =3D &tls_rsa_signature,
+	.key_xchg =3D &tls_ecdhe,
 }, tls_ecdhe_rsa_with_aes_128_cbc_sha256 =3D {
 	.id =3D { 0xc0, 0x27 },
 	.name =3D "TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256",
 	.verify_data_length =3D 12,
 	.encryption =3D &tls_aes128,
 	.mac =3D &tls_sha256,
-	.key_xchg =3D &tls_ecdhe_rsa,
+	.signature =3D &tls_rsa_signature,
+	.key_xchg =3D &tls_ecdhe,
 }, tls_ecdhe_rsa_with_aes_256_cbc_sha384 =3D {
 	.id =3D { 0xc0, 0x28 },
 	.name =3D "TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384",
@@ -1285,20 +1313,23 @@ static struct tls_cipher_suite tls_rsa_with_rc4_128=
_md5 =3D {
 	.encryption =3D &tls_aes256,
 	.mac =3D &tls_sha384,
 	.prf_hmac =3D L_CHECKSUM_SHA384,
-	.key_xchg =3D &tls_ecdhe_rsa,
+	.signature =3D &tls_rsa_signature,
+	.key_xchg =3D &tls_ecdhe,
 }, tls_ecdhe_rsa_with_aes_128_gcm_sha256 =3D {
 	.id =3D { 0xc0, 0x2f },
 	.name =3D "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256",
 	.verify_data_length =3D 12,
 	.encryption =3D &tls_aes128_gcm,
-	.key_xchg =3D &tls_ecdhe_rsa,
+	.signature =3D &tls_rsa_signature,
+	.key_xchg =3D &tls_ecdhe,
 }, tls_ecdhe_rsa_with_aes_256_gcm_sha384 =3D {
 	.id =3D { 0xc0, 0x30 },
 	.name =3D "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384",
 	.verify_data_length =3D 12,
 	.encryption =3D &tls_aes256_gcm,
 	.prf_hmac =3D L_CHECKSUM_SHA384,
-	.key_xchg =3D &tls_ecdhe_rsa,
+	.signature =3D &tls_rsa_signature,
+	.key_xchg =3D &tls_ecdhe,
 };
 =

 struct tls_cipher_suite *tls_cipher_suite_pref[] =3D {
diff --git a/ell/tls.c b/ell/tls.c
index 6e8c968..f7d1d73 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -477,14 +477,21 @@ static bool tls_cipher_suite_is_compatible(struct l_t=
ls *tls,
 		return false;
 	}
 =

+	/*
+	 * If the certificate is compatible with the signature algorithm it
+	 * also must be compatible with the key exchange mechanism because
+	 * the cipher suites are defined so that the same certificates can
+	 * be used by both.
+	 */
 	leaf =3D l_certchain_get_leaf(tls->cert);
-	if (leaf && !suite->key_xchg->validate_cert_key_type(leaf)) {
+	if (leaf && suite->signature &&
+			!suite->signature->validate_cert_key_type(leaf)) {
 		if (error) {
 			*error =3D error_buf;
 			snprintf(error_buf, sizeof(error_buf),
 					"Local certificate has key type "
 					"incompatible with cipher suite %s's "
-					"key xchg mechanism", suite->name);
+					"signature algorithm", suite->name);
 		}
 =

 		return false;
@@ -924,7 +931,7 @@ static bool tls_send_certificate(struct l_tls *tls)
 =

 	/* TODO: might want check this earlier and exclude the cipher suite */
 	leaf =3D l_certchain_get_leaf(tls->cert);
-	if (leaf && !tls->pending.cipher_suite->key_xchg->
+	if (leaf && !tls->pending.cipher_suite->signature->
 			validate_cert_key_type(leaf)) {
 		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, TLS_ALERT_CERT_UNKNOWN,
 				"Local certificate has key type incompatible "
@@ -1174,7 +1181,7 @@ static bool tls_send_certificate_verify(struct l_tls =
*tls)
 =

 	/* Fill in the Certificate Verify body */
 =

-	sign_len =3D tls->pending.cipher_suite->key_xchg->sign(tls,
+	sign_len =3D tls->pending.cipher_suite->signature->sign(tls,
 					buf + TLS_HANDSHAKE_HEADER_SIZE,
 					2048 - TLS_HANDSHAKE_HEADER_SIZE,
 					NULL, 0, tls_get_handshake_hash_by_id);
@@ -1591,7 +1598,7 @@ static void tls_handle_client_hello(struct l_tls *tls,
 =

 	l_queue_destroy(extensions_offered, NULL);
 =

-	if (tls->pending.cipher_suite->key_xchg->certificate_check && tls->cert)
+	if (tls->pending.cipher_suite->signature && tls->cert)
 		if (!tls_send_certificate(tls))
 			return;
 =

@@ -1601,15 +1608,13 @@ static void tls_handle_client_hello(struct l_tls *t=
ls,
 			return;
 =

 	/* TODO: don't bother if configured to not authenticate client */
-	if (tls->pending.cipher_suite->key_xchg->certificate_check &&
-			tls->ca_certs)
+	if (tls->pending.cipher_suite->signature && tls->ca_certs)
 		if (!tls_send_certificate_request(tls))
 			return;
 =

 	tls_send_server_hello_done(tls);
 =

-	if (tls->pending.cipher_suite->key_xchg->certificate_check &&
-			tls->ca_certs)
+	if (tls->pending.cipher_suite->signature && tls->ca_certs)
 		TLS_SET_STATE(TLS_HANDSHAKE_WAIT_CERTIFICATE);
 	else
 		TLS_SET_STATE(TLS_HANDSHAKE_WAIT_KEY_EXCHANGE);
@@ -1726,7 +1731,7 @@ static void tls_handle_server_hello(struct l_tls *tls,
 =

 	TLS_DEBUG("Negotiated %s", tls->pending.compression_method->name);
 =

-	if (tls->pending.cipher_suite->key_xchg->certificate_check)
+	if (tls->pending.cipher_suite->signature)
 		TLS_SET_STATE(TLS_HANDSHAKE_WAIT_CERTIFICATE);
 	else
 		TLS_SET_STATE(TLS_HANDSHAKE_WAIT_KEY_EXCHANGE);
@@ -1807,7 +1812,7 @@ static void tls_handle_certificate(struct l_tls *tls,
 	 * algorithm."
 	 */
 	leaf =3D l_certchain_get_leaf(certchain);
-	if (!tls->pending.cipher_suite->key_xchg->
+	if (!tls->pending.cipher_suite->signature->
 			validate_cert_key_type(leaf)) {
 		TLS_DISCONNECT(TLS_ALERT_UNSUPPORTED_CERT, 0,
 				"Peer certificate key type incompatible with "
@@ -1910,7 +1915,8 @@ static void tls_handle_certificate_request(struct l_t=
ls *tls,
 =

 			/* Ignore hash types for signatures other than ours */
 			if (signature_hash_data[i + 1] !=3D
-					tls->pending.cipher_suite->key_xchg->id)
+					tls->pending.cipher_suite->
+						signature->id)
 				continue;
 =

 			if (hash_id =3D=3D tls_handshake_hash_data[
@@ -2028,7 +2034,8 @@ static void tls_handle_certificate_verify(struct l_tl=
s *tls,
 {
 	int i;
 =

-	if (!tls->pending.cipher_suite->key_xchg->verify(tls, buf, len, NULL, 0,
+	if (!tls->pending.cipher_suite->signature->verify(tls, buf, len,
+						NULL, 0,
 						tls_get_prev_digest_by_id))
 		return;
 =

@@ -2048,7 +2055,7 @@ static void tls_handle_certificate_verify(struct l_tl=
s *tls,
 	 *   - If tls->ca_certs is non-NULL then tls_handle_certificate
 	 *     will have checked the whole certificate chain to be valid and
 	 *     additionally trusted by our CAs if known.
-	 *   - Additionally cipher_suite->key_xchg->verify has just confirmed
+	 *   - Additionally cipher_suite->signature->verify has just confirmed
 	 *     that the peer owns the end-entity certificate because it was
 	 *     able to sign the contents of the handshake messages and that
 	 *     signature could be verified with the public key from that
@@ -2253,8 +2260,7 @@ static void tls_handle_handshake(struct l_tls *tls, i=
nt type,
 		 */
 		if (tls->state !=3D TLS_HANDSHAKE_WAIT_HELLO_DONE ||
 				tls->cert_requested ||
-				!tls->pending.cipher_suite->key_xchg->
-				certificate_check) {
+				!tls->pending.cipher_suite->signature) {
 			TLS_DISCONNECT(TLS_ALERT_UNEXPECTED_MESSAGE, 0,
 					"Message invalid in current state "
 					"or certificate check not supported "
@@ -2307,7 +2313,7 @@ static void tls_handle_handshake(struct l_tls *tls, i=
nt type,
 		/*
 		 * If we accepted a client Certificate message with a
 		 * certificate that has signing capability (TODO: check
-		 * usage bitmask), Certiifcate Verify is received next.  It
+		 * usage bitmask), Certificate Verify is received next.  It
 		 * sounds as if this is mandatory for the client although
 		 * this isn't 100% clear.
 		 */
@@ -2374,8 +2380,8 @@ static void tls_handle_handshake(struct l_tls *tls, i=
nt type,
 		 *      ServerKeyExchange parameters using its certified key
 		 *      pair.
 		 */
-		if (!tls->server && tls->cipher_suite[0]->key_xchg->
-				certificate_check && tls->ca_certs)
+		if (!tls->server && tls->cipher_suite[0]->signature &&
+				tls->ca_certs)
 			tls->peer_authenticated =3D true;
 =

 		tls_finished(tls);
-- =

2.19.1


--===============0830790037433366641==--

