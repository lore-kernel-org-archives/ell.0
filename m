Received: from mail-oa1-f54.google.com (mail-oa1-f54.google.com [209.85.160.54])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A0BFE6D24
	for <ell@lists.linux.dev>; Mon, 19 Sep 2022 18:59:37 +0000 (UTC)
Received: by mail-oa1-f54.google.com with SMTP id 586e51a60fabf-127dca21a7dso707293fac.12
        for <ell@lists.linux.dev>; Mon, 19 Sep 2022 11:59:37 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :from:to:cc:subject:date;
        bh=B+3/t8VUGQ4jhnwQ8rj13Qzxg+ACLHtAjQI6nMdSLS4=;
        b=XOR7+bsXCohE4luTsJg8jMw7NBwXZTSErMKYvFepcSwl8a59lTpIMzFVJrgCDP7qSK
         hbBq0A0viacaxGFNGKUS30fuDgU6yGaAS6Ax3KaVtIjLVo9FweugYO25/NrMUX8w6/Zk
         MdgQa2UROmIJuQJlDo2eIl+8XXfjB3gVdgruyauYDvUeUNIrJNiHcLz8+paSQW0vfvai
         9v32Q35oTDU9hr44M1MQYhqAqyNowJqe965qpK3ICpY/Icf6izAA2YDVJEFZ1FcGSjGG
         yGLRyLe0SVEc3/8p5Ewfxqkqgs3oNpILTIvdw1uGTkpqbcyK5EEbudbAPnSotGXB+24N
         867w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date;
        bh=B+3/t8VUGQ4jhnwQ8rj13Qzxg+ACLHtAjQI6nMdSLS4=;
        b=jSwIRBQPD84MC4QaNLbpjakdFDH+WypIZA8tuqdMRsjYOStZ4R+OYJ+PtlllDxiyMV
         ysNz+lbBPNbtyLyPCzeQQFZtmYw42QbSJ+XgFdI34g/SjeY9QcICqPPpUIxrF+7inT4P
         OGub2HOrWCb5JVePbSpg3rIR73j85XBBVRXrq5AhuwnQJVczG2UuyQDFezUq0TiZw/0d
         +GDiWIfdstJ4YYXajDJsZbLPV9ZCxhsCfAB98pA9J7TKIARYeyRszWj9csGiDrDkpvPs
         ZG7k1JZE3A3tTK8lbTax1e97iTDIWaHTxudcvG25bvTaplVZ02xiDN5ajxFw4FkEMeIe
         Vkxw==
X-Gm-Message-State: ACrzQf0t92G/4p46/WU4VkK9Upv8E0otv+HsaW/lEzgOww6dpHOvQDKq
	khOnHTopZNukSvFnhF42h6CtIuivl/s=
X-Google-Smtp-Source: AMsMyM7nNcs2TArCvSAMWOotzn6VAA6PeylBv/zRIliTpuQy0xWx1caZcCobytNQfrBSc2gwdFq8nw==
X-Received: by 2002:a05:6870:461a:b0:12a:e54e:c8a2 with SMTP id z26-20020a056870461a00b0012ae54ec8a2mr10736709oao.252.1663613976608;
        Mon, 19 Sep 2022 11:59:36 -0700 (PDT)
Received: from [10.0.2.15] (cpe-70-114-247-242.austin.res.rr.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id x31-20020a056870b41f00b00127c03b39cesm8075921oap.35.2022.09.19.11.59.35
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Mon, 19 Sep 2022 11:59:36 -0700 (PDT)
Message-ID: <393c900e-f48c-d397-8388-51e5ca25050b@gmail.com>
Date: Mon, 19 Sep 2022 13:43:06 -0500
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:91.0) Gecko/20100101
 Thunderbird/91.11.0
Subject: Re: [PATCH 7/7] netconfig: Control optimistic DAD
Content-Language: en-US
To: Andrew Zaborowski <andrew.zaborowski@intel.com>, ell@lists.linux.dev
References: <20220919133105.3129080-1-andrew.zaborowski@intel.com>
 <20220919133105.3129080-7-andrew.zaborowski@intel.com>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20220919133105.3129080-7-andrew.zaborowski@intel.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi Andrew,

On 9/19/22 08:31, Andrew Zaborowski wrote:
> Enable or disable optimistic DAD for the interface using /proc.  Add
> l_netconfig_set_optimistic_dad_enabled() for the user to request that
> RFC 4429 optimistic DAD be enabled.  As recommended in the RFC, we'll
> only actually enable optimistic DAD for the automatic address generation
> methods and disable it if a static IPv6 address is configured.  The
> default if l_netconfig_set_optimistic_dad_enabled() isn't used is to
> disable optimistic DAD always.
> 
> Optimistic DAD can shorten practical IPv6 setup time by an amount on
> the order of a second by allowing the link-local address and the global
> address to be used immediately after being generated.  For the
> link-local address this means that DHCPv6 may start sooner and
> for the global address, which is added to the kernel by the
> L_NETCONFIG_EVENT_CONFIGURE event handler, the user can start
> establishing connections sooner.  With DHCPv6 and some luck the two
> savings may compound, with SLAAC only the global address's DAD time
> should matter.
> ---
>   ell/ell.sym     |  1 +
>   ell/netconfig.c | 49 ++++++++++++++++++++++++++++++++++++++++++++++++-
>   ell/netconfig.h |  2 ++
>   3 files changed, 51 insertions(+), 1 deletion(-)
> 

I went ahead and applied all patches in this series.  Question:

> @@ -1724,7 +1737,8 @@ static void netconfig_ifaddr_ipv6_added(struct l_netconfig *nc,
>   	struct in6_addr in6;
>   	_auto_(l_free) char *ip = NULL;
>   
> -	if (ifa->ifa_flags & IFA_F_TENTATIVE)
> +	if ((ifa->ifa_flags & IFA_F_TENTATIVE) &&
> +			!(ifa->ifa_flags & IFA_F_OPTIMISTIC))
>   		return;

This implies that we set the link local address even if it is still OPTIMISTIC. 
  Do we now need to update icmp6_send_router_solicitation() logic to make sure 
we do not include SLLAO from optimistic addresses?

>   
>   	if (!nc->started)

Regards,
-Denis
