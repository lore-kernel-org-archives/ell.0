Content-Type: multipart/mixed; boundary="===============1034575398292833395=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH 01/12] rtnl: Track route & address expiry times
Date: Fri, 11 Mar 2022 10:04:39 -0600
Message-ID: <2c48f00e-6dab-c52d-9713-51a0043765e9@gmail.com>
In-Reply-To: 20220307145543.1558788-1-andrew.zaborowski@intel.com

--===============1034575398292833395==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 3/7/22 08:55, Andrew Zaborowski wrote:
> Store expiry times of addresses and routes in addition to the lifetimes
> so that at any time the current lifetime left can be calculated.
> The expiry time is normally the creation or renewal time + lifetime.
> ---
>   ell/ell.sym |  4 +++
>   ell/rtnl.c  | 76 ++++++++++++++++++++++++++++++++++++++++++++++++-----
>   ell/rtnl.h  | 12 +++++++--
>   3 files changed, 83 insertions(+), 9 deletions(-)
> =


Patches 1-8 applied, thanks.

Regards,
-Denis

--===============1034575398292833395==--

