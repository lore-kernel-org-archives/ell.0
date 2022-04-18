Content-Type: multipart/mixed; boundary="===============8006698020967116557=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH 05/11] rtnl: Minor cleanup
Date: Mon, 18 Apr 2022 14:22:10 -0500
Message-ID: <3425bff6-9ef7-e560-7c59-8b9b31aa0f95@gmail.com>
In-Reply-To: 20220411142056.817784-5-andrew.zaborowski@intel.com

--===============8006698020967116557==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 4/11/22 09:20, Andrew Zaborowski wrote:
> In l_rtnl_route_get_gateway return NULL if route is for an onlink prefix
> (no gateway).  Remove empty lines and use L_IN_SET in one instance.
> ---
>   ell/rtnl.c | 10 +++++-----
>   1 file changed, 5 insertions(+), 5 deletions(-)
> =


Applied, thanks.

Regards,
-Denis

--===============8006698020967116557==--

