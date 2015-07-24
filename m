Content-Type: multipart/mixed; boundary="===============0709942245304439020=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 15/17] tls: Add the cipher suite implementations.
Date: Fri, 24 Jul 2015 05:27:50 +0200
Message-ID: <1437708472-28124-6-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1437708472-28124-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0709942245304439020==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

7 cipher suites are supported, tested against OpenSSL.  All 7 are based
on RSA.  TLS defines two more signature algorithms / key-exchange
methods beside RSA but they depend on algorithms not supported by the
kernel.
---
 ell/tls.c | 402 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++=
++++
 1 file changed, 402 insertions(+)

diff --git a/ell/tls.c b/ell/tls.c
index 8d88ea4..25c938a 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -222,7 +222,125 @@ void tls_disconnect(struct l_tls *tls, enum l_tls_ale=
rt_desc desc,
 				local_desc && !desc);
 }
 =

+static bool tls_send_rsa_client_key_xchg(struct l_tls *tls);
+static void tls_handle_rsa_client_key_xchg(struct l_tls *tls,
+						const uint8_t *buf, size_t len);
+
+static bool tls_rsa_sign(struct l_tls *tls, uint8_t **out, const uint8_t *=
hash);
+static bool tls_rsa_verify(struct l_tls *tls, const uint8_t *in, size_t le=
n,
+				const uint8_t *hash);
+
+static bool tls_rsa_validate_cert_key(struct l_cert *cert)
+{
+	return l_cert_get_pubkey_type(cert) =3D=3D L_CERT_KEY_RSA;
+}
+
+static struct tls_key_exchange_algorithm tls_rsa =3D {
+	.id =3D 1, /* RSA_sign */
+	.certificate_check =3D true,
+	.key_exchange_msg =3D false,
+	.validate_cert_key_type =3D tls_rsa_validate_cert_key,
+	.send_client_key_exchange =3D tls_send_rsa_client_key_xchg,
+	.handle_client_key_exchange =3D tls_handle_rsa_client_key_xchg,
+	.sign =3D tls_rsa_sign,
+	.verify =3D tls_rsa_verify,
+};
+
+static struct tls_bulk_encryption_algorithm tls_rc4 =3D {
+	.cipher_type =3D TLS_CIPHER_STREAM,
+	.l_id =3D L_CIPHER_ARC4,
+	.key_length =3D 16,
+}, tls_aes128 =3D {
+	.cipher_type =3D TLS_CIPHER_BLOCK,
+	.l_id =3D L_CIPHER_AES_CBC,
+	.key_length =3D 16,
+	.iv_length =3D 16,
+	.block_length =3D 16,
+}, tls_aes256 =3D {
+	.cipher_type =3D TLS_CIPHER_BLOCK,
+	.l_id =3D L_CIPHER_AES_CBC,
+	.key_length =3D 32,
+	.iv_length =3D 16,
+	.block_length =3D 16,
+}, tls_3des_ede =3D {
+	.cipher_type =3D TLS_CIPHER_BLOCK,
+	.l_id =3D L_CIPHER_DES3_EDE_CBC,
+	.key_length =3D 24,
+	.iv_length =3D 8,
+	.block_length =3D 8,
+};
+
+static struct tls_mac_algorithm tls_md5 =3D {
+	.id =3D 1,
+	.hmac_type =3D L_CHECKSUM_MD5,
+	.mac_length =3D 16,
+}, tls_sha =3D {
+	.id =3D 2,
+	.hmac_type =3D L_CHECKSUM_SHA1,
+	.mac_length =3D 20,
+}, tls_sha256 =3D {
+	.id =3D 4,
+	.hmac_type =3D L_CHECKSUM_SHA256,
+	.mac_length =3D 32,
+};
+
 static struct tls_cipher_suite tls_cipher_suite_pref[] =3D {
+	{
+		.id =3D { 0x00, 0x35 },
+		.name =3D "TLS_RSA_WITH_AES_256_CBC_SHA",
+		.verify_data_length =3D 12,
+		.encryption =3D &tls_aes256,
+		.mac =3D &tls_sha,
+		.key_xchg =3D &tls_rsa,
+	},
+	{
+		.id =3D { 0x00, 0x2f },
+		.name =3D "TLS_RSA_WITH_AES_128_CBC_SHA",
+		.verify_data_length =3D 12,
+		.encryption =3D &tls_aes128,
+		.mac =3D &tls_sha,
+		.key_xchg =3D &tls_rsa,
+	},
+	{
+		.id =3D { 0x00, 0x3d },
+		.name =3D "TLS_RSA_WITH_AES_256_CBC_SHA256",
+		.verify_data_length =3D 12,
+		.encryption =3D &tls_aes256,
+		.mac =3D &tls_sha256,
+		.key_xchg =3D &tls_rsa,
+	},
+	{
+		.id =3D { 0x00, 0x3c },
+		.name =3D "TLS_RSA_WITH_AES_128_CBC_SHA256",
+		.verify_data_length =3D 12,
+		.encryption =3D &tls_aes128,
+		.mac =3D &tls_sha256,
+		.key_xchg =3D &tls_rsa,
+	},
+	{
+		.id =3D { 0x00, 0x0a },
+		.name =3D "TLS_RSA_WITH_3DES_EDE_CBC_SHA",
+		.verify_data_length =3D 12,
+		.encryption =3D &tls_3des_ede,
+		.mac =3D &tls_sha,
+		.key_xchg =3D &tls_rsa,
+	},
+	{
+		.id =3D { 0x00, 0x05 },
+		.name =3D "TLS_RSA_WITH_RC4_128_SHA",
+		.verify_data_length =3D 12,
+		.encryption =3D &tls_rc4,
+		.mac =3D &tls_sha,
+		.key_xchg =3D &tls_rsa,
+	},
+	{
+		.id =3D { 0x00, 0x04 },
+		.name =3D "TLS_RSA_WITH_RC4_128_MD5",
+		.verify_data_length =3D 12,
+		.encryption =3D &tls_rc4,
+		.mac =3D &tls_md5,
+		.key_xchg =3D &tls_rsa,
+	},
 };
 =

 static struct tls_cipher_suite *tls_find_cipher_suite(const uint8_t *id)
@@ -257,6 +375,7 @@ static struct tls_compression_method *tls_find_compress=
ion_method(
 }
 =

 static uint8_t tls_cert_type_pref[] =3D {
+	1, /* RSA_sign */
 };
 =

 struct tls_signature_hash_algorithms {
@@ -265,6 +384,11 @@ struct tls_signature_hash_algorithms {
 };
 =

 static struct tls_signature_hash_algorithms tls_signature_hash_pref[] =3D {
+	{ 6, 1 }, /* SHA512 + RSA */
+	{ 5, 1 }, /* SHA384 + RSA */
+	{ 4, 1 }, /* SHA256 + RSA */
+	{ 2, 1 }, /* SHA1 + RSA */
+	{ 1, 1 }, /* MD5 + RSA */
 };
 =

 enum tls_handshake_type {
@@ -567,6 +691,192 @@ static void tls_generate_master_secret(struct l_tls *=
tls,
 	memset(tls->pending.server_random, 0, 32);
 }
 =

+static bool tls_send_rsa_client_key_xchg(struct l_tls *tls)
+{
+	uint8_t buf[1024 + 32];
+	uint8_t *ptr =3D buf + TLS_HANDSHAKE_HEADER_SIZE;
+	uint8_t pre_master_secret[48];
+	struct l_rsa *rsa_server_pubkey;
+	int key_size;
+	bool result;
+
+	if (!tls->peer_pubkey) {
+		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR, 0);
+
+		return false;
+	}
+
+	pre_master_secret[0] =3D (uint8_t) (TLS_VERSION >> 8);
+	pre_master_secret[1] =3D (uint8_t) (TLS_VERSION >> 0);
+	l_getrandom(pre_master_secret + 2, 46);
+
+	/* Fill in the RSA Client Key Exchange body */
+
+	rsa_server_pubkey =3D l_rsa_pkcs1_v1_5_new(tls->peer_pubkey,
+						tls->peer_pubkey_length);
+	if (!rsa_server_pubkey) {
+		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR, 0);
+
+		return false;
+	}
+
+	key_size =3D l_rsa_get_key_size(rsa_server_pubkey);
+
+	if (key_size + 32 > (int) sizeof(buf)) {
+		l_rsa_free(rsa_server_pubkey);
+
+		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR, 0);
+
+		return false;
+	}
+
+	l_put_be16(key_size, ptr);
+	result =3D l_rsa_encrypt(rsa_server_pubkey, pre_master_secret, ptr + 2,
+				48, key_size);
+	ptr +=3D key_size + 2;
+
+	l_rsa_free(rsa_server_pubkey);
+
+	if (!result) {
+		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR, 0);
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
+static bool tls_rsa_sign(struct l_tls *tls, uint8_t **out, const uint8_t *=
hash)
+{
+	struct l_rsa *rsa_privkey;
+	uint8_t *privkey, *privkey_short;
+	size_t key_size, short_size;
+	bool result, encrypted;
+	uint8_t digest_info[HANDSHAKE_HASH_SIZE + 32];
+	size_t digest_info_len;
+
+	if (!tls->priv_key_path) {
+		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR,
+				TLS_ALERT_BAD_CERT);
+
+		return false;
+	}
+
+	privkey =3D l_cert_load_key_file(tls->priv_key_path,
+					tls->priv_key_passphrase,
+					&key_size, &encrypted);
+	if (!privkey) {
+		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR,
+				TLS_ALERT_BAD_CERT);
+
+		return false;
+	}
+
+	privkey_short =3D l_cert_extract_rsakey(privkey, key_size, &short_size);
+	l_cert_free_key(privkey, key_size);
+
+	if (!privkey_short) {
+		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR,
+				TLS_ALERT_BAD_CERT);
+
+		return false;
+	}
+
+	rsa_privkey =3D l_rsa_pkcs1_v1_5_new(privkey_short, short_size);
+	l_cert_free_key(privkey_short, short_size);
+
+	if (!rsa_privkey) {
+		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR, 0);
+
+		return false;
+	}
+
+	key_size =3D l_rsa_get_key_size(rsa_privkey);
+
+	/*
+	 * TODO: According to 4.7 we need to support at least two forms
+	 * of the signed content here and at least three in the verification:
+	 *  - pre 1.2 version which didn't use the DigestInfo form at all,
+	 *  - DigestInfo with NULL AlgorithmIdentifier.parameters,
+	 *  - DigestInfo with empty AlgorithmIdentifier.parameters.
+	 *
+	 * Additionally PKCS#1 now says BER is used in place of DER for
+	 * DigestInfo encoding which adds more ambiguity in the encoding.
+	 */
+	pkcs1_write_digest_info(HANDSHAKE_HASH_TYPE,
+				digest_info, &digest_info_len,
+				hash, HANDSHAKE_HASH_SIZE);
+
+	(*out)[0] =3D HANDSHAKE_HASH_TYPE_TLS;
+	(*out)[1] =3D 1;	/* RSA_sign */
+	l_put_be16(key_size, *out + 2);
+	result =3D l_rsa_sign(rsa_privkey, digest_info, *out + 4,
+				digest_info_len, key_size);
+	*out +=3D key_size + 4;
+
+	l_rsa_free(rsa_privkey);
+
+	return result;
+}
+
+static bool tls_rsa_verify(struct l_tls *tls, const uint8_t *in, size_t le=
n,
+				const uint8_t *hash)
+{
+	struct l_rsa *rsa_client_pubkey;
+	size_t key_size;
+	bool result;
+	uint8_t expected[HANDSHAKE_HASH_SIZE + 32];
+	size_t expected_len;
+	uint8_t *digest_info;
+
+	if (len < 4 || (size_t) l_get_be16(in + 2) + 4 !=3D len) {
+		tls_disconnect(tls, TLS_ALERT_DECODE_ERROR, 0);
+
+		return false;
+	}
+
+	rsa_client_pubkey =3D l_rsa_pkcs1_v1_5_new(tls->peer_pubkey,
+						tls->peer_pubkey_length);
+	if (!rsa_client_pubkey) {
+		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR, 0);
+
+		return false;
+	}
+
+	key_size =3D l_rsa_get_key_size(rsa_client_pubkey);
+
+	/* Only the default hash type supported */
+	if (len !=3D 4 + key_size ||
+			in[0] !=3D HANDSHAKE_HASH_TYPE_TLS ||
+			in[1] !=3D 1 /* RSA_sign */) {
+		tls_disconnect(tls, TLS_ALERT_DECRYPT_ERROR, 0);
+
+		return false;
+	}
+
+	pkcs1_write_digest_info(HANDSHAKE_HASH_TYPE, expected, &expected_len,
+				hash, HANDSHAKE_HASH_SIZE);
+	digest_info =3D alloca(key_size);
+
+	result =3D l_rsa_verify(rsa_client_pubkey, in + 4, digest_info,
+				key_size, expected_len);
+
+	l_rsa_free(rsa_client_pubkey);
+
+	if (!result || memcmp(digest_info, expected, expected_len)) {
+		tls_disconnect(tls, TLS_ALERT_DECRYPT_ERROR, 0);
+
+		return false;
+	}
+
+	return true;
+}
+
 static void tls_get_handshake_hash(struct l_tls *tls, uint8_t *out)
 {
 	struct l_checksum *hash =3D l_checksum_clone(tls->handshake_hash);
@@ -1027,6 +1337,98 @@ static void tls_handle_server_hello_done(struct l_tl=
s *tls,
 	tls->state =3D TLS_HANDSHAKE_WAIT_CHANGE_CIPHER_SPEC;
 }
 =

+static void tls_handle_rsa_client_key_xchg(struct l_tls *tls,
+						const uint8_t *buf, size_t len)
+{
+	uint8_t pre_master_secret[48], random_secret[46];
+	struct l_rsa *rsa_server_privkey;
+	uint8_t *privkey, *privkey_short;
+	size_t key_size, short_size;
+	bool result, encrypted;
+
+	if (!tls->priv_key_path) {
+		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR,
+				TLS_ALERT_BAD_CERT);
+
+		return;
+	}
+
+	privkey =3D l_cert_load_key_file(tls->priv_key_path,
+					tls->priv_key_passphrase,
+					&key_size, &encrypted);
+	if (!privkey) {
+		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR,
+				TLS_ALERT_BAD_CERT);
+
+		return;
+	}
+
+	privkey_short =3D l_cert_extract_rsakey(privkey, key_size, &short_size);
+	l_cert_free_key(privkey, key_size);
+
+	if (!privkey_short) {
+		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR,
+				TLS_ALERT_BAD_CERT);
+
+		return;
+	}
+
+	rsa_server_privkey =3D l_rsa_pkcs1_v1_5_new(privkey_short, short_size);
+	l_cert_free_key(privkey_short, short_size);
+
+	if (!rsa_server_privkey) {
+		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR, 0);
+
+		return;
+	}
+
+	key_size =3D l_rsa_get_key_size(rsa_server_privkey);
+
+	if (len !=3D key_size + 2) {
+		l_rsa_free(rsa_server_privkey);
+
+		tls_disconnect(tls, TLS_ALERT_DECODE_ERROR, 0);
+
+		return;
+	}
+
+	len =3D l_get_be16(buf);
+
+	if (len !=3D key_size) {
+		l_rsa_free(rsa_server_privkey);
+
+		tls_disconnect(tls, TLS_ALERT_DECODE_ERROR, 0);
+
+		return;
+	}
+
+	result =3D l_rsa_decrypt(rsa_server_privkey, buf + 2, pre_master_secret,
+				key_size, 48);
+	l_rsa_free(rsa_server_privkey);
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
+	if (!result)
+		memcpy(pre_master_secret + 2, random_secret, 46);
+
+	tls_generate_master_secret(tls, pre_master_secret, 48);
+	memset(pre_master_secret, 0, 48);
+	memset(random_secret, 0, 46);
+}
+
 static void tls_handle_certificate_verify(struct l_tls *tls,
 						const uint8_t *buf, size_t len)
 {
-- =

2.1.4


--===============0709942245304439020==--

