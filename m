Content-Type: multipart/mixed; boundary="===============8420947715047428434=="
MIME-Version: 1.0
From: James Prestwood <james.prestwood@linux.intel.com>
Subject: [PATCH 1/2] cipher: add AES-CTR
Date: Tue, 16 Apr 2019 10:46:41 -0700
Message-ID: <20190416174642.16264-1-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8420947715047428434==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The kernel already supports this with ctr(aes), so adding a new cipher
type was all that was needed.
---
 ell/cipher.c | 2 ++
 ell/cipher.h | 1 +
 2 files changed, 3 insertions(+)

diff --git a/ell/cipher.c b/ell/cipher.c
index 977ebc8..7b909df 100644
--- a/ell/cipher.c
+++ b/ell/cipher.c
@@ -148,6 +148,8 @@ static const char *cipher_type_to_name(enum l_cipher_ty=
pe type)
 		return "ecb(aes)";
 	case L_CIPHER_AES_CBC:
 		return "cbc(aes)";
+	case L_CIPHER_AES_CTR:
+		return "ctr(aes)";
 	case L_CIPHER_ARC4:
 		return "ecb(arc4)";
 	case L_CIPHER_DES:
diff --git a/ell/cipher.h b/ell/cipher.h
index 946b9ad..84f2988 100644
--- a/ell/cipher.h
+++ b/ell/cipher.h
@@ -32,6 +32,7 @@ struct l_cipher;
 enum l_cipher_type {
 	L_CIPHER_AES =3D 0,
 	L_CIPHER_AES_CBC,
+	L_CIPHER_AES_CTR,
 	L_CIPHER_ARC4,
 	L_CIPHER_DES,
 	L_CIPHER_DES_CBC,
-- =

2.17.1


--===============8420947715047428434==--

