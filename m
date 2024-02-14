Received: from mail-oo1-f48.google.com (mail-oo1-f48.google.com [209.85.161.48])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0BA5D60B9B
	for <ell@lists.linux.dev>; Wed, 14 Feb 2024 16:57:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.161.48
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1707929874; cv=none; b=iP+xM25tdZgtiHGS0uq0elti6rho+K6NfNrcrtaYZW/b/m0UUvAaLe2Ygwn8BvNAxqU+84A+tTS8mI3b2gLT9jVZij0tpXoqDRcQvdzGapdmkKW46UgIwUzeIO2J6PvfmfFV9M5/67tiUFmGB/H/L7FE4mpsKoD+i0iYUFWpvS4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1707929874; c=relaxed/simple;
	bh=rYtrOYrqXzdDHM9okjSLPCP2v+hBEMzDn4XdzSDyhCg=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=U2oImz60bv+iyyhW3Z8lVR8RG3HmUX7115W8SAeMdQ9a7R0in61+egvb/tjD3ERj8tg439qvE06CvyNSypY/12cCrsDYWWizVvbFgVx6STk5Op+2K101k7wmwZt31t926PO4rIzTQL9Gc3N4wb5AJuIQ2AWefhjo/Z0/DaI2q3A=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=URuXhBBD; arc=none smtp.client-ip=209.85.161.48
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="URuXhBBD"
Received: by mail-oo1-f48.google.com with SMTP id 006d021491bc7-59f786b2b59so161921eaf.0
        for <ell@lists.linux.dev>; Wed, 14 Feb 2024 08:57:52 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1707929872; x=1708534672; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:references:cc:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :from:to:cc:subject:date:message-id:reply-to;
        bh=mFTdU6Hi+hlUmdWo5/F7gcRnLmfS6YxMYSFqv4g4NsQ=;
        b=URuXhBBDoMsZjtw3LzABQIY7dWYSOSpjQggP1LDlv/+JLrEj7eYvY0q5fuSuqdDnWo
         jHDfL+VRX/03IkF9/zklHgkgFjS2hYss4vr2vOKxFrYO17kz1D6L8NITk0RXFK7Eyuxl
         rgF6ThwAOei04cWBsBw2PnNep1arIuIYhiiAbuHIZEfERbfGlPtlkoHaqKuQLsjLoSeW
         DpGbiy0up8MfLGHsrhjsIB/KRWErAJMVW7zWCL8GiCUR8M2u9KJnE0LwNHNqE7lnBhQl
         nIjtc+opPDZXFSDP0AyRaznSTXmrzc74/8+yAcSR/3lkS6EEam4DRfCGscO4lYN8P1Ce
         fApA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1707929872; x=1708534672;
        h=content-transfer-encoding:in-reply-to:from:references:cc:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=mFTdU6Hi+hlUmdWo5/F7gcRnLmfS6YxMYSFqv4g4NsQ=;
        b=H51EX9IXN9ORZTBsQuT2H9rA80ONhP5HEakkxkQdxvlvoOI9/r9FM2h7pEeXU+SPHx
         n6c/Ngk6xPy9V1WkJbqNlazzGRZbmFvy2VwFQkTp7fmXZvR6/wQfgY4rtqS8LW2QakEF
         QqUNOgk63J+/w05dSTHPfVRP/tb3gZtVJcP+UoDS0nYaP34aI3BFW3iYn6xw/z5KPcY0
         Ys/DT0N99MGTf07xFOmznDp+8KxsBXRAYc4PHT1SE8lEtCnoPLSdFW/nTAjo3lIVu0VB
         7sOUYT5ZWiiz+e1tz7vSiyZ0Yf/+a2s+ZkJcwImswk3m7/XXYjn7q0pFH0KLF+dIT/rx
         gG/g==
X-Forwarded-Encrypted: i=1; AJvYcCXkCcgadLSPcbbPxK3e25ZwIbftwgMCkpLu33F6tyXz8Jfo7/VE/LgCzBxdWX23ucEzDMeolbtjkXnEWHGt18jz0+OC
X-Gm-Message-State: AOJu0YzaKMttuI7+l++qIUQpTDz8pShY4iV/Y+vmIakjTeZvif/dg/Mc
	Uc7U5K0S7Jecum9X+wiDQo4pjbQ5BFJzAH4cZ3PIFrDi/hIdo3ZK
X-Google-Smtp-Source: AGHT+IHqyUQd/xLvBVzbSkCvbT6IRNL0DiCGj4CeEayevjVkejnfBA/Xq1K1MAXU3Hh3pN/tjK7nWQ==
X-Received: by 2002:a4a:ea05:0:b0:59d:5d84:3541 with SMTP id x5-20020a4aea05000000b0059d5d843541mr3234987ood.5.1707929871997;
        Wed, 14 Feb 2024 08:57:51 -0800 (PST)
X-Forwarded-Encrypted: i=1; AJvYcCUmfRZ4Mj2yr515U5cbiJmgT6cDykAWta/j3T60fIzxV4bO9wUyoc0IYQjH8TTPhnBD8lORewEKDMz2ZGZYuou+uDVA
Received: from [172.16.49.130] (070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id w7-20020a4a9d07000000b0059a598daafcsm891142ooj.43.2024.02.14.08.57.51
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Wed, 14 Feb 2024 08:57:51 -0800 (PST)
Message-ID: <9f0927c8-d4d2-4a10-90df-436823f1d663@gmail.com>
Date: Wed, 14 Feb 2024 10:57:50 -0600
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH] log: add l_notice
Content-Language: en-US
To: Marcel Holtmann <marcel@holtmann.org>
Cc: James Prestwood <prestwoj@gmail.com>, ell@lists.linux.dev
References: <20240213131619.828613-1-prestwoj@gmail.com>
 <0D7EFC7E-C3D9-43E0-823E-6C06498C6B3D@holtmann.org>
 <da1ddff5-80c7-46a4-9187-6cd8d5b2854b@gmail.com>
 <3129778E-09AF-46D9-97DE-44EC89C996DB@holtmann.org>
 <5645df71-5fa8-497e-b5cd-b21557aa9bb3@gmail.com>
 <306317D2-65C4-4299-83C3-DC4C616975C5@holtmann.org>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <306317D2-65C4-4299-83C3-DC4C616975C5@holtmann.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

James,

> 
> fine, then lets get a section into the coding style document.

Can you come up with something?

I've applied this patch, thanks.

Regards,
-Denis
