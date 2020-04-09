Content-Type: multipart/mixed; boundary="===============7635176498629629105=="
MIME-Version: 1.0
From: =?unknown-8bit?q?Micha=C5=82?= Lowas-Rzechonek <michal.lowas-rzechonek@silvair.com>
Subject: Re: [PATCH v1] ell/rtnl: fix compile with older toolchains
Date: Thu, 09 Apr 2020 23:15:07 +0200
Message-ID: <20200409211507.wfcz3dy6cqlzg3vy@kynes>
In-Reply-To: <20200409203818.19519-1-ps.report@gmx.net>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7635176498629629105==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Peter,

On 04/09, Peter Seiderer wrote:
> Older toolchains need to include sys/types.h and sys/socket.h before
> linux/if.h, RTA_PREF was introduces with linux-4.1.x.
> =

> Fixes:
> =

>   In file included from ell/rtnl.c:28:0:
>   .../host/arm-buildroot-linux-gnueabi/sysroot/usr/include/linux/if.h:185=
:19: error: field 'ifru_addr' has incomplete type
>   .../host/arm-buildroot-linux-gnueabi/sysroot/usr/include/linux/if.h:186=
:19: error: field 'ifru_dstaddr' has incomplete type
>   .../host/arm-buildroot-linux-gnueabi/sysroot/usr/include/linux/if.h:187=
:19: error: field 'ifru_broadaddr' has incomplete type
>   .../host/arm-buildroot-linux-gnueabi/sysroot/usr/include/linux/if.h:188=
:19: error: field 'ifru_netmask' has incomplete type
>   .../arm-buildroot-linux-gnueabi/sysroot/usr/include/linux/if.h:189:20: =
error: field 'ifru_hwaddr' has incomplete type
>   ell/rtnl.c: In function 'l_rtnl_route_extract':
>   ell/rtnl.c:120:8: error: 'RTA_PREF' undeclared (first use in this funct=
ion)

Nice one, I came up with almost identical patch, but eventually forgot
to send it!

Tested-by: Micha=C5=82 Lowas-Rzechonek <michal.lowas-rzechonek@silvair.co=
m>

-- =

Micha=C5=82 Lowas-Rzechonek <michal.lowas-rzechonek@silvair.com>
Silvair http://silvair.com
Jasnog=C3=B3rska 44, 31-358 Krakow, POLAND
--===============7635176498629629105==--

