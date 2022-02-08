Content-Type: multipart/mixed; boundary="===============3820464110537297598=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH 1/6] rtnl: Track expiry times instead of lifetimes
Date: Tue, 08 Feb 2022 12:45:29 -0600
Message-ID: <60416325-d32a-3b01-8953-f49af1eb3e16@gmail.com>
In-Reply-To: CAOq732KVzzZez9dSMBvSB45Uw1fH0hPe27+uQaJ_iaNKnYA=0A@mail.gmail.com

--===============3820464110537297598==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

> So the lifetime stored in an l_rtnl_{route,address} without a
> reference time is useless once any time has passed from the lease
> receival or RA.  That's going to be the case for both l_netconfig
> internally and also the API user (caller of
> l_netconfig_get_addresses).

Right, but where does the caller get the reference time?  Calling l_time_no=
w() =

possibly.  But lets say you got l_rtnl_route object by querying the kernel =
over =

rtnl.  The reference time is actually the timestamp of the rtnetlink messag=
e =

(which we probably should obtain as well).  So reference_time parameter use=
 is =

just wrong in this context since the caller can't do the right thing.

I would remove this completely and either track the reference time internal=
ly in =

l_rtnl_{route|address}, or inside l_netconfig.

> =

> So internally I could wrap l_rtnl_{route,address} in a new private
> structre, but since it's also an issue for the public API I'd rather
> create new public classes, and they'd be very similar to
> l_rtnl_{route,address}.
> =


I'm not following? Why isn't validity time enough?

> New APIs outside of l_netconfig may end up having that problem too,
> the user can't tell if an addresses is still valid.
> =

> Remember we're basing l_netconfig on the idea that we don't set
> timeouts for addresses or routes.  Without timers I'll probably be
> purging expired addresses from the lists when
> l_netconfig_get_addresses() is called and at other entry points.

It isn't really a blanket ban on timers.  It is more to optimize the case o=
f a =

repeated RAs being received and having to blast all the info into the kerne=
l =

each time.  We can still set a timer for DHCP lease for example.  Also, we =
can =

hook into the main loop to be woken up every time an event fires and update =

whatever expiry times we have, and optionally take action if needed.

> =

> Note we already use l_rtnl_address in places where most of its
> contents are irrelevant.  I.e. we may only need 32 bits for each IPv4
> address (prefix length is common to the subnet) but we chose to use
> l_rtnl_address with the space overhead that it implies.  I thought the
> slight extra size of the timestamp shouldn't be an issue.

I'm mostly concerned about API use.  The 'reference' time is confusing to a=
 pure =

rtnetlink user.

Regards,
-Denis
--===============3820464110537297598==--

