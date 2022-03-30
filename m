Content-Type: multipart/mixed; boundary="===============3974298677372080969=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH] rtnl: change l_rtnl_address expire times to uint64_t
Date: Wed, 30 Mar 2022 14:23:10 -0500
Message-ID: <ff5ddf31-fc31-b697-6ea3-1efd0ac48a1c@gmail.com>
In-Reply-To: 20220330192321.1871376-1-prestwoj@gmail.com

--===============3974298677372080969==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

On 3/30/22 14:23, James Prestwood wrote:
> These are calculated from uint64_t values so they also should be
> uint64_t sizes.
> ---
>   ell/rtnl.c | 4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)

Applied, thanks.

Regards,
-Denis

--===============3974298677372080969==--

