Content-Type: multipart/mixed; boundary="===============6946985578581354149=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: Re: [PATCH 1/6] rtnl: Track expiry times instead of lifetimes
Date: Tue, 08 Feb 2022 19:15:15 +0100
Message-ID: <CAOq732KVzzZez9dSMBvSB45Uw1fH0hPe27+uQaJ_iaNKnYA=0A@mail.gmail.com>
In-Reply-To: 61ad7b0e-d685-33c3-187c-c14d0cef2e41@gmail.com

--===============6946985578581354149==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On Tue, 8 Feb 2022 at 18:38, Denis Kenzior <denkenz(a)gmail.com> wrote:
> On 2/7/22 09:07, Andrew Zaborowski wrote:
> > Internally within rtnl.c store expiry times of addresses and routes
> > instead of their lifetime periods so that at any time the current
>
> I'm not too sure about this.  l_rtnl_route/address reflect the information
> obtained from RTNL.  They are going to be used not just for l_netconfig. =
 Why do
> we need the expiry time anyway?  Can't l_netconfig just set the lifetime =
based
> on its own expiry time book-keeping?

It can but it complicates things a little.

So the lifetime stored in an l_rtnl_{route,address} without a
reference time is useless once any time has passed from the lease
receival or RA.  That's going to be the case for both l_netconfig
internally and also the API user (caller of
l_netconfig_get_addresses).

So internally I could wrap l_rtnl_{route,address} in a new private
structre, but since it's also an issue for the public API I'd rather
create new public classes, and they'd be very similar to
l_rtnl_{route,address}.

New APIs outside of l_netconfig may end up having that problem too,
the user can't tell if an addresses is still valid.

Remember we're basing l_netconfig on the idea that we don't set
timeouts for addresses or routes.  Without timers I'll probably be
purging expired addresses from the lists when
l_netconfig_get_addresses() is called and at other entry points.

Note we already use l_rtnl_address in places where most of its
contents are irrelevant.  I.e. we may only need 32 bits for each IPv4
address (prefix length is common to the subnet) but we chose to use
l_rtnl_address with the space overhead that it implies.  I thought the
slight extra size of the timestamp shouldn't be an issue.

Best regards
--===============6946985578581354149==--

