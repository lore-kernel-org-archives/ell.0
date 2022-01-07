Content-Type: multipart/mixed; boundary="===============3953237561725733524=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH 4/5] icmp6: Track routers and prefix routes from multiple
 RAs
Date: Fri, 07 Jan 2022 15:18:50 -0600
Message-ID: <d9934b52-f4a6-3049-f25f-0d5d6d9d5cad@gmail.com>
In-Reply-To: CAOq732KtZrD5t3LjOV+6zOS5_Gq1Lp_PWR6_xCmv_mqxhVF+OQ@mail.gmail.com

--===============3953237561725733524==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

> (But, didn't we talk on the IWD list about how we need to pass those
> events to a "netconfig-committer" entity and let it apply the
> settings?)
> =


That's why I'm asking.  It seems there is an implicit assumption that we wa=
nt to =

pass all the information from l_icmp6_client up to iwd and have it commit t=
he =

routes.   But given the complexity of doing this, I'm actually not entirely=
 sure =

it is worth the effort.

>>
>> In case of 2, the client just wants a snapshot of what the settings shou=
ld be,
>> not get notified that each individual route has changed.
> =

> Right, but we do need most of the events in this case.  If we're not

I'm still not following.  Wouldn't l_icmp6_client_get_full_info() be what y=
ou =

want?  And have the client call it after every L_ICMP6_CLIENT_EVENT_ROUTER_=
FOUND?

>> I suppose we do need at least a single timer for case 2 above.  But havi=
ng a
>> timer for each route seems excessive.
> =

> Are you ok we me converting this new code to use a single timer as a
> separate optimisation later, like I mentioned?
> =


Sure.

>> Yes, we could do that since you're not passing lifetimes in the proposed=
 iwd
>> API.  But is that intended or an oversight?
> =

> To be honest I didn't realise that finite lifetimes are actually
> popular (judging from the docs I read so far...), in fact only the
> prefix options support infinite lifetimes, default router info
> doesn't.  So wrt the D-Bus API it seems that not passing the lifetimes
> and lifetime updates will be much more efficient.  As for applying

Question is, are you sure that this is what NM guys would be ok with?

> them through RTNL we can also take care of cleaning up the routes
> ourselves and not set the lifetimes (either we don't call
> l_rtnl_route_set_lifetime at all, or we just don't pass the value to
> the kernel in rtnl.c)
> =


I think we need to find out if we can update just the lifetime first.  But =
in =

general I would tend to lean in the direction that we should be setting the =

lifetime.  The reason we don't do this now is just for expediency, not beca=
use =

it is the 'correct' thing to do.

Regards,
-Denis
--===============3953237561725733524==--

