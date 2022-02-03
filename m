Content-Type: multipart/mixed; boundary="===============8163304018606357978=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH] ecc: make l_ecc_point_from_data const time (for
 compressed points)
Date: Thu, 03 Feb 2022 10:06:30 -0600
Message-ID: <62af0698-a957-3d5d-844c-8d1af295ab38@gmail.com>
In-Reply-To: 20220112224055.1308675-1-prestwoj@gmail.com

--===============8163304018606357978==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

On 1/12/22 16:40, James Prestwood wrote:
> This only alters the two compressed point types as there isn't a security
> reason to make the function const time for compliant/full point data as
> these are never used in conjunction with compressed points.
> =

> The timing difference came down mainly to the conditional _vli_mod_sub ca=
ll
> which was only called depending on the first bit of p->y. More subtly the
> check differered between BIT0 and BIT1 by a '!' operation which would res=
ult
> in an additional instruction.
> =

> This patch addresses the '!' operation by checking if the subtraction is
> needed and considering both compressed types in that logic.
> =

> For the subtraction, it is now done unconditionally and the result is sto=
red
> in a temporary variable. Then l_secure_select is used to copy the data to
> p->y, or back into the temporary variable depending on if 'need_sub' eval=
uated
> to true.
> ---
>   ell/ecc.c | 20 ++++++++++----------
>   1 file changed, 10 insertions(+), 10 deletions(-)
> =


Applied, thanks.

Regards,
-Denis

--===============8163304018606357978==--

