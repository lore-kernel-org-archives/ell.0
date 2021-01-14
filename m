Content-Type: multipart/mixed; boundary="===============8274209053966600962=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH] cert: Fix warning of possible uninitialized var
Date: Thu, 14 Jan 2021 23:53:13 +0100
Message-ID: <CAOq732J-5oRBdqQX_TL_vf0hcE2ZPkuBq3K_=8-TkpLJp=mNTA@mail.gmail.com>
In-Reply-To: <73a12eac-a80c-3472-caee-0567a0d19ba0@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8274209053966600962==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Thu, 14 Jan 2021 at 22:35, Denis Kenzior <denkenz@gmail.com> wrote:
> On 1/14/21 3:16 PM, Brian Gix wrote:
> > ell/cert-crypto.c: In function =E2=80=98cert_pkcs12_pbkdf=E2=80=99:
> > ell/cert-crypto.c:244:3: error: =E2=80=98bmpstring=E2=80=99 may be used=
 uninitialized in this function [-Werror=3Dmaybe-uninitialized]
> >    244 |   explicit_bzero(bmpstring, passwd_len);
> >        |   ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
>
> What compiler are you seeing this on?
>
> > ---
> >   ell/cert-crypto.c | 2 +-
> >   1 file changed, 1 insertion(+), 1 deletion(-)
> >
> > diff --git a/ell/cert-crypto.c b/ell/cert-crypto.c
> > index 6eb4e14..b3d3000 100644
> > --- a/ell/cert-crypto.c
> > +++ b/ell/cert-crypto.c
> > @@ -194,7 +194,7 @@ uint8_t *cert_pkcs12_pbkdf(const char *password,
> >   {
> >       /* All lengths in bytes instead of bits */
> >       size_t passwd_len =3D password ? 2 * strlen(password) + 2 : 0;
> > -     uint8_t *bmpstring;
> > +     uint8_t *bmpstring =3D NULL;
>
> So generally I don't like this type of fix because it just hides problems=
.  The
> issues with bmpstring use seem to be a bit more complex than that.
>
> >       /* Documented as v(ceiling(s/v)), usually will just equal v */
> >       unsigned int s_len =3D (salt_len + hash->v - 1) & ~(hash->v - 1);
> >       /* Documented as p(ceiling(s/p)), usually will just equal v */
> >
>
> Andrew:
>
> Why is p_len initialized to be non-zero.  In particular, this block:
>
>          for (j =3D passwd_len; j < p_len; j +=3D passwd_len, ptr +=3D pa=
sswd_len)
>                  memcpy(ptr, bmpstring, passwd_len);
>
> would seem to copy from an uninitialized bmpstring even if password is NU=
LL.

It's not very obvious but p_len and passwd_len are both going to be 0
if password is NULL.  p_len becomes (v - 1) & ~(v - 1), I can see that
it's hard for the compiler to notice that.

Brian, can you check if perhaps initializing p_len this way fixes it:

unsigned int p_len =3D password ? (passwd_len + hash->v - 1) & ~(hash->v - =
1) : 0;

Or the part that uses bmpstring can be made conditional on password as well.

Best regard
--===============8274209053966600962==--

