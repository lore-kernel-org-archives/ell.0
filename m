Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F3D1531AABF;
	Tue, 23 Jun 2026 16:51:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782233469; cv=none; b=LDrkfvEXEDEpA17r3PBoCGNReI3+tMjfba22iwWcj5krOrjZrNkFf393VNgBHiVLoL9QwJ60vbqQUoNzqYqWacs2LOrehoyiUEihJ0EE6BPh9tBnRu67ieqlhu/Duj+U7NJ5j5erP/bE7glB3z1Y7cSZH+HC/clTBmU1KaFSgmo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782233469; c=relaxed/simple;
	bh=jEIfOz8L3Xvj/I99+aKSmhRVI9moHWAB23vzqWdnkhQ=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=kUpqXJ1uXCKFppCwk7jHyyoMb3v+omyF/n8RurnIjU9idb2BWNDbkGIFhaG9eTnySpWt26oAEsl10CsJ7ckgC3d65n2LaEK6fajgQH7KgGZO7Hz44HDskeiadE7HlBv9M3DRSZMvyGBDXC6e565jhtQD4aTDnnGf9Tf3z2NsFLU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=eb50iDUH; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="eb50iDUH"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3C7BC1F000E9;
	Tue, 23 Jun 2026 16:51:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1782233468;
	bh=br1dDqQSE3Y/rlJoCar3aldqoF93foDqyKQcutQqY9s=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=eb50iDUHq00+xrXaIrlUViHsFtPLU4oDzdWikR5Bkk78aU56/2xe07iQ91ISc//Zl
	 kHUAsfjK1Y3U2rb523vLCRbrdbCqBBWUmRgKGNG9oeupcVoz3FDSbF3wYHGF/R1EWB
	 6pIUmeYYYyq9hfLyFg1AdhSPhZ01XPbzwZakM+i+u07Q9vnjKGY0XCaa2pj6sZekwk
	 eAGVHPQ7OERb7En2c4Zm9SM6ogQnJf5x3v7Um48ZiSS2msWbq+AJ3Ls+0Ag6Hk1Tcq
	 U058ws8hmOS4bxcwd1AnPcJtcEvdc237m8bjr1S8vk7TEO5Pglj0D1Du8AX7Z7D9RL
	 KmSxq8pCB7o4g==
Date: Tue, 23 Jun 2026 09:49:32 -0700
From: Eric Biggers <ebiggers@kernel.org>
To: Bastien Nocera <hadess@hadess.net>
Cc: linux-crypto@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>,
	Marcel Holtmann <marcel@holtmann.org>,
	Luiz Augusto von Dentz <luiz.dentz@gmail.com>,
	linux-doc@vger.kernel.org, linux-api@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-bluetooth@vger.kernel.org, ell@lists.linux.dev
Subject: Re: [PATCH] crypto: af_alg - Document the deprecation of AF_ALG
Message-ID: <20260623164932.GA1793@sol>
References: <20260430011544.31823-1-ebiggers@kernel.org>
 <7d08a6df54279e9915f5df6bd4e5e5dde52b4fe1.camel@hadess.net>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <7d08a6df54279e9915f5df6bd4e5e5dde52b4fe1.camel@hadess.net>

On Tue, Jun 23, 2026 at 02:44:28PM +0200, Bastien Nocera wrote:
> Hey,
> 
> Replying to this older patch.
> 
> On Wed, 2026-04-29 at 18:15 -0700, Eric Biggers wrote:
> <snip>
> > This isn't intended to change anything overnight.  After all, most Linux
> > distros won't be able to disable the kconfig options quite yet, mainly
> > because of iwd.  But this should create a bit more impetus for these
> > userspace programs to be fixed, and the documentation update should also
> > help prevent more users from appearing.
> 
> There are 2 other users that I know of: bluez, and the ell library
> (used by iwd and bluez).
>
> From what I could tell, bluetoothd uses AF_ALG for cryptography:
> https://git.kernel.org/pub/scm/bluetooth/bluez.git/tree/src/shared/crypto.c
> https://git.kernel.org/pub/scm/bluetooth/bluez.git/tree/tools/mesh-gatt/crypto.c
> 
> It uses "ecb(aes)" and "cmac(aes)" as algorithms.
> 
> Finally, it also uses them both again:
> https://git.kernel.org/pub/scm/bluetooth/bluez.git/tree/mesh/crypto.c
> through ell:
> https://git.kernel.org/pub/scm/libs/ell/ell.git/tree/ell/cipher.c
> 
> Because that's a question that also came up, bluetoothd also uses the
> CAP_NET_ADMIN capability.
> 
> I'll let Luiz and Marcel take it over from here.
> 

We're aware of that and are taking it into account in the allowlist:
https://lore.kernel.org/linux-crypto/20260622234803.6982-1-ebiggers@kernel.org/
If you have any feedback on the allowlist, please respond to that patch.

- Eric
