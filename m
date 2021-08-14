Content-Type: multipart/mixed; boundary="===============3809676991998004946=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 3/4] dhcp: Add l_dhcp_client_set_lease
Date: Sat, 14 Aug 2021 02:40:04 +0200
Message-ID: <CAOq732+T_jUAN26Rsn8cdtzaQ2eQv7yhwr94tDC8jHxkog+QAA@mail.gmail.com>
In-Reply-To: <ace2d966-5319-2441-8dad-c6418bb5fdd8@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3809676991998004946==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On Fri, 13 Aug 2021 at 17:48, Denis Kenzior <denkenz@gmail.com> wrote:
> On 8/12/21 3:51 PM, Andrew Zaborowski wrote:
> > @@ -422,7 +422,8 @@ static int dhcp_client_send_request(struct l_dhcp_c=
lient *client)
> >                *
> >                * NOTE: 'SELECTING' is meant to be 'REQUESTING' in the R=
FC
> >                */
> > -             if (!_dhcp_message_builder_append(&builder,
> > +             if (client->lease->server_address &&
>
> I'm not sure this is right according to the RFC?  Since we are in the Req=
uesting
> state, the server_address must be valid.  If it is somehow not, then shou=
ldn't
> we be in Init-Reboot or Rebinding state instead?

True, this change should not be needed.

>
> > +                             !_dhcp_message_builder_append(&builder,
> >                                       L_DHCP_OPTION_SERVER_IDENTIFIER,
> >                                       4, &client->lease->server_address=
)) {
> >                       CLIENT_DEBUG("Failed to append server ID");
> > @@ -468,7 +469,8 @@ static int dhcp_client_send_request(struct l_dhcp_c=
lient *client)
> >        * 'server identifier' option for any unicast requests to the DHCP
> >        * server.
> >        */
> > -     if (client->state =3D=3D DHCP_STATE_RENEWING)
> > +     if (client->state =3D=3D DHCP_STATE_RENEWING &&
> > +                     client->lease->server_address)
>
> I think this is against the spec?

So in both cases the check should be always true if
l_dhcp_client_set_lease was not used...  Checking an always-true
condition isn't against the spec.

>
> >               return dhcp_client_send_unicast(client, request, len);
> >
> >       return client->transport->l2_send(client->transport,
> > @@ -504,7 +506,8 @@ static void dhcp_client_send_release(struct l_dhcp_=
client *client)
> >
> >       request->ciaddr =3D client->lease->address;
> >
> > -     if (!_dhcp_message_builder_append(&builder,
> > +     if (client->lease->server_address &&
> > +                     !_dhcp_message_builder_append(&builder,
>
> Should we even bother with this if server_address is NULL?  If we have no=
 server
> address to send a release to, then we shouldn't even get here.

So we can move the check to the caller.  There's also a bigger
question of whether we should call dhcp_client_send_release() at all.
The only current caller is l_dhcp_client_stop.  I believe most clients
don't use DHCPRELEASE because they cache their leases for future use,
so maybe it makes sense that we send it for now because we don't save
our leases.  In the FILS and P2P cases (which can only exist with
802.11) the AP knows exactly when we disconnect so it can take
whatever action is needed without the DHCPRELEASE.

>
> I really don't think that DHCP servers will somehow work completely again=
st the
> relevant RFCs in order to support this FILS IP Address assignment use cas=
e.

On one hand RFC2131 says which messages should be unicast vs.
broadcast, and which messages should contain the "Server Identifier"
option, but it also just says:

"The DHCP client broadcasts DHCPDISCOVER, DHCPREQUEST and DHCPINFORM
messages, unless the client knows the address of a DHCP server."

In the FILS case we don't know the IP of the server until our first
renewal.  You're right that if we strictly follow 4.3.2 or 4.4.5, both
of which say that the DHCPREQUEST in the RENEWING state should be
unicast, we have no way of renewing the lease in a compliant way.  On
the other hand, from when I looked at whether the chaddr field should
be validated against the source address, I found most servers don't
look at either the source or destination addresses by default.

Then again we do have the server's MAC (in IWD...), we just don't have
its IP so we can unicast the message using transport->l2_send maybe?

> So
> the question is what do we do if a non-infinite validity time for an addr=
ess is
> given to us.

So there are two things that we can do that will be fully compliant
with all specs:

* Instead of renewing the IP by going to the RENEWING state, we can go
back to INIT and go through the full DISCOVER/OFFER/REQUEST/ACK.  We
may be offered the same IP, and if we're offered a different one then
we can still live with it.  I guess, to implement this we don't need
my l_dhcp_client_set_lease() method, we can track the lease expiry in
IWD and start the l_dhcp_client only after the initial lease is close
to expiry.

* Track the lease expiry time in IWD and request a new IP by sending a
fils Robust Action Frame with the IP Address Assignment IE again.

>
> I can see 3 things that might happen:
> - We ask for a PTK Rekey, or the AP triggers one for us.  This should res=
ult in
> a new IP Address coming our way.

It's the client that triggers the IP assignment so we don't have to go that=
 far.

> - We issue a DHCP Inform with our configured address, and some DHCP Serve=
r on
> the network confirms it.  We learn the DHCP Server address this way.
> - Once the validity time is almost up, we go into Init-Reboot or Rebindin=
g state
> and hope some DHCP Server on the network takes care of us.
>
> The absence of the server address is probably the reason why 'DHCP over F=
ILS' is
> an option in the first place.  With DHCPv4 Rapid Commit it is fully possi=
ble to
> only need 2 messages (Associate/Associate Resp) to make this work nicely.
>
> >                                       L_DHCP_OPTION_SERVER_IDENTIFIER,
> >                                       4, &client->lease->server_address=
)) {
> >               CLIENT_DEBUG("Failed to append server ID");
> > @@ -513,7 +516,15 @@ static void dhcp_client_send_release(struct l_dhcp=
_client *client)
> >
> >       _dhcp_message_builder_finalize(&builder, &len);
> >
> > -     dhcp_client_send_unicast(client, request, len);
> > +     if (client->lease->server_address) {
> > +             dhcp_client_send_unicast(client, request, len);
> > +             return;
> > +     }
> > +
>
> This looks wrong according to the RFC as well?
>
> > +     client->transport->l2_send(client->transport,
> > +                                     INADDR_ANY, DHCP_PORT_CLIENT,
> > +                                     INADDR_BROADCAST, DHCP_PORT_SERVE=
R,
> > +                                     NULL, request, len);
> >   }
> >
> >   static void dhcp_client_timeout_resend(struct l_timeout *timeout,
>
> <snip>
>
> > @@ -1114,6 +1129,62 @@ LIB_EXPORT const struct l_dhcp_lease *l_dhcp_cli=
ent_get_lease(
> >       return client->lease;
> >   }
> >
> > +/*
> > + * This is mainly to be used when the DHCP lease has been assigned by =
the
> > + * server and communicated to the client through an alternative protoc=
ol,
> > + * or to restore a saved state.
> > + */
> > +LIB_EXPORT void l_dhcp_client_set_lease(struct l_dhcp_client *client,
> > +                                     const struct l_dhcp_lease *lease)
> > +{
> > +     int r =3D L_DHCP_CLIENT_EVENT_LEASE_OBTAINED;
> > +
> > +     if (unlikely(!client || !lease))
> > +             return;
> > +
> > +     l_dhcp_lease_free(client->lease);
> > +     client->lease =3D _dhcp_lease_clone(lease);
>
> I actually wonder why you'd want to clone the lease here and not just take
> ownership of the passed in lease object?  What is the caller going to do =
with it
> besides free it?

The only reason was that IIRC you didn't like APIs where a method
takes ownership of a pointer.

Best regards
--===============3809676991998004946==--

