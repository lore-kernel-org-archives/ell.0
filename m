Content-Type: multipart/mixed; boundary="===============3404292566214936274=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: Re: [PATCH] dhcp-util: Fix warning on signed pointer systems
Date: Wed, 27 Jan 2021 09:57:26 -0800
Message-ID: <b442b9c79cdb5b31406f0e4f1a9f70b1cf5f32c3.camel@gmail.com>
In-Reply-To: <20210127170910.1514394-1-brian.gix@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3404292566214936274==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Brian,

On Wed, 2021-01-27 at 09:09 -0800, Brian Gix wrote:
> Some systems treat pointers as signed values, causing the following
> error:
> =

> ell/dhcp-util.c: In function =E2=80=98_dhcp_message_builder_append=E2=80=
=99:
> ell/dhcp-util.c:55:49: error: comparison of integer expressions of
> different signedness: =E2=80=98int=E2=80=99 and =E2=80=98unsigned int=E2=
=80=99 [-Werror=3Dsign-compare]
>    55 |  if ((builder)->pos - (builder)->start + (next) > (builder)-
> >max) \
>       |                                                 ^
> ell/dhcp-util.c:65:3: note: in expansion of macro =E2=80=98LEN_CHECK=E2=
=80=99
>    65 |   LEN_CHECK(builder, 1);
>       |   ^~~~~~~~~
> ---
>  ell/dhcp-util.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> =

> diff --git a/ell/dhcp-util.c b/ell/dhcp-util.c
> index 7809e52..feb1168 100644
> --- a/ell/dhcp-util.c
> +++ b/ell/dhcp-util.c
> @@ -52,7 +52,8 @@ static void dhcp_init_header(struct dhcp_message
> *message, uint8_t type)
>  }
>  =

>  #define LEN_CHECK(builder, next) \
> -	if ((builder)->pos - (builder)->start + (next) > (builder)-
> >max) \
> +	if ((unsigned)((builder)->pos - (builder)->start + (next)) > \
> +							(builder)->max) =

> \
>  		return false;
>  =

>  bool _dhcp_message_builder_append(struct dhcp_message_builder
> *builder,

I actually just fixed this (for me at least) just by passing '1U' to
LEN_CHECK so the compiler treats it as unsigned. Looks like its at the
HEAD of ELL, 3d096702. See if this works for you.

Thanks,
James

--===============3404292566214936274==--

