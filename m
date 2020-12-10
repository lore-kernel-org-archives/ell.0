Content-Type: multipart/mixed; boundary="===============4626582317810382630=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 02/13] pem: Factor out the PKCS#8 decoding code
Date: Thu, 10 Dec 2020 20:31:55 +0100
Message-ID: <20201210193202.526451-2-andrew.zaborowski@intel.com>
In-Reply-To: <20201210193202.526451-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4626582317810382630==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/pem-private.h |   7 ++
 ell/pem.c         | 167 ++++++++++++++++++++++++----------------------
 2 files changed, 96 insertions(+), 78 deletions(-)

diff --git a/ell/pem-private.h b/ell/pem-private.h
index 1cf7ee5..6e9458d 100644
--- a/ell/pem-private.h
+++ b/ell/pem-private.h
@@ -30,3 +30,10 @@
 const char *pem_next(const void *buf, size_t buf_len, char **type_label,
 				size_t *base64_len,
 				const char **endp, bool strict);
+
+struct l_key *pem_key_from_pkcs8_private_key_info(const uint8_t *der,
+							size_t der_len);
+
+struct l_key *pem_key_from_pkcs8_encrypted_private_key_info(const uint8_t =
*der,
+							size_t der_len,
+							const char *passphrase);
diff --git a/ell/pem.c b/ell/pem.c
index 70d1f62..42c7975 100644
--- a/ell/pem.c
+++ b/ell/pem.c
@@ -601,6 +601,79 @@ cleanup:
 	return cipher;
 }
 =

+struct l_key *pem_key_from_pkcs8_private_key_info(const uint8_t *der,
+							size_t der_len)
+{
+	return l_key_new(L_KEY_RSA, der, der_len);
+}
+
+struct l_key *pem_key_from_pkcs8_encrypted_private_key_info(const uint8_t =
*der,
+							size_t der_len,
+							const char *passphrase)
+{
+	const uint8_t *key_info, *alg_id, *data;
+	uint8_t tag;
+	size_t key_info_len, alg_id_len, data_len, tmp_len;
+	struct l_cipher *alg;
+	uint8_t *decrypted;
+	int i;
+	struct l_key *pkey;
+	bool r;
+
+	/* Technically this is BER, not limited to DER */
+	key_info =3D asn1_der_find_elem(der, der_len, 0, &tag, &key_info_len);
+	if (!key_info || tag !=3D ASN1_ID_SEQUENCE)
+		return NULL;
+
+	alg_id =3D asn1_der_find_elem(key_info, key_info_len, 0, &tag,
+					&alg_id_len);
+	if (!alg_id || tag !=3D ASN1_ID_SEQUENCE)
+		return NULL;
+
+	data =3D asn1_der_find_elem(key_info, key_info_len, 1, &tag, &data_len);
+	if (!data || tag !=3D ASN1_ID_OCTET_STRING || data_len < 8 ||
+			(data_len & 7) !=3D 0)
+		return NULL;
+
+	if (asn1_der_find_elem(der, der_len, 2, &tag, &tmp_len))
+		return NULL;
+
+	alg =3D pkcs5_cipher_from_alg_id(alg_id, alg_id_len, passphrase);
+	if (!alg)
+		return NULL;
+
+	decrypted =3D l_malloc(data_len);
+
+	r =3D l_cipher_decrypt(alg, data, decrypted, data_len);
+	l_cipher_free(alg);
+
+	if (!r) {
+		l_free(decrypted);
+		return NULL;
+	}
+
+	/*
+	 * Strip padding as defined in RFC8018 (for PKCS#5 v1) or
+	 * RFC1423 / RFC5652 (for v2).
+	 */
+	pkey =3D NULL;
+	if (decrypted[data_len - 1] >=3D data_len ||
+			decrypted[data_len - 1] > 16)
+		goto cleanup;
+
+	for (i =3D 1; i < decrypted[data_len - 1]; i++)
+		if (decrypted[data_len - 1 - i] !=3D decrypted[data_len - 1])
+			goto cleanup;
+
+	pkey =3D pem_key_from_pkcs8_private_key_info(decrypted,
+					data_len - decrypted[data_len - 1]);
+
+cleanup:
+	explicit_bzero(decrypted, data_len);
+	l_free(decrypted);
+	return pkey;
+}
+
 static struct l_key *pem_load_private_key(uint8_t *content,
 						size_t len,
 						char *label,
@@ -608,7 +681,7 @@ static struct l_key *pem_load_private_key(uint8_t *cont=
ent,
 						char *headers,
 						bool *encrypted)
 {
-	struct l_key *pkey =3D NULL;
+	struct l_key *pkey;
 =

 	/*
 	 * RFC7468 Section 10-compatible unencrypted private key label
@@ -621,6 +694,7 @@ static struct l_key *pem_load_private_key(uint8_t *cont=
ent,
 		if (headers)
 			goto err;
 =

+		pkey =3D pem_key_from_pkcs8_private_key_info(content, len);
 		goto done;
 	}
 =

@@ -632,13 +706,6 @@ static struct l_key *pem_load_private_key(uint8_t *con=
tent,
 	 * pkcs8-key-parser module.
 	 */
 	if (!strcmp(label, "ENCRYPTED PRIVATE KEY")) {
-		const uint8_t *key_info, *alg_id, *data;
-		uint8_t tag;
-		size_t key_info_len, alg_id_len, data_len, tmp_len;
-		struct l_cipher *alg;
-		uint8_t *decrypted;
-		int i;
-
 		if (encrypted)
 			*encrypted =3D true;
 =

@@ -649,59 +716,9 @@ static struct l_key *pem_load_private_key(uint8_t *con=
tent,
 		if (headers)
 			goto err;
 =

-		/* Technically this is BER, not limited to DER */
-		key_info =3D asn1_der_find_elem(content, len, 0, &tag,
-						&key_info_len);
-		if (!key_info || tag !=3D ASN1_ID_SEQUENCE)
-			goto err;
-
-		alg_id =3D asn1_der_find_elem(key_info, key_info_len, 0, &tag,
-						&alg_id_len);
-		if (!alg_id || tag !=3D ASN1_ID_SEQUENCE)
-			goto err;
-
-		data =3D asn1_der_find_elem(key_info, key_info_len, 1, &tag,
-						&data_len);
-		if (!data || tag !=3D ASN1_ID_OCTET_STRING || data_len < 8 ||
-				(data_len & 7) !=3D 0)
-			goto err;
-
-		if (asn1_der_find_elem(content, len, 2, &tag, &tmp_len))
-			goto err;
-
-		alg =3D pkcs5_cipher_from_alg_id(alg_id, alg_id_len, passphrase);
-		if (!alg)
-			goto err;
-
-		decrypted =3D l_malloc(data_len);
-
-		if (!l_cipher_decrypt(alg, data, decrypted, data_len)) {
-			l_cipher_free(alg);
-			l_free(decrypted);
-			goto err;
-		}
-
-		l_cipher_free(alg);
-		explicit_bzero(content, len);
-		l_free(content);
-		content =3D decrypted;
-		len =3D data_len;
-
-		/*
-		 * Strip padding as defined in RFC8018 (for PKCS#5 v1) or
-		 * RFC1423 / RFC5652 (for v2).
-		 */
-
-		if (content[data_len - 1] >=3D data_len ||
-				content[data_len - 1] > 16)
-			goto err;
-
-		for (i =3D 1; i < content[data_len - 1]; i++)
-			if (content[data_len - 1 - i] !=3D content[data_len - 1])
-				goto err;
-
-		len =3D data_len - content[data_len - 1];
-
+		pkey =3D pem_key_from_pkcs8_encrypted_private_key_info(content,
+								len,
+								passphrase);
 		goto done;
 	}
 =

@@ -791,19 +808,19 @@ static struct l_key *pem_load_private_key(uint8_t *co=
ntent,
 		key_data =3D asn1_der_find_elem(content, len, 0, &tag,
 						&key_data_len);
 		if (!key_data || tag !=3D ASN1_ID_SEQUENCE)
-			goto done;
+			goto err;
 =

 		data =3D asn1_der_find_elem(key_data, key_data_len, 0, &tag,
 						&data_len);
 		if (!data || tag !=3D ASN1_ID_INTEGER || data_len !=3D 1 ||
 				(data[0] !=3D 0x00 && data[0] !=3D 0x01))
-			goto done;
+			goto err;
 =

 		for (i =3D 1; i < 9; i++) {
 			data =3D asn1_der_find_elem(key_data, key_data_len,
 							i, &tag, &data_len);
 			if (!data || tag !=3D ASN1_ID_INTEGER || data_len < 1)
-				goto done;
+				goto err;
 		}
 =

 		private_key =3D l_malloc(10 + len);
@@ -830,25 +847,19 @@ static struct l_key *pem_load_private_key(uint8_t *co=
ntent,
 		explicit_bzero(private_key, private_key_len);
 		l_free(private_key);
 =

-		explicit_bzero(content, len);
-		l_free(content);
-		content =3D one_asymmetric_key;
-		len =3D ptr - one_asymmetric_key;
+		pkey =3D pem_key_from_pkcs8_private_key_info(one_asymmetric_key,
+						ptr - one_asymmetric_key);
+		explicit_bzero(one_asymmetric_key, ptr - one_asymmetric_key);
+		l_free(one_asymmetric_key);
 		goto done;
 	}
 =

 	/* Label not known */
-	goto err;
-
-done:
-	pkey =3D l_key_new(L_KEY_RSA, content, len);
-
 err:
-	if (content) {
-		explicit_bzero(content, len);
-		l_free(content);
-	}
-
+	pkey =3D NULL;
+done:
+	explicit_bzero(content, len);
+	l_free(content);
 	l_free(label);
 	l_free(headers);
 	return pkey;
-- =

2.27.0

--===============4626582317810382630==--

