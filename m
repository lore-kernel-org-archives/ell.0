Content-Type: multipart/mixed; boundary="===============4068083403357447555=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH 4/6] netconfig: Add netconfig API
Date: Tue, 08 Feb 2022 11:35:55 -0600
Message-ID: <1d920cfa-8c3f-4c25-1116-483d5b2b1498@gmail.com>
In-Reply-To: 20220207150717.60511-4-andrew.zaborowski@intel.com

--===============4068083403357447555==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 2/7/22 09:07, Andrew Zaborowski wrote:
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
> They can also decide to let another entity apply the changes.
> ---
>   Makefile.am     |   6 +-
>   ell/ell.h       |   1 +
>   ell/ell.sym     |   8 ++
>   ell/netconfig.c | 375 ++++++++++++++++++++++++++++++++++++++++++++++++
>   ell/netconfig.h |  73 ++++++++++
>   5 files changed, 461 insertions(+), 2 deletions(-)
>   create mode 100644 ell/netconfig.c
>   create mode 100644 ell/netconfig.h
> =


I have no real comments here.  This seems like the right approach.

Regards,
-Denis

--===============4068083403357447555==--

