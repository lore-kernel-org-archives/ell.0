Content-Type: multipart/mixed; boundary="===============5222481438343091281=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 5/8] key: Add l_key_validate_dh_payload
Date: Tue, 08 Jan 2019 21:19:11 -0600
Message-ID: <1a99f556-b8cd-2706-fe7a-8e1e9048d9e8@gmail.com>
In-Reply-To: <20190108042951.21914-5-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5222481438343091281==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 01/07/2019 10:29 PM, Andrew Zaborowski wrote:
> Add a function to validate public values received from the DH peer
> against the minimum and maximum values depending on the group's
> prime modulus.  This is only necessary ~temporarily as the kernel
> *should* be validating the public value in the keyctl operation,
> however due to the shape of the syscall keyctl API it can't do that
> now so fixing it is not easy and may take a while.  We also can't
> do this easily inside l_key_compute_dh_secret because we don't have
> the prime's raw value there.  We could perhaps do that if we created
> a new "DH group" type (simliar to l_ecc_curve for ECDH) and made the
> API more like the ECDH API.
> =

> Additionally even after that is fixed in the kernel the additional
> check can't hurt and lets user code report a more specific error
> because the user code can only assume "internal error" when
> l_key_compute_dh_secret fails.
> ---
>   ell/ell.sym |  1 +
>   ell/key.c   | 48 ++++++++++++++++++++++++++++++++++++++++++++++++
>   ell/key.h   |  3 +++
>   3 files changed, 52 insertions(+)
> =


<snip>

> +/*
> + * Validate that @payload is within range for a private and public key f=
or
> + * a DH computation in the finite field group defined by modulus @prime_=
buf,
> + * both numbers stored as big-endian integers.  We require a key in the
> + * [2, prime - 2] (inclusive) interval.  PKCS #3 does not exclude 1 as a
> + * private key but other specs do.
> + */
> +LIB_EXPORT bool l_key_validate_dh_payload(const void *payload, size_t le=
n,
> +				const void *prime_buf, size_t prime_len)
> +{
> +	static const uint8_t one[] =3D { 1 };
> +	uint8_t prime_1[prime_len];
> +	unsigned int pos =3D prime_len;
> +
> +	memcpy(prime_1, prime_buf, prime_len);
> +
> +	/* Produce prime - 1 for the payload < prime - 1 check */
> +	while (pos && !prime_1[--pos]--);
A prime is by definition odd, so isn't it sufficient to simply mask off =

the least significant bit instead of hand-coding a big-endian bignum =

subtract 1 operation?  And seriously, my brain hurts from looking at this...

> +
> +	if (be_bignum_compare(payload, len, one, 1) <=3D 0)
> +		return false;
> +
> +	if (be_bignum_compare(payload, len, prime_1, prime_len) >=3D 0)
> +		return false;
> +
> +	return true;
> +}
> +

Regards,
-Denis

--===============5222481438343091281==--

