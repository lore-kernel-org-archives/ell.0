Received: from mslow3.mail.gandi.net (mslow3.mail.gandi.net [217.70.178.249])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E57C03921CA
	for <ell@lists.linux.dev>; Thu, 16 Apr 2026 09:24:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.70.178.249
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1776331495; cv=none; b=A5Mr0uMT96vQeMg9m+ozdqlzHtwG4yMzlzPXaKUu9O9FEHrsWGOQr6uulSUqvbrNjqphMsNt4xkUkgz8SvfsC+4+gDkmCJMUbNiPFBX3rIwh7ihRjzXOI3HKtExUK7qKuUWVWM0XcfF/INPyOmMkC/cuLxajEgUdpcs1YlBKvhQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1776331495; c=relaxed/simple;
	bh=47S7WvVkum7QpEj7IkQiSq3Obugf+7FIbi8i9CU/g30=;
	h=Message-ID:Subject:From:To:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=ouDFr/Px9XRbttYqtPdDhAAuteAmtMobxW9izDT3jIXKbrrtuZnsj5JpnkvEWmadx1FOL/R4w0MhSEQi/fndCdHOB2wr6FeZk+UHswuMXW2uVaCuXcGMoF0ayixO528hB2PjrclVLCxGcwb1liW0qzOl54YPYUjQHaBi33Wko2s=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net; spf=pass smtp.mailfrom=hadess.net; arc=none smtp.client-ip=217.70.178.249
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hadess.net
Received: from relay4-d.mail.gandi.net (relay4-d.mail.gandi.net [217.70.183.196])
	by mslow3.mail.gandi.net (Postfix) with ESMTP id 51938582FC9
	for <ell@lists.linux.dev>; Thu, 16 Apr 2026 09:18:34 +0000 (UTC)
Received: by mail.gandi.net (Postfix) with ESMTPSA id C44773E9B4
	for <ell@lists.linux.dev>; Thu, 16 Apr 2026 09:18:26 +0000 (UTC)
Message-ID: <6b956cb2174d01b66a57dd394c22dac0308cd4cc.camel@hadess.net>
Subject: Re: [PATCH 0/4] More build fixes
From: Bastien Nocera <hadess@hadess.net>
To: ell@lists.linux.dev
Date: Thu, 16 Apr 2026 11:18:26 +0200
In-Reply-To: <20260317143018.628844-1-hadess@hadess.net>
References: <20260317143018.628844-1-hadess@hadess.net>
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
X-GND-Score: 0
X-GND-Cause: dmFkZTFhBqChJeFqkK/nK1CV/sSdKGeB4tTpngkgowTbKyQ54dk7uJsac6NFzfv8lTWFuDotJCDXfIBGH1ESFHdtxeP6LeYkZmNbmFTxc4B+htkzEBrpfVWs0Oj27elfXqcHc0e6fmTp4Zrekk21oLOMUwLqiZH52CGIHoVo+aJZRKBHwMR2THb5Rtosrd33LcXBwoEUklX6lP+jXfIQZz4L55Izud3+Qeqa6UYFVzFBxDyKD5LSluN3cbvTZV8GwVYMlONy5UBUN8gixocLA9hqBwCMvCTlEKaG+ig2Kj6iC5YoUFjHLEoMQ2sw7ldvMwqSZv9usP/tZFKnDFwP0hZFzBZnEl7uSSypjMdXchzmw4O0xROLTLyaI/D3nGL2+UWLLBRA53zNlXXQtqVzYf8R8yc06wAh573Uh1LIV2cv2Ip6/zz1xb7K5l/6wtjo3UfIRbbS1z71asnI3UC8Bm3RDp66DfcyPuk6shDWdSTg0G/z0byPh3jhxfhqDI7/PiAu008/COP5879Zdg6JbDhDuQiH6EkPxPef88OTsz08b7mGStaUUdbFAXfJany5KlTD4zKqdpfZ6SLoKJuscYHpHNBMBGXfksl+lEVBnhhWV0BMg0s8oluvdBEXn8M7KpQURYPbTXln050/l7z6bREYjvhXsXu9B3taFkq3lsYfbPKLyQ

Hey,

Would it be possible to get a review on those?

Cheers

On Tue, 2026-03-17 at 15:28 +0100, Bastien Nocera wrote:
> Another batch of fixes for compiling on Alpine Linux and/or clang:
> https://github.com/mesonbuild/wrapdb/pull/2646
>=20
> Bastien Nocera (4):
> =C2=A0 unit: Fix incorrect basename usage
> =C2=A0 ell: Fix rawmemchr implementation warning in Alpine/clang
> =C2=A0 ell: Fix cert_pkcs12_pbkdf() warning under Alpine/clang
> =C2=A0 unit: Skip hwdb test when hwdb isn't available
>=20
> =C2=A0ell/cert-crypto.c |=C2=A0 4 ++++
> =C2=A0ell/missing.h=C2=A0=C2=A0=C2=A0=C2=A0 |=C2=A0 4 ++++
> =C2=A0unit/test-hwdb.c=C2=A0 | 13 ++++++++++---
> =C2=A0unit/test-path.c=C2=A0 |=C2=A0 4 ++--
> =C2=A04 files changed, 20 insertions(+), 5 deletions(-)
