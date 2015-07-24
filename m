Content-Type: multipart/mixed; boundary="===============1384749077246066831=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 04/17] cipher: Add l_cipher_set_iv.
Date: Fri, 24 Jul 2015 05:26:45 +0200
Message-ID: <1437708410-28075-4-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1437708410-28075-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1384749077246066831==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This allows setting the IV on block ciphers for either the encryption
or decryption operations.  It will affect the outcome of any later
_encrypt or _decrypt calls.
---
 ell/cipher.c | 28 ++++++++++++++++++++++++++++
 ell/cipher.h |  3 +++
 2 files changed, 31 insertions(+)

diff --git a/ell/cipher.c b/ell/cipher.c
index b7577d5..3619f2c 100644
--- a/ell/cipher.c
+++ b/ell/cipher.c
@@ -228,3 +228,31 @@ LIB_EXPORT bool l_cipher_decrypt(struct l_cipher *ciph=
er,
 =

 	return operate_cipher(cipher->decrypt_sk, ALG_OP_DECRYPT, in, out, len);
 }
+
+LIB_EXPORT bool l_cipher_set_iv(struct l_cipher *cipher, const uint8_t *iv,
+					size_t iv_length, bool encrypt)
+{
+	char c_msg_buf[CMSG_SPACE(4 + iv_length)];
+	struct msghdr msg =3D {};
+	struct cmsghdr *c_msg;
+	uint32_t len =3D iv_length;
+
+	msg.msg_control =3D c_msg_buf;
+	msg.msg_controllen =3D sizeof(c_msg_buf);
+
+	c_msg =3D CMSG_FIRSTHDR(&msg);
+	c_msg->cmsg_level =3D SOL_ALG;
+	c_msg->cmsg_type =3D ALG_SET_IV;
+	c_msg->cmsg_len =3D CMSG_LEN(4 + iv_length);
+	memcpy(CMSG_DATA(c_msg) + 0, &len, 4);
+	memcpy(CMSG_DATA(c_msg) + 4, iv, iv_length);
+
+	msg.msg_iov =3D NULL;
+	msg.msg_iovlen =3D 0;
+
+	if (sendmsg(encrypt ? cipher->encrypt_sk : cipher->decrypt_sk,
+			&msg, 0) < 0)
+		return false;
+
+	return true;
+}
diff --git a/ell/cipher.h b/ell/cipher.h
index 8e91884..74b96a3 100644
--- a/ell/cipher.h
+++ b/ell/cipher.h
@@ -47,6 +47,9 @@ bool l_cipher_encrypt(struct l_cipher *cipher,
 bool l_cipher_decrypt(struct l_cipher *cipher,
 			const void *in, void *out, size_t len);
 =

+bool l_cipher_set_iv(struct l_cipher *cipher, const uint8_t *iv,
+			size_t iv_length, bool encrypt);
+
 #ifdef __cplusplus
 }
 #endif
-- =

2.1.4


--===============1384749077246066831==--

