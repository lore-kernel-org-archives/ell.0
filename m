Content-Type: multipart/mixed; boundary="===============5956191430699762106=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 2/7] acd: add ARP sockets, listener, and probing
Date: Fri, 04 Dec 2020 00:50:04 -0600
Message-ID: <09ccfb77-f404-3b19-fdf1-65009fc40c6b@gmail.com>
In-Reply-To: <20201203204144.480090-2-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5956191430699762106==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

On 12/3/20 2:41 PM, James Prestwood wrote:
> Add support for opening the network socket, listening for
> messages, and sending ARP probes.
> ---
>   ell/acd.c | 226 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
>   1 file changed, 226 insertions(+)
> =


This looks really nice! I took the entire series and applied it.  Just have=
 a =

few minor nitpicks you can fix later if you think worthwhile:

> +static int acd_send_packet(struct l_acd *acd, uint32_t source_ip)
> +{
> +	struct sockaddr_ll dest;
> +	struct ether_arp p;
> +	uint32_t ip_source;
> +	uint32_t ip_target;
> +	int n;
> +	int fd =3D l_io_get_fd(acd->io);
> +
> +	memset(&dest, 0, sizeof(dest));
> +
> +	dest.sll_family =3D AF_PACKET;
> +	dest.sll_protocol =3D htons(ETH_P_ARP);
> +	dest.sll_ifindex =3D acd->ifindex;
> +	dest.sll_halen =3D ETH_ALEN;
> +	memset(dest.sll_addr, 0xFF, ETH_ALEN);
> +
> +	ip_source =3D htonl(source_ip);
> +	ip_target =3D htonl(acd->ip);

Is there an advantage to storing acd->ip or source_ip in host byte order?  =
Since =

inet_pton already gives a network-order address, this seems like just extra =

cycles wasted.

> +	p.arp_hrd =3D htons(ARPHRD_ETHER);
> +	p.arp_pro =3D htons(ETHERTYPE_IP);
> +	p.arp_hln =3D ETH_ALEN;
> +	p.arp_pln =3D 4;
> +	p.arp_op =3D htons(ARPOP_REQUEST);
> +
> +	ACD_DEBUG("sending packet with target IP %s", IP_STR(ip_target));
> +
> +	memcpy(&p.arp_sha, acd->mac, ETH_ALEN);
> +	memcpy(&p.arp_spa, &ip_source, sizeof(p.arp_spa));
> +	memcpy(&p.arp_tpa, &ip_target, sizeof(p.arp_tpa));
> +
> +	n =3D sendto(fd, &p, sizeof(p), 0,
> +			(struct sockaddr*) &dest, sizeof(dest));
> +	if (n < 0)
> +		n =3D -errno;
> +
> +	return n;
> +}
> +
> +static uint32_t acd_random_delay_ms(uint32_t max_sec)
> +{
> +	uint32_t rand;
> +
> +	l_getrandom(&rand, sizeof(rand));
> +
> +	return rand % (max_sec * 1000);
> +}
> +

Consider using _time_pick_interval_secs() from time.c

> +static void probe_wait_timeout(struct l_timeout *timeout, void *user_dat=
a)
> +{
> +	struct l_acd *acd =3D user_data;
> +	uint32_t delay;
> +
> +	ACD_DEBUG("Sending ACD Probe");
> +
> +	l_timeout_remove(acd->timeout);
> +	acd->timeout =3D NULL;
> +

If you're going to re-start the timeout, it is slightly cheaper to use =

l_timeout_modify* instead.

Regards,
-Denis
--===============5956191430699762106==--

