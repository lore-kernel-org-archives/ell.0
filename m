Received: from mail.holtmann.org (coyote.holtmann.net [212.227.132.17])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 234801D522
	for <ell@lists.linux.dev>; Thu,  9 Nov 2023 14:53:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=holtmann.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=holtmann.org
Authentication-Results: smtp.subspace.kernel.org; dkim=none
Received: from smtpclient.apple (p4fefc822.dip0.t-ipconnect.de [79.239.200.34])
	by mail.holtmann.org (Postfix) with ESMTPSA id BFE05CECE3;
	Thu,  9 Nov 2023 15:53:45 +0100 (CET)
Content-Type: text/plain;
	charset=utf-8
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
Mime-Version: 1.0 (Mac OS X Mail 16.0 \(3774.200.91.1.1\))
Subject: Re: [PATCH 2/4] netlink: Fix compilation on really old platforms
From: Marcel Holtmann <marcel@holtmann.org>
In-Reply-To: <20231108234544.1050199-2-denkenz@gmail.com>
Date: Thu, 9 Nov 2023 15:53:35 +0100
Cc: ell@lists.linux.dev
Content-Transfer-Encoding: quoted-printable
Message-Id: <E3F4E4B3-9FA9-4592-BE11-8BB99D55E091@holtmann.org>
References: <20231108234544.1050199-1-denkenz@gmail.com>
 <20231108234544.1050199-2-denkenz@gmail.com>
To: Denis Kenzior <denkenz@gmail.com>
X-Mailer: Apple Mail (2.3774.200.91.1.1)

Hi Denis,

> Some platforms lack definitions of new netlink features.  Fix this
> by including a local copy of the most up to date netlink.h header.
>=20
>  CC       ell/netlink.lo
> ell/netlink.c: In function =E2=80=98l_netlink_set_debug=E2=80=99:
> ell/netlink.c:629:56: error: =E2=80=98NETLINK_EXT_ACK=E2=80=99 =
undeclared (first use in this function)
>  if (setsockopt(l_io_get_fd(netlink->io), SOL_NETLINK, =
NETLINK_EXT_ACK,
>                                                        ^
> ell/netlink.c:629:56: note: each undeclared identifier is reported =
only once for each function it appears in
> ell/netlink.c: In function =E2=80=98netlink_parse_ext_ack_error=E2=80=99=
:
> ell/netlink.c:649:29: error: =E2=80=98NLM_F_ACK_TLVS=E2=80=99 =
undeclared (first use in this function)
>  if (!(nlmsg->nlmsg_flags & NLM_F_ACK_TLVS))
>                             ^
> ell/netlink.c:657:29: error: =E2=80=98NLM_F_CAPPED=E2=80=99 undeclared =
(first use in this function)
>  if (!(nlmsg->nlmsg_flags & NLM_F_CAPPED))
>                             ^
> ell/netlink.c:677:8: error: =E2=80=98NLMSGERR_ATTR_MSG=E2=80=99 =
undeclared (first use in this function)
>   case NLMSGERR_ATTR_MSG:
>        ^
> ell/netlink.c:681:8: error: =E2=80=98NLMSGERR_ATTR_OFFS=E2=80=99 =
undeclared (first use in this function)
>   case NLMSGERR_ATTR_OFFS:
>        ^
> ---
> Makefile.am     |   2 +-
> linux/netlink.h | 383 ++++++++++++++++++++++++++++++++++++++++++++++++
> 2 files changed, 384 insertions(+), 1 deletion(-)
> create mode 100644 linux/netlink.h
>=20
> diff --git a/Makefile.am b/Makefile.am
> index 6c86e94e963e..ec75bb46ed44 100644
> --- a/Makefile.am
> +++ b/Makefile.am
> @@ -12,7 +12,7 @@ ELL_CURRENT =3D 0
> ELL_REVISION =3D 2
> ELL_AGE =3D 0
>=20
> -linux_headers =3D linux/gpio.h
> +linux_headers =3D linux/gpio.h linux/netlink.h

so while we could do this, I really don=E2=80=99t like it. Running after =
upstream netlink.h changes is something I rather not keep doing. For the =
nl80211.h header this is semi-ok, but I rather not keep doing that for =
all netlink headers.

Can we just add some of these into missing.h and #ifdef fallbacks. We do =
that for AF_ALG for example and I would prefer that than chasing =
upstream.

Regards

Marcel

