Content-Type: multipart/mixed; boundary="===============5502946127891724313=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 1/4] cipher: Correctly propagate AEAD failures
Date: Wed, 24 Jan 2018 13:51:26 -0800
Message-ID: <20180124215129.13337-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5502946127891724313==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Some pre-4.9 kernels have an AEAD bug that makes recvmsg() return an
incorrect value that does not include the AAD length. This could cause
an erroneous successful return from l_aead_cipher_{en,de}crypt() if
ad_len was longer than the expected output. operate_cipher() now returns
the number of bytes copied to the 'out' buffer, and the AEAD functions
only succeed if the expected number of bytes were copied.
---
 ell/cipher.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/ell/cipher.c b/ell/cipher.c
index bbf0a48..bfbe5d4 100644
--- a/ell/cipher.c
+++ b/ell/cipher.c
@@ -378,8 +378,10 @@ static ssize_t operate_cipher(int sk, __u32 operation,
 =

 		result =3D recvmsg(sk, &msg, 0);
 =

-		if (result > (ssize_t) ad_len)
+		if (result >=3D (ssize_t) ad_len)
 			result -=3D ad_len;
+		else if (result > 0)
+			result =3D 0;
 =

 		l_free(iov[0].iov_base);
 	} else {
@@ -546,7 +548,8 @@ LIB_EXPORT bool l_aead_cipher_encrypt(struct l_aead_cip=
her *cipher,
 =

 	return operate_cipher(cipher->encrypt_sk, ALG_OP_ENCRYPT, in, in_len,
 				ad, ad_len, nonce, nonce_len, out, out_len,
-				l_aead_cipher_get_ivlen(cipher)) >=3D 0;
+				l_aead_cipher_get_ivlen(cipher)) =3D=3D
+			(ssize_t)out_len;
 }
 =

 LIB_EXPORT bool l_aead_cipher_decrypt(struct l_aead_cipher *cipher,
@@ -563,7 +566,8 @@ LIB_EXPORT bool l_aead_cipher_decrypt(struct l_aead_cip=
her *cipher,
 =

 	return operate_cipher(cipher->decrypt_sk, ALG_OP_DECRYPT, in, in_len,
 				ad, ad_len, nonce, nonce_len, out, out_len,
-				l_aead_cipher_get_ivlen(cipher)) >=3D 0;
+				l_aead_cipher_get_ivlen(cipher)) =3D=3D
+			(ssize_t)out_len;
 }
 =

 static void init_supported()
-- =

2.16.1


--===============5502946127891724313==--

