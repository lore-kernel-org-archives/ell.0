Content-Type: multipart/mixed; boundary="===============4817086378648074922=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 07/13] pkcs5: Add PKCS#12 algorithms in
 pkcs5_cipher_from_alg_id
Date: Thu, 10 Dec 2020 20:32:00 +0100
Message-ID: <20201210193202.526451-7-andrew.zaborowski@intel.com>
In-Reply-To: <20201210193202.526451-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4817086378648074922==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Since pkcs5_cipher_from_alg_id() is used for decrypting PKCS#8 private
keys, teach it to also parse PKCS#12 AlgorithmIdentifier asn1 syntax
(almost identical to PKCS#5).  Ideally the pkcs5_* functions and pkcs5.c
should be renamed to not include the PKCS#5 string because the callers
are probably not interested in what cipher is used as long as they can
use it to decrypt data their input.  So ideally they want to call
one function that understands all the common algorithm OIDs.
---
 ell/pkcs5.c | 172 +++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 169 insertions(+), 3 deletions(-)

diff --git a/ell/pkcs5.c b/ell/pkcs5.c
index bb02c33..ea0fcc5 100644
--- a/ell/pkcs5.c
+++ b/ell/pkcs5.c
@@ -352,6 +352,74 @@ static const struct pkcs5_pbes1_encryption_oid {
 	/* MD2- and RC2-based schemes 1, 4, 6 and 11 not supported */
 };
 =

+/* RFC7292 Appendix C */
+static const struct pkcs12_encryption_oid {
+	enum l_cipher_type cipher_type;
+	unsigned int key_length;
+	unsigned int iv_length;
+	bool copy_k1;	/* Expand the 2-Key 3DES key for 3-Key 3DES */
+	bool is_block;
+	struct asn1_oid oid;
+} pkcs12_encryption_oids[] =3D {
+	{ /* pbeWithSHAAnd128BitRC4 */
+		.cipher_type =3D L_CIPHER_ARC4,
+		.key_length =3D 16,
+		.oid =3D { 10, {
+			0x2a, 0x86, 0x48, 0x86, 0xf7,
+			0x0d, 0x01, 0x0c, 0x01, 0x01,
+		} }
+	},
+	{ /* pbeWithSHAAnd40BitRC4 */
+		.cipher_type =3D L_CIPHER_ARC4,
+		.key_length =3D 5,
+		.oid =3D { 10, {
+			0x2a, 0x86, 0x48, 0x86, 0xf7,
+			0x0d, 0x01, 0x0c, 0x01, 0x02,
+		} }
+	},
+	{ /* pbeWithSHAAnd3-KeyTripleDES-CBC */
+		.cipher_type =3D L_CIPHER_DES3_EDE_CBC,
+		.key_length =3D 24,
+		.iv_length =3D 8,
+		.is_block =3D true,
+		.oid =3D { 10, {
+			0x2a, 0x86, 0x48, 0x86, 0xf7,
+			0x0d, 0x01, 0x0c, 0x01, 0x03,
+		} }
+	},
+	{ /* pbeWithSHAAnd2-KeyTripleDES-CBC */
+		.cipher_type =3D L_CIPHER_DES3_EDE_CBC,
+		.key_length =3D 16,
+		.iv_length =3D 8,
+		.copy_k1 =3D true,
+		.is_block =3D true,
+		.oid =3D { 10, {
+			0x2a, 0x86, 0x48, 0x86, 0xf7,
+			0x0d, 0x01, 0x0c, 0x01, 0x04,
+		} }
+	},
+	{ /* pbeWithSHAAnd128BitRC2-CBC */
+		.cipher_type =3D L_CIPHER_RC2_CBC,
+		.key_length =3D 16,
+		.iv_length =3D 8,
+		.is_block =3D true,
+		.oid =3D { 10, {
+			0x2a, 0x86, 0x48, 0x86, 0xf7,
+			0x0d, 0x01, 0x0c, 0x01, 0x05,
+		} }
+	},
+	{ /* pbeWithSHAAnd40BitRC2-CBC */
+		.cipher_type =3D L_CIPHER_RC2_CBC,
+		.key_length =3D 5,
+		.iv_length =3D 8,
+		.is_block =3D true,
+		.oid =3D { 10, {
+			0x2a, 0x86, 0x48, 0x86, 0xf7,
+			0x0d, 0x01, 0x0c, 0x01, 0x06,
+		} }
+	},
+};
+
 static const struct pkcs5_digest_alg_oid {
 	enum l_checksum_type type;
 	struct asn1_oid oid;
@@ -528,8 +596,8 @@ static struct l_cipher *pkcs5_cipher_from_pbes2_params(
 	/* RFC8018 section B.2 */
 =

 	/*
-	 * Since we don't support RC2/RC5, all our PKCS#5 ciphers only
-	 * have an obligatory OCTET STRING IV parameter and a fixed key
+	 * Since we don't support the RC2/RC5 PBES2 ciphers, our parameters
+	 * only have an obligatory OCTET STRING IV parameter and a fixed key
 	 * length.
 	 */
 	if (tag !=3D ASN1_ID_OCTET_STRING || params_len !=3D enc_scheme->iv_size)
@@ -559,6 +627,94 @@ static struct l_cipher *pkcs5_cipher_from_pbes2_params(
 	return cipher;
 }
 =

+static struct l_cipher *pkcs12_cipher_from_alg_id(
+				const struct pkcs12_encryption_oid *scheme,
+				const uint8_t *params, size_t params_len,
+				const char *password, bool *out_is_block)
+{
+	uint8_t tag;
+	const uint8_t *salt;
+	const uint8_t *iterations_data;
+	size_t salt_len;
+	size_t iterations_len;
+	unsigned int iterations;
+	uint8_t *key;
+	size_t key_len;
+	struct l_cipher *cipher;
+
+	/* Same parameters as in PKCS#5 */
+	salt =3D asn1_der_find_elem(params, params_len, 0, &tag, &salt_len);
+	if (!salt || tag !=3D ASN1_ID_OCTET_STRING)
+		return NULL;
+
+	iterations_data =3D asn1_der_find_elem(params, params_len, 1,
+						&tag, &iterations_len);
+	if (!iterations_data || tag !=3D ASN1_ID_INTEGER ||
+			iterations_len < 1 || iterations_len > 4)
+		return NULL;
+
+	for (iterations =3D 0; iterations_len; iterations_len--)
+		iterations =3D (iterations << 8) | *iterations_data++;
+
+	if (iterations < 1 || iterations > 8192)
+		return NULL;
+
+	if (iterations_data !=3D params + params_len)
+		return NULL;
+
+	key_len =3D scheme->key_length;
+	key =3D pkcs12_pbkdf(password, &pkcs12_sha1_hash, salt, salt_len,
+				iterations, 1, key_len);
+	if (!key)
+		return NULL;
+
+	if (scheme->copy_k1) {
+		/*
+		 * 2-Key 3DES is like L_CIPHER_DES3_EDE_CBC except the last
+		 * of the 3 8-byte keys is not generated using a KDF and
+		 * instead is a copy of the first key.  In other words
+		 * the first half of the 16-byte key material is appended
+		 * at the end to produce the 24 bytes for DES3_EDE_CBC.
+		 */
+		uint8_t *key2 =3D l_malloc(24);
+
+		memcpy(key2, key, 16);
+		memcpy(key2 + 16, key, 8);
+		explicit_bzero(key, key_len);
+		l_free(key);
+		key =3D key2;
+		key_len =3D 24;
+	}
+
+	cipher =3D l_cipher_new(scheme->cipher_type, key, key_len);
+	explicit_bzero(key, key_len);
+	l_free(key);
+
+	if (!cipher)
+		return NULL;
+
+	if (scheme->iv_length) {
+		uint8_t *iv =3D pkcs12_pbkdf(password, &pkcs12_sha1_hash,
+						salt, salt_len, iterations, 2,
+						scheme->iv_length);
+
+		if (!iv || !l_cipher_set_iv(cipher, iv, scheme->iv_length)) {
+			l_cipher_free(cipher);
+			cipher =3D NULL;
+		}
+
+		if (iv)
+			explicit_bzero(iv, scheme->iv_length);
+
+		l_free(iv);
+	}
+
+	if (out_is_block)
+		*out_is_block =3D scheme->is_block;
+
+	return cipher;
+}
+
 struct l_cipher *pkcs5_cipher_from_alg_id(const uint8_t *id_asn1,
 						size_t id_asn1_len,
 						const char *password,
@@ -601,8 +757,18 @@ struct l_cipher *pkcs5_cipher_from_alg_id(const uint8_=
t *id_asn1,
 		}
 	}
 =

-	if (!pbes1_scheme)
+	/* Check if this is a PKCS#12 OID */
+	if (!pbes1_scheme) {
+		for (i =3D 0; i < L_ARRAY_SIZE(pkcs12_encryption_oids); i++)
+			if (asn1_oid_eq(&pkcs12_encryption_oids[i].oid,
+					oid_len, oid))
+				return pkcs12_cipher_from_alg_id(
+						&pkcs12_encryption_oids[i],
+						params, params_len, password,
+						out_is_block);
+
 		return NULL;
+	}
 =

 	salt =3D asn1_der_find_elem(params, params_len, 0, &tag, &tmp_len);
 	if (!salt || tag !=3D ASN1_ID_OCTET_STRING || tmp_len !=3D 8)
-- =

2.27.0

--===============4817086378648074922==--

