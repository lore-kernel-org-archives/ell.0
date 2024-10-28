Received: from mail.holtmann.org (coyote.holtmann.net [212.227.132.17])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 6EAE71917D7
	for <ell@lists.linux.dev>; Mon, 28 Oct 2024 08:29:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=212.227.132.17
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1730104168; cv=none; b=q2PEliMP+yrQpNi2/AZ6YPrOAzXeHhIlyPgHDO+3P1e4+JA/qYH9Lr7okS09hUfyHAvD7RFUOeU+lgvucIoGmzHiKTBAMwfXGVMj2D81OECEAo5ZBAUJMrcf7q4YE/ef+5BkJHm1EtLPfRBB63wtqx9mII0/eKREb0q8oc7cMUQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1730104168; c=relaxed/simple;
	bh=reiw30XfzCLD6cCXnc/Vu7ZXAVHIZjYQ4FvhUpJnNfc=;
	h=Content-Type:Mime-Version:Subject:From:In-Reply-To:Date:Cc:
	 Message-Id:References:To; b=Q2UkSqEewixWL1P4AzBOyzX7/x5i9WEYUHk8iH24kwl4a7PPbmpN4CgUnmhxNp1vnznf+1eO7tGVngsk8kqhVAOT6/G45yQkHesXUbSvNk3D/7na7AK2Ii7R04sGWQGxxt6xlE0mv1MBJ35UcZzFt+OE3fwBLAmXTYeL2Z2fiDg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=holtmann.org; spf=pass smtp.mailfrom=holtmann.org; arc=none smtp.client-ip=212.227.132.17
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=holtmann.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=holtmann.org
Received: from smtpclient.apple (p4ff9fa77.dip0.t-ipconnect.de [79.249.250.119])
	by mail.holtmann.org (Postfix) with ESMTPSA id 8B728CECE6;
	Mon, 28 Oct 2024 09:21:22 +0100 (CET)
Content-Type: text/plain;
	charset=utf-8
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
Mime-Version: 1.0 (Mac OS X Mail 16.0 \(3818.100.11.1.3\))
Subject: Re: [PATCH] ell: Inclusion of netlink.h in genl.h because of recent
 changes
From: Marcel Holtmann <marcel@holtmann.org>
In-Reply-To: <CAL5LfdR_mL+LZ4APgLbWcptAvqnFvTJqgmE6Ryaj4gyquJYN3g@mail.gmail.com>
Date: Mon, 28 Oct 2024 09:21:11 +0100
Cc: ell@lists.linux.dev
Content-Transfer-Encoding: quoted-printable
Message-Id: <DB6E86A0-BD33-4252-B1BB-CBF24387441C@holtmann.org>
References: <CAL5LfdR_mL+LZ4APgLbWcptAvqnFvTJqgmE6Ryaj4gyquJYN3g@mail.gmail.com>
To: Aditya <vortexilation@gmail.com>
X-Mailer: Apple Mail (2.3818.100.11.1.3)

Hi Aditya,

> I have found out that because recent changes, compilation of mptcpd
> will failed with the following errors :
>=20
> In file included from path_manager.c:21:
> =
/home/user/works/openwrt/staging_dir/target-x86_64_glibc_custom/usr/includ=
e/ell/genl.h:
> In function 'l_genl_attr_next':
> =
/home/user/works/openwrt/staging_dir/target-x86_64_glibc_custom/usr/includ=
e/ell/genl.h:98:16:
> error: implicit declaration of function 'l_netlink_attr_next'; did you
> mean 'l_genl_attr_next'? [-Wimplicit-function-declaration]
>   98 |         return l_netlink_attr_next((struct l_netlink_attr *) =
attr,
>      |                ^~~~~~~~~~~~~~~~~~~
>      |                l_genl_attr_next
> =
/home/user/works/openwrt/staging_dir/target-x86_64_glibc_custom/usr/includ=
e/ell/genl.h:
> In function 'l_genl_attr_recurse':
> =
/home/user/works/openwrt/staging_dir/target-x86_64_glibc_custom/usr/includ=
e/ell/genl.h:105:16:
> error: implicit declaration of function 'l_netlink_attr_recurse'; did
> you mean 'l_genl_attr_recurse'? [-Wimplicit-function-declaration]
>  105 |         return l_netlink_attr_recurse((struct l_netlink_attr *) =
attr,
>      |                ^~~~~~~~~~~~~~~~~~~~~~
>      |                l_genl_attr_recurse
>=20
> This is compilation for glibc and by using gcc 14.2.0, the solution is
> fairly simple :
>=20
> diff -Naur a/ell/genl.h b/ell/genl.h
> --- a/ell/genl.h
> +++ b/ell/genl.h
> @@ -11,6 +11,7 @@
> #include <stdbool.h>
> #include <stddef.h>
> #include <stdint.h>
> +#include "netlink.h"
>=20
> #ifdef __cplusplus
> extern "C=E2=80=9D {
>=20

your fix is wrong. This is not a bug in ELL, this is a bug in mptcpd.

https://github.com/multipath-tcp/mptcpd/pull/309

Users of ELL must include <ell/ell.h> since all the other headers are
on purpose not self-contained.

Regards

Marcel

