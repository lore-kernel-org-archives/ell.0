Content-Type: multipart/mixed; boundary="===============4794485417502603927=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v3 1/4] ecc: add API's to support EAP-PWD
Date: Thu, 10 Jan 2019 12:53:00 -0600
Message-ID: <554e4401-8418-25c2-46a0-f7e4a8573055@gmail.com>
In-Reply-To: <20190110185316.27969-1-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4794485417502603927==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

On 01/10/2019 12:53 PM, James Prestwood wrote:
> EAP-PWD requires the following ECC functionality
>   - Point multiplication
>   - Point addition
>   - Point inverse
>   - Scalar addition
> ---
>   ell/ecc.c | 53 +++++++++++++++++++++++++++++++++++++++++++++++++++++
>   ell/ecc.h | 14 ++++++++++++++
>   2 files changed, 67 insertions(+)
> =


<snip>

> +
> +LIB_EXPORT struct l_ecc_scalar *l_ecc_curve_get_order(
> +						const struct l_ecc_curve *curve)
> +{
> +	return _ecc_constant_new(curve, (void *) curve->n, curve->ndigits * 8);

I took out this cast.

> +}
> +

Regards,
-Denis

--===============4794485417502603927==--

