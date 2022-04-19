Content-Type: multipart/mixed; boundary="===============7153388835748495935=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: Re: [PATCH 02/11] netconfig: Add DHCP override and static IP API
Date: Tue, 19 Apr 2022 09:59:44 +0200
Message-ID: <CAOq732LdD-1p_b=GQLP_ULXo+EY3h0cFCw8JwWBLQcnnpXtRtw@mail.gmail.com>
In-Reply-To: 39949927-436f-7869-5957-2342b5364800@gmail.com

--===============7153388835748495935==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Mon, 18 Apr 2022 at 21:15, Denis Kenzior <denkenz(a)gmail.com> wrote:
> On 4/11/22 09:20, Andrew Zaborowski wrote:
> > +     switch (family) {
> > +     case AF_INET:
> > +             l_rtnl_address_free(l_steal_ptr(netconfig->v4_static_addr=
));
> > +
> > +             if (addr)
> > +                     break;
>
> I take it this should be !addr?

Yep.

>
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
r,
> > +                                                     true);
> > +             return true;
> > +     case AF_INET6:
> > +             l_rtnl_address_free(l_steal_ptr(netconfig->v6_static_addr=
));
> > +
> > +             if (addr)
> > +                     break;
> > +
>
> And here as well?

Yep.

> > +     /*
> > +      * If using a static IP and there's no gateway all the DNSes mut =
be on
>
> typo: mut -> must

Right.

>
> > +     /*
> > +      * If using a static IP, we can validate right now that the gatew=
ay is
> > +      * in the local subnet.
> > +      */
> > +     if (netconfig->v6_static_addr && netconfig->v6_gateway_override)
> > +             if (!l_net_subnet_matches(&local, &gateway, prefix_len))
> > +                     return false;
>
> Not sure this is true?  AFAIK the default gateway could be a link local a=
ddress...

True, that's also a good catch.  I'll add a check for that (unless you
prefer we don't validate this address.)

>
> > +
> > +     /*
> > +      * If using a static IP and there's no gateway all the DNSes mut =
be on
>
> Same typo as above.
>
> > +      * the local subnet too.
> > +      */
> > +     if (netconfig->v6_static_addr && !netconfig->v6_gateway_override =
&&
> > +                     netconfig->v6_dns_override) {
> > +             unsigned int i;
> > +
> > +             for (i =3D 0; i < dns_num; i++)
> > +                     if (!l_net_subnet_matches(&local, &dns_list[i],
> > +                                                     prefix_len))
> > +                             return false;
>
> This whole block maybe should be a static convenience function?  In fact,=
 much
> of these checks are the same as in v4 version of this function and could =
be
> combined?

Ok, let me try to combine them.

>
> > +     }
> > +
> > +     return true;
> > +}
> > +
>
> <snip>
>
> >   LIB_EXPORT bool l_netconfig_start(struct l_netconfig *netconfig)
> >   {
> >       if (unlikely(!netconfig || netconfig->started))
> >               return false;
> >
> > -     if (netconfig->v4_enabled &&
> > -                     !l_dhcp_client_start(netconfig->dhcp_client))
> > +     if (!netconfig_check_config(netconfig))
> >               return false;
> >
>
> Can we check that both v4_enabled and v6_enabled are false and return app=
ropriately?

Ok.  We effectively do but let me add one at the beginning.

>
> > -     netconfig->started =3D true;
> > +     if (netconfig->v4_enabled) {
>
> I'd prefer less nesting, so something like:
>
> if (!netconfig->v4_enabled)
>         goto configure_ipv6;

Ok.

>
> > +             if (netconfig->v4_static_addr) {
> > +                     /*
> > +                      * We're basically ready to configure the interfa=
ce
> > +                      * but do this in an idle callback.
> > +                      */
> > +                     netconfig->do_static_work =3D l_idle_create(
> > +                                             netconfig_do_static_confi=
g,
> > +                                             netconfig, NULL);
>
> goto here..
>
> > +             } else {
> > +                     if (!l_dhcp_client_start(netconfig->dhcp_client))
> > +                             return false;
> > +             }
> > +     }
> >
> > +     netconfig->started =3D true;
> >       return true;
> >   }
> >
>
> <snip>
>
> > diff --git a/ell/netconfig.h b/ell/netconfig.h
> > index 682f4aa..aab9d3f 100644
> > --- a/ell/netconfig.h
> > +++ b/ell/netconfig.h
> > @@ -53,6 +53,22 @@ typedef void (*l_netconfig_destroy_cb_t)(void *user_=
data);
> >
> >   struct l_netconfig *l_netconfig_new(uint32_t ifindex);
> >   void l_netconfig_destroy(struct l_netconfig *netconfig);
> > +bool l_netconfig_set_af_enabled(struct l_netconfig *netconfig, uint8_t=
 family,
> > +                             bool enabled);
>
> Can we call it family_enabled?

Sure.

>
> > +bool l_netconfig_set_static_addr(struct l_netconfig *netconfig, uint8_=
t family,
> > +                                     const struct l_rtnl_address *addr=
);
> > +bool l_netconfig_set_gateway_override(struct l_netconfig *netconfig,
> > +                                     uint8_t family,
> > +                                     const char *gateway_str);
>
> Wonder why you use l_rtnl_address for 'set_static_addr' and a string for =
the
> gateway?

So l_rtnl_address includes the prefix length and such, so the struct
maps to our own addresses.  The gateway would map to the next-hop
address in the l_rtnl_route struct so it didn't seem fitting.  Note
that l_rtnl_route doesn't use l_rtnl_address for that in its API.

Best regards
--===============7153388835748495935==--

