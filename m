Content-Type: multipart/mixed; boundary="===============6619702724905560711=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 07/10] cipher: Add l_cipher_from_pkcs5_id
Date: Fri, 11 Aug 2017 01:10:13 +0200
Message-ID: <20170810231016.29445-7-andrew.zaborowski@intel.com>
In-Reply-To: <20170810231016.29445-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6619702724905560711==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add a utility to parse all of the PKCS#5 DER-encoded encryption scheme
information, use the right PBKDF function to calculate the key,
create the appropriate l_cipher object type (if we support that PKCS#5
cipher type) with that key and set the IV on the l_cipher object.

We don't support any of the RC2 or RC5 based encryption schemes or
those that use MD2, SHA512-224 or SHA512-256 for the hash, because
there's no kernel support for those algorithms.  OpenSSL can create
RSA private keys encrypted with some of these algorithms but MD5+DES
and DES3-EDE are the default and the popular algorithms.  OpenSSL also
supports camellia ciphers in those scenarios which we could add.

Note that the caller still needs to add or remove the padding from the
data encrypted or decrypted with the l_cipher object so technically this
doesn't implement 100% of PKCS#5 PBES1 or PBES2.
Thise code may be better moved to a separate file from cipher.c.  If we
do that then it could be wrapped in a separate object that would do the
padding after calling the l_cipher operation, too, though the padding
is really simple anway, may not be worth the overhead of another wrapper.
---
 ell/cipher.c | 290 +++++++++++++++++++++++++++++++++++++++++++++++++++++++=
++++
 ell/cipher.h |   4 +
 2 files changed, 294 insertions(+)

diff --git a/ell/cipher.c b/ell/cipher.c
index 8e60d61..f9efd2b 100644
--- a/ell/cipher.c
+++ b/ell/cipher.c
@@ -34,6 +34,7 @@
 #include "cipher.h"
 #include "private.h"
 #include "random.h"
+#include "asn1-private.h"
 #include "checksum.h"
 =

 #ifndef HAVE_LINUX_IF_ALG_H
@@ -759,3 +760,292 @@ static bool pkcs5_pbkdf2(enum l_checksum_type type, c=
onst char *password,
 =

 	return !dk_len;
 }
+
+static struct asn1_oid pkcs5_pbkdf2_oid =3D {
+	9, { 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x05, 0x0c }
+};
+
+static struct asn1_oid pkcs5_pbes2_oid =3D {
+	9, { 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x05, 0x0d }
+};
+
+static const struct pkcs5_pbes1_encryption_oid {
+	enum l_checksum_type checksum_type;
+	enum l_cipher_type cipher_type;
+	struct asn1_oid oid;
+} pkcs5_pbes1_encryption_oids[] =3D {
+	{ /* pbeWithMD5AndDES-CBC */
+		L_CHECKSUM_MD5, L_CIPHER_DES_CBC,
+		{ 9, { 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x05, 0x03 } },
+	},
+	{ /* pbeWithSHA1AndDES-CBC */
+		L_CHECKSUM_SHA1, L_CIPHER_DES_CBC,
+		{ 9, { 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x05, 0x0a } },
+	},
+	/* MD2- and RC2-based schemes 1, 4, 6 and 11 not supported */
+};
+
+static const struct pkcs5_digest_alg_oid {
+	enum l_checksum_type type;
+	struct asn1_oid oid;
+} pkcs5_digest_alg_oids[] =3D {
+	{ /* hmacWithSHA1 */
+		L_CHECKSUM_SHA1,
+		{ 8, { 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x02, 0x07 } },
+	},
+	{ /* hmacWithSHA224 */
+		L_CHECKSUM_SHA224,
+		{ 8, { 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x02, 0x08 } },
+	},
+	{ /* hmacWithSHA256 */
+		L_CHECKSUM_SHA256,
+		{ 8, { 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x02, 0x09 } },
+	},
+	{ /* hmacWithSHA384 */
+		L_CHECKSUM_SHA384,
+		{ 8, { 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x02, 0x0a } },
+	},
+	{ /* hmacWithSHA512 */
+		L_CHECKSUM_SHA512,
+		{ 8, { 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x02, 0x0b } },
+	},
+	/* hmacWithSHA512-224 and hmacWithSHA512-256 not supported */
+};
+
+static const struct pkcs5_enc_alg_oid {
+	enum l_cipher_type cipher_type;
+	uint8_t key_size, iv_size;
+	struct asn1_oid oid;
+} pkcs5_enc_alg_oids[] =3D {
+	{ /* desCBC */
+		L_CIPHER_DES_CBC, 8, 8,
+		{ 5, { 0x2b, 0x0e, 0x03, 0x02, 0x07 } },
+	},
+	{ /* des-EDE3-CBC */
+		L_CIPHER_DES3_EDE_CBC, 24, 8,
+		{ 8, { 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x03, 0x07 } },
+	},
+	/* RC2/RC5-based schemes 2 and 9 not supported */
+	{ /* aes128-CBC-PAD */
+		L_CIPHER_AES_CBC, 16, 16,
+		{ 9, { 0x60, 0x86, 0x48, 0x01, 0x65, 0x03, 0x04, 0x01, 0x02 } },
+	},
+	{ /* aes192-CBC-PAD */
+		L_CIPHER_AES_CBC, 24, 16,
+		{ 9, { 0x60, 0x86, 0x48, 0x01, 0x65, 0x03, 0x04, 0x01, 0x16 } },
+	},
+	{ /* aes256-CBC-PAD */
+		L_CIPHER_AES_CBC, 32, 16,
+		{ 9, { 0x60, 0x86, 0x48, 0x01, 0x65, 0x03, 0x04, 0x01, 0x2a } },
+	},
+};
+
+static struct l_cipher *cipher_from_pkcs5_pbes2_params(
+						const uint8_t *pbes2_params,
+						size_t pbes2_params_len,
+						const char *password)
+{
+	uint8_t tag;
+	const uint8_t *kdf_sequence, *enc_sequence, *oid, *params,
+		*salt, *iter_count_buf, *key_len_buf, *prf_sequence;
+	size_t kdf_len, enc_len, params_len, salt_len, key_len, tmp_len;
+	unsigned int i, iter_count;
+	enum l_checksum_type prf_alg =3D L_CHECKSUM_NONE;
+	const struct pkcs5_enc_alg_oid *enc_scheme =3D NULL;
+	uint8_t derived_key[64];
+	struct l_cipher *cipher;
+
+	/* RFC8018 section A.4 */
+
+	kdf_sequence =3D der_find_elem(pbes2_params, pbes2_params_len, 0,
+					&tag, &kdf_len);
+	if (!kdf_sequence || tag !=3D ASN1_ID_SEQUENCE)
+		return NULL;
+
+	enc_sequence =3D der_find_elem(pbes2_params, pbes2_params_len, 1,
+					&tag, &enc_len);
+	if (!enc_sequence || tag !=3D ASN1_ID_SEQUENCE)
+		return NULL;
+
+	if (der_find_elem(pbes2_params, pbes2_params_len, 2, &tag, &tmp_len))
+		return NULL;
+
+	/* RFC8018 section A.2 */
+
+	oid =3D der_find_elem(kdf_sequence, kdf_len, 0, &tag, &tmp_len);
+	if (!oid || tag !=3D ASN1_ID_OID)
+		return NULL;
+
+	if (!asn1_oid_eq(&pkcs5_pbkdf2_oid, tmp_len, oid))
+		return NULL;
+
+	params =3D der_find_elem(kdf_sequence, kdf_len, 1, &tag, &params_len);
+	if (!params || tag !=3D ASN1_ID_SEQUENCE)
+		return NULL;
+
+	if (der_find_elem(kdf_sequence, kdf_len, 2, &tag, &tmp_len))
+		return NULL;
+
+	salt =3D der_find_elem(params, params_len, 0, &tag, &salt_len);
+	if (!salt || tag !=3D ASN1_ID_OCTET_STRING ||
+			salt_len < 1 || salt_len > 512)
+		return NULL;
+
+	iter_count_buf =3D der_find_elem(params, params_len, 1, &tag, &tmp_len);
+	if (!iter_count_buf || tag !=3D ASN1_ID_INTEGER ||
+			tmp_len < 1 || tmp_len > 4)
+		return NULL;
+
+	iter_count =3D 0;
+	while (tmp_len--)
+		iter_count =3D (iter_count << 8) | *iter_count_buf++;
+
+	key_len_buf =3D der_find_elem(params, params_len, 2, &tag, &tmp_len);
+	if (key_len_buf) {
+		if (tag !=3D ASN1_ID_INTEGER || tmp_len !=3D 1)
+			return NULL;
+
+		key_len =3D 0;
+		while (tmp_len--)
+			key_len =3D (key_len << 8) | *key_len_buf++;
+	} else
+		key_len =3D 0;
+
+	prf_sequence =3D der_find_elem(params, params_len, 3, &tag, &tmp_len);
+	if (prf_sequence) {
+		if (tag !=3D ASN1_ID_SEQUENCE)
+			return NULL;
+
+		oid =3D der_find_elem(prf_sequence, tmp_len, 0, &tag, &tmp_len);
+		if (!oid || tag !=3D ASN1_ID_OID)
+			return NULL;
+
+		for (i =3D 0; i < L_ARRAY_SIZE(pkcs5_digest_alg_oids); i++)
+			if (!asn1_oid_eq(&pkcs5_digest_alg_oids[i].oid,
+						tmp_len, oid))
+				prf_alg =3D pkcs5_digest_alg_oids[i].type;
+		if (prf_alg =3D=3D L_CHECKSUM_NONE)
+			return NULL;
+	} else
+		prf_alg =3D L_CHECKSUM_SHA1;
+
+	oid =3D der_find_elem(enc_sequence, enc_len, 0, &tag, &tmp_len);
+	if (!oid || tag !=3D ASN1_ID_OID)
+		return NULL;
+
+	for (i =3D 0; i < L_ARRAY_SIZE(pkcs5_enc_alg_oids); i++)
+		if (asn1_oid_eq(&pkcs5_enc_alg_oids[i].oid, tmp_len, oid)) {
+			enc_scheme =3D &pkcs5_enc_alg_oids[i];
+			break;
+		}
+	if (!enc_scheme)
+		return NULL;
+
+	params =3D der_find_elem(enc_sequence, enc_len, 1, &tag, &params_len);
+	if (!params)
+		return NULL;
+
+	/* RFC8018 section B.2 */
+
+	/*
+	 * Since we don't support RC2/RC5, all our PKCS#5 ciphers only
+	 * have an obligatory OCTET STRING IV parameter and a fixed key
+	 * length.
+	 */
+	if (tag !=3D ASN1_ID_OCTET_STRING || params_len !=3D enc_scheme->iv_size)
+		return NULL;
+
+	if (key_len && enc_scheme->key_size !=3D key_len)
+		return NULL;
+	key_len =3D enc_scheme->key_size;
+
+	if (der_find_elem(enc_sequence, enc_len, 2, &tag, &tmp_len))
+		return NULL;
+
+	/* RFC8018 section 6.2 */
+
+	if (!pkcs5_pbkdf2(prf_alg, password, salt, salt_len, iter_count,
+				key_len, derived_key))
+		return NULL;
+
+	cipher =3D l_cipher_new(enc_scheme->cipher_type, derived_key, key_len);
+	if (!cipher)
+		return NULL;
+
+	if (l_cipher_set_iv(cipher, params, enc_scheme->iv_size))
+		return cipher;
+
+	l_cipher_free(cipher);
+	return NULL;
+}
+
+LIB_EXPORT struct l_cipher *l_cipher_from_pkcs5_id(const uint8_t *id_asn1,
+							size_t id_asn1_len,
+							const char *password)
+{
+	uint8_t tag;
+	const uint8_t *oid, *params, *salt, *iter_count_buf;
+	size_t oid_len, params_len, tmp_len;
+	unsigned int i, iter_count;
+	const struct pkcs5_pbes1_encryption_oid *pbes1_scheme =3D NULL;
+	uint8_t derived_key[16];
+	struct l_cipher *cipher;
+
+	oid =3D der_find_elem(id_asn1, id_asn1_len, 0, &tag, &oid_len);
+	if (!oid || tag !=3D ASN1_ID_OID)
+		return NULL;
+
+	params =3D der_find_elem(id_asn1, id_asn1_len, 1, &tag, &params_len);
+	if (!params || tag !=3D ASN1_ID_SEQUENCE)
+		return NULL;
+
+	if (der_find_elem(id_asn1, id_asn1_len, 2, &tag, &tmp_len))
+		return NULL;
+
+	if (asn1_oid_eq(&pkcs5_pbes2_oid, oid_len, oid))
+		return cipher_from_pkcs5_pbes2_params(params, params_len,
+							password);
+
+	/* RFC8018 section A.3 */
+
+	for (i =3D 0; i < L_ARRAY_SIZE(pkcs5_pbes1_encryption_oids); i++)
+		if (asn1_oid_eq(&pkcs5_pbes1_encryption_oids[i].oid,
+					oid_len, oid)) {
+			pbes1_scheme =3D &pkcs5_pbes1_encryption_oids[i];
+			break;
+		}
+	if (!pbes1_scheme)
+		return NULL;
+
+	salt =3D der_find_elem(params, params_len, 0, &tag, &tmp_len);
+	if (!salt || tag !=3D ASN1_ID_OCTET_STRING || tmp_len !=3D 8)
+		return NULL;
+
+	iter_count_buf =3D der_find_elem(params, params_len, 1, &tag, &tmp_len);
+	if (!iter_count_buf || tag !=3D ASN1_ID_INTEGER ||
+			tmp_len < 1 || tmp_len > 4)
+		return NULL;
+
+	iter_count =3D 0;
+	while (tmp_len--)
+		iter_count =3D (iter_count << 8) | *iter_count_buf++;
+
+	if (der_find_elem(params, params_len, 2, &tag, &tmp_len))
+		return NULL;
+
+	/* RFC8018 section 6.1 */
+
+	if (!pkcs5_pbkdf1(pbes1_scheme->checksum_type,
+				password, salt, 8, iter_count, 16, derived_key))
+		return NULL;
+
+	cipher =3D l_cipher_new(pbes1_scheme->cipher_type, derived_key + 0, 8);
+	if (!cipher)
+		return NULL;
+
+	if (l_cipher_set_iv(cipher, derived_key + 8, 8))
+		return cipher;
+
+	l_cipher_free(cipher);
+	return NULL;
+}
diff --git a/ell/cipher.h b/ell/cipher.h
index d787f33..3c79aee 100644
--- a/ell/cipher.h
+++ b/ell/cipher.h
@@ -41,6 +41,10 @@ enum l_cipher_type {
 struct l_cipher *l_cipher_new(enum l_cipher_type type,
 				const void *key, size_t key_length);
 =

+struct l_cipher *l_cipher_from_pkcs5_id(const uint8_t *id_asn1,
+					size_t id_asn1_len,
+					const char *password);
+
 void l_cipher_free(struct l_cipher *cipher);
 =

 bool l_cipher_encrypt(struct l_cipher *cipher,
-- =

2.11.0


--===============6619702724905560711==--

