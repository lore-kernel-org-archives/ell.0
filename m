Content-Type: multipart/mixed; boundary="===============2634522223543596641=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 05/13] pem: Don't expect padding with stream ciphers
Date: Thu, 10 Dec 2020 20:31:58 +0100
Message-ID: <20201210193202.526451-5-andrew.zaborowski@intel.com>
In-Reply-To: <20201210193202.526451-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2634522223543596641==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

When decoding PKCS#8 encrypted certificates don't try to strip padding
when the encryption uses a stream cipher (RC4).  Standalone PKCS#8 files
encrypted with PKCS#12 ciphers are not common (that I know of..) but
they can be found embedded in PKCS#12 files.
---
 ell/pem.c           | 36 +++++++++++++++++++++++-------------
 ell/pkcs5-private.h |  3 ++-
 ell/pkcs5.c         | 13 +++++++++++--
 3 files changed, 36 insertions(+), 16 deletions(-)

diff --git a/ell/pem.c b/ell/pem.c
index 42c7975..1b995d5 100644
--- a/ell/pem.c
+++ b/ell/pem.c
@@ -619,6 +619,8 @@ struct l_key *pem_key_from_pkcs8_encrypted_private_key_=
info(const uint8_t *der,
 	int i;
 	struct l_key *pkey;
 	bool r;
+	bool is_block;
+	size_t decrypted_len;
 =

 	/* Technically this is BER, not limited to DER */
 	key_info =3D asn1_der_find_elem(der, der_len, 0, &tag, &key_info_len);
@@ -638,7 +640,8 @@ struct l_key *pem_key_from_pkcs8_encrypted_private_key_=
info(const uint8_t *der,
 	if (asn1_der_find_elem(der, der_len, 2, &tag, &tmp_len))
 		return NULL;
 =

-	alg =3D pkcs5_cipher_from_alg_id(alg_id, alg_id_len, passphrase);
+	alg =3D pkcs5_cipher_from_alg_id(alg_id, alg_id_len, passphrase,
+					&is_block);
 	if (!alg)
 		return NULL;
 =

@@ -652,21 +655,28 @@ struct l_key *pem_key_from_pkcs8_encrypted_private_ke=
y_info(const uint8_t *der,
 		return NULL;
 	}
 =

-	/*
-	 * Strip padding as defined in RFC8018 (for PKCS#5 v1) or
-	 * RFC1423 / RFC5652 (for v2).
-	 */
-	pkey =3D NULL;
-	if (decrypted[data_len - 1] >=3D data_len ||
-			decrypted[data_len - 1] > 16)
-		goto cleanup;
+	decrypted_len =3D data_len;
+
+	if (is_block) {
+		/*
+		 * For block ciphers strip padding as defined in RFC8018
+		 * (for PKCS#5 v1) or RFC1423 / RFC5652 (for v2).
+		 */
+		pkey =3D NULL;
 =

-	for (i =3D 1; i < decrypted[data_len - 1]; i++)
-		if (decrypted[data_len - 1 - i] !=3D decrypted[data_len - 1])
+		if (decrypted[data_len - 1] >=3D data_len ||
+				decrypted[data_len - 1] > 16)
 			goto cleanup;
 =

-	pkey =3D pem_key_from_pkcs8_private_key_info(decrypted,
-					data_len - decrypted[data_len - 1]);
+		for (i =3D 1; i < decrypted[data_len - 1]; i++)
+			if (decrypted[data_len - 1 - i] !=3D
+					decrypted[data_len - 1])
+				goto cleanup;
+
+		decrypted_len -=3D decrypted[data_len - 1];
+	}
+
+	pkey =3D pem_key_from_pkcs8_private_key_info(decrypted, decrypted_len);
 =

 cleanup:
 	explicit_bzero(decrypted, data_len);
diff --git a/ell/pkcs5-private.h b/ell/pkcs5-private.h
index f4f41f5..27ff41c 100644
--- a/ell/pkcs5-private.h
+++ b/ell/pkcs5-private.h
@@ -22,4 +22,5 @@
 =

 struct l_cipher *pkcs5_cipher_from_alg_id(const uint8_t *id_asn1,
 						size_t id_asn1_len,
-						const char *password);
+						const char *password,
+						bool *out_is_block);
diff --git a/ell/pkcs5.c b/ell/pkcs5.c
index f225c71..21fda2b 100644
--- a/ell/pkcs5.c
+++ b/ell/pkcs5.c
@@ -415,7 +415,8 @@ static struct l_cipher *pkcs5_cipher_from_pbes2_params(
 =

 struct l_cipher *pkcs5_cipher_from_alg_id(const uint8_t *id_asn1,
 						size_t id_asn1_len,
-						const char *password)
+						const char *password,
+						bool *out_is_block)
 {
 	uint8_t tag;
 	const uint8_t *oid, *params, *salt, *iter_count_buf;
@@ -436,9 +437,13 @@ struct l_cipher *pkcs5_cipher_from_alg_id(const uint8_=
t *id_asn1,
 	if (asn1_der_find_elem(id_asn1, id_asn1_len, 2, &tag, &tmp_len))
 		return NULL;
 =

-	if (asn1_oid_eq(&pkcs5_pbes2_oid, oid_len, oid))
+	if (asn1_oid_eq(&pkcs5_pbes2_oid, oid_len, oid)) {
+		if (out_is_block)
+			*out_is_block =3D true;
+
 		return pkcs5_cipher_from_pbes2_params(params, params_len,
 							password);
+	}
 =

 	/* RFC8018 section A.3 */
 =

@@ -484,5 +489,9 @@ struct l_cipher *pkcs5_cipher_from_alg_id(const uint8_t=
 *id_asn1,
 	}
 =

 	explicit_bzero(derived_key, 16);
+
+	if (out_is_block)
+		*out_is_block =3D true;
+
 	return cipher;
 }
-- =

2.27.0

--===============2634522223543596641==--

