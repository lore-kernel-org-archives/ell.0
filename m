Content-Type: multipart/mixed; boundary="===============1030453165551046000=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH] rtnl: Add neighbor discovery utilities
Date: Thu, 26 Aug 2021 01:57:22 +0200
Message-ID: <CAOq732Kxtk3=mLE_gSDvadF9ZB3FRP=cV8N5fjM+em436oQq0Q@mail.gmail.com>
In-Reply-To: <e4662281-c4f7-0b3e-485c-69243a6f0104@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1030453165551046000==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Thu, 26 Aug 2021 at 00:51, Denis Kenzior <denkenz@gmail.com> wrote:
> >> I was hoping to avoid using in_addr / in6_addr in the public API, but =
maybe that
> >> would be the lesser evil option than 'const uint8_t *'.  Or just use
> >> l_rtnl_address for everything.
> >
> > My preference would be for in_addr / in6_addr, l_rtnl_address seems to
> > be overkill for a wrapper for a 32-bit value.
>
> I wouldn't actually mind seeing more context on how you're using these.  =
In
> theory you would need the rtnl address anyway, unless you're using this w=
ithin
> dhcp server classes.  In which case you can provide a private API as well.

This would be used in IWD like in
https://github.com/balrog-kun/iwd/commit/2da9ad4bb20a85f53fc459b5ec00dd90ad=
bfe01f#diff-38b3dd2a52d30079b126664f14e4c72daab4887eb5d84aa07c684076db1f5e0=
cR278-R292

We only build an l_rtnl_address for our own IPs in netconfig.c.

>
> >
> > The only evil aspect of these that I can see is uint32_t's endianness
> > ambiguity (something similar to kernel's __be32 would have been
> > better) but the simplicity is a big advantage.
> >
>
> Use of struct in_addr would imply network order is being used.  Same as
> inet_ntoa/inet_ntop, etc.

Right, and same as __be32.  __be32 has the advantage that it's not a
struct so, 1. you know its size and contents and can pass its pointer
directly to, say, an attribute builder without looking up internal
structures, 2. don't need to convert to/from it by assigning cryptic
field names, 3. can pass it as parameter.

>
> >>
> >>> +                                     l_rtnl_neighbour_get_cb_t cb,
> >>> +                                     void *user_data,
> >>> +                                     l_netlink_destroy_func_t destro=
y);
> >>> +uint32_t l_rtnl_neighbour_get_addr_hwaddr(struct l_netlink *rtnl, in=
t ifindex,
> >>> +                                     const struct l_rtnl_address *ad=
dr,
> >>> +                                     l_rtnl_neighbour_get_cb_t cb,
> >>> +                                     void *user_data,
> >>> +                                     l_netlink_destroy_func_t destro=
y);
> >>> +uint32_t l_rtnl_neighbour_set_ipv4_hwaddr(struct l_netlink *rtnl, in=
t ifindex,
> >>> +                                     uint32_t addr, const uint8_t *h=
waddr,
> >>
> >> You're making an assumption that hwaddr is always 6?  That will not re=
ally be
> >> true long term.  Might as well take care of this now.
> >
> > I am, but if the address is not 6 bytes the user will know it based on
> > the ifindex too.  We can be more explicit and include a length though.
>
> User might, but API implementation doesn't.  How does the implementation =
of this
> function know that ifindex is for a device that uses 8 byte hardware addr=
ess?
> ifindex is just an int as far as it is concerned.  So unless you're going=
 to
> introduce a netdev abstraction, hardware length would be needed here at s=
ome point.

True, we don't have netdev data directly in ell and would need to
either get it from the user or query it from the kernel if that is
ever a concern.

Best regards
--===============1030453165551046000==--

