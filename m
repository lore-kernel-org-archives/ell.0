Received: from mail-oa1-f43.google.com (mail-oa1-f43.google.com [209.85.160.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4F58F7462
	for <ell@lists.linux.dev>; Tue, 20 Sep 2022 15:22:38 +0000 (UTC)
Received: by mail-oa1-f43.google.com with SMTP id 586e51a60fabf-11eab59db71so4657211fac.11
        for <ell@lists.linux.dev>; Tue, 20 Sep 2022 08:22:38 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :from:to:cc:subject:date;
        bh=Y6XQTOGcUwqqMN1CfQ0xDy5MLI2GxRnDGIuHSNfO2Jo=;
        b=LBH6ZYu1B+k/nB9aYkfdADQ5HeUE5ngmlu97EUNYT5Zc177o0vMI2qBSn+3MfCRjV6
         GPjYff9VRDUXZXSnwmghvwIzAorzFKbJg6qXxTXgU1bszI2jFqodmkqTqh9bswboZF33
         rwkQRMGiiqw8ZaSVHxBXq1il0pINMrs0Z237l3FFc41s8qg2GTFEoR23tI0OUDPsIPmh
         xpHdXJA4qpque0zSdskSDBJs2MUwEZadLEHCnwf6ILwEP1Qnqb6BcLpnhSVWv0vTrA42
         QLwni6BulrZpXTKGCnY7djLGKHpTXvQDIOrlSyxoPTvVfLNi7wdlM60RkYzaOIUvgZNH
         uSTA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date;
        bh=Y6XQTOGcUwqqMN1CfQ0xDy5MLI2GxRnDGIuHSNfO2Jo=;
        b=GrtWzO9gkU1oSiZJeODAKAdUJDM1WLV08xkcTCtFXoVlhKfMUyiangdEUQY8wO3wR9
         kbvpApvRVGCavGvbaP9dbPCHxcln1vTubHVSORnxC/n/viF94+0H9oijyVX8nHfHQxWf
         YlmrX8tzG5PGfTSjeXX1IDQ5qgnmBNfyOvLnx1hOG9fmEaFELi4Ylc7nsWVUX4NrOkZE
         xcDwJhDtjWkr2nxZ5ixF0yboT6AXqDcS0gV3i3RlwdLh+7pcGYkU1ncoGYjL69476YVp
         kq1F5frDFn4AE3rrI3kSrnOcr7+XpQQI82VDDT0hospzpYj0ZB63B3V853WQg0wae3oX
         pUaw==
X-Gm-Message-State: ACrzQf3lTl+Fk95pYP8KfGYrECvtI5dBrkdqyQfTC7fRV4K/1sukc15h
	UO0Fsowm2wsXNoY4579kdXRyNUuWgh4=
X-Google-Smtp-Source: AMsMyM5YQHr3Wl2NkY7RSxgVI1T87BOG6e7faxfnCuaQ7pS08AGwt/mIAnxeJeJcR9kVfwr6LMuoqw==
X-Received: by 2002:a05:6871:291:b0:128:4c:b207 with SMTP id i17-20020a056871029100b00128004cb207mr2329492oae.65.1663687357196;
        Tue, 20 Sep 2022 08:22:37 -0700 (PDT)
Received: from [10.0.2.15] (cpe-70-114-247-242.austin.res.rr.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id r11-20020a0568080aab00b0034f763a9650sm23032oij.20.2022.09.20.08.22.36
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Tue, 20 Sep 2022 08:22:36 -0700 (PDT)
Message-ID: <fda107ac-b988-408e-9c58-ebca4f57b518@gmail.com>
Date: Tue, 20 Sep 2022 10:06:01 -0500
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:91.0) Gecko/20100101
 Thunderbird/91.11.0
Subject: Re: [PATCH 1/6] net: Allow padding in net_domain_list_parse
Content-Language: en-US
To: Andrew Zaborowski <andrew.zaborowski@intel.com>, ell@lists.linux.dev
References: <20220920133201.3303119-1-andrew.zaborowski@intel.com>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20220920133201.3303119-1-andrew.zaborowski@intel.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi Andrew,

On 9/20/22 08:31, Andrew Zaborowski wrote:
> The domain name lists in ICMPv6 options may be 0-padded meaning that a
> 0-byte at the beginning of a domain record (ie. a domain with no labels)
> is allowed and should be treated as the end of the list.  Add a boolean
> parameter to tell net_domain_list_parse() whether to allow this.
> 
> Fixes: 4b1ce9b3e3d0 ("icmp6: Parse RDNSS and DNSSL options")
> ---
>   ell/dhcp6-lease.c | 2 +-
>   ell/icmp6.c       | 6 +++---
>   ell/net-private.h | 2 +-
>   ell/net.c         | 8 +++++++-
>   4 files changed, 12 insertions(+), 6 deletions(-)
> 

All applied, thanks.

Regards,
-Denis

