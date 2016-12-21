Content-Type: multipart/mixed; boundary="===============8662108541777182205=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 1/3] cipher: Remove more public key vestiges from cipher
 internals
Date: Tue, 20 Dec 2016 17:40:33 -0800
Message-ID: <20161221014035.22874-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8662108541777182205==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/cipher.c | 23 ++++-------------------
 1 file changed, 4 insertions(+), 19 deletions(-)

diff --git a/ell/cipher.c b/ell/cipher.c
index 139331e..ac5248a 100644
--- a/ell/cipher.c
+++ b/ell/cipher.c
@@ -77,17 +77,6 @@ struct af_alg_iv {
 #define SOL_ALG 279
 #endif
 =

-#ifndef ALG_OP_SIGN
-#define ALG_OP_SIGN	2
-#endif
-#ifndef ALG_OP_VERIFY
-#define ALG_OP_VERIFY	3
-#endif
-
-#ifndef ALG_SET_PUBKEY
-#define ALG_SET_PUBKEY	6
-#endif
-
 #define is_valid_type(type)  ((type) <=3D L_CIPHER_DES3_EDE_CBC)
 =

 struct l_cipher {
@@ -97,11 +86,10 @@ struct l_cipher {
 };
 =

 static int create_alg(const char *alg_type, const char *alg_name,
-			const void *key, size_t key_length, bool public)
+			const void *key, size_t key_length)
 {
 	struct sockaddr_alg salg;
 	int sk;
-	int keyopt;
 	int ret;
 =

 	sk =3D socket(PF_ALG, SOCK_SEQPACKET | SOCK_CLOEXEC, 0);
@@ -118,8 +106,7 @@ static int create_alg(const char *alg_type, const char =
*alg_name,
 		return -1;
 	}
 =

-	keyopt =3D public ? ALG_SET_PUBKEY : ALG_SET_KEY;
-	if (setsockopt(sk, SOL_ALG, keyopt, key, key_length) < 0) {
+	if (setsockopt(sk, SOL_ALG, ALG_SET_KEY, key, key_length) < 0) {
 		close(sk);
 		return -1;
 	}
@@ -164,13 +151,11 @@ LIB_EXPORT struct l_cipher *l_cipher_new(enum l_ciphe=
r_type type,
 		break;
 	}
 =

-	cipher->encrypt_sk =3D create_alg("skcipher", alg_name, key, key_length,
-					false);
+	cipher->encrypt_sk =3D create_alg("skcipher", alg_name, key, key_length);
 	if (cipher->encrypt_sk < 0)
 		goto error_free;
 =

-	cipher->decrypt_sk =3D create_alg("skcipher", alg_name, key, key_length,
-					false);
+	cipher->decrypt_sk =3D create_alg("skcipher", alg_name, key, key_length);
 	if (cipher->decrypt_sk < 0)
 		goto error_close;
 =

-- =

2.11.0


--===============8662108541777182205==--

