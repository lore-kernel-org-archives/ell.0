Content-Type: multipart/mixed; boundary="===============8175657549157260102=="
MIME-Version: 1.0
From: James Prestwood <james.prestwood@linux.intel.com>
Subject: Re: [PATCH 2/2] ecc: added API's to support SAE
Date: Thu, 10 Jan 2019 08:53:24 -0800
Message-ID: <77ea33287e347cf08a636227f0c5c802981e75a1.camel@linux.intel.com>
In-Reply-To: <CAOq732LL_Y1KT2w6-ASsWCoxgTS-mE15JgSmvsoxhMvQgVH14Q@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8175657549157260102==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Thu, 2019-01-10 at 02:35 +0100, Andrew Zaborowski wrote:
> Hi James,
> =

> On Wed, 9 Jan 2019 at 18:05, James Prestwood
> <james.prestwood@linux.intel.com> wrote:
> > =

> > The functionality require was:
> >  - Scalar multiplication
> >  - Find a scalars legendre symbol
> >  - Sum the curve equations X side
> >  - Get prime from curve (needed for input to SAE KDF)
> >  - Check if scalars/points are equal
> > ---
> >  ell/ecc.c | 59
> > +++++++++++++++++++++++++++++++++++++++++++++++++++++++
> >  ell/ecc.h | 12 +++++++++++
> >  2 files changed, 71 insertions(+)
> > =

> > diff --git a/ell/ecc.c b/ell/ecc.c
> > index c7e7089..b6b2cd6 100644
> > --- a/ell/ecc.c
> > +++ b/ell/ecc.c
> > @@ -485,3 +485,62 @@ LIB_EXPORT bool l_ecc_point_inverse(struct
> > l_ecc_point *p)
> > =

> >         return true;
> >  }
> > +
> > +LIB_EXPORT bool l_ecc_scalar_multiply(struct l_ecc_scalar *ret,
> > +                                       struct l_ecc_scalar *a,
> > +                                       struct l_ecc_scalar *b)
> > +{
> > +       if (unlikely(!ret) || unlikely(!a) || unlikely(!b))
> > +               return false;
> > +
> > +       _vli_mod_mult_fast(ret->c, a->c, b->c, a->curve->p, a-
> > >curve->ndigits);
> > +
> > +       return true;
> > +}
> > +
> > +LIB_EXPORT int l_ecc_scalar_legendre(struct l_ecc_scalar *value)
> > +{
> > +       if (unlikely(!value))
> > +               return -1;
> > +
> > +       return _vli_legendre(value->c, value->curve->p, value-
> > >curve->ndigits);
> > +}
> > +
> > +LIB_EXPORT bool l_ecc_scalar_sum_x(struct l_ecc_scalar *ret,
> > +                                       struct l_ecc_scalar *x)
> > +{
> > +       if (unlikely(!ret) || unlikely(!x))
> > +               return false;
> > +
> > +       ecc_compute_y_sqr(x->curve, ret->c, x->c);
> > +
> > +       return true;
> > +}
> > +
> > +LIB_EXPORT struct l_ecc_scalar *l_ecc_curve_get_prime(
> > +                                               const struct
> > l_ecc_curve *curve)
> > +{
> > +       if (unlikely(!curve))
> > +               return NULL;
> > +
> > +       return _ecc_constant_new(curve, (void *) curve->p, curve-
> > >ndigits * 8);
> > +}
> > +
> > +LIB_EXPORT bool l_ecc_scalars_are_equal(struct l_ecc_scalar *a,
> > +                                               struct l_ecc_scalar
> > *b)
> > +{
> > +       if (unlikely(!a) || unlikely(!b))
> > +               return false;
> > +
> > +       return (memcmp(a->c, b->c, a->curve->ndigits * 8) =3D=3D 0);
> > +}
> > +
> > +LIB_EXPORT bool l_ecc_points_are_equal(struct l_ecc_point *a,
> > +                                               struct l_ecc_point
> > *b)
> > +{
> > +       if (unlikely(!a) || unlikely(!b))
> > +               return false;
> > +
> > +       return ((memcmp(a->x, b->x, a->curve->ndigits * 8) =3D=3D 0) &&
> > +                       (memcmp(a->y, b->y, a->curve->ndigits *
> > 8)));
> =

> Seems the second memcmp is missing the =3D=3D 0.  I don't have anything
> to
> say about the rest of the changes although I think unlikely(a || b)
> in
> theory should be as good as unlikely(a) || unlikely(b).

Good catch. Ill move all the checks into one unlikely as well. Thanks
> =

> Best regards


--===============8175657549157260102==--

