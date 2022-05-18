Content-Type: multipart/mixed; boundary="===============6369535164601574762=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH] dhcp,dhcp6,icmp6,time: Convert timestamps to
 CLOCK_BOOTTIME
Date: Wed, 18 May 2022 09:19:30 -0500
Message-ID: <11b132ac-4069-88a6-ddfb-e68a570b810f@gmail.com>
In-Reply-To: 20220518003523.1717565-1-andrew.zaborowski@intel.com

--===============6369535164601574762==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 5/17/22 19:35, Andrew Zaborowski wrote:
> The frame reception timestamps obtained for DHCPv4, DHCPv6 and ICMPv6
> frames from the kernel are based on CLOCK_REALTIME, there's no option to
> switch them to CLOCK_BOOTTIME, which we use across our retransmission and
> renew logic.  Add a time-private.h utility to convert the timestamps
> right where we read them from recvmsg() to produce CLOCK_BOOTTIME based
> times.  This isn't 100% bulletproof because the offset between the two
> clocks can vary between the time the frame was received by the kernel and
> the time we read the offset.  The probability is very low though and we
> have no better solution at this time other than fixing it in the kernel.
> Using CLOCK_REALTIME for frame reception timestamps seems to mainly
> create potential for problems in the common usages.
> =

> Fixes: c78ad1bb6d7e ("dhcp: Set lease expiry based on frame reception tim=
es")
> ---
>   ell/dhcp-transport.c  |  3 ++-
>   ell/dhcp6-transport.c |  5 +++--
>   ell/icmp6.c           |  2 +-
>   ell/time-private.h    |  1 +
>   ell/time.c            | 34 ++++++++++++++++++++++++++++++++++
>   6 files changed, 44 insertions(+), 6 deletions(-)
> =


Applied, thanks.

Regards,
-Denis

--===============6369535164601574762==--

