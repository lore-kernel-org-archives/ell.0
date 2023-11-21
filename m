Received: from mail.holtmann.org (coyote.holtmann.net [212.227.132.17])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 32C2441A81
	for <ell@lists.linux.dev>; Tue, 21 Nov 2023 18:50:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=holtmann.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=holtmann.org
Authentication-Results: smtp.subspace.kernel.org; dkim=none
Received: from smtpclient.apple (p4fefc822.dip0.t-ipconnect.de [79.239.200.34])
	by mail.holtmann.org (Postfix) with ESMTPSA id A9969CECDA;
	Tue, 21 Nov 2023 19:50:22 +0100 (CET)
Content-Type: text/plain;
	charset=utf-8
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
Mime-Version: 1.0 (Mac OS X Mail 16.0 \(3774.200.91.1.1\))
Subject: Re: ELL 0.59 Does Not Compile against Linux-4.9.212 and/or GLibC-2.28
From: Marcel Holtmann <marcel@holtmann.org>
In-Reply-To: <4109CD12-09E3-498F-A088-89847F416EFB@nuovations.com>
Date: Tue, 21 Nov 2023 19:50:11 +0100
Cc: Denis Kenzior <denkenz@gmail.com>,
 ell@lists.linux.dev
Content-Transfer-Encoding: quoted-printable
Message-Id: <B20EB806-7930-40DA-B4A1-726117CABFCE@holtmann.org>
References: <EE577BA9-358B-44E1-BC6E-810EBFA4998F@nuovations.com>
 <2b9a12a2-87a9-4e10-b24d-77268369d01d@gmail.com>
 <124DF4B5-4611-458F-8F68-E386891838AD@nuovations.com>
 <DC4C03D7-B99E-475A-86AD-CB0AAD934BE3@holtmann.org>
 <4109CD12-09E3-498F-A088-89847F416EFB@nuovations.com>
To: Grant Erickson <gerickson@nuovations.com>
X-Mailer: Apple Mail (2.3774.200.91.1.1)

Hi Grant,

>>>>> Over on the connman mailing list, Marcel and Denis have been =
advocating, rightly so, for iwd over wpa_supplicant for Wi-Fi.
>>>>> Is there a kernel version expectation of ELL?
>>>=20
>>> Will do. I=E2=80=99m running openssl-1.1.1w.
>>>=20
>>> Regarding the patches, won=E2=80=99t inclusion of an uprev netlink =
header result in a -ENOSYS or -EINVAL when those symbols hit the downrev =
kernel? Or were they privately defined in the 4.x series but not =
publicly exported?
>>=20
>> any chance you can give ell-0.60 a spin and let me know if this =
helps. The only thing we left out was the RTA_EXPIRES workaround and I =
need to think about this a bit harder on how to work around it.
>=20
> Thank you for investing time on this. Here are my latest results =
against linux-4.9.212, glibc-2.37, and the Arm GNU Toolchain 12.3.1 =
against ell-0.60:

<snip>

>=20
>  CC       ell/dbus.lo
> ${BuildRoot}/third_party/ell/ell-0.60/ell/netlink.c: In function =
'netlink_parse_ext_ack_error':
> ${BuildRoot}/third_party/ell/ell-0.60/ell/netlink.c:649:36: error: =
'NLM_F_ACK_TLVS' undeclared (first use in this function); did you mean =
'NLM_F_ACK'?
>  649 |         if (!(nlmsg->nlmsg_flags & NLM_F_ACK_TLVS))
>      |                                    ^~~~~~~~~~~~~~
>      |                                    NLM_F_ACK
> ${BuildRoot}/third_party/ell/ell-0.60/ell/netlink.c:649:36: note: each =
undeclared identifier is reported only once for each function it appears =
in
> ${BuildRoot}/third_party/ell/ell-0.60/ell/netlink.c:657:36: error: =
'NLM_F_CAPPED' undeclared (first use in this function); did you mean =
'NLM_F_APPEND'?
>  657 |         if (!(nlmsg->nlmsg_flags & NLM_F_CAPPED))
>      |                                    ^~~~~~~~~~~~
>      |                                    NLM_F_APPEND
> make[2]: *** [Makefile:2026: ell/netlink.lo] Error 1
> make[2]: *** Waiting for unfinished jobs....
> make[1]: *** [Makefile:1296: all] Error 2
> make[1]: Leaving directory =
'${BuildRoot}/third_party/ell/.build/Makefile/${PRODUCT}/arm/gnu-toolchain=
/12.3.1/release'
> make: *** [Makefile:94: build] Error 2

this seems rather simple to fix and just an oversight on my part. Patch =
to fix this is on the mailing list. Hopefully that is enough.

Regards

Marcel

