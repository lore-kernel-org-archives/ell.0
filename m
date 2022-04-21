Content-Type: multipart/mixed; boundary="===============0537174765563832937=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH 01/11] net: Add l_net_subnet_matches
Date: Wed, 20 Apr 2022 21:36:45 -0500
Message-ID: <07a346d3-574e-b1e8-15a6-0a04784d4b38@gmail.com>
In-Reply-To: CAOq732+8rYW9t-kvOsQtFVHpUwJYwPz8yPsmjm4KeqtyauuSHg@mail.gmail.com

--===============0537174765563832937==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

> I put the following comment in one of the patches:
> =

> +        * TODO: check if we have a prefix route covering the IP,
> +        * l_dhcp6_client doesn't guarantee that the received IP is in
> +        * on of the subnets marked as on-link in the RA.
> =


You keep repeating this, but I still don't believe this is true.  You could=
 have =

RA gateway address being link-local, or subnet C.  The prefix info in the R=
A =

could be subnet B and the DHCPv6 address obtained could be in subnet A with=
 no =

overlap.  Why would you want to? Who knows ;)

The only 'requirement' is that the gateway is routable.  If it isn't, then =

obviously no traffic can get outside.

So I would simply drop this TODO, and any hope of doing any sort of validat=
ion. =

  Let the kernel do this.

> That's a different discussion.  We might want to warn or directly
> return an error from the D-Bus .Connect call if the connection is
> unusable, rather than ignore it and make the user discover it the hard
> way.  You could argue that it's usable for local traffic though.
> =


Let the higher layers deal with it.  If they need internet connectivity, th=
en =

services like connman already implement these types of checks.

>> If there is no gateway and the DNS address is not 'onlink', what 'implic=
it'
>> route can we add that would make any sense?
> =

> You could add a direct route for that ip, assume it's 'onlink'.  But

Yeah, no :)

> it's really an error situation and should rather be treated that way
> IMHO.

Sure, but I'd still let the higher levels deal with it.

Regards,
-Denis
--===============0537174765563832937==--

