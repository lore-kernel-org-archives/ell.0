Content-Type: multipart/mixed; boundary="===============2254236349094812199=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 02/10] cipher: Add DES-CBC cipher type
Date: Fri, 11 Aug 2017 01:10:08 +0200
Message-ID: <20170810231016.29445-2-andrew.zaborowski@intel.com>
In-Reply-To: <20170810231016.29445-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2254236349094812199==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/cipher.c | 2 ++
 ell/cipher.h | 1 +
 2 files changed, 3 insertions(+)

diff --git a/ell/cipher.c b/ell/cipher.c
index 8c9e1d0..e51f6e7 100644
--- a/ell/cipher.c
+++ b/ell/cipher.c
@@ -152,6 +152,8 @@ static const char *cipher_type_to_name(enum l_cipher_ty=
pe type)
 		return "ecb(arc4)";
 	case L_CIPHER_DES:
 		return "ecb(des)";
+	case L_CIPHER_DES_CBC:
+		return "cbc(des)";
 	case L_CIPHER_DES3_EDE_CBC:
 		return "cbc(des3_ede)";
 	}
diff --git a/ell/cipher.h b/ell/cipher.h
index 9297eeb..d787f33 100644
--- a/ell/cipher.h
+++ b/ell/cipher.h
@@ -34,6 +34,7 @@ enum l_cipher_type {
 	L_CIPHER_AES_CBC,
 	L_CIPHER_ARC4,
 	L_CIPHER_DES,
+	L_CIPHER_DES_CBC,
 	L_CIPHER_DES3_EDE_CBC,
 };
 =

-- =

2.11.0


--===============2254236349094812199==--

