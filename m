Content-Type: multipart/mixed; boundary="===============0008036678931868008=="
MIME-Version: 1.0
From: Gix, Brian <brian.gix@intel.com>
Subject: Re: [PATCH] cert: Fix warning of possible uninitialized var
Date: Mon, 18 Jan 2021 18:24:38 +0000
Message-ID: <6a7b320329c66f04246982ad2470b44d370412d4.camel@intel.com>
In-Reply-To: <df2ca0efff5133af5775b048352c87bf4780d932.camel@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0008036678931868008==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Sat, 2021-01-16 at 07:28 +0000, Stotland, Inga wrote:
> On Thu, 2021-01-14 at 23:53 +0100, Andrew Zaborowski wrote:
> > On Thu, 14 Jan 2021 at 22:35, Denis Kenzior <
> >  denkenz(a)gmail.com
> >  > wrote:
> > > On 1/14/21 3:16 PM, Brian Gix wrote:
> > > > ell/cert-crypto.c: In function =E2=80=98cert_pkcs12_pbkdf=E2=80=99:
> > > > ell/cert-crypto.c:244:3: error: =E2=80=98bmpstring=E2=80=99 may be =
used uninitialized in this function [-Werror=3Dmaybe-
> > > > uninitialized]
> > > >    244 |   explicit_bzero(bmpstring, passwd_len);
> > > >        |   ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> > > =

> > > What compiler are you seeing this on?
> =

> Not sure which version of the compiler Brian is using, but I encounter th=
is issue with:
> gcc (GCC) 10.2.1 20201125 (Red Hat 10.2.1-9)
> =

> > > > ---
> > > >   ell/cert-crypto.c | 2 +-
> > > >   1 file changed, 1 insertion(+), 1 deletion(-)
> > > > =

> > > > diff --git a/ell/cert-crypto.c b/ell/cert-crypto.c
> > > > index 6eb4e14..b3d3000 100644
> > > > --- a/ell/cert-crypto.c
> > > > +++ b/ell/cert-crypto.c
> > > > @@ -194,7 +194,7 @@ uint8_t *cert_pkcs12_pbkdf(const char *password,
> > > >   {
> > > >       /* All lengths in bytes instead of bits */
> > > >       size_t passwd_len =3D password ? 2 * strlen(password) + 2 : 0;
> > > > -     uint8_t *bmpstring;
> > > > +     uint8_t *bmpstring =3D NULL;
> > > =

> > > So generally I don't like this type of fix because it just hides prob=
lems.  The
> > > issues with bmpstring use seem to be a bit more complex than that.
> > > =

> > > >       /* Documented as v(ceiling(s/v)), usually will just equal v */
> > > >       unsigned int s_len =3D (salt_len + hash->v - 1) & ~(hash->v -=
 1);
> > > >       /* Documented as p(ceiling(s/p)), usually will just equal v */
> > > > =

> > > =

> > > Andrew:
> > > =

> > > Why is p_len initialized to be non-zero.  In particular, this block:
> > > =

> > >          for (j =3D passwd_len; j < p_len; j +=3D passwd_len, ptr +=
=3D passwd_len)
> > >                  memcpy(ptr, bmpstring, passwd_len);
> > > =

> > > would seem to copy from an uninitialized bmpstring even if password i=
s NULL.
> > =

> > It's not very obvious but p_len and passwd_len are both going to be 0
> > if password is NULL.  p_len becomes (v - 1) & ~(v - 1), I can see that
> > it's hard for the compiler to notice that.
> > =

> > Brian, can you check if perhaps initializing p_len this way fixes it:
> > =

> > unsigned int p_len =3D password ? (passwd_len + hash->v - 1) & ~(hash->=
v - 1) : 0;
> =

> This change still does not fix the compiler problem.
> =

> However, the warning disappears if we move "for" loop inside the "if" cla=
use that immediately follows.
> =

> The way I see it, the for loop is not going to be executed if p_len is ze=
ro anyway and this
> chage appears to be safe since the comparisons are perfrmed on unsigned i=
ntegers.
> =

> -       for (j =3D passwd_len; j < p_len; j +=3D passwd_len, ptr +=3D pas=
swd_len)
> -               memcpy(ptr, bmpstring, passwd_len);
>  =

>         if (p_len) {
> +               for (j =3D passwd_len; j < p_len; j +=3D passwd_len, ptr =
+=3D passwd_len)
> +                       memcpy(ptr, bmpstring, passwd_len);
>                 memcpy(ptr, bmpstring, p_len + passwd_len - j);
> =


This does *not* fix the problen on "gcc (GCC) 9.3.1 20200408" unless *combi=
ned* with the change from Andrew:
	unsigned int p_len =3D password ? (passwd_len + hash->v - 1) & ~(hash->v -=
 1) : 0;

> =

> > Or the part that uses bmpstring can be made conditional on password as =
well.
> > =

> > Best regard
> > _______________________________________________
> > ell mailing list -- =

> >  ell(a)lists.01.org
> > =

> > To unsubscribe send an email to =

> >  ell-leave(a)lists.01.org
> >=20

--===============0008036678931868008==--

