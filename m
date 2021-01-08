Content-Type: multipart/mixed; boundary="===============1528774914198829493=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 6/8] cert: Add PKCS#12 loading support
Date: Thu, 07 Jan 2021 22:59:52 -0600
Message-ID: <bde3ebff-fb44-b2f1-74b6-cdaac00d62f4@gmail.com>
In-Reply-To: <20210106195446.1428769-6-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1528774914198829493==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

<snip>

> +/* RFC5652 Section 8 */
> +static uint8_t *cert_decrypt_pkcs7_encrypted_data(const uint8_t *data,
> +						size_t data_len,
> +						const char *password,
> +						struct asn1_oid *out_oid,
> +						size_t *out_len)
> +{
> +	const uint8_t *version;
> +	size_t version_len;
> +	const uint8_t *encrypted_info;
> +	size_t encrypted_info_len;
> +	const uint8_t *type;
> +	size_t type_len;
> +	const uint8_t *alg_id;
> +	size_t alg_id_len;
> +	const uint8_t *encrypted;
> +	size_t encrypted_len;
> +	uint8_t tag;
> +	struct l_cipher *alg;
> +	uint8_t *plaintext;
> +	int i;
> +	bool ok;
> +	bool is_block;
> +
> +	if (!(version =3D asn1_der_find_elem(data, data_len, 0, &tag,
> +						&version_len)) ||
> +			tag !=3D ASN1_ID_INTEGER || version_len !=3D 1 ||
> +			!L_IN_SET(version[0], 0, 2))
> +		return NULL;
> +
> +	if (!(encrypted_info =3D asn1_der_find_elem(data, data_len, 1, &tag,
> +							&encrypted_info_len)) ||
> +			tag !=3D ASN1_ID_SEQUENCE)
> +		return NULL;
> +
> +	if (!(type =3D asn1_der_find_elem(encrypted_info, encrypted_info_len, 0,
> +					&tag, &type_len)) ||
> +			tag !=3D ASN1_ID_OID ||
> +			type_len > sizeof(out_oid->asn1))
> +		return NULL;
> +
> +	if (!(alg_id =3D asn1_der_find_elem(encrypted_info, encrypted_info_len,=
 1,
> +					&tag, &alg_id_len)) ||
> +			tag !=3D ASN1_ID_SEQUENCE)
> +		return NULL;
> +
> +	/* Not optional in our case, defined [0] IMPLICIT OCTET STRING */
> +	if (!(encrypted =3D asn1_der_find_elem(encrypted_info, encrypted_info_l=
en,
> +						ASN1_CONTEXT_IMPLICIT(0),
> +						&tag, &encrypted_len)) ||
> +			tag !=3D ASN1_ID(ASN1_CLASS_CONTEXT, 0, 0) ||
> +			encrypted_len < 8)
> +		return NULL;
> +
> +	if (!(alg =3D cert_cipher_from_pkcs_alg_id(alg_id, alg_id_len, password,
> +							&is_block)))
> +		return NULL;
> +
> +	plaintext =3D l_malloc(encrypted_len);
> +	ok =3D l_cipher_decrypt(alg, encrypted, plaintext, encrypted_len);
> +	l_cipher_free(alg);
> +
> +	if (!ok)
> +		return NULL;
> +

is plaintext leaked here?

> +	if (is_block) {
> +		bool ok =3D true;
> +
> +		/* Also validate the padding */
> +		if (encrypted_len < plaintext[encrypted_len - 1] ||
> +				plaintext[encrypted_len - 1] > 16)
> +			return NULL;
> +

same question as above?

> +		for (i =3D 1; i < plaintext[encrypted_len - 1]; i++)
> +			if (plaintext[encrypted_len - 1 - i] !=3D
> +					plaintext[encrypted_len - 1])
> +				ok =3D false;
> +
> +		if (!ok) {
> +			explicit_bzero(plaintext, encrypted_len);
> +			l_free(plaintext);
> +			return NULL;
> +		}
> +
> +		encrypted_len -=3D plaintext[encrypted_len - 1];
> +	}
> +
> +	if (out_oid) {
> +		out_oid->asn1_len =3D type_len;
> +		memcpy(out_oid->asn1, type, type_len);
> +	}
> +
> +	*out_len =3D encrypted_len;
> +	return plaintext;
> +}
> +

<snip>

> +static bool cert_parse_pkcs12_pfx(const uint8_t *ptr, size_t len,
> +					const char *password,
> +					struct l_certchain **out_certchain,
> +					struct l_key **out_privkey)
> +{
> +	const uint8_t *version;
> +	size_t version_len;
> +	const uint8_t *auth_safe;
> +	size_t auth_safe_len;
> +	const uint8_t *auth_safe_seq;
> +	size_t auth_safe_seq_len;
> +	const uint8_t *mac_data;
> +	size_t mac_data_len;
> +	const uint8_t *mac;
> +	size_t mac_len;
> +	const uint8_t *mac_salt;
> +	size_t mac_salt_len;
> +	const uint8_t *iterations_data;
> +	size_t iterations_len;
> +	unsigned int iterations;
> +	const uint8_t *digest_alg;
> +	size_t digest_alg_len;
> +	const uint8_t *digest;
> +	size_t digest_len;
> +	const uint8_t *alg_id;
> +	size_t alg_id_len;
> +	const struct cert_pkcs12_hash *mac_hash;
> +	L_AUTO_FREE_VAR(uint8_t *, key) =3D NULL;
> +	struct l_checksum *hmac;
> +	uint8_t hmac_val[64];
> +	uint8_t tag;
> +	unsigned int i;
> +	bool ok;

This function is unusually long.  It makes me wonder if breaking it up into =

multiple pieces would make it more readable...?

> +
> +	/* RFC7292 Section 4 */
> +	if (!(version =3D asn1_der_find_elem(ptr, len, 0, &tag, &version_len)) =
||
> +			tag !=3D ASN1_ID_INTEGER)
> +		return false;
> +
> +	if (version_len !=3D 1 || version[0] !=3D 3)
> +		return false;
> +
> +	/*
> +	 * Since we only support the password-based integrity mode,  the
> +	 * authSafe must be of PKCS#7 type "data" and not "signedData".
> +	 */
> +	if (!(auth_safe =3D cert_unpack_pkcs7_content_info(ptr, len, 1,
> +							&pkcs7_data_oid, NULL,
> +							&tag,
> +							&auth_safe_len)) ||
> +			tag !=3D ASN1_ID_OCTET_STRING)
> +		return false;
> +
> +	/*
> +	 * openssl can generate PFX structures without macData not signed
> +	 * with a public key so handle this case, otherwise the macData
> +	 * would not be optional.
> +	 */
> +	if (auth_safe + auth_safe_len =3D=3D ptr + len)
> +		goto integrity_check_done;
> +
> +	if (!(mac_data =3D asn1_der_find_elem(ptr, len, 2, &tag,
> +						&mac_data_len)) ||
> +			tag !=3D ASN1_ID_SEQUENCE)
> +		return false;
> +
> +	if (!(mac =3D asn1_der_find_elem(mac_data, mac_data_len, 0, &tag,
> +					&mac_len)) ||
> +			tag !=3D ASN1_ID_SEQUENCE)
> +		return false;
> +
> +	if (!(mac_salt =3D asn1_der_find_elem(mac_data, mac_data_len, 1, &tag,
> +						&mac_salt_len)) ||
> +			tag !=3D ASN1_ID_OCTET_STRING || mac_salt_len > 1024)
> +		return false;
> +
> +	if (!(iterations_data =3D asn1_der_find_elem(mac_data, mac_data_len, 2,
> +							&tag,
> +							&iterations_len)) ||
> +			tag !=3D ASN1_ID_INTEGER || iterations_len > 4)
> +		return false;
> +
> +	for (iterations =3D 0; iterations_len; iterations_len--)
> +		iterations =3D (iterations << 8) | *iterations_data++;
> +
> +	if (iterations < 1 || iterations > 8192)
> +		return false;
> +
> +	/* RFC2315 Section 9.4 */
> +	if (!(digest_alg =3D asn1_der_find_elem(mac, mac_len, 0, &tag,
> +						&digest_alg_len)) ||
> +			tag !=3D ASN1_ID_SEQUENCE)
> +		return false;
> +
> +	if (!(digest =3D asn1_der_find_elem(mac, mac_len, 1, &tag,
> +						&digest_len)) ||
> +			tag !=3D ASN1_ID_OCTET_STRING)
> +		return false;
> +
> +	if (!(alg_id =3D asn1_der_find_elem(digest_alg, digest_alg_len,
> +						0, &tag, &alg_id_len)) ||
> +			tag !=3D ASN1_ID_OID)
> +		return false;
> +
> +	/* This is going to be used for both the MAC and its key derivation */
> +	for (i =3D 0; i < L_ARRAY_SIZE(pkcs12_mac_algs); i++)
> +		if (asn1_oid_eq(&pkcs12_mac_algs[i].oid, alg_id_len, alg_id)) {
> +			mac_hash =3D &pkcs12_mac_algs[i];
> +			break;
> +		}
> +
> +	if (i =3D=3D L_ARRAY_SIZE(pkcs12_mac_algs) || digest_len !=3D mac_hash-=
>u)
> +		return false;
> +
> +	if (!(key =3D cert_pkcs12_pbkdf(password, mac_hash,
> +					mac_salt, mac_salt_len,
> +					iterations, 3, mac_hash->u)))
> +		return false;
> +
> +	hmac =3D l_checksum_new_hmac(mac_hash->alg, key, mac_hash->u);
> +	explicit_bzero(key, mac_hash->u);
> +
> +	if (!hmac)
> +		return false;
> +
> +	ok =3D l_checksum_update(hmac, auth_safe, auth_safe_len) &&
> +		l_checksum_get_digest(hmac, hmac_val, mac_hash->len) > 0;
> +	l_checksum_free(hmac);
> +
> +	if (!ok)
> +		return false;
> +
> +	/*
> +	 * SHA-512/224 and SHA-512/256 are not supported.  We can truncate the
> +	 * output for key derivation but we can't do this inside the HMAC
> +	 * algorithms based on these hashes.  We skip the MAC verification
> +	 * if one of these hashes is used (identified by .u !=3D .len)
> +	 */
> +	if (mac_hash->u !=3D mac_hash->len)
> +		goto integrity_check_done;
> +
> +	if (l_secure_memcmp(hmac_val, digest, digest_len))
> +		return false;
> +
> +integrity_check_done:
> +	if (!(auth_safe_seq =3D asn1_der_find_elem(auth_safe, auth_safe_len, 0,
> +						&tag, &auth_safe_seq_len)) ||
> +			tag !=3D ASN1_ID_SEQUENCE ||
> +			auth_safe + auth_safe_len !=3D
> +			auth_safe_seq + auth_safe_seq_len)
> +		return false;
> +
> +	i =3D 0;
> +	while (1) {
> +		struct asn1_oid data_oid;
> +		const uint8_t *data;
> +		size_t data_len;
> +
> +		if (!(data =3D cert_unpack_pkcs7_content_info(auth_safe_seq,
> +							auth_safe_seq_len, i++,
> +							NULL, &data_oid, &tag,
> +							&data_len)))
> +			return false;
> +
> +		if (asn1_oid_eq(&pkcs7_encrypted_data_oid,
> +					data_oid.asn1_len, data_oid.asn1)) {
> +			uint8_t *plaintext;
> +			size_t plaintext_len;
> +			struct asn1_oid oid;
> +
> +			if (tag !=3D ASN1_ID_SEQUENCE)
> +				return false;
> +
> +			/*
> +			 * This is same as PKCS#7 encryptedData but the ciphers
> +			 * used are from PKCS#12 (broken but still the default
> +			 * everywhere) and PKCS#5 (recommended).
> +			 */
> +			plaintext =3D cert_decrypt_pkcs7_encrypted_data(data,
> +								data_len,
> +								password, &oid,
> +								&plaintext_len);
> +			if (!plaintext)
> +				return false;
> +
> +			/*
> +			 * Since we only support PKCS#7 data and encryptedData
> +			 * types, and there's no point re-encrypting
> +			 * encryptedData, the plaintext must be a PKCS#7
> +			 * "data".
> +			 */
> +			ok =3D asn1_oid_eq(&pkcs7_data_oid,
> +						oid.asn1_len, oid.asn1) &&
> +				cert_parse_pkcs12_safe_contents(plaintext,
> +								plaintext_len,
> +								password,
> +								out_certchain,
> +								out_privkey);
> +			explicit_bzero(plaintext, plaintext_len);
> +			l_free(plaintext);
> +
> +			if (!ok)
> +				return false;
> +		} else if (asn1_oid_eq(&pkcs7_data_oid,
> +					data_oid.asn1_len, data_oid.asn1)) {
> +			if (tag !=3D ASN1_ID_OCTET_STRING)
> +				return false;
> +
> +			if (!cert_parse_pkcs12_safe_contents(data, data_len,
> +								password,
> +								out_certchain,
> +								out_privkey))

While this function is not public API, it still feels like side-effecting t=
he =

out parameters here is something that makes the logic harder to follow...  =
Are =

you sure you don't want to clean these up on failure?

> +				return false;
> +		}
> +		/* envelopedData support not needed */
> +
> +		if (data + data_len =3D=3D auth_safe_seq + auth_safe_seq_len)
> +			return true;
> +	}
> +}
> +
>   /*
>    * Look at a file, try to detect which of the few X.509 certificate and=
/or
>    * private key container formats it uses and load any certificates in i=
t as

<snip>

Regards,
-Denis
--===============1528774914198829493==--

