Received: from mslow3.mail.gandi.net (mslow3.mail.gandi.net [217.70.178.249])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B45303F077C
	for <ell@lists.linux.dev>; Wed, 18 Mar 2026 16:25:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.70.178.249
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1773851127; cv=none; b=bD/lVZ2eG4s1CgrnOGdh4LHtNB0JPGex4YKuNSbc2AbWGULOSbE4r2EWVNrzwjXl3zdCPWYgGJpN7k2UF/Hk1mz/A4MAD0lN3eQDNmeiuYFpm0SHDwUFYYbpPN3A32hktHA575X66f8VwDTu81n4mkzrL0XLy/xySmhijZQOtOY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1773851127; c=relaxed/simple;
	bh=IrOuRMvwgTRazTyzUYuqtJIPL66dHSGmMgw3AUzGurE=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=iTTXhPMyh/61poL4PW8cU0rmcmEdUVN4jpJ9kl6TUV6bc39QovNI3LgLXMXeeS2UvCpwyqGGTH0tfLD9uaOb9ung5k2K96+KWruel5oeslYH7Ek8BQTnLUQjTbumSieEKKMZhxdCGr34E5ZeVgRRqpc9oLPv9MLepH1lerqef+o=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net; spf=pass smtp.mailfrom=hadess.net; arc=none smtp.client-ip=217.70.178.249
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hadess.net
Received: from relay6-d.mail.gandi.net (relay6-d.mail.gandi.net [217.70.183.198])
	by mslow3.mail.gandi.net (Postfix) with ESMTP id 914D5582E1B
	for <ell@lists.linux.dev>; Wed, 18 Mar 2026 16:17:15 +0000 (UTC)
Received: by mail.gandi.net (Postfix) with ESMTPSA id E2AA83E954;
	Wed, 18 Mar 2026 16:17:07 +0000 (UTC)
Message-ID: <dced3b494ec9ef9c7ed3884bb08cd0243d4cf432.camel@hadess.net>
Subject: Re: [PATCH 1/4] unit: Fix incorrect basename usage
From: Bastien Nocera <hadess@hadess.net>
To: Phil Hodges <philip.hodges@bluewin.ch>
Cc: ell@lists.linux.dev
Date: Wed, 18 Mar 2026 17:17:07 +0100
In-Reply-To: <D98F0DC1-9621-4E61-887A-CCA145F16AFF@bluewin.ch>
References: <20260317143018.628844-1-hadess@hadess.net>
	 <20260317143018.628844-2-hadess@hadess.net>
	 <D98F0DC1-9621-4E61-887A-CCA145F16AFF@bluewin.ch>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.58.3 (3.58.3-1.fc43) 
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
X-GND-Sasl: hadess@hadess.net
X-GND-State: clean
X-GND-Score: -100
X-GND-Cause: gggruggvucftvghtrhhoucdtuddrgeefgedrtddtgdeftdegheelucetufdoteggodetrfdotffvucfrrhhofhhilhgvmecuifetpfffkfdpucggtfgfnhhsuhgsshgtrhhisggvnecuuegrihhlohhuthemuceftddunecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenucfjughrpefkuffhvfevffgjfhgtgfgfggesthhqredttderjeenucfhrhhomhepuegrshhtihgvnhcupfhotggvrhgruceohhgruggvshhssehhrgguvghsshdrnhgvtheqnecuggftrfgrthhtvghrnhepieffgfehtedtgefgjeeggfffgeeuvdegveekveejfeekkedujeehteffueefffeunecukfhppedvrgdtudemvgefgeemvggtjeefmegtfhdvtdemsggrgeefmegrieejieemtgdvugefmeejrgehfeenucevlhhushhtvghrufhiiigvpedtnecurfgrrhgrmhepihhnvghtpedvrgdtudemvgefgeemvggtjeefmegtfhdvtdemsggrgeefmegrieejieemtgdvugefmeejrgehfedphhgvlhhopeglkffrvheimedvrgdtudemvgefgeemvggtjeefmegtfhdvtdemsggrgeefmegrieejieemtgdvugefmeejrgehfegnpdhmrghilhhfrhhomhephhgruggvshhssehhrgguvghsshdrnhgvthdpqhhiugepgfdvteetkeefgfelheegpdhmohguvgepshhmthhpohhuthdpnhgspghrtghpthhtohepvddprhgtphhtthhopehphhhilhhiphdrhhhoughgvghssegslhhuvgifihhnrdgthhdprhgtphhtthhopegvlhhlsehlihhsthhsrdhli
 hhnuhigrdguvghv

On Wed, 2026-03-18 at 02:14 +0100, Phil Hodges wrote:
> found cant_find meaning can't find expected cannot_find
>=20
> An English teacher taught me to expand the apostrophe in written
> English,
> long before we ever wanted to use apostrophe in an identifier.
>=20
> "cant" looks ignorant and wrong.

I'm having a hard time figuring out how this is relevant as I'm not
touching any lines of code that mention "cant_find", that you didn't
put the mailing-list in copy where folks that might have written this
code might read it, and that your idea of what is a proper identifier
is probably antiquated.

"ignorant and wrong" alright.

>=20
>=20
> On 17 Mar 2026, at 15:28, Bastien Nocera <hadess@hadess.net> wrote:
>=20
> The code called basename(), which requires either relying on the GNU
> libc, or including libgen.h to get access to the POSIX
> implementation.
>=20
> As neither was done, and the output of basename() was not freed, it's
> likely that the intent was to use the library-exported l_basename()
> instead which does not output an allocated string.
>=20
> ninja: job failed: clang -Isubprojects/ell-0.83/unit/test-path.p -
> Isubprojects/ell-0.83/unit -I../subprojects/ell-0.83/unit -
> Isubprojects/ell-0.83 -I../subprojects/ell-0.83 -fdiagnostics-
> color=3Dalways -D_FILE_OFFSET_BITS=3D64 -Wall -Winvalid-pch -O0 -g -
> DHAVE_CONFIG_H '-
> DUNITDIR=3D"/home/runner/work/wrapdb/wrapdb/subprojects/ell-
> 0.83/unit/"' '-
> DCERTDIR=3D"/home/runner/work/wrapdb/wrapdb/_build/subprojects/ell-
> 0.83/unit/"' -MD -MQ subprojects/ell-0.83/unit/test-path.p/test-
> path.c.o -MF subprojects/ell-0.83/unit/test-path.p/test-path.c.o.d -o
> subprojects/ell-0.83/unit/test-path.p/test-path.c.o -c
> ../subprojects/ell-0.83/unit/test-path.c
> ../subprojects/ell-0.83/unit/test-path.c:65:9: error: call to
> undeclared function 'basename'; ISO C99 and later do not support
> implicit function declarations [-Wimplicit-function-declaration]
> =C2=A0 65 |=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 base =3D base=
name(tmp_path);
> =C2=A0=C2=A0=C2=A0=C2=A0 |=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 ^
> ../subprojects/ell-0.83/unit/test-path.c:65:9: note: did you mean
> 'l_basename'?
> ../subprojects/ell-0.83/ell/path.h:20:13: note: 'l_basename' declared
> here
> =C2=A0 20 | const char *l_basename(const char *path);
> =C2=A0=C2=A0=C2=A0=C2=A0 |=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0 ^
> ../subprojects/ell-0.83/unit/test-path.c:65:7: error: incompatible
> integer to pointer conversion assigning to 'char *' from 'int' [-
> Wint-conversion]
> =C2=A0 65 |=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 base =3D base=
name(tmp_path);
> =C2=A0=C2=A0=C2=A0=C2=A0 |=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 ^ ~~~~~~~~~~~~~~~~~~
> ---
> unit/test-path.c | 4 ++--
> 1 file changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/unit/test-path.c b/unit/test-path.c
> index 1f744234c395..f01fa526aaa1 100644
> --- a/unit/test-path.c
> +++ b/unit/test-path.c
> @@ -55,14 +55,14 @@ static void test_path_find(const void *data)
> 	static const char *cant_find =3D "/foo:/bar:/dir:fr";
> 	static const char *can_find =3D "/tmp";
> 	char *tmp_path =3D l_strdup("/tmp/foobarXXXXXX.tmp");
> -	char *base;
> +	const char *base;
> 	char *path;
> 	int fd;
>=20
> 	fd =3D L_TFR(mkostemps(tmp_path, 4, O_CLOEXEC));
> 	assert(fd > 0);
> 	L_TFR(close(fd));
> -	base =3D basename(tmp_path);
> +	base =3D l_basename(tmp_path);
>=20
> 	assert(l_path_find(base, cant_find, F_OK) =3D=3D NULL);
