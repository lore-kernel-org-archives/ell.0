Content-Type: multipart/mixed; boundary="===============8078761236558702365=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH 04/17] netconfig: Create routes from Router Advertisements
Date: Wed, 18 May 2022 13:42:41 -0500
Message-ID: <75baec0d-b940-5fd0-2250-99907c641968@gmail.com>
In-Reply-To: 20220513224713.1447773-4-andrew.zaborowski@intel.com

--===============8078761236558702365==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 5/13/22 17:47, Andrew Zaborowski wrote:
> If IPv6 is enabled, create the ICMP6 client and handle Router
> Advertisements received by creating, updating and removing routes per
> the data in the Router Advertisements.  Timeouts aren't handled yet.
> ---
>   ell/netconfig.c | 293 +++++++++++++++++++++++++++++++++++++++++++++---
>   1 file changed, 278 insertions(+), 15 deletions(-)
> =


<snip>

> +static void netconfig_icmp6_event_handler(struct l_icmp6_client *client,
> +						enum l_icmp6_client_event event,
> +						void *event_data,
> +						void *user_data)
> +{
> +	struct l_netconfig *nc =3D user_data;
> +	const struct l_icmp6_router *r;
> +	struct l_rtnl_route *default_route;
> +	unsigned int i;
> +
> +	if (event !=3D L_ICMP6_CLIENT_EVENT_ROUTER_FOUND)
> +		return;
> +
> +	r =3D event_data;
> +
> +	/*
> +	 * Note: If this is the first RA received, the l_dhcp6_client
> +	 * will have received the event before us and will be acting
> +	 * on it by now.
> +	 */
> +
> +	if (nc->v4_gateway_override)
> +		return;
> +

So I think you meant v6_gateway_override here and I fixed this up according=
ly. =

Send a fix if this wasn't correct.

Patches 1-4 applied, thanks.

Regards,
-Denis

--===============8078761236558702365==--

