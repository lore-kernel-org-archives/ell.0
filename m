Content-Type: multipart/mixed; boundary="===============7740909292610498270=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH 1/3] rtnl: Fix address conversion buffer overflow.
Date: Wed, 10 Nov 2021 09:55:51 -0600
Message-ID: <ac6e7c2c-c8ea-a10c-20a3-f3c8d5ee2031@gmail.com>
In-Reply-To: 20211110001448.175980-2-ossama.othman@intel.com

--===============7740909292610498270==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Ossama,

On 11/9/21 6:14 PM, Ossama Othman wrote:
> Some l_rtnl functions that return a stringified address could
> potentially overrun a user supplied buffer of insufficient length.
> Add a buffer length argument to prevent ELL from making incorrect
> assumptions.  Impacted functions are l_rtnl_address_get_address(),
> l_rtnl_route_get_gateway(), and l_rtnl_route_get_prefsrc().
> ---
>   ell/rtnl.c | 28 +++++++++++++++++-----------
>   ell/rtnl.h |  8 +++++---
>   2 files changed, 22 insertions(+), 14 deletions(-)
> =


<snip>

>   bool l_rtnl_address_get_address(const struct l_rtnl_address *addr,
> -				char *out_buf);
> +				char *out_buf, size_t buflen);

So I'm a little torn about this.  On the one hand, specifying the buffer le=
n is =

indeed safer.  However, simply passing a buffer of size INET6_ADDRSTRLEN is=
 also =

guaranteed to work for any address that we support and saves the need for t=
he =

extra argument.  Alternatively, if you know the family or can look it up vi=
a =

l_rtnl_*_get_family(), you can use INET_ADDRSTRLEN for ipv4 getters.  Maybe=
 this =

is more of a documentation issue?

If you look at how iwd uses these functions, the extra argument is unnecess=
ary.

Can you share more info about what made you propose this change?  Are you u=
sing =

these functions in ways where the buffer size argument would be advantageou=
s?

Regards,
-Denis
--===============7740909292610498270==--

