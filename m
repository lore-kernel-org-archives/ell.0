Content-Type: multipart/mixed; boundary="===============5009603512088086252=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v6 3/6] dhcp-server: handle DECLINE messages
Date: Tue, 20 Oct 2020 09:59:19 -0500
Message-ID: <0578d737-0d33-247e-8674-3aa56aea5c6c@gmail.com>
In-Reply-To: <20201020013242.1575694-3-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5009603512088086252==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

On 10/19/20 8:32 PM, James Prestwood wrote:
> Process DECLINE messages from clients and remove any pending
> leases that were created during DISCOVER.
> ---
>   ell/dhcp-server.c | 22 ++++++++++++++++++++++
>   1 file changed, 22 insertions(+)
> =

> diff --git a/ell/dhcp-server.c b/ell/dhcp-server.c
> index 2008c56..7d2d6f0 100644
> --- a/ell/dhcp-server.c
> +++ b/ell/dhcp-server.c
> @@ -111,6 +111,18 @@ static struct l_dhcp_lease *find_lease_by_mac(struct=
 l_dhcp_server *server,
>   	return l_queue_find(server->lease_list, match_lease_mac, mac);
>   }
>   =

> +static void remove_lease(struct l_dhcp_server *server,
> +				struct l_dhcp_lease *lease)
> +{
> +	l_queue_remove(server->lease_list, lease);
> +
> +	if (server->event_handler)
> +		server->event_handler(server, L_DHCP_SERVER_EVENT_LEASE_EXPIRED,
> +					server->user_data, lease);

I don't think you want to do this here since the lease might be declined (a=
nd =

EVENT_LEASE_EXPIRED sent) without ever LEASE_NEW event being fired.

> +
> +	_dhcp_lease_free(lease);
> +}
> +
>   /* Clear the old lease and create the new one */
>   static int get_lease(struct l_dhcp_server *server, uint32_t yiaddr,
>   				const uint8_t *mac,

Regards,
-Denis
--===============5009603512088086252==--

