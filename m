Content-Type: multipart/mixed; boundary="===============3374565697758166130=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 3/8] pem: Move PKCS private key parsing to cert.c
Date: Wed, 06 Jan 2021 20:54:41 +0100
Message-ID: <20210106195446.1428769-3-andrew.zaborowski@intel.com>
In-Reply-To: <20210106195446.1428769-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3374565697758166130==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This code implements the parsing and building of ASN.1 structures
defined in PKCS and RFCs that say nothing about encoding them as PEM, in
fact the PKCS#8 private key structures are also used in binary file
formats.  The legacy encrypted PKCS#1 RSAPrivateKey format is probably
only used in PEM files since it depends on the non-standard PEM headers,
so leave the decoding in pem.c.
---
 ell/cert-private.h |   8 +++
 ell/cert.c         | 163 +++++++++++++++++++++++++++++++++++++++++++++
 ell/pem-private.h  |   7 --
 ell/pem.c          | 160 +-------------------------------------------
 4 files changed, 174 insertions(+), 164 deletions(-)

diff --git a/ell/cert-private.h b/ell/cert-private.h
index 929f88d..e792c4c 100644
--- a/ell/cert-private.h
+++ b/ell/cert-private.h
@@ -28,3 +28,11 @@ void certchain_link_issuer(struct l_certchain *chain, st=
ruct l_cert *ca);
 const uint8_t *cert_get_extension(struct l_cert *cert,
 					const struct asn1_oid *ext_id,
 					bool *out_critical, size_t *out_len);
+
+struct l_key *cert_key_from_pkcs8_private_key_info(const uint8_t *der,
+							size_t der_len);
+struct l_key *cert_key_from_pkcs8_encrypted_private_key_info(const uint8_t=
 *der,
+							size_t der_len,
+							const char *passphrase);
+struct l_key *cert_key_from_pkcs1_rsa_private_key(const uint8_t *der,
+							size_t der_len);
diff --git a/ell/cert.c b/ell/cert.c
index cfe9a8d..a102fcc 100644
--- a/ell/cert.c
+++ b/ell/cert.c
@@ -29,6 +29,9 @@
 #include "key.h"
 #include "queue.h"
 #include "asn1-private.h"
+#include "cipher.h"
+#include "pkcs5.h"
+#include "pkcs5-private.h"
 #include "cert.h"
 #include "cert-private.h"
 =

@@ -576,3 +579,163 @@ LIB_EXPORT bool l_certchain_verify(struct l_certchain=
 *chain,
 	l_key_free(prev_key);
 	return true;
 }
+
+struct l_key *cert_key_from_pkcs8_private_key_info(const uint8_t *der,
+							size_t der_len)
+{
+	return l_key_new(L_KEY_RSA, der, der_len);
+}
+
+struct l_key *cert_key_from_pkcs8_encrypted_private_key_info(const uint8_t=
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
+	bool is_block;
+	size_t decrypted_len;
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
+	alg =3D pkcs5_cipher_from_alg_id(alg_id, alg_id_len, passphrase,
+					&is_block);
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
+	decrypted_len =3D data_len;
+
+	if (is_block) {
+		/*
+		 * For block ciphers strip padding as defined in RFC8018
+		 * (for PKCS#5 v1) or RFC1423 / RFC5652 (for v2).
+		 */
+		pkey =3D NULL;
+
+		if (decrypted[data_len - 1] >=3D data_len ||
+				decrypted[data_len - 1] > 16)
+			goto cleanup;
+
+		for (i =3D 1; i < decrypted[data_len - 1]; i++)
+			if (decrypted[data_len - 1 - i] !=3D
+					decrypted[data_len - 1])
+				goto cleanup;
+
+		decrypted_len -=3D decrypted[data_len - 1];
+	}
+
+	pkey =3D cert_key_from_pkcs8_private_key_info(decrypted, decrypted_len);
+
+cleanup:
+	explicit_bzero(decrypted, data_len);
+	l_free(decrypted);
+	return pkey;
+}
+
+struct l_key *cert_key_from_pkcs1_rsa_private_key(const uint8_t *der,
+							size_t der_len)
+{
+	const uint8_t *data;
+	uint8_t tag;
+	size_t data_len;
+	const uint8_t *key_data;
+	size_t key_data_len;
+	int i;
+	uint8_t *private_key;
+	size_t private_key_len;
+	uint8_t *one_asymmetric_key;
+	uint8_t *ptr;
+	struct l_key *pkey;
+
+	static const uint8_t version0[] =3D {
+		ASN1_ID_INTEGER, 0x01, 0x00
+	};
+	static const uint8_t pkcs1_rsa_encryption[] =3D {
+		ASN1_ID_SEQUENCE, 0x0d,
+		ASN1_ID_OID, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d,
+		0x01, 0x01, 0x01,
+		ASN1_ID_NULL, 0x00,
+	};
+
+	/*
+	 * Sanity check that it's a version 0 or 1 RSAPrivateKey structure
+	 * with the 8 integers.
+	 */
+	key_data =3D asn1_der_find_elem(der, der_len, 0, &tag, &key_data_len);
+	if (!key_data || tag !=3D ASN1_ID_SEQUENCE)
+		return NULL;
+
+	data =3D asn1_der_find_elem(key_data, key_data_len, 0, &tag,
+					&data_len);
+	if (!data || tag !=3D ASN1_ID_INTEGER || data_len !=3D 1 ||
+			(data[0] !=3D 0x00 && data[0] !=3D 0x01))
+		return NULL;
+
+	for (i =3D 1; i < 9; i++) {
+		data =3D asn1_der_find_elem(key_data, key_data_len, i, &tag,
+						&data_len);
+		if (!data || tag !=3D ASN1_ID_INTEGER || data_len < 1)
+			return NULL;
+	}
+
+	private_key =3D l_malloc(10 + der_len);
+	ptr =3D private_key;
+	*ptr++ =3D ASN1_ID_OCTET_STRING;
+	asn1_write_definite_length(&ptr, der_len);
+	memcpy(ptr, der, der_len);
+	ptr +=3D der_len;
+	private_key_len =3D ptr - private_key;
+
+	one_asymmetric_key =3D l_malloc(32 + private_key_len);
+	ptr =3D one_asymmetric_key;
+	*ptr++ =3D ASN1_ID_SEQUENCE;
+	asn1_write_definite_length(&ptr, sizeof(version0) +
+					sizeof(pkcs1_rsa_encryption) +
+					private_key_len);
+	memcpy(ptr, version0, sizeof(version0));
+	ptr +=3D sizeof(version0);
+	memcpy(ptr, pkcs1_rsa_encryption, sizeof(pkcs1_rsa_encryption));
+	ptr +=3D sizeof(pkcs1_rsa_encryption);
+	memcpy(ptr, private_key, private_key_len);
+	ptr +=3D private_key_len;
+	explicit_bzero(private_key, private_key_len);
+	l_free(private_key);
+
+	pkey =3D cert_key_from_pkcs8_private_key_info(one_asymmetric_key,
+						ptr - one_asymmetric_key);
+	explicit_bzero(one_asymmetric_key, ptr - one_asymmetric_key);
+	l_free(one_asymmetric_key);
+
+	return pkey;
+}
diff --git a/ell/pem-private.h b/ell/pem-private.h
index 10f918f..68e3fcb 100644
--- a/ell/pem-private.h
+++ b/ell/pem-private.h
@@ -33,12 +33,5 @@ const char *pem_next(const void *buf, size_t buf_len, ch=
ar **type_label,
 				size_t *base64_len,
 				const char **endp, bool strict);
 =

-struct l_key *pem_key_from_pkcs8_private_key_info(const uint8_t *der,
-							size_t der_len);
-
-struct l_key *pem_key_from_pkcs8_encrypted_private_key_info(const uint8_t =
*der,
-							size_t der_len,
-							const char *passphrase);
-
 int pem_write_certificate_chain(const struct l_certchain *cert,
 				const char *filename);
diff --git a/ell/pem.c b/ell/pem.c
index fd25016..384fb9f 100644
--- a/ell/pem.c
+++ b/ell/pem.c
@@ -41,7 +41,6 @@
 #include "base64.h"
 #include "utf8.h"
 #include "asn1-private.h"
-#include "pkcs5-private.h"
 #include "cipher.h"
 #include "cert-private.h"
 #include "missing.h"
@@ -646,89 +645,6 @@ cleanup:
 	return cipher;
 }
 =

-struct l_key *pem_key_from_pkcs8_private_key_info(const uint8_t *der,
-							size_t der_len)
-{
-	return l_key_new(L_KEY_RSA, der, der_len);
-}
-
-struct l_key *pem_key_from_pkcs8_encrypted_private_key_info(const uint8_t =
*der,
-							size_t der_len,
-							const char *passphrase)
-{
-	const uint8_t *key_info, *alg_id, *data;
-	uint8_t tag;
-	size_t key_info_len, alg_id_len, data_len, tmp_len;
-	struct l_cipher *alg;
-	uint8_t *decrypted;
-	int i;
-	struct l_key *pkey;
-	bool r;
-	bool is_block;
-	size_t decrypted_len;
-
-	/* Technically this is BER, not limited to DER */
-	key_info =3D asn1_der_find_elem(der, der_len, 0, &tag, &key_info_len);
-	if (!key_info || tag !=3D ASN1_ID_SEQUENCE)
-		return NULL;
-
-	alg_id =3D asn1_der_find_elem(key_info, key_info_len, 0, &tag,
-					&alg_id_len);
-	if (!alg_id || tag !=3D ASN1_ID_SEQUENCE)
-		return NULL;
-
-	data =3D asn1_der_find_elem(key_info, key_info_len, 1, &tag, &data_len);
-	if (!data || tag !=3D ASN1_ID_OCTET_STRING || data_len < 8 ||
-			(data_len & 7) !=3D 0)
-		return NULL;
-
-	if (asn1_der_find_elem(der, der_len, 2, &tag, &tmp_len))
-		return NULL;
-
-	alg =3D pkcs5_cipher_from_alg_id(alg_id, alg_id_len, passphrase,
-					&is_block);
-	if (!alg)
-		return NULL;
-
-	decrypted =3D l_malloc(data_len);
-
-	r =3D l_cipher_decrypt(alg, data, decrypted, data_len);
-	l_cipher_free(alg);
-
-	if (!r) {
-		l_free(decrypted);
-		return NULL;
-	}
-
-	decrypted_len =3D data_len;
-
-	if (is_block) {
-		/*
-		 * For block ciphers strip padding as defined in RFC8018
-		 * (for PKCS#5 v1) or RFC1423 / RFC5652 (for v2).
-		 */
-		pkey =3D NULL;
-
-		if (decrypted[data_len - 1] >=3D data_len ||
-				decrypted[data_len - 1] > 16)
-			goto cleanup;
-
-		for (i =3D 1; i < decrypted[data_len - 1]; i++)
-			if (decrypted[data_len - 1 - i] !=3D
-					decrypted[data_len - 1])
-				goto cleanup;
-
-		decrypted_len -=3D decrypted[data_len - 1];
-	}
-
-	pkey =3D pem_key_from_pkcs8_private_key_info(decrypted, decrypted_len);
-
-cleanup:
-	explicit_bzero(decrypted, data_len);
-	l_free(decrypted);
-	return pkey;
-}
-
 static struct l_key *pem_load_private_key(uint8_t *content,
 						size_t len,
 						char *label,
@@ -749,7 +665,7 @@ static struct l_key *pem_load_private_key(uint8_t *cont=
ent,
 		if (headers)
 			goto err;
 =

-		pkey =3D pem_key_from_pkcs8_private_key_info(content, len);
+		pkey =3D cert_key_from_pkcs8_private_key_info(content, len);
 		goto done;
 	}
 =

@@ -771,7 +687,7 @@ static struct l_key *pem_load_private_key(uint8_t *cont=
ent,
 		if (headers)
 			goto err;
 =

-		pkey =3D pem_key_from_pkcs8_encrypted_private_key_info(content,
+		pkey =3D cert_key_from_pkcs8_encrypted_private_key_info(content,
 								len,
 								passphrase);
 		goto done;
@@ -784,29 +700,9 @@ static struct l_key *pem_load_private_key(uint8_t *con=
tent,
 	 * PrivateKeyInfo for the pkcs8-key-parser module.
 	 */
 	if (!strcmp(label, "RSA PRIVATE KEY")) {
-		const uint8_t *data;
-		uint8_t tag;
-		size_t data_len;
-		const uint8_t *key_data;
-		size_t key_data_len;
-		int i;
-		uint8_t *private_key;
-		size_t private_key_len;
-		uint8_t *one_asymmetric_key;
-		uint8_t *ptr;
 		const char *dekalgid;
 		const char *dekparameters;
 =

-		static const uint8_t version0[] =3D {
-			ASN1_ID_INTEGER, 0x01, 0x00
-		};
-		static const uint8_t pkcs1_rsa_encryption[] =3D {
-			ASN1_ID_SEQUENCE, 0x0d,
-			ASN1_ID_OID, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d,
-			0x01, 0x01, 0x01,
-			ASN1_ID_NULL, 0x00,
-		};
-
 		/*
 		 * "openssl rsa ..." can produce encrypted PKCS#1-formatted
 		 * keys.  These are incompatible with RFC7468 parsing because
@@ -855,57 +751,7 @@ static struct l_key *pem_load_private_key(uint8_t *con=
tent,
 			len -=3D content[len - 1];
 		}
 =

-		/*
-		 * Sanity check that it's a version 0 or 1 RSAPrivateKey
-		 * structure with the 8 integers, if it's not, make a last
-		 * ditch attempt to load it into the kernel directly.
-		 */
-		key_data =3D asn1_der_find_elem(content, len, 0, &tag,
-						&key_data_len);
-		if (!key_data || tag !=3D ASN1_ID_SEQUENCE)
-			goto err;
-
-		data =3D asn1_der_find_elem(key_data, key_data_len, 0, &tag,
-						&data_len);
-		if (!data || tag !=3D ASN1_ID_INTEGER || data_len !=3D 1 ||
-				(data[0] !=3D 0x00 && data[0] !=3D 0x01))
-			goto err;
-
-		for (i =3D 1; i < 9; i++) {
-			data =3D asn1_der_find_elem(key_data, key_data_len,
-							i, &tag, &data_len);
-			if (!data || tag !=3D ASN1_ID_INTEGER || data_len < 1)
-				goto err;
-		}
-
-		private_key =3D l_malloc(10 + len);
-		ptr =3D private_key;
-		*ptr++ =3D ASN1_ID_OCTET_STRING;
-		asn1_write_definite_length(&ptr, len);
-		memcpy(ptr, content, len);
-		ptr +=3D len;
-		private_key_len =3D ptr - private_key;
-
-		one_asymmetric_key =3D l_malloc(32 + private_key_len);
-		ptr =3D one_asymmetric_key;
-		*ptr++ =3D ASN1_ID_SEQUENCE;
-		asn1_write_definite_length(&ptr,
-						sizeof(version0) +
-						sizeof(pkcs1_rsa_encryption) +
-						private_key_len);
-		memcpy(ptr, version0, sizeof(version0));
-		ptr +=3D sizeof(version0);
-		memcpy(ptr, pkcs1_rsa_encryption, sizeof(pkcs1_rsa_encryption));
-		ptr +=3D sizeof(pkcs1_rsa_encryption);
-		memcpy(ptr, private_key, private_key_len);
-		ptr +=3D private_key_len;
-		explicit_bzero(private_key, private_key_len);
-		l_free(private_key);
-
-		pkey =3D pem_key_from_pkcs8_private_key_info(one_asymmetric_key,
-						ptr - one_asymmetric_key);
-		explicit_bzero(one_asymmetric_key, ptr - one_asymmetric_key);
-		l_free(one_asymmetric_key);
+		pkey =3D cert_key_from_pkcs1_rsa_private_key(content, len);
 		goto done;
 	}
 =

-- =

2.27.0

--===============3374565697758166130==--

