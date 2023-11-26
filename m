Received: from mohas.pair.com (mohas.pair.com [209.68.5.112])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AB8FDD515
	for <ell@lists.linux.dev>; Sun, 26 Nov 2023 18:26:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; dkim=none
Received: from mohas.pair.com (localhost [127.0.0.1])
	by mohas.pair.com (Postfix) with ESMTP id 8DD48730CE;
	Sun, 26 Nov 2023 13:26:26 -0500 (EST)
Received: from [IPv6:2601:647:5a00:15c1:5990:5683:21b8:9188] (unknown [IPv6:2601:647:5a00:15c1:5990:5683:21b8:9188])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mohas.pair.com (Postfix) with ESMTPSA id 2D548730FB;
	Sun, 26 Nov 2023 13:26:26 -0500 (EST)
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
In-Reply-To: <EE577BA9-358B-44E1-BC6E-810EBFA4998F@nuovations.com>
Date: Sun, 26 Nov 2023 10:26:25 -0800
Cc: ell@lists.linux.dev
Content-Transfer-Encoding: quoted-printable
Message-Id: <8C5460B3-DF8A-46E5-AB9B-343B2A099A4D@nuovations.com>
References: <EE577BA9-358B-44E1-BC6E-810EBFA4998F@nuovations.com>
To: Marcel Holtmann <marcel@holtmann.org>,
 Denis Kenzior <denkenz@gmail.com>
X-Mailer: Apple Mail (2.3608.120.23.2.4)
X-Scanned-By: mailmunge 3.11 on 209.68.5.112

On Nov 8, 2023, at 1:21 PM, Grant Erickson <gerickson@nuovations.com> =
wrote:
> ELL Community:
>=20
> Over on the connman mailing list, Marcel and Denis have been =
advocating, rightly so, for iwd over wpa_supplicant for Wi-Fi.
>=20
> Is there a kernel version expectation of ELL?
>=20
> For the current project I am engaged on, the kernel is locked at =
linux-4.9.212, glibc-2.28, and GCC 8.2. With that combination, I have =
found that the absolutely latest version of ELL I can build is 0.28. =
Regrettably, iwd requires a more recent version than that. However, =
neither the version of ELL that iwd embeds nor the latest independent =
version of ELL, 0.59 compile against the aforementioned combination. I =
see the following errors:
>=20
> [ =E2=80=A6 ]


Denis and Marcel,

Thank you for your work on this. I can confirm that ell-0.61 builds =
against my linux-4.9.212 / glibc-2.32 configuration and, in turn, =
ofono-2.2 builds against that. Hopefully, I=E2=80=99ll have similar =
success with iwd as well.

Best,

Grant

--=20
Principal
Nuovations

gerickson@nuovations.com
http://www.nuovations.com/

