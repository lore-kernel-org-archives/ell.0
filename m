Received: from mail-ot1-f42.google.com (mail-ot1-f42.google.com [209.85.210.42])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ECD281104
	for <ell@lists.linux.dev>; Tue, 16 Aug 2022 20:38:20 +0000 (UTC)
Received: by mail-ot1-f42.google.com with SMTP id h9-20020a9d5549000000b0063727299bb4so8188082oti.9
        for <ell@lists.linux.dev>; Tue, 16 Aug 2022 13:38:20 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :from:to:cc;
        bh=/VE4gNYD/196C+6Zs57VJqY+Te4H4kNd1xNy8mgruiU=;
        b=ZSYcx8CzSGDj4UFc+CEfIu/S6W+/vAN2WO5UkGUPRfBWRa6YcncdGP1PWhp/YooLlM
         6exEpMCUqsJ/VUpslDW0h32AlOXlheLBEJrEkIL3vCm0ndeHZeCcHnjTlPCcagRoSyrc
         M+xLATyERb0VSAZRFT8tw8Mw84Yffr1wjtV6ZQ+8o72EFRXwgeSYVt1Em1CFR6rY9myx
         okj8uDTOK3G+XzZu5QqZcF+Y1r7Mb2AOMQaF8IfGn1/ZQnJV2+4CM1Wusi4K1w163Hlp
         Gh3QTwYsj1M6Xp2JqgckOOd/KpUORZOItlMq4AZknZdSFZtH7VqB2oeaOzWliIgPAZ/E
         /Low==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc;
        bh=/VE4gNYD/196C+6Zs57VJqY+Te4H4kNd1xNy8mgruiU=;
        b=bpyZEDlwkOwyRajPMaj9MpCdkI1+JjzUOwtNCMpvJijw8f9uHcDRYs+Did0pzRFfdt
         /mF/+lvVxvqPfgAO7stcIclkDPEqxs2B77rUvA+6va4airWvZgHOox9Thps5KCZdy2tk
         LqbpdGk3V6o7mw/GkFqF4n0guyPya7sHFc6w17QfHC3VQuJsofzri9XIRNzOvRlHUk/w
         EkSWXFi9fhHGR5eInQvxA/qYDv6DPhUa++8miHVBNIlxU/jh+phQ5nFsMb4Z1JCTNRy0
         DP3tkfkPiemNFSkse9o10M7K2coQo0seFBKLDR3LbZUl9M+LS8heeKk6pYss1DfUpsVh
         Fx/w==
X-Gm-Message-State: ACgBeo2nYq5uiIRnWZvWhXzx+NOEpYvmPI1CBvOQYsbm1cOHh8oueQ8k
	r0Qfuc7suxVijAkmVD/t16U=
X-Google-Smtp-Source: AA6agR6DiHr75XrKTng7+HHA0vmE5Ep6I4L2Ye2e1xTMBhXL+0wp9NODFvu3TIfKZHtIjZKl5u6jgA==
X-Received: by 2002:a05:6830:2498:b0:638:9325:3370 with SMTP id u24-20020a056830249800b0063893253370mr5951793ots.228.1660682299884;
        Tue, 16 Aug 2022 13:38:19 -0700 (PDT)
Received: from [10.0.2.15] (cpe-70-114-247-242.austin.res.rr.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id g20-20020a9d6214000000b0061c4d5a5616sm2848472otj.63.2022.08.16.13.38.19
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Tue, 16 Aug 2022 13:38:19 -0700 (PDT)
Message-ID: <ca1010f5-ae14-6033-9740-453f383a0826@gmail.com>
Date: Tue, 16 Aug 2022 15:28:26 -0500
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:91.0) Gecko/20100101
 Thunderbird/91.11.0
Subject: Re: [PATCH 1/2] netconfig: API to disable/enable ACD
Content-Language: en-US
To: Andrew Zaborowski <andrew.zaborowski@intel.com>, ell@lists.linux.dev
References: <20220815182602.1146368-1-andrew.zaborowski@intel.com>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20220815182602.1146368-1-andrew.zaborowski@intel.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi Andrew,

On 8/15/22 13:26, Andrew Zaborowski wrote:
> When using FILS IP Assignment, the received configuration will be passed
> to l_netconfig as "static", yet we may want to skip ACD to avoid the
> overhead.
> ---
>   ell/ell.sym     |  1 +
>   ell/netconfig.c | 40 ++++++++++++++++++++++++++++------------
>   ell/netconfig.h |  1 +
>   3 files changed, 30 insertions(+), 12 deletions(-)
> 

Both applied, thanks.

Regards,
-Denis

