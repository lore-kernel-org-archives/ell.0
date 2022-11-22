Received: from mail-oi1-f174.google.com (mail-oi1-f174.google.com [209.85.167.174])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 793E4107A1
	for <ell@lists.linux.dev>; Tue, 22 Nov 2022 17:22:24 +0000 (UTC)
Received: by mail-oi1-f174.google.com with SMTP id v81so16521970oie.5
        for <ell@lists.linux.dev>; Tue, 22 Nov 2022 09:22:24 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :from:to:cc:subject:date:message-id:reply-to;
        bh=U9LsIv61Kz0cq+c63AQGQTOMfUg7v7uEYxaoow9J43k=;
        b=jPTBc0drFnZqWe7LPTzr34liYqlI1j1uQI6E3qW8UDkXwBDcBDAbmZ2L/K8NkT1x+q
         2nLPDwYwzb1NF7agufJe/GjhTqqFxXRRRkoqihAE6MK/SqO4PitjGhyYMTapCQIMUHJs
         QuRsGu0H+1ptnpf96p8jmhrCJlCyCuwKPqonJ//EY6jMe5z2FFl/TAEmysbPI544WyWa
         DysK/forDSr1FUJsSzCpIBOgK0Rfw5jwv6NbXld95ERoMSnvj3JN0g1xcBUk80xwCz97
         AoZjCffnSR4j3/EJ/rvxAUeSIMbM+yHU7bBGWwv2RCjZ1Vpl37Ywa49ZL7HYWixsNbku
         l1OA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=U9LsIv61Kz0cq+c63AQGQTOMfUg7v7uEYxaoow9J43k=;
        b=0pdqRrOEtDfQ6ycP7oyM59LuQQfbHPpEuyOdA+AVwPIN8t9fQCuwVnbWHxvfdJhIX7
         KCcQVULcAmAp+NB9QorGEUNTdTq0iivzUxGxU10QmpXS/Jt+90IGxH1cMxREjoNKt23O
         W4s1iARb92PbejfK/HdxN3YW6fIG4duIq75FlMxZ3ospflDQgJ6nbecJxFt+SHWcrCgl
         cMu+Y+V0BtRX2yGMG6EcoYbm9YqevtGF+G3bcThMOMfZpUNHu2sLbaH/tSXQD7PLihNm
         bE5K5rkrG0Zoq03n7wSpcdkpsObBYc3FHAvrZx1afB1W/PmbiHrwTcyzybroDt8AyHuB
         bQfQ==
X-Gm-Message-State: ANoB5plYmKDwuQgJQQ22Z/zoEg4a0j1nZ46yYCTcIEldCRFtPVSumRcp
	yoaC4kKGuVeVgl7nLaBYgIc9ihW70Mw=
X-Google-Smtp-Source: AA0mqf4+OpwIKJe+Him3UkpX4+agDp5yB3Ag2SHAvjE0QZHcQsuPNMhorGohv43CX0A5ox1LJAYvng==
X-Received: by 2002:a05:6808:22a5:b0:35a:3da7:e8ce with SMTP id bo37-20020a05680822a500b0035a3da7e8cemr11355585oib.190.1669137743577;
        Tue, 22 Nov 2022 09:22:23 -0800 (PST)
Received: from [10.0.2.15] (cpe-70-114-247-242.austin.res.rr.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id e35-20020a05687023a300b0013297705e5dsm7845378oap.28.2022.11.22.09.22.22
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Tue, 22 Nov 2022 09:22:22 -0800 (PST)
Message-ID: <ba521a25-fd9b-189c-a607-02cd897cae32@gmail.com>
Date: Tue, 22 Nov 2022 11:09:20 -0600
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:91.0) Gecko/20100101
 Thunderbird/91.11.0
Subject: Re: [RFC 1/8] key: add l_key_search
Content-Language: en-US
To: James Prestwood <prestwoj@gmail.com>, ell@lists.linux.dev
References: <20221118211624.19298-1-prestwoj@gmail.com>
 <20221118211624.19298-2-prestwoj@gmail.com>
 <f4f33ae6-ba6f-e19a-89cb-6ba5c9a101f1@gmail.com>
 <176cde43f3fe383fbb096eeb3b4f7be8b212a19f.camel@gmail.com>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <176cde43f3fe383fbb096eeb3b4f7be8b212a19f.camel@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

Hi James,

>>> +LIB_EXPORT int32_t l_key_search(enum l_key_type type, const char
>>> *keyring,
>>
>> How likely are we to search some custom keyring?  Wouldn't we
>> generally be
>> searching a user/default user session keyrings?
> 
> I was just leaning on the side of flexibility. I don't really care
> either way but figured an extra argument was fine even if we end up
> calling it with "user".

So this function would perform some sort of !strcmp conversion between "user" 
and KEY_SPEC_USER_KEYRING?  That's fine I suppose.

Alternatively you can ignore that for now and if you really need to search 
keyrings that are not "standard", then one can introduce l_keyring_search() or 
something later.

Regards,
-Denis
