Content-Type: multipart/mixed; boundary="===============5678233196682040436=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/9] tls: Drop local code to add hash OID, let kernel do it
Date: Tue, 27 Nov 2018 21:45:31 -0600
Message-ID: <0820f66c-2460-2cc0-2697-c0b6fed96dad@gmail.com>
In-Reply-To: <20181128023835.2081-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5678233196682040436==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 11/27/2018 08:38 PM, Andrew Zaborowski wrote:
> Drop tls.c code to build the PKCS#1 DigestInfo structure which basically
> consisted of prepending the signature hash algorithm's OID to the hash.
> Let the key API do it by setting the hash type in the l_key_sign and
> l_key_verify calls.  Slightly simplify the tls_rsa_sign and
> tls_rsa_verify code while doing this.
> ---
>   ell/tls.c | 164 ++++++++++++++++++------------------------------------
>   1 file changed, 53 insertions(+), 111 deletions(-)
> =


<snip>

> @@ -1238,13 +1179,11 @@ static bool tls_send_rsa_client_key_xchg(struct l=
_tls *tls)
>   static ssize_t tls_rsa_sign(struct l_tls *tls, uint8_t *out, size_t len,
>   				tls_get_hash_t get_hash)
>   {
> -	ssize_t result;
> -	const struct tls_hash_algorithm *hash_type;
> -	uint8_t hash[HANDSHAKE_HASH_MAX_SIZE];
> +	ssize_t result =3D -EMSGSIZE;
> +	enum l_checksum_type sign_checksum_type;
>   	uint8_t sign_input[HANDSHAKE_HASH_MAX_SIZE * 2 + 32];

Does this need to be updated?

>   	size_t sign_input_len;
> -	bool prepend_hash_type =3D false;
> -	size_t expected_bytes;
> +	uint8_t *ptr =3D out;
>   =

>   	if (!tls->priv_key || !tls->priv_key_size) {
>   		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, TLS_ALERT_BAD_CERT,
> @@ -1253,54 +1192,49 @@ static ssize_t tls_rsa_sign(struct l_tls *tls, ui=
nt8_t *out, size_t len,
>   		return -ENOKEY;
>   	}
>   =

> -	expected_bytes =3D tls->priv_key_size + 2;
> -
>   	if (tls->negotiated_version >=3D TLS_V12) {
> -		hash_type =3D &tls_handshake_hash_data[tls->signature_hash];
> -		get_hash(tls, hash_type->tls_id, hash, NULL, NULL);
> +		const struct tls_hash_algorithm *hash_type =3D
> +			hash_type =3D &tls_handshake_hash_data[tls->signature_hash];

What is going on here?

> +
> +		get_hash(tls, hash_type->tls_id, sign_input, NULL, NULL);
> +		sign_checksum_type =3D hash_type->l_id;
> +		sign_input_len =3D hash_type->length;
>   =

> -		pkcs1_write_digest_info(hash_type->l_id,
> -					sign_input, &sign_input_len,
> -					hash, hash_type->length);
> +		if (len < 2)
> +			goto error;

Why do we check this after generating the signature?

>   =

> -		prepend_hash_type =3D true;
> -		expected_bytes +=3D 2;
> +		*ptr++ =3D hash_type->tls_id;
> +		*ptr++ =3D 1;	/* RSA_sign */
> +		len -=3D 2;
>   	} else {
>   		get_hash(tls, 1, sign_input + 0, NULL, NULL);	/* MD5 */
>   		get_hash(tls, 2, sign_input + 16, NULL, NULL);	/* SHA1 */
> +		sign_checksum_type =3D L_CHECKSUM_NONE;
>   		sign_input_len =3D 36;
>   	}
>   =

> -	result =3D -EMSGSIZE;
> -
> -	if (len >=3D expected_bytes) {
> -		if (prepend_hash_type) {
> -			*out++ =3D hash_type->tls_id;
> -			*out++ =3D 1;	/* RSA_sign */
> -		}
> +	if (len < tls->priv_key_size + 2)
> +		goto error;
>   =

> -		l_put_be16(tls->priv_key_size, out);
> -		result =3D l_key_sign(tls->priv_key, L_KEY_RSA_PKCS1_V1_5,
> -					L_CHECKSUM_NONE, sign_input, out + 2,
> -					sign_input_len, tls->priv_key_size);
> +	l_put_be16(tls->priv_key_size, ptr);
> +	result =3D l_key_sign(tls->priv_key, L_KEY_RSA_PKCS1_V1_5,
> +				sign_checksum_type, sign_input, ptr + 2,
> +				sign_input_len, tls->priv_key_size);
> +	ptr +=3D tls->priv_key_size + 2;
>   =

> -		if (result =3D=3D (ssize_t) tls->priv_key_size)
> -			result =3D expected_bytes;
> -	}
> -
> -	if (result < 0)
> -		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
> -				"Signing the hash failed: %s",
> -				strerror(-result));
> +	if (result =3D=3D (ssize_t) tls->priv_key_size)
> +		return ptr - out; /* Success */
>   =

> +error:
> +	TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
> +			"Signing the hash failed: %s",
> +			strerror(-result));
>   	return result;
>   }
>   =

>   static bool tls_rsa_verify(struct l_tls *tls, const uint8_t *in, size_t=
 len,
>   				tls_get_hash_t get_hash)
>   {
> -	uint8_t hash[HANDSHAKE_HASH_MAX_SIZE];
> -	size_t hash_len;
>   	enum l_checksum_type hash_type;
>   	uint8_t expected[HANDSHAKE_HASH_MAX_SIZE * 2 + 32];

Same question here?

>   	size_t expected_len;

Regards,
-Denis

--===============5678233196682040436==--

