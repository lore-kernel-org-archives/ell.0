Content-Type: multipart/mixed; boundary="===============5273162041819928646=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH 01/11] net: Add l_net_subnet_matches
Date: Tue, 19 Apr 2022 15:12:20 -0500
Message-ID: <f705212f-f095-1fd5-d975-dbaf8c292885@gmail.com>
In-Reply-To: CAOq732LGogmh7t7y81wsiUOmDevHT=ow2P8bvQzv_6XvXQp44w@mail.gmail.com

--===============5273162041819928646==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

> With IPv6 Router Advertisements you can have knowledge of multiple
> on-link prefixes.  The gateway needs to match one of them in exactly
> the same way as with IPv4.

But netconfig is not doing this matching? The kernel is?  icmp6 simply puts=
 in =

the default gateway info and the prefix routes into the routing table.  I d=
on't =

think it is 'our problem' if the prefixes and route info from the RA result=
s in =

the RA address not being routable.


> Well, if that address you're trying to validate (e.g. let's say your
> DNS IP) is on-link, which you'd find out from the RA, then you don't
> need to add anything to the routing table because your RA handler will
> already have added that route.  If it's not and there's no default
> router, then either it's an error or you might want to implicitly add
> a route for it.

If there is no gateway and the DNS address is not 'onlink', what 'implicit' =

route can we add that would make any sense?  Isn't the address simply unrea=
chable?

Why would we be 'validating' the DNS address in the first place?  How would=
 we =

validate it?

> =

> But the way you'd find out whether given IP is on-link is by calling
> l_net_subnet_matches for each prefix.  Their lengths vary from 0 to
> 128 like the RFC says.

Anyhow, just rename this function l_net_prefix_matches, since that is what =
you =

really intend.

Regards,
-Denis
--===============5273162041819928646==--

