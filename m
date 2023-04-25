Received: from mail-qt1-f175.google.com (mail-qt1-f175.google.com [209.85.160.175])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 72223538B
	for <ell@lists.linux.dev>; Tue, 25 Apr 2023 14:49:26 +0000 (UTC)
Received: by mail-qt1-f175.google.com with SMTP id d75a77b69052e-3f0596e2c00so11851601cf.3
        for <ell@lists.linux.dev>; Tue, 25 Apr 2023 07:49:26 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20221208; t=1682434165; x=1685026165;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :from:to:cc:subject:date:message-id:reply-to;
        bh=u5Biw/sEya1KO61CatRIiv2LDj2W1FIgalwnPhE5qqE=;
        b=TXqaDOiEO/fNeZvI7J4hkw5vP+IXrJ5XE4OuCqmNs6U3BKqeqkmdLh21hAmwNjVtT9
         Li33zee1gaQTkLtpXQ1DPSYn8UNxQQG9e4a626abdJ8ip6vpLZ4N0sJMTCl38xS2gHBl
         u6UDZhWytVIWR2huzzRh0zJp0s7m/th+7F/zGfwWD4HTTE6yc4EPrfrKAiu4gnE03892
         r/Qq04V9rkSRe2+A6Ae7DQVUW3mylzx8fkKI+4y04nRw9Lyz53psjArXhdc6Rmy9yFDp
         xRSVQ30RES/D31HZCxz4bBrPi1g5+9SedDu8f50oxHTXCzCrO84xela/mydGziQ7ubmc
         JOPA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20221208; t=1682434165; x=1685026165;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=u5Biw/sEya1KO61CatRIiv2LDj2W1FIgalwnPhE5qqE=;
        b=PnLZFec/3U8U82RwY98hoiotjpfjGuTZq+Qze6mHbobZFY10FIQXK639OkfeG1WqC2
         shMy8w8Z2kRF5CIpyxzmfvD56owpXsArwH6VPHNxVI31bxbwrlsbIImrKe8Uvri1iJm+
         UHH9ZVaDGwqfE6ASXrN54mng9fyldocbajDKCO7iT50ADjwDMkFfr7RXScd0UkAyLYFq
         86EaTMB4ft6IHVTHkudonUR/ur/yPrm7WTrDUqhb9FGEtx//6OgRh6Regh1hVaU1kZHD
         uJiS8c+X223rEYp1SdCIOWUunLFn/65qPwOQlf8NV0rvnF1Zsr7FCOqr8EgQefoQ4NAG
         sekQ==
X-Gm-Message-State: AAQBX9eK3mKbRHigOEmEkN0FriyEqXlcVZJrlrU2gxEMpK4ZzCMGJuZX
	Y6uvy9LkdfRfQf0WtKB9Dtg=
X-Google-Smtp-Source: AKy350aN5GpiOxypufxsg/dxfjmJ7UD8hLLcwY2UGjv97EjWxUHLjZKXceQ0LCOvUNvRiqfPUZEabQ==
X-Received: by 2002:a05:622a:1387:b0:3ea:bac1:a5a0 with SMTP id o7-20020a05622a138700b003eabac1a5a0mr28021843qtk.37.1682434165179;
        Tue, 25 Apr 2023 07:49:25 -0700 (PDT)
Received: from [10.102.4.159] (50-78-19-50-static.hfc.comcastbusiness.net. [50.78.19.50])
        by smtp.gmail.com with ESMTPSA id pw9-20020a05620a63c900b0074f5fac707fsm1938026qkn.81.2023.04.25.07.49.24
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Tue, 25 Apr 2023 07:49:24 -0700 (PDT)
Message-ID: <b0400fee-c228-7505-8e1e-c4aff185da9b@gmail.com>
Date: Tue, 25 Apr 2023 07:49:22 -0700
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:102.0) Gecko/20100101
 Thunderbird/102.10.0
Subject: Re: Static array indices in function parameter declarations
Content-Language: en-US
To: Brandon Cheo Fusi <fusibrandon13@gmail.com>, ell@lists.linux.dev
References: <CAEVJM+pjy7k+to4uYCVBsBL9U0DDJzZ08DLtzvO5SrH-PS6Lxg@mail.gmail.com>
From: James Prestwood <prestwoj@gmail.com>
In-Reply-To: <CAEVJM+pjy7k+to4uYCVBsBL9U0DDJzZ08DLtzvO5SrH-PS6Lxg@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

H Brandon,

On 4/25/23 2:01 AM, Brandon Cheo Fusi wrote:
> Hi everyone,
> 
> I'm currently using ell for talking to dbus, and have found it way
> more convenient and easier to use as compared to gdbus, or any of the
> other bindings I've looked at. So many thanks.
> 
> The extern "C"  usage in the header files show the library is allowed
> to be compiled with C++ code. However the usage of the C99 feature
> that allows one to declare the index of the argument array using the
> 'static' keyword in some header files (like rtnl.h:110) seems to
> prevent this.
> 
> Is there a workaround for this issue?  Or should I submit a patch that
> removes all usage of this feature.

Is this you're only issue compiling ELL with C++ code? I ask because I 
quickly tried:

~/ell$ g++ -o ell/rtnl.o ell/rtnl.c -I.

And I got a TON of errors. Mostly void* pointer arithmetic and missing 
casts from void* to other types.

I haven't heard anyone using ELL with C++, maybe a long time ago, so its 
not surprising there are some problems. If you're willing to fix it I'd 
say go for it!

Specifically, with declaring arrays like this, the compiler can both 
optimize and warn during compile if your doing something stupid. So you 
may want to hear back from Marcel/Denis on if we can remove this, or if 
there is another route to go down.

Thanks,
James

> 
> Regards,
> Brandon.
> 
