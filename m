Received: from mail.holtmann.org (coyote.holtmann.net [212.227.132.17])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id DE2012566
	for <ell@lists.linux.dev>; Tue, 27 May 2025 17:30:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=212.227.132.17
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1748367031; cv=none; b=GT0WQfmLsAcoQc624I1C38tXDCv5ZBqbkarbB5gaBs0e5ZCVqUJ6yfF6CNBmytdzHRUzNHyd+W3qXFPfeiYCkZDgrSfJAo9/UyJPcud5SL0nC4YIPB5J6AuKY/zZERH3u34883zso5CiGoofedlnFHtp+e6WdRTOsO0R578JtzY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1748367031; c=relaxed/simple;
	bh=ZnVlyq+b/U+o2mokluF/Bb8HtVTuuXXXUWEz36JW0cQ=;
	h=Content-Type:Mime-Version:Subject:From:In-Reply-To:Date:Cc:
	 Message-Id:References:To; b=hDp3V+224S6vl5AecjmKPzb5TvZATngZt2bbH2UCDCb2r2DoL262tmCRjQbtdZo4yq7kLHobPvlTxrxF31oCREZ+DYZ29SmSunt3CukOpnsZlS5myfAGb7YHCYMMxene5YyhZwmyAaPIopwGl2Xg7Vm+gR+Koyup4slkkarlujE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=holtmann.org; spf=pass smtp.mailfrom=holtmann.org; arc=none smtp.client-ip=212.227.132.17
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=holtmann.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=holtmann.org
Received: from smtpclient.apple (p4ff9f112.dip0.t-ipconnect.de [79.249.241.18])
	by mail.holtmann.org (Postfix) with ESMTPSA id 0F5B2CECC6;
	Tue, 27 May 2025 19:20:58 +0200 (CEST)
Content-Type: text/plain;
	charset=utf-8
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
Mime-Version: 1.0 (Mac OS X Mail 16.0 \(3826.600.51.1.1\))
Subject: Re: [PATCH v9 0/9] Input/Output Terminal Abstraction
From: Marcel Holtmann <marcel@holtmann.org>
In-Reply-To: <cover.1743976923.git.gerickson@nuovations.com>
Date: Tue, 27 May 2025 19:20:47 +0200
Cc: ell@lists.linux.dev
Content-Transfer-Encoding: quoted-printable
Message-Id: <9E228E49-412C-478B-AD92-F8FA2210BFDD@holtmann.org>
References: <cover.1743976923.git.gerickson@nuovations.com>
To: Grant Erickson <gerickson@nuovations.com>
X-Mailer: Apple Mail (2.3826.600.51.1.1)

Hi Grant,

> This expands on Marcel Holtman's 2023-12-22 RFCv4 patch for an
> input/output terminal abstraction.
>=20
> Substantive changes from the v7 version:
>=20
>  * Fixed a typo in the  ASCII C0 and C1 control code mnemonics.
>=20
> Grant Erickson (9):
>  term: Initial revision.

I actually reverted it back to my version and included printf / vprintf =
helpers.

What is the purpose of l_term_set_bounds? Is it important for non-TTY =
setups since for TTY compatible terminals, this should not be needed.

The  l_term_io_callback and l_term_process is something I don=E2=80=99t =
really like since I rather keep that internal.

>  ell: Add include directive for 'ell/term.h'.
>  ell/Makefile: Added 'term.[ch]' to HEADERS and SOURCES.
>  term: Added 'l_term_*' symbols.

These 3 were already in my latest set.

>  ell/term: Do not return -EPERM for 'putnstr' and 'vprint' if not
>    running.

Why is that important. It seems like a hack. If you haven=E2=80=99t =
successfully acquired the terminal, there is no point in writing to it =
since you have no idea what termios setting are dealing with.

>  ell/term: Return error on writes if the output descriptor is invalid.

Seems like a fix for the previous change.

>  ell/edit: Rename 'l_term_{open,close}'.

I incorporated that into my set. Makes sense to me.

>  ell/term: Add an 'l_term_is_acquired' introspection function.

I added it, but don=E2=80=99t really know how it would be used.

>  ell/term: Added ASCII C0 and C1 control code mnemonics.

Hmm. We could do that, but the constant name is too long for my taste. =
And why use an enum instead of defines?

Regards

Marcel

