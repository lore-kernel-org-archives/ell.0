Content-Type: multipart/mixed; boundary="===============5477301669507517262=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH 4/5] icmp6: Track routers and prefix routes from multiple
 RAs
Date: Fri, 07 Jan 2022 11:47:28 -0600
Message-ID: <38599430-89de-66bd-c7e9-d0875674a086@gmail.com>
In-Reply-To: 20220106150529.458775-4-andrew.zaborowski@intel.com

--===============5477301669507517262==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 1/6/22 09:05, Andrew Zaborowski wrote:
> Add tracking of default/non-default routers and prefix routes in
> separate lists that are updated with new information from new RAs.
> This is gets us closer to what RFC4861 mandates.
> =


So I'm still reviewing this, but let me share some preliminary thoughts and=
 see =

what you think.

> There's no single client->routes list now, there are two lists, one for
> the routers and one for prefix routes.  According to the RFC there's no
> relation between the prefix routes and which router's RA they were
> received in (same prefixes can be received from multiple routers).

While this makes sense on some level, I'm actually concerned that this can =
lead =

to real weirdness.  For example, you might have one RA broadcasting a prefi=
x =

with a non-zero lifetime and another RA broadcasting the same prefix with a =

lifetime of 0.  They might also have differing priority, mtu or valid lifet=
ime =

information.  It may be easier to just simply set the info into the kernel =
and =

let it deal with it.

I actually wonder how common this actually is in the real world?

> =

> The DHCP6 behaviour should be unchanged for now, it'll still only use
> the first router that sent an announcement.  The public API is also
> unchnaged for now except for new events.

As you point out, this patch is getting rather long.  Perhaps you want to b=
reak =

it up and add the ROUTER and PREFIX events in separate commits.

Also, some of these events are somewhat useless if icmp6 is responsible for =

setting the routes into the kernel.  Maybe they shouldn't even be fired in =
this =

case.

> ---
> There are some rought corners in this code but the commit is already a
> little big.  For example the route_info structure we use for prefix
> routes is actually sent to clients in event_data but the structure is
> private so it's useless to the clients as is.

This might need to be figured out first.

> =

> Also icmp6 may end up using a lot of timeouts since we have to track
> router timeouts and prefix route timeouts.  In this case it would be
> pretty easy to convert all those timeouts into one that only tracks the
> soonest expiry event so I'd be happy to do that.  We can't really avoid
> tracking the lifetimes if we want to correctly implement the RFC.

This is another part that seriously concerns me right now.  I actually wond=
er =

why we would need to use timeouts at all?  If we set the lifetime into the =

kernel, then it can take care of removing these routes (assuming it doesn't=
 just =

leave them in there with lifetime 0).

> ---
>   ell/dhcp6.c         |  15 +-
>   ell/icmp6-private.h |  13 ++
>   ell/icmp6.c         | 339 ++++++++++++++++++++++++++++++++++++--------
>   ell/icmp6.h         |   6 +
>   4 files changed, 313 insertions(+), 60 deletions(-)
> =


<snip>

> @@ -292,53 +292,242 @@ static bool icmp6_client_remove_route(void *data, =
void *user_data)
>   	return true;
>   }
>   =

> -static void icmp6_client_setup_routes(struct l_icmp6_client *client)
> +static void icmp6_router_timeout(struct l_timeout *timeout, void *user_d=
ata)
>   {
> -	struct l_icmp6_router *ra =3D client->ra;
> -	struct l_rtnl_route *rt;
> -	char buf[INET6_ADDRSTRLEN];
> -	unsigned int i;
> +	struct l_icmp6_router *r =3D user_data;
>   =

> -	rt =3D l_rtnl_route_new_gateway(inet_ntop(AF_INET6, ra->address,
> -							buf, sizeof(buf)));
> -	if (!rt) {
> -		CLIENT_DEBUG("Unable to parse RA 'from' address");
> -		return;
> -	}
> +	icmp6_client_remove_route(l_steal_ptr(r->default_route), r->client);
> +	l_timeout_remove(l_steal_ptr(r->default_timeout));
> +	r->default_expiry =3D 0;
>   =

> -	l_rtnl_route_set_preference(rt, ra->pref);
> -	l_rtnl_route_set_protocol(rt, RTPROT_RA);
> -	l_rtnl_route_set_mtu(rt, ra->mtu);
> -	l_rtnl_route_set_priority(rt, client->route_priority);
> -	l_queue_push_tail(client->routes, rt);
> +	icmp6_client_event_notify(r->client,
> +				L_ICMP6_CLIENT_EVENT_DEFAULT_ROUTER_REMOVED, r);

What does the kernel do when a default route reaches 0 lifetime?  Can we li=
sten =

to DELROUTE events and infer that the lifetime expired based on the timesta=
mp of =

the event and our own records?

> +}
>   =

> -	if (client->rtnl)
> -		l_rtnl_route_add(client->rtnl, client->ifindex, rt,
> -					NULL, NULL, NULL);
> +static bool icmp6_route_info_free(void *data, void *user_data) {
> +	struct route_info *info =3D data;
>   =

> -	for (i =3D 0; i < ra->n_prefixes; i++) {
> -		struct route_info *info =3D &ra->prefixes[i];
> +	icmp6_client_remove_route(info->route, info->client);
> +	l_timeout_remove(info->timeout);
> +	l_free(info);
> +	return true;
> +}
> +
> +static void icmp6_prefix_timeout(struct l_timeout *timeout, void *user_d=
ata)
> +{
> +	struct route_info *info =3D user_data;
>   =

> -		if (info->valid_lifetime =3D=3D 0)
> -			continue;
> +	l_queue_remove(info->client->prefix_routes, info);
> +	icmp6_client_event_notify(info->client,
> +				L_ICMP6_CLIENT_EVENT_ONLINK_PREFIX_REMOVED,
> +				info);
> +	icmp6_route_info_free(info, NULL);

Same as above here?

> +}
>   =

> -		if (!inet_ntop(AF_INET6, info->address, buf, sizeof(buf)))
> -			continue;
> +/* Mostly RFC4861 Section 6.3.4 */
> +static void icmp6_router_update(struct l_icmp6_client *client,
> +				struct l_icmp6_router *r,
> +				struct l_icmp6_router *new_ra)
> +{
> +	bool changed =3D false;
> +	enum l_icmp6_client_event event =3D -1;
>   =

> -		rt =3D l_rtnl_route_new_prefix(buf, info->prefix_len);
> -		if (!rt)
> -			continue;
> +	if (r) {
> +		uint64_t new_expiry =3D 0;
>   =

> -		l_rtnl_route_set_preference(rt, info->preference);
> -		l_rtnl_route_set_protocol(rt, RTPROT_RA);
> -		l_rtnl_route_set_mtu(rt, ra->mtu);
> -		l_rtnl_route_set_priority(rt, client->route_priority);
> -		l_queue_push_tail(client->routes, rt);
> +		r->lifetime =3D new_ra->lifetime;
>   =

> +		if (r->lifetime)
> +			new_expiry =3D new_ra->ra_timestamp +
> +				r->lifetime * L_USEC_PER_SEC;
> +
> +		if (r->default_expiry !=3D new_expiry) {
> +			r->default_expiry =3D new_expiry;
> +			changed =3D true;
> +		}
> +
> +		if (new_ra->mtu) {
> +			r->mtu =3D new_ra->mtu;
> +			changed =3D true;
> +		}
> +	} else
> +		r =3D new_ra;
> +

One thing to keep in mind is that for us, the 99% use case is a single rout=
er =

that keeps sending the same RA message every several seconds.  The net effe=
ct is =

that the same route info keeps getting re-uploaded to the kernel every few =

seconds.  I think this is pointless and we need to optimize that.  Maybe =

something along these lines:

- If RA is binary the same, extract the new lifetime.
- If the lifetime of the gateway route (timestamped at the time when we sen=
t the =

NEWROUTE message) is still at least N% of the original lifetime, then do no=
thing.
- Otherwise, re-upload the route to the kernel

I guess for external client purposes (NM) you may want to make the N above =

configurable and emit the event on every RA.  Seems wasteful though?

Also, are you sure that we need to fully remove the route just to change th=
e =

lifetime?

> @@ -347,31 +536,53 @@ static int icmp6_client_handle_message(struct l_icm=
p6_client *client,
>   						const struct in6_addr *src)
>   {
>   	struct l_icmp6_router *r =3D _icmp6_router_parse(ra, len, src->s6_addr=
);
> +	struct l_icmp6_router *old_ra;
> +	unsigned int i;
>   =

>   	if (!r)
>   		return -EBADMSG;
>   =

> -	if (!client->ra) {
> -		client->ra =3D r;
> +	old_ra =3D l_queue_remove_if(client->routers, icmp6_router_match_addres=
s,
> +					r->address);
> +	if (old_ra) {
> +		/* Move to the head of the queue */
> +		l_queue_push_head(client->routers, old_ra);
> +	} else {
> +		r->ra_timestamp =3D l_time_now();
> +		r->client =3D client;
> +		l_queue_push_head(client->routers, r);
> +
>   		icmp6_client_event_notify(client,
>   					L_ICMP6_CLIENT_EVENT_ROUTER_FOUND,
>   					NULL);
>   =

>   		/* DHCP6 client may have stopped us */
> -		if (!client->ra)
> +		if (!client->io)
>   			return -ECANCELED;
> +	}
>   =

> -		icmp6_client_setup_routes(client);
> -		return 0;
> +	icmp6_router_update(client, old_ra, r);
> +
> +	if (!client->io)
> +		goto done;
> +
> +	for (i =3D 0; i < r->n_prefixes; i++) {
> +		struct route_info *info =3D &r->prefixes[i];
> +		struct route_info *old_info =3D
> +			l_queue_remove_if(client->prefix_routes,
> +						icmp6_route_match_prefix, info);
> +

As mentioned above, I wonder if this is the right approach.

> +		icmp6_onlink_prefix_update(client, r, old_info, info);
> +
> +		if (!client->io)
> +			goto done;
>   	}
>   =


Regards,
-Denis
--===============5477301669507517262==--

