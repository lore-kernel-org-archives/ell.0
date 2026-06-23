Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A07CC329C6D;
	Tue, 23 Jun 2026 16:55:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782233754; cv=none; b=NhRm+84ReePTfeUwcvA4ctz6MypsHYS0fmjEVY2pDTBx11vnVt+HruGdp9ASGrV0L4XpFputU3FV4xl/hyD5+273W5Nq9sjXzT9OcFm1r0R6wNXLjfh0nD9rirmTKKsAIw/SR4iC4D2WCBJPQGOarXF1N+5qicd+C/w1G340sYM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782233754; c=relaxed/simple;
	bh=sAu/8s86kMThH4NQPMbDWLqwFNOPAHVJwRfPa1cuc7I=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=pln6tDQXYinVZWtEDqxE82MicARqbGt4KTYFSrk55oBPQekm0NgY7hpxgV9dsxtrSl3SaYZt8zsBpY5deBAww7IHUb9KLLUxRVQzuHEGywv2RjkrXXXxvyrqC+oQh7hs3vWm2PUaO+Ejp8ccoJCjE7uJMh8u8Bfwm7zG8yCR+ew=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ChHudWG2; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ChHudWG2"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C4FC11F000E9;
	Tue, 23 Jun 2026 16:55:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1782233752;
	bh=57cidAKqM7bjU5fmDA+0e2ApWPh3VeirF0Lu7h10CT8=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=ChHudWG2Fb4f0YFzSbd4uV9Ki/lyTWTYcPEjr2YXHDfs5MYr8I1OKIxZTmW2YKjv8
	 RE3EO4I+AsDbUICItsbI7Nmg95M6H8HiaKOQRjBeqf+Hp8SgKA4Y51NZjAN4yZjVXC
	 y6gDxqGP/dTtwlWyEkWEq2LVxf2hmnQv24g3ucTcZTt8DwKC7o5oMLyQHXbygAy0U7
	 EBixztm7ZX9QSgXshHkMe9k0hr9vmWIiwmTT6iW8YrZfvezU+TDU6i0zYe6Lxo0thq
	 5fk6DGjAaDYqbTfjHoVZqiyhQT2TR+/c0X23vF45P984ZeME1xZO/pzXcK0P7a2SEY
	 b94+MaSN0RMfg==
Date: Tue, 23 Jun 2026 09:54:16 -0700
From: Eric Biggers <ebiggers@kernel.org>
To: Bastien Nocera <hadess@hadess.net>
Cc: linux-crypto@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>,
	linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org,
	linux-bluetooth@vger.kernel.org, iwd@lists.linux.dev,
	linux-hardening@vger.kernel.org, Milan Broz <gmazyland@gmail.com>,
	Demi Marie Obenour <demiobenour@gmail.com>,
	Andy Lutomirski <luto@amacapital.net>, ell@lists.linux.dev
Subject: Re: [PATCH] crypto: af_alg - Add af_alg_restrict sysctl, defaulting
 to 1
Message-ID: <20260623165416.GC1793@sol>
References: <20260622234803.6982-1-ebiggers@kernel.org>
 <fa46b3c8f70ee586439db68143cae4bcd40e537b.camel@hadess.net>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <fa46b3c8f70ee586439db68143cae4bcd40e537b.camel@hadess.net>

On Tue, Jun 23, 2026 at 10:42:34AM +0200, Bastien Nocera wrote:
> Hello Eric,
> 
> On Mon, 2026-06-22 at 16:48 -0700, Eric Biggers wrote:
> > AF_ALG is a frequent source of vulnerabilities and a maintenance
> > nightmare.  It exposes far more functionality to userspace than ever
> > should have been exposed, especially to unprivileged processes. 
> > Recent
> > exploits have targeted kernel internal implementation details like
> > "authencesn" that have zero use case for userspace access.
> 
> You should also CC: ell@lists.linux.dev for AF_ALG related changes, as
> ell uses AF_ALG extensively for crypto and checksumming.
> 
> Cheers

The known users of libell (iwd and bluez) are already taken into
account.

- Eric
