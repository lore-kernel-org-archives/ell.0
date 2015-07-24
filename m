Content-Type: multipart/mixed; boundary="===============5529390680954412283=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 03/17] cipher: Add 3DES EDE and AES CBC-mode cipher types.
Date: Fri, 24 Jul 2015 05:26:44 +0200
Message-ID: <1437708410-28075-3-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1437708410-28075-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5529390680954412283==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This again only adds the definitions needed to use the kernel
implementations, no real code here.
---
 ell/cipher.c | 8 +++++++-
 ell/cipher.h | 2 ++
 2 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/ell/cipher.c b/ell/cipher.c
index 2c4fd90..b7577d5 100644
--- a/ell/cipher.c
+++ b/ell/cipher.c
@@ -76,7 +76,7 @@ struct af_alg_iv {
 #define SOL_ALG 279
 #endif
 =

-#define is_valid_type(type)  ((type) <=3D L_CIPHER_ARC4)
+#define is_valid_type(type)  ((type) <=3D L_CIPHER_DES3_EDE_CBC)
 =

 struct l_cipher {
 	enum l_cipher_type type;
@@ -103,9 +103,15 @@ static int create_alg(enum l_cipher_type type,
 	case L_CIPHER_AES:
 		strcpy((char *) salg.salg_name, "ecb(aes)");
 		break;
+	case L_CIPHER_AES_CBC:
+		strcpy((char *) salg.salg_name, "cbc(aes)");
+		break;
 	case L_CIPHER_ARC4:
 		strcpy((char *) salg.salg_name, "ecb(arc4)");
 		break;
+	case L_CIPHER_DES3_EDE_CBC:
+		strcpy((char *) salg.salg_name, "cbc(des3_ede)");
+		break;
 	}
 =

 	if (bind(sk, (struct sockaddr *) &salg, sizeof(salg)) < 0) {
diff --git a/ell/cipher.h b/ell/cipher.h
index efa1ad2..8e91884 100644
--- a/ell/cipher.h
+++ b/ell/cipher.h
@@ -31,7 +31,9 @@ struct l_cipher;
 =

 enum l_cipher_type {
 	L_CIPHER_AES =3D 0,
+	L_CIPHER_AES_CBC,
 	L_CIPHER_ARC4,
+	L_CIPHER_DES3_EDE_CBC,
 };
 =

 struct l_cipher *l_cipher_new(enum l_cipher_type type,
-- =

2.1.4


--===============5529390680954412283==--

