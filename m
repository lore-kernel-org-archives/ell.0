Content-Type: multipart/mixed; boundary="===============1346051890407378122=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 2/9] cipher: Remove l_asymmetric_cipher
Date: Fri, 23 Sep 2016 16:02:15 -0700
Message-ID: <20160923230222.27401-2-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20160923230222.27401-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1346051890407378122==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

AF_ALG akcipher hasn't been merged to the mainline kernel, and it doesn't
appear likely that it will be. ELL has access to RSA crypto in the l_key
module using the keyctl syscall, so l_asymmetric_cipher is not needed.
---
 ell/cipher.c | 161 -------------------------------------------------------=
----
 ell/cipher.h |  27 ----------
 2 files changed, 188 deletions(-)

diff --git a/ell/cipher.c b/ell/cipher.c
index daa2c2b..0af0b4b 100644
--- a/ell/cipher.c
+++ b/ell/cipher.c
@@ -293,12 +293,6 @@ LIB_EXPORT bool l_cipher_set_iv(struct l_cipher *ciphe=
r, const uint8_t *iv,
 	return true;
 }
 =

-struct l_asymmetric_cipher {
-	int type;
-	int sk;
-	int key_size;
-};
-
 static inline int parse_asn1_definite_length(const uint8_t **buf,
 						size_t *len)
 {
@@ -347,158 +341,3 @@ uint8_t *der_find_elem(uint8_t *buf, size_t len_in, i=
nt index,
 		len_in -=3D tlv_len;
 	}
 }
-
-static bool parse_rsa_key(struct l_asymmetric_cipher *cipher, const void *=
key,
-				size_t key_length)
-{
-	/*
-	 * Parse the DER-encoded public or private RSA key to find
-	 * and cache the size of the modulus n for later use.
-	 * (RFC3279)
-	 */
-	size_t seq_length;
-	size_t n_length;
-	uint8_t *seq;
-	uint8_t *der;
-	uint8_t tag;
-
-	if (key_length < 8)
-		return false;
-
-	/* Unpack the outer SEQUENCE */
-	seq =3D der_find_elem((uint8_t *) key, key_length, 0, &tag, &seq_length);
-	if (!seq || tag !=3D ASN1_ID_SEQUENCE)
-		return false;
-
-	/* First INTEGER may be a 1-byte version (for private key) or
-	 * the modulus (public key)
-	 */
-	der =3D der_find_elem(seq, seq_length, 0, &tag, &n_length);
-	if (der && tag =3D=3D ASN1_ID_INTEGER && n_length =3D=3D 1) {
-		/* Found version number, implies this is a private key. */
-		der =3D der_find_elem(seq, seq_length, 1, &tag, &n_length);
-	}
-
-	if (!der || tag !=3D ASN1_ID_INTEGER || n_length < 4)
-		return false;
-
-	/* Skip leading zeros */
-	while (n_length && der[0] =3D=3D 0x00) {
-		der++;
-		n_length--;
-	}
-
-	cipher->key_size =3D n_length;
-
-	return true;
-}
-
-LIB_EXPORT struct l_asymmetric_cipher *l_asymmetric_cipher_new(
-					enum l_asymmetric_cipher_type type,
-					const void *key, size_t key_length,
-					bool public_key)
-{
-	struct l_asymmetric_cipher *cipher;
-	const char *alg_name;
-
-	if (unlikely(!key))
-		return NULL;
-
-	if (type !=3D L_CIPHER_RSA_PKCS1_V1_5)
-		return NULL;
-
-	cipher =3D l_new(struct l_asymmetric_cipher, 1);
-	cipher->type =3D type;
-
-	switch (type) {
-	case L_CIPHER_RSA_PKCS1_V1_5:
-		if (!parse_rsa_key(cipher, key, key_length))
-			goto error_free;
-
-		alg_name =3D "pkcs1pad(rsa)";
-		break;
-	}
-
-	cipher->sk =3D create_alg("akcipher", alg_name, key, key_length,
-				public_key);
-	if (cipher->sk < 0)
-		goto error_free;
-
-	return cipher;
-
-error_free:
-	l_free(cipher);
-	return NULL;
-}
-
-LIB_EXPORT void l_asymmetric_cipher_free(struct l_asymmetric_cipher *ciphe=
r)
-{
-	if (unlikely(!cipher))
-		return;
-
-	close(cipher->sk);
-
-	l_free(cipher);
-}
-
-LIB_EXPORT int l_asymmetric_cipher_get_key_size(
-					struct l_asymmetric_cipher *cipher)
-{
-	return cipher->key_size;
-}
-
-LIB_EXPORT ssize_t l_asymmetric_cipher_encrypt(struct l_asymmetric_cipher =
*cipher,
-						const void *in, void *out,
-						size_t len_in, size_t len_out)
-{
-	if (unlikely(!cipher))
-		return false;
-
-	if (unlikely(!in) || unlikely(!out))
-		return false;
-
-	return operate_cipher(cipher->sk, ALG_OP_ENCRYPT, in, out, len_in,
-				len_out);
-}
-
-LIB_EXPORT ssize_t l_asymmetric_cipher_decrypt(struct l_asymmetric_cipher =
*cipher,
-						const void *in, void *out,
-						size_t len_in, size_t len_out)
-{
-	if (unlikely(!cipher))
-		return false;
-
-	if (unlikely(!in) || unlikely(!out))
-		return false;
-
-	return operate_cipher(cipher->sk, ALG_OP_DECRYPT, in, out, len_in,
-				len_out);
-}
-
-LIB_EXPORT ssize_t l_asymmetric_cipher_sign(struct l_asymmetric_cipher *ci=
pher,
-						const void *in, void *out,
-						size_t len_in, size_t len_out)
-{
-	if (unlikely(!cipher))
-		return false;
-
-	if (unlikely(!in) || unlikely(!out))
-		return false;
-
-	return operate_cipher(cipher->sk, ALG_OP_SIGN, in, out, len_in,
-				len_out);
-}
-
-LIB_EXPORT ssize_t l_asymmetric_cipher_verify(struct l_asymmetric_cipher *=
cipher,
-						const void *in, void *out,
-						size_t len_in, size_t len_out)
-{
-	if (unlikely(!cipher))
-		return false;
-
-	if (unlikely(!in) || unlikely(!out))
-		return false;
-
-	return operate_cipher(cipher->sk, ALG_OP_VERIFY, in, out, len_in,
-				len_out);
-}
diff --git a/ell/cipher.h b/ell/cipher.h
index 45e51c7..9f09d76 100644
--- a/ell/cipher.h
+++ b/ell/cipher.h
@@ -50,37 +50,10 @@ bool l_cipher_decrypt(struct l_cipher *cipher,
 bool l_cipher_set_iv(struct l_cipher *cipher, const uint8_t *iv,
 			size_t iv_length);
 =

-struct l_asymmetric_cipher;
-
 enum l_asymmetric_cipher_type {
 	L_CIPHER_RSA_PKCS1_V1_5,
 };
 =

-struct l_asymmetric_cipher *l_asymmetric_cipher_new(
-					enum l_asymmetric_cipher_type type,
-					const void *key, size_t key_length,
-					bool public_key);
-
-void l_asymmetric_cipher_free(struct l_asymmetric_cipher *cipher);
-
-int l_asymmetric_cipher_get_key_size(struct l_asymmetric_cipher *cipher);
-
-ssize_t l_asymmetric_cipher_encrypt(struct l_asymmetric_cipher *cipher,
-					const void *in, void *out,
-					size_t len_in, size_t len_out);
-
-ssize_t l_asymmetric_cipher_decrypt(struct l_asymmetric_cipher *cipher,
-					const void *in, void *out,
-					size_t len_in, size_t len_out);
-
-ssize_t l_asymmetric_cipher_sign(struct l_asymmetric_cipher *cipher,
-					const void *in, void *out,
-					size_t len_in, size_t len_out);
-
-ssize_t l_asymmetric_cipher_verify(struct l_asymmetric_cipher *cipher,
-					const void *in, void *out,
-					size_t len_in, size_t len_out);
-
 #ifdef __cplusplus
 }
 #endif
-- =

2.10.0


--===============1346051890407378122==--

