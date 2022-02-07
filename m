Content-Type: multipart/mixed; boundary="===============5989921439019509510=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH v3] ecc: make l_ecc_point_from_data fully constant time
Date: Mon, 07 Feb 2022 16:25:00 -0600
Message-ID: <d9127717-5a6e-389a-e0f9-2c2a117f53e2@gmail.com>
In-Reply-To: 20220204203340.326241-1-prestwoj@gmail.com

--===============5989921439019509510==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

On 2/4/22 14:33, James Prestwood wrote:
> This was modified earlier to be constant time but there was one
> minor problem with how 'sub' was determined. That logic could short
> circuit which could alter the timing. The change in timing would be
> extremely small, especially compared to the previous fix making
> _vli_mod_sub() execute always but in any case there would be a small
> difference.
> =

> This patch uses l_secure_select_byte to select either of the two
> subtraction conditions which depend on the point type.
> ---
>   ell/ecc.c | 6 ++----
>   1 file changed, 2 insertions(+), 4 deletions(-)
> =


Applied, thanks.

Regards,
-Denis

--===============5989921439019509510==--

