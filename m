Content-Type: multipart/mixed; boundary="===============8441974641001418190=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v3 1/5] cipher: Update for current kernel akcipher
 interface
Date: Mon, 13 Jun 2016 12:49:00 -0500
Message-ID: <575EF20C.7010607@gmail.com>
In-Reply-To: <20160610170910.20259-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8441974641001418190==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

On 06/10/2016 12:09 PM, Mat Martineau wrote:
> There are some significant differences in the current iteration of
> kernel AF_ALG akcipher support:
>   * Kernel handles padding
>   * Kernel accepts DER-encoded certs as-is (no need to extract values)
>   * Must explicitly set private or public key
> ---
>   ell/cipher-private.h |   3 -
>   ell/cipher.c         | 311 ++++++++++++++------------------------------=
-------
>   ell/tls.c            |  43 +++----
>   3 files changed, 97 insertions(+), 260 deletions(-)
>

<snip>

>   LIB_EXPORT bool l_cipher_set_iv(struct l_cipher *cipher, const uint8_t =
*iv,
> @@ -275,6 +293,7 @@ LIB_EXPORT bool l_cipher_set_iv(struct l_cipher *ciph=
er, const uint8_t *iv,
>   struct l_asymmetric_cipher {
>   	struct l_cipher cipher;
>   	int key_size;
> +	bool public_key;

Do we really need this variable?  It seems that we only use it inside =

l_asymmetric_cipher_new.  In which case we can have a local variable to =

that function and have parse_rsa_key have an out parameter for this.

>   };
>
>   static inline int parse_asn1_definite_length(const uint8_t **buf,
> @@ -334,20 +353,31 @@ static bool parse_rsa_key(struct l_asymmetric_ciphe=
r *cipher, const void *key,
>   	 * and cache the size of the modulus n for later use.
>   	 * (RFC3279)
>   	 */
> +	size_t seq_length;
>   	size_t n_length;
> +	uint8_t *seq;
>   	uint8_t *der;
>   	uint8_t tag;
> +	bool pubkey =3D true;
>
>   	if (key_length < 8)
>   		return false;
>
>   	/* Unpack the outer SEQUENCE */
> -	der =3D der_find_elem((uint8_t *) key, key_length, 0, &tag, &n_length);
> -	if (!der || tag !=3D ASN1_ID_SEQUENCE)
> +	seq =3D der_find_elem((uint8_t *) key, key_length, 0, &tag, &seq_length=
);
> +	if (!seq || tag !=3D ASN1_ID_SEQUENCE)
>   		return false;
>
> -	/* Take first INTEGER as the modulus */
> -	der =3D der_find_elem(der, n_length, 0, &tag, &n_length);
> +	/* First INTEGER may be a 1-byte version (for private key) or
> +	 * the modulus (public key)
> +	 */
> +	der =3D der_find_elem(seq, seq_length, 0, &tag, &n_length);
> +	if (der && tag =3D=3D ASN1_ID_INTEGER && n_length =3D=3D 1) {
> +		/* Found version number, implies this is a private key. */
> +		der =3D der_find_elem(seq, seq_length, 1, &tag, &n_length);
> +		pubkey =3D false;
> +	}
> +
>   	if (!der || tag !=3D ASN1_ID_INTEGER || n_length < 4)
>   		return false;
>
> @@ -358,95 +388,11 @@ static bool parse_rsa_key(struct l_asymmetric_ciphe=
r *cipher, const void *key,
>   	}
>
>   	cipher->key_size =3D n_length;
> +	cipher->public_key =3D pubkey;
>

I'm okay with this for now, but really I'd rather that we didn't have =

any ASN.1 parsers inside ell.

Should we go in the direction of doing something like:

acipher =3D l_asymmetric_cipher_new(type);

l_asymmetric_cipher_set_pubkey(acipher, key, key_size);
l_asymmetric_cipher_set_privkey(acipher, key, key_size);

l_asymmetric_cipher_get_key_size(acipher);

>   	return true;
>   }
>

<snip>

>   LIB_EXPORT struct l_asymmetric_cipher *l_asymmetric_cipher_new(
>   					enum l_asymmetric_cipher_type type,
>   					const void *key, size_t key_length)
> @@ -468,19 +414,23 @@ LIB_EXPORT struct l_asymmetric_cipher *l_asymmetric=
_cipher_new(
>   		if (!parse_rsa_key(cipher, key, key_length))
>   			goto error_free;
>
> -		alg_name =3D "rsa";
> +		alg_name =3D "pkcs1pad(rsa)";
>   		break;
>   	}
>
>   	cipher->cipher.encrypt_sk =3D create_alg("akcipher", alg_name,
> -						key, key_length);
> +						key, key_length,
> +						cipher->public_key);
>   	if (cipher->cipher.encrypt_sk < 0)
>   		goto error_free;
>
> -	cipher->cipher.decrypt_sk =3D create_alg("akcipher", alg_name,
> -						key, key_length);
> -	if (cipher->cipher.decrypt_sk < 0)
> -		goto error_close;
> +	if (!cipher->public_key) {
> +		cipher->cipher.decrypt_sk =3D create_alg("akcipher", alg_name,
> +							key, key_length,
> +							cipher->public_key);
> +		if (cipher->cipher.decrypt_sk < 0)
> +			goto error_close;
> +	}
>
>   	return cipher;
>

<snip>

> -LIB_EXPORT bool l_asymmetric_cipher_decrypt(struct l_asymmetric_cipher *=
cipher,
> +LIB_EXPORT bool l_asymmetric_cipher_decrypt(struct l_asymmetric_cipher *=
acipher,
>   					const void *in, void *out,
>   					size_t len_in, size_t len_out)
>   {
> -	if (cipher->cipher.type =3D=3D L_CIPHER_RSA_PKCS1_V1_5) {
> -		/* PKCS#1 v1.5 RSA padding according to RFC3447 */
> -		uint8_t buf[cipher->key_size];
> -		int pos;
> -
> -		if (len_in !=3D (size_t) cipher->key_size)
> -			return false;
> -
> -		if (!l_cipher_decrypt(&cipher->cipher, in, buf,
> -					cipher->key_size))
> -			return false;
> -
> -		if (buf[0] !=3D 0x00)
> -			return false;
> -		if (buf[1] !=3D 0x02)
> -			return false;
> -
> -		for (pos =3D 2; pos < cipher->key_size; pos++)
> -			if (buf[pos] =3D=3D 0)
> -				break;
> -		if (pos < 10 || pos =3D=3D cipher->key_size)
> -			return false;
> -
> -		pos++;
> -		if (len_out !=3D (size_t) cipher->key_size - pos)
> -			return false;
> -
> -		memcpy(out, buf + pos, cipher->key_size - pos);
> -	}
> +	if (unlikely(!acipher))
> +		return false;
>
> -	return true;
> +	if (unlikely(!in) || unlikely(!out))
> +		return false;
> +

This should probably check for validity of decrypt_sk

> +	return operate_cipher(acipher->cipher.decrypt_sk, ALG_OP_DECRYPT,
> +				in, out, len_in, len_out);
>   }
>
>   LIB_EXPORT bool l_asymmetric_cipher_sign(struct l_asymmetric_cipher *ci=
pher,
>   					const void *in, void *out,
>   					size_t len_in, size_t len_out)
>   {
> -	if (cipher->cipher.type =3D=3D L_CIPHER_RSA_PKCS1_V1_5) {
> -		/* PKCS#1 v1.5 RSA padding according to RFC3447 */
> -		uint8_t buf[cipher->key_size];
> -		int ps_len =3D cipher->key_size - len_in - 3;
> -
> -		if (len_in > (size_t) cipher->key_size - 11)
> -			return false;
> -		if (len_out !=3D (size_t) cipher->key_size)
> -			return false;
> -
> -		buf[0] =3D 0x00;
> -		buf[1] =3D 0x01;
> -		memset(buf + 2, 0xff, ps_len);
> -		buf[ps_len + 2] =3D 0x00;
> -		memcpy(buf + ps_len + 3, in, len_in);
> -
> -		/*
> -		 * The RSA signing operation uses the same primitive as
> -		 * decryption so just call decrypt for now.
> -		 */
> -		if (!l_cipher_decrypt(&cipher->cipher, buf, out,
> -					cipher->key_size))
> -			return false;
> -	}
> +	if (unlikely(!acipher))
> +		return false;
>
> -	return true;
> +	if (unlikely(!in) || unlikely(!out))
> +		return false;
> +
> +	return operate_cipher(acipher->cipher.decrypt_sk, ALG_OP_SIGN,
> +				in, out, len_in, len_out);

Same here

>   }
>

<snip>

Regards,
-Denis


--===============8441974641001418190==--

