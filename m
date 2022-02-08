Content-Type: multipart/mixed; boundary="===============1174956388293454058=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH 1/6] rtnl: Track expiry times instead of lifetimes
Date: Tue, 08 Feb 2022 11:38:27 -0600
Message-ID: <61ad7b0e-d685-33c3-187c-c14d0cef2e41@gmail.com>
In-Reply-To: 20220207150717.60511-1-andrew.zaborowski@intel.com

--===============1174956388293454058==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 2/7/22 09:07, Andrew Zaborowski wrote:
> Internally within rtnl.c store expiry times of addresses and routes
> instead of their lifetime periods so that at any time the current

I'm not too sure about this.  l_rtnl_route/address reflect the information =

obtained from RTNL.  They are going to be used not just for l_netconfig.  W=
hy do =

we need the expiry time anyway?  Can't l_netconfig just set the lifetime ba=
sed =

on its own expiry time book-keeping?

> lifetime left can be returned.  This is an incompatible API change to
> the lifetime getters and setters as they now take a reference_time
> parameter, which in the setter case should normally be the timestamp of
> when the address or route was received from DHCP.  These setters and
> getters don't seem to have been used outside of ell.
> ---
>   ell/dhcp.c  |  3 ++-
>   ell/dhcp6.c |  3 ++-
>   ell/rtnl.c  | 71 ++++++++++++++++++++++++++++++++++-------------------
>   ell/rtnl.h  | 15 +++++++----
>   4 files changed, 60 insertions(+), 32 deletions(-)
> =


Regards,
-Denis
--===============1174956388293454058==--

