Received: from mail.holtmann.org (coyote.holtmann.net [212.227.132.17])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 1F76A604BA
	for <ell@lists.linux.dev>; Wed, 14 Feb 2024 16:54:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=212.227.132.17
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1707929664; cv=none; b=jmH0nKuk5lbH7yLMVtC/owqn4BPhh8aBuoANKrhSidhF/6m5XtspTbNvDR4+i3k0GZScO51JrCo4/RCiENmlBwaPvxafNn0/UwRISziZR6NzW+SDajOkEEizr422vkLy9HAiBuZFdIBKV9yCM1axon2uY5pa+17KpfwTzIFrC0M=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1707929664; c=relaxed/simple;
	bh=oF2YhP/j2S7zolWzPctA40zLOgOdvx7gCzTZRjyyetk=;
	h=Content-Type:Mime-Version:Subject:From:In-Reply-To:Date:Cc:
	 Message-Id:References:To; b=UVA5kvpWMNhnyGGebTOxdcwEafkYMM7ihWz8cLc3e6DEwLRaypBRQ04D5ZdyGrYbG4N7JqfKtXBOJrcHFyj8nk6ARv52ufnR1Rcvwr0jQ4C57qni2X7e3f108OhrCsTMhSSbfqAuwZJ6qldoCfeN6OClP/W4lardPM5ix9tGX7s=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=holtmann.org; spf=pass smtp.mailfrom=holtmann.org; arc=none smtp.client-ip=212.227.132.17
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=holtmann.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=holtmann.org
Received: from smtpclient.apple (p4ff9fa23.dip0.t-ipconnect.de [79.249.250.35])
	by mail.holtmann.org (Postfix) with ESMTPSA id F0A0DCECBE;
	Wed, 14 Feb 2024 17:54:20 +0100 (CET)
Content-Type: text/plain;
	charset=us-ascii
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
Mime-Version: 1.0 (Mac OS X Mail 16.0 \(3774.400.31\))
Subject: Re: [PATCH] log: add l_notice
From: Marcel Holtmann <marcel@holtmann.org>
In-Reply-To: <5645df71-5fa8-497e-b5cd-b21557aa9bb3@gmail.com>
Date: Wed, 14 Feb 2024 17:54:10 +0100
Cc: James Prestwood <prestwoj@gmail.com>,
 ell@lists.linux.dev
Content-Transfer-Encoding: quoted-printable
Message-Id: <306317D2-65C4-4299-83C3-DC4C616975C5@holtmann.org>
References: <20240213131619.828613-1-prestwoj@gmail.com>
 <0D7EFC7E-C3D9-43E0-823E-6C06498C6B3D@holtmann.org>
 <da1ddff5-80c7-46a4-9187-6cd8d5b2854b@gmail.com>
 <3129778E-09AF-46D9-97DE-44EC89C996DB@holtmann.org>
 <5645df71-5fa8-497e-b5cd-b21557aa9bb3@gmail.com>
To: Denis Kenzior <denkenz@gmail.com>
X-Mailer: Apple Mail (2.3774.400.31)

Hi Denis,

>>>>> #define L_LOG_WARNING 4
>>>>> +#define L_LOG_NOTICE 5
>>>>> #define L_LOG_INFO 6
>>>>> #define L_LOG_DEBUG 7
>>>> for what? What is the difference to just use l_info?
>>>=20
>>> Per conversation on Slack, James wants to categorize certain =
messages for easier searching.  Since NOTICE level exists, I suggested =
it would fit the usecase.
>> I never really liked having many different levels. That was the =
reason I left l_notice out initially. I see no real benefit of it except =
us discussing "is this suppose to be l_info and l_notice" and in the end =
it will be just random.
>=20
> There will always be some of that.  Each project will have to =
calibrate individually, but I don't see a problem exposing this inside =
ell.
>=20
> In iwd we use l_info for purely informational messages, like hardware =
capabilities.  Most users won't care.  l_notice would be used for things =
like roaming decision logic and other messages that do not warrant a =
l_warn / l_error.  I think it is a nice in-between actually, =
particularly on non-user facing systems.

fine, then lets get a section into the coding style document.

Regards

Marcel

