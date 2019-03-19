Content-Type: multipart/mixed; boundary="===============1563212044839589038=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/4] pkcs5: Memzero copies of secrets
Date: Tue, 19 Mar 2019 01:48:41 +0100
Message-ID: <20190319004843.13451-2-andrew.zaborowski@intel.com>
In-Reply-To: <20190319004843.13451-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1563212044839589038==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Those functions are used, among others, for decrypting private keys and
are passed the private key passphrases so make sure those are being
cleared.
---
 ell/pkcs5.c | 34 ++++++++++++++++------------------
 1 file changed, 16 insertions(+), 18 deletions(-)

diff --git a/ell/pkcs5.c b/ell/pkcs5.c
index 9fac479..bd7db90 100644
--- a/ell/pkcs5.c
+++ b/ell/pkcs5.c
@@ -89,11 +89,11 @@ LIB_EXPORT bool l_pkcs5_pbkdf1(enum l_checksum_type typ=
e, const char *password,
 =

 	l_checksum_free(checksum);
 =

-	if (iter_count)
-		return false;
+	if (!iter_count)
+		memcpy(out_dk, t, dk_len);
 =

-	memcpy(out_dk, t, dk_len);
-	return true;
+	explicit_bzero(t, sizeof(t));
+	return !iter_count;
 }
 =

 /* RFC8018 section 5.2 */
@@ -399,14 +399,13 @@ static struct l_cipher *pkcs5_cipher_from_pbes2_param=
s(
 		return NULL;
 =

 	cipher =3D l_cipher_new(enc_scheme->cipher_type, derived_key, key_len);
-	if (!cipher)
-		return NULL;
-
-	if (l_cipher_set_iv(cipher, params, enc_scheme->iv_size))
-		return cipher;
+	if (cipher && !l_cipher_set_iv(cipher, params, enc_scheme->iv_size)) {
+		l_cipher_free(cipher);
+		cipher =3D NULL;
+	}
 =

-	l_cipher_free(cipher);
-	return NULL;
+	explicit_bzero(derived_key, 16);
+	return cipher;
 }
 =

 struct l_cipher *pkcs5_cipher_from_alg_id(const uint8_t *id_asn1,
@@ -474,12 +473,11 @@ struct l_cipher *pkcs5_cipher_from_alg_id(const uint8=
_t *id_asn1,
 		return NULL;
 =

 	cipher =3D l_cipher_new(pbes1_scheme->cipher_type, derived_key + 0, 8);
-	if (!cipher)
-		return NULL;
-
-	if (l_cipher_set_iv(cipher, derived_key + 8, 8))
-		return cipher;
+	if (cipher && !l_cipher_set_iv(cipher, derived_key + 8, 8)) {
+		l_cipher_free(cipher);
+		cipher =3D NULL;
+	}
 =

-	l_cipher_free(cipher);
-	return NULL;
+	explicit_bzero(derived_key, 16);
+	return cipher;
 }
-- =

2.19.1


--===============1563212044839589038==--

