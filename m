Content-Type: multipart/mixed; boundary="===============1402595771263613027=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH 04/13] netconfig: Support IPv6 static configurations
Date: Wed, 27 Apr 2022 08:30:28 -0500
Message-ID: <d40420e6-e9c5-c6a4-b007-ee43c6e5b0dd@gmail.com>
In-Reply-To: 20220422185952.105279-4-andrew.zaborowski@intel.com

--===============1402595771263613027==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 4/22/22 13:59, Andrew Zaborowski wrote:
> ---
>   ell/netconfig.c | 148 ++++++++++++++++++++++++++++++++++++++++++++++--
>   1 file changed, 143 insertions(+), 5 deletions(-)
> =


So I was going to apply this, but let me ask you this first...

<snip>

> @@ -159,6 +161,50 @@ static void netconfig_add_v4_routes(struct l_netconf=
ig *nc, const char *ip,
>   	l_queue_push_tail(nc->routes.added, nc->v4_default_route);
>   }
>   =

> +static void netconfig_add_v6_static_routes(struct l_netconfig *nc,
> +						const char *ip,
> +						uint8_t prefix_len)
> +{
> +	struct in6_addr in6_addr;
> +	char network[INET6_ADDRSTRLEN];
> +	struct l_rtnl_route *v6_subnet_route;
> +	struct l_rtnl_route *v6_default_route;
> +
> +	/* Subnet route */
> +
> +	if (L_WARN_ON(inet_pton(AF_INET6, ip, &in6_addr) !=3D 1))
> +		return;
> +
> +	/* Zero out host address bits to produce network address */
> +	if (prefix_len & 7)
> +		in6_addr.s6_addr[prefix_len / 8] &=3D 0xff00 >> (prefix_len & 7);

Can we make this a bit cleaner? Something like

last_byte =3D prefix_len / 8;

if (prefix_len & 7) {
	/* zero out lsb bits */
	last_byte +=3D 1;
}

memset(in6_addr + last_byte, 0, 16 - last_byte);

However, the more general question here is why do we want to store and comp=
ute =

the prefix route separately?  Is the assumption here that all addresses use=
 the =

noprefixroute flag?  Wouldn't it be simpler to just have the kernel handle =
this?

> +
> +	if (prefix_len <=3D 120)
> +		memset(in6_addr.s6_addr + (prefix_len + 7) / 8, 0,
> +			16 - (prefix_len + 7) / 8);
> +
> +	if (L_WARN_ON(!inet_ntop(AF_INET6, &in6_addr, network,
> +					INET6_ADDRSTRLEN)))
> +		return;
> +
> +	v6_subnet_route =3D l_rtnl_route_new_prefix(network, prefix_len);
> +	l_rtnl_route_set_protocol(v6_subnet_route, RTPROT_STATIC);
> +	l_rtnl_route_set_priority(v6_subnet_route, nc->route_priority);
> +	l_queue_push_tail(nc->routes.current, v6_subnet_route);
> +	l_queue_push_tail(nc->routes.added, v6_subnet_route);
> +
> +	/* Gateway route */
> +
> +	if (!nc->v6_gateway_override)
> +		return;
> +
> +	v6_default_route =3D l_rtnl_route_new_gateway(nc->v6_gateway_override);
> +	l_rtnl_route_set_protocol(v6_default_route, RTPROT_STATIC);
> +	L_WARN_ON(!l_rtnl_route_set_prefsrc(v6_default_route, ip));
> +	l_queue_push_tail(nc->routes.current, v6_default_route);
> +	l_queue_push_tail(nc->routes.added, v6_default_route);
> +}
> +
>   static void netconfig_add_dhcp_address_routes(struct l_netconfig *nc)
>   {
>   	const struct l_dhcp_lease *lease =3D

<snip>

> @@ -580,11 +629,56 @@ static bool netconfig_check_v4_config(struct l_netc=
onfig *netconfig)
>   	return true;
>   }
>   =

> +static bool netconfig_check_v6_config(struct l_netconfig *netconfig)
> +{
> +	struct in6_addr local;
> +	struct in6_addr gateway;
> +	uint8_t prefix_len =3D 0;
> +	unsigned int dns_num =3D 0;
> +	_auto_(l_free) struct in6_addr *dns_list =3D NULL;
> +
> +	if (!netconfig->v6_enabled)
> +		return true;
> +
> +	if (netconfig->v6_static_addr) {
> +		char str[INET6_ADDRSTRLEN];
> +
> +		prefix_len =3D l_rtnl_address_get_prefix_length(
> +						netconfig->v6_static_addr);
> +		if (unlikely(prefix_len > 126))
> +			return false;
> +
> +		l_rtnl_address_get_address(netconfig->v6_static_addr, str);
> +		inet_pton(AF_INET6, str, &local);
> +	}
> +
> +	if (netconfig->v6_gateway_override) {
> +		if (unlikely(inet_pton(AF_INET6, netconfig->v6_gateway_override,
> +					&gateway) !=3D 1))
> +			return false;
> +	}
> +
> +	if (netconfig->v6_dns_override &&
> +			(dns_num =3D l_strv_length(netconfig->v6_dns_override))) {
> +		unsigned int i;
> +
> +		dns_list =3D l_new(struct in6_addr, dns_num);
> +
> +		for (i =3D 0; i < dns_num; i++)
> +			if (inet_pton(AF_INET6, netconfig->v6_dns_override[i],
> +					&dns_list[i]) !=3D 1)
> +				return false;
> +	}
> +

All this checking is pure copy-paste of the v4 version.  Can they be combin=
ed?

> +	return true;
> +}
> +
>   static bool netconfig_check_config(struct l_netconfig *netconfig)
>   {
>   	/* TODO: error reporting through a debug log handler or otherwise */
>   =

> -	return netconfig_check_v4_config(netconfig);
> +	return netconfig_check_v4_config(netconfig) &&
> +		netconfig_check_v6_config(netconfig);
>   }
>   =

>   LIB_EXPORT bool l_netconfig_check_config(struct l_netconfig *netconfig)

Regards,
-Denis
--===============1402595771263613027==--

