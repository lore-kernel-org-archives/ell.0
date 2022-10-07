Received: from mail-oi1-f174.google.com (mail-oi1-f174.google.com [209.85.167.174])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2FA7F256D
	for <ell@lists.linux.dev>; Fri,  7 Oct 2022 18:35:20 +0000 (UTC)
Received: by mail-oi1-f174.google.com with SMTP id v134so6450647oie.10
        for <ell@lists.linux.dev>; Fri, 07 Oct 2022 11:35:20 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :from:to:cc:subject:date:message-id:reply-to;
        bh=HqSezCnzfg+Gzn8veR32PA6a1rFH4JYrHQjoy1vBT/8=;
        b=No0MMUZuHk18SX/bukjxX2UbNcTmLMx7asx1aHNoVNmOMx5HGMrgibbE6VWD25HtHw
         TdLh9P/T0ZTOXdt8bKeHZ0tu0Df9M8lDsIEB5l5G+/DF9y8j1lZq5wJzlqn0xWzgCxt+
         SB3YibvuWspSmuz4PG0zLJlxsXi2qf+1aKLMhzdpKPjiS9F8FBUoU3z7EdRDmKcgiknk
         mC6CRZVP35A0HDOvZSn0b2TChrQkEZjWHTbc0HGYWUV57OvHchBzDfAbruJdbWIuFdIu
         5glOZyToA9d3fiW31oJ81zvXcsjOTfMelld+U78E1a2mUgC2p7n17Pe5bqMvrBJbjWnz
         Jj3A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=HqSezCnzfg+Gzn8veR32PA6a1rFH4JYrHQjoy1vBT/8=;
        b=61JLwr1fePFIaznjf6qbM314lZvHslsGPsy75iHadwdZeDvdXuSk6TjqM9wd8GwCPC
         9uSs6lyARCTyl9VPK7BPD2d1+LBwZz28mZNkNjXba+PpD1Phu/wo4qjw+0JIc8Oc1hwb
         gsln5L6TUB2iNWl0/OYEum0Pe23A9/NNhCE8USWAlx9RgxIHDmi+1ovDCWzGKjVHIdKk
         ubwMq9jO1yyZtUx6z222Tzlei9NTTOqbWnQsuP67BMEE77P3ICFhjPsBw06TQ8OzuE80
         JEojHIFyGKD68nnywJJyBW6MMgALHMKQzPU42SvdkaKcvYuJaftVUtkX2vrfcHsPiV+4
         hV2Q==
X-Gm-Message-State: ACrzQf065LoEEIx5ZbYUb669CttpGZlSMpSCrohFMXQOyJOjnuVKcXLj
	uCIqPPPLQ3qKjFGkckxNaZY=
X-Google-Smtp-Source: AMsMyM6JPh/GLmcpftSe69jUuVCFemx9am4nGzzv17HQyjuOksrc5bCkDOH8AH78TH6ZCj/RV0GcBQ==
X-Received: by 2002:a05:6808:1827:b0:354:ee3:30b2 with SMTP id bh39-20020a056808182700b003540ee330b2mr3280839oib.43.1665167719260;
        Fri, 07 Oct 2022 11:35:19 -0700 (PDT)
Received: from [10.0.2.15] (cpe-70-114-247-242.austin.res.rr.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id i9-20020a4adf09000000b00476989d42ebsm1246526oou.8.2022.10.07.11.35.18
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Fri, 07 Oct 2022 11:35:18 -0700 (PDT)
Message-ID: <5bc2423a-55bf-3503-12ff-82d1374994da@gmail.com>
Date: Fri, 7 Oct 2022 13:35:17 -0500
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:91.0) Gecko/20100101
 Thunderbird/91.11.0
Subject: Re: [PATCH 1/2] netconfig: Set preferred lifetimes on DHCP addresses
Content-Language: en-US
To: Andrew Zaborowski <andrew.zaborowski@intel.com>, ell@lists.linux.dev
References: <20221007180209.1069526-1-andrew.zaborowski@intel.com>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20221007180209.1069526-1-andrew.zaborowski@intel.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi Andrew,

On 10/7/22 13:02, Andrew Zaborowski wrote:
> We receive one lease lifetime value for a DHCP lease so we were setting
> the preferred lifetime for the RTNL address to 0 and the valid lifetime
> to the lease lifetime.  If either value is non-zero rtnl.c will send
> both to the kernel and the 0 preferred lifetime is treated as literal
> zero and the address becomes deprecated immediately.  This doesn't
> matter for most usages but systemd-resolved would check whether a link
> has a non-deprecated address before setting the link's
> "unicast_relevant" flag and internally wouldn't create a DNS "scope" on
> the link or set its "DefaultRoute" flag both of which are required for
> it to want to resolve names.
> ---
>   ell/netconfig.c | 4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
> 

Both applied, thanks.

Regards,
-Denis

