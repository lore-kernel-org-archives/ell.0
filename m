Content-Type: multipart/mixed; boundary="===============0831164878393697846=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 10/11] cipher: Return result length from asymmetric cipher
 operations
Date: Mon, 06 Jun 2016 13:54:49 -0700
Message-ID: <20160606205450.23615-10-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20160606205450.23615-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0831164878393697846==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Short reads from AF_ALG akcipher sockets return an error rather than a
partial buffer so it's important to provide both an output buffer
length (which is typically longer than the expected data), and to find
out how many bytes were read.
---
 ell/cipher.c       | 64 +++++++++++++++++++++++-----------------
 ell/cipher.h       | 16 +++++-----
 ell/tls-private.h  |  2 +-
 ell/tls.c          | 86 ++++++++++++++++++++++++++++++++++++--------------=
----
 unit/test-cipher.c |  8 +++--
 5 files changed, 109 insertions(+), 67 deletions(-)

diff --git a/ell/cipher.c b/ell/cipher.c
index 04bbd82..04316d8 100644
--- a/ell/cipher.c
+++ b/ell/cipher.c
@@ -78,6 +78,13 @@ struct af_alg_iv {
 #define SOL_ALG 279
 #endif
 =

+#ifndef ALG_OP_SIGN
+#define ALG_OP_SIGN	2
+#endif
+#ifndef ALG_OP_VERIFY
+#define ALG_OP_VERIFY	3
+#endif
+
 #ifndef ALG_SET_PUBKEY
 #define ALG_SET_PUBKEY	6
 #endif
@@ -185,7 +192,7 @@ LIB_EXPORT void l_cipher_free(struct l_cipher *cipher)
 	l_free(cipher);
 }
 =

-static bool operate_cipher(int sk, __u32 operation,
+static ssize_t operate_cipher(int sk, __u32 operation,
 				const void *in, void *out, size_t len_in,
 				size_t len_out)
 {
@@ -215,10 +222,7 @@ static bool operate_cipher(int sk, __u32 operation,
 	if (sendmsg(sk, &msg, 0) < 0)
 		return false;
 =

-	if (read(sk, out, len_out) < 0)
-		return false;
-
-	return true;
+	return read(sk, out, len_out);
 }
 =

 LIB_EXPORT bool l_cipher_encrypt(struct l_cipher *cipher,
@@ -451,9 +455,9 @@ LIB_EXPORT int l_asymmetric_cipher_get_key_size(
 	return cipher->key_size;
 }
 =

-LIB_EXPORT bool l_asymmetric_cipher_encrypt(struct l_asymmetric_cipher *ac=
ipher,
-					const void *in, void *out,
-					size_t len_in, size_t len_out)
+LIB_EXPORT ssize_t l_asymmetric_cipher_encrypt(struct l_asymmetric_cipher =
*acipher,
+						const void *in, void *out,
+						size_t len_in, size_t len_out)
 {
 	if (unlikely(!acipher))
 		return false;
@@ -465,9 +469,9 @@ LIB_EXPORT bool l_asymmetric_cipher_encrypt(struct l_as=
ymmetric_cipher *acipher,
 				in, out, len_in, len_out);
 }
 =

-LIB_EXPORT bool l_asymmetric_cipher_decrypt(struct l_asymmetric_cipher *ac=
ipher,
-					const void *in, void *out,
-					size_t len_in, size_t len_out)
+LIB_EXPORT ssize_t l_asymmetric_cipher_decrypt(struct l_asymmetric_cipher =
*acipher,
+						const void *in, void *out,
+						size_t len_in, size_t len_out)
 {
 	if (unlikely(!acipher))
 		return false;
@@ -479,24 +483,30 @@ LIB_EXPORT bool l_asymmetric_cipher_decrypt(struct l_=
asymmetric_cipher *acipher,
 				in, out, len_in, len_out);
 }
 =

-LIB_EXPORT bool l_asymmetric_cipher_sign(struct l_asymmetric_cipher *ciphe=
r,
-					const void *in, void *out,
-					size_t len_in, size_t len_out)
+LIB_EXPORT ssize_t l_asymmetric_cipher_sign(struct l_asymmetric_cipher *ac=
ipher,
+						const void *in, void *out,
+						size_t len_in, size_t len_out)
 {
-	/*
-	 * The RSA signing operation uses the same primitive as
-	 * decryption so just call decrypt for now.
-	 */
-	return l_asymmetric_cipher_decrypt(cipher, in, out, len_in, len_out);
+	if (unlikely(!acipher))
+		return false;
+
+	if (unlikely(!in) || unlikely(!out))
+		return false;
+
+	return operate_cipher(acipher->cipher.decrypt_sk, ALG_OP_SIGN,
+				in, out, len_in, len_out);
 }
 =

-LIB_EXPORT bool l_asymmetric_cipher_verify(struct l_asymmetric_cipher *cip=
her,
-					const void *in, void *out,
-					size_t len_in, size_t len_out)
+LIB_EXPORT ssize_t l_asymmetric_cipher_verify(struct l_asymmetric_cipher *=
acipher,
+						const void *in, void *out,
+						size_t len_in, size_t len_out)
 {
-	/*
-	 * The RSA verify operation uses the same primitive as
-	 * encryption so just call encrypt.
-	 */
-	return l_asymmetric_cipher_encrypt(cipher, in, out, len_in, len_out);
+	if (unlikely(!acipher))
+		return false;
+
+	if (unlikely(!in) || unlikely(!out))
+		return false;
+
+	return operate_cipher(acipher->cipher.encrypt_sk, ALG_OP_VERIFY,
+				in, out, len_in, len_out);
 }
diff --git a/ell/cipher.h b/ell/cipher.h
index 329f667..a65903e 100644
--- a/ell/cipher.h
+++ b/ell/cipher.h
@@ -64,21 +64,21 @@ void l_asymmetric_cipher_free(struct l_asymmetric_ciphe=
r *cipher);
 =

 int l_asymmetric_cipher_get_key_size(struct l_asymmetric_cipher *cipher);
 =

-bool l_asymmetric_cipher_encrypt(struct l_asymmetric_cipher *cipher,
+ssize_t l_asymmetric_cipher_encrypt(struct l_asymmetric_cipher *cipher,
 					const void *in, void *out,
 					size_t len_in, size_t len_out);
 =

-bool l_asymmetric_cipher_decrypt(struct l_asymmetric_cipher *cipher,
+ssize_t l_asymmetric_cipher_decrypt(struct l_asymmetric_cipher *cipher,
 					const void *in, void *out,
 					size_t len_in, size_t len_out);
 =

-bool l_asymmetric_cipher_sign(struct l_asymmetric_cipher *cipher,
-				const void *in, void *out,
-				size_t len_in, size_t len_out);
+ssize_t l_asymmetric_cipher_sign(struct l_asymmetric_cipher *cipher,
+					const void *in, void *out,
+					size_t len_in, size_t len_out);
 =

-bool l_asymmetric_cipher_verify(struct l_asymmetric_cipher *cipher,
-				const void *in, void *out,
-				size_t len_in, size_t len_out);
+ssize_t l_asymmetric_cipher_verify(struct l_asymmetric_cipher *cipher,
+					const void *in, void *out,
+					size_t len_in, size_t len_out);
 =

 #ifdef __cplusplus
 }
diff --git a/ell/tls-private.h b/ell/tls-private.h
index 184f2ae..9ea1554 100644
--- a/ell/tls-private.h
+++ b/ell/tls-private.h
@@ -65,7 +65,7 @@ struct tls_key_exchange_algorithm {
 	void (*handle_client_key_exchange)(struct l_tls *tls,
 						const uint8_t *buf, size_t len);
 =

-	bool (*sign)(struct l_tls *tls, uint8_t **out,
+	bool (*sign)(struct l_tls *tls, uint8_t **out, size_t len,
 			tls_get_hash_t get_hash);
 	bool (*verify)(struct l_tls *tls, const uint8_t *in, size_t len,
 			tls_get_hash_t get_hash);
diff --git a/ell/tls.c b/ell/tls.c
index 6896a05..e1630c3 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -274,7 +274,7 @@ static bool tls_send_rsa_client_key_xchg(struct l_tls *=
tls);
 static void tls_handle_rsa_client_key_xchg(struct l_tls *tls,
 						const uint8_t *buf, size_t len);
 =

-static bool tls_rsa_sign(struct l_tls *tls, uint8_t **out,
+static bool tls_rsa_sign(struct l_tls *tls, uint8_t **out, size_t len,
 				tls_get_hash_t get_hash);
 static bool tls_rsa_verify(struct l_tls *tls, const uint8_t *in, size_t le=
n,
 				tls_get_hash_t get_hash);
@@ -856,10 +856,10 @@ static bool tls_send_rsa_client_key_xchg(struct l_tls=
 *tls)
 {
 	uint8_t buf[1024 + 32];
 	uint8_t *ptr =3D buf + TLS_HANDSHAKE_HEADER_SIZE;
-	uint8_t pre_master_secret[48];
+	uint8_t *pre_master_secret;
 	struct l_asymmetric_cipher *rsa_server_pubkey;
 	int key_size;
-	bool result;
+	ssize_t bytes_encrypted;
 =

 	if (!tls->peer_pubkey) {
 		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR, 0);
@@ -867,10 +867,6 @@ static bool tls_send_rsa_client_key_xchg(struct l_tls =
*tls)
 		return false;
 	}
 =

-	pre_master_secret[0] =3D (uint8_t) (TLS_VERSION >> 8);
-	pre_master_secret[1] =3D (uint8_t) (TLS_VERSION >> 0);
-	l_getrandom(pre_master_secret + 2, 46);
-
 	/* Fill in the RSA Client Key Exchange body */
 =

 	rsa_server_pubkey =3D l_asymmetric_cipher_new(L_CIPHER_RSA_PKCS1_V1_5,
@@ -892,16 +888,23 @@ static bool tls_send_rsa_client_key_xchg(struct l_tls=
 *tls)
 		return false;
 	}
 =

+	pre_master_secret =3D l_malloc(key_size);
+
+	pre_master_secret[0] =3D (uint8_t) (TLS_VERSION >> 8);
+	pre_master_secret[1] =3D (uint8_t) (TLS_VERSION >> 0);
+	l_getrandom(pre_master_secret + 2, 46);
+
 	l_put_be16(key_size, ptr);
-	result =3D l_asymmetric_cipher_encrypt(rsa_server_pubkey,
-						pre_master_secret, ptr + 2,
-						48, key_size);
+	bytes_encrypted =3D l_asymmetric_cipher_encrypt(rsa_server_pubkey,
+							pre_master_secret,
+							ptr + 2, 48, key_size);
 	ptr +=3D key_size + 2;
 =

 	l_asymmetric_cipher_free(rsa_server_pubkey);
 =

-	if (!result) {
+	if (bytes_encrypted !=3D key_size) {
 		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR, 0);
+		l_free(pre_master_secret);
 =

 		return false;
 	}
@@ -910,22 +913,30 @@ static bool tls_send_rsa_client_key_xchg(struct l_tls=
 *tls)
 =

 	tls_generate_master_secret(tls, pre_master_secret, 48);
 	memset(pre_master_secret, 0, 48);
+	l_free(pre_master_secret);
 =

 	return true;
 }
 =

-static bool tls_rsa_sign(struct l_tls *tls, uint8_t **out,
+static bool tls_rsa_sign(struct l_tls *tls, uint8_t **out, size_t len,
 				tls_get_hash_t get_hash)
 {
 	struct l_asymmetric_cipher *rsa_privkey;
 	uint8_t *privkey;
 	size_t key_size;
 	bool result;
+	ssize_t sign_output_len;
 	const struct tls_hash_algorithm *hash_type;
 	uint8_t hash[HANDSHAKE_HASH_MAX_SIZE];
 	uint8_t sign_input[HANDSHAKE_HASH_MAX_SIZE * 2 + 32];
 	size_t sign_input_len;
 =

+	if (len < 2) {
+		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR, 0);
+
+		return false;
+	}
+
 	if (!tls->priv_key_path) {
 		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR,
 				TLS_ALERT_BAD_CERT);
@@ -965,16 +976,25 @@ static bool tls_rsa_sign(struct l_tls *tls, uint8_t *=
*out,
 =

 		*(*out)++ =3D hash_type->tls_id;
 		*(*out)++ =3D 1;	/* RSA_sign */
+		len -=3D 2;
 	} else {
 		get_hash(tls, 1, sign_input + 0, NULL, NULL);	/* MD5 */
 		get_hash(tls, 2, sign_input + 16, NULL, NULL);	/* SHA1 */
 		sign_input_len =3D 36;
 	}
 =

-	l_put_be16(key_size, *out);
-	result =3D l_asymmetric_cipher_sign(rsa_privkey, sign_input, *out + 2,
-						sign_input_len, key_size);
-	*out +=3D key_size + 2;
+	if (len >=3D key_size + 2) {
+		l_put_be16(key_size, *out);
+		sign_output_len =3D l_asymmetric_cipher_sign(rsa_privkey,
+							   sign_input, *out + 2,
+							   sign_input_len,
+							   key_size);
+		*out +=3D sign_output_len + 2;
+		result =3D sign_output_len =3D=3D (ssize_t)key_size;
+	} else {
+		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR, 0);
+		result =3D false;
+	}
 =

 	l_asymmetric_cipher_free(rsa_privkey);
 =

@@ -986,7 +1006,7 @@ static bool tls_rsa_verify(struct l_tls *tls, const ui=
nt8_t *in, size_t len,
 {
 	struct l_asymmetric_cipher *rsa_client_pubkey;
 	size_t key_size;
-	bool result;
+	ssize_t verify_bytes;
 	uint8_t hash[HANDSHAKE_HASH_MAX_SIZE];
 	size_t hash_len;
 	enum l_checksum_type hash_type;
@@ -1073,13 +1093,14 @@ static bool tls_rsa_verify(struct l_tls *tls, const=
 uint8_t *in, size_t len,
 =

 	digest_info =3D alloca(key_size);
 =

-	result =3D l_asymmetric_cipher_verify(rsa_client_pubkey, in + 4,
-						digest_info,
-						key_size, key_size);
+	verify_bytes =3D l_asymmetric_cipher_verify(rsa_client_pubkey, in + 4,
+							digest_info, key_size,
+							key_size);
 =

 	l_asymmetric_cipher_free(rsa_client_pubkey);
 =

-	if (!result || memcmp(digest_info, expected, expected_len)) {
+	if (verify_bytes !=3D (ssize_t)expected_len ||
+		memcmp(digest_info, expected, expected_len)) {
 		tls_disconnect(tls, TLS_ALERT_DECRYPT_ERROR, 0);
 =

 		return false;
@@ -1139,7 +1160,8 @@ static bool tls_send_certificate_verify(struct l_tls =
*tls)
 	/* Fill in the Certificate Verify body */
 =

 	if (!tls->pending.cipher_suite->key_xchg->sign(tls, &ptr,
-						tls_get_handshake_hash_by_id))
+					2048 - TLS_HANDSHAKE_HEADER_SIZE,
+					tls_get_handshake_hash_by_id))
 		return false;
 =

 	/* Stop maintaining handshake message hashes other than SHA256. */
@@ -1732,11 +1754,12 @@ static void tls_handle_server_hello_done(struct l_t=
ls *tls,
 static void tls_handle_rsa_client_key_xchg(struct l_tls *tls,
 						const uint8_t *buf, size_t len)
 {
-	uint8_t pre_master_secret[48], random_secret[46];
+	uint8_t *pre_master_secret;
+	uint8_t random_secret[46];
 	struct l_asymmetric_cipher *rsa_server_privkey;
 	uint8_t *privkey;
 	size_t key_size;
-	bool result;
+	ssize_t bytes_decrypted;
 =

 	if (!tls->priv_key_path) {
 		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR,
@@ -1785,9 +1808,12 @@ static void tls_handle_rsa_client_key_xchg(struct l_=
tls *tls,
 		return;
 	}
 =

-	result =3D l_asymmetric_cipher_decrypt(rsa_server_privkey, buf + 2,
-						pre_master_secret,
-						key_size, 48);
+	pre_master_secret =3D l_malloc(key_size);
+
+	bytes_decrypted =3D l_asymmetric_cipher_decrypt(rsa_server_privkey,
+							buf + 2,
+							pre_master_secret,
+							key_size, key_size);
 	l_asymmetric_cipher_free(rsa_server_privkey);
 =

 	/*
@@ -1805,12 +1831,14 @@ static void tls_handle_rsa_client_key_xchg(struct l=
_tls *tls,
 	pre_master_secret[0] =3D tls->client_version >> 8;
 	pre_master_secret[1] =3D tls->client_version >> 0;
 =

-	if (!result)
+	if (bytes_decrypted !=3D 48)
 		memcpy(pre_master_secret + 2, random_secret, 46);
 =

 	tls_generate_master_secret(tls, pre_master_secret, 48);
-	memset(pre_master_secret, 0, 48);
+	memset(pre_master_secret, 0, key_size);
 	memset(random_secret, 0, 46);
+
+	l_free(pre_master_secret);
 }
 =

 static bool tls_get_prev_digest_by_id(struct l_tls *tls, uint8_t hash_id,
diff --git a/unit/test-cipher.c b/unit/test-cipher.c
index 2527dcc..23021bf 100644
--- a/unit/test-cipher.c
+++ b/unit/test-cipher.c
@@ -184,16 +184,20 @@ static void test_rsa(const void *data)
 {
 	struct l_asymmetric_cipher *cipher;
 	char buf[128];
+	ssize_t encrypted, decrypted;
 =

 	cipher =3D l_asymmetric_cipher_new(L_CIPHER_RSA_PKCS1_V1_5,
 						rsa_priv_key,
 						sizeof(rsa_priv_key));
 	assert(cipher);
-	assert(l_asymmetric_cipher_encrypt(cipher, FIXED_STR, buf, 100, 128));
+	encrypted =3D l_asymmetric_cipher_encrypt(cipher, FIXED_STR, buf,
+						100, 128);
+	assert(encrypted =3D=3D 128);
 =

 	assert(memcmp(FIXED_STR, buf, 100));
 =

-	assert(l_asymmetric_cipher_decrypt(cipher, buf, buf, 128, 128));
+	decrypted =3D l_asymmetric_cipher_decrypt(cipher, buf, buf, 128, 128);
+	assert(decrypted =3D=3D 100);
 =

 	assert(!memcmp(FIXED_STR, buf, 100));
 =

-- =

2.8.3


--===============0831164878393697846==--

