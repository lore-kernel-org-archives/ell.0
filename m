Content-Type: multipart/mixed; boundary="===============7695389704731119643=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 1/2] cipher: Add AEAD API with AES-CCM
Date: Wed, 21 Dec 2016 18:09:34 -0800
Message-ID: <20161222020935.21617-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7695389704731119643==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add new function calls to handle encryption and decryption for
authenticated encryption with associated data (AEAD).

The only AEAD cipher supported so far is AES-CCM.

Requires kernel v4.10 or later for l_aead_cipher_encrypt() and
l_aead_cipher_decrypt() to return the correct length. Earlier kernels have a
bug in AF_ALG aead sockets.
---
 ell/cipher.c | 238 ++++++++++++++++++++++++++++++++++++++++++++++++++++++-=
----
 ell/cipher.h |  24 ++++++
 2 files changed, 244 insertions(+), 18 deletions(-)

diff --git a/ell/cipher.c b/ell/cipher.c
index ac5248a..ddcd310 100644
--- a/ell/cipher.c
+++ b/ell/cipher.c
@@ -28,6 +28,7 @@
 #include <unistd.h>
 #include <errno.h>
 #include <sys/socket.h>
+#include <alloca.h>
 =

 #include "util.h"
 #include "cipher.h"
@@ -85,8 +86,14 @@ struct l_cipher {
 	int decrypt_sk;
 };
 =

+struct l_aead_cipher {
+	int type;
+	int encrypt_sk;
+	int decrypt_sk;
+};
+
 static int create_alg(const char *alg_type, const char *alg_name,
-			const void *key, size_t key_length)
+			const void *key, size_t key_length, size_t tag_length)
 {
 	struct sockaddr_alg salg;
 	int sk;
@@ -111,6 +118,12 @@ static int create_alg(const char *alg_type, const char=
 *alg_name,
 		return -1;
 	}
 =

+	if (tag_length && setsockopt(sk, SOL_ALG, ALG_SET_AEAD_AUTHSIZE, NULL,
+					tag_length)) {
+		close(sk);
+		return -1;
+	}
+
 	ret =3D accept4(sk, NULL, 0, SOCK_CLOEXEC);
 	close(sk);
 =

@@ -151,11 +164,55 @@ LIB_EXPORT struct l_cipher *l_cipher_new(enum l_ciphe=
r_type type,
 		break;
 	}
 =

-	cipher->encrypt_sk =3D create_alg("skcipher", alg_name, key, key_length);
+	cipher->encrypt_sk =3D create_alg("skcipher", alg_name, key, key_length,
+					0);
+	if (cipher->encrypt_sk < 0)
+		goto error_free;
+
+	cipher->decrypt_sk =3D create_alg("skcipher", alg_name, key, key_length,
+					0);
+	if (cipher->decrypt_sk < 0)
+		goto error_close;
+
+	return cipher;
+
+error_close:
+	close(cipher->encrypt_sk);
+error_free:
+	l_free(cipher);
+	return NULL;
+}
+
+LIB_EXPORT struct l_aead_cipher *l_aead_cipher_new(enum l_aead_cipher_type=
 type,
+							const void *key,
+							size_t key_length,
+							size_t tag_length)
+{
+	struct l_aead_cipher *cipher;
+	const char *alg_name;
+
+	if (unlikely(!key))
+		return NULL;
+
+	if (type !=3D L_AEAD_CIPHER_AES_CCM)
+		return NULL;
+
+	cipher =3D l_new(struct l_aead_cipher, 1);
+	cipher->type =3D type;
+
+	switch (type) {
+	case L_AEAD_CIPHER_AES_CCM:
+		alg_name =3D "ccm(aes)";
+		break;
+	}
+
+	cipher->encrypt_sk =3D create_alg("aead", alg_name, key, key_length,
+					tag_length);
 	if (cipher->encrypt_sk < 0)
 		goto error_free;
 =

-	cipher->decrypt_sk =3D create_alg("skcipher", alg_name, key, key_length);
+	cipher->decrypt_sk =3D create_alg("aead", alg_name, key, key_length,
+					tag_length);
 	if (cipher->decrypt_sk < 0)
 		goto error_close;
 =

@@ -179,21 +236,61 @@ LIB_EXPORT void l_cipher_free(struct l_cipher *cipher)
 	l_free(cipher);
 }
 =

+LIB_EXPORT void l_aead_cipher_free(struct l_aead_cipher *cipher)
+{
+	if (unlikely(!cipher))
+		return;
+
+	close(cipher->encrypt_sk);
+	close(cipher->decrypt_sk);
+
+	l_free(cipher);
+}
+
+static ssize_t build_iv(const void *nonce, uint8_t nonce_len, uint8_t *iv,
+			uint8_t iv_len)
+{
+	const size_t iv_overhead =3D 2;
+
+	if (nonce_len + iv_overhead > iv_len)
+		return -EINVAL;
+
+	iv[0] =3D iv_len - iv_overhead - nonce_len;
+	memcpy(iv + 1, nonce, nonce_len);
+
+	/* Assumes that remaining bytes in iv were already zeroed out */
+
+	return iv_len;
+}
+
 static ssize_t operate_cipher(int sk, __u32 operation,
-				const void *in, void *out, size_t len_in,
-				size_t len_out)
+				const void *in, size_t in_len,
+				const void *ad, size_t ad_len,
+				const void *nonce, size_t nonce_len,
+				void *out, size_t out_len,
+				size_t iv_len)
 {
-	char c_msg_buf[CMSG_SPACE(sizeof(operation))];
+	char *c_msg_buf;
+	size_t c_msg_size;
 	struct msghdr msg;
 	struct cmsghdr *c_msg;
-	struct iovec iov;
+	struct iovec iov[2];
 	ssize_t result;
 =

-	memset(&c_msg_buf, 0, sizeof(c_msg_buf));
+	c_msg_size =3D CMSG_SPACE(sizeof(operation));
+	c_msg_size +=3D ad_len ? CMSG_SPACE(sizeof(uint32_t)) : 0;
+	c_msg_size +=3D (nonce && iv_len) ?
+		CMSG_SPACE(sizeof(struct af_alg_iv) + iv_len) : 0;
+
+	c_msg_buf =3D alloca(c_msg_size);
+
+	memset(c_msg_buf, 0, c_msg_size);
 	memset(&msg, 0, sizeof(msg));
 =

+	msg.msg_iov =3D iov;
+
 	msg.msg_control =3D c_msg_buf;
-	msg.msg_controllen =3D sizeof(c_msg_buf);
+	msg.msg_controllen =3D c_msg_size;
 =

 	c_msg =3D CMSG_FIRSTHDR(&msg);
 	c_msg->cmsg_level =3D SOL_ALG;
@@ -201,17 +298,75 @@ static ssize_t operate_cipher(int sk, __u32 operation,
 	c_msg->cmsg_len =3D CMSG_LEN(sizeof(operation));
 	memcpy(CMSG_DATA(c_msg), &operation, sizeof(operation));
 =

-	iov.iov_base =3D (void *) in;
-	iov.iov_len =3D len_in;
+	if (ad_len) {
+		uint32_t *ad_data;
+
+		c_msg =3D CMSG_NXTHDR(&msg, c_msg);
+		c_msg->cmsg_level =3D SOL_ALG;
+		c_msg->cmsg_type =3D ALG_SET_AEAD_ASSOCLEN;
+		c_msg->cmsg_len =3D CMSG_LEN(sizeof(*ad_data));
+		ad_data =3D (void *) CMSG_DATA(c_msg);
+		*ad_data =3D ad_len;
+
+		iov[0].iov_base =3D (void *) ad;
+		iov[0].iov_len =3D ad_len;
+		iov[1].iov_base =3D (void *) in;
+		iov[1].iov_len =3D in_len;
+		msg.msg_iovlen =3D 2;
+	} else {
+		iov[0].iov_base =3D (void *) in;
+		iov[0].iov_len =3D in_len;
+		msg.msg_iovlen =3D 1;
+	}
+
+	if (nonce && iv_len) {
+		struct af_alg_iv *algiv;
+
+		c_msg =3D CMSG_NXTHDR(&msg, c_msg);
+		c_msg->cmsg_level =3D SOL_ALG;
+		c_msg->cmsg_type =3D ALG_SET_IV;
+		c_msg->cmsg_len =3D CMSG_LEN(sizeof(*algiv) + iv_len);
 =

-	msg.msg_iov =3D &iov;
-	msg.msg_iovlen =3D 1;
+		algiv =3D (void *)CMSG_DATA(c_msg);
+		algiv->ivlen =3D iv_len;
+		result =3D build_iv(nonce, nonce_len, &algiv->iv[0], iv_len);
+		if (result < 0)
+			return result;
+	}
 =

 	result =3D sendmsg(sk, &msg, 0);
 	if (result < 0)
 		return -errno;
 =

-	result =3D read(sk, out, len_out);
+	if (ad) {
+		/*
+		 * When AEAD additional data is passed to sendmsg() for
+		 * use in computing the tag, those bytes also appear at
+		 * the beginning of the encrypt or decrypt results.  Rather
+		 * than force the caller to pad their result buffer with
+		 * the correct number of bytes for the additional data,
+		 * the necessary space is allocated here and then the
+		 * duplicate AAD is discarded.
+		 */
+		iov[0].iov_base =3D l_malloc(ad_len);
+		iov[0].iov_len =3D ad_len;
+		iov[1].iov_base =3D (void *) out;
+		iov[1].iov_len =3D out_len;
+		msg.msg_iovlen =3D 2;
+
+		msg.msg_control =3D NULL;
+		msg.msg_controllen =3D 0;
+
+		result =3D recvmsg(sk, &msg, 0);
+
+		if (result > (ssize_t) ad_len)
+			result -=3D ad_len;
+
+		l_free(iov[0].iov_base);
+	} else {
+		result =3D read(sk, out, out_len);
+	}
+
 	if (result < 0)
 		return -errno;
 =

@@ -227,8 +382,8 @@ LIB_EXPORT bool l_cipher_encrypt(struct l_cipher *ciphe=
r,
 	if (unlikely(!in) || unlikely(!out))
 		return false;
 =

-	return operate_cipher(cipher->encrypt_sk, ALG_OP_ENCRYPT, in, out, len,
-				len) >=3D 0;
+	return operate_cipher(cipher->encrypt_sk, ALG_OP_ENCRYPT, in, len,
+				NULL, 0, NULL, 0, out, len, 0) >=3D 0;
 }
 =

 LIB_EXPORT bool l_cipher_decrypt(struct l_cipher *cipher,
@@ -240,8 +395,8 @@ LIB_EXPORT bool l_cipher_decrypt(struct l_cipher *ciphe=
r,
 	if (unlikely(!in) || unlikely(!out))
 		return false;
 =

-	return operate_cipher(cipher->decrypt_sk, ALG_OP_DECRYPT, in, out, len,
-				len) >=3D 0;
+	return operate_cipher(cipher->decrypt_sk, ALG_OP_DECRYPT, in, len,
+				NULL, 0, NULL, 0, out, len, 0) >=3D 0;
 }
 =

 LIB_EXPORT bool l_cipher_set_iv(struct l_cipher *cipher, const uint8_t *iv,
@@ -279,3 +434,50 @@ LIB_EXPORT bool l_cipher_set_iv(struct l_cipher *ciphe=
r, const uint8_t *iv,
 =

 	return true;
 }
+
+static size_t l_aead_cipher_get_ivlen(struct l_aead_cipher *cipher)
+{
+	size_t ret;
+
+	switch (cipher->type) {
+	case L_AEAD_CIPHER_AES_CCM:
+		ret =3D 16;
+		break;
+	}
+
+	return ret;
+}
+
+LIB_EXPORT bool l_aead_cipher_encrypt(struct l_aead_cipher *cipher,
+					const void *in, size_t in_len,
+					const void *ad, size_t ad_len,
+					const void *nonce, size_t nonce_len,
+					void *out, size_t out_len)
+{
+	if (unlikely(!cipher))
+		return false;
+
+	if (unlikely(!in) || unlikely(!out))
+		return false;
+
+	return operate_cipher(cipher->encrypt_sk, ALG_OP_ENCRYPT, in, in_len,
+				ad, ad_len, nonce, nonce_len, out, out_len,
+				l_aead_cipher_get_ivlen(cipher)) >=3D 0;
+}
+
+LIB_EXPORT bool l_aead_cipher_decrypt(struct l_aead_cipher *cipher,
+					const void *in, size_t in_len,
+					const void *ad, size_t ad_len,
+					const void *nonce, size_t nonce_len,
+					void *out, size_t out_len)
+{
+	if (unlikely(!cipher))
+		return false;
+
+	if (unlikely(!in) || unlikely(!out))
+		return false;
+
+	return operate_cipher(cipher->decrypt_sk, ALG_OP_DECRYPT, in, in_len,
+				ad, ad_len, nonce, nonce_len, out, out_len,
+				l_aead_cipher_get_ivlen(cipher)) >=3D 0;
+}
diff --git a/ell/cipher.h b/ell/cipher.h
index f9ff42f..29c9542 100644
--- a/ell/cipher.h
+++ b/ell/cipher.h
@@ -51,6 +51,30 @@ bool l_cipher_decrypt(struct l_cipher *cipher,
 bool l_cipher_set_iv(struct l_cipher *cipher, const uint8_t *iv,
 			size_t iv_length);
 =

+struct l_aead_cipher;
+
+enum l_aead_cipher_type {
+	L_AEAD_CIPHER_AES_CCM =3D 0,
+};
+
+struct l_aead_cipher *l_aead_cipher_new(enum l_aead_cipher_type type,
+					const void *key, size_t key_length,
+					size_t tag_length);
+
+void l_aead_cipher_free(struct l_aead_cipher *cipher);
+
+bool l_aead_cipher_encrypt(struct l_aead_cipher *cipher,
+				const void *in, size_t in_len,
+				const void *ad, size_t ad_len,
+				const void *nonce, size_t nonce_len,
+				void *out, size_t out_len);
+
+bool l_aead_cipher_decrypt(struct l_aead_cipher *cipher,
+				const void *in, size_t in_len,
+				const void *ad, size_t ad_len,
+				const void *nonce, size_t nonce_len,
+				void *out, size_t out_len);
+
 #ifdef __cplusplus
 }
 #endif
-- =

2.11.0


--===============7695389704731119643==--

