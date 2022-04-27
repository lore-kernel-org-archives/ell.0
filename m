Content-Type: multipart/mixed; boundary="===============2316862920045883398=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH 04/13] netconfig: Support IPv6 static configurations
Date: Wed, 27 Apr 2022 09:47:59 -0500
Message-ID: <9e537ed3-5fde-db84-0401-caa445a81c42@gmail.com>
In-Reply-To: CAOq732+5r43LtLMGJe21sMWDhk9LXZLR8FDvOWq-3G8ZGhtOQQ@mail.gmail.com

--===============2316862920045883398==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

>> However, the more general question here is why do we want to store and c=
ompute
>> the prefix route separately?  Is the assumption here that all addresses =
use the
>> noprefixroute flag?  Wouldn't it be simpler to just have the kernel hand=
le this?
> =

> So I think we can do that if we're committing the addresses to the
> kernel ourselves.  If we have to delegate it to NM we still need this
> code.  In the end I think it's easier to have just one branch here.

Explain?  NM doesn't understand the noprefixroute flag?  Just curious.  I t=
hink =

we do indeed need to do it as you propose.  See below.

> =

> Having the kernel handle the subnet routes is even more obvious for
> IPv4 because it works for static as well as DHCP.  For some reason the
> IWD code always sets this flag for both IPv4 and IPv6.
> =


I don't recall exactly why we originally added the connected route separate=
ly. =

I'm pretty sure this resulted in two prefix routes in the routing table unt=
il I =

introduced the noprefixroute flag to ell.

But I *think* the reason we add a separate connected route, in icmp6 at lea=
st, =

is to make sure the metric is applied properly.  If noprefixroute flag isn'=
t =

set, the kernel will automagically create a new connected route when the ad=
dress =

is installed.  But the metric used for this route is the default.

I don't think we found a way to affect the connected route's metric without =

resorting to the noprefixroute flag and adding the route separately.  Maybe=
 it =

is possible?  Would save us a round trip.

Regards,
-Denis
--===============2316862920045883398==--

