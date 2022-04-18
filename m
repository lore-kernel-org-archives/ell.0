Content-Type: multipart/mixed; boundary="===============3283954034931568364=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH 01/11] net: Add l_net_subnet_matches
Date: Mon, 18 Apr 2022 11:34:36 -0500
Message-ID: <04db266e-cc38-0832-b19f-d9f8c22a1c56@gmail.com>
In-Reply-To: 20220411142056.817784-1-andrew.zaborowski@intel.com

--===============3283954034931568364==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 4/11/22 09:20, Andrew Zaborowski wrote:
> Add inline function to check if two IP addresses are in the same subnet.
> ---
>   ell/net.h | 21 +++++++++++++++++++++
>   1 file changed, 21 insertions(+)
> =

> diff --git a/ell/net.h b/ell/net.h
> index c97d9c9..837209c 100644
> --- a/ell/net.h
> +++ b/ell/net.h
> @@ -25,6 +25,7 @@
>   =

>   #include <stdbool.h>
>   #include <stdint.h>
> +#include <string.h>
>   =

>   struct in_addr;
>   struct in6_addr;
> @@ -40,6 +41,26 @@ bool l_net_hostname_is_localhost(const char *hostname);
>   bool l_net_get_address(int ifindex, struct in_addr *out);
>   bool l_net_get_link_local_address(int ifindex, struct in6_addr *out);
>   =

> +static inline bool l_net_subnet_matches(const void *a, const void *b,
> +					uint8_t prefix_len)
> +{
> +	uint8_t bytes =3D prefix_len / 8;
> +	uint8_t bits =3D prefix_len & 7;
> +
> +	/*
> +	 * @a and @b are network byte order IPv4 or IPv6 addresses.
> +	 * We want to check if the initial (top) @prefix_len bits match.
> +	 * memcmp the whole bytes, then compare the final byte's top
> +	 * bits by anding with a mask.
> +	 */
> +	if (bytes && memcmp(a, b, bytes))

It looks like memcmp with a zero length is indeed guaranteed to return 0.  =
So =

this was simplified to if (memcmp(..))

> +		return false;
> +
> +	return !bits ||
> +		((((const uint8_t *) a)[bytes] ^ ((const uint8_t *) b)[bytes]) &
> +		 (0xff00u >> bits)) =3D=3D 0;

There were a bit too many '()' for my liking.  I moved the casts to the var=
iable =

declaration block above which ended up being the same number of lines and l=
ooked =

a bit cleaner.  Please double check that I didn't screw anything up.

> +}
> +
>   #ifdef __cplusplus
>   }
>   #endif
> =


Applied, thanks.

Regards,
-Denis
--===============3283954034931568364==--

