Received: from relay3-d.mail.gandi.net (relay3-d.mail.gandi.net [217.70.183.195])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D9E113CE083;
	Tue, 23 Jun 2026 08:42:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.70.183.195
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782204167; cv=none; b=mbgEb8qWwSctDO+rj66SJ+NaDb6Tomh2dJhlGogN/3OsLaK7dr+onFXhZZFeSw0VzB7dYOZDZzFpQaIpIgDtGp2vXTjUFPcdZH9aK5WRNcz7m6Axp9GkX7eVYSUN1Z9hR1uAKsrl5llvh+srgT06u5saiNS8d0xy356BbmEm12A=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782204167; c=relaxed/simple;
	bh=0kjK8YmYmJDEOGnbmMoUo+m/WY2eZp7URLgo18X+534=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=Sz27K/69GWMkeDkBYkNz1ZphvYFAfMObsROl4nbSzXIDbDxSlZS86cPV5CaAEbh3LF11wFTgsBiAOx15V6oVglV2O9mXMthr4UGFSTWP0nV3Sz7lTlvZF/qGZwE159Lee4rr1qn/pkT5D22zg4CWYJk0heYoJ08rhTVAOcO219A=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net; spf=pass smtp.mailfrom=hadess.net; arc=none smtp.client-ip=217.70.183.195
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hadess.net
Received: by mail.gandi.net (Postfix) with ESMTPSA id 331F81F75F;
	Tue, 23 Jun 2026 08:42:35 +0000 (UTC)
Message-ID: <fa46b3c8f70ee586439db68143cae4bcd40e537b.camel@hadess.net>
Subject: Re: [PATCH] crypto: af_alg - Add af_alg_restrict sysctl, defaulting
 to 1
From: Bastien Nocera <hadess@hadess.net>
To: Eric Biggers <ebiggers@kernel.org>, linux-crypto@vger.kernel.org, 
 Herbert Xu <herbert@gondor.apana.org.au>
Cc: linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, 
	linux-bluetooth@vger.kernel.org, iwd@lists.linux.dev, 
	linux-hardening@vger.kernel.org, Milan Broz <gmazyland@gmail.com>, Demi
 Marie Obenour <demiobenour@gmail.com>, Andy Lutomirski
 <luto@amacapital.net>, ell@lists.linux.dev
Date: Tue, 23 Jun 2026 10:42:34 +0200
In-Reply-To: <20260622234803.6982-1-ebiggers@kernel.org>
References: <20260622234803.6982-1-ebiggers@kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.60.2 (3.60.2-1.fc44) 
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
X-GND-Sasl: hadess@hadess.net
X-GND-State: clean
X-GND-Score: -100
X-GND-Cause: dmFkZTFjISr2LcG/UqOygHHl9e/XIVjJhRORQ6H0Fpq7FR/tKi5ROiRHdgj/bmAozKwIqjJ2NNI0ARzUl+Rv1Z7Gwns/JKaBKR5SqvETp6FF4zLQdQvXqzNvwC525Eh8owCNT7hGL2w6+DQ4sm0Dj4udGSS16CeEGRiTmy9ggtFuQlYlKC6YBS9RIM5o8cXvBxS/Xl8OqMLW5fHxfSbESpAOv2e3yW9Y3LljMDXAFSLVTN4DpO7wMe49kWxNclOc1Wr4Hj/Q9Y46iPeYaYbP8hIzJXKvKv9a92xgAW0VvvAhjDjXtEZqaXNXjWstwQw/LlQNBYZyJQr2VHaSLjqSraS4e6GyKHqPPZ6YK3Z3ftwh1FsnEBGDM2xznqS2CqZj/0lc0UQxmwr5WiwMZemIoy6Reh9DjPljUosXZNhwXtEclFVvNvSyt/w3l8aOxF+7sZhbPSaArmXojWXgtLs77h+x8koAe4LebRuhV0Fkpk8UixyG7VJJjgYRpV3ZIuo7ybSnD9P7iqsWvlj33Ify6SpJvvM4eoZKG9ndv3BRLpo1H5kLtD2vYw3+jNdGMExKJbm24LiILnyAAbiyGREajRcmf4fcrA7rdLXs0ZuIHA/bxrSs6dEoCQ9DcOqAzNaHlxs/wyBWeFUGUHrEzsjK90si3eIMu46qoUuXqWna87qX/gBn2Q

Hello Eric,

On Mon, 2026-06-22 at 16:48 -0700, Eric Biggers wrote:
> AF_ALG is a frequent source of vulnerabilities and a maintenance
> nightmare.=C2=A0 It exposes far more functionality to userspace than ever
> should have been exposed, especially to unprivileged processes.=C2=A0
> Recent
> exploits have targeted kernel internal implementation details like
> "authencesn" that have zero use case for userspace access.

You should also CC: ell@lists.linux.dev for AF_ALG related changes, as
ell uses AF_ALG extensively for crypto and checksumming.

Cheers

>=20
> Fortunately, AF_ALG is rarely used in practice, as userspace crypto
> libraries exist.=C2=A0 And when it is used, only some functionality is
> known
> to be used, and many users are known to hold capabilities already.
> iwd for example requires CAP_NET_ADMIN and has a known algorithm list
> (
> https://lore.kernel.org/linux-crypto/bcbbef00-5881-421b-8892-7be6c04b832d=
@gmail.com
> /).
>=20
> Thus, let's restrict the set of allowed algorithms by default,
> depending
> on the capabilities held.
>=20
> Add a sysctl /proc/sys/crypto/af_alg_restrict with meaning:
>=20
> =C2=A0=C2=A0=C2=A0 0: unrestricted
> =C2=A0=C2=A0=C2=A0 1: limited functionality
> =C2=A0=C2=A0=C2=A0 2: completely disabled
>=20
> Set the default value to 1, which enables an algorithm allowlist for
> unprivileged processes and a slightly longer allowlist for privileged
> processes.
>=20
> Note that the list may be tweaked in the future.=C2=A0 However, the commo=
n
> use cases such as iwd and bluez are taken into account already.=C2=A0 I'v=
e
> tested that iwd still works with the default value of 1.
>=20
> Signed-off-by: Eric Biggers <ebiggers@kernel.org>
> ---
> =C2=A0Documentation/admin-guide/sysctl/crypto.rst | 36 +++++++++++
> =C2=A0Documentation/crypto/userspace-if.rst=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0 | 13 +++-
> =C2=A0crypto/af_alg.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 | 72
> +++++++++++++++++++--
> =C2=A0crypto/algif_aead.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0 | 11 ++++
> =C2=A0crypto/algif_hash.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0 | 24 +++++++
> =C2=A0crypto/algif_rng.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0 |=C2=A0 9 +++
> =C2=A0crypto/algif_skcipher.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0 | 20 ++++++
> =C2=A0include/crypto/if_alg.h=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0 |=C2=A0 8 +++
> =C2=A08 files changed, 184 insertions(+), 9 deletions(-)
>=20
> diff --git a/Documentation/admin-guide/sysctl/crypto.rst
> b/Documentation/admin-guide/sysctl/crypto.rst
> index b707bd314a64..9a1bd53287f4 100644
> --- a/Documentation/admin-guide/sysctl/crypto.rst
> +++ b/Documentation/admin-guide/sysctl/crypto.rst
> @@ -5,10 +5,46 @@
> =C2=A0These files show up in ``/proc/sys/crypto/``, depending on the
> =C2=A0kernel configuration:
> =C2=A0
> =C2=A0.. contents:: :local:
> =C2=A0
> +.. _af_alg_restrict:
> +
> +af_alg_restrict
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> +
> +Controls the level of restriction of AF_ALG.
> +
> +AF_ALG is a deprecated and rarely-used userspace interface that is a
> +frequent source of vulnerabilities. It also unnecessarily exposes a
> +large number of kernel implementation details. For more information
> +about AF_ALG, see :ref:`Documentation/crypto/userspace-if.rst
> +<crypto_userspace_interface>`.
> +
> +Starting in Linux v7.3, AF_ALG supports only a limited set of
> +algorithms by default. This sysctl allows the system administrator
> to
> +remove this restriction when needed for compatibility reasons, or to
> +go further and disable AF_ALG entirely. The default value is 1.
> +
> +=3D=3D=3D=C2=A0
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> +0=C2=A0=C2=A0=C2=A0 AF_ALG is unrestricted.
> +
> +1=C2=A0=C2=A0=C2=A0 AF_ALG is supported with a limited list of algorithm=
s. The list
> +=C2=A0=C2=A0=C2=A0=C2=A0 is designed for compatibility with known users =
such as iwd and
> +=C2=A0=C2=A0=C2=A0=C2=A0 bluez that haven't yet been fixed to use usersp=
ace crypto code.
> +
> +=C2=A0=C2=A0=C2=A0=C2=A0 Specifically, there is an allowlist for unprivi=
leged processes
> +=C2=A0=C2=A0=C2=A0=C2=A0 and a somewhat longer allowlist for processes t=
hat hold
> +=C2=A0=C2=A0=C2=A0=C2=A0 CAP_SYS_ADMIN or CAP_NET_ADMIN in the initial u=
ser namespace.
> +
> +=C2=A0=C2=A0=C2=A0=C2=A0 Attempts to bind() an AF_ALG socket with a disa=
llowed algorithm
> +=C2=A0=C2=A0=C2=A0=C2=A0 fail with ENOENT.
> +
> +2=C2=A0=C2=A0=C2=A0 AF_ALG is completely disabled. Attempts to create an=
 AF_ALG
> +=C2=A0=C2=A0=C2=A0=C2=A0 socket fail with EAFNOSUPPORT.
> +=3D=3D=3D=C2=A0
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> +
> =C2=A0fips_enabled
> =C2=A0=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> =C2=A0
> =C2=A0Read-only flag that indicates whether FIPS mode is enabled.
> =C2=A0
> diff --git a/Documentation/crypto/userspace-if.rst
> b/Documentation/crypto/userspace-if.rst
> index ab93300c8e04..d6194346e366 100644
> --- a/Documentation/crypto/userspace-if.rst
> +++ b/Documentation/crypto/userspace-if.rst
> @@ -1,5 +1,7 @@
> +.. _crypto_userspace_interface:
> +
> =C2=A0User Space Interface
> =C2=A0=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> =C2=A0
> =C2=A0Introduction
> =C2=A0------------
> @@ -10,13 +12,18 @@ code.
> =C2=A0
> =C2=A0AF_ALG is insecure and is deprecated. Originally added to the kerne=
l
> in 2010,
> =C2=A0most kernel developers now consider it to be a mistake. Support for
> hardware
> =C2=A0accelerators, which was the original purpose of AF_ALG, has been
> removed.
> =C2=A0
> -AF_ALG continues to be supported only for backwards compatibility.
> On systems
> -where no programs using AF_ALG remain, the support for it should be
> disabled by
> -disabling ``CONFIG_CRYPTO_USER_API_*``.
> +AF_ALG continues to be supported only for backwards compatibility.
> +
> +Starting in Linux v7.3, the set of algorithms supported by AF_ALG is
> limited by
> +default. See :ref:`/proc/sys/crypto/af_alg_restrict
> <af_alg_restrict>`.
> +
> +On systems where no programs using AF_ALG remain, the support for it
> should be
> +disabled entirely by setting ``/proc/sys/crypto/af_alg_restrict`` to
> 2 or by
> +disabling ``CONFIG_CRYPTO_USER_API_*`` in the kernel configuration.
> =C2=A0
> =C2=A0Deprecation
> =C2=A0-----------
> =C2=A0
> =C2=A0AF_ALG was originally intended to provide userspace programs access
> to crypto
> diff --git a/crypto/af_alg.c b/crypto/af_alg.c
> index cce000e8590e..34b801568fba 100644
> --- a/crypto/af_alg.c
> +++ b/crypto/af_alg.c
> @@ -6,10 +6,11 @@
> =C2=A0 *
> =C2=A0 * Copyright (c) 2010 Herbert Xu <herbert@gondor.apana.org.au>
> =C2=A0 */
> =C2=A0
> =C2=A0#include <linux/atomic.h>
> +#include <linux/capability.h>
> =C2=A0#include <crypto/if_alg.h>
> =C2=A0#include <linux/crypto.h>
> =C2=A0#include <linux/init.h>
> =C2=A0#include <linux/kernel.h>
> =C2=A0#include <linux/key.h>
> @@ -20,14 +21,32 @@
> =C2=A0#include <linux/rwsem.h>
> =C2=A0#include <linux/sched.h>
> =C2=A0#include <linux/sched/signal.h>
> =C2=A0#include <linux/security.h>
> =C2=A0#include <linux/string.h>
> +#include <linux/sysctl.h>
> +#include <linux/user_namespace.h>
> =C2=A0#include <keys/user-type.h>
> =C2=A0#include <keys/trusted-type.h>
> =C2=A0#include <keys/encrypted-type.h>
> =C2=A0
> +static int af_alg_restrict =3D 1;
> +
> +static const struct ctl_table af_alg_table[] =3D {
> +	{
> +		.procname=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 =3D "af_alg_restrict",
> +		.data=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 =3D =
&af_alg_restrict,
> +		.maxlen=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 =3D sizeof(int=
),
> +		.mode=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 =3D =
0644,
> +		.proc_handler=C2=A0=C2=A0 =3D proc_dointvec_minmax,
> +		.extra1		=3D SYSCTL_ZERO,
> +		.extra2		=3D SYSCTL_TWO,
> +	},
> +};
> +
> +static struct ctl_table_header *af_alg_header;
> +
> =C2=A0struct alg_type_list {
> =C2=A0	const struct af_alg_type *type;
> =C2=A0	struct list_head list;
> =C2=A0};
> =C2=A0
> @@ -108,10 +127,43 @@ int af_alg_unregister_type(const struct
> af_alg_type *type)
> =C2=A0
> =C2=A0	return err;
> =C2=A0}
> =C2=A0EXPORT_SYMBOL_GPL(af_alg_unregister_type);
> =C2=A0
> +static bool af_alg_capable(void)
> +{
> +	return ns_capable_noaudit(&init_user_ns, CAP_NET_ADMIN) ||
> +	=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 capable(CAP_SYS_ADMIN);
> +}
> +
> +int af_alg_check_restriction(const char *name,
> +			=C2=A0=C2=A0=C2=A0=C2=A0 const struct af_alg_allowlist_entry
> allowlist[])
> +{
> +	int level =3D READ_ONCE(af_alg_restrict);
> +
> +	if (level =3D=3D 0)
> +		return 0;
> +	if (level =3D=3D 1) {
> +		for (const struct af_alg_allowlist_entry *ent =3D
> allowlist;
> +		=C2=A0=C2=A0=C2=A0=C2=A0 ent->name; ent++) {
> +			if (strcmp(name, ent->name) =3D=3D 0 &&
> +			=C2=A0=C2=A0=C2=A0 (!ent->privileged || af_alg_capable()))
> +				return 0;
> +		}
> +	}
> +	/*
> +	 * Use -ENOENT (the error code for "algorithm not found")
> instead of
> +	 * -EACCES or -EPERM, for the highest chance of correctly
> triggering
> +	 * fallback code paths in userspace programs.
> +	 *
> +	 * Don't log a warning, since it would be noisy.=C2=A0 iwd tries
> to bind a
> +	 * bunch of algorithms that it never uses.
> +	 */
> +	return -ENOENT;
> +}
> +EXPORT_SYMBOL_GPL(af_alg_check_restriction);
> +
> =C2=A0static void alg_do_release(const struct af_alg_type *type, void
> *private)
> =C2=A0{
> =C2=A0	if (!type)
> =C2=A0		return;
> =C2=A0
> @@ -504,10 +556,13 @@ static int alg_create(struct net *net, struct
> socket *sock, int protocol,
> =C2=A0		=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 int kern)
> =C2=A0{
> =C2=A0	struct sock *sk;
> =C2=A0	int err;
> =C2=A0
> +	if (READ_ONCE(af_alg_restrict) =3D=3D 2)
> +		return -EAFNOSUPPORT;
> +
> =C2=A0	if (sock->type !=3D SOCK_SEQPACKET)
> =C2=A0		return -ESOCKTNOSUPPORT;
> =C2=A0	if (protocol !=3D 0)
> =C2=A0		return -EPROTONOSUPPORT;
> =C2=A0
> @@ -1220,31 +1275,36 @@ int af_alg_get_rsgl(struct sock *sk, struct
> msghdr *msg, int flags,
> =C2=A0}
> =C2=A0EXPORT_SYMBOL_GPL(af_alg_get_rsgl);
> =C2=A0
> =C2=A0static int __init af_alg_init(void)
> =C2=A0{
> -	int err =3D proto_register(&alg_proto, 0);
> +	int err;
> +
> +	af_alg_header =3D register_sysctl("crypto", af_alg_table);
> =C2=A0
> +	err =3D proto_register(&alg_proto, 0);
> =C2=A0	if (err)
> -		goto out;
> +		goto out_unregister_sysctl;
> =C2=A0
> =C2=A0	err =3D sock_register(&alg_family);
> -	if (err !=3D 0)
> +	if (err)
> =C2=A0		goto out_unregister_proto;
> =C2=A0
> -out:
> -	return err;
> +	return 0;
> =C2=A0
> =C2=A0out_unregister_proto:
> =C2=A0	proto_unregister(&alg_proto);
> -	goto out;
> +out_unregister_sysctl:
> +	unregister_sysctl_table(af_alg_header);
> +	return err;
> =C2=A0}
> =C2=A0
> =C2=A0static void __exit af_alg_exit(void)
> =C2=A0{
> =C2=A0	sock_unregister(PF_ALG);
> =C2=A0	proto_unregister(&alg_proto);
> +	unregister_sysctl_table(af_alg_header);
> =C2=A0}
> =C2=A0
> =C2=A0module_init(af_alg_init);
> =C2=A0module_exit(af_alg_exit);
> =C2=A0MODULE_DESCRIPTION("Crypto userspace interface");
> diff --git a/crypto/algif_aead.c b/crypto/algif_aead.c
> index 787aac8aeb24..b9217f9086aa 100644
> --- a/crypto/algif_aead.c
> +++ b/crypto/algif_aead.c
> @@ -32,10 +32,15 @@
> =C2=A0#include <linux/mm.h>
> =C2=A0#include <linux/module.h>
> =C2=A0#include <linux/net.h>
> =C2=A0#include <net/sock.h>
> =C2=A0
> +static const struct af_alg_allowlist_entry aead_allowlist[] =3D {
> +	{ "ccm(aes)", true }, /* bluez */
> +	{},
> +};
> +
> =C2=A0static inline bool aead_sufficient_data(struct sock *sk)
> =C2=A0{
> =C2=A0	struct alg_sock *ask =3D alg_sk(sk);
> =C2=A0	struct sock *psk =3D ask->parent;
> =C2=A0	struct alg_sock *pask =3D alg_sk(psk);
> @@ -342,10 +347,16 @@ static struct proto_ops algif_aead_ops_nokey =3D
> {
> =C2=A0	.poll		=3D	af_alg_poll,
> =C2=A0};
> =C2=A0
> =C2=A0static void *aead_bind(const char *name)
> =C2=A0{
> +	int err;
> +
> +	err =3D af_alg_check_restriction(name, aead_allowlist);
> +	if (err)
> +		return ERR_PTR(err);
> +
> =C2=A0	return crypto_alloc_aead(name, 0, AF_ALG_CRYPTOAPI_MASK);
> =C2=A0}
> =C2=A0
> =C2=A0static void aead_release(void *private)
> =C2=A0{
> diff --git a/crypto/algif_hash.c b/crypto/algif_hash.c
> index 5452ad6c1506..a8d958d51ece 100644
> --- a/crypto/algif_hash.c
> +++ b/crypto/algif_hash.c
> @@ -14,10 +14,28 @@
> =C2=A0#include <linux/mm.h>
> =C2=A0#include <linux/module.h>
> =C2=A0#include <linux/net.h>
> =C2=A0#include <net/sock.h>
> =C2=A0
> +static const struct af_alg_allowlist_entry hash_allowlist[] =3D {
> +	{ "cmac(aes)", true }, /* iwd, bluez */
> +	{ "hmac(md5)", true }, /* iwd */
> +	{ "hmac(sha1)", true }, /* iwd */
> +	{ "hmac(sha224)", true }, /* iwd */
> +	{ "hmac(sha256)", true }, /* iwd */
> +	{ "hmac(sha384)", true }, /* iwd */
> +	{ "hmac(sha512)", true }, /* iwd, sha512hmac */
> +	{ "md4", true }, /* iwd */
> +	{ "md5", true }, /* iwd */
> +	{ "sha1", false }, /* iwd, iproute2 < 7.0 */
> +	{ "sha224", true }, /* iwd */
> +	{ "sha256", true }, /* iwd */
> +	{ "sha384", true }, /* iwd */
> +	{ "sha512", true }, /* iwd */
> +	{},
> +};
> +
> =C2=A0struct hash_ctx {
> =C2=A0	struct af_alg_sgl sgl;
> =C2=A0
> =C2=A0	u8 *result;
> =C2=A0
> @@ -380,10 +398,16 @@ static struct proto_ops algif_hash_ops_nokey =3D
> {
> =C2=A0	.accept		=3D	hash_accept_nokey,
> =C2=A0};
> =C2=A0
> =C2=A0static void *hash_bind(const char *name)
> =C2=A0{
> +	int err;
> +
> +	err =3D af_alg_check_restriction(name, hash_allowlist);
> +	if (err)
> +		return ERR_PTR(err);
> +
> =C2=A0	return crypto_alloc_ahash(name, 0, AF_ALG_CRYPTOAPI_MASK);
> =C2=A0}
> =C2=A0
> =C2=A0static void hash_release(void *private)
> =C2=A0{
> diff --git a/crypto/algif_rng.c b/crypto/algif_rng.c
> index 4dfe7899f8fa..bd522915d56d 100644
> --- a/crypto/algif_rng.c
> +++ b/crypto/algif_rng.c
> @@ -48,10 +48,14 @@
> =C2=A0
> =C2=A0MODULE_LICENSE("GPL");
> =C2=A0MODULE_AUTHOR("Stephan Mueller <smueller@chronox.de>");
> =C2=A0MODULE_DESCRIPTION("User-space interface for random number
> generators");
> =C2=A0
> +static const struct af_alg_allowlist_entry rng_allowlist[] =3D {
> +	{},
> +};
> +
> =C2=A0struct rng_ctx {
> =C2=A0#define MAXSIZE 128
> =C2=A0	unsigned int len;
> =C2=A0	struct crypto_rng *drng;
> =C2=A0	u8 *addtl;
> @@ -199,10 +203,15 @@ static struct proto_ops __maybe_unused
> algif_rng_test_ops =3D {
> =C2=A0
> =C2=A0static void *rng_bind(const char *name)
> =C2=A0{
> =C2=A0	struct rng_parent_ctx *pctx;
> =C2=A0	struct crypto_rng *rng;
> +	int err;
> +
> +	err =3D af_alg_check_restriction(name, rng_allowlist);
> +	if (err)
> +		return ERR_PTR(err);
> =C2=A0
> =C2=A0	pctx =3D kzalloc_obj(*pctx);
> =C2=A0	if (!pctx)
> =C2=A0		return ERR_PTR(-ENOMEM);
> =C2=A0
> diff --git a/crypto/algif_skcipher.c b/crypto/algif_skcipher.c
> index df20bdfe1f1f..2b8069667974 100644
> --- a/crypto/algif_skcipher.c
> +++ b/crypto/algif_skcipher.c
> @@ -32,10 +32,24 @@
> =C2=A0#include <linux/mm.h>
> =C2=A0#include <linux/module.h>
> =C2=A0#include <linux/net.h>
> =C2=A0#include <net/sock.h>
> =C2=A0
> +static const struct af_alg_allowlist_entry skcipher_allowlist[] =3D {
> +	{ "adiantum(xchacha12,aes)", false }, /* cryptsetup */
> +	{ "adiantum(xchacha20,aes)", false }, /* cryptsetup */
> +	{ "cbc(aes)", true }, /* iwd */
> +	{ "cbc(des)", true }, /* iwd */
> +	{ "cbc(des3_ede)", true }, /* iwd */
> +	{ "ctr(aes)", true }, /* iwd */
> +	{ "ecb(aes)", true }, /* iwd, bluez */
> +	{ "ecb(des)", true }, /* iwd */
> +	{ "hctr2(aes)", false }, /* cryptsetup */
> +	{ "xts(aes)", false }, /* cryptsetup benchmark */
> +	{},
> +};
> +
> =C2=A0static int skcipher_sendmsg(struct socket *sock, struct msghdr *msg=
,
> =C2=A0			=C2=A0=C2=A0=C2=A0 size_t size)
> =C2=A0{
> =C2=A0	struct sock *sk =3D sock->sk;
> =C2=A0	struct alg_sock *ask =3D alg_sk(sk);
> @@ -307,10 +321,16 @@ static struct proto_ops
> algif_skcipher_ops_nokey =3D {
> =C2=A0	.poll		=3D	af_alg_poll,
> =C2=A0};
> =C2=A0
> =C2=A0static void *skcipher_bind(const char *name)
> =C2=A0{
> +	int err;
> +
> +	err =3D af_alg_check_restriction(name, skcipher_allowlist);
> +	if (err)
> +		return ERR_PTR(err);
> +
> =C2=A0	return crypto_alloc_skcipher(name, 0,
> AF_ALG_CRYPTOAPI_MASK);
> =C2=A0}
> =C2=A0
> =C2=A0static void skcipher_release(void *private)
> =C2=A0{
> diff --git a/include/crypto/if_alg.h b/include/crypto/if_alg.h
> index 7643ba954125..4e9ed8e73403 100644
> --- a/include/crypto/if_alg.h
> +++ b/include/crypto/if_alg.h
> @@ -159,13 +159,21 @@ struct af_alg_ctx {
> =C2=A0	unsigned int len;
> =C2=A0
> =C2=A0	unsigned int inflight;
> =C2=A0};
> =C2=A0
> +struct af_alg_allowlist_entry {
> +	const char *name;
> +	bool privileged;
> +};
> +
> =C2=A0int af_alg_register_type(const struct af_alg_type *type);
> =C2=A0int af_alg_unregister_type(const struct af_alg_type *type);
> =C2=A0
> +int af_alg_check_restriction(const char *name,
> +			=C2=A0=C2=A0=C2=A0=C2=A0 const struct af_alg_allowlist_entry
> allowlist[]);
> +
> =C2=A0int af_alg_release(struct socket *sock);
> =C2=A0void af_alg_release_parent(struct sock *sk);
> =C2=A0int af_alg_accept(struct sock *sk, struct socket *newsock,
> =C2=A0		=C2=A0 struct proto_accept_arg *arg);
> =C2=A0
>=20
> base-commit: 1dc18801be29bc54709aa355b8acd80e183b03cd
