Received: from mail-oo1-f51.google.com (mail-oo1-f51.google.com [209.85.161.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C66FA7E767
	for <ell@lists.linux.dev>; Wed, 14 Feb 2024 18:51:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.161.51
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1707936676; cv=none; b=mcwtS1de9WsKlMVfZh/ZvALV4bhSVzXi6SKT8bE8J3ovSMBYPTJg0N5nc3xW6jSEf2j6zmGEmUgr2wiLlpzfz9m2nWanuxXxuVPMDOexK3UFVeM5UZXyB2Kg3QXZv88WwEtV0odpL2M6oZ3tzpAL+CBJ+OOeVoy8o9wZ4uKyfLc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1707936676; c=relaxed/simple;
	bh=A4qYsGQmtg2/4CLnsY7mace7mI96pOoHaaPlAbWLK98=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=kBa7q38SABG7HFvTZSO+v8eJRQv7UhHPDQxg1itHbrC8Xm6RFcJU6GS6GpCD47mLCZGekiegGBPHrIbUQPJQY6F0e2V3ko04KnaZoSBa1tq2lxQQtXmdIXCnsgCJTuUfnBBnSMGnlip8UcgSj4HVYQXYG7GrZwhwKWcLyjuNGz0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=Yig+cmpw; arc=none smtp.client-ip=209.85.161.51
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Yig+cmpw"
Received: by mail-oo1-f51.google.com with SMTP id 006d021491bc7-59caf51d4bcso23373eaf.1
        for <ell@lists.linux.dev>; Wed, 14 Feb 2024 10:51:14 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1707936673; x=1708541473; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:references:cc:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :from:to:cc:subject:date:message-id:reply-to;
        bh=/Dn0IUYAtxGoI7CAF8zqoBFcNLmtd8Am/fmXz5+j1Ks=;
        b=Yig+cmpwvS77Ig0jiRFTbTy30buCsNgrIAQi6/55+Q2EMO/OhgB1+e0voibyUakvx4
         nABRunrB5xb6SQpCAqNjDnVMSQAHIMmSt23EnBiWq6bbe9aM5xMaMcC9xi70uZO4bkr5
         5s8gkiR0IX6LOJoUeM492gOviRZU9Vwgmy+/TaTgHGpC+7a0fLqiuRj+8BxteTlo86iI
         BrpuovvGbpMXpr6rR67xzC3PBENXVs59y0alPg+q2m26m0Nb69Jsc1xMCh/2Yq3WF6Lb
         tyfFGz4cW31cdpqdmIuMFD7gI30vs4Cm/ry1XYkK0znP3/3Kr3BqZ/MEB6ceMLavFtCb
         GUiQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1707936673; x=1708541473;
        h=content-transfer-encoding:in-reply-to:from:references:cc:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=/Dn0IUYAtxGoI7CAF8zqoBFcNLmtd8Am/fmXz5+j1Ks=;
        b=Tfs07htUWhQM5L83S9QW8SYP61YiVTCCsQylfkjYnLGhkb+k3t1b/veJV7I91OMibX
         5Qiu3fShB96wUgOvGkih6JfyxWCLLLsms6fbGHgKBZAEuxRLSppmLbeqSsCSyl+XHp9E
         RR/fv7tQdpG7FN8u02pB4Tm6X7zBt7PSC3LU2kmQu5xlkiMdOkhB1cobrRtfet1niYry
         JpaxQrQLkYTwemA6caJqB9DkL9u3m0fD+fc9NZbC/4FpoC0CYqxEyjBptU6K83mHdhIC
         YrUZU84Ev9sJ02be/VMKzZEHuoGUcgtRI6L38qTDrR234nYI2a1KoxW0zmwS0K7V/STT
         crwA==
X-Gm-Message-State: AOJu0YzF2bE8nIM7akgz/oobSqaSfYroWYDjVNIxiUEVozpdhYZwSVJ4
	gPIpuRRYBEojXEy5BgGt2l05jsqtYWAWw3gABamhtIg889DcF/Ck
X-Google-Smtp-Source: AGHT+IHtejW/KnOa5easTYSczJ+913FhGp0AXfEzBxhFWXUi2y8vh+n8EWughniaMmZYLDxt6K7feA==
X-Received: by 2002:a4a:6259:0:b0:59d:72c0:ec51 with SMTP id y25-20020a4a6259000000b0059d72c0ec51mr1283461oog.4.1707936673649;
        Wed, 14 Feb 2024 10:51:13 -0800 (PST)
X-Forwarded-Encrypted: i=1; AJvYcCVpebV/IO4LeN7fGh0EIDiGH3LPWGe83m7RTC0oWDDBV64rs/LOWabn1BOSdMIJGedAUIyocDCZzUfHGoRAP0K/ZsWC
Received: from [172.16.49.130] (070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id k20-20020a4a3114000000b0059cc37c8cdcsm927235ooa.46.2024.02.14.10.51.13
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Wed, 14 Feb 2024 10:51:13 -0800 (PST)
Message-ID: <c441b052-15bf-4bbc-a39f-d028f0d3c644@gmail.com>
Date: Wed, 14 Feb 2024 12:51:12 -0600
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH] log: add l_notice
Content-Language: en-US
To: James Prestwood <prestwoj@gmail.com>,
 Marcel Holtmann <marcel@holtmann.org>
Cc: ell@lists.linux.dev
References: <20240213131619.828613-1-prestwoj@gmail.com>
 <0D7EFC7E-C3D9-43E0-823E-6C06498C6B3D@holtmann.org>
 <da1ddff5-80c7-46a4-9187-6cd8d5b2854b@gmail.com>
 <3129778E-09AF-46D9-97DE-44EC89C996DB@holtmann.org>
 <5645df71-5fa8-497e-b5cd-b21557aa9bb3@gmail.com>
 <306317D2-65C4-4299-83C3-DC4C616975C5@holtmann.org>
 <9f0927c8-d4d2-4a10-90df-436823f1d663@gmail.com>
 <8d128478-7c2c-45cd-a789-c44dffc2ad15@gmail.com>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <8d128478-7c2c-45cd-a789-c44dffc2ad15@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi James,

On 2/14/24 12:28, James Prestwood wrote:
> 
> On 2/14/24 8:57 AM, Denis Kenzior wrote:
>> James,
>>
>>>
>>> fine, then lets get a section into the coding style document.
>>
>> Can you come up with something?
> 
> Yep sure, but are you talking about IWD's or ELL's coding style document? l_log 

iwd

> isn't used in ELL so I'm not sure its relevant there, and any external project 
> using l_log could really do whatever they want with it.
> 
> For IWD yes, I planned on adding a coding style section along with my patches 
> using l_notice as its going to be reserved for very specific use-cases and have 
> some basic syntax requirements for tooling to parse.

Awesome.  Sounds good.

Regards,
-Denis
