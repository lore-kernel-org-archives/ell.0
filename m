Content-Type: multipart/mixed; boundary="===============7107933873135070759=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH 1/4] rtnl: Add l_rtnl_route_set_gateway
Date: Mon, 03 Jan 2022 12:37:59 -0600
Message-ID: <492f1eb9-7785-55b2-2479-3c2b88c7b48d@gmail.com>
In-Reply-To: 20220103141830.311011-1-andrew.zaborowski@intel.com

--===============7107933873135070759==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 1/3/22 08:18, Andrew Zaborowski wrote:
> Allow creating prefix routes for off-link prefixes, i.e. ones that
> should be routed through a gateway.
> ---
>   ell/ell.sym |  1 +
>   ell/rtnl.c  | 16 ++++++++++++++++
>   ell/rtnl.h  |  1 +
>   3 files changed, 18 insertions(+)
> =


<snip>

>   =

> +LIB_EXPORT bool l_rtnl_route_set_gateway(struct l_rtnl_route *rt,
> +						const char *address)
> +{
> +	if (unlikely(!rt))
> +		return false;
> +
> +	switch (rt->family) {
> +	case AF_INET:
> +		return inet_pton(AF_INET, address, &rt->gw.in_addr) =3D=3D 1;
> +	case AF_INET6:
> +		return inet_pton(AF_INET6, address, &rt->gw.in6_addr) =3D=3D 1;
> +	default:
> +		return  false;
> +	}
> +}
> +

Since we already have l_rtnl_route_new_gateway, would this make more sense =
as a =

dedicated constructor? Something like l_rtnl_route_new_static?

>   LIB_EXPORT uint32_t l_rtnl_route_get_lifetime(const struct l_rtnl_route=
 *rt)
>   {
>   	if (unlikely(!rt))

Regards,
-Denis
--===============7107933873135070759==--

