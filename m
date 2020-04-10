Content-Type: multipart/mixed; boundary="===============2116513607678768168=="
MIME-Version: 1.0
From: Peter Seiderer <ps.report@gmx.net>
Subject: Re: [PATCH v1] ell/rtnl: fix compile with older toolchains
Date: Fri, 10 Apr 2020 22:06:04 +0200
Message-ID: <20200410220604.284ba74b@gmx.net>
In-Reply-To: <E3333D13-5302-40E7-84E0-D55468068E1F@holtmann.org>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2116513607678768168==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hello Marcel,

On Fri, 10 Apr 2020 19:58:53 +0200, Marcel Holtmann <marcel@holtmann.org>=
 wrote:

> Hi Peter,
> =

> > Older toolchains need to include sys/types.h and sys/socket.h before
> > linux/if.h, RTA_PREF was introduces with linux-4.1.x.  =

> =

> sounds like these are two separate fixes.
> =

> > =

> > Fixes:
> > =

> >  In file included from ell/rtnl.c:28:0:
> >  .../host/arm-buildroot-linux-gnueabi/sysroot/usr/include/linux/if.h:18=
5:19: error: field 'ifru_addr' has incomplete type
> >  .../host/arm-buildroot-linux-gnueabi/sysroot/usr/include/linux/if.h:18=
6:19: error: field 'ifru_dstaddr' has incomplete type
> >  .../host/arm-buildroot-linux-gnueabi/sysroot/usr/include/linux/if.h:18=
7:19: error: field 'ifru_broadaddr' has incomplete type
> >  .../host/arm-buildroot-linux-gnueabi/sysroot/usr/include/linux/if.h:18=
8:19: error: field 'ifru_netmask' has incomplete type
> >  .../arm-buildroot-linux-gnueabi/sysroot/usr/include/linux/if.h:189:20:=
 error: field 'ifru_hwaddr' has incomplete type
> >  ell/rtnl.c: In function 'l_rtnl_route_extract':
> >  ell/rtnl.c:120:8: error: 'RTA_PREF' undeclared (first use in this func=
tion)
> > ---
> > configure.ac | 2 ++
> > ell/rtnl.c   | 7 ++++++-
> > 2 files changed, 8 insertions(+), 1 deletion(-)
> > =

> > diff --git a/configure.ac b/configure.ac
> > index 0351f89..3be35a4 100644
> > --- a/configure.ac
> > +++ b/configure.ac
> > @@ -113,6 +113,8 @@ AC_CHECK_LIB(dl, dlopen, dummy=3Dyes,
> > =

> > AC_CHECK_HEADERS(linux/types.h linux/if_alg.h)
> > =

> > +AC_CHECK_DECLS([RTA_PREF], [], [], [[#include <linux/rtnetlink.h>]])
> > +
> > AC_ARG_ENABLE(glib, AC_HELP_STRING([--enable-glib],
> > 				[enable ell/glib main loop example]),
> > 					[enable_glib=3D${enableval}])
> > diff --git a/ell/rtnl.c b/ell/rtnl.c
> > index dc83937..3493d34 100644
> > --- a/ell/rtnl.c
> > +++ b/ell/rtnl.c
> > @@ -25,8 +25,9 @@
> > #endif
> > =

> > #define _GNU_SOURCE
> > -#include <linux/if.h>
> > +#include <sys/types.h>
> > #include <sys/socket.h>
> > +#include <linux/if.h>
> > #include <arpa/inet.h>
> > =

> > #include "util.h"
> > @@ -35,6 +36,10 @@
> > #include "rtnl.h"
> > #include "private.h"
> > =

> > +#if defined HAVE_DECL_RTA_PREF && !HAVE_DECL_RTA_PREF
> > +#define RTA_PREF 20
> > +#endif
> > +  =

> =

> Do we actually care about such an ancient kernel? And I don=E2=80=99t get=
 the if check above.

It is not about ancient kernel, but about the kernel-header files the toolc=
hain uses
(and in the embedded world this may be quiet ancient)...

Depending on the availability RTA_PREF it will be

#define HAVE_DECL_RTA_PREF 0

or =


#define HAVE_DECL_RTA_PREF 1

Both will trigger '#if defined HAVE_DECL_RTA_PREF' the second
one will check for 0 or 1 (but will give a warning in case
HAVE_DECL_RTA_PREF is not defined at all)...

See [1] for motivation of this patch...

Regards,
Peter

[1] http://lists.busybox.net/pipermail/buildroot/2020-April/279531.html

> =

> Regards
> =

> Marcel
>=20

--===============2116513607678768168==--

