Content-Type: multipart/mixed; boundary="===============3001623879550740344=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH 04/11] rtnl: Add l_rtnl_route getters for raw address data
Date: Mon, 18 Apr 2022 14:21:05 -0500
Message-ID: <18da3822-f487-d9b5-1695-fb8697630549@gmail.com>
In-Reply-To: 20220411142056.817784-4-andrew.zaborowski@intel.com

--===============3001623879550740344==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 4/11/22 09:20, Andrew Zaborowski wrote:
> Add l_rtnl_route_get_gateway_in_addr and l_rtnl_route_get_dst_in_addr
> for raw struct in_addr / struct in6_addr addresses, as opposed to string
> representations.  This is to be used to avoid unneeded string
> conversions in both directions.
> ---
>   ell/ell.sym |  2 ++
>   ell/rtnl.c  | 30 ++++++++++++++++++++++++++++++
>   ell/rtnl.h  |  3 +++
>   3 files changed, 35 insertions(+)
> =


Applied, thanks.

Regards,
-Denis

--===============3001623879550740344==--

