Content-Type: multipart/mixed; boundary="===============6452987173087302631=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH 02/11] netconfig: Add DHCP override and static IP API
Date: Mon, 18 Apr 2022 14:15:41 -0500
Message-ID: <39949927-436f-7869-5957-2342b5364800@gmail.com>
In-Reply-To: 20220411142056.817784-2-andrew.zaborowski@intel.com

--===============6452987173087302631==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 4/11/22 09:20, Andrew Zaborowski wrote:
> Add API to override things like DNS, gateway/router address, domain
> names, etc. received from DHCP or disable DHCP completely by setting
> a static address.
> ---
>   ell/ell.sym     |   8 +
>   ell/netconfig.c | 413 +++++++++++++++++++++++++++++++++++++++++++++++-
>   ell/netconfig.h |  16 ++
>   3 files changed, 432 insertions(+), 5 deletions(-)
> =


<snip>

> +LIB_EXPORT bool l_netconfig_set_static_addr(struct l_netconfig *netconfi=
g,
> +					uint8_t family,
> +					const struct l_rtnl_address *addr)
> +{
> +	if (unlikely(!netconfig || netconfig->started))
> +		return false;
> +
> +	if (addr && l_rtnl_address_get_family(addr) !=3D family)
> +		return false;
> +
> +	switch (family) {
> +	case AF_INET:
> +		l_rtnl_address_free(l_steal_ptr(netconfig->v4_static_addr));
> +
> +		if (addr)
> +			break;

I take it this should be !addr?

> +
> +		netconfig->v4_static_addr =3D l_rtnl_address_clone(addr);
> +		l_rtnl_address_set_lifetimes(netconfig->v4_static_addr, 0, 0);
> +
> +		/*
> +		 * We could leave the decision about this flag up to the
> +		 * caller but for simplicity override to true.
> +		 */
> +		l_rtnl_address_set_noprefixroute(netconfig->v4_static_addr,
> +							true);
> +		return true;
> +	case AF_INET6:
> +		l_rtnl_address_free(l_steal_ptr(netconfig->v6_static_addr));
> +
> +		if (addr)
> +			break;
> +

And here as well?

> +		netconfig->v6_static_addr =3D l_rtnl_address_clone(addr);
> +		l_rtnl_address_set_lifetimes(netconfig->v6_static_addr, 0, 0);
> +		l_rtnl_address_set_noprefixroute(netconfig->v6_static_addr,
> +							true);
> +		return true;
> +	}
> +
> +	return false;
> +}
> +

<snip>

> +static bool netconfig_check_v4_config(struct l_netconfig *netconfig)
> +{
> +	struct in_addr local;
> +	struct in_addr gateway;
> +	uint8_t prefix_len =3D 0;
> +	unsigned int dns_num =3D 0;
> +	_auto_(l_free) struct in_addr *dns_list =3D NULL;
> +
> +	if (!netconfig->v4_enabled)
> +		return true;
> +
> +	if (netconfig->v4_static_addr) {
> +		char str[INET_ADDRSTRLEN];
> +
> +		prefix_len =3D l_rtnl_address_get_prefix_length(
> +						netconfig->v4_static_addr);
> +		if (prefix_len > 30)
> +			return false;
> +
> +		l_rtnl_address_get_address(netconfig->v4_static_addr, str);
> +		inet_pton(AF_INET, str, &local);
> +	}
> +
> +	if (netconfig->v4_gateway_override) {
> +		if (inet_pton(AF_INET, netconfig->v4_gateway_override,
> +				&gateway) !=3D 1)
> +			return false;
> +	}
> +
> +	if (netconfig->v4_dns_override &&
> +			(dns_num =3D l_strv_length(netconfig->v4_dns_override))) {
> +		unsigned int i;
> +
> +		dns_list =3D l_new(struct in_addr, dns_num);
> +
> +		for (i =3D 0; i < dns_num; i++)
> +			if (inet_pton(AF_INET, netconfig->v4_dns_override[i],
> +					&dns_list[i]) !=3D 1)
> +				return false;
> +	}
> +
> +	/*
> +	 * If using a static IP, we can validate right now that the gateway is
> +	 * in the local subnet.
> +	 */
> +	if (netconfig->v4_static_addr && netconfig->v4_gateway_override)
> +		if (!l_net_subnet_matches(&local, &gateway, prefix_len))
> +			return false;
> +
> +	/*
> +	 * If using a static IP and there's no gateway all the DNSes mut be on

typo: mut -> must

> +	 * the local subnet too.
> +	 */
> +	if (netconfig->v4_static_addr && !netconfig->v4_gateway_override &&
> +			netconfig->v4_dns_override) {
> +		unsigned int i;
> +
> +		for (i =3D 0; i < dns_num; i++)
> +			if (!l_net_subnet_matches(&local, &dns_list[i],
> +							prefix_len))
> +				return false;
> +	}
> +
> +	return true;
> +}
> +
> +static bool netconfig_check_v6_config(struct l_netconfig *netconfig)
> +{
> +	struct in_addr local;
> +	struct in_addr gateway;
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
> +		if (prefix_len > 126)
> +			return false;
> +
> +		l_rtnl_address_get_address(netconfig->v6_static_addr, str);
> +		inet_pton(AF_INET6, str, &local);
> +	}
> +
> +	if (netconfig->v6_gateway_override) {
> +		if (inet_pton(AF_INET6, netconfig->v6_gateway_override,
> +				&gateway) !=3D 1)
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
> +	/*
> +	 * If using a static IP, we can validate right now that the gateway is
> +	 * in the local subnet.
> +	 */
> +	if (netconfig->v6_static_addr && netconfig->v6_gateway_override)
> +		if (!l_net_subnet_matches(&local, &gateway, prefix_len))
> +			return false;

Not sure this is true?  AFAIK the default gateway could be a link local add=
ress...

> +
> +	/*
> +	 * If using a static IP and there's no gateway all the DNSes mut be on

Same typo as above.

> +	 * the local subnet too.
> +	 */
> +	if (netconfig->v6_static_addr && !netconfig->v6_gateway_override &&
> +			netconfig->v6_dns_override) {
> +		unsigned int i;
> +
> +		for (i =3D 0; i < dns_num; i++)
> +			if (!l_net_subnet_matches(&local, &dns_list[i],
> +							prefix_len))
> +				return false;

This whole block maybe should be a static convenience function?  In fact, m=
uch =

of these checks are the same as in v4 version of this function and could be =

combined?

> +	}
> +
> +	return true;
> +}
> +

<snip>

>   LIB_EXPORT bool l_netconfig_start(struct l_netconfig *netconfig)
>   {
>   	if (unlikely(!netconfig || netconfig->started))
>   		return false;
>   =

> -	if (netconfig->v4_enabled &&
> -			!l_dhcp_client_start(netconfig->dhcp_client))
> +	if (!netconfig_check_config(netconfig))
>   		return false;
>  =


Can we check that both v4_enabled and v6_enabled are false and return appro=
priately?

> -	netconfig->started =3D true;
> +	if (netconfig->v4_enabled) {

I'd prefer less nesting, so something like:

if (!netconfig->v4_enabled)
	goto configure_ipv6;

> +		if (netconfig->v4_static_addr) {
> +			/*
> +			 * We're basically ready to configure the interface
> +			 * but do this in an idle callback.
> +			 */
> +			netconfig->do_static_work =3D l_idle_create(
> +						netconfig_do_static_config,
> +						netconfig, NULL);

goto here..

> +		} else {
> +			if (!l_dhcp_client_start(netconfig->dhcp_client))
> +				return false;
> +		}
> +	}
>   =

> +	netconfig->started =3D true;
>   	return true;
>   }
>   =


<snip>

> diff --git a/ell/netconfig.h b/ell/netconfig.h
> index 682f4aa..aab9d3f 100644
> --- a/ell/netconfig.h
> +++ b/ell/netconfig.h
> @@ -53,6 +53,22 @@ typedef void (*l_netconfig_destroy_cb_t)(void *user_da=
ta);
>   =

>   struct l_netconfig *l_netconfig_new(uint32_t ifindex);
>   void l_netconfig_destroy(struct l_netconfig *netconfig);
> +bool l_netconfig_set_af_enabled(struct l_netconfig *netconfig, uint8_t f=
amily,
> +				bool enabled);

Can we call it family_enabled?

> +bool l_netconfig_set_static_addr(struct l_netconfig *netconfig, uint8_t =
family,
> +					const struct l_rtnl_address *addr);
> +bool l_netconfig_set_gateway_override(struct l_netconfig *netconfig,
> +					uint8_t family,
> +					const char *gateway_str);

Wonder why you use l_rtnl_address for 'set_static_addr' and a string for th=
e =

gateway?

Regards,
-Denis
--===============6452987173087302631==--

