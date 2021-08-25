Content-Type: multipart/mixed; boundary="===============6890451294303789910=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] rtnl: Add neighbor discovery utilities
Date: Wed, 25 Aug 2021 14:05:50 -0500
Message-ID: <8a12adad-18f3-99de-3201-ab80f21a872d@gmail.com>
In-Reply-To: <20210825004003.296590-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6890451294303789910==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 8/24/21 7:40 PM, Andrew Zaborowski wrote:
> Add a few variants of RTNL utilities to look up addresses in the
> kernel's neighbour table entries and to add new entries.  This is
> basically the ARP (for IPv4) and NDP (for IPv6) tables, that map IP
> addresses to hardware addresses.
> ---
> There are three variants of each method, I currently only have a use
> case for the ipv4 and ipv6 variants so I'm happy dropping the struct
> l_rtnl_address variant.
> =

>   ell/ell.sym  |   6 ++
>   ell/rtnl.c   | 194 +++++++++++++++++++++++++++++++++++++++++++++++++++
>   ell/rtnl.h   |  36 ++++++++++
>   ell/useful.h |   4 ++
>   4 files changed, 240 insertions(+)
> =


<snip>

> diff --git a/ell/rtnl.h b/ell/rtnl.h
> index 9ea24f5..834cd14 100644
> --- a/ell/rtnl.h
> +++ b/ell/rtnl.h
> @@ -33,6 +33,9 @@ extern "C" {
>   struct l_rtnl_address;
>   struct l_rtnl_route;
>   =

> +typedef void (*l_rtnl_neighbour_get_cb_t) (int error, const uint8_t *hwa=
ddr,

You probably want a length as well, no?

> +						void *user_data);
> +
>   struct l_rtnl_address *l_rtnl_address_new(const char *ip, uint8_t prefi=
x_len);
>   struct l_rtnl_address *l_rtnl_address_clone(const struct l_rtnl_address=
 *orig);
>   void l_rtnl_address_free(struct l_rtnl_address *addr);
> @@ -191,6 +194,39 @@ uint32_t l_rtnl_route_delete(struct l_netlink *rtnl,=
 int ifindex,
>   					void *user_data,
>   					l_netlink_destroy_func_t destroy);
>   =

> +uint32_t l_rtnl_neighbour_get_ipv4_hwaddr(struct l_netlink *rtnl, int if=
index,
> +					uint32_t addr,

We do not use uint32_t to represent an ipv4 anywhere in the ell API.

> +					l_rtnl_neighbour_get_cb_t cb,
> +					void *user_data,
> +					l_netlink_destroy_func_t destroy);
> +uint32_t l_rtnl_neighbour_get_ipv6_hwaddr(struct l_netlink *rtnl, int if=
index,
> +					const uint8_t *addr,

similarly to above, ipv6 is never represented like this.

I was hoping to avoid using in_addr / in6_addr in the public API, but maybe=
 that =

would be the lesser evil option than 'const uint8_t *'.  Or just use =

l_rtnl_address for everything.

> +					l_rtnl_neighbour_get_cb_t cb,
> +					void *user_data,
> +					l_netlink_destroy_func_t destroy);
> +uint32_t l_rtnl_neighbour_get_addr_hwaddr(struct l_netlink *rtnl, int if=
index,
> +					const struct l_rtnl_address *addr,
> +					l_rtnl_neighbour_get_cb_t cb,
> +					void *user_data,
> +					l_netlink_destroy_func_t destroy);
> +uint32_t l_rtnl_neighbour_set_ipv4_hwaddr(struct l_netlink *rtnl, int if=
index,
> +					uint32_t addr, const uint8_t *hwaddr,

You're making an assumption that hwaddr is always 6?  That will not really =
be =

true long term.  Might as well take care of this now.

> +					l_netlink_command_func_t cb,
> +					void *user_data,
> +					l_netlink_destroy_func_t destroy);
> +uint32_t l_rtnl_neighbour_set_ipv6_hwaddr(struct l_netlink *rtnl, int if=
index,
> +					const uint8_t *addr,
> +					const uint8_t *hwaddr,
> +					l_netlink_command_func_t cb,
> +					void *user_data,
> +					l_netlink_destroy_func_t destroy);
> +uint32_t l_rtnl_neighbour_set_addr_hwaddr(struct l_netlink *rtnl, int if=
index,
> +					const struct l_rtnl_address *addr,
> +					const uint8_t *hwaddr,
> +					l_netlink_command_func_t cb,
> +					void *user_data,
> +					l_netlink_destroy_func_t destroy);
> +

Regards,
-Denis
--===============6890451294303789910==--

