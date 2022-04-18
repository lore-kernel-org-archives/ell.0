Content-Type: multipart/mixed; boundary="===============6691772338773962632=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH 07/11] icmp6: Emit L_ICMP6_CLIENT_EVENT_ROUTER_FOUND for
 all RAs
Date: Mon, 18 Apr 2022 16:10:59 -0500
Message-ID: <a5018523-e400-0bb1-9975-2260fac973d6@gmail.com>
In-Reply-To: 20220411142056.817784-7-andrew.zaborowski@intel.com

--===============6691772338773962632==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 4/11/22 09:20, Andrew Zaborowski wrote:
> Emit an L_ICMP6_CLIENT_EVENT_ROUTER_FOUND event for ever Router
> Advertisement received instead of only the first one.
> ---
>   ell/dhcp6.c | 10 +++++++---
>   ell/icmp6.c | 17 ++++++++---------
>   2 files changed, 15 insertions(+), 12 deletions(-)

Applied, thanks.

Regards,
-Denis

--===============6691772338773962632==--

