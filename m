Content-Type: multipart/mixed; boundary="===============5311703612053051456=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 3/4] dhcp: Add l_dhcp_client_set_lease
Date: Fri, 13 Aug 2021 22:07:02 -0500
Message-ID: <ab85b3c9-586c-fc1e-6907-00541f390dc4@gmail.com>
In-Reply-To: <CAOq732K5khUVQtiidHR-S5heVkitOZo5EyZcPtBgJtUkSESKGw@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5311703612053051456==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

> used then it would be against sections 4.3.2 and 4.4.5 to use
> broadcast in the RENEWING state but we'd have no other option (also by

Also 4.3.6.  I interpret section 4.4.4 to be more general.  So when it talk=
s =

about the client 'knowing the address' it means DHCP Request in the RENEWIN=
G =

state.  The state transitions in Section 5 make it pretty clear that we can=
't =

end up in the Renewing state unless we know the server address.

> my reading unicast wasn't a strict requirement, there's even that
> mention of clients that can't *receive* unicast)

I disagree here.  Renewing state by definition means the client has an addr=
ess =

assigned and active (the only transition is from the Bound state)  Otherwis=
e the =

client should be in a different state entirely.  You also have Section 4.4.=
3 =

that talks about the possibility of an address being assigned by means othe=
r =

than DHCP.  I would think 4.4.3 applies in the FILS use case?

>> What you will find is that there's almost never a time that the release =
actually
>> has a chance to get sent out over the air.
> =

> I think I saw it being received in the debug logs of some autotest.
> But if it doesn't make it to the peer that'd be more reason to not
> send it.

We could be racing between the genl socket and the data socket too.  It pro=
bably =

doesn't really matter at all whether we manage to send a release or not.

>>> * Track the lease expiry time in IWD and request a new IP by sending a
>>> fils Robust Action Frame with the IP Address Assignment IE again.
>>
>> That might be best.  Maybe that is what the spec intends?
> =

> This is what it intends but it would be nice to reuse the DHCP client

Nice, yes.  But it isn't looking like it is in the cards...

> for the lease renewals.  We can also do it in IWD, it's just that it'd
> be hard to stuff into IWD's netconfig.c since it would have to start
> sending and receiving action frames, so most of it might end up in
> station.c.

Agreed.  We'll have to see how we can make this work nicely.

>> Depends on context, we have plenty of APIs that take ownership :)
> =

> I've probably used that argument and was told those APIs were a mistake. =
;)
> =


I don't know about that.  I mean look at all the _send() APIs.  They take =

ownership.  I'll admit that this is not something we do (or have a need to =
do) =

often.

Regards,
-Denis
--===============5311703612053051456==--

