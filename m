Received: from mail-ot1-f41.google.com (mail-ot1-f41.google.com [209.85.210.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 911E7242D72
	for <ell@lists.linux.dev>; Wed, 20 Aug 2025 16:17:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.41
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1755706643; cv=none; b=cgD2Dwr5f/BmQsAI24fnEm/QOD8wOJrFF4mRmWv6/FLQLRJCF5rcCqYla58ZroOePG0DaTb3z9Oxdkkn/TCEBUvia/1RAEUt/Ci9l+s1SjYryeRB1ObnrQyxtDj+7NnF/H38Kumn/OKPMrK4tbF1Kg0mY4gDgLm+npIqkk07ZAI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1755706643; c=relaxed/simple;
	bh=jGC3yH3gMxCSxOFEhd8NG9WmmPBVdL3jY0/BMMsZhVU=;
	h=Message-ID:Date:MIME-Version:Subject:To:References:From:
	 In-Reply-To:Content-Type; b=TL1zR5YsCR31cRTo/wkLoDDTPwA09QyC/iKr1qTnWRINTONZg8EwxYN/xg+eMFK6Pja5U7tJOcPOmFEgl99L3M5jU1OgYUesvC2Ogbs0Bf4HvJo1qX+6T+7F76pVVjOgnXJ7lK0aI1KHJoGilT1Mbrwm+iUISTrZYpz3WLqFSHk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=Yf1cWYCz; arc=none smtp.client-ip=209.85.210.41
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Yf1cWYCz"
Received: by mail-ot1-f41.google.com with SMTP id 46e09a7af769-74381ef25deso2700182a34.1
        for <ell@lists.linux.dev>; Wed, 20 Aug 2025 09:17:19 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1755706638; x=1756311438; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id:from
         :to:cc:subject:date:message-id:reply-to;
        bh=PphPwe6pXHdJL648f/NUKQzMkcBPeisNbUbwO9cUyxI=;
        b=Yf1cWYCzBlcoNhTydaT9PMG2aE8/QQ4A6Y/9l+4T79A+W42UhtOZFffwjVnlzoyGFH
         +2Xdq2jsWSaaJKDW9KchchWA5S/kBLTmaxzbdOTWVaZF1QHpb/MzVLFdAvfRGgZ9Ipka
         6DkTbq44Z7M8I9TGq5a/MlIyKblm7Ps+IR/MxJhCpzitBgOWyZPjkFVHrQ9RqWabOUST
         YJAGaufpuun/9KQKPz2rK7sKTVH3pqjd0jqgPXgy0ycuX9iTyEH7WBuPbjBNdgbydk14
         +I5WYCGOv2TKFYs5s21G9jsGbO+0wpSxHlrlsQncMtv9FDRtQtR523+/s82iyiMOrC9f
         F+PA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1755706638; x=1756311438;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=PphPwe6pXHdJL648f/NUKQzMkcBPeisNbUbwO9cUyxI=;
        b=huuH89jHtKegUamgv5fmQUqclPaPce37ojsNlbKVVrY1j6ZcsjM5qWnPq53jRhjsTA
         Nj00U4JkAq+9DXtHGpEXdoG2gbD6cG/Qc3xUPTOhy+o+leZ1aKP99UDC00MqZzPKki4i
         XdBzvKxMpIYBUgkXbmXxqHOt/guA9slsBf9aCFn05h1oVbUvy7zS+phEhiyTU2JxZjTQ
         fjZfNInhPUqUBnq3XRTtIQLRLxvNMQZAxGuG8YSXsKmEaUG+3n/YWf67pSP8a610SOM0
         JkX7c4BW4PjU25BOLqYTqQ05CLK4gYxaSG/zSo4j8O0Y97OSrP2Sp7UT3yGyfJA909V8
         WBow==
X-Forwarded-Encrypted: i=1; AJvYcCUzq5IY4Q6TuGTPBpMcr0QH2zo6Tneaw5iJv66CSUKxLMZGAsVDp3XwfDC0rPCYJ09OVOQ=@lists.linux.dev
X-Gm-Message-State: AOJu0YyGxfIrIuJsBF9KK3a1VSZp9tNC2jUd4f980qV6st2cZb8Q5KcE
	lrYUeUenuC1o1Ivf9xVgCXHOlOvJlxIHXsQXz9ImtjFkWD5FHGvtjk+c
X-Gm-Gg: ASbGncttuKH+w2h2tS2psJ6oXxSl7aXhsK+3n7jNlvwr1+OplDlHzZNG3IL3devZ49Z
	nYapjZq2P6uTUN07aX3F6GxlHrzwKo9acrbsKMZdT13yA7EDy6vydZtIaDgxP0EAb7e6aFM1+nZ
	XvXW9qAzxzeykk1Ov3faWO+79qUx88w2yYl4u5riD+4baOQxCc1yQzcPs/ahNp7PXDPvbB1byT0
	fCAmXGIxfvV1fyPUkB4yJq87Nx6Wk7yBCgvyhUy7H0ft94LoclWcYJSFJqQf6rmKCZjZ6Pd0Gb8
	e3St2IalbvWi1NAnTy2X6ooXL2bsZ/Rhe8I3Fe/aJQatWHucdyapvRRAiOgm6FE8K4rlKtwZGhN
	o1PdnMt+4188tgwDM2LW1aZ5NUoyRaOmR0iGM/lUApmBE+LYgdmoJTyMzbVm23Ta9zjezGQVIql
	4=
X-Google-Smtp-Source: AGHT+IE0ttLOU+NmCkaMRDBc6f6szcE8fZlYpUlb8fiDI5ArhAle9tOXyA0UNhL2rsjGAVLOuulr+Q==
X-Received: by 2002:a05:6830:d0d:b0:73e:5490:cf0f with SMTP id 46e09a7af769-744ebbcc8bdmr2340479a34.16.1755706638604;
        Wed, 20 Aug 2025 09:17:18 -0700 (PDT)
Received: from [172.16.49.130] (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id 006d021491bc7-61bebfb2a02sm1385943eaf.11.2025.08.20.09.17.18
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Wed, 20 Aug 2025 09:17:18 -0700 (PDT)
Message-ID: <8cf523c2-fa78-4f1c-9e3f-48a529d1e280@gmail.com>
Date: Wed, 20 Aug 2025 11:17:17 -0500
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH v5 1/1] build: Add meson build system
To: Bastien Nocera <hadess@hadess.net>, ell@lists.linux.dev
References: <20250807134859.930870-1-hadess@hadess.net>
 <20250807134859.930870-2-hadess@hadess.net>
 <5939828972792a22be2680c6b2bf377f1cd0d437.camel@hadess.net>
 <bd05acb2cb6bb96ff13d1c82b0fb2d28c199a843.camel@hadess.net>
Content-Language: en-US
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <bd05acb2cb6bb96ff13d1c82b0fb2d28c199a843.camel@hadess.net>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi Bastien,

On 8/20/25 4:02 AM, Bastien Nocera wrote:
> Sorry to nag, I'd really appreciate if you could review and merge this,
> as it's blocking any further work on bluez.

I personally have nothing against taking this in, but Marcel is the one 
maintaining the build system, so I'd need his ack first.

Regards,
-Denis
