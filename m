Received: from mail.holtmann.org (coyote.holtmann.net [212.227.132.17])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 111D429D0E
	for <ell@lists.linux.dev>; Mon,  2 Jun 2025 06:19:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=212.227.132.17
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1748845153; cv=none; b=OM1em6hR58m84Z9wQuCAk34W56R+ZbG1bfYO35AlbA2uf9Qvf9/QOm+waQdPbt//rHTRQlbTdw37+k9DoEKaHJpU9LF6+zLmPvO7UEgedsq0urRah59aXLyUy/zTYHzanQwLz+4QXE4BI4ytsgPgUrR9xcUdmCDBvNKA3hxN3oA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1748845153; c=relaxed/simple;
	bh=pj48LhDK+MkziqT8390BZ03YHeZXsRkzH2D+GtQ5tiw=;
	h=Content-Type:Mime-Version:Subject:From:In-Reply-To:Date:Cc:
	 Message-Id:References:To; b=mLcQ+hofeMIqGTp8oh1G0CBJP6dlX/svcFeNm/3uGQf7lLVuq9pput76SuHvgC9hnh5kx/kl5DzJyz9+I8YZ7DrkUWaOE81kGgh0XbZYB+plLLN9AQCB21Mo49U51QxSLrv3jyu00rPcmq0ZK6LKO346Ybwl0WiFtJ1aN7mpjEw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=holtmann.org; spf=pass smtp.mailfrom=holtmann.org; arc=none smtp.client-ip=212.227.132.17
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=holtmann.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=holtmann.org
Received: from smtpclient.apple (p4ff9f112.dip0.t-ipconnect.de [79.249.241.18])
	by mail.holtmann.org (Postfix) with ESMTPSA id 472F7CECC7;
	Mon,  2 Jun 2025 08:19:04 +0200 (CEST)
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
In-Reply-To: <EC404FFD-E142-4D69-B635-4A519D07D885@nuovations.com>
Date: Mon, 2 Jun 2025 08:18:53 +0200
Cc: ell@lists.linux.dev
Content-Transfer-Encoding: quoted-printable
Message-Id: <B162491F-838A-4BEE-8C21-E4A765DB9408@holtmann.org>
References: <cover.1743976923.git.gerickson@nuovations.com>
 <9E228E49-412C-478B-AD92-F8FA2210BFDD@holtmann.org>
 <748F73CA-FB10-43BC-969F-0D497C4605E9@nuovations.com>
 <EC404FFD-E142-4D69-B635-4A519D07D885@nuovations.com>
To: Grant Erickson <gerickson@nuovations.com>
X-Mailer: Apple Mail (2.3826.600.51.1.1)

Hi Gran,

>>>> This expands on Marcel Holtman's 2023-12-22 RFCv4 patch for an
>>>> input/output terminal abstraction.
>>>>=20
>>>> Substantive changes from the v7 version:
>>>>=20
>>>> * Fixed a typo in the  ASCII C0 and C1 control code mnemonics.
>>>>=20
>>>> Grant Erickson (9):
>>>> term: Initial revision.
>>>=20
>>> I actually reverted it back to my version and included printf / =
vprintf helpers.
>>>=20
>>> What is the purpose of l_term_set_bounds? Is it important for =
non-TTY setups since for TTY compatible terminals, this should not be =
needed.
>>=20
>> It=E2=80=99s been a year and a half since I first deploy[ed] this, so =
bear with me as I attempt to clear some dust and cobwebs from some of =
the details.
>>=20
>>>=20
>>>> ell/term: Do not return -EPERM for 'putnstr' and 'vprint' if not
>>>> running.
>>>=20
>>> Why is that important. It seems like a hack. If you haven=E2=80=99t =
successfully acquired the terminal, there is no point in writing to it =
since you have no idea what termios setting are dealing with.
>>=20
>> Per the above, regrettably, at this point I don=E2=80=99t recall the =
issue that I had run into. For what they are worth, my output methods =
are:
>>=20
>> ...
>>=20
>>>> ell/term: Return error on writes if the output descriptor is =
invalid.
>>>=20
>>> Seems like a fix for the previous change.
>>=20
>> It might well be. Again, per the comment above about getting back =
into the context of a year and a half ago, it seems like there was a =
desire to be able to initialize an instance with the stdin / stdout file =
stream pointers and have things work as-is and then bootstrap into / out =
of those with the terminal as my line oriented UI/UX acquired / released =
the terminal as UI/UX elements were pushed/popped off the stack.
>=20
> Thinking about this further, I suspect my original changes about =
is_running (now, is_acquired) / -EPERM and -EBADF were about early =
prototyping and refining my stack based, line-oriented UI/UX.
>=20
> I suspect if we left the code as-it was in those two regards, the =
stack based, line-oriented UI/UX would work fine. If that=E2=80=99s not =
the case, I can revisit that specific issue later.

then I am starting to leave things out and see how far we get.

Regards

Marcel

