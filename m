Content-Type: multipart/mixed; boundary="===============1842305554872779219=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v5 04/12] dhcp-server: process DISCOVER and send OFFER
Date: Mon, 19 Oct 2020 20:09:35 -0500
Message-ID: <b2469728-b8e3-f0ac-9463-47b765745959@gmail.com>
In-Reply-To: <20201019232814.1541221-4-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1842305554872779219==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

On 10/19/20 6:28 PM, James Prestwood wrote:
> Add handling of DISCOVER messages and ability to send offers.
> ---
>   ell/dhcp-server.c | 333 ++++++++++++++++++++++++++++++++++++++++++++++
>   1 file changed, 333 insertions(+)
> =

> v5:
>   * Removed byte alignment on broadcast/any addresses
>   * Remove MAC_ANY_ADDR in favor of l_memeqzero
> =

> diff --git a/ell/dhcp-server.c b/ell/dhcp-server.c
> index c6e1b43..44482cd 100644
> --- a/ell/dhcp-server.c
> +++ b/ell/dhcp-server.c
> @@ -41,6 +41,13 @@
>   /* 8 hours */
>   #define DEFAULT_DHCP_LEASE_SEC (8*60*60)
>   =

> +/* 5 minutes  */
> +#define OFFER_TIME (5*60)
> +
> +static const uint8_t MAC_BCAST_ADDR[ETH_ALEN] =3D {
> +	0xff, 0xff, 0xff, 0xff, 0xff, 0xff
> +};
> +

Minor detail, but this belongs in patch 5 now.

>   struct l_dhcp_server {
>   	bool started;
>   	int ifindex;
> @@ -82,8 +89,334 @@ struct l_dhcp_server {
>   	l_util_debug(server->debug_handler, server->debug_data,		\
>   			"%s:%i " fmt, __func__, __LINE__, ## args)
>   =

> +static bool is_expired_lease(struct l_dhcp_lease *lease)
> +{
> +	if (lease->lifetime < l_time_to_secs(l_time_now()))
> +		return true;
> +
> +	return false;
> +}
> +
> +static bool match_lease_mac(const void *data, const void *user_data)
> +{
> +	const struct l_dhcp_lease *lease =3D data;
> +	const uint8_t *mac =3D user_data;
> +
> +	return !memcmp(lease->mac, mac, 6);
> +}
> +
> +static struct l_dhcp_lease *find_lease_by_mac(struct l_dhcp_server *serv=
er,
> +						const uint8_t *mac)
> +{
> +	return l_queue_find(server->lease_list, match_lease_mac, mac);
> +}
> +
> +/* Clear the old lease and create the new one */
> +static int get_lease(struct l_dhcp_server *server, uint32_t yiaddr,
> +				const uint8_t *mac,
> +				struct l_dhcp_lease **lease_out)
> +{
> +	struct l_dhcp_lease *lease;
> +
> +	if (yiaddr =3D=3D 0)
> +		return -ENXIO;
> +
> +	if (ntohl(yiaddr) < server->start_ip)
> +		return -ENXIO;
> +
> +	if (ntohl(yiaddr) > server->end_ip)
> +		return -ENXIO;
> +
> +	if (l_memeq(mac, ETH_ALEN, 0xff))
> +		return -ENXIO;
> +
> +	if (l_memeqzero(mac, ETH_ALEN))
> +		return -ENXIO;
> +
> +	lease =3D find_lease_by_mac(server, mac);
> +
> +	if (lease) {
> +		l_queue_remove(server->lease_list, lease);
> +
> +		*lease_out =3D lease;
> +
> +		return 0;
> +	}
> +
> +	*lease_out =3D l_new(struct l_dhcp_lease, 1);
> +	if (!*lease_out)
> +		return -ENOMEM;

l_new cannot fail

> +
> +	return 0;
> +}
> +
> +static int compare_lifetime(const void *a, const void *b, void *user_dat=
a)
> +{
> +	const struct l_dhcp_lease *lease1 =3D a;
> +	const struct l_dhcp_lease *lease2 =3D b;
> +
> +	return lease2->lifetime - lease1->lifetime;
> +}
> +
> +static struct l_dhcp_lease *add_lease(struct l_dhcp_server *server,
> +					uint32_t expire, const uint8_t *chaddr,
> +					uint32_t yiaddr)
> +{
> +	struct l_dhcp_lease *lease =3D NULL;
> +	int ret;
> +
> +	ret =3D get_lease(server, yiaddr, chaddr, &lease);
> +	if (ret !=3D 0)
> +		return NULL;
> +
> +	memset(lease, 0, sizeof(*lease));
> +
> +	memcpy(lease->mac, chaddr, ETH_ALEN);
> +	lease->address =3D yiaddr;
> +
> +	if (expire =3D=3D 0)
> +		lease->lifetime =3D l_time_to_secs(l_time_now()) +
> +						server->lease_seconds;
> +	else
> +		lease->lifetime =3D expire;
> +
> +	l_queue_insert(server->lease_list, lease, compare_lifetime, NULL);
> +
> +	SERVER_DEBUG("added lease IP %s for "MAC " lifetime=3D%u",
> +			IP_STR(yiaddr), MAC_STR(chaddr),
> +			lease->lifetime);
> +
> +	return lease;
> +}
> +
> +static bool match_lease_ip(const void *data, const void *user_data)
> +{
> +	const struct l_dhcp_lease *lease =3D data;
> +
> +	return lease->address =3D=3D L_PTR_TO_UINT(user_data);
> +}
> +
> +static struct l_dhcp_lease *find_lease_by_ip(struct l_dhcp_server *serve=
r,
> +						uint32_t nip)
> +{
> +	return l_queue_find(server->lease_list, match_lease_ip,
> +				L_INT_TO_PTR(nip));

nit, but probably should be L_UINT_TO_PTR

> +}
> +
> +static bool check_requested_ip(struct l_dhcp_server *server,
> +				uint32_t requested_nip)
> +{
> +	struct l_dhcp_lease *lease;
> +
> +	if (requested_nip =3D=3D 0)
> +		return false;
> +
> +	if (requested_nip < htonl(server->start_ip))
> +		return false;

Don't you mean to do this the other way?  ntohl the requested_nip and compa=
re? =

You do it this way in get_lease()

> +
> +	if (requested_nip > htonl(server->end_ip))
> +		return false;
> +

Same as above

> +	lease =3D find_lease_by_ip(server, requested_nip);
> +	if (!lease)
> +		return true;
> +
> +	if (!is_expired_lease(lease))
> +		return false;
> +
> +	return true;
> +}
> +
> +/* Check if the IP is taken; if it is, add it to the lease table */
> +static bool arp_check(uint32_t nip, const uint8_t *safe_mac)
> +{
> +	/* TODO: Add ARP checking */
> +	return true;
> +}
> +
> +static uint32_t find_free_or_expired_ip(struct l_dhcp_server *server,
> +						const uint8_t *safe_mac)
> +{
> +	uint32_t ip_addr;
> +	struct l_dhcp_lease *lease;
> +
> +	for (ip_addr =3D server->start_ip; ip_addr <=3D server->end_ip; ip_addr=
++) {
> +		/* e.g. 192.168.55.0 */
> +		if ((ip_addr & 0xff) =3D=3D 0)
> +			continue;
> +
> +		/* e.g. 192.168.55.255 */
> +		if ((ip_addr & 0xff) =3D=3D 0xff)
> +			continue;
> +
> +		lease =3D find_lease_by_ip(server, htonl(ip_addr));
> +		if (lease)
> +			continue;
> +
> +		if (arp_check(ip_addr, safe_mac))

I think you forgot htonl here as well.  Maybe you want to just do this once =

after checking for 0/255.

> +			return htonl(ip_addr);
> +	}
> +
> +	lease =3D l_queue_peek_tail(server->lease_list);
> +	if (!lease)
> +		return 0;
> +
> +	if (!is_expired_lease(lease))
> +		return 0;
> +
> +	if (!arp_check(lease->address, safe_mac))
> +		return 0;
> +
> +	return lease->address;
> +}
> +

<snip>

Regards,
-Denis
--===============1842305554872779219==--

