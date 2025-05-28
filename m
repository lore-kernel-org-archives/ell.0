Received: from mail5.g24.pair.com (mail5.g24.pair.com [66.39.139.36])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DEE792797B5
	for <ell@lists.linux.dev>; Wed, 28 May 2025 14:34:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=66.39.139.36
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1748442878; cv=none; b=dAGtL/CpooxmJtLnRWJwwHkQ94iaP0q2MIldqC+VATsgA7GhtT4Ra9zjBwwDRN9nPNEUiW5jOqcZ1m4bbT/Uh04neK5vW8Cu7W2WjGOjBxjZ1AgRZXHwLdhnNRtgOZGPHY/tzlnb2t47LTlSmFcAZpSxilWDitS0eLkn/InFhC0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1748442878; c=relaxed/simple;
	bh=wa5LuvhtRtSnm07RvIEX2SZThVbh8wVy2J/lFpQIJWw=;
	h=Content-Type:Mime-Version:Subject:From:In-Reply-To:Date:Cc:
	 Message-Id:References:To; b=DbygEd3c4agmzkZcElMqU/3a8XNS7L5yx4/jzAmxU/quIK06bqYxcG8iLvBv0vIBY6EPVIF+V8LVKwuykg/3KM3hfOhWoZxAcYTRytGAssjYZBR90ZMnBn3VtXfCp+Gc6JdoMfktGLzpHOBgKa3oxWMS7euwQbS2C2/ZU+JgPX4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com; spf=pass smtp.mailfrom=nuovations.com; dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b=E5DBjB8/; arc=none smtp.client-ip=66.39.139.36
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nuovations.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b="E5DBjB8/"
Received: from mail5.g24.pair.com (localhost [127.0.0.1])
	by mail5.g24.pair.com (Postfix) with ESMTP id 895F31649C1;
	Wed, 28 May 2025 10:34:34 -0400 (EDT)
Received: from smtpclient.apple (c-73-202-173-252.hsd1.ca.comcast.net [73.202.173.252])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail5.g24.pair.com (Postfix) with ESMTPSA id 388C5124FB3;
	Wed, 28 May 2025 10:34:34 -0400 (EDT)
Content-Type: text/plain;
	charset=utf-8
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
Mime-Version: 1.0 (Mac OS X Mail 16.0 \(3826.600.51.1.1\))
Subject: Re: [PATCH v9 0/9] Input/Output Terminal Abstraction
From: Grant Erickson <gerickson@nuovations.com>
In-Reply-To: <748F73CA-FB10-43BC-969F-0D497C4605E9@nuovations.com>
Date: Wed, 28 May 2025 07:34:23 -0700
Cc: ell@lists.linux.dev
Content-Transfer-Encoding: quoted-printable
Message-Id: <EC404FFD-E142-4D69-B635-4A519D07D885@nuovations.com>
References: <cover.1743976923.git.gerickson@nuovations.com>
 <9E228E49-412C-478B-AD92-F8FA2210BFDD@holtmann.org>
 <748F73CA-FB10-43BC-969F-0D497C4605E9@nuovations.com>
To: Marcel Holtmann <marcel@holtmann.org>
X-Mailer: Apple Mail (2.3826.600.51.1.1)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nuovations.com; h=content-type:mime-version:subject:from:in-reply-to:date:cc:content-transfer-encoding:message-id:references:to; s=pair-202401062137; bh=W6n3TaFvFB2rDr+rsX70IkZvlsNrrd2ODT/m564D/EI=; b=E5DBjB8/OFj+QbXkhpa3PSscJ8NDzaelveiFgQShULpOzuF/HUvZkE8CNHpS2V413HjZAERoOHCUWM+wB1uw7/J2jTiM4/WY0B6s+5neH3ODAWXtmEJK2BtVRQ1djIlYGUTwiX/GIoRRseLYgcb2xo5IBIerylJeSyowloA1x/ycxcWzk/l97TzQ7eZdJc5K8JLmGchORmTeuwMubIo/vGvQOBSrQP5+BI/1moMwgnFyQiIjg1fS1PlPopdljP+j224Q/oQTTF3H8pMM3UzKKmgHYopkJ1CpBzH4NA93bitatj8ivjPDbMGwYMtfRJbr6Z34rwm6pUlwwh3qTL6PHQ==
X-Scanned-By: mailmunge 3.10 on 66.39.139.36

On May 27, 2025, at 11:08=E2=80=AFAM, Grant Erickson =
<gerickson@nuovations.com> wrote:
> On May 27, 2025, at 10:20=E2=80=AFAM, Marcel Holtmann =
<marcel@holtmann.org> wrote:
>>> This expands on Marcel Holtman's 2023-12-22 RFCv4 patch for an
>>> input/output terminal abstraction.
>>>=20
>>> Substantive changes from the v7 version:
>>>=20
>>> * Fixed a typo in the  ASCII C0 and C1 control code mnemonics.
>>>=20
>>> Grant Erickson (9):
>>> term: Initial revision.
>>=20
>> I actually reverted it back to my version and included printf / =
vprintf helpers.
>>=20
>> What is the purpose of l_term_set_bounds? Is it important for non-TTY =
setups since for TTY compatible terminals, this should not be needed.
>=20
> It=E2=80=99s been a year and a half since I first deploy[ed] this, so =
bear with me as I attempt to clear some dust and cobwebs from some of =
the details.
>=20
>>=20
>>> ell/term: Do not return -EPERM for 'putnstr' and 'vprint' if not
>>>  running.
>>=20
>> Why is that important. It seems like a hack. If you haven=E2=80=99t =
successfully acquired the terminal, there is no point in writing to it =
since you have no idea what termios setting are dealing with.
>=20
> Per the above, regrettably, at this point I don=E2=80=99t recall the =
issue that I had run into. For what they are worth, my output methods =
are:
>=20
> ...
>=20
>>> ell/term: Return error on writes if the output descriptor is =
invalid.
>>=20
>> Seems like a fix for the previous change.
>=20
> It might well be. Again, per the comment above about getting back into =
the context of a year and a half ago, it seems like there was a desire =
to be able to initialize an instance with the stdin / stdout file stream =
pointers and have things work as-is and then bootstrap into / out of =
those with the terminal as my line oriented UI/UX acquired / released =
the terminal as UI/UX elements were pushed/popped off the stack.

Thinking about this further, I suspect my original changes about =
is_running (now, is_acquired) / -EPERM and -EBADF were about early =
prototyping and refining my stack based, line-oriented UI/UX.

I suspect if we left the code as-it was in those two regards, the stack =
based, line-oriented UI/UX would work fine. If that=E2=80=99s not the =
case, I can revisit that specific issue later.

Best,

Grant

--=20
Principal
Nuovations

gerickson@nuovations.com
https://www.nuovations.com/

