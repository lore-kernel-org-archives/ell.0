Received: from relay5-d.mail.gandi.net (relay5-d.mail.gandi.net [217.70.183.197])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 507582FE596
	for <ell@lists.linux.dev>; Thu, 11 Sep 2025 11:34:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.70.183.197
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1757590496; cv=none; b=u/VColToIv7Nne1dvjss3Mp/sGKy3VPTyUN0MuoqguCV5xM3i8djsjA5Lsg5yNN4D6cb9aIS9FWaZUPwF95zPR/pHvE7YCSx5TXTcc9CXriixG8ecMS391j8psHpe3CY2ZIvUKlzm9pYzn0KvaAoMGUWtvayvNYmrVijy7v3FEg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1757590496; c=relaxed/simple;
	bh=Ttbyh7I9jYhLU8dUp+L+7WAj7NCWQDjVChAwvYWgwK8=;
	h=Message-ID:Subject:From:To:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=JTVQchu5j2YsslDL8tIRNgEIQzmL5nS3tCJXRaH/Jxd9YAWLLO8EHmnAotRoSkvnwBPwMnsF0ZlEq6vaLEsKXdQbkc4GageR6hiqTbRa6rlN6xqZfW4TBXcXfWKwyAjdktwWfcKwJmVwiVFHneDCPCjiFSf0R1yOMgyPKO5w7Lg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net; spf=pass smtp.mailfrom=hadess.net; arc=none smtp.client-ip=217.70.183.197
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hadess.net
Received: by mail.gandi.net (Postfix) with ESMTPSA id 000F143305;
	Thu, 11 Sep 2025 11:34:50 +0000 (UTC)
Message-ID: <cdf72df75a9d37b2e997f66dd2f28653f00b7073.camel@hadess.net>
Subject: Re: [PATCH v5 1/1] build: Add meson build system
From: Bastien Nocera <hadess@hadess.net>
To: Denis Kenzior <denkenz@gmail.com>, ell@lists.linux.dev
Date: Thu, 11 Sep 2025 13:34:50 +0200
In-Reply-To: <a137bd2597373a562a27d93e665705c3e0223ea4.camel@hadess.net>
References: <20250807134859.930870-1-hadess@hadess.net>
		 <20250807134859.930870-2-hadess@hadess.net>
		 <5939828972792a22be2680c6b2bf377f1cd0d437.camel@hadess.net>
		 <bd05acb2cb6bb96ff13d1c82b0fb2d28c199a843.camel@hadess.net>
		 <8cf523c2-fa78-4f1c-9e3f-48a529d1e280@gmail.com>
	 <a137bd2597373a562a27d93e665705c3e0223ea4.camel@hadess.net>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.56.2 (3.56.2-2.fc42) 
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
X-GND-State: clean
X-GND-Score: -100
X-GND-Cause: gggruggvucftvghtrhhoucdtuddrgeeffedrtdeggddviedtiecutefuodetggdotefrodftvfcurfhrohhfihhlvgemucfitefpfffkpdcuggftfghnshhusghstghrihgsvgenuceurghilhhouhhtmecufedtudenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujfgurhepkffuhffvffgjfhgtgfgfggesthhqredttderjeenucfhrhhomhepuegrshhtihgvnhcupfhotggvrhgruceohhgruggvshhssehhrgguvghsshdrnhgvtheqnecuggftrfgrthhtvghrnhepueeviedvteekkefgfefffeethfejieekteffvdetjeehfeeileettddvueeludelnecukfhppedvrgdtudemvgefgeemvggtjeefmegtfhdvtdemjeduuggrmeefsggumedvtdgrleemudeffeenucevlhhushhtvghrufhiiigvpedtnecurfgrrhgrmhepihhnvghtpedvrgdtudemvgefgeemvggtjeefmegtfhdvtdemjeduuggrmeefsggumedvtdgrleemudeffedphhgvlhhopeglkffrvheimedvrgdtudemvgefgeemvggtjeefmegtfhdvtdemjeduuggrmeefsggumedvtdgrleemudeffegnpdhmrghilhhfrhhomhephhgruggvshhssehhrgguvghsshdrnhgvthdpnhgspghrtghpthhtohepvddprhgtphhtthhopeguvghnkhgvnhiisehgmhgrihhlrdgtohhmpdhrtghpthhtohepvghllheslhhishhtshdrlhhinhhugidruggvvh
X-GND-Sasl: hadess@hadess.net

Hey,

It's been a couple of weeks, so sorry to insist on this, but it's
blocking my work on bluez, as the maintainers there would rather depend
on an official ell repo rather than the fork I setup to test builds
using meson.

Cheers

On Wed, 2025-08-20 at 18:28 +0200, Bastien Nocera wrote:
> On Wed, 2025-08-20 at 11:17 -0500, Denis Kenzior wrote:
> > Hi Bastien,
> >=20
> > On 8/20/25 4:02 AM, Bastien Nocera wrote:
> > > Sorry to nag, I'd really appreciate if you could review and merge
> > > this,
> > > as it's blocking any further work on bluez.
> >=20
> > I personally have nothing against taking this in, but Marcel is the
> > one=20
> > maintaining the build system, so I'd need his ack first.
>=20
> I just wanted to clarify that this doesn't touch the original build
> system (autotools) at all, and that I'm happy doing follow-up bug
> fixes
> as necessary.
