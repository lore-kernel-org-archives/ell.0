Content-Type: multipart/mixed; boundary="===============4483565642371983072=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCHv2] Fix side channel leak in l_ecc_scalar_new
Date: Mon, 03 Aug 2020 14:21:32 -0500
Message-ID: <b6b86dde-e197-285e-75c5-260467ecf111@gmail.com>
In-Reply-To: <20200803090619.62347-1-daniel.de-almeida-braga@irisa.fr>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4483565642371983072==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Daniel,

On 8/3/20 4:06 AM, Daniel DE ALMEIDA BRAGA wrote:
> A secure (constant time and memory access) memory comparaison function
> is needed to handle secret data. Namely, l_ecc_scalar tends to be
> instantiated with secret, and _vli_cmp leak "how much" different it is
> from the prime p.
> The secure memcmp is defined in ell/util.h to be available to projects
> using ELL.
> ---
>   ell/ecc-private.h | 33 +++++++++++++++++++++
>   ell/ecc.c         |  2 +-
>   ell/util.h        | 73 +++++++++++++++++++++++++++++++++++++++++++++++
>   3 files changed, 107 insertions(+), 1 deletion(-)
> =


I tweaked the formatting of the code and comments a bit to make them fit on=
 80 =

character lines.

I also made two trivial changes:

> +static inline int l_secure_memcmp_64(const uint64_t *a, const uint64_t *=
b,
> +					size_t size)

I dropped the l_ prefix here since this is no longer public API.

> +{
> +	uint64_t aa_64, bb_64;
> +
> +	int res =3D 0, mask;
> +
> +	int i =3D 0;

I also changed the type of i to 'size_t' due to the following compiler warn=
ing:

In file included from ell/ecc-external.c:36:
ell/ecc-private.h: In function =E2=80=98secure_memcmp_64=E2=80=99:
ell/ecc-private.h:80:13: error: comparison of integer expressions of differ=
ent =

signedness: =E2=80=98int=E2=80=99 and =E2=80=98size_t=E2=80=99 {aka =E2=80=
=98long unsigned int=E2=80=99} [-Werror=3Dsign-compare]
    80 |   } while(i !=3D size);

Applied, thanks!

Regards,
-Denis
--===============4483565642371983072==--

