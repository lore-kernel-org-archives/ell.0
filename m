Received: from mail.holtmann.org (coyote.holtmann.net [212.227.132.17])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 2A1881427B
	for <ell@lists.linux.dev>; Sun, 19 Nov 2023 16:50:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=holtmann.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=holtmann.org
Authentication-Results: smtp.subspace.kernel.org; dkim=none
Received: from smtpclient.apple (p4fefc822.dip0.t-ipconnect.de [79.239.200.34])
	by mail.holtmann.org (Postfix) with ESMTPSA id D926ACECD0
	for <ell@lists.linux.dev>; Sun, 19 Nov 2023 17:50:57 +0100 (CET)
From: Marcel Holtmann <marcel@holtmann.org>
Content-Type: text/plain;
	charset=utf-8
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
Mime-Version: 1.0 (Mac OS X Mail 16.0 \(3774.200.91.1.1\))
Subject: Re: [RFC PATCH 2/2] rtnl: Check if RTA_EXPIRES enum value is
 available
Date: Sun, 19 Nov 2023 17:50:47 +0100
References: <20231111180753.51488-2-marcel@holtmann.org>
To: ell@lists.linux.dev
In-Reply-To: <20231111180753.51488-2-marcel@holtmann.org>
Message-Id: <5A84029F-7CEA-4F04-ABEA-389DE0D123A6@holtmann.org>
X-Mailer: Apple Mail (2.3774.200.91.1.1)

Hi,

> Work around the missing RTA_EXPIRES settings of really really old
> kernels and disable setting that attribute if the enum value is not
> present.
> ---
> acinclude.m4 | 15 +++++++++++++++
> configure.ac |  2 ++
> ell/rtnl.c   |  4 ++++
> 3 files changed, 21 insertions(+)
>=20
> diff --git a/acinclude.m4 b/acinclude.m4
> index 6fb1de565a1d..3bb7b51d9ee6 100644
> --- a/acinclude.m4
> +++ b/acinclude.m4
> @@ -75,3 +75,18 @@ AC_DEFUN([COMPILER_FLAGS], [
> CFLAGS+=3D" -Wno-unknown-pragmas"
> fi
> ])
> +
> +AC_DEFUN([TEST_RTNL], [
> + AC_MSG_CHECKING([for RTA_EXPIRES])
> + AC_LANG_PUSH([C])
> + ac_rtnl_save_CFLAGS=3D"$CFLAGS"
> + CFLAGS=3D""
> + AC_COMPILE_IFELSE([
> + AC_LANG_PROGRAM([#include <linux/rtnetlink.h>],
> + [enum rtattr_type_t t =3D RTA_EXPIRES;])],
> + AC_DEFINE(HAVE_RTA_EXPIRES, 1,
> + [Define to 1 if you have the RTA_EXPIRES enum value.])
> + AC_MSG_RESULT([yes]), AC_MSG_RESULT([no]))
> + CFLAGS=3D$ac_rtnl_save_CFLAGS
> + AC_LANG_POP([C])
> +])
> diff --git a/configure.ac b/configure.ac
> index cf3b53cfb574..44084bc4384b 100644
> --- a/configure.ac
> +++ b/configure.ac
> @@ -111,6 +111,8 @@ AC_CHECK_FUNC(epoll_create, dummy=3Dyes,
>=20
> AC_CHECK_HEADERS(linux/types.h linux/if_alg.h)
>=20
> +TEST_RTNL
> +
> AC_ARG_ENABLE(glib, AS_HELP_STRING([--enable-glib],
> [enable ell/glib main loop example]),
> [enable_glib=3D${enableval}])
> diff --git a/ell/rtnl.c b/ell/rtnl.c
> index ad2dca2f9e3c..5b392eae3fb3 100644
> --- a/ell/rtnl.c
> +++ b/ell/rtnl.c
> @@ -1348,7 +1348,9 @@ static uint32_t _rtnl_route_change(struct =
l_netlink *rtnl,
> size_t bufsize;
> void *rta_buf;
> uint16_t flags;
> +#ifdef HAVE_RTA_EXPIRES
> uint64_t now =3D l_time_now();
> +#endif
>=20
> bufsize =3D NLMSG_ALIGN(sizeof(struct rtmsg)) +
> RTA_SPACE(sizeof(uint32_t)) +        /* RTA_OIF */
> @@ -1404,9 +1406,11 @@ static uint32_t _rtnl_route_change(struct =
l_netlink *rtnl,
> if (rt->preference)
> rta_buf +=3D rta_add_u8(rta_buf, RTA_PREF, rt->preference);
>=20
> +#ifdef HAVE_RTA_EXPIRES
> if (rt->expiry_time > now)
> rta_buf +=3D rta_add_u32(rta_buf, RTA_EXPIRES,
> l_time_to_secs(rt->expiry_time - now));
> +#endif

while I think this is simple enough, it might make sense to actually add =
RTA_EXPIRES even if older kernels don=E2=80=99t support it.

What other obstacles do we have to get ELL compiled and working on older =
kernels?

Regards

Marcel

