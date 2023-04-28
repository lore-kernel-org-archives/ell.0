Received: from mail-pf1-f173.google.com (mail-pf1-f173.google.com [209.85.210.173])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9353E79C0
	for <ell@lists.linux.dev>; Fri, 28 Apr 2023 16:09:00 +0000 (UTC)
Received: by mail-pf1-f173.google.com with SMTP id d2e1a72fcca58-64115e652eeso13639723b3a.0
        for <ell@lists.linux.dev>; Fri, 28 Apr 2023 09:09:00 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20221208; t=1682698140; x=1685290140;
        h=content-transfer-encoding:in-reply-to:from:references:cc:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :from:to:cc:subject:date:message-id:reply-to;
        bh=YUJfa6Pe3ZxTvmGSN8YZbeLWlsXh8xmPSUqb5I3KQbs=;
        b=G5akGqGtsnpyoZ6dFPwMzFa+vrQURe5Z5eyy8vME4/V9FamrdQDINfT94B74gYpAVd
         nw1Nx6LYoocrKuF1Yo0pN+UGt2AMP9HhkqIGOjmIf/Rve6Bgi/SaY/I49NyZUeMAzwDY
         B2TcirP+DBxULBugtDfJiSbUFWk4t5euxpnn+lU4sxThOQtp6WUxLj/cPGo8DPEn63EV
         /NGIMK++pPaEwG4+sui+7DEthD1y4En17QKwEPFuXDI4FfkdLsgele1WtgETSfS1xZ6I
         erHe5z2MqjBgLj+1clu3BGDtkEeuGRtUS2N3zxi5GPGkyfQD7A/mcotienAuwXB4rZAn
         s6+A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20221208; t=1682698140; x=1685290140;
        h=content-transfer-encoding:in-reply-to:from:references:cc:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=YUJfa6Pe3ZxTvmGSN8YZbeLWlsXh8xmPSUqb5I3KQbs=;
        b=i0/fDaMKFMRZCl7KdnSPmVa/rYiPYv9O0nVJ4DLjSs/IY+ukVFFz4za8qLqWr/vL2s
         loosSUVbWDBUtepVyR2pyxO/vuzRCeOF0c/BwNxRMqC6cyi8plzzQ08iIyN75Hsm6IBt
         Sq6vUQjZibVCaErrEjzVBFMm+O070avniClwltVyw0Sx33nFQTzzvF3EuTSsM7m5pSRQ
         rWCzRctdh59d7k3au5auOsf69yJt9c0Fa1RIBuiHC+jPtwOMkWbn9g3y4Q24+ZYtakKr
         9v8fjP2XGvzEbNYELjlfLlAtCqywZl+2Y88UKYXuyixnJNsYS52z8H5YITGepzGzmn0X
         /i5A==
X-Gm-Message-State: AC+VfDzDWzAdV25o2A87Uhylu2Y0PO5u/QzTy2vbPWPkUL68f6hodf7k
	Ne6pXc1tc9oVOwCkZR1Mnut/o49YcC+tMw==
X-Google-Smtp-Source: ACHHUZ6NMBKFATf7M8R/Bmx0Rozq+d3KwUMo9fMPASRUU+43M9KFV+rrm5cJoyLAQ0hJ1Ex8+Iw/6g==
X-Received: by 2002:a05:6a00:1819:b0:63b:87fd:a705 with SMTP id y25-20020a056a00181900b0063b87fda705mr7348834pfa.10.1682698139831;
        Fri, 28 Apr 2023 09:08:59 -0700 (PDT)
Received: from [192.168.254.76] ([50.39.172.77])
        by smtp.gmail.com with ESMTPSA id n12-20020a056a00212c00b0063f172b1c47sm13787376pfj.35.2023.04.28.09.08.59
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Fri, 28 Apr 2023 09:08:59 -0700 (PDT)
Message-ID: <61a363bb-62b3-01b3-017c-2f0893099e15@gmail.com>
Date: Fri, 28 Apr 2023 09:08:59 -0700
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:102.0) Gecko/20100101
 Thunderbird/102.10.0
Subject: Re: [PATCH] ell: Make public headers compilable with C++
Content-Language: en-US
To: Brandon Cheo Fusi <fusibrandon13@gmail.com>, marcel@holtmann.org
Cc: ell@lists.linux.dev
References: <20230428122025.117834-1-fusibrandon13@gmail.com>
From: James Prestwood <prestwoj@gmail.com>
In-Reply-To: <20230428122025.117834-1-fusibrandon13@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi Brandon,

On 4/28/23 5:20 AM, Brandon Cheo Fusi wrote:
> This patch allows ell/ell.h to be included in C++ code by removing
> 'only C' features. These comprise
> 
> i)  implicit casts from void* to other types which are now made
>      explicit
> ii) C99 Static array indices.
> ---
>   ell/cert.h     |  4 ++--
>   ell/cleanup.h  |  4 ++--
>   ell/ecc.h      |  4 ++--
>   ell/icmp6.h    |  2 +-
>   ell/key.h      |  4 ++--
>   ell/rtnl.h     |  6 +++---
>   ell/settings.h |  2 +-
>   ell/string.h   |  2 +-
>   ell/strv.h     |  2 +-
>   ell/uintset.h  |  2 +-
>   ell/util.h     | 12 ++++++------
>   11 files changed, 22 insertions(+), 22 deletions(-)
> 

<snip>

> diff --git a/ell/cleanup.h b/ell/cleanup.h
> index 89b1981..d2c9232 100644
> --- a/ell/cleanup.h
> +++ b/ell/cleanup.h
> @@ -22,6 +22,6 @@
>   
>   #pragma once
>   
> -#define DEFINE_CLEANUP_FUNC(func)			\
> +#define DEFINE_CLEANUP_FUNC(func, arg_type)			\
>   	inline __attribute__((always_inline))		\
> -	void func ## _cleanup(void *p) { func(*(void **) p); }
> +	void func ## _cleanup(void *p) { func((arg_type)(*(void **) p)); }

Just an FYI, we do use DEFINE_CLEANUP_FUNC in IWD:

https://git.kernel.org/pub/scm/network/wireless/iwd.git/tree/src/util.h#n131

I doubt other projects use it since its pretty new, but maybe someone 
else can speak to that? Just wanted everyone to be aware of the API change.

Thanks,
James

