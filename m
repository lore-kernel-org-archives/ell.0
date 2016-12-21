Content-Type: multipart/mixed; boundary="===============8714758384474651447=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 2/3] cipher: Add AEAD API with AES-CCM
Date: Wed, 21 Dec 2016 13:32:00 -0600
Message-ID: <bfac5be1-ebc6-ecb7-b93d-df205b12e678@gmail.com>
In-Reply-To: <20161221014035.22874-2-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8714758384474651447==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

<snip>

> diff --git a/ell/cipher.h b/ell/cipher.h
> index f9ff42f..3aaf05d 100644
> --- a/ell/cipher.h
> +++ b/ell/cipher.h
> @@ -32,6 +32,7 @@ struct l_cipher;
>  enum l_cipher_type {
>  	L_CIPHER_AES =3D 0,
>  	L_CIPHER_AES_CBC,
> +	L_CIPHER_AES_CCM,
>  	L_CIPHER_ARC4,
>  	L_CIPHER_DES,
>  	L_CIPHER_DES3_EDE_CBC,
> @@ -39,14 +40,28 @@ enum l_cipher_type {
>
>  struct l_cipher *l_cipher_new(enum l_cipher_type type,
>  				const void *key, size_t key_length);
> +struct l_cipher *l_cipher_new_aead(enum l_cipher_type type,
> +					const void *key, size_t key_length,
> +					size_t tag_length);

I wonder if we should make this a whole new type, similar to how we did =

the asymmetric ciphers before keys took that over?

>
>  void l_cipher_free(struct l_cipher *cipher);
>
>  bool l_cipher_encrypt(struct l_cipher *cipher,
>  			const void *in, void *out, size_t len);
>
> +bool l_cipher_encrypt_aead(struct l_cipher *cipher,
> +				const void *in, size_t in_len,
> +				const void *ad, size_t ad_len,
> +				const void *nonce, size_t nonce_len,
> +				void *out, size_t out_len);

Otherwise we get into a situation that encrypt_aead can be called on a =

regular cipher or encrypt gets called on an aead cipher...

> +
>  bool l_cipher_decrypt(struct l_cipher *cipher,
>  			const void *in, void *out, size_t len);
> +bool l_cipher_decrypt_aead(struct l_cipher *cipher,
> +				const void *in, size_t in_len,
> +				const void *ad, size_t ad_len,
> +				const void *nonce, size_t nonce_len,
> +				void *out, size_t out_len);
>
>  bool l_cipher_set_iv(struct l_cipher *cipher, const uint8_t *iv,
>  			size_t iv_length);
>

Regards,
-Denis

--===============8714758384474651447==--

