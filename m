Content-Type: multipart/mixed; boundary="===============6444404245350482329=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH] rtnl: Add neighbor discovery utilities
Date: Thu, 26 Aug 2021 00:40:36 +0200
Message-ID: <CAOq732KRGfd=PWeOqRUNbmb6VarFsRx+7=riBbpA-dwpxxtpuQ@mail.gmail.com>
In-Reply-To: <8a12adad-18f3-99de-3201-ab80f21a872d@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6444404245350482329==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On Wed, 25 Aug 2021 at 21:09, Denis Kenzior <denkenz@gmail.com> wrote:
> On 8/24/21 7:40 PM, Andrew Zaborowski wrote:
> > Add a few variants of RTNL utilities to look up addresses in the
> > kernel's neighbour table entries and to add new entries.  This is
> > basically the ARP (for IPv4) and NDP (for IPv6) tables, that map IP
> > addresses to hardware addresses.
> > ---
> > There are three variants of each method, I currently only have a use
> > case for the ipv4 and ipv6 variants so I'm happy dropping the struct
> > l_rtnl_address variant.
> >
> >   ell/ell.sym  |   6 ++
> >   ell/rtnl.c   | 194 +++++++++++++++++++++++++++++++++++++++++++++++++++
> >   ell/rtnl.h   |  36 ++++++++++
> >   ell/useful.h |   4 ++
> >   4 files changed, 240 insertions(+)
> >
>
> <snip>
>
> > diff --git a/ell/rtnl.h b/ell/rtnl.h
> > index 9ea24f5..834cd14 100644
> > --- a/ell/rtnl.h
> > +++ b/ell/rtnl.h
> > @@ -33,6 +33,9 @@ extern "C" {
> >   struct l_rtnl_address;
> >   struct l_rtnl_route;
> >
> > +typedef void (*l_rtnl_neighbour_get_cb_t) (int error, const uint8_t *h=
waddr,
>
> You probably want a length as well, no?
>
> > +                                             void *user_data);
> > +
> >   struct l_rtnl_address *l_rtnl_address_new(const char *ip, uint8_t pre=
fix_len);
> >   struct l_rtnl_address *l_rtnl_address_clone(const struct l_rtnl_addre=
ss *orig);
> >   void l_rtnl_address_free(struct l_rtnl_address *addr);
> > @@ -191,6 +194,39 @@ uint32_t l_rtnl_route_delete(struct l_netlink *rtn=
l, int ifindex,
> >                                       void *user_data,
> >                                       l_netlink_destroy_func_t destroy);
> >
> > +uint32_t l_rtnl_neighbour_get_ipv4_hwaddr(struct l_netlink *rtnl, int =
ifindex,
> > +                                     uint32_t addr,
>
> We do not use uint32_t to represent an ipv4 anywhere in the ell API.
>
> > +                                     l_rtnl_neighbour_get_cb_t cb,
> > +                                     void *user_data,
> > +                                     l_netlink_destroy_func_t destroy);
> > +uint32_t l_rtnl_neighbour_get_ipv6_hwaddr(struct l_netlink *rtnl, int =
ifindex,
> > +                                     const uint8_t *addr,
>
> similarly to above, ipv6 is never represented like this.
>
> I was hoping to avoid using in_addr / in6_addr in the public API, but may=
be that
> would be the lesser evil option than 'const uint8_t *'.  Or just use
> l_rtnl_address for everything.

My preference would be for in_addr / in6_addr, l_rtnl_address seems to
be overkill for a wrapper for a 32-bit value.

The only evil aspect of these that I can see is uint32_t's endianness
ambiguity (something similar to kernel's __be32 would have been
better) but the simplicity is a big advantage.

>
> > +                                     l_rtnl_neighbour_get_cb_t cb,
> > +                                     void *user_data,
> > +                                     l_netlink_destroy_func_t destroy);
> > +uint32_t l_rtnl_neighbour_get_addr_hwaddr(struct l_netlink *rtnl, int =
ifindex,
> > +                                     const struct l_rtnl_address *addr,
> > +                                     l_rtnl_neighbour_get_cb_t cb,
> > +                                     void *user_data,
> > +                                     l_netlink_destroy_func_t destroy);
> > +uint32_t l_rtnl_neighbour_set_ipv4_hwaddr(struct l_netlink *rtnl, int =
ifindex,
> > +                                     uint32_t addr, const uint8_t *hwa=
ddr,
>
> You're making an assumption that hwaddr is always 6?  That will not reall=
y be
> true long term.  Might as well take care of this now.

I am, but if the address is not 6 bytes the user will know it based on
the ifindex too.  We can be more explicit and include a length though.

Best regards
--===============6444404245350482329==--

