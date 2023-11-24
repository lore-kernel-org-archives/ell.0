Received: from mail-oa1-f49.google.com (mail-oa1-f49.google.com [209.85.160.49])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AF411364C1
	for <ell@lists.linux.dev>; Fri, 24 Nov 2023 18:40:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="FlEH7S3n"
Received: by mail-oa1-f49.google.com with SMTP id 586e51a60fabf-1f9ec5dac5bso604118fac.3
        for <ell@lists.linux.dev>; Fri, 24 Nov 2023 10:40:24 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1700851223; x=1701456023; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :from:to:cc:subject:date:message-id:reply-to;
        bh=U4w9NusNitzkfRErJydlrb+3SUAlVpqdhe+ewGCEHUA=;
        b=FlEH7S3nnXGb/NU8Fms8letjasKPYQqVvBZW38o5/1/WxTNvgnDd1LQxEvQqEaIcRP
         /FxML+HhduCqNF2A1xmMhQAQV8SyoeHw2ynhuxtd4go1t9ly/P6Mqzxl5UY8uBOYbsK5
         U9E/txu0NPWPV5P3wzSDIum26+YKr3YH7xW869SzkesL9TfQ4nlkeTITvziLfj72XY9D
         BnJ3N6Evfxv6/m98ZIXHrE7+ReZdWWoF2Nw2WbUs6qtIdjIp2E/H8iGAyrijIXv4rNQ3
         DDdj15gGZb0FGM72aPb4sACCHgjCYVePWkFZ9V4P3m7Tf+fRqGcKZ+z7/E2oP1NMCskT
         8yuw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1700851223; x=1701456023;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=U4w9NusNitzkfRErJydlrb+3SUAlVpqdhe+ewGCEHUA=;
        b=NPNdRrilbse9SCA4VvZMdk6fK/Dco+7NBRavkqEIEymlW9w7yXU9t74EH8Ot2a+K99
         5cAgZV0ybYd+CHCS775c56kkUm5+dtCJ6eI5x2Huo10QZ8CgVrBC6Cf8DVGw/mLanmaK
         5yHwDRA/GgpqIjlyZkCeVy+Y/U9kHfOurRbaYAsMUZLxlfKNnqeYkmnI+qHK0m3MTeg9
         Ff+sChjI1dmhYVK4f/74e6oT1/9WBw4FUncy5DeD4LJZaVhGJ4PEdbkpMbjjb1ZfMhrS
         xpE/kXOtsbhDCrklYOmd9kbv+pxmD7egU30aS3q+T6mO/NKK0k1FqTXJUpqmSenNSWP9
         vyNw==
X-Gm-Message-State: AOJu0Yx2KP/C+wbH8Stngi1kx5nEd+ysmYN9jVTHFO0FTnFpl/ZTXww1
	xoBPxqUznt3ogXjblbKYqJEjjtsfgd0=
X-Google-Smtp-Source: AGHT+IEO0q5Hkva52YscBW69bFKcV2pHnFIIW1EE1BuurODPNZi5uM0Olp2Pji9shpYFrutkvSV5bg==
X-Received: by 2002:a05:6870:d14e:b0:1f5:cd37:34e with SMTP id f14-20020a056870d14e00b001f5cd37034emr4273497oac.20.1700851222860;
        Fri, 24 Nov 2023 10:40:22 -0800 (PST)
Received: from [172.16.49.130] (070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id oi8-20020a0568702e0800b001efb3910402sm898595oab.0.2023.11.24.10.40.21
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Fri, 24 Nov 2023 10:40:22 -0800 (PST)
Message-ID: <364f8062-060d-4b43-be0b-ff0723e0c61c@gmail.com>
Date: Fri, 24 Nov 2023 12:40:21 -0600
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH] netconfig: Always set DHCP MAC address on start
Content-Language: en-US
To: ell@lists.linux.dev
References: <20231124161740.1243946-1-denkenz@gmail.com>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20231124161740.1243946-1-denkenz@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

On 11/24/23 10:17, Denis Kenzior wrote:
> l_netconfig_stop() calls l_dhcp_client_stop which does not reset the
> client MAC address being used.  Since the underlying MAC might have
> changed (for example, due to per-network MAC address generation in iwd),
> make sure that any subsequent l_netconfig_start() invocations will
> update the DHCP client MAC.  This already happens for DHCPv6, but
> somehow did not happen for DHCPv4.
> ---
>   ell/netconfig.c | 9 ++++++---
>   1 file changed, 6 insertions(+), 3 deletions(-)
> 

Applied.

