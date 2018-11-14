Content-Type: multipart/mixed; boundary="===============5833773911983809371=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: Re: [PATCH 01/12] cipher: Only do the RFC3610 IV formatting for CCM
Date: Wed, 14 Nov 2018 13:13:20 -0800
Message-ID: <alpine.OSX.2.21.1811141259360.19580@mjmartin-mac01.local>
In-Reply-To: <20181114131902.1695-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5833773911983809371==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable


Hi Andrew -

On Wed, 14 Nov 2018, Andrew Zaborowski wrote:

> In preparation to add the AES GCM mode, move the CCM-specific IV
> formatting code from operate_cipher to the callers (only aead encrypt
> and decrypt), make operate_cipher accept the IV buffer directly.  Check
> that the nonce is >=3D 7 bytes.
>
> Zero the "counter" part of the IV to avoid sending uninitialized bytes
> to the kernel (the kernel will zero them again though)
> ---
> ell/cipher.c | 91 +++++++++++++++++++++++++++++++++++-----------------
> 1 file changed, 61 insertions(+), 30 deletions(-)
>
> diff --git a/ell/cipher.c b/ell/cipher.c
> index 79cecdb..af4bc10 100644
> --- a/ell/cipher.c
> +++ b/ell/cipher.c
> @@ -266,28 +266,11 @@ LIB_EXPORT void l_aead_cipher_free(struct l_aead_ci=
pher *cipher)
> 	l_free(cipher);
> }
>
> -static ssize_t build_iv(const void *nonce, uint8_t nonce_len, uint8_t *i=
v,
> -			uint8_t iv_len)
> -{
> -	const size_t iv_overhead =3D 2;
> -
> -	if (nonce_len + iv_overhead > iv_len)
> -		return -EINVAL;
> -
> -	iv[0] =3D iv_len - iv_overhead - nonce_len;
> -	memcpy(iv + 1, nonce, nonce_len);
> -
> -	/* Assumes that remaining bytes in iv were already zeroed out */
> -
> -	return iv_len;
> -}
> -
> static ssize_t operate_cipher(int sk, __u32 operation,
> 				const void *in, size_t in_len,
> 				const void *ad, size_t ad_len,
> -				const void *nonce, size_t nonce_len,
> -				void *out, size_t out_len,
> -				size_t iv_len)
> +				const void *iv, size_t iv_len,
> +				void *out, size_t out_len)
> {
> 	char *c_msg_buf;
> 	size_t c_msg_size;
> @@ -298,7 +281,7 @@ static ssize_t operate_cipher(int sk, __u32 operation,
>
> 	c_msg_size =3D CMSG_SPACE(sizeof(operation));
> 	c_msg_size +=3D ad_len ? CMSG_SPACE(sizeof(uint32_t)) : 0;
> -	c_msg_size +=3D (nonce && iv_len) ?
> +	c_msg_size +=3D iv_len ?
> 		CMSG_SPACE(sizeof(struct af_alg_iv) + iv_len) : 0;
>
> 	c_msg_buf =3D alloca(c_msg_size);
> @@ -338,7 +321,7 @@ static ssize_t operate_cipher(int sk, __u32 operation,
> 		msg.msg_iovlen =3D 1;
> 	}
>
> -	if (nonce && iv_len) {
> +	if (iv_len) {
> 		struct af_alg_iv *algiv;
>
> 		c_msg =3D CMSG_NXTHDR(&msg, c_msg);
> @@ -348,9 +331,7 @@ static ssize_t operate_cipher(int sk, __u32 operation,
>
> 		algiv =3D (void *)CMSG_DATA(c_msg);
> 		algiv->ivlen =3D iv_len;
> -		result =3D build_iv(nonce, nonce_len, &algiv->iv[0], iv_len);
> -		if (result < 0)
> -			return result;
> +		memcpy(algiv->iv, iv, iv_len);
> 	}
>
> 	result =3D sendmsg(sk, &msg, 0);
> @@ -444,7 +425,7 @@ LIB_EXPORT bool l_cipher_encrypt(struct l_cipher *cip=
her,
> 		return false;
>
> 	return operate_cipher(cipher->encrypt_sk, ALG_OP_ENCRYPT, in, len,
> -				NULL, 0, NULL, 0, out, len, 0) >=3D 0;
> +				NULL, 0, NULL, 0, out, len) >=3D 0;
> }
>
> LIB_EXPORT bool l_cipher_encryptv(struct l_cipher *cipher,
> @@ -471,7 +452,7 @@ LIB_EXPORT bool l_cipher_decrypt(struct l_cipher *cip=
her,
> 		return false;
>
> 	return operate_cipher(cipher->decrypt_sk, ALG_OP_DECRYPT, in, len,
> -				NULL, 0, NULL, 0, out, len, 0) >=3D 0;
> +				NULL, 0, NULL, 0, out, len) >=3D 0;
> }
>
> LIB_EXPORT bool l_cipher_decryptv(struct l_cipher *cipher,
> @@ -534,21 +515,54 @@ static size_t l_aead_cipher_get_ivlen(struct l_aead=
_cipher *cipher)
> 	return 0;
> }
>
> +/* RFC3610 Section 2.3 */
> +static ssize_t build_ccm_iv(const void *nonce, uint8_t nonce_len, uint8_=
t *iv)
> +{
> +	const size_t iv_overhead =3D 2;
> +	const size_t iv_len =3D 16;

This depends on the length of the iv array being 16, but all we get from =

the caller is a uint8_t pointer. How about passing in iv_len for a more =

robust length check?

Other than that, the cipher patches look good. I also did a quick review =

of the rest of the series and didn't spot any issues.

Thanks,

Mat


> +
> +	if (unlikely(nonce_len + iv_overhead > iv_len || nonce_len < 7))
> +		return -EINVAL;
> +
> +	iv[0] =3D iv_len - iv_overhead - nonce_len;
> +	memcpy(iv + 1, nonce, nonce_len);
> +	memset(iv + 1 + nonce_len, 0, iv_len - 1 - nonce_len);
> +
> +	return iv_len;
> +}
> +
> LIB_EXPORT bool l_aead_cipher_encrypt(struct l_aead_cipher *cipher,
> 					const void *in, size_t in_len,
> 					const void *ad, size_t ad_len,
> 					const void *nonce, size_t nonce_len,
> 					void *out, size_t out_len)
> {
> +	uint8_t ccm_iv[16];
> +	const uint8_t *iv;
> +	ssize_t iv_len;
> +
> 	if (unlikely(!cipher))
> 		return false;
>
> 	if (unlikely(!in) || unlikely(!out))
> 		return false;
>
> +	if (cipher->type =3D=3D L_AEAD_CIPHER_AES_CCM) {
> +		iv_len =3D build_ccm_iv(nonce, nonce_len, ccm_iv);
> +		if (unlikely(iv_len < 0))
> +			return false;
> +
> +		iv =3D ccm_iv;
> +	} else {
> +		if (unlikely(nonce_len !=3D l_aead_cipher_get_ivlen(cipher)))
> +			return false;
> +
> +		iv =3D nonce;
> +		iv_len =3D nonce_len;
> +	}
> +
> 	return operate_cipher(cipher->encrypt_sk, ALG_OP_ENCRYPT, in, in_len,
> -				ad, ad_len, nonce, nonce_len, out, out_len,
> -				l_aead_cipher_get_ivlen(cipher)) =3D=3D
> +				ad, ad_len, iv, iv_len, out, out_len) =3D=3D
> 			(ssize_t)out_len;
> }
>
> @@ -558,15 +572,32 @@ LIB_EXPORT bool l_aead_cipher_decrypt(struct l_aead=
_cipher *cipher,
> 					const void *nonce, size_t nonce_len,
> 					void *out, size_t out_len)
> {
> +	uint8_t ccm_iv[16];
> +	const uint8_t *iv;
> +	ssize_t iv_len;
> +
> 	if (unlikely(!cipher))
> 		return false;
>
> 	if (unlikely(!in) || unlikely(!out))
> 		return false;
>
> +	if (cipher->type =3D=3D L_AEAD_CIPHER_AES_CCM) {
> +		iv_len =3D build_ccm_iv(nonce, nonce_len, ccm_iv);
> +		if (unlikely(iv_len < 0))
> +			return false;
> +
> +		iv =3D ccm_iv;
> +	} else {
> +		if (unlikely(nonce_len !=3D l_aead_cipher_get_ivlen(cipher)))
> +			return false;
> +
> +		iv =3D nonce;
> +		iv_len =3D nonce_len;
> +	}
> +
> 	return operate_cipher(cipher->decrypt_sk, ALG_OP_DECRYPT, in, in_len,
> -				ad, ad_len, nonce, nonce_len, out, out_len,
> -				l_aead_cipher_get_ivlen(cipher)) =3D=3D
> +				ad, ad_len, iv, iv_len, out, out_len) =3D=3D
> 			(ssize_t)out_len;
> }
>
> -- =

> 2.19.1
>
> _______________________________________________
> ell mailing list
> ell(a)lists.01.org
> https://lists.01.org/mailman/listinfo/ell
>

--
Mat Martineau
Intel OTC

--===============5833773911983809371==--

