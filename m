Received: from mail-oa1-f42.google.com (mail-oa1-f42.google.com [209.85.160.42])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DDA5C320E
	for <ell@lists.linux.dev>; Fri, 28 Oct 2022 18:27:47 +0000 (UTC)
Received: by mail-oa1-f42.google.com with SMTP id 586e51a60fabf-13ba9a4430cso7174394fac.11
        for <ell@lists.linux.dev>; Fri, 28 Oct 2022 11:27:47 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :from:to:cc:subject:date:message-id:reply-to;
        bh=nSs2IGZpbxHkklp/hbllIH6ek0EasUwNotfGeydKi/k=;
        b=S1FOq0HvNqLXyfN+IuXAEQ4CVP+0gdnUMnUX08yOib2RXXUYHBKtzHHL52fWfdnTfW
         V058h5Tw40zUFvVu+5ZZsSwP93U1rzvh8+mK8XHLlJz8toCEJd8yV6KD9Z9hYOQBTXqS
         610ZyynFflXj2kRR93Dp6PAootg+EPyvCfgaZyAIofTVX/x9kOiOL0EyrPV+1S3DOzto
         kEUVK/BSX8FNUlCuKrfqdjyqNrZqgVvJE9fceVYdHAbFcl72Oaae4o9qg7m4zWVayhiu
         XQc79aBr5PYXUYJHZpeDkYiKkLhD77yU0+qIk9fVSKfWJ4VH7v0E+mAjwZ4UU/v3fANK
         LfJg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=nSs2IGZpbxHkklp/hbllIH6ek0EasUwNotfGeydKi/k=;
        b=EEfhJEE7rcr9xBlNlpAAhEDehJmSvgVuv4Ai3uM/arvM+fF5nWPz1iLO7T7+5Lz4Ce
         WlRLNmVKv5u7YxsBqMCyxCMQLpK8Tap/jCA4pkoliNaTT1n6y3STNdSIoRfKQXIlWaAz
         K8Za+CBI2V44YFmFymcHOtRXXBJDYJudxAyud/u0fabT3uHyYK7k73LzemsmoFsPG+zG
         Gh/8kFKt/cDvRTWakE3ytfLcuIJVendf7UFwGvu1eGg49rJvJ50qCnLHp4g4Wa2GIZSa
         6UCcqfWz0oOHVImFeKx6t8bU92DZ5yK+D2bCGCLz/SOYTljtkoL27q7V9illYrc0OxOt
         3slg==
X-Gm-Message-State: ACrzQf000OdEgVsZkkQZzwMoZ3x8xSCt5A/jrWt0bS3+kynIieenQDqM
	iwQZGxZ50bQuRwC1ptCTx0M=
X-Google-Smtp-Source: AMsMyM4FYXxHR7bEABTm3DFWO5exM2zfm7+x9l07X721CzY26FGw4SCJtUkp0OJyQsLsDcUt0pvZKQ==
X-Received: by 2002:a05:6870:328e:b0:13b:9374:c5f0 with SMTP id q14-20020a056870328e00b0013b9374c5f0mr9750439oac.253.1666981666976;
        Fri, 28 Oct 2022 11:27:46 -0700 (PDT)
Received: from [10.0.2.15] (cpe-70-114-247-242.austin.res.rr.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id r65-20020acaf344000000b00354948e04e4sm1768751oih.2.2022.10.28.11.27.45
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Fri, 28 Oct 2022 11:27:46 -0700 (PDT)
Message-ID: <32e16d0f-dbb1-d14a-370f-a499b200cf41@gmail.com>
Date: Fri, 28 Oct 2022 13:27:32 -0500
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:91.0) Gecko/20100101
 Thunderbird/91.11.0
Subject: Re: [PATCH 1/6] time: Add time_realtime_now
Content-Language: en-US
To: Andrew Zaborowski <andrew.zaborowski@intel.com>, ell@lists.linux.dev
References: <20221026131558.2393488-1-andrew.zaborowski@intel.com>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20221026131558.2393488-1-andrew.zaborowski@intel.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi Andrew,

On 10/26/22 08:15, Andrew Zaborowski wrote:
> ---
>   ell/time-private.h | 1 +
>   ell/time.c         | 8 ++++++++
>   2 files changed, 9 insertions(+)
> 

All applied, thanks.

Regards,
-Denis

