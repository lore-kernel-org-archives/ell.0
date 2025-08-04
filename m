Received: from mail-oa1-f47.google.com (mail-oa1-f47.google.com [209.85.160.47])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 99B8B26B755
	for <ell@lists.linux.dev>; Mon,  4 Aug 2025 14:24:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.160.47
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1754317485; cv=none; b=nxHc1bd/tPNaj0Vh69smV5uThd0vIlmbN3i9hzkaonQnSoKOuSXrJAfsXyX9MZoy0TPcdPRSqBTzXvFTfa2mgyr32hCyfb9CBPT6ydRXG3PevOqXaipQhMEg69DxL3Rrk3LzNWKsoKetX+dDpU59CCWQJ6AYhlahUXIZTcvzLB8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1754317485; c=relaxed/simple;
	bh=+x6KWNMsFzWITYQy31oM91K2sMkgvmEy0EnQ2oZjN7c=;
	h=Message-ID:Date:MIME-Version:Subject:To:References:From:
	 In-Reply-To:Content-Type; b=bpG/7tsUKt+YLtC+Xba24B+0kEgGJ/yh5IDjqdV9ekW3COdRaUTRfAn34/mSOeKnYzKOTYZTtkuKF2SipxAB+QjpbEiEta6lR7rDdxGVbfeMe9ms96xvDtEKOVl3YHmbezTJW9Mlkscf015WxkSS+TMCHWBuanEK/9oh3PCIDlI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=dFKmpCMa; arc=none smtp.client-ip=209.85.160.47
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="dFKmpCMa"
Received: by mail-oa1-f47.google.com with SMTP id 586e51a60fabf-306b7eb492aso2862224fac.0
        for <ell@lists.linux.dev>; Mon, 04 Aug 2025 07:24:43 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1754317482; x=1754922282; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id:from
         :to:cc:subject:date:message-id:reply-to;
        bh=QsHrgrpVTMmMdgJ4MrMY5lFNi7arWymtse20PAgaKu8=;
        b=dFKmpCMafQ4bn5hBkZ9V/xYlf100p7EK5mAgg9uREabd/EVnHscn90LAHqYZj17/fd
         viuKXeoyPodHvJJB384JmjYbnejQY3JZuVyI2AI/Qq/VATisnRsGHXU206El174Eskl7
         zxKjYX1eM+BR79IuvygWaBKwbp48zkf+X9cDY+IoLdJtj0TJlGPcomqoSj4jJx0fuzYo
         zwDtlT+zsHkPphZfFe55PkCC8Ouxl+yludp1aQpIs81Nk0XygWisnKtZQ2oT0fzldnMm
         quBRWzatTWJFbrymFSmp2qwqi3djwsb/30JkKJ/RBnn92XOpyOst2lwvGfcY7m1t3F0Q
         9fgw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1754317482; x=1754922282;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=QsHrgrpVTMmMdgJ4MrMY5lFNi7arWymtse20PAgaKu8=;
        b=Qo/KJLZzEbfJZEHk2k/oqo6jSqoSFncGw9pBMne7x+oyDn3UjTsU2suoozPpmzVtJn
         Y6kWZXyjqVuge4pdXhvbGOULJQFfYe+dEBIA6MTQ8XabwPNp5zxWLOK+1dkrfITlePeU
         Kn/HFT8Cf18HpyV2FQwfhrVonso6rprykfj8D6D8ueIwSlIbCme1M+mrLUShKMzzPBR3
         j8EHlUpDW0dVSSy0eELO3OBKgJ9itCl4ShNHw+ewlhz46lXHjnwuTgWhGwjtIGnPsgUl
         hzkahNNzj+E5Pj3ko55L3MlyLHCuquFNL3JSK8Xi90TY/X3O72CZ6pgOQpA/zoAQCiHg
         JJXQ==
X-Forwarded-Encrypted: i=1; AJvYcCUkMZC0g/CKOZgMw75/8UyaevD5Rpwtjg1JzQBTPLi8IoOuFdn9oGicqyoc3PWiRQrNW+E=@lists.linux.dev
X-Gm-Message-State: AOJu0YwndlLNUSePF8vlXIxp31aYcQTe/YtTQqXb0wQduVOQDDvO3FZj
	Ri8MU0qLh1cTGJKr9lm2peWJ3vCVph2lKg3IRADSO3YUPt/XCz2mJxihm2RJtw==
X-Gm-Gg: ASbGnctVgyIn9tfts6lErNwQjTokjXlxXd1vzpsGPUNZ8fwpnhEGZjT/QD0qBDgAiBG
	swqb/bRd07B0FuAs3mRE1QYgHBAWgYVNYaJZipGKh9vSmyfIKmslCLrqJW6BofSu8IKS07U/aEk
	n3eaEmb6oECls5p0wef9+qmq843XLIluVuwZ3UfWxfSap4Kluy7HQFoOC0k44PM/ZvkPxfTKE4m
	5yYAunxUPgy40SEGN2tWJ2X8fCJIdT44ICsbRMva5q0w4WIkH61Mju5cQo8Uax8v6NM2gczYWWM
	jy5dDPX0MyvmNNO/ezrbsUgMkEBS77+qp7S77oHyyIeXbJ3gnwSqTxrlboflnfI5QLcBuc0l2cD
	GTewjJq4dQJ4LoKXmPdwwLbzjIeAYpNbIHVCPSrcDJxWONZ1Ex0ESaPgH+ulakagxdsylAqsCRP
	o=
X-Google-Smtp-Source: AGHT+IFlgyoTLIDQA9oLV5P+yYCNX4ElLeLywKE2/2yjULM0DeqmgoARdR72thpXQrUaGHQvVQmCQg==
X-Received: by 2002:a05:6870:1f09:b0:30b:ac1a:568d with SMTP id 586e51a60fabf-30bac1a7293mr1566438fac.13.1754317482573;
        Mon, 04 Aug 2025 07:24:42 -0700 (PDT)
Received: from [172.16.49.130] (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id 586e51a60fabf-307a7172ac6sm2735946fac.9.2025.08.04.07.24.41
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Mon, 04 Aug 2025 07:24:42 -0700 (PDT)
Message-ID: <bf1a3bf8-8189-457d-945f-8e6b58f1f940@gmail.com>
Date: Mon, 4 Aug 2025 09:24:41 -0500
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH 3/5] test: Bump support TAP version
To: Bastien Nocera <hadess@hadess.net>, ell@lists.linux.dev
References: <20250731142153.2802258-1-hadess@hadess.net>
 <20250731142153.2802258-4-hadess@hadess.net>
 <264df186-6d7e-471f-b155-f5942e79cb78@gmail.com>
 <5a4a8472d39727e048a98125e689f16b968f29b9.camel@hadess.net>
Content-Language: en-US
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <5a4a8472d39727e048a98125e689f16b968f29b9.camel@hadess.net>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi Bastien,

 >
> glib has been using TAP 13 since 2022[1], and I think that the only
> reason it didn't use TAP 14 at the time was because meson didn't
> support it.
> 
> meson supports TAP 13 or 14 now, so I did the smallest possible change
> and bumped it to 13.

Ok, fair enough.  I went ahead and applied this as well.

Regards,
-Denis
