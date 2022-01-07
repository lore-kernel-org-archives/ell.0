Content-Type: multipart/mixed; boundary="===============3869789888430854796=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: Re: [PATCH 4/5] icmp6: Track routers and prefix routes from multiple
 RAs
Date: Fri, 07 Jan 2022 20:00:06 +0100
Message-ID: <CAOq732KU1JUn+jMrrzXARPqFy1pb7OOyng0BY_m9xbPM8+N76Q@mail.gmail.com>
In-Reply-To: 38599430-89de-66bd-c7e9-d0875674a086@gmail.com

--===============3869789888430854796==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On Fri, 7 Jan 2022 at 19:00, Denis Kenzior <denkenz(a)gmail.com> wrote:
> On 1/6/22 09:05, Andrew Zaborowski wrote:
> > Add tracking of default/non-default routers and prefix routes in
> > separate lists that are updated with new information from new RAs.
> > This is gets us closer to what RFC4861 mandates.
> >
>
> So I'm still reviewing this, but let me share some preliminary thoughts a=
nd see
> what you think.
>
> > There's no single client->routes list now, there are two lists, one for
> > the routers and one for prefix routes.  According to the RFC there's no
> > relation between the prefix routes and which router's RA they were
> > received in (same prefixes can be received from multiple routers).
>
> While this makes sense on some level, I'm actually concerned that this ca=
n lead
> to real weirdness.  For example, you might have one RA broadcasting a pre=
fix
> with a non-zero lifetime and another RA broadcasting the same prefix with=
 a
> lifetime of 0.  They might also have differing priority, mtu or valid lif=
etime
> information.

Right, so the RFC specifically talks about how cases like these are
dealt with, in essence every parameter is optional (has a possible
"not present" value) and we should keep the old value if the new value
is not present.  Now it could happen that two routers are adevrtising
different actual values and I think it would be a configuration error,
I don't think we should be ignoring new values just because in theory
it's possible that they're wrong.

I found that some network stacks document exactly how they process
router advertisements (also which options they support etc.), e.g.
Cisco and z/OS document this.  They seem to follow the RFC exactly,
but it being explicitly explained in their docs should help admins be
clear in how those things should be configured.

> It may be easier to just simply set the info into the kernel and
> let it deal with it.
>
> I actually wonder how common this actually is in the real world?

I have no idea.

>
> >
> > The DHCP6 behaviour should be unchanged for now, it'll still only use
> > the first router that sent an announcement.  The public API is also
> > unchnaged for now except for new events.
>
> As you point out, this patch is getting rather long.  Perhaps you want to=
 break
> it up and add the ROUTER and PREFIX events in separate commits.
>
> Also, some of these events are somewhat useless if icmp6 is responsible f=
or
> setting the routes into the kernel.  Maybe they shouldn't even be fired i=
n this
> case.

Right, we could do this but we wouldn't be saving a lot of cycles and
it sounds like a hack.

>
> > ---
> > There are some rought corners in this code but the commit is already a
> > little big.  For example the route_info structure we use for prefix
> > routes is actually sent to clients in event_data but the structure is
> > private so it's useless to the clients as is.
>
> This might need to be figured out first.

Maybe I should pass the l_rtnl_route objects.

>
> >
> > Also icmp6 may end up using a lot of timeouts since we have to track
> > router timeouts and prefix route timeouts.  In this case it would be
> > pretty easy to convert all those timeouts into one that only tracks the
> > soonest expiry event so I'd be happy to do that.  We can't really avoid
> > tracking the lifetimes if we want to correctly implement the RFC.
>
> This is another part that seriously concerns me right now.  I actually wo=
nder
> why we would need to use timeouts at all?  If we set the lifetime into the
> kernel, then it can take care of removing these routes (assuming it doesn=
't just
> leave them in there with lifetime 0).

So when we receive a new RA we need to know whether we already have
this router/prefix to know how to process it.  For a lot of things we
can instead save an expiration timestamp and next time we look at the
data we ignore it if it's expired.  But would couldn't emit events.

The docs I mentioned also explain how different RA or prefix
parameters influcence how two routes can be shadowed by other routes
already in the system and how they're supposed to be re-instated when
the higher priority route times out, or how a lower priority route is
supposed to be re-instated when this route is removed, etc.

>
> > ---
> >   ell/dhcp6.c         |  15 +-
> >   ell/icmp6-private.h |  13 ++
> >   ell/icmp6.c         | 339 ++++++++++++++++++++++++++++++++++++--------
> >   ell/icmp6.h         |   6 +
> >   4 files changed, 313 insertions(+), 60 deletions(-)
> >
>
> <snip>
>
> > @@ -292,53 +292,242 @@ static bool icmp6_client_remove_route(void *data=
, void *user_data)
> >       return true;
> >   }
> >
> > -static void icmp6_client_setup_routes(struct l_icmp6_client *client)
> > +static void icmp6_router_timeout(struct l_timeout *timeout, void *user=
_data)
> >   {
> > -     struct l_icmp6_router *ra =3D client->ra;
> > -     struct l_rtnl_route *rt;
> > -     char buf[INET6_ADDRSTRLEN];
> > -     unsigned int i;
> > +     struct l_icmp6_router *r =3D user_data;
> >
> > -     rt =3D l_rtnl_route_new_gateway(inet_ntop(AF_INET6, ra->address,
> > -                                                     buf, sizeof(buf))=
);
> > -     if (!rt) {
> > -             CLIENT_DEBUG("Unable to parse RA 'from' address");
> > -             return;
> > -     }
> > +     icmp6_client_remove_route(l_steal_ptr(r->default_route), r->clien=
t);
> > +     l_timeout_remove(l_steal_ptr(r->default_timeout));
> > +     r->default_expiry =3D 0;
> >
> > -     l_rtnl_route_set_preference(rt, ra->pref);
> > -     l_rtnl_route_set_protocol(rt, RTPROT_RA);
> > -     l_rtnl_route_set_mtu(rt, ra->mtu);
> > -     l_rtnl_route_set_priority(rt, client->route_priority);
> > -     l_queue_push_tail(client->routes, rt);
> > +     icmp6_client_event_notify(r->client,
> > +                             L_ICMP6_CLIENT_EVENT_DEFAULT_ROUTER_REMOV=
ED, r);
>
> What does the kernel do when a default route reaches 0 lifetime?  Can we =
listen
> to DELROUTE events and infer that the lifetime expired based on the times=
tamp of
> the event and our own records?

We could do this if ell is managing the RTNL routes.  I considered it
but I thought it's easiest to just have one variant of the code (at
least initially) and one place where it's all handled whether we're
managing the RTNL routes or delegating it.

>
> > +}
> >
> > -     if (client->rtnl)
> > -             l_rtnl_route_add(client->rtnl, client->ifindex, rt,
> > -                                     NULL, NULL, NULL);
> > +static bool icmp6_route_info_free(void *data, void *user_data) {
> > +     struct route_info *info =3D data;
> >
> > -     for (i =3D 0; i < ra->n_prefixes; i++) {
> > -             struct route_info *info =3D &ra->prefixes[i];
> > +     icmp6_client_remove_route(info->route, info->client);
> > +     l_timeout_remove(info->timeout);
> > +     l_free(info);
> > +     return true;
> > +}
> > +
> > +static void icmp6_prefix_timeout(struct l_timeout *timeout, void *user=
_data)
> > +{
> > +     struct route_info *info =3D user_data;
> >
> > -             if (info->valid_lifetime =3D=3D 0)
> > -                     continue;
> > +     l_queue_remove(info->client->prefix_routes, info);
> > +     icmp6_client_event_notify(info->client,
> > +                             L_ICMP6_CLIENT_EVENT_ONLINK_PREFIX_REMOVE=
D,
> > +                             info);
> > +     icmp6_route_info_free(info, NULL);
>
> Same as above here?
>
> > +}
> >
> > -             if (!inet_ntop(AF_INET6, info->address, buf, sizeof(buf)))
> > -                     continue;
> > +/* Mostly RFC4861 Section 6.3.4 */
> > +static void icmp6_router_update(struct l_icmp6_client *client,
> > +                             struct l_icmp6_router *r,
> > +                             struct l_icmp6_router *new_ra)
> > +{
> > +     bool changed =3D false;
> > +     enum l_icmp6_client_event event =3D -1;
> >
> > -             rt =3D l_rtnl_route_new_prefix(buf, info->prefix_len);
> > -             if (!rt)
> > -                     continue;
> > +     if (r) {
> > +             uint64_t new_expiry =3D 0;
> >
> > -             l_rtnl_route_set_preference(rt, info->preference);
> > -             l_rtnl_route_set_protocol(rt, RTPROT_RA);
> > -             l_rtnl_route_set_mtu(rt, ra->mtu);
> > -             l_rtnl_route_set_priority(rt, client->route_priority);
> > -             l_queue_push_tail(client->routes, rt);
> > +             r->lifetime =3D new_ra->lifetime;
> >
> > +             if (r->lifetime)
> > +                     new_expiry =3D new_ra->ra_timestamp +
> > +                             r->lifetime * L_USEC_PER_SEC;
> > +
> > +             if (r->default_expiry !=3D new_expiry) {
> > +                     r->default_expiry =3D new_expiry;
> > +                     changed =3D true;
> > +             }
> > +
> > +             if (new_ra->mtu) {
> > +                     r->mtu =3D new_ra->mtu;
> > +                     changed =3D true;
> > +             }
> > +     } else
> > +             r =3D new_ra;
> > +
>
> One thing to keep in mind is that for us, the 99% use case is a single ro=
uter
> that keeps sending the same RA message every several seconds.  The net ef=
fect is
> that the same route info keeps getting re-uploaded to the kernel every few
> seconds.  I think this is pointless and we need to optimize that.

What we could do is not set lifetimes on the RTNL routes and delete
them ourselves, then we wouldn't have to update their lifetimes.

> Maybe
> something along these lines:
>
> - If RA is binary the same, extract the new lifetime.
> - If the lifetime of the gateway route (timestamped at the time when we s=
ent the
> NEWROUTE message) is still at least N% of the original lifetime, then do =
nothing.
> - Otherwise, re-upload the route to the kernel

That sounds very complicated but maybe it's also an option, ideally
though I'd do this when we have the basic version working.

>
> I guess for external client purposes (NM) you may want to make the N above
> configurable and emit the event on every RA.  Seems wasteful though?
>
> Also, are you sure that we need to fully remove the route just to change =
the
> lifetime?

So with a quick search right now I can't see the place where it checks
whether a route already exists, it might be that we can create
duplicates which would also be bad... I'll try to look deeper in the
kernel, this doesn't seem to be documented.

Best regards
--===============3869789888430854796==--

