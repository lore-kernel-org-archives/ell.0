Received: from mail-oa1-f50.google.com (mail-oa1-f50.google.com [209.85.160.50])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 92C731519AC
	for <ell@lists.linux.dev>; Fri,  1 Aug 2025 18:32:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.160.50
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1754073161; cv=none; b=qV3nf15XayFqFgWHYQjnzhV+h0lyiyRXqDMB84ZNGKZhQuzbxhniZBOz8murqYuXfHCsdE8E2HKiMViX0/bF7C3hNusb8wRgCa7eMAK8Kd25sZ9gyQ7S4lfvufEOj66W3qC+JO2hL3xuLFt9lIb+T2hpNq/6gNOs4TNZIWqyVug=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1754073161; c=relaxed/simple;
	bh=H+Y3XZwpeoofsefwxanbaiDPXDUkc8QAEoCVVKHptUU=;
	h=Message-ID:Date:MIME-Version:Subject:To:References:From:
	 In-Reply-To:Content-Type; b=gxAzE5Gs/4nIGBA7Nci2R6dAyq9u3/LKGh//BFm64jJuxF/bOit6WAYHzXR76GA8dq+rQ/RzLLfpAHP10kcNHQP8eCZl+ZIKb8TEWVWvjNYINGmRF1EyThGVy/BQjMLZKxxj4Ds/uYg1ACKwOKQGWdrJEqtBd6OLfd5qUHD5cGg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=fFnT5vf4; arc=none smtp.client-ip=209.85.160.50
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="fFnT5vf4"
Received: by mail-oa1-f50.google.com with SMTP id 586e51a60fabf-30063371404so659063fac.1
        for <ell@lists.linux.dev>; Fri, 01 Aug 2025 11:32:38 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1754073157; x=1754677957; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id:from
         :to:cc:subject:date:message-id:reply-to;
        bh=HVacVXx0yY8XSckju5TU+5ok7YFNlW/Lv3Z6aLoPFEQ=;
        b=fFnT5vf4ag02LLC22QKadudpLQCsNle3TSlCCVrtZEaAbzcRXLq17xrKz23w+g//ua
         8T2gm1UAxcjf88p3aNJMAHQFECLMqZprVeK8fn7CN5ms+5dEg1icBXzeMbKw+zgh2VWP
         lIT5pTSUYThnWPLlFMTyRUcrx/IPWqEO4+3CSk1f/MdW5K++pfgcg4CUYlQQ2sdRI7bt
         +X+1ABXNtYHrOZpdBAijdNdh8aPLVZ980VwN5U5fzw+3J3Vzq8G9fin/vlGEpiLLg9no
         KejFPaWiMGJCpJNh2gdTNWPUoefdnrb88IrdIagUgpYg2VZudUYAn9/s18fEaSo+7tjw
         CioQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1754073157; x=1754677957;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=HVacVXx0yY8XSckju5TU+5ok7YFNlW/Lv3Z6aLoPFEQ=;
        b=K1iGdUXiafVnUfLhqca4QNV15cOLun+iU4GRyUsR56RF+UtzM13BGOBkoglol6y8eF
         NdUr6QPKAnGqLwg1JKjtI1jUcf0ncFvARniyictB1zApvHIqBXje+WeB/wYF/26RtN2S
         SKI+LagqkYy5ALcNw500nAGnVzjI7sCW66fAct13nlDsTHARFAMwG0KWRgahnal3kKk1
         BiPk7mtwme3ZaiMMgJZgTn6t3xuW4A7QFtJF/IaTXhqvb2mbRWeYta6zRMDCeSQHYshN
         TMC1ZpvMuOsqwDRTyXpAReZWPSJybsbOM+TxLswp74eqTLx7dgrc6Jg+5fQlUaDDCBpk
         L6SA==
X-Forwarded-Encrypted: i=1; AJvYcCXHzGJMrk0pYMIASa4tGmws37Ic5JgO+pi7utixrbMoAHw5QMb3LfrSwAB1ITOVB95Eecs=@lists.linux.dev
X-Gm-Message-State: AOJu0YyOLOkIy6eS/91bPpqrdIFjJDpU9q8zgx6xaSsflwTdi/q+IW+8
	HXvg63YKvRPzbCFafSyZcU5Gf+/R8UrUlI+48RWhae7GzxPhBdU4DD8bIzmLiw==
X-Gm-Gg: ASbGncunq/TAyZVrIFcv6jRAPaD+ncD3HpLzYXnxxyvDZutPQadjhUQJNbtG9o96QuQ
	hdJJUnIkDkZ9zP6Po/QWlb1b8aML3Xkkwlc/rD/c/Jr70sGOrc8hqciN0ZlNvyPVLSzyuvnnmjH
	nxrvnQOjLzFgz+e1XdGx8Bkn/cbmM77TcmowZTHz+EGy+AI32s5Kx2bp6IEq0gRC7wRsLTyN06k
	ThelbNLcjzUULfLsguS8bLcMRJ8XI9XNvrpcqa81dzYVOs6p9NIiKIYTiFWXchmqOBiNJx2FdK5
	4jrfv26SUnlNmV4tj+gIdp1nKpoCy5R4VrJ05BFYbXcxf0ekHvsQDA2kxsDFn8J6K13u+VqmDQB
	cGtSrdI+x9kNoqUsqA5m+ek+vbBlyNhVjOEDAWDq5ugJb7gwC7TJadDuSObCFtRO7HunoQ96BUu
	8=
X-Google-Smtp-Source: AGHT+IF9ZGgCEKEn6w5Yvc7LQ6EZO6ZLF33FPP+33KSgFVKfIgy29SytYd4uuexBjHvtS2THeQZ20Q==
X-Received: by 2002:a05:6870:2a48:b0:307:a8aa:6e59 with SMTP id 586e51a60fabf-30b6791e094mr435340fac.30.1754073157359;
        Fri, 01 Aug 2025 11:32:37 -0700 (PDT)
Received: from [172.16.49.130] (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id 46e09a7af769-74186cc4d97sm863992a34.17.2025.08.01.11.32.36
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Fri, 01 Aug 2025 11:32:37 -0700 (PDT)
Message-ID: <264df186-6d7e-471f-b155-f5942e79cb78@gmail.com>
Date: Fri, 1 Aug 2025 13:32:35 -0500
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
Content-Language: en-US
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20250731142153.2802258-4-hadess@hadess.net>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi Bastien,

On 7/31/25 9:20 AM, Bastien Nocera wrote:
> Version 13 is the last upstream supported version. See:
> https://testanything.org/
> ---
>   ell/test.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)

I went ahead and applied patches 1,2,4 and 5.  Thanks!

For this commit, Marcel was wondering whether bumping to version 13 was safe 
enough.  His concern was that some projects (like glib) were sticking to '12'?

Regards,
-Denis
