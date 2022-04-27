Content-Type: multipart/mixed; boundary="===============0542692859449278137=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: Re: [PATCH 04/13] netconfig: Support IPv6 static configurations
Date: Wed, 27 Apr 2022 16:18:19 +0200
Message-ID: <CAOq732+5r43LtLMGJe21sMWDhk9LXZLR8FDvOWq-3G8ZGhtOQQ@mail.gmail.com>
In-Reply-To: d40420e6-e9c5-c6a4-b007-ee43c6e5b0dd@gmail.com

--===============0542692859449278137==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Wed, 27 Apr 2022 at 15:30, Denis Kenzior <denkenz(a)gmail.com> wrote:
> On 4/22/22 13:59, Andrew Zaborowski wrote:
> > +     /* Zero out host address bits to produce network address */
> > +     if (prefix_len & 7)
> > +             in6_addr.s6_addr[prefix_len / 8] &=3D 0xff00 >> (prefix_l=
en & 7);
>
> Can we make this a bit cleaner? Something like
>
> last_byte =3D prefix_len / 8;
>
> if (prefix_len & 7) {
>         /* zero out lsb bits */
>         last_byte +=3D 1;
> }
>
> memset(in6_addr + last_byte, 0, 16 - last_byte);

Ok.

>
> However, the more general question here is why do we want to store and co=
mpute
> the prefix route separately?  Is the assumption here that all addresses u=
se the
> noprefixroute flag?  Wouldn't it be simpler to just have the kernel handl=
e this?

So I think we can do that if we're committing the addresses to the
kernel ourselves.  If we have to delegate it to NM we still need this
code.  In the end I think it's easier to have just one branch here.

Having the kernel handle the subnet routes is even more obvious for
IPv4 because it works for static as well as DHCP.  For some reason the
IWD code always sets this flag for both IPv4 and IPv6.

> > @@ -580,11 +629,56 @@ static bool netconfig_check_v4_config(struct l_ne=
tconfig *netconfig)
> >       return true;
> >   }
> >
> > +static bool netconfig_check_v6_config(struct l_netconfig *netconfig)
> > +{
> > +     struct in6_addr local;
> > +     struct in6_addr gateway;
> > +     uint8_t prefix_len =3D 0;
> > +     unsigned int dns_num =3D 0;
> > +     _auto_(l_free) struct in6_addr *dns_list =3D NULL;
> > +
> > +     if (!netconfig->v6_enabled)
> > +             return true;
> > +
> > +     if (netconfig->v6_static_addr) {
> > +             char str[INET6_ADDRSTRLEN];
> > +
> > +             prefix_len =3D l_rtnl_address_get_prefix_length(
> > +                                             netconfig->v6_static_addr=
);
> > +             if (unlikely(prefix_len > 126))
> > +                     return false;
> > +
> > +             l_rtnl_address_get_address(netconfig->v6_static_addr, str=
);
> > +             inet_pton(AF_INET6, str, &local);
> > +     }
> > +
> > +     if (netconfig->v6_gateway_override) {
> > +             if (unlikely(inet_pton(AF_INET6, netconfig->v6_gateway_ov=
erride,
> > +                                     &gateway) !=3D 1))
> > +                     return false;
> > +     }
> > +
> > +     if (netconfig->v6_dns_override &&
> > +                     (dns_num =3D l_strv_length(netconfig->v6_dns_over=
ride))) {
> > +             unsigned int i;
> > +
> > +             dns_list =3D l_new(struct in6_addr, dns_num);
> > +
> > +             for (i =3D 0; i < dns_num; i++)
> > +                     if (inet_pton(AF_INET6, netconfig->v6_dns_overrid=
e[i],
> > +                                     &dns_list[i]) !=3D 1)
> > +                             return false;
> > +     }
> > +
>
> All this checking is pure copy-paste of the v4 version.  Can they be comb=
ined?

Ok, let me do it that way.

Best regards
--===============0542692859449278137==--

