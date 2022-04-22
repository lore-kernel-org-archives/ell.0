Content-Type: multipart/mixed; boundary="===============6208970699346849160=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH 13/13] icmp6,dhcp6,dhcp: Ensure buffer space for
 SCM_TIMESTAMP
Date: Fri, 22 Apr 2022 16:33:25 -0500
Message-ID: <8cd13bf8-3394-7957-55e5-962e3a8906b0@gmail.com>
In-Reply-To: 20220422185952.105279-13-andrew.zaborowski@intel.com

--===============6208970699346849160==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 4/22/22 13:59, Andrew Zaborowski wrote:
> Apparently the kernel will include message ancillary elements like
> SCM_TIMESTAMP even if there isn't enough space for the entire element.
> Reserve enough buffer space and check we received the whole
> SCM_TIMESTAMP element.
> =

> Fixes: adf18f2bae67 ("icmp6: Use SO_TIMESTAMP")
> Fixes: cd678415a75c ("dhcp6: Set lease expiry based on frame reception ti=
mes")
> Fixes: c78ad1bb6d7e ("dhcp: Set lease expiry based on frame reception tim=
es")
> ---
>   ell/dhcp-transport.c  | 6 ++++--
>   ell/dhcp6-transport.c | 8 +++++---
>   ell/icmp6.c           | 7 +++++--
>   3 files changed, 14 insertions(+), 7 deletions(-)
> =


Applied, thanks.

Regards,
-Denis

--===============6208970699346849160==--

