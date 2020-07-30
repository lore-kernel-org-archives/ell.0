Content-Type: multipart/mixed; boundary="===============6683391822913372001=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] Fix side channel leak in l_ecc_scalar_new
Date: Thu, 30 Jul 2020 10:30:35 -0500
Message-ID: <2a23cb92-0a31-1b3f-3ee5-715ab86914a0@gmail.com>
In-Reply-To: <20200730092507.803294-1-daniel.de-almeida-braga@irisa.fr>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6683391822913372001==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Daniel,

On 7/30/20 4:25 AM, Daniel DE ALMEIDA BRAGA wrote:
> A secure (constant time and memory access) memory comparaison function
> is needed to handle secret data. Namely, l_ecc_scalar tends to be
> instantiated with secret, and _vli_cmp leak "how much" different it is
> from the prime p.
> The secure memcmp is defined in ell/util.h to be available to projects
> using ELL.
> ---
>   ell/ecc.c  |   2 +-
>   ell/util.h | 120 +++++++++++++++++++++++++++++++++++++++++++++++++++++
>   2 files changed, 121 insertions(+), 1 deletion(-)
> =


Looks good, a couple of small things:

> diff --git a/ell/ecc.c b/ell/ecc.c
> index 250f7e8..a5ab556 100644
> --- a/ell/ecc.c
> +++ b/ell/ecc.c
> @@ -603,7 +603,7 @@ LIB_EXPORT struct l_ecc_scalar *l_ecc_scalar_new(
>   	_ecc_be2native(c->c, buf, curve->ndigits);
>   =

>   	if (!vli_is_zero_or_one(c->c, curve->ndigits) &&
> -				_vli_cmp(c->c, curve->n, curve->ndigits) < 0)
> +				l_secure_memcmp_64(curve->n, c->c, curve->ndigits) =3D=3D 1)
>   		return c;
>   =

>   	l_ecc_scalar_free(c);
> diff --git a/ell/util.h b/ell/util.h
> index 6e88505..501b03f 100644
> --- a/ell/util.h
> +++ b/ell/util.h
> @@ -315,6 +315,126 @@ const char *l_util_get_debugfs_path(void);
>          while (__result =3D=3D -1L && errno =3D=3D EINTR);  \
>          __result; }))
>   =

> +/*
> + * Taken from https://github.com/chmike/cst_time_memcmp, adding a volati=
le to
> + * ensure the compiler does not try to optimize the constant time behavi=
or.
> + * The code has been modified to add comments and project specific code
> + * styling.
> + * This specific piece of code is subjet to the following copyright:

s/subjet/subject

> + *
> + * The MIT License (MIT)
> + *
> + * Copyright (c) 2015 Christophe Meessen
> + *
> + * Permission is hereby granted, free of charge, to any person obtaining=
 a copy
> + * of this software and associated documentation files (the "Software"),=
 to
> + * deal in the Software without restriction, including without limitatio=
n the
> + * rights to use, copy, modify, merge, publish, distribute, sublicense, =
and/or
> + * sell copies of the Software, and to permit persons to whom the Softwa=
re is
> + * furnished to do so, subject to the following conditions:
> + *
> + * The above copyright notice and this permission notice shall be includ=
ed in
> + * all copies or substantial portions of the Software.
> + *
> + * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRE=
SS OR
> + * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILI=
TY,
> + * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHA=
LL THE
> + * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
> + * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISI=
NG
> + * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER D=
EALINGS
> + * IN THE SOFTWARE.
> + *
> + * This function performs a secure memory comparaison of two buffers of =
size
> + * bytes, representing an integer (byte order is big endian). It returns
> + * -1, 0 or 1 if a < b, a =3D=3D b or a > b respectivelly.
> + */
> +static inline int8_t l_secure_mem_cmp(const uint8_t *a, const uint8_t *b,

can we name this l_secure_memcmp?  Also, shouldn't a and b be const void *?

> +					size_t size)

any particular reason to use int8 here?  memcmp returns an int and offers n=
o =

particular contract on the values that can be returned...

> +{
> +	const volatile uint8_t *aa =3D a;
> +	const volatile uint8_t *bb =3D b;
> +	int res =3D 0, diff, mask;
> +	/*
> +	 * We will compare all bytes, starting with the less significant. When =
we
> +	 * find a non-zero difference, we update the result accordingly.
> +	 */
> +	if (size > 0) {
> +		do {
> +			--size;
> +			diff =3D aa[size] - bb[size];
> +			/*
> +			 * The following couple of lines can be summarized as a constant
> +			 * time/memory access version of:
> +			 * 		if (diff !=3D 0) res =3D diff;
> +			 *
> +			 * From the previous operation, we know that diff is in [-255, 255]
> +			 * The following figure show the possible value of mask, based on
> +			 * different cases of diff:
> +			 *
> +			 *    diff |   diff-1   |   ~diff    | ((diff-1) & ~diff) |  mask
> +			 *  -------|------------|------------|--------------------|------
> +			 *    < 0  | 0xFFFFFFXX | 0x000000YY |     0x000000ZZ     |   0
> +			 *   =3D=3D 0  | 0xFFFFFFFF | 0xFFFFFFFF |     0xFFFFFFFF     | 0xF..F
> +			 *    > 0  | 0x000000XX | 0xFFFFFFYY |     0x000000ZZ     |   0
> +			 *
> +			 * Hence, the mask allows to keep res when diff =3D=3D 0, and to set
> +			 * res to diff otherwise.
> +			 */
> +			mask =3D (((diff - 1) & ~diff) >> 8);
> +			res =3D (res & mask) | diff;
> +		} while (size !=3D 0);
> +	}
> +
> +	/*
> +	 * We want the resut to fit in one byte, being 0xFF, 0 or 0x01.
> +	 * Since the function return a single byte, the result of the sum is
> +	 * truncated (only the last byte is returned).
> +	 *
> +	 *         res        | (res - 1) >> 8 |  res >> 8  |   output
> +	 * -------------------|----------------|------------|-----------
> +	 *  0xFFFFFFXX (< 0)  |   0x00FFFFFF   | 0x00FFFFFF | 0x01FFFFFF
> +	 *  0x00000000 (=3D=3D 0) |   0x00FFFFFF   | 0x00000000 | 0x01000000
> +	 *  0x000000XX (> 0)  |   0x00000000   | 0x00000000 | 0x00000001
> +	 *
> +	 */
> +	return ((res - 1) >> 8) + (res >> 8) + 1;

Is this needed if we return an int?  You could change =

util_secure_fill_with_msb() to use a uint32_t instead of uint8.  Then this =

re-scaling step is unnecessary, right?

> +}
> +
> +/*
> + * Performs a secure memory comparaison of two uint64_t buffers of size =
bytes

s/comparaison/comparison

> + * representing an integer. Blobs are ordered in little endian. It retur=
ns
> + * -1, 0 or 1 if a < b, a =3D=3D b or a > b respectivelly.
> + */
> +static inline uint8_t l_secure_memcmp_64(const uint64_t *a, const uint64=
_t *b,
> +					size_t size)

This function is only useful for ecc and related parts.  In fact we tried v=
ery =

hard to hide the ecc implementation details (like the uint64_t arrays =

representing the points) in data structures that are opaque to the outside =

world.  So there's really no reason to expose this in util.h.

I would move this to ecc.c directly or perhaps ecc-private.h if you foresee =

needing to replace some / all instances of _vli_cmp in ell/ecc-external.c w=
ith =

the secure version.

> +{
> +	uint8_t *aa_8, *bb_8;
> +	uint64_t aa_64, bb_64;
> +
> +	uint8_t res =3D 0, mask;
> +
> +	int i =3D 0;
> +
> +	if (size) {
> +		/*
> +		 * Arrays store blobs in LE, we will process each blob as a byte array
> +		 * of size 8 using l_secure_mem_cmp. We need to make sure to feed a BE
> +		 * byte array to avoid unexpected behavior on different architectures.
> +		 */
> +		do {
> +			aa_64 =3D L_CPU_TO_BE64(a[i]);
> +			bb_64 =3D L_CPU_TO_BE64(b[i]);
> +			aa_8 =3D (uint8_t *) &aa_64;
> +			bb_8 =3D (uint8_t *) &bb_64;
> +			mask =3D l_secure_mem_cmp(aa_8, bb_8, 8);

if l_secure_memcmp takes void, the aa_8 and bb_8 variables become unnecessa=
ry =

and you can simply pass &aa_64, &bb_64 directly.

> +			res =3D (mask & res) | mask;
> +			i++;
> +		} while(i !=3D size);
> +	}
> +
> +	return res;
> +}
> +
>   #ifdef __cplusplus
>   }
>   #endif
> =


Regards,
-Denis
--===============6683391822913372001==--

