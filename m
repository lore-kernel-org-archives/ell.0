Received: from mail-oa1-f47.google.com (mail-oa1-f47.google.com [209.85.160.47])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 229B93C0A
	for <ell@lists.linux.dev>; Mon, 18 Jul 2022 20:24:57 +0000 (UTC)
Received: by mail-oa1-f47.google.com with SMTP id 586e51a60fabf-10bffc214ffso26945801fac.1
        for <ell@lists.linux.dev>; Mon, 18 Jul 2022 13:24:56 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=message-id:date:mime-version:user-agent:subject:content-language:to
         :cc:references:from:in-reply-to:content-transfer-encoding;
        bh=kX6Q6oNawEZnrf8E2/JXgf4JEZBPfvgGohfjyvYvZCA=;
        b=dR80BAc6LWedAzDgMOnwVomyjIpSKe4aTydkKcX09uQuM1Y4oOVkYzl0TFdghv/gKB
         FQ253d4WUg/zsaS6KFGFqBKd+FX/HjQ58qKBCMi91C/ckt6NEWf+Sr+LIvR8G0m+wcak
         qse9OUpcUaa8EfNzXwIJZ9gqpWxkcknMMxcA/Y5dnkP0AYnf+uh6PNk6dkcDp6QZ2vdo
         Ejuxq7SCiwr1GfjOcFWs9Tcsgs/NKb19q4PGc9Gxd+e2DOFSOytcrmESA6YBvXfZCpPj
         rUUk707jKoOvV79YQoo1AzSs1nhA+LuCIlaXckkX6WuRlfwRzMyxzPiY+pHsZVLyUAHj
         b4Bg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:message-id:date:mime-version:user-agent:subject
         :content-language:to:cc:references:from:in-reply-to
         :content-transfer-encoding;
        bh=kX6Q6oNawEZnrf8E2/JXgf4JEZBPfvgGohfjyvYvZCA=;
        b=RYQ7K6bnMuo2VI/4Dg8cktIp7oLTuA9Qhrj2xE09E0YUfSD/iw2uZ9Rg90bQGYEyVx
         eNf6iis73VX7G2Q1gp2q/hDqWWIWvCdXBJ9XrLAIK8VwUvr+cIDoHrV0nnNCeaq2f0CF
         yOcNLloTOJrUQmrAUPnjTFfM+u0bFA40INuwVWo2Om2bmNq4q1Cz6Fs9/Xb4/lXznRaW
         UwmxDjrC66Oy1aevgiPSA3dTQIPpoVqMtrcncYzlzcSwxAX+7X4odlS/ZNZCqkBlZy6p
         iYCNl1H0xFeFnMbf5nUvlBt3+tyLLelqpjhPhfsWfXsWsVVQPjFAD7lx44Zwy3erF/8W
         YXqw==
X-Gm-Message-State: AJIora+2ww3HG35oWK5wVJZcSZU+y2LeIPnsvrBvKJnFL98kCReIqAMF
	7/lg4e5hZuEc/LDCAMgjopqBL7Ra4kU=
X-Google-Smtp-Source: AGRyM1ux8UFeyHl0vWjqU38YHRryyAIAmmerBSB7HqnmRq5Hk+/x6Ec1in2WVi3oqFw3RgRsEJr/9g==
X-Received: by 2002:a05:6870:808d:b0:10c:7b97:8da5 with SMTP id q13-20020a056870808d00b0010c7b978da5mr19137039oab.70.1658175896094;
        Mon, 18 Jul 2022 13:24:56 -0700 (PDT)
Received: from [10.0.2.15] (216.106.68.145.reverse.socket.net. [216.106.68.145])
        by smtp.googlemail.com with ESMTPSA id d7-20020a056830138700b0061c94e755d8sm2833547otq.58.2022.07.18.13.24.55
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Mon, 18 Jul 2022 13:24:55 -0700 (PDT)
Message-ID: <83e13273-5c51-815c-99de-6517a42e0b5b@gmail.com>
Date: Mon, 18 Jul 2022 15:21:50 -0500
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:91.0) Gecko/20100101
 Thunderbird/91.11.0
Subject: Re: [PATCH v2 02/10] unit: Add basic EC-DSA verification test
Content-Language: en-US
To: Mat Martineau <mathew.j.martineau@linux.intel.com>
Cc: ell@lists.linux.dev
References: <20220718180045.5845-1-denkenz@gmail.com>
 <20220718180045.5845-2-denkenz@gmail.com>
 <559e999-ea7c-cab2-1327-d37b2c36e713@linux.intel.com>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <559e999-ea7c-cab2-1327-d37b2c36e713@linux.intel.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi Mat,

> A few typos here: "ce-cert" instead of "ec-cert". This showed up as:
> 

Ok, I fixed this in my local copy now.

> 
> Other than that, v2 looks good on my system. I didn't try out the kernel patch 

Excellent, thanks for testing.

> you mention in patch 1, I assume that's why I had the test failures with 
> "tls-suites: Add ECDSA suites from RFC 8422".

The reason is that kernel upstream only supports signature verification and not 
the sign operation itself.  Not sure why.  I'll try to fix that eventually, but 
for now we're limited to ECDSA use in anonymous client mode only.  The test 
assumes that both client + server side is implemented.  Hence the need for patch 
8/10.

Regards,
-Denis
