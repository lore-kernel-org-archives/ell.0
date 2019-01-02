Content-Type: multipart/mixed; boundary="===============3183978400003533442=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 14/17] tls: DHE_RSA key exchange implementation client side
Date: Wed, 02 Jan 2019 16:32:44 -0600
Message-ID: <8717364a-9053-6bbc-48a3-ce6a17b63d67@gmail.com>
In-Reply-To: <20190101194939.5974-14-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3183978400003533442==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 01/01/2019 01:49 PM, Andrew Zaborowski wrote:
> Add a new key exchange definition with the callbacks needed to handle the
> client side of the DHE_RSA key exchange.
> ---
>   ell/tls-suites.c | 354 +++++++++++++++++++++++++++++++++++++++++++++++
>   1 file changed, 354 insertions(+)
> =


<snip>

> +static bool tls_create_dhe_keys(struct l_tls *tls)
> +{
> +	struct tls_dhe_params *params =3D tls->pending.key_xchg_params;
> +
> +	if (!params)
> +		return false;
> +
> +	if (params->prime_buf && !params->prime) {
> +		params->prime =3D l_key_new(L_KEY_RAW, params->prime_buf,
> +						params->prime_len);
> +		if (!params->prime) {
> +			TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
> +					"l_key_new(prime) failed");
> +			return false;
> +		}
> +	}
> +
> +	if (params->generator_buf && !params->generator) {
> +		params->generator =3D l_key_new(L_KEY_RAW, params->generator_buf,
> +						params->generator_len);
> +		if (!params->generator) {
> +			TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
> +					"l_key_new(generator) failed");
> +			return false;
> +		}
> +	}
> +
> +	if (params->private_buf && !params->private) {
> +		params->private =3D l_key_new(L_KEY_RAW, params->private_buf,
> +						params->private_len);
> +		if (!params->private) {
> +			TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
> +					"l_key_new(private) failed");
> +			return false;
> +		}
> +	}
> +
> +	if (params->public_buf && !params->public) {
> +		params->public =3D l_key_new(L_KEY_RAW, params->public_buf,
> +						params->public_len);
> +		if (!params->public) {
> +			TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
> +					"l_key_new(public) failed");
> +			return false;
> +		}
> +	}
> +
> +	return true;
> +}

It seems like the intent of this function is to be called more than =

once, piecemeal creating the l_key objects.  Why?  That type of pattern =

isn't terribly readable / maintainable.

> +
> +static bool tls_generate_dhe_private(struct l_tls *tls, uint8_t *buf, si=
ze_t len)
> +{
> +	struct tls_dhe_params *params =3D tls->pending.key_xchg_params;
> +
> +	do {
> +		unsigned int written =3D 0;
> +
> +		/* Leading zeros in the private value are fine */
> +
> +		do {
> +			size_t chunk_len =3D
> +				written + 256 <=3D len ? 256 : len - written;
> +
> +			if (!l_getrandom(buf + written, chunk_len)) {
> +				TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
> +						"l_getrandom(buf, %zu) failed",
> +						chunk_len);
> +				return false;
> +			}
> +
> +			written +=3D chunk_len;
> +		} while (written < len);

So where is the magic 256 byte thing is coming from?  Is this due to the =

EINTR possibility?  If so either use TFR() inside l_getrandom itself, or =

have l_getrandom perform this magic.  This blocking logic doesn't belong =

here.

> +	} while (!l_key_validate_dh_payload(buf, len,
> +						params->prime_buf,
> +						params->prime_len));

Generating a whole new random number is really a bad way of doing =

things.  The entropy pool is a very limited resource, so don't abuse it. =

  A much easier way would be to simply set the most-significant-byte to =

0.  Or maybe even just the most-significant-bit.  The prime numbers are =

usually always starting with 0xff, so fudging a single byte out of 192+ =

should be safe.

> +
> +	return true;
> +}
> +

<snip>

> +static bool tls_get_server_dh_params_hash(struct l_tls *tls, uint8_t tls=
_id,
> +						uint8_t *out, size_t *len,
> +						enum l_checksum_type *type)
> +{
> +	unsigned int hash;
> +	struct l_checksum *checksum;
> +	uint8_t params[32 + TLS_DHE_MAX_SIZE * 3];

Have you considered making this a static buf inside =

tls_write_server_dh_params?

> +	size_t params_len;
> +	ssize_t hash_len, ret;
> +
> +	params_len =3D tls_write_server_dh_params(tls, params);
> +
> +	for (hash =3D 0; hash < __HANDSHAKE_HASH_COUNT; hash++)
> +		if (tls_handshake_hash_data[hash].tls_id =3D=3D tls_id)
> +			break;
> +
> +	if (hash =3D=3D __HANDSHAKE_HASH_COUNT)
> +		return false;

Why not perform the search prior to tls_write_server_dh_params?

> +
> +	hash_len =3D tls_handshake_hash_data[hash].length;
> +
> +	checksum =3D l_checksum_new(tls_handshake_hash_data[hash].l_id);
> +	if (!checksum)
> +		return false;
> +
> +	l_checksum_update(checksum, tls->pending.client_random, 32);
> +	l_checksum_update(checksum, tls->pending.server_random, 32);
> +	l_checksum_update(checksum, params, params_len);
> +	ret =3D l_checksum_get_digest(checksum, out, hash_len);
> +	l_checksum_free(checksum);
> +
> +	if (ret !=3D (ssize_t) hash_len)
> +		return false;
> +
> +	if (len)
> +		*len =3D hash_len;
> +
> +	if (type)
> +		*type =3D tls_handshake_hash_data[hash].l_id;
> +
> +	return true;
> +}
> +
> +static void tls_handle_dhe_server_key_xchg(struct l_tls *tls,
> +						const uint8_t *buf, size_t len)
> +{
> +	struct tls_dhe_params *params;
> +
> +	params =3D l_new(struct tls_dhe_params, 1);
> +	tls->pending.key_xchg_params =3D params;

Why do this assignment here?

> +
> +	if (len < 2)
> +		goto decode_error;
> +
> +	params->prime_len =3D l_get_be16(buf);
> +	if (len < 2 + params->prime_len + 2)
> +		goto decode_error;
> +
> +	params->prime_buf =3D l_memdup(buf + 2, params->prime_len);
> +	buf +=3D 2 + params->prime_len;
> +	len -=3D 2 + params->prime_len;
> +
> +	params->generator_len =3D l_get_be16(buf);
> +	if (len < 2 + params->generator_len + 2)
> +		goto decode_error;
> +
> +	params->generator_buf =3D l_memdup(buf + 2, params->generator_len);;
> +	buf +=3D 2 + params->generator_len;
> +	len -=3D 2 + params->generator_len;
> +
> +	params->public_len =3D l_get_be16(buf);
> +	if (len < 2 + params->public_len)
> +		goto decode_error;
> +
> +	params->public_buf =3D buf + 2;
> +	buf +=3D 2 + params->public_len;
> +	len -=3D 2 + params->public_len;
> +
> +	/*
> +	 * Validate the values received.  Without RFC 7919 we basically have
> +	 * to blindly accept the provided prime value.  We have no way to
> +	 * confirm that it's actually prime or that it's a "safe prime" or
> +	 * that it forms a group without small sub-groups.  There's also no
> +	 * way to whitelist all valid values.  But we do a basic sanity
> +	 * check and require it to be 1024-bit or longer (see weakdh.org),
> +	 * might need to move to 2048 bits actually.
> +	 */
> +
> +	if (params->prime_len > TLS_DHE_MAX_SIZE ||
> +			params->generator_len > params->prime_len) {
> +		TLS_DISCONNECT(TLS_ALERT_HANDSHAKE_FAIL, 0,
> +				"Server DH prime modulus or generator "
> +				"too long");
> +		return;
> +	}
> +
> +	if (params->prime_len < 128 || params->prime_buf[0] =3D=3D 0x00 ||
> +			!(params->prime_buf[params->prime_len - 1] & 1)) {
> +		TLS_DISCONNECT(TLS_ALERT_HANDSHAKE_FAIL, 0,
> +				"Server DH prime modulus invalid");
> +		return;
> +	}
> +
> +	/*
> +	 * RFC 7919 Section 3.0:
> +	 * "the client MUST verify that dh_Ys is in the range
> +	 * 1 < dh_Ys < dh_p - 1.  If dh_Ys is not in this range, the client
> +	 * MUST terminate the connection with a fatal handshake_failure(40)
> +	 * alert."
> +	 */
> +	if (params->public_len > params->prime_len ||
> +			!l_key_validate_dh_payload(params->public_buf,
> +							params->public_len,
> +							params->prime_buf,
> +							params->prime_len)) {

So can we rely on the kernel to do this part for us?

> +		TLS_DISCONNECT(TLS_ALERT_HANDSHAKE_FAIL, 0,
> +				"Server DH public value invalid");
> +		return;
> +	}
> +
> +	if (!tls_create_dhe_keys(tls))
> +		return;
> +
> +	if (!tls->pending.cipher_suite->key_xchg->verify(tls, buf, len,
> +						tls_get_server_dh_params_hash))
> +		return;
> +
> +	TLS_SET_STATE(TLS_HANDSHAKE_WAIT_HELLO_DONE);
> +	return;
> +
> +decode_error:
> +	TLS_DISCONNECT(TLS_ALERT_DECODE_ERROR, 0,
> +			"ServerKeyExchange decode error");
> +}
> +

Regards,
-Denis

--===============3183978400003533442==--

