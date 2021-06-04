Content-Type: multipart/mixed; boundary="===============4900042046443780413=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] dhcp-server: Fix lease expiry time calculation
Date: Fri, 04 Jun 2021 13:48:41 -0500
Message-ID: <89f90fa8-10b1-d1e8-17fb-7103bbf1b8d8@gmail.com>
In-Reply-To: <CAOq732L3vCwm-OGKd4gYs+ne1MDcLc3U_qU7hepb_EUc982Sgg@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4900042046443780413==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

> It's the "commit early, commit often" kind of question, we have a
> completely broken lease expiry here so the main goal was to make it
> even work and then while I was changing that line... it felt wrong to
> not make such a simple improvement, and then edited this line for
> consistency with that line but without delving into the reasons this
> uses uint32_t.

I agree, but it feels like in this case you're trading something completely =

broken for something not-quite-completely-broken and it isn't much of an =

improvement.  You touch it, you own it ;)

> =

>>
>>>
>>>>    And with these changes I'm not sure
>>>> there's any point to store lease->lifetime in seconds.  I suspect this=
 was done
>>>> originally to use 'second' versions of l_timeout_*.
>>>
>>> Right, we could just convert it to the time.h format, uint64_t
>>> microseconds, but it would break the API.
>>>
>>
>> What API?
> =

> l_dhcp_lease_get_lifetime, though I guess you could just add a second
> getter for the full resolution value.

The lease lifetime seems to be getting abused anyway.  In DHCP client case =
it is =

just the plain lifetime value sent by the gateway, in the server case it se=
ems =

to be an absolute time.  So I suspect we need to keep storing it in seconds=
, but =

either change the timeout logic or keep additional info about the absolute =

timeout, preferably in l_time* compatible units.

>> I suspect you need a sanity check regardless if the l_time_to_msec conve=
rsion
>> results in something > UINT_MAX since the result is just truncated and t=
hat is
>> likely not what you want anyway.
> =

> I guess the behaviour (if we want to worry about it) should be that if
> the expiry time is too far out into the future then we set the longest
> timeout we can with the current API, and then in lease_expired_cb() we

Yep, that would be ideal.  Really, this should never-ever happen since our =

lifetimes are quite short.

> just reschedule the timeout if the lease has not expired, possibly
> this is what you mean too.
> =


Yep, that's what I had in mind.

Regards,
-Denis

--===============4900042046443780413==--

