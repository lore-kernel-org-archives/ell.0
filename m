Content-Type: multipart/mixed; boundary="===============3555143533895001595=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH 5/6] netconfig: Add l_netconfig_apply_rtnl
Date: Tue, 08 Feb 2022 11:42:00 -0600
Message-ID: <6c24d725-3eb8-b3d3-6493-2eb55f815359@gmail.com>
In-Reply-To: 20220207150717.60511-5-andrew.zaborowski@intel.com

--===============3555143533895001595==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 2/7/22 09:07, Andrew Zaborowski wrote:
> Add l_netconfig_apply_rtnl and the getters for current lists of routes
> and addresses for the netconfig user to be able to commit address and
> route changes.
> ---
>   ell/ell.sym     |  3 ++
>   ell/netconfig.c | 73 +++++++++++++++++++++++++++++++++++++++++++++++++
>   ell/netconfig.h | 11 ++++++++
>   3 files changed, 87 insertions(+)
> =


<snip>

>   =

> +void l_netconfig_apply_rtnl(struct l_netconfig *netconfig,
> +				struct l_netlink *rtnl);
> +struct l_queue *l_netconfig_get_addresses(struct l_netconfig *netconfig,
> +					struct l_queue **out_added,
> +					struct l_queue **out_updated,
> +					struct l_queue **out_removed);
> +struct l_queue *l_netconfig_get_routes(struct l_netconfig *netconfig,
> +					struct l_queue **out_added,
> +					struct l_queue **out_updated,
> +					struct l_queue **out_removed);
> +

I wonder if we can use const l_queue_entry * instead.  Or maybe some sort o=
f =

iterator concept?  Returning a pointer to the internal data structure is =

something we should only do as a last resort.

Regards,
-Denis
--===============3555143533895001595==--

