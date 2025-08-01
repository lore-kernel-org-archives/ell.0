Received: from relay2-d.mail.gandi.net (relay2-d.mail.gandi.net [217.70.183.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ED5FF128395
	for <ell@lists.linux.dev>; Fri,  1 Aug 2025 20:23:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.70.183.194
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1754079795; cv=none; b=mxyvDci9AxT+IrnaefcHtxnlcZ8/a9KmLeWyGN44m/tz72/t4Ex3IyWSJvgXkCyhcyYRLO2oVL+DNoxqYrWiiN/IhUN+Fofj7yhP1hHxXjHmxqBMnFDUxVJPJwEF3CdtvXWhtmdNH3cgd4wQGvI4DWnyuHPn6mrDgZRXVmK/Kuk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1754079795; c=relaxed/simple;
	bh=rqsPd5yruuoc233aFm3N4jbhWe6QpiCKceIPtROpILU=;
	h=Message-ID:Subject:From:To:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=QCzqxwbB7zhlzDkw/7Ae7FtBHtIN6blpSQTHuFvm7NhpU5o6kYJ4ua3njTxWFEuqV1mjVihz4Lhse3UGXzcv+64eakJXuMNWL2NdVzDs5YKk5qZnPQxuOPlFRM9LSoTqSEkRCKcldVPemaw3H+CCj5yOnAhTy6F0us8AzVwuw/Q=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net; spf=pass smtp.mailfrom=hadess.net; arc=none smtp.client-ip=217.70.183.194
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hadess.net
Received: by mail.gandi.net (Postfix) with ESMTPSA id 2CF48441C6;
	Fri,  1 Aug 2025 20:23:11 +0000 (UTC)
Message-ID: <5a4a8472d39727e048a98125e689f16b968f29b9.camel@hadess.net>
Subject: Re: [PATCH 3/5] test: Bump support TAP version
From: Bastien Nocera <hadess@hadess.net>
To: Denis Kenzior <denkenz@gmail.com>, ell@lists.linux.dev
Date: Fri, 01 Aug 2025 22:23:10 +0200
In-Reply-To: <264df186-6d7e-471f-b155-f5942e79cb78@gmail.com>
References: <20250731142153.2802258-1-hadess@hadess.net>
	 <20250731142153.2802258-4-hadess@hadess.net>
	 <264df186-6d7e-471f-b155-f5942e79cb78@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.56.2 (3.56.2-1.fc42) 
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
X-GND-State: clean
X-GND-Score: -100
X-GND-Cause: gggruggvucftvghtrhhoucdtuddrgeeffedrtdefgddutdegieegucetufdoteggodetrfdotffvucfrrhhofhhilhgvmecuifetpfffkfdpucggtfgfnhhsuhgsshgtrhhisggvnecuuegrihhlohhuthemuceftddunecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenucfjughrpefkuffhvfffjghftgfgfgggsehtqhertddtreejnecuhfhrohhmpeeurghsthhivghnucfpohgtvghrrgcuoehhrgguvghssheshhgruggvshhsrdhnvghtqeenucggtffrrghtthgvrhhnpefhjeefueffveejjefhjeeujeetheduuddujefhffefueefvdduudettdeijeejueenucffohhmrghinhepthgvshhtrghnhihthhhinhhgrdhorhhgnecukfhppedvrgdtudemvgefgeemvggtjeefmegtfhdvtdemjeduuggrmeefsggumedvtdgrleemudeffeenucevlhhushhtvghrufhiiigvpedtnecurfgrrhgrmhepihhnvghtpedvrgdtudemvgefgeemvggtjeefmegtfhdvtdemjeduuggrmeefsggumedvtdgrleemudeffedphhgvlhhopeglkffrvheimedvrgdtudemvgefgeemvggtjeefmegtfhdvtdemjeduuggrmeefsggumedvtdgrleemudeffegnpdhmrghilhhfrhhomhephhgruggvshhssehhrgguvghsshdrnhgvthdpnhgspghrtghpthhtohepvddprhgtphhtthhopeguvghnkhgvnhiisehgmhgrihhlrdgtohhmpdhrtghpthhtohepvghllheslhhishhtshdrlhhinhhugidruggvvh
X-GND-Sasl: hadess@hadess.net

On Fri, 2025-08-01 at 13:32 -0500, Denis Kenzior wrote:
> Hi Bastien,
>=20
> On 7/31/25 9:20 AM, Bastien Nocera wrote:
> > Version 13 is the last upstream supported version. See:
> > https://testanything.org/
> > ---
> > =C2=A0 ell/test.c | 2 +-
> > =C2=A0 1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> I went ahead and applied patches 1,2,4 and 5.=C2=A0 Thanks!
>=20
> For this commit, Marcel was wondering whether bumping to version 13
> was safe=20
> enough.=C2=A0 His concern was that some projects (like glib) were stickin=
g
> to '12'?

glib has been using TAP 13 since 2022[1], and I think that the only
reason it didn't use TAP 14 at the time was because meson didn't
support it.

meson supports TAP 13 or 14 now, so I did the smallest possible change
and bumped it to 13.

meson prints the sub-tests results when running tests:
$ meson test
ninja: Entering directory `/home/hadess/.cache/jhbuild/build/ell'
ninja: no work to do.
 1/52 /home/hadess/.cache/jhbuild/build/ell/unit/cert-server.pem-verify    =
         OK              0.03s
 2/52 /home/hadess/.cache/jhbuild/build/ell/unit/ec-cert-server.pem-verify =
         OK              0.03s
 3/52 /home/hadess/.cache/jhbuild/build/ell/unit/cert-client.pem-verify    =
         OK              0.03s
 4/52 /home/hadess/.cache/jhbuild/build/ell/unit/cert-intca.pem-verify     =
         OK              0.03s
 5/52 /home/hadess/.cache/jhbuild/build/ell/unit/cert-entity-int.pem-verify=
         OK              0.03s
 6/52 /home/hadess/.cache/jhbuild/build/ell/unit/cert-no-keyid.pem-verify  =
         OK              0.03s
 7/52 test-queue                                                           =
         OK              0.02s   2 subtests passed
 8/52 test-endian                                                          =
         OK              0.02s   6 subtests passed
 9/52 test-string                                                          =
         OK              0.02s   13 subtests passed
10/52 test-io                                                              =
         OK              0.03s   1 subtests passed
11/52 test-unit                                                            =
         OK              0.05s   9 subtests passed
12/52 test-hashmap                                                         =
         OK              0.05s   5 subtests passed
13/52 test-utf8                                                            =
         OK              0.05s   91 subtests passed
14/52 test-ringbuf                                                         =
         OK              0.05s   5 subtests passed
15/52 test-checksum                                                        =
         OK              0.04s   88 subtests passed
16/52 test-settings                                                        =
         OK              0.04s   9 subtests passed
17/52 test-genl-msg                                                        =
         OK              0.04s   9 subtests passed
18/52 test-siphash                                                         =
         OK              0.03s   1 subtests passed
19/52 test-cipher                                                          =
         OK              0.03s   46 subtests passed
20/52 test-random                                                          =
         OK              0.03s   1 subtests passed
21/52 test-util                                                            =
         OK              0.03s   24 subtests passed
22/52 test-uintset                                                         =
         OK              0.03s   12 subtests passed
23/52 test-netlink                                                         =
         OK              0.06s   1 subtests passed
24/52 test-rtnl                                                            =
         OK              0.06s   6 subtests passed
25/52 test-base64                                                          =
         OK              0.04s   26 subtests passed
26/52 test-uuid                                                            =
         OK              0.05s   9 subtests passed
27/52 test-dhcp                                                            =
         OK              0.04s   17 subtests passed
28/52 test-dhcp6                                                           =
         OK              0.04s   4 subtests passed
29/52 test-dir-watch                                                       =
         OK              0.04s   4 subtests passed
30/52 test-pbkdf2                                                          =
         OK              0.05s   11 subtests passed
31/52 test-ecc                                                             =
         OK              0.04s   25 subtests passed
32/52 test-time                                                            =
         OK              0.04s   2 subtests passed
33/52 test-path                                                            =
         OK              0.04s   2 subtests passed
34/52 test-net                                                             =
         OK              0.04s   4 subtests passed
35/52 test-sysctl                                                          =
         OK              0.04s   1 subtests passed
36/52 test-notifylist                                                      =
         OK              0.04s   5 subtests passed
37/52 test-dbus                                                            =
         OK              0.04s   1 subtests passed
38/52 test-dbus-util                                                       =
         OK              0.04s   34 subtests passed
39/52 test-hwdb                                                            =
         OK              0.05s   1 subtests passed
40/52 test-ecdh                                                            =
         OK              0.06s   10 subtests passed
41/52 test-dbus-message-fds                                                =
         OK              0.04s   1 subtests passed
42/52 test-dbus-watch                                                      =
         OK              0.03s   2 subtests passed
43/52 test-gvariant-message                                                =
         OK              0.02s   7 subtests passed
44/52 test-dbus-message                                                    =
         OK              0.04s   70 subtests passed
45/52 test-gvariant-util                                                   =
         OK              0.03s   145 subtests passed
46/52 test-dbus-properties                                                 =
         OK              0.05s   8 subtests passed
47/52 test-key                                                             =
         OK              0.04s   8 subtests passed
48/52 test-minheap                                                         =
         OK              0.13s   5 subtests passed
49/52 test-tls                                                             =
         OK              0.15s   9 subtests passed
50/52 test-pem                                                             =
         OK              0.19s   30 subtests passed
51/52 test-dbus-service                                                    =
         OK              0.48s   11 subtests passed
52/52 test-main                                                            =
         OK              3.00s   1 subtests passed

Ok:                 52 =20
Expected Fail:      0  =20
Fail:               0  =20
Unexpected Pass:    0  =20
Skipped:            0  =20
Timeout:            0  =20

Full log written to /home/hadess/.cache/jhbuild/build/ell/meson-logs/testlo=
g.txt


[1]: commit f893df4b7d52cce6c2abcd485a8cfc15320835b7
