Content-Type: multipart/mixed; boundary="===============4704853365719280351=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: Re: [PATCH] key: Have kernel handle padding
Date: Thu, 08 Nov 2018 14:07:33 -0800
Message-ID: <alpine.OSX.2.21.1811081347530.6619@dbdavenp-mobl.amr.corp.intel.com>
In-Reply-To: <20181108152145.23765-1-denkenz@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4704853365719280351==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On Thu, 8 Nov 2018, Denis Kenzior wrote:

Worth having the commit message note the kernel version where the padding =

functionality returns?

> ---
> ell/key.c | 170 ++++++++++++---------------------------------------------=
-----
> 1 file changed, 33 insertions(+), 137 deletions(-)
>
> diff --git a/ell/key.c b/ell/key.c
> index fe2fbb3..37e1841 100644
> --- a/ell/key.c
> +++ b/ell/key.c

You can drop random.h from the includes now.

> @@ -238,6 +238,26 @@ static long kernel_key_eds(int op, int32_t serial, c=
onst char *encoding,
> 	return result >=3D 0 ? result : -errno;
> }
>
> +static long kernel_key_verify(int32_t serial,
> +				const char *encoding, const char *hash,
> +				const void *data, size_t data_len,
> +				const void *sig, size_t sig_len)
> +{
> +	struct keyctl_pkey_params params =3D {
> +		.key_id		=3D serial,
> +		.in_len		=3D data_len,
> +		.in2_len	=3D sig_len,
> +	};
> +	char *info =3D format_key_info(encoding, hash);
> +	long result;
> +
> +	result =3D syscall(__NR_keyctl, KEYCTL_PKEY_VERIFY, &params,
> +				info ?: "", data, sig);
> +	l_free(info);
> +
> +	return result >=3D 0 ? result : -errno;
> +}
> +
> static bool setup_internal_keyring(void)
> {
> 	internal_keyring =3D kernel_add_key("keyring", "ell-internal", NULL, 0,
> @@ -352,7 +372,7 @@ static const char *lookup_cipher(enum l_key_cipher_ty=
pe cipher)
> 		/* Padding is handled in userspace, so the kernel only sees
> 		 * raw RSA operations
> 		 */
> -		ret =3D "raw";
> +		ret =3D "pkcs1";
> 		break;
> 	case L_KEY_RSA_RAW:
> 		ret =3D "raw";
> @@ -461,75 +481,6 @@ static ssize_t eds_common(struct l_key *key,
> 				len_out);
> }
>
> -static void getrandom_nonzero(uint8_t *buf, int len)
> -{
> -	l_getrandom(buf, len);
> -
> -	while (len--) {
> -		while (buf[0] =3D=3D 0)
> -			l_getrandom(buf, 1);
> -
> -		buf++;
> -	}
> -}
> -
> -/* PKCS#1 v1.5 RSA padding according to RFC3447 */
> -static uint8_t *pad(const uint8_t *in, size_t len_in, size_t len_out,
> -			uint8_t flag, bool randfill)
> -{
> -	size_t fill_len;
> -	uint8_t *padded;
> -
> -	if (len_in > len_out - 11)
> -		return NULL;
> -
> -	padded =3D l_malloc(len_out);
> -	fill_len =3D len_out - len_in - 3;
> -
> -	padded[0] =3D 0x00;
> -	padded[1] =3D flag;
> -
> -	if (randfill)
> -		getrandom_nonzero(padded + 2, fill_len);
> -	else
> -		memset(padded + 2, 0xff, fill_len);
> -
> -	padded[fill_len + 2] =3D 0x00;
> -	memcpy(padded + fill_len + 3, in, len_in);
> -
> -	return padded;
> -}
> -
> -static ssize_t unpad(uint8_t *in, uint8_t *out, size_t len_in, size_t le=
n_out,
> -			uint8_t flag, bool randfill)
> -{
> -	size_t pos;
> -	ssize_t unpad_len;
> -
> -	if (in[0] !=3D 0x00 || in[1] !=3D flag)
> -		return -EINVAL;
> -
> -	if (randfill)
> -		for (pos =3D 2; pos < len_in && in[pos] !=3D 0x00; pos++);
> -	else
> -		for (pos =3D 2; pos < len_in && in[pos] =3D=3D 0xff; pos++);
> -
> -	if (pos < 10 || pos =3D=3D len_in)
> -		return -EINVAL;
> -
> -	pos++;
> -	unpad_len =3D len_in - pos;
> -
> -	if (out) {
> -		if ((size_t)unpad_len > len_out)
> -			return -EINVAL;
> -
> -		memcpy(out, in + pos, unpad_len);
> -	}
> -
> -	return unpad_len;
> -}
> -
> LIB_EXPORT ssize_t l_key_encrypt(struct l_key *key,
> 					enum l_key_cipher_type cipher,
> 					enum l_checksum_type checksum,
> @@ -543,14 +494,6 @@ LIB_EXPORT ssize_t l_key_encrypt(struct l_key *key,
> 	if (checksum !=3D L_CHECKSUM_NONE)
> 		return -EINVAL;
>
> -	if (cipher =3D=3D L_KEY_RSA_PKCS1_V1_5) {
> -		padded =3D pad(in, len_in, len_out, 0x02, true);
> -		if (!padded)
> -			return -EOVERFLOW;
> -
> -		cipher =3D L_KEY_RSA_RAW;
> -	}
> -
> 	ret_len =3D eds_common(key, cipher, checksum, padded ?: in, out,
> 				padded ? len_out : len_in, len_out,
> 				KEYCTL_PKEY_ENCRYPT);

The 'padded' variable needs to be removed from this function too.

Otherwise, looks good. (I haven't run this with a 4.20 rc build though)


Mat


> @@ -566,28 +509,19 @@ LIB_EXPORT ssize_t l_key_decrypt(struct l_key *key,
> 					const void *in, void *out,
> 					size_t len_in, size_t len_out)
> {
> -	uint8_t *padded =3D NULL;
> 	ssize_t ret_len;
>
> 	/* Other checksum types are not yet supported */
> 	if (checksum !=3D L_CHECKSUM_NONE)
> 		return -EINVAL;
>
> -	if (cipher =3D=3D L_KEY_RSA_PKCS1_V1_5)
> -		padded =3D l_malloc(len_in);
> -
> -	ret_len =3D eds_common(key, cipher, checksum, in, padded ?: out, len_in,
> -				padded ? len_in : len_out, KEYCTL_PKEY_DECRYPT);
> +	ret_len =3D eds_common(key, cipher, checksum, in, out, len_in,
> +				len_out, KEYCTL_PKEY_DECRYPT);
>
> 	if (ret_len < 0)
> 		goto done;
>
> -	if (padded)
> -		ret_len =3D unpad(padded, out, ret_len, len_out, 0x02, true);
> -
> done:
> -	l_free(padded);
> -
> 	return ret_len;
> }
>
> @@ -596,27 +530,16 @@ LIB_EXPORT ssize_t l_key_sign(struct l_key *key,
> 				enum l_checksum_type checksum, const void *in,
> 				void *out, size_t len_in, size_t len_out)
> {
> -	uint8_t *padded =3D NULL;
> 	ssize_t ret_len;
>
> 	/* Other checksum types are not yet supported */
> 	if (checksum !=3D L_CHECKSUM_NONE)
> 		return -EINVAL;
>
> -	if (cipher =3D=3D L_KEY_RSA_PKCS1_V1_5) {
> -		padded =3D pad(in, len_in, len_out, 0x01, false);
> -		if (!padded)
> -			return -EOVERFLOW;
> -
> -		cipher =3D L_KEY_RSA_RAW;
> -	}
> -
> -	ret_len =3D eds_common(key, cipher, checksum, padded ?: in, out,
> -				padded ? len_out : len_in, len_out,
> +	ret_len =3D eds_common(key, cipher, checksum, in, out,
> +				len_in, len_out,
> 				KEYCTL_PKEY_SIGN);
>
> -	l_free(padded);
> -
> 	return ret_len;
> }
>
> @@ -626,48 +549,21 @@ LIB_EXPORT bool l_key_verify(struct l_key *key,
> 				const void *sig, size_t len_data,
> 				size_t len_sig)
> {
> -	enum l_key_cipher_type kernel_cipher;
> -	ssize_t hash_len;
> -	uint8_t *compare_hash;
> -	L_AUTO_FREE_VAR(uint8_t *, sig_hash);
> +	long result;
>
> -	sig_hash =3D l_malloc(len_sig);
> +	if (unlikely(!key))
> +		return false;
>
> 	/* Other checksum types are not yet supported */
> 	if (checksum !=3D L_CHECKSUM_NONE)
> 		return false;
>
> -	/* The keyctl verify implementation compares the verify results
> -	 * before we get a chance to unpad it. Instead, use the *encrypt*
> -	 * operation (which uses the same math as verify) to get the hash
> -	 * returned to us so it can be unpadded before comparing
> -	 */
> -	if (cipher =3D=3D L_KEY_RSA_PKCS1_V1_5)
> -		kernel_cipher =3D L_KEY_RSA_RAW;
> -	else
> -		kernel_cipher =3D cipher;
> -
> -	hash_len =3D eds_common(key, kernel_cipher, checksum, sig, sig_hash,
> -				len_sig, len_sig, KEYCTL_PKEY_ENCRYPT);
> -
> -	if (hash_len < 0)
> -		return false;
> -
> -	compare_hash =3D sig_hash;
> -
> -	if (cipher =3D=3D L_KEY_RSA_PKCS1_V1_5) {
> -		ssize_t unpad_len;
> -
> -		unpad_len =3D unpad(sig_hash, NULL, hash_len, 0, 0x01, false);
> -		if (unpad_len < 0)
> -			return false;
> -
> -		compare_hash +=3D hash_len - unpad_len;
> -		hash_len =3D unpad_len;
> -	}
> +	result =3D kernel_key_verify(key->serial, lookup_cipher(cipher),
> +					lookup_checksum(checksum),
> +					data, len_data,
> +					sig, len_sig);
>
> -	return (len_data =3D=3D (size_t)hash_len) &&
> -		(memcmp(data, compare_hash, hash_len) =3D=3D 0);
> +	return result >=3D 0;
> }
>
> LIB_EXPORT struct l_keyring *l_keyring_new(void)
> -- =

> 2.16.1
>
> _______________________________________________
> ell mailing list
> ell(a)lists.01.org
> https://lists.01.org/mailman/listinfo/ell
>

--
Mat Martineau
Intel OTC

--===============4704853365719280351==--

