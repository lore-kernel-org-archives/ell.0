Content-Type: multipart/mixed; boundary="===============1655923743899468817=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 3/4] dhcp: Add l_dhcp_client_set_lease
Date: Fri, 13 Aug 2021 10:40:55 -0500
Message-ID: <ace2d966-5319-2441-8dad-c6418bb5fdd8@gmail.com>
In-Reply-To: <20210812205112.86584-3-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1655923743899468817==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 8/12/21 3:51 PM, Andrew Zaborowski wrote:
> This method can be used when the DHCP server sends us a new lease
> through an alternative protocol/transport such as when a lower layer's
> (e.g. 802.11) initial handshake frames are reused to send the server's
> IP assignment for faster connection setup.  If the lease has a defined
> lifetime the user will want to use l_dhcp_client to track the expiry and
> renewal of the leases.  The user will build an l_dhcp_lease object
> using the data that was included in the handshake frames and call
> l_dhcp_client_set_lease() and then the l_dhcp_client_start() as normal
> once the ethernet link is setup.  The L_DHCP_CLIENT_EVENT_LEASE_OBTAINED
> event will be sent inside the later l_dhcp_client_start() call.
> =

> With more work this method could be used for restoring the DHCP client
> state from an older instance.
> ---
>   ell/dhcp-lease.c   |  26 ++++
>   ell/dhcp-private.h |   1 +
>   ell/dhcp.c         | 311 ++++++++++++++++++++++++++++-----------------
>   ell/dhcp.h         |   2 +
>   ell/ell.sym        |   1 +
>   5 files changed, 226 insertions(+), 115 deletions(-)
> =


<snip>

> diff --git a/ell/dhcp.c b/ell/dhcp.c
> index e06ab05..49398d5 100644
> --- a/ell/dhcp.c
> +++ b/ell/dhcp.c
> @@ -422,7 +422,8 @@ static int dhcp_client_send_request(struct l_dhcp_cli=
ent *client)
>   		 *
>   		 * NOTE: 'SELECTING' is meant to be 'REQUESTING' in the RFC
>   		 */
> -		if (!_dhcp_message_builder_append(&builder,
> +		if (client->lease->server_address &&

I'm not sure this is right according to the RFC?  Since we are in the Reque=
sting =

state, the server_address must be valid.  If it is somehow not, then should=
n't =

we be in Init-Reboot or Rebinding state instead?

> +				!_dhcp_message_builder_append(&builder,
>   					L_DHCP_OPTION_SERVER_IDENTIFIER,
>   					4, &client->lease->server_address)) {
>   			CLIENT_DEBUG("Failed to append server ID");
> @@ -468,7 +469,8 @@ static int dhcp_client_send_request(struct l_dhcp_cli=
ent *client)
>   	 * 'server identifier' option for any unicast requests to the DHCP
>   	 * server.
>   	 */
> -	if (client->state =3D=3D DHCP_STATE_RENEWING)
> +	if (client->state =3D=3D DHCP_STATE_RENEWING &&
> +			client->lease->server_address)

I think this is against the spec?

>   		return dhcp_client_send_unicast(client, request, len);
>   =

>   	return client->transport->l2_send(client->transport,
> @@ -504,7 +506,8 @@ static void dhcp_client_send_release(struct l_dhcp_cl=
ient *client)
>   =

>   	request->ciaddr =3D client->lease->address;
>   =

> -	if (!_dhcp_message_builder_append(&builder,
> +	if (client->lease->server_address &&
> +			!_dhcp_message_builder_append(&builder,

Should we even bother with this if server_address is NULL?  If we have no s=
erver =

address to send a release to, then we shouldn't even get here.

I really don't think that DHCP servers will somehow work completely against=
 the =

relevant RFCs in order to support this FILS IP Address assignment use case.=
  So =

the question is what do we do if a non-infinite validity time for an addres=
s is =

given to us.

I can see 3 things that might happen:
- We ask for a PTK Rekey, or the AP triggers one for us.  This should resul=
t in =

a new IP Address coming our way.
- We issue a DHCP Inform with our configured address, and some DHCP Server =
on =

the network confirms it.  We learn the DHCP Server address this way.
- Once the validity time is almost up, we go into Init-Reboot or Rebinding =
state =

and hope some DHCP Server on the network takes care of us.

The absence of the server address is probably the reason why 'DHCP over FIL=
S' is =

an option in the first place.  With DHCPv4 Rapid Commit it is fully possibl=
e to =

only need 2 messages (Associate/Associate Resp) to make this work nicely.

>   					L_DHCP_OPTION_SERVER_IDENTIFIER,
>   					4, &client->lease->server_address)) {
>   		CLIENT_DEBUG("Failed to append server ID");
> @@ -513,7 +516,15 @@ static void dhcp_client_send_release(struct l_dhcp_c=
lient *client)
>   =

>   	_dhcp_message_builder_finalize(&builder, &len);
>   =

> -	dhcp_client_send_unicast(client, request, len);
> +	if (client->lease->server_address) {
> +		dhcp_client_send_unicast(client, request, len);
> +		return;
> +	}
> +

This looks wrong according to the RFC as well?

> +	client->transport->l2_send(client->transport,
> +					INADDR_ANY, DHCP_PORT_CLIENT,
> +					INADDR_BROADCAST, DHCP_PORT_SERVER,
> +					NULL, request, len);
>   }
>   =

>   static void dhcp_client_timeout_resend(struct l_timeout *timeout,

<snip>

> @@ -1114,6 +1129,62 @@ LIB_EXPORT const struct l_dhcp_lease *l_dhcp_clien=
t_get_lease(
>   	return client->lease;
>   }
>   =

> +/*
> + * This is mainly to be used when the DHCP lease has been assigned by the
> + * server and communicated to the client through an alternative protocol,
> + * or to restore a saved state.
> + */
> +LIB_EXPORT void l_dhcp_client_set_lease(struct l_dhcp_client *client,
> +					const struct l_dhcp_lease *lease)
> +{
> +	int r =3D L_DHCP_CLIENT_EVENT_LEASE_OBTAINED;
> +
> +	if (unlikely(!client || !lease))
> +		return;
> +
> +	l_dhcp_lease_free(client->lease);
> +	client->lease =3D _dhcp_lease_clone(lease);

I actually wonder why you'd want to clone the lease here and not just take =

ownership of the passed in lease object?  What is the caller going to do wi=
th it =

besides free it?

I have no real objection to the other refactoring in this patch.  It might =
have =

been easier to send that separately first.

Regards,
-Denis
--===============1655923743899468817==--

