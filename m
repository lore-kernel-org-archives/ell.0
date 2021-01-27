Content-Type: multipart/mixed; boundary="===============0351076856321325475=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] dhcp-util: Fix warning on signed pointer systems
Date: Wed, 27 Jan 2021 12:22:37 -0600
Message-ID: <b8316add-a72a-3c38-a424-06b80c36a739@gmail.com>
In-Reply-To: <20210127170910.1514394-1-brian.gix@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0351076856321325475==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Brian,

On 1/27/21 11:09 AM, Brian Gix wrote:
> Some systems treat pointers as signed values, causing the following
> error:

That doesn't seem right.  The issue is that pointer arithmetic is a signed =
type =

and the macro assumes that next is unsigned, so the temporary resulting in =
the =

operation left of '>' gets promoted to unsigned type.  This breaks if a sig=
ned =

type is passed in as 'next' argument of the macro.  In theory this should =

already be fixed by 3d096702811d ("dhcp-util: fix GCC 10 warning").

There may be systems that have ptrdiff_t be a non-standard type, so a reall=
y =

paranoid fix would be an explicit cast, as you have it here...

> =

> ell/dhcp-util.c: In function =E2=80=98_dhcp_message_builder_append=E2=80=
=99:
> ell/dhcp-util.c:55:49: error: comparison of integer expressions of differ=
ent signedness: =E2=80=98int=E2=80=99 and =E2=80=98unsigned int=E2=80=99 [-=
Werror=3Dsign-compare]
>     55 |  if ((builder)->pos - (builder)->start + (next) > (builder)->max=
) \
>        |                                                 ^
> ell/dhcp-util.c:65:3: note: in expansion of macro =E2=80=98LEN_CHECK=E2=
=80=99
>     65 |   LEN_CHECK(builder, 1);
>        |   ^~~~~~~~~
> ---
>   ell/dhcp-util.c | 3 ++-
>   1 file changed, 2 insertions(+), 1 deletion(-)
>

Regards,
-Denis

--===============0351076856321325475==--

