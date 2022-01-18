Content-Type: multipart/mixed; boundary="===============2944406345321165383=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH] ecc: add l_ecc_point_y_isodd
Date: Tue, 18 Jan 2022 13:53:36 -0600
Message-ID: <e7c11677-c9b6-61c0-d3f0-f7c56d76c9ea@gmail.com>
In-Reply-To: 20220118165605.1968201-1-prestwoj@gmail.com

--===============2944406345321165383==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

On 1/18/22 10:56, James Prestwood wrote:
> This is required to know how a compressed point will be interpreted
> after sending the raw (compressed) X coordiate.
> ---
>   ell/ecc.c   | 5 +++++
>   ell/ecc.h   | 1 +
>   ell/ell.sym | 1 +
>   3 files changed, 7 insertions(+)
> =


Applied, thanks.

Regards,
-Denis

--===============2944406345321165383==--

