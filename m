Content-Type: multipart/mixed; boundary="===============5844103981013526113=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH 03/12] netconfig: Add DHCP override and static IP API
Date: Thu, 21 Apr 2022 14:47:19 -0500
Message-ID: <c3a07449-ba00-4e89-7153-c4c2f8f998d9@gmail.com>
In-Reply-To: 20220421154525.1416984-3-andrew.zaborowski@intel.com

--===============5844103981013526113==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 4/21/22 10:45, Andrew Zaborowski wrote:
> Add API to override things like DNS, domain names, etc. received from
> DHCP or disable DHCP completely by setting a static address.
> ---
>   ell/ell.sym     |   8 ++
>   ell/netconfig.c | 349 +++++++++++++++++++++++++++++++++++++++++++++++-
>   ell/netconfig.h |  16 +++
>   3 files changed, 368 insertions(+), 5 deletions(-)
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

switch (family) {
case AF_INET:
	ptr =3D &netconfig->v4_static_addr;
	break;
case AF_INET6:
	ptr =3D &netconfig->v6_static_addr;
	break;
default:
	return false;
}

l_rtnl_address_free(*ptr);
*ptr =3D NULL;
...

> +	switch (family) {
> +	case AF_INET:
> +		l_rtnl_address_free(l_steal_ptr(netconfig->v4_static_addr));
> +
> +		if (!addr)
> +			break;
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
> +		if (!addr)
> +			break;
> +
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
> +LIB_EXPORT bool l_netconfig_set_gateway_override(struct l_netconfig *net=
config,
> +							uint8_t family,
> +							const char *gateway_str)
> +{
> +	if (unlikely(!netconfig || netconfig->started))
> +		return false;
> +
> +	switch (family) {
> +	case AF_INET:
> +		l_free(l_steal_ptr(netconfig->v4_gateway_override));
> +
> +		if (!gateway_str)
> +			break;
> +
> +		netconfig->v4_gateway_override =3D l_strdup(gateway_str);
> +		return true;
> +	case AF_INET6:
> +		l_free(l_steal_ptr(netconfig->v6_gateway_override));
> +
> +		if (!gateway_str)
> +			break;
> +
> +		netconfig->v6_gateway_override =3D l_strdup(gateway_str);
> +		return true;
> +	}
> +
> +	return false;
> +}

As above.

> +
> +LIB_EXPORT bool l_netconfig_set_dns_override(struct l_netconfig *netconf=
ig,
> +						uint8_t family, char **dns_list)
> +{
> +	if (unlikely(!netconfig || netconfig->started))
> +		return false;
> +
> +	switch (family) {
> +	case AF_INET:
> +		l_strv_free(l_steal_ptr(netconfig->v4_dns_override));
> +
> +		if (!dns_list)
> +			break;
> +
> +		netconfig->v4_dns_override =3D l_strv_copy(dns_list);
> +		return true;
> +	case AF_INET6:
> +		l_strv_free(l_steal_ptr(netconfig->v6_dns_override));
> +
> +		if (!dns_list)
> +			break;
> +
> +		netconfig->v6_dns_override =3D l_strv_copy(dns_list);
> +		return true;
> +	}

And here too...

> +
> +	return false;
> +}
> +
> +LIB_EXPORT bool l_netconfig_set_domain_names_override(
> +						struct l_netconfig *netconfig,
> +						uint8_t family, char **names)
> +{
> +	if (unlikely(!netconfig || netconfig->started))
> +		return false;
> +
> +	switch (family) {
> +	case AF_INET:
> +		l_strv_free(l_steal_ptr(netconfig->v4_domain_names_override));
> +
> +		if (!names)
> +			break;
> +
> +		netconfig->v4_domain_names_override =3D l_strv_copy(names);
> +		return true;
> +	case AF_INET6:
> +		l_strv_free(l_steal_ptr(netconfig->v6_domain_names_override));
> +
> +		if (!names)
> +			break;
> +
> +		netconfig->v6_domain_names_override =3D l_strv_copy(names);
> +		return true;
> +	}
> +

And here

> +	return false;
> +}
> +
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
> +		if (!l_net_prefix_matches(&local, &gateway, prefix_len))
> +			return false;
> +

I know you're trying to be nice, but we should not be doing this.  Static =

configuration is for expert users, and if they want to shoot themselves in =
the =

foot, then I say let them.

Besides, such policy enforcement should not be done by netconfig itself.  T=
hat =

should be done by a layer above, or you should provide a policy enforcement =

abstraction that the caller could provide to netconfig.  Not something we c=
are =

about at the moment.

> +	/*
> +	 * If using a static IP and there's no gateway all the DNSes must be on
> +	 * the local subnet too.
> +	 */
> +	if (netconfig->v4_static_addr && !netconfig->v4_gateway_override &&
> +			netconfig->v4_dns_override) {
> +		unsigned int i;
> +
> +		for (i =3D 0; i < dns_num; i++)
> +			if (!l_net_prefix_matches(&local, &dns_list[i],
> +							prefix_len))
> +				return false;
> +	}

As above here

> +
> +	return true;
> +}
> +

Regards,
-Dens
--===============5844103981013526113==--

