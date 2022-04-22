Content-Type: multipart/mixed; boundary="===============6175719749585880324=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: Re: [PATCH 03/12] netconfig: Add DHCP override and static IP API
Date: Fri, 22 Apr 2022 20:38:37 +0200
Message-ID: <CAOq732KGxcn7y6GMc8uc-B45RgmzdMxkpqJ+c3K3zHoPXsEyZA@mail.gmail.com>
In-Reply-To: c3a07449-ba00-4e89-7153-c4c2f8f998d9@gmail.com

--===============6175719749585880324==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On Thu, 21 Apr 2022 at 21:47, Denis Kenzior <denkenz(a)gmail.com> wrote:
> On 4/21/22 10:45, Andrew Zaborowski wrote:
> > +LIB_EXPORT bool l_netconfig_set_static_addr(struct l_netconfig *netcon=
fig,
> > +                                     uint8_t family,
> > +                                     const struct l_rtnl_address *addr)
> > +{
> > +     if (unlikely(!netconfig || netconfig->started))
> > +             return false;
> > +
> > +     if (addr && l_rtnl_address_get_family(addr) !=3D family)
> > +             return false;
> > +
>
> switch (family) {
> case AF_INET:
>         ptr =3D &netconfig->v4_static_addr;
>         break;
> case AF_INET6:
>         ptr =3D &netconfig->v6_static_addr;
>         break;
> default:
>         return false;
> }
>
> l_rtnl_address_free(*ptr);
> *ptr =3D NULL;

Ok.

> > +     /*
> > +      * If using a static IP, we can validate right now that the gatew=
ay is
> > +      * in the local subnet.
> > +      */
> > +     if (netconfig->v4_static_addr && netconfig->v4_gateway_override)
> > +             if (!l_net_prefix_matches(&local, &gateway, prefix_len))
> > +                     return false;
> > +
>
> I know you're trying to be nice, but we should not be doing this.  Static
> configuration is for expert users, and if they want to shoot themselves i=
n the
> foot, then I say let them.

Ok.

>
> Besides, such policy enforcement should not be done by netconfig itself. =
 That
> should be done by a layer above, or you should provide a policy enforceme=
nt
> abstraction that the caller could provide to netconfig.  Not something we=
 care
> about at the moment.
>
> > +     /*
> > +      * If using a static IP and there's no gateway all the DNSes must=
 be on
> > +      * the local subnet too.
> > +      */
> > +     if (netconfig->v4_static_addr && !netconfig->v4_gateway_override =
&&
> > +                     netconfig->v4_dns_override) {
> > +             unsigned int i;
> > +
> > +             for (i =3D 0; i < dns_num; i++)
> > +                     if (!l_net_prefix_matches(&local, &dns_list[i],
> > +                                                     prefix_len))
> > +                             return false;
> > +     }
>
> As above here

Ok, dropping the checks then.

Best regards
--===============6175719749585880324==--

