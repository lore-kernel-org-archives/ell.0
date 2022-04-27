Content-Type: multipart/mixed; boundary="===============6576403161609529560=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: Re: [PATCH 04/13] netconfig: Support IPv6 static configurations
Date: Wed, 27 Apr 2022 23:42:46 +0200
Message-ID: <CAOq732JGL_OGXtiMiCGmC1dV3=-JiOn0Q9NHPV+WPEBB-+Ho5g@mail.gmail.com>
In-Reply-To: 9e537ed3-5fde-db84-0401-caa445a81c42@gmail.com

--===============6576403161609529560==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Wed, 27 Apr 2022 at 16:48, Denis Kenzior <denkenz(a)gmail.com> wrote:
> >> However, the more general question here is why do we want to store and=
 compute
> >> the prefix route separately?  Is the assumption here that all addresse=
s use the
> >> noprefixroute flag?  Wouldn't it be simpler to just have the kernel ha=
ndle this?
> >
> > So I think we can do that if we're committing the addresses to the
> > kernel ourselves.  If we have to delegate it to NM we still need this
> > code.  In the end I think it's easier to have just one branch here.
>
> Explain?  NM doesn't understand the noprefixroute flag?  Just curious.  I=
 think
> we do indeed need to do it as you propose.  See below.

After some digging my understanding is that NM internally stores the
address flags bitmap and the IWD backend could set it or clear
IFA_F_NOPREFIXROUTE on the addresses received from IWD.  But the core
code doesn't often look at whether IFA_F_NOPREFIXROUTE is set because
there's a policy in their netconfig code that basically it should be
always set.  The logic is quite involved but basically NM will set the
flag when talking to the kernel, and then will autogenerate the subnet
routes for IPv4 (statically or dynamically assigned) and for IPv6
static configs.  That means that IWD doesn't need to give NM those
subnet routes, same as if IFA_F_NOPREFIXROUTE was cleared.

On the other hand my thinking is that 1. we might want to not shape
the ell API based on current NM behaviour and might want to add the
subnet routes at the risk of NM ignoring them or adding duplicates.
These routes can also be dropped (or added) at the IWD-backend or IWD
level.

2. We may want to avoid adding too many address parameters and flags
in the D-Bus API, or the ell C API.

Here are some interesting comments in NM code:
https://gitlab.freedesktop.org/NetworkManager/NetworkManager/-/blob/main/sr=
c/libnm-platform/nm-platform.c#L5388-5404
https://gitlab.freedesktop.org/NetworkManager/NetworkManager/-/blob/main/sr=
c/libnm-platform/nm-platform.h#L411-425
https://gitlab.freedesktop.org/NetworkManager/NetworkManager/-/blob/main/sr=
c/core/nm-l3-config-data.c#L2418-2430
https://gitlab.freedesktop.org/NetworkManager/NetworkManager/-/blob/main/sr=
c/core/nm-l3-config-data.c#L2457-2465

>
> >
> > Having the kernel handle the subnet routes is even more obvious for
> > IPv4 because it works for static as well as DHCP.  For some reason the
> > IWD code always sets this flag for both IPv4 and IPv6.
> >
>
> I don't recall exactly why we originally added the connected route separa=
tely.
> I'm pretty sure this resulted in two prefix routes in the routing table u=
ntil I
> introduced the noprefixroute flag to ell.
>
> But I *think* the reason we add a separate connected route, in icmp6 at l=
east,
> is to make sure the metric is applied properly.  If noprefixroute flag is=
n't
> set, the kernel will automagically create a new connected route when the =
address
> is installed.  But the metric used for this route is the default.

Ok I didn't know that, and it matches what NM comments say too.  I
guess this matters because the local subnet needs a higher metric than
other routes?

>
> I don't think we found a way to affect the connected route's metric witho=
ut
> resorting to the noprefixroute flag and adding the route separately.  May=
be it
> is possible?  Would save us a round trip.

Best regards
--===============6576403161609529560==--

