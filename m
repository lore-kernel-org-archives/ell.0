Content-Type: multipart/mixed; boundary="===============8139862806759152899=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH 11/12] netconfig: Add DHCP override and static IP API
Date: Fri, 11 Mar 2022 11:07:24 -0600
Message-ID: <1aa3437c-0cdf-2684-3f10-a50de35e61d1@gmail.com>
In-Reply-To: 20220307145543.1558788-11-andrew.zaborowski@intel.com

--===============8139862806759152899==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 3/7/22 08:55, Andrew Zaborowski wrote:
> Add API to override things like DNS, gateway/router address, domain
> names, etc. received from DHCP or disable DHCP completely by setting
> a static address.
> ---
>   ell/ell.sym     |   8 +
>   ell/netconfig.c | 424 +++++++++++++++++++++++++++++++++++++++++++++++-
>   ell/netconfig.h |  17 ++
>   3 files changed, 445 insertions(+), 4 deletions(-)
> =


<snip>

> @@ -322,15 +352,396 @@ LIB_EXPORT void l_netconfig_destroy(struct l_netco=
nfig *netconfig)
>   	l_free(netconfig);
>   }
>   =

> -LIB_EXPORT bool l_netconfig_start(struct l_netconfig *netconfig)
> +/*
> + * The following l_netconfig_set_* functions configure the l_netconfig's
> + * client settings.  The setters can be called independently, without
> + * following a specific order.  Most of the setters will not validate the
> + * values passed, l_netconfig_start() will fail if settings are incorrect
> + * or inconsistent between themselves, e.g. if the static local IP and
> + * gateway IP are not in the same subnet.  Alternatively
> + * l_netconfig_check_config() can be called at any point to validate the
> + * current configuration.  The configuration can only be changed while
> + * the l_netconfig state machine is stopped, i.e. before
> + * l_netconfig_start() and after l_netconfig_stop().
> + *
> + * l_netconfig_set_hostname, l_netconfig_set_static_addr,
> + * l_netconfig_set_gateway_override, l_netconfig_set_dns_override and
> + * l_netconfig_set_domain_names_override can be passed NULL to unset a
> + * value that had been set before (revert to auto).  This is why the
> + * family parameter is needed even when it could otherwise be derived
> + * from the new value that is passed.
> + */
> +LIB_EXPORT void l_netconfig_set_af_enabled(struct l_netconfig *netconfig,
> +						uint8_t family, bool enabled)
> +{
> +	if (unlikely(!netconfig || netconfig->started))
> +		return;

Should we at least return bool here?  In case family is invalid for example?

> +
> +	switch (family) {
> +	case AF_INET:
> +		netconfig->v4_enabled =3D enabled;
> +		break;
> +	}
> +}
> +
> +LIB_EXPORT void l_netconfig_set_hostname(struct l_netconfig *netconfig,
> +						const char *hostname)
> +{
> +	if (unlikely(!netconfig || netconfig->started))
> +		return;
> +
> +	l_dhcp_client_set_hostname(netconfig->dhcp_client, hostname);

Same with this?  In theory set_hostname might fail.

> +}
> +
> +LIB_EXPORT void l_netconfig_set_route_priority(struct l_netconfig *netco=
nfig,
> +						uint32_t priority)
> +{
> +	if (unlikely(!netconfig || netconfig->started))
> +		return;
> +
> +	netconfig->route_priority =3D priority;
> +}
> +
> +LIB_EXPORT void l_netconfig_set_static_addr(struct l_netconfig *netconfi=
g,
> +					uint8_t family,
> +					const struct l_rtnl_address *addr)
> +{
> +	if (unlikely(!netconfig || netconfig->started))
> +		return;
> +
> +	if (L_WARN_ON(addr && l_rtnl_address_get_family(addr) !=3D family))
> +		return;
> +
> +	switch (family) {
> +	case AF_INET:
> +		if (netconfig->v4_static_addr)
> +			l_rtnl_address_free(l_steal_ptr(
> +						netconfig->v4_static_addr));

Why not simply l_rtnl_address_free(l_steal_ptr...))?

> +
> +		if (addr)
> +			break;
> +
> +		netconfig->v4_static_addr =3D l_rtnl_address_clone(addr);
> +		l_rtnl_address_set_lifetimes(netconfig->v4_static_addr, 0, 0);
> +
> +		/*
> +		 * We could leave the decision about this flag up to the
> +		 * caller but for simplicity override to true.
> +		 */
> +		l_rtnl_address_set_noprefixroute(netconfig->v4_static_addr, true);

This line > 80 chars

> +		break;
> +	case AF_INET6:
> +		if (netconfig->v6_static_addr)
> +			l_rtnl_address_free(l_steal_ptr(
> +						netconfig->v6_static_addr));

As above, the if seems unnecessary.

> +
> +		if (addr)
> +			break;
> +
> +		netconfig->v6_static_addr =3D l_rtnl_address_clone(addr);
> +		l_rtnl_address_set_lifetimes(netconfig->v6_static_addr, 0, 0);
> +		l_rtnl_address_set_noprefixroute(netconfig->v6_static_addr, true);

This line > 80 chars

> +		break;
> +	}
> +}
> +
> +LIB_EXPORT void l_netconfig_set_gateway_override(struct l_netconfig *net=
config,
> +							uint8_t family,
> +							const char *gateway_str)
> +{
> +	if (unlikely(!netconfig || netconfig->started))
> +		return;
> +
> +	switch (family) {
> +	case AF_INET:
> +		l_free(l_steal_ptr(netconfig->v4_gateway_override));
> +
> +		if (!gateway_str)
> +			break;
> +
> +		netconfig->v4_gateway_override =3D l_strdup(gateway_str);
> +		break;
> +	case AF_INET6:
> +		l_free(l_steal_ptr(netconfig->v6_gateway_override));
> +
> +		if (!gateway_str)
> +			break;
> +
> +		netconfig->v6_gateway_override =3D l_strdup(gateway_str);
> +		break;
> +	}
> +}
> +
> +LIB_EXPORT void l_netconfig_set_dns_override(struct l_netconfig *netconf=
ig,
> +						uint8_t family,
> +						const char **dns_list)

Why const char **?  For const-correctness you'd likely need some C++ thing =
like =

'const char * const *'.  We generally fall back to simply char ** for situa=
tions =

like this.

> +{
> +	if (unlikely(!netconfig || netconfig->started))
> +		return;
> +
> +	switch (family) {
> +	case AF_INET:
> +		l_strv_free(l_steal_ptr(netconfig->v4_dns_override));
> +
> +		if (!dns_list)
> +			break;
> +
> +		netconfig->v4_dns_override =3D l_strv_copy((char **) dns_list);
> +		break;
> +	case AF_INET6:
> +		l_strv_free(l_steal_ptr(netconfig->v6_dns_override));
> +
> +		if (!dns_list)
> +			break;
> +
> +		netconfig->v6_dns_override =3D l_strv_copy((char **) dns_list);
> +		break;
> +	}
> +}
> +
> +LIB_EXPORT void l_netconfig_set_domain_names_override(
> +						struct l_netconfig *netconfig,
> +						uint8_t family,
> +						const char **names)

Same as above

> +{
> +	if (unlikely(!netconfig || netconfig->started))
> +		return;
> +
> +	switch (family) {
> +	case AF_INET:
> +		l_strv_free(l_steal_ptr(netconfig->v4_domain_names_override));
> +
> +		if (!names)
> +			break;
> +
> +		netconfig->v4_domain_names_override =3D
> +			l_strv_copy((char **) names);
> +		break;
> +	case AF_INET6:
> +		l_strv_free(l_steal_ptr(netconfig->v6_domain_names_override));
> +
> +		if (!names)
> +			break;
> +
> +		netconfig->v6_domain_names_override =3D
> +			l_strv_copy((char **) names);
> +		break;
> +	}
> +}
> +
> +static bool netconfig_match_subnet(const void *a, const void *b,
> +					uint8_t prefix_len)
> +{
> +	uint8_t bytes =3D prefix_len / 8;
> +	uint8_t bits =3D prefix_len & 7;
> +
> +	if (bytes && memcmp(a, b, bytes))
> +		return false;
> +
> +	return !bits ||
> +		((((const uint8_t *) a)[bytes] ^ ((const uint8_t *) b)[bytes]) &
> +		 (0xff00u >> bits)) =3D=3D 0;
> +}

Do we not have a similar function in iwd?  Perhaps this should be a utility =

function in l_net?  Also, with all the magic operations happening here, a f=
ew =

comments might be nice.

> +
Regards,
-Denis
--===============8139862806759152899==--

