Received: from mail-oa1-f51.google.com (mail-oa1-f51.google.com [209.85.160.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D56F9111B
	for <ell@lists.linux.dev>; Wed, 22 Jun 2022 20:52:20 +0000 (UTC)
Received: by mail-oa1-f51.google.com with SMTP id 586e51a60fabf-101bb9275bcso19101097fac.8
        for <ell@lists.linux.dev>; Wed, 22 Jun 2022 13:52:20 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=message-id:date:mime-version:user-agent:subject:content-language:to
         :references:from:in-reply-to:content-transfer-encoding;
        bh=j42sLRv2XRPH5LNbPRQ84BcuRSWg0KKL8YxAL+qLo+M=;
        b=P/GwDw7SzcPvr90FAo90U4YrNMUUpa5RogpO1Utn1T55F9rDM8WNAgGz3db6gaI/Y9
         aWLcPyiR7Vc8VOa/7aU76sNswXi260POx3nvt+OaniYcYCRhW2gPJAYJOzK0n09bjnqW
         Z+8cGFjGSxTFAWF8SgHrQuBKD0hoM2SYR2pmAPj/47kfLfcyGSDemM1PwKq9Q0pRyksD
         0qUoEBGRuDno5lshNWfkrfEUDufoclkZ+Rkkl5e5DlaAebvzmgVCaUvZA6YkKtYRDtgR
         Fbg80jVjloKVYBUjP6q/WZt9GumXAoZ1QJ7SOEizP7byxyovzIA3lw9Bth24SmmVB2+v
         LS4g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:message-id:date:mime-version:user-agent:subject
         :content-language:to:references:from:in-reply-to
         :content-transfer-encoding;
        bh=j42sLRv2XRPH5LNbPRQ84BcuRSWg0KKL8YxAL+qLo+M=;
        b=TU4ynvyYOoXzXdjxuWgcSPok4wW+kpzMFLAaIe1Yn/oWJicALs+BwtUNJwjZjm9GRt
         WySOMA16V+CfOHlQ2T5Nll0wySWwDdV/IYhWpzOe7vCgV9DlB+Hc5GbIFByjG7AA47Pl
         qts6ZHI1YyeJ7nA5rgxCrrOnoZobE66OP4Do+Kit3sGS0wgfZXIjw5eOcj+Q7QDNbbgC
         1vh2CmZESzZsNpPm+E/L6AecC2oVtaAD/6U38EKDBUMGjpKXiuWcidjQ8wZwzs5j6DOz
         +n6oFfOQCCNrltZPqq6C43sk3CQd9FZkH3vhF6qGCOHGzwuO4Yc+cTKDsLdHUNU4fFdI
         Pq5A==
X-Gm-Message-State: AJIora+W7yTiBnjSavWWLzY9zoaEw1VQAGWBegV30TJxbo+YX9Q/qdLx
	t6bRAPzRJ5c21NgIz0BQDDlUdZsXUyizffFh
X-Google-Smtp-Source: AGRyM1u07U6aygKF+5HSd/y0HyxIh1JCCY3VUjUGbW5yucOg7zQArrfJjlVKB4GQpNG7VNKgTCxJ/g==
X-Received: by 2002:a05:6870:701f:b0:101:a5bb:5356 with SMTP id u31-20020a056870701f00b00101a5bb5356mr159873oae.81.1655931139831;
        Wed, 22 Jun 2022 13:52:19 -0700 (PDT)
Received: from [10.0.2.15] (cpe-70-114-247-242.austin.res.rr.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id f91-20020a9d03e4000000b0060c00c3fde5sm853801otf.72.2022.06.22.13.52.19
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Wed, 22 Jun 2022 13:52:19 -0700 (PDT)
Message-ID: <33517b5a-bea7-1553-c125-afe9d26deaa5@gmail.com>
Date: Wed, 22 Jun 2022 15:49:53 -0500
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:91.0) Gecko/20100101
 Thunderbird/91.3.0
Subject: Re: [PATCH] netconfig: Add getters for DNS addresses and domain names
Content-Language: en-US
To: Andrew Zaborowski <andrew.zaborowski@intel.com>, ell@lists.linux.dev
References: <20220622005714.2319560-1-andrew.zaborowski@intel.com>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20220622005714.2319560-1-andrew.zaborowski@intel.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi Andrew,

On 6/21/22 19:57, Andrew Zaborowski wrote:
> ---
>   ell/ell.sym     |  2 ++
>   ell/netconfig.c | 73 +++++++++++++++++++++++++++++++++++++++++++++++++
>   ell/netconfig.h |  2 ++
>   3 files changed, 77 insertions(+)
> 

Applied, thanks.

Regards,
-Denis

