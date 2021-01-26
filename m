Content-Type: multipart/mixed; boundary="===============2502957005204968818=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] dhcp-util: fix GCC 10 warning
Date: Tue, 26 Jan 2021 15:41:13 -0600
Message-ID: <954f27a0-81c4-9270-e590-7d5a8843da2f@gmail.com>
In-Reply-To: <20210126212005.885653-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2502957005204968818==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

On 1/26/21 3:20 PM, James Prestwood wrote:
> LEN_CHECK was being fed a hardcoded '1' which was being
> treated as an int. This led GCC 10.2.1 to emit a warning about
> comparison between signed/unsigned integers because the
> builder->max member is unsigned:
> =

> ell/dhcp-util.c: In function =E2=80=98_dhcp_message_builder_append=E2=80=
=99:
> ell/dhcp-util.c:55:49: error: comparison of integer expressions of differ=
ent
> 		signedness: =E2=80=98int=E2=80=99 and =E2=80=98unsigned int=E2=80=99 [-=
Werror=3Dsign-compare]
>     55 |  if ((builder)->pos - (builder)->start + (next) > (builder)->max=
) \
>        |                                                 ^
> ell/dhcp-util.c:65:3: note: in expansion of macro =E2=80=98LEN_CHECK=E2=
=80=99
>     65 |   LEN_CHECK(builder, 1);
>        |   ^~~~~~~~~
> cc1: all warnings being treated as errors
> =

> To fix this explicitly use '1U' so the compiler treats it
> as unsigned.
> ---
>   ell/dhcp-util.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
> =


Applied, thanks.

Regards,
-Denis

--===============2502957005204968818==--

