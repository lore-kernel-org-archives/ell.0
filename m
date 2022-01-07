Content-Type: multipart/mixed; boundary="===============1253497250062591662=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH 4/5] icmp6: Track routers and prefix routes from multiple
 RAs
Date: Fri, 07 Jan 2022 13:48:15 -0600
Message-ID: <3c2b5013-b08b-cb3c-de1a-884b27154bea@gmail.com>
In-Reply-To: CAOq732KU1JUn+jMrrzXARPqFy1pb7OOyng0BY_m9xbPM8+N76Q@mail.gmail.com

--===============1253497250062591662==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

> I found that some network stacks document exactly how they process
> router advertisements (also which options they support etc.), e.g.
> Cisco and z/OS document this.  They seem to follow the RFC exactly,
> but it being explicitly explained in their docs should help admins be
> clear in how those things should be configured.

Do you have some links handy?

>> Also, some of these events are somewhat useless if icmp6 is responsible =
for
>> setting the routes into the kernel.  Maybe they shouldn't even be fired =
in this
>> case.
> =

> Right, we could do this but we wouldn't be saving a lot of cycles and
> it sounds like a hack.

How so?  We in theory have two use cases:

1. iwd managing an ipv6 interface.
2. info is sent out via IP configuration events over D-Bus.

In case of 1, none of these events are really useful since iwd would just l=
et =

icmp6/dhcp6_client manage this completely.

In case of 2, the client just wants a snapshot of what the settings should =
be, =

not get notified that each individual route has changed.

Or do you have something else in mind?

>> This is another part that seriously concerns me right now.  I actually w=
onder
>> why we would need to use timeouts at all?  If we set the lifetime into t=
he
>> kernel, then it can take care of removing these routes (assuming it does=
n't just
>> leave them in there with lifetime 0).
> =

> So when we receive a new RA we need to know whether we already have
> this router/prefix to know how to process it.  For a lot of things we
> can instead save an expiration timestamp and next time we look at the
> data we ignore it if it's expired.  But would couldn't emit events.

I suppose we do need at least a single timer for case 2 above.  But having =
a =

timer for each route seems excessive.

>>
>> One thing to keep in mind is that for us, the 99% use case is a single r=
outer
>> that keeps sending the same RA message every several seconds.  The net e=
ffect is
>> that the same route info keeps getting re-uploaded to the kernel every f=
ew
>> seconds.  I think this is pointless and we need to optimize that.
> =

> What we could do is not set lifetimes on the RTNL routes and delete
> them ourselves, then we wouldn't have to update their lifetimes.

Yes, we could do that since you're not passing lifetimes in the proposed iw=
d =

API.  But is that intended or an oversight?

Regards,
-Denis
--===============1253497250062591662==--

