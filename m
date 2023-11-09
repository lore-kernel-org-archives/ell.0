Received: from mohas.pair.com (mohas.pair.com [209.68.5.112])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DE2B1360
	for <ell@lists.linux.dev>; Thu,  9 Nov 2023 00:08:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; dkim=none
Received: from mohas.pair.com (localhost [127.0.0.1])
	by mohas.pair.com (Postfix) with ESMTP id 9A8EC731EB;
	Wed,  8 Nov 2023 19:08:08 -0500 (EST)
Received: from [IPv6:2601:647:5a00:15c1:ec32:172b:4c97:6a74] (unknown [IPv6:2601:647:5a00:15c1:ec32:172b:4c97:6a74])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mohas.pair.com (Postfix) with ESMTPSA id 3B56273232;
	Wed,  8 Nov 2023 19:08:08 -0500 (EST)
Content-Type: text/plain;
	charset=utf-8
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
Mime-Version: 1.0 (Mac OS X Mail 13.4 \(3608.120.23.2.4\))
Subject: Re: ELL 0.59 Does Not Compile against Linux-4.9.212 and/or GLibC-2.28
From: Grant Erickson <gerickson@nuovations.com>
In-Reply-To: <2b9a12a2-87a9-4e10-b24d-77268369d01d@gmail.com>
Date: Wed, 8 Nov 2023 16:08:07 -0800
Cc: ell@lists.linux.dev,
 Marcel Holtmann <marcel@holtmann.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <124DF4B5-4611-458F-8F68-E386891838AD@nuovations.com>
References: <EE577BA9-358B-44E1-BC6E-810EBFA4998F@nuovations.com>
 <2b9a12a2-87a9-4e10-b24d-77268369d01d@gmail.com>
To: Denis Kenzior <denkenz@gmail.com>
X-Mailer: Apple Mail (2.3608.120.23.2.4)
X-Scanned-By: mailmunge 3.11 on 209.68.5.112

Denis,

Thanks for the fast turn around on the patches and response.

More below.

On Nov 8, 2023, at 3:56 PM, Denis Kenzior <denkenz@gmail.com> wrote:
> On 11/8/23 15:21, Grant Erickson wrote:
>> ELL Community:
>> Over on the connman mailing list, Marcel and Denis have been =
advocating, rightly so, for iwd over wpa_supplicant for Wi-Fi.
>> Is there a kernel version expectation of ELL?
>=20
> For the most part, no.  It should work with pretty old kernels.  But =
most of our development started post 4.15 or so.  If you need iwd to =
work with EAP, then 4.19 is required.  Otherwise, older kernels should =
work fine.

I=E2=80=99ve no requirement for EAP, so all good there.

>> For the current project I am engaged on, the kernel is locked at =
linux-4.9.212, glibc-2.28, and GCC 8.2. With that combination, I have =
found that the absolutely latest version of ELL I can build is 0.28. =
Regrettably, iwd requires a more recent version than that. However, =
neither the version of ELL that iwd embeds nor the latest independent =
version of ELL, 0.59 compile against the aforementioned combination. I =
see the following errors:
>=20
> Try the 4 patches I sent out.  Depending on your openssl version, you =
might see some weirdness there.  The detection logic seems to not work =
on _really_ old openssl versions.

Will do. I=E2=80=99m running openssl-1.1.1w.

Regarding the patches, won=E2=80=99t inclusion of an uprev netlink =
header result in a -ENOSYS or -EINVAL when those symbols hit the downrev =
kernel? Or were they privately defined in the 4.x series but not =
publicly exported?

Best,

Grant=
