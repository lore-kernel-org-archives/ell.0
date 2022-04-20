Content-Type: multipart/mixed; boundary="===============4196786615749572946=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: Re: [PATCH 01/11] net: Add l_net_subnet_matches
Date: Thu, 21 Apr 2022 00:34:28 +0200
Message-ID: <CAOq732+8rYW9t-kvOsQtFVHpUwJYwPz8yPsmjm4KeqtyauuSHg@mail.gmail.com>
In-Reply-To: f705212f-f095-1fd5-d975-dbaf8c292885@gmail.com

--===============4196786615749572946==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On Tue, 19 Apr 2022 at 22:12, Denis Kenzior <denkenz(a)gmail.com> wrote:
> > With IPv6 Router Advertisements you can have knowledge of multiple
> > on-link prefixes.  The gateway needs to match one of them in exactly
> > the same way as with IPv4.
>
> But netconfig is not doing this matching?

I put the following comment in one of the patches:

+        * TODO: check if we have a prefix route covering the IP,
+        * l_dhcp6_client doesn't guarantee that the received IP is in
+        * on of the subnets marked as on-link in the RA.

So it's not currently doing this but like I said l_net_subnet_match is
a public function so it's irrelevant whether netconfig is doing this.
We don't want to make public functions only work for some use cases
(without documenting which ones...) but rather for the generally
useful scenarios.

> The kernel is?  icmp6 simply puts in
> the default gateway info and the prefix routes into the routing table.  I=
 don't
> think it is 'our problem' if the prefixes and route info from the RA resu=
lts in
> the RA address not being routable.

That's a different discussion.  We might want to warn or directly
return an error from the D-Bus .Connect call if the connection is
unusable, rather than ignore it and make the user discover it the hard
way.  You could argue that it's usable for local traffic though.

>
>
> > Well, if that address you're trying to validate (e.g. let's say your
> > DNS IP) is on-link, which you'd find out from the RA, then you don't
> > need to add anything to the routing table because your RA handler will
> > already have added that route.  If it's not and there's no default
> > router, then either it's an error or you might want to implicitly add
> > a route for it.
>
> If there is no gateway and the DNS address is not 'onlink', what 'implici=
t'
> route can we add that would make any sense?

You could add a direct route for that ip, assume it's 'onlink'.  But
it's really an error situation and should rather be treated that way
IMHO.

>  Isn't the address simply unreachable?
>
> Why would we be 'validating' the DNS address in the first place?

To avoid wasting the user's time connecting to an unusable SSID and
possibly try the next network available.  But again that's a different
topic.

>  How would we
> validate it?

By checking if we have a route covering the address.  Basically same
as how we validate static configurations.

Best regards
--===============4196786615749572946==--

