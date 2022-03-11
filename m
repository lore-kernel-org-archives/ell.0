Content-Type: multipart/mixed; boundary="===============4935617497714353895=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH 09/12] netconfig: Add netconfig API
Date: Fri, 11 Mar 2022 10:11:23 -0600
Message-ID: <10a6ede1-411a-3b1a-0269-35502dfdbe42@gmail.com>
In-Reply-To: 20220307145543.1558788-9-andrew.zaborowski@intel.com

--===============4935617497714353895==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 3/7/22 08:55, Andrew Zaborowski wrote:
> This adds the netconfig class that will encapsulate static IP
> configuration, DHCP, DHCP6, ICMP6, SLAAC logic and free the user of
> manually handling DHCP/DHCP6 events to implement netconfig policies.
> The user will still need to handle committing received DNS and mdns
> information.
> =

> In this patch only IPv4 DHCP is implemented and no configurable settings
> are added.
> =

> When events are emitted for address and/or route changes, the changes
> are split into "added", "updated" and "removed" lists so that the user
> can decide apply those changes without first removing all addresses and
> routes from the interface and the re-adding the complete new list.
> They can also decide to let another entity apply the changes.  The
> obvious downside is the proliferation of lists.
> ---
>   Makefile.am     |   6 +-
>   ell/ell.h       |   1 +
>   ell/ell.sym     |   7 +
>   ell/netconfig.c | 377 ++++++++++++++++++++++++++++++++++++++++++++++++
>   ell/netconfig.h |  72 +++++++++
>   5 files changed, 461 insertions(+), 2 deletions(-)
>   create mode 100644 ell/netconfig.c
>   create mode 100644 ell/netconfig.h
> =


Due to:

make --no-print-directory all-am
   CC       unit/test-unit.o
   CC       ell/netconfig.lo
In file included from ell/netconfig.c:32:
ell/netconfig.c: In function =E2=80=98l_netconfig_stop=E2=80=99:
ell/netconfig.c:339:39: error: =E2=80=98struct l_netconfig=E2=80=99 has no =
member named =E2=80=98started=E2=80=99
   339 |  if (unlikely(!netconfig || !netconfig->started))
       |                                       ^~
ell/useful.h:26:41: note: in definition of macro =E2=80=98unlikely=E2=80=99
    26 | #define unlikely(x) __builtin_expect(!!(x), 0)
       |                                         ^

I slightly amended this patch to move the 'started' variable introduction f=
rom =

patch 11 over to this patch.

Applied, thanks.

Regards,
-Denis

--===============4935617497714353895==--

