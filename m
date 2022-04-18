Content-Type: multipart/mixed; boundary="===============4391405185157782070=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH 06/11] icmp6: Parse extra options
Date: Mon, 18 Apr 2022 14:39:19 -0500
Message-ID: <f06829ab-4001-2202-523a-1c6ce45dd6b0@gmail.com>
In-Reply-To: 20220411142056.817784-6-andrew.zaborowski@intel.com

--===============4391405185157782070==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 4/11/22 09:20, Andrew Zaborowski wrote:
> Parse Route Information and New Advertisement Interval options.  Route
> Information options (RIOs) are supported by radvd and a few clients that
> I checked.
> ---
>   ell/icmp6-private.h |   6 ++-
>   ell/icmp6.c         | 121 +++++++++++++++++++++++++++++++++++++++-----
>   2 files changed, 113 insertions(+), 14 deletions(-)
> =


<snip>

> @@ -719,7 +732,35 @@ struct l_icmp6_router *_icmp6_router_parse(const str=
uct nd_router_advert *ra,
>   				return NULL;
>   =

>   			if (opts[3] & ND_OPT_PI_FLAG_ONLINK)
> -				n_prefixes +=3D 1;
> +				n_routes +=3D 1;
> +			break;
> +		case ND_OPT_ROUTE_INFORMATION:
> +			if (l < 8)
> +				return NULL;
> +
> +			if (opts[2] > 128 || opts[2] > (l - 8) * 8)
> +				return NULL;
> +
> +			/*
> +			 * RFC 4191 Section 2.3:
> +			 * "If the Reserved (10) value is received, the Route
> +			 * Information Option MUST be ignored."
> +			 */
> +			if (((opts[3] >> 3) & 3) =3D=3D 2)
> +				break;

Can we use bit_field() from useful.h instead?

> +
> +			/*
> +			 * RFC 4191 Section 3.1:
> +			 * "The Router Preference and Lifetime values in a ::/0
> +			 * Route Information Option override the preference and
> +			 * lifetime values in the Router Advertisement header."
> +			 *
> +			 * Don't count ::/0 routes.
> +			 */
> +			if (opts[2] =3D=3D 0)
> +				break;
> +
> +			n_routes +=3D 1;
>   			break;
>   		}
>   =

> @@ -739,6 +780,10 @@ struct l_icmp6_router *_icmp6_router_parse(const str=
uct nd_router_advert *ra,
>   		r->other =3D true;
>   =

>   	r->pref =3D (ra->nd_ra_flags_reserved >> 3) & 0x3;
> +	/*
> +	 * "If the Reserved (10) value is received, the receiver MUST
> +	 * treat the value as if it were (00).
> +	 */

This might warrant a separate commit

>   	if (r->pref =3D=3D 0x2) /* If invalid, reset to medium */
>   		r->pref =3D 0;
>   =


<snip>

> @@ -765,17 +810,69 @@ struct l_icmp6_router *_icmp6_router_parse(const st=
ruct nd_router_advert *ra,
>   			break;
>   		case ND_OPT_PREFIX_INFORMATION:
>   		{
> -			struct route_info *i =3D &r->prefixes[n_prefixes];
> +			struct route_info *i =3D &r->routes[n_routes];
>   =

>   			if (!(opts[3] & ND_OPT_PI_FLAG_ONLINK))
>   				break;
>   =

>   			i->prefix_len =3D opts[2];
> +			i->onlink =3D true;
>   			i->valid_lifetime =3D l_get_be32(opts + 4);
>   			i->preferred_lifetime =3D l_get_be32(opts + 8);
>   			memcpy(i->address, opts + 16, 16);
>   =

> -			n_prefixes +=3D 1;
> +			n_routes +=3D 1;
> +			break;
> +		}
> +		case ND_OPT_RTR_ADV_INTERVAL:
> +			if (l < 8)
> +				break;
> +
> +			r->max_rtr_adv_interval_ms =3D l_get_be32(opts + 4);
> +			break;
> +		case ND_OPT_ROUTE_INFORMATION:
> +		{
> +			struct route_info *i =3D &r->routes[n_routes++];
> +
> +			if (((opts[3] >> 3) & 3) =3D=3D 2)

bit_field()?

Also, you access this value at least twice below, so maybe just use a varia=
ble =

and assign it.

> +				break;
> +
> +			/*
> +			 * RFC 4191 Section 3.1:
> +			 * "The Router Preference and Lifetime values in a ::/0
> +			 * Route Information Option override the preference and
> +			 * lifetime values in the Router Advertisement header."
> +			 */
> +			if (opts[2] =3D=3D 0) {
> +				if (r->lifetime =3D=3D 0 && l_get_be32(opts + 4)) {
> +					/*
> +					 * A ::/0 route received from a
> +					 * non-default router?  Should issue
> +					 * a warning?
> +					 */
> +					break;
> +				}
> +
> +				r->pref =3D (opts[3] >> 3) & 3;
> +				r->lifetime =3D l_get_be16(opts + 4) ? 0xffff :
> +					l_get_be16(opts + 6);
> +				break;
> +			}
> +
> +			/*
> +			 * Don't check or warn if the route lifetime is longer
> +			 * than the router lifetime because that refers to its
> +			 * time as the default router.  It may be configured to
> +			 * route packets for us for specific prefixes without
> +			 * being a default router.
> +			 */
> +			i->prefix_len =3D opts[2];
> +			i->onlink =3D false;
> +			i->preference =3D (opts[3] >> 3) & 3;
> +			i->valid_lifetime =3D l_get_be32(opts + 4);
> +			memcpy(i->address, opts + 8, (i->prefix_len + 7) / 8);
> +
> +			n_routes +=3D 1;
>   			break;
>   		}
>   		}
> =


Regards,
-Denis
--===============4391405185157782070==--

