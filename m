Content-Type: multipart/mixed; boundary="===============1739890920861649589=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 07/10] cipher: Add l_cipher_from_pkcs5_id
Date: Fri, 11 Aug 2017 11:55:18 -0500
Message-ID: <83284742-6c95-af79-80cc-12e3bec8a77f@gmail.com>
In-Reply-To: <20170810231016.29445-7-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1739890920861649589==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 08/10/2017 06:10 PM, Andrew Zaborowski wrote:
> Add a utility to parse all of the PKCS#5 DER-encoded encryption scheme
> information, use the right PBKDF function to calculate the key,
> create the appropriate l_cipher object type (if we support that PKCS#5
> cipher type) with that key and set the IV on the l_cipher object.
> =

> We don't support any of the RC2 or RC5 based encryption schemes or
> those that use MD2, SHA512-224 or SHA512-256 for the hash, because
> there's no kernel support for those algorithms.  OpenSSL can create
> RSA private keys encrypted with some of these algorithms but MD5+DES
> and DES3-EDE are the default and the popular algorithms.  OpenSSL also
> supports camellia ciphers in those scenarios which we could add.
> =

> Note that the caller still needs to add or remove the padding from the
> data encrypted or decrypted with the l_cipher object so technically this
> doesn't implement 100% of PKCS#5 PBES1 or PBES2.
> Thise code may be better moved to a separate file from cipher.c.  If we
> do that then it could be wrapped in a separate object that would do the
> padding after calling the l_cipher operation, too, though the padding
> is really simple anway, may not be worth the overhead of another wrapper.

Another reason to move this is that I don't really want to expose it in =

l_cipher.  The right way for us to enable encrypted certificates is via =

the keyctl API.  Until then, we should stuff this into some private =

file.  Can we put this into asn1-private.[ch]?

> ---
>   ell/cipher.c | 290 ++++++++++++++++++++++++++++++++++++++++++++++++++++=
+++++++
>   ell/cipher.h |   4 +
>   2 files changed, 294 insertions(+)
> =


<snip>

> +static struct l_cipher *cipher_from_pkcs5_pbes2_params(
> +						const uint8_t *pbes2_params,
> +						size_t pbes2_params_len,
> +						const char *password)
> +{
> +	uint8_t tag;
> +	const uint8_t *kdf_sequence, *enc_sequence, *oid, *params,
> +		*salt, *iter_count_buf, *key_len_buf, *prf_sequence;
> +	size_t kdf_len, enc_len, params_len, salt_len, key_len, tmp_len;
> +	unsigned int i, iter_count;
> +	enum l_checksum_type prf_alg =3D L_CHECKSUM_NONE;
> +	const struct pkcs5_enc_alg_oid *enc_scheme =3D NULL;
> +	uint8_t derived_key[64];
> +	struct l_cipher *cipher;
> +
> +	/* RFC8018 section A.4 */
> +
> +	kdf_sequence =3D der_find_elem(pbes2_params, pbes2_params_len, 0,
> +					&tag, &kdf_len);
> +	if (!kdf_sequence || tag !=3D ASN1_ID_SEQUENCE)
> +		return NULL;
> +
> +	enc_sequence =3D der_find_elem(pbes2_params, pbes2_params_len, 1,
> +					&tag, &enc_len);
> +	if (!enc_sequence || tag !=3D ASN1_ID_SEQUENCE)
> +		return NULL;
> +
> +	if (der_find_elem(pbes2_params, pbes2_params_len, 2, &tag, &tmp_len))
> +		return NULL;
> +
> +	/* RFC8018 section A.2 */
> +
> +	oid =3D der_find_elem(kdf_sequence, kdf_len, 0, &tag, &tmp_len);
> +	if (!oid || tag !=3D ASN1_ID_OID)
> +		return NULL;
> +
> +	if (!asn1_oid_eq(&pkcs5_pbkdf2_oid, tmp_len, oid))
> +		return NULL;
> +
> +	params =3D der_find_elem(kdf_sequence, kdf_len, 1, &tag, &params_len);
> +	if (!params || tag !=3D ASN1_ID_SEQUENCE)
> +		return NULL;
> +
> +	if (der_find_elem(kdf_sequence, kdf_len, 2, &tag, &tmp_len))
> +		return NULL;
> +
> +	salt =3D der_find_elem(params, params_len, 0, &tag, &salt_len);
> +	if (!salt || tag !=3D ASN1_ID_OCTET_STRING ||
> +			salt_len < 1 || salt_len > 512)
> +		return NULL;
> +
> +	iter_count_buf =3D der_find_elem(params, params_len, 1, &tag, &tmp_len);
> +	if (!iter_count_buf || tag !=3D ASN1_ID_INTEGER ||
> +			tmp_len < 1 || tmp_len > 4)
> +		return NULL;
> +
> +	iter_count =3D 0;
> +	while (tmp_len--)
> +		iter_count =3D (iter_count << 8) | *iter_count_buf++;
> +
> +	key_len_buf =3D der_find_elem(params, params_len, 2, &tag, &tmp_len);
> +	if (key_len_buf) {
> +		if (tag !=3D ASN1_ID_INTEGER || tmp_len !=3D 1)
> +			return NULL;
> +
> +		key_len =3D 0;
> +		while (tmp_len--)
> +			key_len =3D (key_len << 8) | *key_len_buf++;
> +	} else
> +		key_len =3D 0;
> +
> +	prf_sequence =3D der_find_elem(params, params_len, 3, &tag, &tmp_len);
> +	if (prf_sequence) {
> +		if (tag !=3D ASN1_ID_SEQUENCE)
> +			return NULL;
> +
> +		oid =3D der_find_elem(prf_sequence, tmp_len, 0, &tag, &tmp_len);
> +		if (!oid || tag !=3D ASN1_ID_OID)
> +			return NULL;
> +
> +		for (i =3D 0; i < L_ARRAY_SIZE(pkcs5_digest_alg_oids); i++)
> +			if (!asn1_oid_eq(&pkcs5_digest_alg_oids[i].oid,
> +						tmp_len, oid))
> +				prf_alg =3D pkcs5_digest_alg_oids[i].type;
> +		if (prf_alg =3D=3D L_CHECKSUM_NONE)
> +			return NULL;
> +	} else
> +		prf_alg =3D L_CHECKSUM_SHA1;
> +
> +	oid =3D der_find_elem(enc_sequence, enc_len, 0, &tag, &tmp_len);
> +	if (!oid || tag !=3D ASN1_ID_OID)
> +		return NULL;
> +
> +	for (i =3D 0; i < L_ARRAY_SIZE(pkcs5_enc_alg_oids); i++)
> +		if (asn1_oid_eq(&pkcs5_enc_alg_oids[i].oid, tmp_len, oid)) {
> +			enc_scheme =3D &pkcs5_enc_alg_oids[i];
> +			break;
> +		}

Our preference is to put {} around the enclosing for in this case.

item M1 here as well

> +	if (!enc_scheme)
> +		return NULL;
> +
> +	params =3D der_find_elem(enc_sequence, enc_len, 1, &tag, &params_len);
> +	if (!params)
> +		return NULL;
> +
> +	/* RFC8018 section B.2 */
> +
> +	/*
> +	 * Since we don't support RC2/RC5, all our PKCS#5 ciphers only
> +	 * have an obligatory OCTET STRING IV parameter and a fixed key
> +	 * length.
> +	 */
> +	if (tag !=3D ASN1_ID_OCTET_STRING || params_len !=3D enc_scheme->iv_siz=
e)
> +		return NULL;
> +
> +	if (key_len && enc_scheme->key_size !=3D key_len)
> +		return NULL;
> +	key_len =3D enc_scheme->key_size;
> +
> +	if (der_find_elem(enc_sequence, enc_len, 2, &tag, &tmp_len))
> +		return NULL;
> +
> +	/* RFC8018 section 6.2 */
> +
> +	if (!pkcs5_pbkdf2(prf_alg, password, salt, salt_len, iter_count,
> +				key_len, derived_key))
> +		return NULL;
> +
> +	cipher =3D l_cipher_new(enc_scheme->cipher_type, derived_key, key_len);
> +	if (!cipher)
> +		return NULL;
> +
> +	if (l_cipher_set_iv(cipher, params, enc_scheme->iv_size))
> +		return cipher;
> +
> +	l_cipher_free(cipher);
> +	return NULL;
> +}
> +
> +LIB_EXPORT struct l_cipher *l_cipher_from_pkcs5_id(const uint8_t *id_asn=
1,
> +							size_t id_asn1_len,
> +							const char *password)
> +{
> +	uint8_t tag;
> +	const uint8_t *oid, *params, *salt, *iter_count_buf;
> +	size_t oid_len, params_len, tmp_len;
> +	unsigned int i, iter_count;
> +	const struct pkcs5_pbes1_encryption_oid *pbes1_scheme =3D NULL;
> +	uint8_t derived_key[16];
> +	struct l_cipher *cipher;
> +
> +	oid =3D der_find_elem(id_asn1, id_asn1_len, 0, &tag, &oid_len);
> +	if (!oid || tag !=3D ASN1_ID_OID)
> +		return NULL;
> +
> +	params =3D der_find_elem(id_asn1, id_asn1_len, 1, &tag, &params_len);
> +	if (!params || tag !=3D ASN1_ID_SEQUENCE)
> +		return NULL;
> +
> +	if (der_find_elem(id_asn1, id_asn1_len, 2, &tag, &tmp_len))
> +		return NULL;
> +
> +	if (asn1_oid_eq(&pkcs5_pbes2_oid, oid_len, oid))
> +		return cipher_from_pkcs5_pbes2_params(params, params_len,
> +							password);
> +
> +	/* RFC8018 section A.3 */
> +
> +	for (i =3D 0; i < L_ARRAY_SIZE(pkcs5_pbes1_encryption_oids); i++)
> +		if (asn1_oid_eq(&pkcs5_pbes1_encryption_oids[i].oid,
> +					oid_len, oid)) {
> +			pbes1_scheme =3D &pkcs5_pbes1_encryption_oids[i];
> +			break;
> +		}

{}s for the outer for here please.  Item M1...

> +	if (!pbes1_scheme)
> +		return NULL;
> +
> +	salt =3D der_find_elem(params, params_len, 0, &tag, &tmp_len);
> +	if (!salt || tag !=3D ASN1_ID_OCTET_STRING || tmp_len !=3D 8)
> +		return NULL;
> +
> +	iter_count_buf =3D der_find_elem(params, params_len, 1, &tag, &tmp_len);
> +	if (!iter_count_buf || tag !=3D ASN1_ID_INTEGER ||
> +			tmp_len < 1 || tmp_len > 4)
> +		return NULL;
> +
> +	iter_count =3D 0;
> +	while (tmp_len--)
> +		iter_count =3D (iter_count << 8) | *iter_count_buf++;
> +
> +	if (der_find_elem(params, params_len, 2, &tag, &tmp_len))
> +		return NULL;
> +
> +	/* RFC8018 section 6.1 */
> +
> +	if (!pkcs5_pbkdf1(pbes1_scheme->checksum_type,
> +				password, salt, 8, iter_count, 16, derived_key))
> +		return NULL;
> +
> +	cipher =3D l_cipher_new(pbes1_scheme->cipher_type, derived_key + 0, 8);
> +	if (!cipher)
> +		return NULL;
> +
> +	if (l_cipher_set_iv(cipher, derived_key + 8, 8))
> +		return cipher;
> +
> +	l_cipher_free(cipher);
> +	return NULL;
> +}
> diff --git a/ell/cipher.h b/ell/cipher.h
> index d787f33..3c79aee 100644
> --- a/ell/cipher.h
> +++ b/ell/cipher.h
> @@ -41,6 +41,10 @@ enum l_cipher_type {
>   struct l_cipher *l_cipher_new(enum l_cipher_type type,
>   				const void *key, size_t key_length);
>   =

> +struct l_cipher *l_cipher_from_pkcs5_id(const uint8_t *id_asn1,
> +					size_t id_asn1_len,
> +					const char *password);
> +
>   void l_cipher_free(struct l_cipher *cipher);
>   =

>   bool l_cipher_encrypt(struct l_cipher *cipher,
> =


Regards,
-Denis

--===============1739890920861649589==--

