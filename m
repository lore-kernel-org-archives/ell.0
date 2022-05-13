Content-Type: multipart/mixed; boundary="===============8067451043706215132=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: Re: [PATCH 01/13] net: Add l_net_clear_host_bits utility
Date: Sat, 14 May 2022 00:41:22 +0200
Message-ID: <CAOq732KWWpTQh62tDdTvRpjXgFUg1-d4ENZWDYeSUU-7i2VMNw@mail.gmail.com>
In-Reply-To: 913bb777-2b72-47e8-7b57-de3de66b3af4@gmail.com

--===============8067451043706215132==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Fri, 13 May 2022 at 16:15, Denis Kenzior <denkenz(a)gmail.com> wrote:
> >>> +static inline void l_net_clear_host_bits(uint8_t *address, uint8_t p=
refix_len,
> >>> +                                             uint8_t bytes)
> >>
> >> I'm not super excited about the naming.  What about l_net_prefix_from_=
address()?
> >
> > Ok, I guess host mask is an IPv4 term with the v6 term being interface
> > ID.  l_net_prefix_from_address sounds good, or how about
>
> You could also add a separate v4/v6 version instead?  Your set only uses =
this
> for v6 right now, and you'd be able to drop the bytes parameter?  You cou=
ld also
> use a static buffer for the return value (or simply a uint32 for the v4 v=
ersion)
> and make address in-only instead of in-out.

Ok.

>
> > l_net_mask_prefix?
>
> The use of l_net_prefix_from_address() would make it very clear what is
> happening in netconfig_add_v6_static_address_routes().  l_net_mask_prefix=
 better
> suites the usage in patch 13, though your original naming also works well=
 here.
>
> Question is, if you're already sanitizing & dropping the address portion =
in
> netconfig_add_v6_static_routes(), do you even need the use of
> l_net_clear_host_bits in patch 13?

netconfig_add_v6_static_routes() is only used for the static configs.
In icmp.c I use it for the RA data and I think it's nice if the higher
layer (netconfig) can trust that what it received from the ICMPv6
layer is already validated.

>
> Anyhow, maybe the outcome from this discussion is to just put this into
> net-private.h for now and we can agree on the name later if this function=
 needs
> to be exposed into public API.

Ok.

Best regards
--===============8067451043706215132==--

