Content-Type: multipart/mixed; boundary="===============1601265371160050386=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v3 2/4] ecc: added API's to support SAE
Date: Thu, 10 Jan 2019 13:32:16 -0600
Message-ID: <7bd1b2c2-8a7d-9f88-2d5f-c258dd81a577@gmail.com>
In-Reply-To: <20190110185316.27969-2-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1601265371160050386==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

On 01/10/2019 12:53 PM, James Prestwood wrote:
> The functionality require was:
>   - Scalar multiplication
>   - Find a scalars legendre symbol
>   - Sum the curve equations X side
>   - Get prime from curve (needed for input to SAE KDF)
>   - Check if scalars/points are equal
> ---
>   ell/ecc.c | 61 ++++++++++++++++++++++++++++++++++++++++++++++++++++++-
>   ell/ecc.h | 15 ++++++++++++++
>   2 files changed, 75 insertions(+), 1 deletion(-)
> =


<snip>

> +LIB_EXPORT struct l_ecc_scalar *l_ecc_curve_get_prime(
> +						const struct l_ecc_curve *curve)
> +{
> +	if (unlikely(!curve))
> +		return NULL;
> +
> +	return _ecc_constant_new(curve, (void *) curve->p, curve->ndigits * 8);

I took out this cast and applied this patch.

> +}
> +

Regards,
-Denis

--===============1601265371160050386==--

