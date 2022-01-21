Content-Type: multipart/mixed; boundary="===============4184432864168218034=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH] ecc: enforce strict length with l_ecc_point_from_data
Date: Fri, 21 Jan 2022 10:51:51 -0600
Message-ID: <769ff176-449d-ff4c-d591-5a74e9e8024b@gmail.com>
In-Reply-To: 20220121164532.2528621-1-prestwoj@gmail.com

--===============4184432864168218034==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

On 1/21/22 10:45, James Prestwood wrote:
> This add some extra convenience to users of l_ecc_point_from_data
> allowing the exact length to be verified in addition to creating
> the point.
> ---
>   ell/ecc.c | 10 +++++-----
>   1 file changed, 5 insertions(+), 5 deletions(-)
> =


This seems to break test-sae?

Regards,
-Denis

--===============4184432864168218034==--

