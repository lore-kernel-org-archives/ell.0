Received: from mail.holtmann.org (coyote.holtmann.net [212.227.132.17])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 098F06025A
	for <ell@lists.linux.dev>; Wed, 14 Feb 2024 16:27:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=212.227.132.17
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1707928082; cv=none; b=eBa1fevqA6/JM06t+UCO48YBkNJ0NbUo7X1qPoDwqpbsqzyHnwsdAvFRrqCWQ0gUtL0mUoxc0HlcLBw25hQExAIud4yNiaGB3w5Onc3vE0BGakq1Wl3stwrevTjQsvLnNR8XpoEgTZnnkyC7peEBLRxJ/7devF3BjcmGRMo69HM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1707928082; c=relaxed/simple;
	bh=NVMDP0YPI+KYpTWwRY2wik+c7x2Kw0UuE4hobcl0fcQ=;
	h=Content-Type:Mime-Version:Subject:From:In-Reply-To:Date:Cc:
	 Message-Id:References:To; b=iXeItTuRvFxIc7nUjx8SCsIRJbT6MxgAiXopB0hOy+DXeqqe6TSpAXm6/jt+XpmklO1vuASLU0H1ZGBjHOPG13os4s5fFznFYLNKomM5CtY/FhcFydNd1OsUIgqoDa5Eej6+nrPg7U1cZVFEKM+RHjokkAU7a0b2eAhYGywZ47E=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=holtmann.org; spf=pass smtp.mailfrom=holtmann.org; arc=none smtp.client-ip=212.227.132.17
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=holtmann.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=holtmann.org
Received: from smtpclient.apple (p4ff9fa23.dip0.t-ipconnect.de [79.249.250.35])
	by mail.holtmann.org (Postfix) with ESMTPSA id 5C54ECECBE;
	Wed, 14 Feb 2024 17:27:53 +0100 (CET)
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
In-Reply-To: <da1ddff5-80c7-46a4-9187-6cd8d5b2854b@gmail.com>
Date: Wed, 14 Feb 2024 17:27:42 +0100
Cc: James Prestwood <prestwoj@gmail.com>,
 ell@lists.linux.dev
Content-Transfer-Encoding: quoted-printable
Message-Id: <3129778E-09AF-46D9-97DE-44EC89C996DB@holtmann.org>
References: <20240213131619.828613-1-prestwoj@gmail.com>
 <0D7EFC7E-C3D9-43E0-823E-6C06498C6B3D@holtmann.org>
 <da1ddff5-80c7-46a4-9187-6cd8d5b2854b@gmail.com>
To: Denis Kenzior <denkenz@gmail.com>
X-Mailer: Apple Mail (2.3774.400.31)

Hi Denis,

>>> #define L_LOG_WARNING 4
>>> +#define L_LOG_NOTICE 5
>>> #define L_LOG_INFO 6
>>> #define L_LOG_DEBUG 7
>> for what? What is the difference to just use l_info?
>=20
> Per conversation on Slack, James wants to categorize certain messages =
for easier searching.  Since NOTICE level exists, I suggested it would =
fit the usecase.

I never really liked having many different levels. That was the reason I =
left l_notice out initially. I see no real benefit of it except us =
discussing "is this suppose to be l_info and l_notice" and in the end it =
will be just random.

So if you tell me / convince me when to use l_notice of l_info or use =
l_warn instead of l_notice, then we can talk.

Regards

Marcel

