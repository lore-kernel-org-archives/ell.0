Content-Type: multipart/mixed; boundary="===============6746736075115281110=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH 03/13] netconfig: Create routes from Router Advertisements
Date: Thu, 12 May 2022 11:14:02 -0500
Message-ID: <37eb260b-969e-e6a6-4c45-4f7ba26b1d0e@gmail.com>
In-Reply-To: 20220505231539.888792-3-andrew.zaborowski@intel.com

--===============6746736075115281110==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 5/5/22 18:15, Andrew Zaborowski wrote:
> If IPv6 is enabled, create the ICMP6 client and handle Router
> Advertisements received by creating, updating and removing routes per
> the data in the Router Advertisements.  Timeouts aren't handled yet.
> ---
>   ell/netconfig.c | 248 +++++++++++++++++++++++++++++++++++++++++++++++-
>   1 file changed, 246 insertions(+), 2 deletions(-)
> =


<snip>

>   =

> +static bool netconfig_match_ptr(const void *a, const void *b)
> +{
> +	return a =3D=3D b;
> +}
> +

Ugh, can we use l_queue_get_entries loop directly or a helper function inst=
ead?

>   static void netconfig_update_cleanup(struct l_netconfig *nc)
>   {
>   	l_queue_clear(nc->addresses.added, NULL);
> @@ -356,6 +367,224 @@ static void netconfig_dhcp_event_handler(struct l_d=
hcp_client *client,
>   	}
>   }
>   =

> +static struct l_rtnl_route *netconfig_find_icmp6_route(
> +						struct l_netconfig *nc,
> +						const uint8_t *gateway,
> +						const struct route_info *dst)
> +{
> +	const struct l_queue_entry *entry;
> +
> +	for (entry =3D l_queue_get_entries(nc->routes.current); entry;
> +			entry =3D entry->next) {
> +		struct l_rtnl_route *route =3D entry->data;
> +		const uint8_t *route_gateway;
> +		const uint8_t *route_dst;
> +		uint8_t route_prefix_len =3D 0;
> +
> +		if (l_rtnl_route_get_family(route) !=3D AF_INET6 ||
> +				l_rtnl_route_get_protocol(route) !=3D RTPROT_RA)
> +			continue;
> +
> +		route_gateway =3D l_rtnl_route_get_gateway_in_addr(route);
> +		if ((gateway || route_gateway) &&
> +				(!gateway || !route_gateway ||
> +				 memcmp(gateway, route_gateway, 16)))
> +			continue;
> +
> +		route_dst =3D l_rtnl_route_get_dst_in_addr(route,
> +							&route_prefix_len);
> +		if ((dst || route_prefix_len) &&
> +				(!dst || !route_prefix_len ||
> +				 dst->prefix_len !=3D route_prefix_len ||
> +				 memcmp(dst->address, route_dst,
> +					 (dst->prefix_len + 7) / 8)))

This might need a utility function, something like l_net_prefix_matches?

> +			continue;
> +
> +		return route;
> +	}
> +
> +	return NULL;
> +}
> +
> +static struct l_rtnl_route *netconfig_add_icmp6_route(struct l_netconfig=
 *nc,
> +						const uint8_t *gateway,
> +						const struct route_info *dst,
> +						uint8_t preference)
> +{
> +	struct l_rtnl_route *rt;
> +	char buf1[INET6_ADDRSTRLEN];
> +	char buf2[INET6_ADDRSTRLEN];
> +
> +	if (gateway && !dst)
> +		rt =3D l_rtnl_route_new_gateway(inet_ntop(AF_INET6, gateway,
> +							buf1, sizeof(buf1)));
> +	else if (dst && !gateway)
> +		rt =3D l_rtnl_route_new_prefix(inet_ntop(AF_INET6, dst->address,
> +							buf2, sizeof(buf2)),
> +						dst->prefix_len);
> +	else
> +		rt =3D l_rtnl_route_new_static(inet_ntop(AF_INET6, gateway,
> +							buf1, sizeof(buf1)),
> +						inet_ntop(AF_INET6,
> +							dst->address,
> +							buf2, sizeof(buf2)),
> +						dst->prefix_len);

We can move l_rtnl_route structure definition into rtnl-private.h if you pr=
efer =

to fill these in directly?

> +
> +	if (L_WARN_ON(!rt))
> +		return NULL;
> +
> +	l_rtnl_route_set_preference(rt, preference);
> +	l_rtnl_route_set_protocol(rt, RTPROT_RA);
> +	l_rtnl_route_set_priority(rt, nc->route_priority);
> +	l_queue_push_tail(nc->routes.current, rt);
> +	l_queue_push_tail(nc->routes.added, rt);
> +	return rt;
> +}
> +

<snip>

> @@ -398,6 +634,7 @@ LIB_EXPORT void l_netconfig_destroy(struct l_netconfi=
g *netconfig)
>   	l_netconfig_set_domain_names_override(netconfig, AF_INET6, NULL);
>   =

>   	l_dhcp_client_destroy(netconfig->dhcp_client);
> +	l_dhcp6_client_destroy(netconfig->dhcp6_client);
>   	l_netconfig_set_event_handler(netconfig, NULL, NULL, NULL);
>   	l_queue_destroy(netconfig->addresses.current, NULL);
>   	l_queue_destroy(netconfig->addresses.added, NULL);
> @@ -731,16 +968,22 @@ configure_ipv6:
>   	if (!netconfig->v6_enabled)
>   		goto done;
>   =

> -	if (netconfig->v6_static_addr && !netconfig->do_static_work) {
> +	if (netconfig->v6_static_addr) {
>   		/*
>   		 * We're basically ready to configure the interface
>   		 * but do this in an idle callback.
>   		 */
> -		netconfig->do_static_work =3D l_idle_create(
> +		if (!netconfig->do_static_work)
> +			netconfig->do_static_work =3D l_idle_create(
>   						netconfig_do_static_config,
>   						netconfig, NULL);
> +
> +		goto done;
>   	}
>   =

> +	if (!l_dhcp6_client_start(netconfig->dhcp6_client))
> +		return false;

What about the dhcp4 client started earlier?

> +
>   done:
>   	netconfig->started =3D true;
>   	return true;

<snip>

Regards,
-Denis
--===============6746736075115281110==--

