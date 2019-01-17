Content-Type: multipart/mixed; boundary="===============1730484799925954165=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/2] tls: Pass optional data parameter to sign/verify
 callbacks
Date: Thu, 17 Jan 2019 11:03:35 -0600
Message-ID: <5e13d457-a422-2ab6-7cec-00e54eedc520@gmail.com>
In-Reply-To: <20190111131430.12428-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1730484799925954165==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 01/11/2019 07:14 AM, Andrew Zaborowski wrote:
> Add parameters to optinally provide a buffer with the data to be
> signed/verified to the signature algorithm .sign and .verify functions,
> in addition to the current get_hash callback parameter.  Currently .sign
> and .verify would receive the get_hash callback and call it when
> necessary to obtain the hash of the data being signed.
> =

> In the case of the handshake messages signature the hash data is part of
> the handshake state so there was no need for additional parameters.
> When we're hashing the ServerKeyExchange parameters though there's no
> need to keep a buffer of the data around for longer than we're building
> or processing the message so there's no point copying it to the
> handshake state structs.  So instead we pass that buffer to
> .sign/.verify which then passes it to the get_hash callbacks.
> =

> This removes some duplication and in case of ECDHE gets rid of two
> instances of rebuilding the ServerECDHParams struct unnecessarily.
> ---
> This is to illustrate the possible cleanup in DHE to avoid putting a
> pointer to a stack structure in the handshake state.
> ---
>   ell/tls-private.h |   3 +
>   ell/tls-suites.c  | 198 ++++++++++++++++++++--------------------------
>   ell/tls.c         |   6 +-
>   3 files changed, 91 insertions(+), 116 deletions(-)

So I like this approach way more than the current situation.

> =

> diff --git a/ell/tls-private.h b/ell/tls-private.h
> index c82a4d5..134203f 100644
> --- a/ell/tls-private.h
> +++ b/ell/tls-private.h
> @@ -59,6 +59,7 @@ struct tls_hash_algorithm {
>   extern const struct tls_hash_algorithm tls_handshake_hash_data[];
>   =

>   typedef bool (*tls_get_hash_t)(struct l_tls *tls, uint8_t tls_id,
> +				const uint8_t *data, size_t data_len,
>   				uint8_t *out, size_t *len,

Can we call this out_len to make this clearer?

>   				enum l_checksum_type *type);

So one question I have is whether this type argument is needed.  It =

seems like you only ever use it in 1 place, and pass in NULL everywhere =

else.

You could simply add a convenience method to lookup l_checksum from a =

tls_id, no?

>   =

> @@ -80,8 +81,10 @@ struct tls_key_exchange_algorithm {
>   						const uint8_t *buf, size_t len);
>   =

>   	ssize_t (*sign)(struct l_tls *tls, uint8_t *out, size_t len,

Can we name this out_len to make it clearer

> +			const uint8_t *data, size_t data_len,

These maybe might need to come after the get_hash, since our general =

pattern is callback, userdata, not the other way around.

>   			tls_get_hash_t get_hash);
>   	bool (*verify)(struct l_tls *tls, const uint8_t *in, size_t len,
> +			const uint8_t *data, size_t data_len,
>   			tls_get_hash_t get_hash);

As above

>   =

>   	void (*free_params)(struct l_tls *tls);
> diff --git a/ell/tls-suites.c b/ell/tls-suites.c
> index cb1416a..d3c7f8f 100644
> --- a/ell/tls-suites.c
> +++ b/ell/tls-suites.c

<snip>

> @@ -188,8 +190,10 @@ static ssize_t tls_rsa_sign(struct l_tls *tls, uint8=
_t *out, size_t len,
>   		*ptr++ =3D 1;	/* RSA_sign */
>   		len -=3D 2;
>   	} else {
> -		get_hash(tls, 1, sign_input + 0, NULL, NULL);	/* MD5 */
> -		get_hash(tls, 2, sign_input + 16, NULL, NULL);	/* SHA1 */
> +		/* MD5 */
> +		get_hash(tls, 1, data, data_len, sign_input + 0, NULL, NULL);
> +		/* SHA1 */
> +		get_hash(tls, 2, data, data_len, sign_input + 16, NULL, NULL);

So for example, here this can be simplified to:

get_hash((tls, L_CHECKSUM_SHA1, data, data_len, sign_input + 16, NULL);
etc

>   		sign_checksum_type =3D L_CHECKSUM_NONE;
>   		sign_input_len =3D 36;
>   	}
> @@ -214,6 +218,7 @@ error:
>   }
>   =

>   static bool tls_rsa_verify(struct l_tls *tls, const uint8_t *in, size_t=
 len,
> +				const uint8_t *data, size_t data_len,
>   				tls_get_hash_t get_hash)
>   {
>   	enum l_checksum_type hash_type;
> @@ -255,8 +260,8 @@ static bool tls_rsa_verify(struct l_tls *tls, const u=
int8_t *in, size_t len,
>   			return false;
>   		}
>   =

> -		if (!get_hash(tls, in[0], expected, &expected_len,
> -				&hash_type)) {
> +		if (!get_hash(tls, in[0], data, data_len,
> +				expected, &expected_len, &hash_type)) {

And here you'd lookup hash_type first...

>   			TLS_DISCONNECT(TLS_ALERT_DECRYPT_ERROR, 0,
>   					"Unknown hash type %i", in[0]);
>   =


The rest seems fine to me.

Regards,
-Denis

--===============1730484799925954165==--

