Content-Type: multipart/mixed; boundary="===============7830616866981605633=="
MIME-Version: 1.0
From: Brian Gix <brian.gix@intel.com>
Subject: [PATCH] cipher: Use single SK for AEAD ciphers
Date: Sat, 01 Jun 2019 11:19:58 -0700
Message-ID: <20190601181958.3170-1-brian.gix@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7830616866981605633==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/cipher.c | 27 +++++++--------------------
 1 file changed, 7 insertions(+), 20 deletions(-)

diff --git a/ell/cipher.c b/ell/cipher.c
index 7b909df..4a27b5e 100644
--- a/ell/cipher.c
+++ b/ell/cipher.c
@@ -99,8 +99,7 @@ struct l_cipher {
 =

 struct l_aead_cipher {
 	int type;
-	int encrypt_sk;
-	int decrypt_sk;
+	int sk;
 };
 =

 static int create_alg(const char *alg_type, const char *alg_name,
@@ -229,21 +228,10 @@ LIB_EXPORT struct l_aead_cipher *l_aead_cipher_new(en=
um l_aead_cipher_type type,
 	cipher->type =3D type;
 	alg_name =3D aead_cipher_type_to_name(type);
 =

-	cipher->encrypt_sk =3D create_alg("aead", alg_name, key, key_length,
-					tag_length);
-	if (cipher->encrypt_sk < 0)
-		goto error_free;
-
-	cipher->decrypt_sk =3D create_alg("aead", alg_name, key, key_length,
-					tag_length);
-	if (cipher->decrypt_sk < 0)
-		goto error_close;
+	cipher->sk =3D create_alg("aead", alg_name, key, key_length, tag_length);
+	if (cipher->sk >=3D 0)
+		return cipher;
 =

-	return cipher;
-
-error_close:
-	close(cipher->encrypt_sk);
-error_free:
 	l_free(cipher);
 	return NULL;
 }
@@ -264,8 +252,7 @@ LIB_EXPORT void l_aead_cipher_free(struct l_aead_cipher=
 *cipher)
 	if (unlikely(!cipher))
 		return;
 =

-	close(cipher->encrypt_sk);
-	close(cipher->decrypt_sk);
+	close(cipher->sk);
 =

 	l_free(cipher);
 }
@@ -570,7 +557,7 @@ LIB_EXPORT bool l_aead_cipher_encrypt(struct l_aead_cip=
her *cipher,
 		iv_len =3D nonce_len;
 	}
 =

-	return operate_cipher(cipher->encrypt_sk, ALG_OP_ENCRYPT, in, in_len,
+	return operate_cipher(cipher->sk, ALG_OP_ENCRYPT, in, in_len,
 				ad, ad_len, iv, iv_len, out, out_len) =3D=3D
 			(ssize_t)out_len;
 }
@@ -605,7 +592,7 @@ LIB_EXPORT bool l_aead_cipher_decrypt(struct l_aead_cip=
her *cipher,
 		iv_len =3D nonce_len;
 	}
 =

-	return operate_cipher(cipher->decrypt_sk, ALG_OP_DECRYPT, in, in_len,
+	return operate_cipher(cipher->sk, ALG_OP_DECRYPT, in, in_len,
 				ad, ad_len, iv, iv_len, out, out_len) =3D=3D
 			(ssize_t)out_len;
 }
-- =

2.20.1


--===============7830616866981605633==--

