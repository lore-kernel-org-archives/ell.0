Content-Type: multipart/mixed; boundary="===============7579235548558881400=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: Re: [PATCH 01/11] net: Add l_net_subnet_matches
Date: Tue, 19 Apr 2022 20:48:36 +0200
Message-ID: <CAOq732LGogmh7t7y81wsiUOmDevHT=ow2P8bvQzv_6XvXQp44w@mail.gmail.com>
In-Reply-To: fda11a36-9bd2-77da-4845-15bb62146577@gmail.com

--===============7579235548558881400==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Tue, 19 Apr 2022 at 17:02, Denis Kenzior <denkenz(a)gmail.com> wrote:
> On 4/19/22 02:42, Andrew Zaborowski wrote:
> > On Mon, 18 Apr 2022 at 20:00, Denis Kenzior <denkenz(a)gmail.com> wrote:
> >> IPv6 doesn't really use subnets like IPv4 does though?  I'm not even s=
ure this
> >> function would be relevant for IPv6?
> >
> > You need it to check if an address is within a subnet prefix?
> >
>
> IPv6 doesn't work the same as IPv4 though.  I'm fairly certain that the g=
ateway
> and the static address do not need to be part of the same subnet at all.

Well, I was trying not to concentrate on just one use case since this
is public API.

But they kinda do work the same way.  The gateway always needs to be
in one of the on-link subnets or prefixes.

With static configuration (IPv4 and IPv6) or DHCP v4 you generally
have one on-link subnet, the one defined by your IP + prefix length.

With IPv6 Router Advertisements you can have knowledge of multiple
on-link prefixes.  The gateway needs to match one of them in exactly
the same way as with IPv4.

>
> >>   Is it?  Looks like we do this for FILS,
> >> but I'm not even certain that the check in ie.c in iwd is correct.
> >>
> >>> buffer of just long enough for the subnet address, or passing a
> >>> prefix_len of 32 / 128 for things like a route prefix.
> >>
> >> Well, prefix_len of 32/128 implies point-to-point routing (and even 31=
 in IPv4
> >> would be special).  So I'm not sure calling this function with such pr=
efixes
> >> even makes sense?
> >
> > While an IPv4 31/32-bit subnet might not be a valid subnet, with IPv6
> > I don't know of a reason that single-address prefixes should be
> > treated specially.  RFC4191 for example says that an onlink prefix
> > length "value ranges from 0 to 128".
>
> Sure, but I still don't see how this figures into the subnet validation?
>
> An on-link with a prefix 128 just means that the host is on the local lin=
k.  You
> simply add it to the routing table and treat it as directly reachable (no=
t via
> the default gateway).  I don't think there would be anything to validate?

Well, if that address you're trying to validate (e.g. let's say your
DNS IP) is on-link, which you'd find out from the RA, then you don't
need to add anything to the routing table because your RA handler will
already have added that route.  If it's not and there's no default
router, then either it's an error or you might want to implicitly add
a route for it.

But the way you'd find out whether given IP is on-link is by calling
l_net_subnet_matches for each prefix.  Their lengths vary from 0 to
128 like the RFC says.

Best regards
--===============7579235548558881400==--

