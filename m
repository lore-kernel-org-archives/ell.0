Content-Type: multipart/mixed; boundary="===============0758647028816277704=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH v6 2/5] cipher: Return number of read bytes from asymmetric ops
Date: Mon, 20 Jun 2016 14:47:17 -0700
Message-ID: <20160620214720.24016-2-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20160620214720.24016-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0758647028816277704==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

When using asymmetric cipher operations, the data written to the
output buffer might be shorter than the full buffer size. The number
of bytes read is now returned from the asymmetric
encrypt/decrypt/sign/verify functions. A negative error code is
returned if the call fails.
---
 ell/cipher.c | 41 ++++++++++++++++++++---------------------
 ell/cipher.h | 16 ++++++++--------
 ell/tls.c    | 50 ++++++++++++++++++++++++++------------------------
 3 files changed, 54 insertions(+), 53 deletions(-)

diff --git a/ell/cipher.c b/ell/cipher.c
index 04ef838..d1b3845 100644
--- a/ell/cipher.c
+++ b/ell/cipher.c
@@ -192,7 +192,7 @@ LIB_EXPORT void l_cipher_free(struct l_cipher *cipher)
 	l_free(cipher);
 }
 =

-static bool operate_cipher(int sk, __u32 operation,
+static ssize_t operate_cipher(int sk, __u32 operation,
 				const void *in, void *out, size_t len_in,
 				size_t len_out)
 {
@@ -200,6 +200,7 @@ static bool operate_cipher(int sk, __u32 operation,
 	struct msghdr msg;
 	struct cmsghdr *c_msg;
 	struct iovec iov;
+	ssize_t result;
 =

 	memset(&c_msg_buf, 0, sizeof(c_msg_buf));
 	memset(&msg, 0, sizeof(msg));
@@ -219,13 +220,11 @@ static bool operate_cipher(int sk, __u32 operation,
 	msg.msg_iov =3D &iov;
 	msg.msg_iovlen =3D 1;
 =

-	if (sendmsg(sk, &msg, 0) < 0)
-		return false;
-
-	if (read(sk, out, len_out) < 0)
-		return false;
+	result =3D sendmsg(sk, &msg, 0);
+	if (result < 0)
+		return result;
 =

-	return true;
+	return read(sk, out, len_out);
 }
 =

 LIB_EXPORT bool l_cipher_encrypt(struct l_cipher *cipher,
@@ -238,7 +237,7 @@ LIB_EXPORT bool l_cipher_encrypt(struct l_cipher *ciphe=
r,
 		return false;
 =

 	return operate_cipher(cipher->encrypt_sk, ALG_OP_ENCRYPT, in, out, len,
-				len);
+				len) >=3D 0;
 }
 =

 LIB_EXPORT bool l_cipher_decrypt(struct l_cipher *cipher,
@@ -251,7 +250,7 @@ LIB_EXPORT bool l_cipher_decrypt(struct l_cipher *ciphe=
r,
 		return false;
 =

 	return operate_cipher(cipher->decrypt_sk, ALG_OP_DECRYPT, in, out, len,
-				len);
+				len) >=3D 0;
 }
 =

 LIB_EXPORT bool l_cipher_set_iv(struct l_cipher *cipher, const uint8_t *iv,
@@ -454,9 +453,9 @@ LIB_EXPORT int l_asymmetric_cipher_get_key_size(
 	return cipher->key_size;
 }
 =

-LIB_EXPORT bool l_asymmetric_cipher_encrypt(struct l_asymmetric_cipher *ci=
pher,
-					const void *in, void *out,
-					size_t len_in, size_t len_out)
+LIB_EXPORT ssize_t l_asymmetric_cipher_encrypt(struct l_asymmetric_cipher =
*cipher,
+						const void *in, void *out,
+						size_t len_in, size_t len_out)
 {
 	if (unlikely(!cipher))
 		return false;
@@ -468,9 +467,9 @@ LIB_EXPORT bool l_asymmetric_cipher_encrypt(struct l_as=
ymmetric_cipher *cipher,
 				in, out, len_in, len_out);
 }
 =

-LIB_EXPORT bool l_asymmetric_cipher_decrypt(struct l_asymmetric_cipher *ci=
pher,
-					const void *in, void *out,
-					size_t len_in, size_t len_out)
+LIB_EXPORT ssize_t l_asymmetric_cipher_decrypt(struct l_asymmetric_cipher =
*cipher,
+						const void *in, void *out,
+						size_t len_in, size_t len_out)
 {
 	if (unlikely(!cipher))
 		return false;
@@ -482,9 +481,9 @@ LIB_EXPORT bool l_asymmetric_cipher_decrypt(struct l_as=
ymmetric_cipher *cipher,
 				in, out, len_in, len_out);
 }
 =

-LIB_EXPORT bool l_asymmetric_cipher_sign(struct l_asymmetric_cipher *ciphe=
r,
-					const void *in, void *out,
-					size_t len_in, size_t len_out)
+LIB_EXPORT ssize_t l_asymmetric_cipher_sign(struct l_asymmetric_cipher *ci=
pher,
+						const void *in, void *out,
+						size_t len_in, size_t len_out)
 {
 	if (unlikely(!cipher))
 		return false;
@@ -496,9 +495,9 @@ LIB_EXPORT bool l_asymmetric_cipher_sign(struct l_asymm=
etric_cipher *cipher,
 				in, out, len_in, len_out);
 }
 =

-LIB_EXPORT bool l_asymmetric_cipher_verify(struct l_asymmetric_cipher *cip=
her,
-					const void *in, void *out,
-					size_t len_in, size_t len_out)
+LIB_EXPORT ssize_t l_asymmetric_cipher_verify(struct l_asymmetric_cipher *=
cipher,
+						const void *in, void *out,
+						size_t len_in, size_t len_out)
 {
 	if (unlikely(!cipher))
 		return false;
diff --git a/ell/cipher.h b/ell/cipher.h
index b958804..45e51c7 100644
--- a/ell/cipher.h
+++ b/ell/cipher.h
@@ -65,21 +65,21 @@ void l_asymmetric_cipher_free(struct l_asymmetric_ciphe=
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
diff --git a/ell/tls.c b/ell/tls.c
index e03b464..854a287 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -862,7 +862,7 @@ static bool tls_send_rsa_client_key_xchg(struct l_tls *=
tls)
 	uint8_t pre_master_secret[48];
 	struct l_asymmetric_cipher *rsa_server_pubkey;
 	int key_size;
-	bool result;
+	ssize_t bytes_encrypted;
 =

 	if (!tls->peer_pubkey) {
 		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR, 0);
@@ -897,14 +897,14 @@ static bool tls_send_rsa_client_key_xchg(struct l_tls=
 *tls)
 	}
 =

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
 =

 		return false;
@@ -925,6 +925,7 @@ static ssize_t tls_rsa_sign(struct l_tls *tls, uint8_t =
*out, size_t len,
 	uint8_t *privkey;
 	size_t key_size;
 	ssize_t result;
+	ssize_t sign_output_len;
 	const struct tls_hash_algorithm *hash_type;
 	uint8_t hash[HANDSHAKE_HASH_MAX_SIZE];
 	uint8_t sign_input[HANDSHAKE_HASH_MAX_SIZE * 2 + 32];
@@ -985,13 +986,15 @@ static ssize_t tls_rsa_sign(struct l_tls *tls, uint8_=
t *out, size_t len,
 		}
 =

 		l_put_be16(key_size, out);
-		if (l_asymmetric_cipher_sign(rsa_privkey, sign_input,
-						out + 2, sign_input_len,
-						key_size)) {
+		sign_output_len =3D l_asymmetric_cipher_sign(rsa_privkey,
+								sign_input,
+								out + 2,
+								sign_input_len,
+								key_size);
+		if (sign_output_len =3D=3D (ssize_t) key_size)
 			result =3D expected_bytes;
-		} else {
+		else
 			result =3D -EMSGSIZE;
-		}
 	} else {
 		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR, 0);
 		result =3D -EMSGSIZE;
@@ -1007,7 +1010,7 @@ static bool tls_rsa_verify(struct l_tls *tls, const u=
int8_t *in, size_t len,
 {
 	struct l_asymmetric_cipher *rsa_client_pubkey;
 	size_t key_size;
-	bool result;
+	ssize_t verify_bytes;
 	uint8_t hash[HANDSHAKE_HASH_MAX_SIZE];
 	size_t hash_len;
 	enum l_checksum_type hash_type;
@@ -1090,18 +1093,16 @@ static bool tls_rsa_verify(struct l_tls *tls, const=
 uint8_t *in, size_t len,
 		 */
 	}
 =

-	if (expected_len > key_size)
-		goto err_free_rsa;
-
-	digest_info =3D alloca(key_size);
+	digest_info =3D alloca(expected_len);
 =

-	result =3D l_asymmetric_cipher_verify(rsa_client_pubkey, in + 4,
-						digest_info,
-						key_size, key_size);
+	verify_bytes =3D l_asymmetric_cipher_verify(rsa_client_pubkey, in + 4,
+							digest_info, key_size,
+							expected_len);
 =

 	l_asymmetric_cipher_free(rsa_client_pubkey);
 =

-	if (!result || memcmp(digest_info, expected, expected_len)) {
+	if (verify_bytes !=3D (ssize_t)expected_len ||
+		memcmp(digest_info, expected, expected_len)) {
 		tls_disconnect(tls, TLS_ALERT_DECRYPT_ERROR, 0);
 =

 		return false;
@@ -1763,7 +1764,7 @@ static void tls_handle_rsa_client_key_xchg(struct l_t=
ls *tls,
 	struct l_asymmetric_cipher *rsa_server_privkey;
 	uint8_t *privkey;
 	size_t key_size;
-	bool result;
+	ssize_t bytes_decrypted;
 =

 	if (!tls->priv_key_path) {
 		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR,
@@ -1813,9 +1814,10 @@ static void tls_handle_rsa_client_key_xchg(struct l_=
tls *tls,
 		return;
 	}
 =

-	result =3D l_asymmetric_cipher_decrypt(rsa_server_privkey, buf + 2,
-						pre_master_secret,
-						key_size, 48);
+	bytes_decrypted =3D l_asymmetric_cipher_decrypt(rsa_server_privkey,
+							buf + 2,
+							pre_master_secret,
+							key_size, 48);
 	l_asymmetric_cipher_free(rsa_server_privkey);
 =

 	/*
@@ -1833,7 +1835,7 @@ static void tls_handle_rsa_client_key_xchg(struct l_t=
ls *tls,
 	pre_master_secret[0] =3D tls->client_version >> 8;
 	pre_master_secret[1] =3D tls->client_version >> 0;
 =

-	if (!result)
+	if (bytes_decrypted !=3D 48)
 		memcpy(pre_master_secret + 2, random_secret, 46);
 =

 	tls_generate_master_secret(tls, pre_master_secret, 48);
-- =

2.9.0


--===============0758647028816277704==--

