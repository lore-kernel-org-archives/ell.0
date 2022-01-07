Content-Type: multipart/mixed; boundary="===============6348095389471238044=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: Re: [PATCH 4/5] icmp6: Track routers and prefix routes from multiple
 RAs
Date: Fri, 07 Jan 2022 22:10:22 +0100
Message-ID: <CAOq732KtZrD5t3LjOV+6zOS5_Gq1Lp_PWR6_xCmv_mqxhVF+OQ@mail.gmail.com>
In-Reply-To: 3c2b5013-b08b-cb3c-de1a-884b27154bea@gmail.com

--===============6348095389471238044==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Fri, 7 Jan 2022 at 21:04, Denis Kenzior <denkenz(a)gmail.com> wrote:
> > I found that some network stacks document exactly how they process
> > router advertisements (also which options they support etc.), e.g.
> > Cisco and z/OS document this.  They seem to follow the RFC exactly,
> > but it being explicitly explained in their docs should help admins be
> > clear in how those things should be configured.
>
> Do you have some links handy?

https://www.ibm.com/docs/en/zos/2.4.0?topic=3Ddiscovery-router-advertisemen=
ts
and the prefix information subpage.

>
> >> Also, some of these events are somewhat useless if icmp6 is responsibl=
e for
> >> setting the routes into the kernel.  Maybe they shouldn't even be fire=
d in this
> >> case.
> >
> > Right, we could do this but we wouldn't be saving a lot of cycles and
> > it sounds like a hack.
>
> How so?  We in theory have two use cases:
>
> 1. iwd managing an ipv6 interface.
> 2. info is sent out via IP configuration events over D-Bus.
>
> In case of 1, none of these events are really useful since iwd would just=
 let
> icmp6/dhcp6_client manage this completely.

Currently dhcp6.c is the only listener of those events, so by not
emitting one event we merely save one function call and a switch(){}.
Now if IWD isn't interested in them then ideally it won't register a
listener.

(But, didn't we talk on the IWD list about how we need to pass those
events to a "netconfig-committer" entity and let it apply the
settings?)

>
> In case of 2, the client just wants a snapshot of what the settings shoul=
d be,
> not get notified that each individual route has changed.

Right, but we do need most of the events in this case.  If we're not
sending original lifetimes over D-Bus then naturally we wouldn't send
lifetime changes over D-Bus either but that's for netconfig-committer
to determine.  We should maybe consider skipping the CHANGED events
when it's only the lifetime changing.  For other changes like MTU and
preference we probably do need to handle the event and send a new
snapshot of the routing information.

>
> Or do you have something else in mind?
>
> >> This is another part that seriously concerns me right now.  I actually=
 wonder
> >> why we would need to use timeouts at all?  If we set the lifetime into=
 the
> >> kernel, then it can take care of removing these routes (assuming it do=
esn't just
> >> leave them in there with lifetime 0).
> >
> > So when we receive a new RA we need to know whether we already have
> > this router/prefix to know how to process it.  For a lot of things we
> > can instead save an expiration timestamp and next time we look at the
> > data we ignore it if it's expired.  But would couldn't emit events.
>
> I suppose we do need at least a single timer for case 2 above.  But havin=
g a
> timer for each route seems excessive.

Are you ok we me converting this new code to use a single timer as a
separate optimisation later, like I mentioned?

>
> >>
> >> One thing to keep in mind is that for us, the 99% use case is a single=
 router
> >> that keeps sending the same RA message every several seconds.  The net=
 effect is
> >> that the same route info keeps getting re-uploaded to the kernel every=
 few
> >> seconds.  I think this is pointless and we need to optimize that.
> >
> > What we could do is not set lifetimes on the RTNL routes and delete
> > them ourselves, then we wouldn't have to update their lifetimes.
>
> Yes, we could do that since you're not passing lifetimes in the proposed =
iwd
> API.  But is that intended or an oversight?

To be honest I didn't realise that finite lifetimes are actually
popular (judging from the docs I read so far...), in fact only the
prefix options support infinite lifetimes, default router info
doesn't.  So wrt the D-Bus API it seems that not passing the lifetimes
and lifetime updates will be much more efficient.  As for applying
them through RTNL we can also take care of cleaning up the routes
ourselves and not set the lifetimes (either we don't call
l_rtnl_route_set_lifetime at all, or we just don't pass the value to
the kernel in rtnl.c)

Best regards
--===============6348095389471238044==--

