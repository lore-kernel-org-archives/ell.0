Content-Type: multipart/mixed; boundary="===============8568114991624132860=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: Re: [PATCH 11/12] netconfig: Add DHCP override and static IP API
Date: Fri, 11 Mar 2022 22:30:29 +0100
Message-ID: <CAOq732Lzb=2p1OLq7SEkUzatSDfoRX=8rS3gyXqsQm5e74mWbw@mail.gmail.com>
In-Reply-To: 1aa3437c-0cdf-2684-3f10-a50de35e61d1@gmail.com

--===============8568114991624132860==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On Fri, 11 Mar 2022 at 18:09, Denis Kenzior <denkenz(a)gmail.com> wrote:
> On 3/7/22 08:55, Andrew Zaborowski wrote:
> > +LIB_EXPORT void l_netconfig_set_af_enabled(struct l_netconfig *netconf=
ig,
> > +                                             uint8_t family, bool enab=
led)
> > +{
> > +     if (unlikely(!netconfig || netconfig->started))
> > +             return;
>
> Should we at least return bool here?  In case family is invalid for examp=
le?

I wanted to avoid forcing the user to perform too many checks, and
instead only return bool from l_netconfig_start, but there may be no
way around it.

>
> > +
> > +     switch (family) {
> > +     case AF_INET:
> > +             netconfig->v4_enabled =3D enabled;
> > +             break;
> > +     }
> > +}
> > +
> > +LIB_EXPORT void l_netconfig_set_hostname(struct l_netconfig *netconfig,
> > +                                             const char *hostname)
> > +{
> > +     if (unlikely(!netconfig || netconfig->started))
> > +             return;
> > +
> > +     l_dhcp_client_set_hostname(netconfig->dhcp_client, hostname);
>
> Same with this?

Ok.

> In theory set_hostname might fail.

We ensure that netconfig->dhcp_client is in the right state but ok.

>
> > +}
> > +
> > +LIB_EXPORT void l_netconfig_set_route_priority(struct l_netconfig *net=
config,
> > +                                             uint32_t priority)
> > +{
> > +     if (unlikely(!netconfig || netconfig->started))
> > +             return;
> > +
> > +     netconfig->route_priority =3D priority;
> > +}
> > +
> > +LIB_EXPORT void l_netconfig_set_static_addr(struct l_netconfig *netcon=
fig,
> > +                                     uint8_t family,
> > +                                     const struct l_rtnl_address *addr)
> > +{
> > +     if (unlikely(!netconfig || netconfig->started))
> > +             return;
> > +
> > +     if (L_WARN_ON(addr && l_rtnl_address_get_family(addr) !=3D family=
))
> > +             return;
> > +
> > +     switch (family) {
> > +     case AF_INET:
> > +             if (netconfig->v4_static_addr)
> > +                     l_rtnl_address_free(l_steal_ptr(
> > +                                             netconfig->v4_static_addr=
));
>
> Why not simply l_rtnl_address_free(l_steal_ptr...))?

True.

>
> > +
> > +             if (addr)
> > +                     break;
> > +
> > +             netconfig->v4_static_addr =3D l_rtnl_address_clone(addr);
> > +             l_rtnl_address_set_lifetimes(netconfig->v4_static_addr, 0=
, 0);
> > +
> > +             /*
> > +              * We could leave the decision about this flag up to the
> > +              * caller but for simplicity override to true.
> > +              */
> > +             l_rtnl_address_set_noprefixroute(netconfig->v4_static_add=
r, true);
>
> This line > 80 chars

Oops, will fix these too.

>
> > +             break;
> > +     case AF_INET6:
> > +             if (netconfig->v6_static_addr)
> > +                     l_rtnl_address_free(l_steal_ptr(
> > +                                             netconfig->v6_static_addr=
));
>
> As above, the if seems unnecessary.
>
> > +
> > +             if (addr)
> > +                     break;
> > +
> > +             netconfig->v6_static_addr =3D l_rtnl_address_clone(addr);
> > +             l_rtnl_address_set_lifetimes(netconfig->v6_static_addr, 0=
, 0);
> > +             l_rtnl_address_set_noprefixroute(netconfig->v6_static_add=
r, true);
>
> This line > 80 chars
>
> > +             break;
> > +     }
> > +}
> > +
> > +LIB_EXPORT void l_netconfig_set_gateway_override(struct l_netconfig *n=
etconfig,
> > +                                                     uint8_t family,
> > +                                                     const char *gatew=
ay_str)
> > +{
> > +     if (unlikely(!netconfig || netconfig->started))
> > +             return;
> > +
> > +     switch (family) {
> > +     case AF_INET:
> > +             l_free(l_steal_ptr(netconfig->v4_gateway_override));
> > +
> > +             if (!gateway_str)
> > +                     break;
> > +
> > +             netconfig->v4_gateway_override =3D l_strdup(gateway_str);
> > +             break;
> > +     case AF_INET6:
> > +             l_free(l_steal_ptr(netconfig->v6_gateway_override));
> > +
> > +             if (!gateway_str)
> > +                     break;
> > +
> > +             netconfig->v6_gateway_override =3D l_strdup(gateway_str);
> > +             break;
> > +     }
> > +}
> > +
> > +LIB_EXPORT void l_netconfig_set_dns_override(struct l_netconfig *netco=
nfig,
> > +                                             uint8_t family,
> > +                                             const char **dns_list)
>
> Why const char **?  For const-correctness you'd likely need some C++ thin=
g like
> 'const char * const *'.  We generally fall back to simply char ** for sit=
uations
> like this.

Right, I'll drop this.

const char ** is not as correct as const char * const *, but more than
char ** ;) visually conveys the meaning though.

>
> > +{
> > +     if (unlikely(!netconfig || netconfig->started))
> > +             return;
> > +
> > +     switch (family) {
> > +     case AF_INET:
> > +             l_strv_free(l_steal_ptr(netconfig->v4_dns_override));
> > +
> > +             if (!dns_list)
> > +                     break;
> > +
> > +             netconfig->v4_dns_override =3D l_strv_copy((char **) dns_=
list);
> > +             break;
> > +     case AF_INET6:
> > +             l_strv_free(l_steal_ptr(netconfig->v6_dns_override));
> > +
> > +             if (!dns_list)
> > +                     break;
> > +
> > +             netconfig->v6_dns_override =3D l_strv_copy((char **) dns_=
list);
> > +             break;
> > +     }
> > +}
> > +
> > +LIB_EXPORT void l_netconfig_set_domain_names_override(
> > +                                             struct l_netconfig *netco=
nfig,
> > +                                             uint8_t family,
> > +                                             const char **names)
>
> Same as above
>
> > +{
> > +     if (unlikely(!netconfig || netconfig->started))
> > +             return;
> > +
> > +     switch (family) {
> > +     case AF_INET:
> > +             l_strv_free(l_steal_ptr(netconfig->v4_domain_names_overri=
de));
> > +
> > +             if (!names)
> > +                     break;
> > +
> > +             netconfig->v4_domain_names_override =3D
> > +                     l_strv_copy((char **) names);
> > +             break;
> > +     case AF_INET6:
> > +             l_strv_free(l_steal_ptr(netconfig->v6_domain_names_overri=
de));
> > +
> > +             if (!names)
> > +                     break;
> > +
> > +             netconfig->v6_domain_names_override =3D
> > +                     l_strv_copy((char **) names);
> > +             break;
> > +     }
> > +}
> > +
> > +static bool netconfig_match_subnet(const void *a, const void *b,
> > +                                     uint8_t prefix_len)
> > +{
> > +     uint8_t bytes =3D prefix_len / 8;
> > +     uint8_t bits =3D prefix_len & 7;
> > +
> > +     if (bytes && memcmp(a, b, bytes))
> > +             return false;
> > +
> > +     return !bits ||
> > +             ((((const uint8_t *) a)[bytes] ^ ((const uint8_t *) b)[by=
tes]) &
> > +              (0xff00u >> bits)) =3D=3D 0;
> > +}
>
> Do we not have a similar function in iwd?  Perhaps this should be a utili=
ty
> function in l_net?  Also, with all the magic operations happening here, a=
 few
> comments might be nice.

True, let me move it from IWD's util.h to ell/net.h.

Best regards
--===============8568114991624132860==--

