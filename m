Content-Type: multipart/mixed; boundary="===============0694351610067626301=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: Re: [PATCH 1/6] rtnl: Track expiry times instead of lifetimes
Date: Tue, 08 Feb 2022 20:54:28 +0100
Message-ID: <CAOq732J7q1xjaRapf0do5GY3UfrWaojUDTbTebsHwcndOkagDw@mail.gmail.com>
In-Reply-To: 60416325-d32a-3b01-8953-f49af1eb3e16@gmail.com

--===============0694351610067626301==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Tue, 8 Feb 2022 at 19:45, Denis Kenzior <denkenz(a)gmail.com> wrote:
> > So the lifetime stored in an l_rtnl_{route,address} without a
> > reference time is useless once any time has passed from the lease
> > receival or RA.  That's going to be the case for both l_netconfig
> > internally and also the API user (caller of
> > l_netconfig_get_addresses).
>
> Right, but where does the caller get the reference time?  Calling l_time_=
now()
> possibly.  But lets say you got l_rtnl_route object by querying the kerne=
l over
> rtnl.  The reference time is actually the timestamp of the rtnetlink mess=
age
> (which we probably should obtain as well).  So reference_time parameter u=
se is
> just wrong in this context since the caller can't do the right thing.

Ok, yes, I kind of included that parameter for people who will need to
call l_rtnl_route_get_lifetime() for a whole list of routes, and want
to optimize and call l_time_now() just once.

> I would remove this completely and either track the reference time intern=
ally in
> l_rtnl_{route|address}, or inside l_netconfig.

How about l_rtnl_{get,set}_expiry? But I'm ok also making it internal
and moving the structs to rtnl-private.h, that would help optimize a
lot of these string conversions.  However IWD will need to read the
lifetimes in some form.

>
> >
> > So internally I could wrap l_rtnl_{route,address} in a new private
> > structre, but since it's also an issue for the public API I'd rather
> > create new public classes, and they'd be very similar to
> > l_rtnl_{route,address}.
> >
>
> I'm not following? Why isn't validity time enough?

I mean it's not enough in the current code where you call
l_rtnl_route_get_lifetime but you have no idea how much time has
already passed.  Any form that references a specific timestamp would
work.

>
> > New APIs outside of l_netconfig may end up having that problem too,
> > the user can't tell if an addresses is still valid.
> >
> > Remember we're basing l_netconfig on the idea that we don't set
> > timeouts for addresses or routes.  Without timers I'll probably be
> > purging expired addresses from the lists when
> > l_netconfig_get_addresses() is called and at other entry points.
>
> It isn't really a blanket ban on timers.  It is more to optimize the case=
 of a
> repeated RAs being received and having to blast all the info into the ker=
nel
> each time.

And IIRC avoid maintaining a timer FD per route/address.

>  We can still set a timer for DHCP lease for example.  Also, we can
> hook into the main loop to be woken up every time an event fires and upda=
te
> whatever expiry times we have, and optionally take action if needed.

It should be enough to do this on entry points into netconfig.c.

>
> >
> > Note we already use l_rtnl_address in places where most of its
> > contents are irrelevant.  I.e. we may only need 32 bits for each IPv4
> > address (prefix length is common to the subnet) but we chose to use
> > l_rtnl_address with the space overhead that it implies.  I thought the
> > slight extra size of the timestamp shouldn't be an issue.
>
> I'm mostly concerned about API use.  The 'reference' time is confusing to=
 a pure
> rtnetlink user.

True, 'lifetime' is the term used by the kernel but if it's not
updated it's wrong.  So either we should be returning an updated
lifetime or use a term like expiry.

Best regards
--===============0694351610067626301==--

