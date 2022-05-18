Content-Type: multipart/mixed; boundary="===============5797426636865829264=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH 07/17] netconfig: Use an internal rtnl socket for
 l_netconfig_apply_rtnl
Date: Wed, 18 May 2022 13:58:09 -0500
Message-ID: <378dbbda-7453-9a67-db2f-e098ba159388@gmail.com>
In-Reply-To: 20220513224713.1447773-7-andrew.zaborowski@intel.com

--===============5797426636865829264==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 5/13/22 17:47, Andrew Zaborowski wrote:
> Since we'll need to keep an internal RTNL socket for DHCPv6
> functionality anyway, change l_netconfig_apply_rtnl's signature to not
> require an rtnl parameter.
> ---
>   ell/netconfig.c | 34 ++++++++++++++++++++--------------
>   ell/netconfig.h |  3 +--
>   2 files changed, 21 insertions(+), 16 deletions(-)
> =


<snip>

> @@ -730,8 +731,13 @@ static void netconfig_icmp6_event_handler(struct l_i=
cmp6_client *client,
>   LIB_EXPORT struct l_netconfig *l_netconfig_new(uint32_t ifindex)
>   {
>   	struct l_netconfig *nc;
> +	struct l_netlink *rtnl =3D l_netlink_new(NETLINK_ROUTE);
> +
> +	if (!rtnl)
> +		return NULL;

I'm against this.  We will have multiple netconfig objects in play and each=
 one =

would be utilizing an fd.  We should be keeping our fd use to a minimum, =

particularly since we're limited to ~128 right now.  Passing in the rtnl ob=
ject =

from outside is preferred.

Regards,
-Denis
--===============5797426636865829264==--

