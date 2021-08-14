Content-Type: multipart/mixed; boundary="===============0362469760712277216=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 3/4] dhcp: Add l_dhcp_client_set_lease
Date: Sat, 14 Aug 2021 04:46:27 +0200
Message-ID: <CAOq732K5khUVQtiidHR-S5heVkitOZo5EyZcPtBgJtUkSESKGw@mail.gmail.com>
In-Reply-To: <46fd9af0-c1e5-5f32-076a-56ed45c1ee56@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0362469760712277216==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Sat, 14 Aug 2021 at 03:30, Denis Kenzior <denkenz@gmail.com> wrote:
> >>> @@ -468,7 +469,8 @@ static int dhcp_client_send_request(struct l_dhcp=
_client *client)
> >>>         * 'server identifier' option for any unicast requests to the =
DHCP
> >>>         * server.
> >>>         */
> >>> -     if (client->state =3D=3D DHCP_STATE_RENEWING)
> >>> +     if (client->state =3D=3D DHCP_STATE_RENEWING &&
> >>> +                     client->lease->server_address)
> >>
> >> I think this is against the spec?
> >
> > So in both cases the check should be always true if
> > l_dhcp_client_set_lease was not used...  Checking an always-true
> > condition isn't against the spec.
>
> I get the feeling you're arguing for the sake of arguing here.  Strictly
> speaking you're completely right, but ... If the check is always going to=
 be
> true, why check it? :)

What I meant was that it was not against the spec if
l_dhcp_client_set_lease was not used.  If l_dhcp_client_set_lease was
used then it would be against sections 4.3.2 and 4.4.5 to use
broadcast in the RENEWING state but we'd have no other option (also by
my reading unicast wasn't a strict requirement, there's even that
mention of clients that can't *receive* unicast)

>  Our coding style says to avoid a 'complex if body.'  And
> most likely you'll get into trouble in the future since your brain will f=
lag it.
>   Static analysis will also flag it and will likely want you to check for=
 this
> explicitly.  So you'd end up with a L_WARN_ON if the condition was false,=
 or
> return -EINVAL from this operation, or something.  Which arguably would m=
ake
> more sense.
>
> >
> >>
> >>>                return dhcp_client_send_unicast(client, request, len);
> >>>
> >>>        return client->transport->l2_send(client->transport,
> >>> @@ -504,7 +506,8 @@ static void dhcp_client_send_release(struct l_dhc=
p_client *client)
> >>>
> >>>        request->ciaddr =3D client->lease->address;
> >>>
> >>> -     if (!_dhcp_message_builder_append(&builder,
> >>> +     if (client->lease->server_address &&
> >>> +                     !_dhcp_message_builder_append(&builder,
> >>
> >> Should we even bother with this if server_address is NULL?  If we have=
 no server
> >> address to send a release to, then we shouldn't even get here.
> >
> > So we can move the check to the caller.  There's also a bigger
> > question of whether we should call dhcp_client_send_release() at all.
> > The only current caller is l_dhcp_client_stop.  I believe most clients
>
> What you will find is that there's almost never a time that the release a=
ctually
> has a chance to get sent out over the air.

I think I saw it being received in the debug logs of some autotest.
But if it doesn't make it to the peer that'd be more reason to not
send it.

>  We're usually disassociated by the
> time this fires.  Maybe we can use l_dhcp_client_stop as part of our
> disassociate logic, but we'd need to take extra care that this actually g=
oes out...
>
> > don't use DHCPRELEASE because they cache their leases for future use,
> > so maybe it makes sense that we send it for now because we don't save
> > our leases.  In the FILS and P2P cases (which can only exist with
> > 802.11) the AP knows exactly when we disconnect so it can take
> > whatever action is needed without the DHCPRELEASE.
> >
>
> That is what I would expect, yes.
>
> >>
> >> I really don't think that DHCP servers will somehow work completely ag=
ainst the
> >> relevant RFCs in order to support this FILS IP Address assignment use =
case.
> >
> > On one hand RFC2131 says which messages should be unicast vs.
> > broadcast, and which messages should contain the "Server Identifier"
> > option, but it also just says:
> >
> > "The DHCP client broadcasts DHCPDISCOVER, DHCPREQUEST and DHCPINFORM
> > messages, unless the client knows the address of a DHCP server."
> >
> > In the FILS case we don't know the IP of the server until our first
> > renewal.  You're right that if we strictly follow 4.3.2 or 4.4.5, both
> > of which say that the DHCPREQUEST in the RENEWING state should be
> > unicast, we have no way of renewing the lease in a compliant way.  On
> > the other hand, from when I looked at whether the chaddr field should
> > be validated against the source address, I found most servers don't
> > look at either the source or destination addresses by default.
> >
> > Then again we do have the server's MAC (in IWD...), we just don't have
> > its IP so we can unicast the message using transport->l2_send maybe?
>
> I'm not following, how do we have the server's MAC?  The AP is not necess=
arily
> the DHCP server.

True, I kinda assumed that it was if the AP is able to return the IP
directly in the Association Response but even then it's not
necessarily true.

>
> >
> >> So
> >> the question is what do we do if a non-infinite validity time for an a=
ddress is
> >> given to us.
> >
> > So there are two things that we can do that will be fully compliant
> > with all specs:
> >
> > * Instead of renewing the IP by going to the RENEWING state, we can go
> > back to INIT and go through the full DISCOVER/OFFER/REQUEST/ACK.  We
> > may be offered the same IP, and if we're offered a different one then
>
> shouldn't we go into Init-Reboot or Rebinding instead of back to Init?

We could do that, we'll probably never know what is actually
"correct".  Since we already have an IP it's not as important as
during initial setup for speed.

>
> > we can still live with it.  I guess, to implement this we don't need
> > my l_dhcp_client_set_lease() method, we can track the lease expiry in
> > IWD and start the l_dhcp_client only after the initial lease is close
> > to expiry.
>
> Yes, that makes sense.
>
> >
> > * Track the lease expiry time in IWD and request a new IP by sending a
> > fils Robust Action Frame with the IP Address Assignment IE again.
>
> That might be best.  Maybe that is what the spec intends?

This is what it intends but it would be nice to reuse the DHCP client
for the lease renewals.  We can also do it in IWD, it's just that it'd
be hard to stuff into IWD's netconfig.c since it would have to start
sending and receiving action frames, so most of it might end up in
station.c.

>
> <snip>
>
> >>
> >> I actually wonder why you'd want to clone the lease here and not just =
take
> >> ownership of the passed in lease object?  What is the caller going to =
do with it
> >> besides free it?
> >
> > The only reason was that IIRC you didn't like APIs where a method
> > takes ownership of a pointer.
> >
>
> Depends on context, we have plenty of APIs that take ownership :)

I've probably used that argument and was told those APIs were a mistake. ;)

Best regards
--===============0362469760712277216==--

