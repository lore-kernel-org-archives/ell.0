Content-Type: multipart/mixed; boundary="===============7135816090123847732=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: Re: [PATCH 06/11] icmp6: Parse extra options
Date: Tue, 19 Apr 2022 13:37:42 +0200
Message-ID: <CAOq732+1TU1_79BcjR-+Gw-q8tsqu-q8FgY4yGDDoODCUY5qfA@mail.gmail.com>
In-Reply-To: f06829ab-4001-2202-523a-1c6ce45dd6b0@gmail.com

--===============7135816090123847732==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On Mon, 18 Apr 2022 at 21:39, Denis Kenzior <denkenz(a)gmail.com> wrote:
> On 4/11/22 09:20, Andrew Zaborowski wrote:
> > +                     if (((opts[3] >> 3) & 3) =3D=3D 2)
> > +                             break;
>
> Can we use bit_field() from useful.h instead?

Sure.

>
> > +
> > +                     /*
> > +                      * RFC 4191 Section 3.1:
> > +                      * "The Router Preference and Lifetime values in =
a ::/0
> > +                      * Route Information Option override the preferen=
ce and
> > +                      * lifetime values in the Router Advertisement he=
ader."
> > +                      *
> > +                      * Don't count ::/0 routes.
> > +                      */
> > +                     if (opts[2] =3D=3D 0)
> > +                             break;
> > +
> > +                     n_routes +=3D 1;
> >                       break;
> >               }
> >
> > @@ -739,6 +780,10 @@ struct l_icmp6_router *_icmp6_router_parse(const s=
truct nd_router_advert *ra,
> >               r->other =3D true;
> >
> >       r->pref =3D (ra->nd_ra_flags_reserved >> 3) & 0x3;
> > +     /*
> > +      * "If the Reserved (10) value is received, the receiver MUST
> > +      * treat the value as if it were (00).
> > +      */
>
> This might warrant a separate commit

Ok.

>
> >       if (r->pref =3D=3D 0x2) /* If invalid, reset to medium */
> >               r->pref =3D 0;
> >
>
> <snip>
>
> > @@ -765,17 +810,69 @@ struct l_icmp6_router *_icmp6_router_parse(const =
struct nd_router_advert *ra,
> >                       break;
> >               case ND_OPT_PREFIX_INFORMATION:
> >               {
> > -                     struct route_info *i =3D &r->prefixes[n_prefixes];
> > +                     struct route_info *i =3D &r->routes[n_routes];
> >
> >                       if (!(opts[3] & ND_OPT_PI_FLAG_ONLINK))
> >                               break;
> >
> >                       i->prefix_len =3D opts[2];
> > +                     i->onlink =3D true;
> >                       i->valid_lifetime =3D l_get_be32(opts + 4);
> >                       i->preferred_lifetime =3D l_get_be32(opts + 8);
> >                       memcpy(i->address, opts + 16, 16);
> >
> > -                     n_prefixes +=3D 1;
> > +                     n_routes +=3D 1;
> > +                     break;
> > +             }
> > +             case ND_OPT_RTR_ADV_INTERVAL:
> > +                     if (l < 8)
> > +                             break;
> > +
> > +                     r->max_rtr_adv_interval_ms =3D l_get_be32(opts + =
4);
> > +                     break;
> > +             case ND_OPT_ROUTE_INFORMATION:
> > +             {
> > +                     struct route_info *i =3D &r->routes[n_routes++];
> > +
> > +                     if (((opts[3] >> 3) & 3) =3D=3D 2)
>
> bit_field()?
>
> Also, you access this value at least twice below, so maybe just use a var=
iable
> and assign it.

Ok.

Best regards
--===============7135816090123847732==--

