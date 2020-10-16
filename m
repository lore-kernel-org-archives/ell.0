Content-Type: multipart/mixed; boundary="===============7150237941267265737=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 05/20] dhcp-transport: modify BPF filter for server
Date: Fri, 16 Oct 2020 11:31:27 -0500
Message-ID: <c93b61af-6e35-b2c1-2cfb-05abb2f36667@gmail.com>
In-Reply-To: <20201016153635.660391-5-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7150237941267265737==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

On 10/16/20 10:36 AM, James Prestwood wrote:
> In preparation for dhcp server the XID portion of the BPF
> needs to be skipped when the port is DHCP_PORT_SERVER since
> this value will not be present in messages going to the
> server. The check for the message op was also changed to
> include both BOOTREQUEST and BOOTREPLY depending if the
> port matches the server or client port.
> ---
>   ell/dhcp-transport.c | 8 +++++++-
>   ell/dhcp.c           | 3 +--
>   2 files changed, 8 insertions(+), 3 deletions(-)
> =

> v2:
>   * Maintained the check for BOOTREPLY while also filtering for
>     BOOTREQUEST in the server case
>   * Maintained the check for XID in the client case but skip
>     over this check for server.
> =

> diff --git a/ell/dhcp-transport.c b/ell/dhcp-transport.c
> index e332f99..b693530 100644
> --- a/ell/dhcp-transport.c
> +++ b/ell/dhcp-transport.c
> @@ -384,7 +384,9 @@ static int kernel_raw_socket_open(uint32_t ifindex, u=
int16_t port, uint32_t xid)
>   				offsetof(struct dhcp_packet, dhcp.op)),
>   		/* op =3D=3D BOOTREPLY ? */

I updated the comment slightly here

>   		BPF_JUMP(BPF_JMP + BPF_JEQ + BPF_K,
> -				DHCP_OP_CODE_BOOTREPLY, 1, 0),
> +				(port =3D=3D DHCP_PORT_CLIENT) ?
> +				DHCP_OP_CODE_BOOTREPLY :
> +				DHCP_OP_CODE_BOOTREQUEST, 1, 0),
>   		/* ignore */
>   		BPF_STMT(BPF_RET + BPF_K, 0),
>   		/* A <- DHCP header type */
> @@ -394,6 +396,10 @@ static int kernel_raw_socket_open(uint32_t ifindex, =
uint16_t port, uint32_t xid)
>   		BPF_JUMP(BPF_JMP + BPF_JEQ + BPF_K, ARPHRD_ETHER, 1, 0),
>   		/* ignore */
>   		BPF_STMT(BPF_RET + BPF_K, 0),
> +		/* A <- UDP destination port */
> +		BPF_STMT(BPF_LD + BPF_H + BPF_ABS,
> +				offsetof(struct dhcp_packet, udp.dest)),
> +		BPF_JUMP(BPF_JMP + BPF_JEQ + BPF_K, DHCP_PORT_SERVER, 3, 0),
>   		/* A <- client identifier */
>   		BPF_STMT(BPF_LD + BPF_W + BPF_ABS,
>   				offsetof(struct dhcp_packet, dhcp.xid)),
> diff --git a/ell/dhcp.c b/ell/dhcp.c
> index e604dc0..12ed505 100644
> --- a/ell/dhcp.c
> +++ b/ell/dhcp.c
> @@ -974,8 +974,7 @@ LIB_EXPORT bool l_dhcp_client_start(struct l_dhcp_cli=
ent *client)
>   		l_getrandom(&client->xid, sizeof(client->xid));
>   =

>   	if (client->transport->open)
> -		if (client->transport->open(client->transport,
> -							client->xid) < 0)
> +		if (client->transport->open(client->transport, client->xid) < 0)
>   			return false;
>   =

>   	_dhcp_transport_set_rx_callback(client->transport,
> =


And I dropped this chunk since it was formatting only and not related to th=
e change.

Applied, thanks.

Regards,
-Denis
--===============7150237941267265737==--

