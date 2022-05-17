Content-Type: multipart/mixed; boundary="===============0542832733278743735=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH] dhcp,dhcp6,icmp6,time: Convert timestamps to
 CLOCK_BOOTTIME
Date: Tue, 17 May 2022 09:37:06 -0500
Message-ID: <bc24661a-7fcb-01f7-62de-da38f82b9e34@gmail.com>
In-Reply-To: 20220516213153.1612039-1-andrew.zaborowski@intel.com

--===============0542832733278743735==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 5/16/22 16:31, Andrew Zaborowski wrote:
> The frame reception timestamps obtained for DHCPv4, DHCPv6 and ICMPv6
> frames from the kernel are based on CLOCK_REALTIME, there's no option to
> switch them to CLOCK_BOOTTIME, which we use across our retransmission and
> renew logic.  Add a time-private.h utility to get the offset between the
> two clocks and offset the timestamps right where read them from recvmsg()
> to produce CLOCK_BOOTTIME based times.  This isn't 100% bulletproof
> because the offset between the two clocks can vary between the moment the
> frame was received by the kernel and the time we read the offset.  The
> probability is very low though and we have no better solution at this
> time other than fixing it in the kernel.  Using CLOCK_REALTIME for frame
> reception timestamps seems to only create potential for problems in the
> common usages.
> =

> Fixes: c78ad1bb6d7e ("dhcp: Set lease expiry based on frame reception tim=
es")
> ---
>   ell/dhcp-transport.c  |  8 +++++++-
>   ell/dhcp6-transport.c | 12 +++++++++---
>   ell/icmp6.c           |  7 ++++++-
>   ell/time-private.h    |  1 +
>   ell/time.c            | 17 +++++++++++++++++
>   5 files changed, 40 insertions(+), 5 deletions(-)
> =


Makes sense to me, just minor comments:

> diff --git a/ell/dhcp-transport.c b/ell/dhcp-transport.c
> index 52da2db..ba1423f 100644
> --- a/ell/dhcp-transport.c
> +++ b/ell/dhcp-transport.c
> @@ -45,6 +45,7 @@
>   #include "util.h"
>   #include "private.h"
>   #include "time.h"
> +#include "time-private.h"
>   #include "dhcp-private.h"
>   =

>   struct dhcp_default_transport {
> @@ -170,7 +171,12 @@ static bool _dhcp_default_transport_read_handler(str=
uct l_io *io,
>   				CMSG_LEN(sizeof(struct timeval))) {
>   			const struct timeval *tv =3D (void *) CMSG_DATA(cmsg);
>   =

> -			timestamp =3D tv->tv_sec * L_USEC_PER_SEC + tv->tv_usec;
> +			/*
> +			 * Not ideal but this is our best approximation of the
> +			 * CLOCK_BOOTTIME-based Rx time.
> +			 */
> +			timestamp =3D tv->tv_sec * L_USEC_PER_SEC + tv->tv_usec -
> +				_time_get_realtime_boottime_offset();

Can we actually just send the timestamp as a 'struct timeval' to the privat=
e =

function?  Instead of duplicating the conversion calculation everywhere?

>   		}
>   	}
>   =


<snip>

> diff --git a/ell/time.c b/ell/time.c
> index d02dabe..cda09be 100644
> --- a/ell/time.c
> +++ b/ell/time.c
> @@ -105,3 +105,20 @@ uint64_t _time_fuzz_secs(uint32_t secs, uint32_t max=
_offset)
>   =

>   	return ms;
>   }
> +
> +/*
> + * Get approximate difference between CLOCK_REALTIME and CLOCK_BOOTTIME,
> + * for converting recent timestamps from one to the other.  The value can
> + * change at any time.
> + */
> +int64_t _time_get_realtime_boottime_offset(void)

So I would avoid signed integers for these calculations.  We already have =

l_time_before/l_time_after.  And l_time_offset takes care of overflows.  Le=
ts =

use those to implement this.  You also need to consider potential underflow=
, =

though it is probably astronomically unlikely.

I'd name this something like:

uint64_t _time_realtime_to_boottime(const struct timeval *ts)

By the way, given that you're using struct timespec below, do you want to u=
se =

SO_TIMESTAMPNS?

> +{
> +	struct timespec boottime;
> +	struct timespec realtime;
> +
> +	clock_gettime(CLOCK_BOOTTIME, &boottime);
> +	clock_gettime(CLOCK_REALTIME, &realtime);
> +

Then here do something like:

offset =3D l_time_diff(ts, now_realtime);

/* most likely case, timestamp in the past */
if (l_time_before(ts, now_realtime)) {
	if (offset > now_boot)
		return 0;

	return now_boot - offset;
}

return l_time_offset(now_boot, offset);

> +	return ((int64_t) realtime.tv_sec - boottime.tv_sec) * 1000000 +
> +		((int64_t) realtime.tv_nsec - boottime.tv_nsec) / 1000;

Lets use the L_USEC_* defines when possible.

> +}
> =


Regards,
-Denis
--===============0542832733278743735==--

