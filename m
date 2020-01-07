Content-Type: multipart/mixed; boundary="===============5617189636659179548=="
MIME-Version: 1.0
From: Gix, Brian <brian.gix@intel.com>
Subject: Re: Warn-to-error on -Werror=cast-align
Date: Tue, 07 Jan 2020 00:18:57 +0000
Message-ID: <16492c82999ed2dcc5a03e9af15137970edc3faa.camel@intel.com>
In-Reply-To: <20191230074402.hdm63equduouznjw@kynes>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5617189636659179548==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Marcel && Denis,

On Mon, 2019-12-30 at 08:44 +0100, Micha=C5=82 Lowas-Rzechonek wrote:
> On 12/29, Gix, Brian wrote:
> > (...)
> > ell/util.h:40:3: error: cast increases required alignment of target typ=
e [-Werror=3Dcast-align]
> >    (type *)((char *) __mptr - offsetof(type, member)); \
> >    ^
> > ell/dbus.c:582:3: note: in expansion of macro =E2=80=98l_container_of=
=E2=80=99
> >    l_container_of(dbus, struct l_dbus_classic, super);
> >    ^~~~~~~~~~~~~~
> =

> FWIW, I've encountered that on iMX.6 as well. I've fixed that with:
> =

> diff --git a/ell/util.h b/ell/util.h
> index 4f20ef0..fe7c7e2 100644
> --- a/ell/util.h
> +++ b/ell/util.h
> @@ -37,7 +37,7 @@ extern "C" {
>  =

>  #define l_container_of(ptr, type, member) ({                           \
>                 const __typeof__(((type *) 0)->member) *__mptr =3D (ptr);=
 \
> -               (type *)((char *) __mptr - offsetof(type, member));     \
> +               (type *)(void *)((char *) __mptr - offsetof(type, member)=
);     \
>         })


Any opinion on this change?  It is causing us build fails on some platforms=
 (including Raspberry PI 4).

I have not yet had a chance to run the battery of unit tests with this chan=
ge in ELL, and am not even really
sure of the if this warning means that there could be some unforseen impact.

Otherwise, perhaps we should just create an ELL patch that makes clears up =
these warnings (Micha=C5=82?).

If this is done, we should make sure it gets all of them, and not just the =
dbus.c instances.


>  =

>  #define likely(x)   __builtin_expect(!!(x), 1)
> =

> But I'm not sure this is correct...
> =

> regards

--===============5617189636659179548==--

