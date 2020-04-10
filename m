Content-Type: multipart/mixed; boundary="===============5686607283360810994=="
MIME-Version: 1.0
From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH v1] ell/rtnl: fix compile with older toolchains
Date: Fri, 10 Apr 2020 19:58:53 +0200
Message-ID: <E3333D13-5302-40E7-84E0-D55468068E1F@holtmann.org>
In-Reply-To: <20200409203818.19519-1-ps.report@gmx.net>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5686607283360810994==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Peter,

> Older toolchains need to include sys/types.h and sys/socket.h before
> linux/if.h, RTA_PREF was introduces with linux-4.1.x.

sounds like these are two separate fixes.

> =

> Fixes:
> =

>  In file included from ell/rtnl.c:28:0:
>  .../host/arm-buildroot-linux-gnueabi/sysroot/usr/include/linux/if.h:185:=
19: error: field 'ifru_addr' has incomplete type
>  .../host/arm-buildroot-linux-gnueabi/sysroot/usr/include/linux/if.h:186:=
19: error: field 'ifru_dstaddr' has incomplete type
>  .../host/arm-buildroot-linux-gnueabi/sysroot/usr/include/linux/if.h:187:=
19: error: field 'ifru_broadaddr' has incomplete type
>  .../host/arm-buildroot-linux-gnueabi/sysroot/usr/include/linux/if.h:188:=
19: error: field 'ifru_netmask' has incomplete type
>  .../arm-buildroot-linux-gnueabi/sysroot/usr/include/linux/if.h:189:20: e=
rror: field 'ifru_hwaddr' has incomplete type
>  ell/rtnl.c: In function 'l_rtnl_route_extract':
>  ell/rtnl.c:120:8: error: 'RTA_PREF' undeclared (first use in this functi=
on)
> ---
> configure.ac | 2 ++
> ell/rtnl.c   | 7 ++++++-
> 2 files changed, 8 insertions(+), 1 deletion(-)
> =

> diff --git a/configure.ac b/configure.ac
> index 0351f89..3be35a4 100644
> --- a/configure.ac
> +++ b/configure.ac
> @@ -113,6 +113,8 @@ AC_CHECK_LIB(dl, dlopen, dummy=3Dyes,
> =

> AC_CHECK_HEADERS(linux/types.h linux/if_alg.h)
> =

> +AC_CHECK_DECLS([RTA_PREF], [], [], [[#include <linux/rtnetlink.h>]])
> +
> AC_ARG_ENABLE(glib, AC_HELP_STRING([--enable-glib],
> 				[enable ell/glib main loop example]),
> 					[enable_glib=3D${enableval}])
> diff --git a/ell/rtnl.c b/ell/rtnl.c
> index dc83937..3493d34 100644
> --- a/ell/rtnl.c
> +++ b/ell/rtnl.c
> @@ -25,8 +25,9 @@
> #endif
> =

> #define _GNU_SOURCE
> -#include <linux/if.h>
> +#include <sys/types.h>
> #include <sys/socket.h>
> +#include <linux/if.h>
> #include <arpa/inet.h>
> =

> #include "util.h"
> @@ -35,6 +36,10 @@
> #include "rtnl.h"
> #include "private.h"
> =

> +#if defined HAVE_DECL_RTA_PREF && !HAVE_DECL_RTA_PREF
> +#define RTA_PREF 20
> +#endif
> +

Do we actually care about such an ancient kernel? And I don=E2=80=99t get t=
he if check above.

Regards

Marcel

--===============5686607283360810994==--

