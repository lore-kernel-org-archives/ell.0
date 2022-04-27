Content-Type: multipart/mixed; boundary="===============6601596710496342520=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH 03/13] netconfig: Add DHCP override and static IP API
Date: Tue, 26 Apr 2022 21:30:16 -0500
Message-ID: <4469529f-e08a-6aee-3ab6-c2d5d936ce67@gmail.com>
In-Reply-To: 20220422185952.105279-3-andrew.zaborowski@intel.com

--===============6601596710496342520==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 4/22/22 13:59, Andrew Zaborowski wrote:
> Add API to override things like DNS, domain names, etc. received from
> DHCP or disable DHCP completely by setting a static address.
> ---
>   ell/ell.sym     |   8 ++
>   ell/netconfig.c | 322 +++++++++++++++++++++++++++++++++++++++++++++++-
>   ell/netconfig.h |  16 +++
>   3 files changed, 341 insertions(+), 5 deletions(-)
> =


Applied, thanks.

Regards,
-Denis

--===============6601596710496342520==--

