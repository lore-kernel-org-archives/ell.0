Content-Type: multipart/mixed; boundary="===============5906005871282850965=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 3/4] dhcp: Add l_dhcp_client_set_lease
Date: Fri, 13 Aug 2021 20:20:03 -0500
Message-ID: <46fd9af0-c1e5-5f32-076a-56ed45c1ee56@gmail.com>
In-Reply-To: <CAOq732+T_jUAN26Rsn8cdtzaQ2eQv7yhwr94tDC8jHxkog+QAA@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5906005871282850965==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

>>> @@ -468,7 +469,8 @@ static int dhcp_client_send_request(struct l_dhcp_c=
lient *client)
>>>         * 'server identifier' option for any unicast requests to the DH=
CP
>>>         * server.
>>>         */
>>> -     if (client->state =3D=3D DHCP_STATE_RENEWING)
>>> +     if (client->state =3D=3D DHCP_STATE_RENEWING &&
>>> +                     client->lease->server_address)
>>
>> I think this is against the spec?
> =

> So in both cases the check should be always true if
> l_dhcp_client_set_lease was not used...  Checking an always-true
> condition isn't against the spec.

I get the feeling you're arguing for the sake of arguing here.  Strictly =

speaking you're completely right, but ... If the check is always going to b=
e =

true, why check it? :)  Our coding style says to avoid a 'complex if body.'=
  And =

most likely you'll get into trouble in the future since your brain will fla=
g it. =

  Static analysis will also flag it and will likely want you to check for t=
his =

explicitly.  So you'd end up with a L_WARN_ON if the condition was false, o=
r =

return -EINVAL from this operation, or something.  Which arguably would mak=
e =

more sense.

> =

>>
>>>                return dhcp_client_send_unicast(client, request, len);
>>>
>>>        return client->transport->l2_send(client->transport,
>>> @@ -504,7 +506,8 @@ static void dhcp_client_send_release(struct l_dhcp_=
client *client)
>>>
>>>        request->ciaddr =3D client->lease->address;
>>>
>>> -     if (!_dhcp_message_builder_append(&builder,
>>> +     if (client->lease->server_address &&
>>> +                     !_dhcp_message_builder_append(&builder,
>>
>> Should we even bother with this if server_address is NULL?  If we have n=
o server
>> address to send a release to, then we shouldn't even get here.
> =

> So we can move the check to the caller.  There's also a bigger
> question of whether we should call dhcp_client_send_release() at all.
> The only current caller is l_dhcp_client_stop.  I believe most clients

What you will find is that there's almost never a time that the release act=
ually =

has a chance to get sent out over the air.  We're usually disassociated by =
the =

time this fires.  Maybe we can use l_dhcp_client_stop as part of our =

disassociate logic, but we'd need to take extra care that this actually goe=
s out...

> don't use DHCPRELEASE because they cache their leases for future use,
> so maybe it makes sense that we send it for now because we don't save
> our leases.  In the FILS and P2P cases (which can only exist with
> 802.11) the AP knows exactly when we disconnect so it can take
> whatever action is needed without the DHCPRELEASE.
> =


That is what I would expect, yes.

>>
>> I really don't think that DHCP servers will somehow work completely agai=
nst the
>> relevant RFCs in order to support this FILS IP Address assignment use ca=
se.
> =

> On one hand RFC2131 says which messages should be unicast vs.
> broadcast, and which messages should contain the "Server Identifier"
> option, but it also just says:
> =

> "The DHCP client broadcasts DHCPDISCOVER, DHCPREQUEST and DHCPINFORM
> messages, unless the client knows the address of a DHCP server."
> =

> In the FILS case we don't know the IP of the server until our first
> renewal.  You're right that if we strictly follow 4.3.2 or 4.4.5, both
> of which say that the DHCPREQUEST in the RENEWING state should be
> unicast, we have no way of renewing the lease in a compliant way.  On
> the other hand, from when I looked at whether the chaddr field should
> be validated against the source address, I found most servers don't
> look at either the source or destination addresses by default.
> =

> Then again we do have the server's MAC (in IWD...), we just don't have
> its IP so we can unicast the message using transport->l2_send maybe?

I'm not following, how do we have the server's MAC?  The AP is not necessar=
ily =

the DHCP server.

> =

>> So
>> the question is what do we do if a non-infinite validity time for an add=
ress is
>> given to us.
> =

> So there are two things that we can do that will be fully compliant
> with all specs:
> =

> * Instead of renewing the IP by going to the RENEWING state, we can go
> back to INIT and go through the full DISCOVER/OFFER/REQUEST/ACK.  We
> may be offered the same IP, and if we're offered a different one then

shouldn't we go into Init-Reboot or Rebinding instead of back to Init?

> we can still live with it.  I guess, to implement this we don't need
> my l_dhcp_client_set_lease() method, we can track the lease expiry in
> IWD and start the l_dhcp_client only after the initial lease is close
> to expiry.

Yes, that makes sense.

> =

> * Track the lease expiry time in IWD and request a new IP by sending a
> fils Robust Action Frame with the IP Address Assignment IE again.

That might be best.  Maybe that is what the spec intends?

<snip>

>>
>> I actually wonder why you'd want to clone the lease here and not just ta=
ke
>> ownership of the passed in lease object?  What is the caller going to do=
 with it
>> besides free it?
> =

> The only reason was that IIRC you didn't like APIs where a method
> takes ownership of a pointer.
> =


Depends on context, we have plenty of APIs that take ownership :)

Regards,
-Denis
--===============5906005871282850965==--

