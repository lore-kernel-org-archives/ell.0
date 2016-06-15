Content-Type: multipart/mixed; boundary="===============5809390771979401786=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH v4 6/6] cipher: Use only one socket for asymmetric cipher
Date: Wed, 15 Jun 2016 10:18:23 -0700
Message-ID: <20160615171823.20699-6-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20160615171823.20699-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5809390771979401786==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/cipher.c | 40 +++++++++++++++-------------------------
 1 file changed, 15 insertions(+), 25 deletions(-)

diff --git a/ell/cipher.c b/ell/cipher.c
index d1b3845..b51a96d 100644
--- a/ell/cipher.c
+++ b/ell/cipher.c
@@ -290,7 +290,8 @@ LIB_EXPORT bool l_cipher_set_iv(struct l_cipher *cipher=
, const uint8_t *iv,
 }
 =

 struct l_asymmetric_cipher {
-	struct l_cipher cipher;
+	int type;
+	int sk;
 	int key_size;
 };
 =

@@ -403,7 +404,7 @@ LIB_EXPORT struct l_asymmetric_cipher *l_asymmetric_cip=
her_new(
 		return NULL;
 =

 	cipher =3D l_new(struct l_asymmetric_cipher, 1);
-	cipher->cipher.type =3D type;
+	cipher->type =3D type;
 =

 	switch (type) {
 	case L_CIPHER_RSA_PKCS1_V1_5:
@@ -414,23 +415,13 @@ LIB_EXPORT struct l_asymmetric_cipher *l_asymmetric_c=
ipher_new(
 		break;
 	}
 =

-	cipher->cipher.encrypt_sk =3D create_alg("akcipher", alg_name,
-						key, key_length, public_key);
-	if (cipher->cipher.encrypt_sk < 0)
+	cipher->sk =3D create_alg("akcipher", alg_name, key, key_length,
+				public_key);
+	if (cipher->sk < 0)
 		goto error_free;
 =

-	if (public_key) {
-		cipher->cipher.decrypt_sk =3D create_alg("akcipher", alg_name,
-							key, key_length,
-							public_key);
-		if (cipher->cipher.decrypt_sk < 0)
-			goto error_close;
-	}
-
 	return cipher;
 =

-error_close:
-	close(cipher->cipher.encrypt_sk);
 error_free:
 	l_free(cipher);
 	return NULL;
@@ -441,8 +432,7 @@ LIB_EXPORT void l_asymmetric_cipher_free(struct l_asymm=
etric_cipher *cipher)
 	if (unlikely(!cipher))
 		return;
 =

-	close(cipher->cipher.encrypt_sk);
-	close(cipher->cipher.decrypt_sk);
+	close(cipher->sk);
 =

 	l_free(cipher);
 }
@@ -463,8 +453,8 @@ LIB_EXPORT ssize_t l_asymmetric_cipher_encrypt(struct l=
_asymmetric_cipher *ciphe
 	if (unlikely(!in) || unlikely(!out))
 		return false;
 =

-	return operate_cipher(cipher->cipher.encrypt_sk, ALG_OP_ENCRYPT,
-				in, out, len_in, len_out);
+	return operate_cipher(cipher->sk, ALG_OP_ENCRYPT, in, out, len_in,
+				len_out);
 }
 =

 LIB_EXPORT ssize_t l_asymmetric_cipher_decrypt(struct l_asymmetric_cipher =
*cipher,
@@ -477,8 +467,8 @@ LIB_EXPORT ssize_t l_asymmetric_cipher_decrypt(struct l=
_asymmetric_cipher *ciphe
 	if (unlikely(!in) || unlikely(!out))
 		return false;
 =

-	return operate_cipher(cipher->cipher.decrypt_sk, ALG_OP_DECRYPT,
-				in, out, len_in, len_out);
+	return operate_cipher(cipher->sk, ALG_OP_DECRYPT, in, out, len_in,
+				len_out);
 }
 =

 LIB_EXPORT ssize_t l_asymmetric_cipher_sign(struct l_asymmetric_cipher *ci=
pher,
@@ -491,8 +481,8 @@ LIB_EXPORT ssize_t l_asymmetric_cipher_sign(struct l_as=
ymmetric_cipher *cipher,
 	if (unlikely(!in) || unlikely(!out))
 		return false;
 =

-	return operate_cipher(cipher->cipher.decrypt_sk, ALG_OP_SIGN,
-				in, out, len_in, len_out);
+	return operate_cipher(cipher->sk, ALG_OP_SIGN, in, out, len_in,
+				len_out);
 }
 =

 LIB_EXPORT ssize_t l_asymmetric_cipher_verify(struct l_asymmetric_cipher *=
cipher,
@@ -505,6 +495,6 @@ LIB_EXPORT ssize_t l_asymmetric_cipher_verify(struct l_=
asymmetric_cipher *cipher
 	if (unlikely(!in) || unlikely(!out))
 		return false;
 =

-	return operate_cipher(cipher->cipher.encrypt_sk, ALG_OP_VERIFY,
-				in, out, len_in, len_out);
+	return operate_cipher(cipher->sk, ALG_OP_VERIFY, in, out, len_in,
+				len_out);
 }
-- =

2.9.0


--===============5809390771979401786==--

