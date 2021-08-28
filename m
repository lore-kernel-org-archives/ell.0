Content-Type: multipart/mixed; boundary="===============2916035441588484636=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] rtnl: Add neighbor discovery utilities
Date: Fri, 27 Aug 2021 20:12:34 -0500
Message-ID: <65671350-35ab-1e62-1772-9402da02061c@gmail.com>
In-Reply-To: <20210826224759.334624-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2916035441588484636==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 8/26/21 5:47 PM, Andrew Zaborowski wrote:
> Add a few variants of RTNL utilities to look up addresses in the
> kernel's neighbour table entries and to add new entries.  This is
> basically the ARP (for IPv4) and NDP (for IPv6) tables, that map IP
> addresses to hardware addresses.
> ---
>   ell/ell.sym  |   2 +
>   ell/rtnl.c   | 127 +++++++++++++++++++++++++++++++++++++++++++++++++++
>   ell/rtnl.h   |  17 +++++++
>   ell/useful.h |   4 ++
>   4 files changed, 150 insertions(+)
> =


Applied, thanks.

Regards,
-Denis

--===============2916035441588484636==--

