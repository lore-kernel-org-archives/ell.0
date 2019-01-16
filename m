Content-Type: multipart/mixed; boundary="===============8587205838734902273=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v2 1/2] ecc: add l_ecc_curve_get_supported_groups
Date: Wed, 16 Jan 2019 10:35:03 -0600
Message-ID: <4341153c-47a1-fbc6-6969-44eed0e7acdf@gmail.com>
In-Reply-To: <20190115224308.6100-1-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8587205838734902273==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

On 01/15/2019 04:43 PM, James Prestwood wrote:
> ---
>   ell/ecc.c   | 18 ++++++++++++++++++
>   ell/ecc.h   |  1 +
>   ell/ell.sym |  1 +
>   3 files changed, 20 insertions(+)
> =

> diff --git a/ell/ecc.c b/ell/ecc.c
> index 053e5fb..b2110df 100644
> --- a/ell/ecc.c
> +++ b/ell/ecc.c
> @@ -90,6 +90,9 @@ static const struct l_ecc_curve *curves[] =3D {
>   	&p384,
>   };
>   =

> +static unsigned int supported_groups[L_ARRAY_SIZE(curves) + 1];
> +static bool first =3D true;
> +

I moved these into the function definition itself to make things a bit =

neater.

Applied, thanks.

Regards,
-Denis


--===============8587205838734902273==--

