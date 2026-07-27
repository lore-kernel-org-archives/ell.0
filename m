Received: from mslow3.mail.gandi.net (mslow3.mail.gandi.net [217.70.178.249])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D4F762E7390
	for <ell@lists.linux.dev>; Mon, 27 Jul 2026 08:54:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.70.178.249
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785142443; cv=none; b=cyeiM1/gtjW3nQM2Ff9ozLFG3+DV2bdmVgQqS76TyPYAUhpbM3aZsDtgkHJ5Qgi11Ds0pCdoFuHAOahkgZN50xJX+cJT5bajmY+jXcYJ8EIGcnhR6BM3QD25F9Fzc9F2ATT2aSwVUjCe2IQl/Rncsac+o+qR2aY13+l5R3cmZcY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785142443; c=relaxed/simple;
	bh=xNh0Aw1luUSAS9rFAuuzl0ksA1nFKZUOazx9xlX7v48=;
	h=Message-ID:Subject:From:To:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=em01gksB1SdutkrCQnNTODf0tKzTReKqtWQ1WEml6mLIpeUY7UWyDwhSwkjg9tt+M8GHAr3hN/fYhHE5UAzMv4Fak4Tfej7PSJz70r2Qdf8I/eb0WMnfsr2MpfXXOqDagKSTDDf1JImJ1lf48q+mWIAsU2Og8y8aDpNJDinId7k=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net; spf=pass smtp.mailfrom=hadess.net; arc=none smtp.client-ip=217.70.178.249
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hadess.net
Received: from relay5-d.mail.gandi.net (relay5-d.mail.gandi.net [IPv6:2001:4b98:dc4:8::225])
	by mslow3.mail.gandi.net (Postfix) with ESMTP id E679E58119C
	for <ell@lists.linux.dev>; Mon, 27 Jul 2026 08:41:19 +0000 (UTC)
Received: by mail.gandi.net (Postfix) with ESMTPSA id 067BC3EBBB
	for <ell@lists.linux.dev>; Mon, 27 Jul 2026 08:41:11 +0000 (UTC)
Message-ID: <0c65ebd79327e4eeb98e2e48cbeb185480a39787.camel@hadess.net>
Subject: Re: [PATCH 0/4] More build fixes
From: Bastien Nocera <hadess@hadess.net>
To: ell@lists.linux.dev
Date: Mon, 27 Jul 2026 10:41:11 +0200
In-Reply-To: <d00a329fc475b6ae38c12e9100f6ec9a0c4e3ddb.camel@hadess.net>
References: <20260317143018.628844-1-hadess@hadess.net>
		 <6b956cb2174d01b66a57dd394c22dac0308cd4cc.camel@hadess.net>
	 <d00a329fc475b6ae38c12e9100f6ec9a0c4e3ddb.camel@hadess.net>
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
X-GND-Score: 0
X-GND-Cause: dmFkZTEkDgkSA1M4P9F+n+kzG2l43PUSj8CpT3JrHz6c1+GJhQrZTTEqf94VF8RN4PrU0PWEJvx2qRa4cjjzP3BDtm+HkeDyHHvo0bE6NvI+cLPLeDoPZJKq0sVRVPZLNpxKnou5h5g+uPBZgaiAZrngN4MkKg8CBxma/ps5bj67JVJkETLhXvZsRp88VNkPR+4MXl9NBHqH9VpIQEO91/fRg1kekYDatnyzJDBuUyBC8KlZOLGE3UqreBH4TEsrJOJNx0mnlCbl2B/ByG6MFtf7x9EscX4ycmTRGRqsNeO568uFC7b/JXWt5zvKXFSuvENmsifJV765HdIFgXzEu7C9J81EOgweGd4g2/9eMaqmLjVNIMeu/ZPnQ7vLunkLDsTzEgTcyu2GvC2Gqrlob4Pxo7j0vgp1UVWSPzA/+x7B1CjJHtThgugi5t+dyd09ImWDydLJs7+5/T18E6YM/GgMTbDP9jM8GApCcYOg4l1EfvMUWUYyZ3h+JUf0FgH+XldSwijd2jm+yHn515/IiJiZX0ERmHPHz1hnOO61QagwovOidDtpwCn+edPaAdKGL1WgLO7C5u3l0QF45qgt11Mx3EX1Gv1lEYLnKi8bk0eRqt3eXWno/FBcQzgHAk0RKmrAbLrjA0PF/AHdFwK9uInd7BHRt/Zu8UaTpweUST+U5nbLXA
X-GND-State: clean

Hello again,

Those patches were sent back in March, and I've pinged about getting
them reviewed back in April and June, to no avail.

Could you please let me know what's missing to get those build patches
reviewed and merged?

Regards

On Mon, 2026-06-08 at 09:38 +0200, Bastien Nocera wrote:
> Hello again,
>=20
> Would it be possible to get those merged?
>=20
> Regards
>=20
> On Thu, 2026-04-16 at 11:18 +0200, Bastien Nocera wrote:
> > Hey,
> >=20
> > Would it be possible to get a review on those?
> >=20
> > Cheers
> >=20
> > On Tue, 2026-03-17 at 15:28 +0100, Bastien Nocera wrote:
> > > Another batch of fixes for compiling on Alpine Linux and/or
> > > clang:
> > > https://github.com/mesonbuild/wrapdb/pull/2646
> > >=20
> > > Bastien Nocera (4):
> > > =C2=A0 unit: Fix incorrect basename usage
> > > =C2=A0 ell: Fix rawmemchr implementation warning in Alpine/clang
> > > =C2=A0 ell: Fix cert_pkcs12_pbkdf() warning under Alpine/clang
> > > =C2=A0 unit: Skip hwdb test when hwdb isn't available
> > >=20
> > > =C2=A0ell/cert-crypto.c |=C2=A0 4 ++++
> > > =C2=A0ell/missing.h=C2=A0=C2=A0=C2=A0=C2=A0 |=C2=A0 4 ++++
> > > =C2=A0unit/test-hwdb.c=C2=A0 | 13 ++++++++++---
> > > =C2=A0unit/test-path.c=C2=A0 |=C2=A0 4 ++--
> > > =C2=A04 files changed, 20 insertions(+), 5 deletions(-)
