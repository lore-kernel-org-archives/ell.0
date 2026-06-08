Received: from relay5-d.mail.gandi.net (relay5-d.mail.gandi.net [217.70.183.197])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C494234CFB9
	for <ell@lists.linux.dev>; Mon,  8 Jun 2026 07:39:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.70.183.197
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780904345; cv=none; b=gbv3GW1BbMQscc/rZPfo6h1abYtM0fCRR9B/JsGPcEQh3FsaR/Zdsvgilvlp9OfyDzHlbuuASzG6Z3aliNCjfc0tGaNrGXQua+GmRJwxPKMnGr1J1fjpV7l+Na4x2ak0PKwIAKokE0gujgVjvJkwSGz1Xu4NPuuzu7iZIx/rTao=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780904345; c=relaxed/simple;
	bh=rUa2arXMcby8yNZi961qk+IZCd30tVhDkcw2EZ4bntU=;
	h=Message-ID:Subject:From:To:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=N6O0O8mlkQURXMnPC5xsnbvdFU3Uc2oYnummi+4WtfTAaVNa1wxM4s+O6HJDSaAhNGbawXx+cjSxNMul6PyvCSg38vjwldjYdOPe9imKu1rVJ9sdsNOwUOlXm5LH0uIXfuBbe7lzHaKlWvCMQZDb1HQiKoRreMIe8r7C/SsJrx0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net; spf=pass smtp.mailfrom=hadess.net; arc=none smtp.client-ip=217.70.183.197
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hadess.net
Received: by mail.gandi.net (Postfix) with ESMTPSA id 73E1D3ECCA
	for <ell@lists.linux.dev>; Mon,  8 Jun 2026 07:38:55 +0000 (UTC)
Message-ID: <d00a329fc475b6ae38c12e9100f6ec9a0c4e3ddb.camel@hadess.net>
Subject: Re: [PATCH 0/4] More build fixes
From: Bastien Nocera <hadess@hadess.net>
To: ell@lists.linux.dev
Date: Mon, 08 Jun 2026 09:38:55 +0200
In-Reply-To: <6b956cb2174d01b66a57dd394c22dac0308cd4cc.camel@hadess.net>
References: <20260317143018.628844-1-hadess@hadess.net>
	 <6b956cb2174d01b66a57dd394c22dac0308cd4cc.camel@hadess.net>
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
X-GND-Score: 0
X-GND-Cause: dmFkZTGYCTAzrjuaADbDYCBTbZ9M/lbGnPvNCAtIXRhH5TRNGXPrLMBelb+BMSVEaJfSkvIrxEcvUOQKYUyEsnlEtAwohoojgfFojxjTrnz2taBkI0q4aKplUfUf61onLxUeELEK32qFGD1ERGv/Jrm66zvCpvj4sLFYXWCR8UOBRW0sqossn0oY2DHQaBv4N9PUmVToT8Hc9FgGob+5SAPmwlRSldKJU/Wi23HW40BfMzuHRwgjlyIJhQAPyEa61pDYzVoEO9I8jhwONZEJNTazA8NrgsgPI4MNHUwVpUA72VQ+eOZjaXP/880R4pn4RfBu1eFu5OoJiyB8G2cRZSXtj7gRRIyj2xMTdifLIoNtKYDcOIbyG1VBC6qo3GrehVGTIV/s8wtOG+Tj5rhJqnQjjtK8onIRxEurzZxLzu/XNlRQwnA35eD/wOjeOlaSlOOcayDuZ5Xo3twY9SZ/OaBTa6G/tEDO12qusyNcpqeJk0PBrOxCQR8lgbOp8eaHel9jOjbkoIcUR8hzwVCpT4u50JHp2JlwzCzfU0JibKyLIB8HKe0E0F6orL5R/S9rFdG9oPwxkj4cJkUHP3Q9jdul7wLWZqCJKPncDELxJErvVxXk1zE+TcDZchEDT7QfMcma475ixVLK06mfn/PIPR9bpcXKeGRq+0xQ+iHgQLnheaHQSg

Hello again,

Would it be possible to get those merged?

Regards

On Thu, 2026-04-16 at 11:18 +0200, Bastien Nocera wrote:
> Hey,
>=20
> Would it be possible to get a review on those?
>=20
> Cheers
>=20
> On Tue, 2026-03-17 at 15:28 +0100, Bastien Nocera wrote:
> > Another batch of fixes for compiling on Alpine Linux and/or clang:
> > https://github.com/mesonbuild/wrapdb/pull/2646
> >=20
> > Bastien Nocera (4):
> > =C2=A0 unit: Fix incorrect basename usage
> > =C2=A0 ell: Fix rawmemchr implementation warning in Alpine/clang
> > =C2=A0 ell: Fix cert_pkcs12_pbkdf() warning under Alpine/clang
> > =C2=A0 unit: Skip hwdb test when hwdb isn't available
> >=20
> > =C2=A0ell/cert-crypto.c |=C2=A0 4 ++++
> > =C2=A0ell/missing.h=C2=A0=C2=A0=C2=A0=C2=A0 |=C2=A0 4 ++++
> > =C2=A0unit/test-hwdb.c=C2=A0 | 13 ++++++++++---
> > =C2=A0unit/test-path.c=C2=A0 |=C2=A0 4 ++--
> > =C2=A04 files changed, 20 insertions(+), 5 deletions(-)
