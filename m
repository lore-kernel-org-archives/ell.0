Received: from mail.holtmann.org (coyote.holtmann.net [212.227.132.17])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 1B1271B279
	for <ell@lists.linux.dev>; Mon, 20 Nov 2023 14:55:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=holtmann.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=holtmann.org
Authentication-Results: smtp.subspace.kernel.org; dkim=none
Received: from smtpclient.apple (p4fefc822.dip0.t-ipconnect.de [79.239.200.34])
	by mail.holtmann.org (Postfix) with ESMTPSA id 6C519CECC4;
	Mon, 20 Nov 2023 15:55:19 +0100 (CET)
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
In-Reply-To: <124DF4B5-4611-458F-8F68-E386891838AD@nuovations.com>
Date: Mon, 20 Nov 2023 15:55:08 +0100
Cc: Denis Kenzior <denkenz@gmail.com>,
 ell@lists.linux.dev
Content-Transfer-Encoding: quoted-printable
Message-Id: <DC4C03D7-B99E-475A-86AD-CB0AAD934BE3@holtmann.org>
References: <EE577BA9-358B-44E1-BC6E-810EBFA4998F@nuovations.com>
 <2b9a12a2-87a9-4e10-b24d-77268369d01d@gmail.com>
 <124DF4B5-4611-458F-8F68-E386891838AD@nuovations.com>
To: Grant Erickson <gerickson@nuovations.com>
X-Mailer: Apple Mail (2.3774.200.91.1.1)

Hi Grant,

>>> ELL Community:
>>> Over on the connman mailing list, Marcel and Denis have been =
advocating, rightly so, for iwd over wpa_supplicant for Wi-Fi.
>>> Is there a kernel version expectation of ELL?
>>=20
>> For the most part, no.  It should work with pretty old kernels.  But =
most of our development started post 4.15 or so.  If you need iwd to =
work with EAP, then 4.19 is required.  Otherwise, older kernels should =
work fine.
>=20
> I=E2=80=99ve no requirement for EAP, so all good there.
>=20
>>> For the current project I am engaged on, the kernel is locked at =
linux-4.9.212, glibc-2.28, and GCC 8.2. With that combination, I have =
found that the absolutely latest version of ELL I can build is 0.28. =
Regrettably, iwd requires a more recent version than that. However, =
neither the version of ELL that iwd embeds nor the latest independent =
version of ELL, 0.59 compile against the aforementioned combination. I =
see the following errors:
>>=20
>> Try the 4 patches I sent out.  Depending on your openssl version, you =
might see some weirdness there.  The detection logic seems to not work =
on _really_ old openssl versions.
>=20
> Will do. I=E2=80=99m running openssl-1.1.1w.
>=20
> Regarding the patches, won=E2=80=99t inclusion of an uprev netlink =
header result in a -ENOSYS or -EINVAL when those symbols hit the downrev =
kernel? Or were they privately defined in the 4.x series but not =
publicly exported?

any chance you can give ell-0.60 a spin and let me know if this helps. =
The only thing we left out was the RTA_EXPIRES workaround and I need to =
think about this a bit harder on how to work around it.

Regards

Marcel

