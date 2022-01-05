Content-Type: multipart/mixed; boundary="===============3181102956281942928=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: Re: [PATCH 1/4] rtnl: Add l_rtnl_route_set_gateway
Date: Wed, 05 Jan 2022 15:20:58 +0100
Message-ID: <CAOq732J-4g7vb2F5xt5pMpkB7pUPM8xkX6oomGZ31PMJd7LX-Q@mail.gmail.com>
In-Reply-To: 492f1eb9-7785-55b2-2479-3c2b88c7b48d@gmail.com

--===============3181102956281942928==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On Mon, 3 Jan 2022 at 19:54, Denis Kenzior <denkenz(a)gmail.com> wrote:
> On 1/3/22 08:18, Andrew Zaborowski wrote:
> > Allow creating prefix routes for off-link prefixes, i.e. ones that
> > should be routed through a gateway.
> > ---
> >   ell/ell.sym |  1 +
> >   ell/rtnl.c  | 16 ++++++++++++++++
> >   ell/rtnl.h  |  1 +
> >   3 files changed, 18 insertions(+)
> >
>
> <snip>
>
> >
> > +LIB_EXPORT bool l_rtnl_route_set_gateway(struct l_rtnl_route *rt,
> > +                                             const char *address)
> > +{
> > +     if (unlikely(!rt))
> > +             return false;
> > +
> > +     switch (rt->family) {
> > +     case AF_INET:
> > +             return inet_pton(AF_INET, address, &rt->gw.in_addr) =3D=
=3D 1;
> > +     case AF_INET6:
> > +             return inet_pton(AF_INET6, address, &rt->gw.in6_addr) =3D=
=3D 1;
> > +     default:
> > +             return  false;
> > +     }
> > +}
> > +
>
> Since we already have l_rtnl_route_new_gateway, would this make more sens=
e as a
> dedicated constructor? Something like l_rtnl_route_new_static?

Ok.

Best regards
--===============3181102956281942928==--

