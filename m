Received: from mail-oa1-f45.google.com (mail-oa1-f45.google.com [209.85.160.45])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D55B57E
	for <ell@lists.linux.dev>; Mon,  6 Jun 2022 18:30:53 +0000 (UTC)
Received: by mail-oa1-f45.google.com with SMTP id 586e51a60fabf-e656032735so20234429fac.0
        for <ell@lists.linux.dev>; Mon, 06 Jun 2022 11:30:53 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=message-id:date:mime-version:user-agent:subject:content-language:to
         :references:from:in-reply-to:content-transfer-encoding;
        bh=Lg1U9iEn8ivMzkiCJM7JMAkBMkmiGpCfqfB+XZKp73k=;
        b=QUMbrgmqqALWFAwNzf16yDElC16T7JIxDwVhKL3xtHWejgBgrqb0bgb9jeaWQzVg1q
         kfCcAesM8ENWqnkQyQTPspXOUuk1/pIAXraPr4DK0wKQ8wnGGLwi9RNbQQwUBJMR3qSG
         9mUYlkVXdlOb8tWeJBFiOduO/fGeGvrYFnnOF2Kr6CpjZB49nHJAHY9QhsN04oJ1FcmW
         TVwpjI0wxMRg6MeBPWrjZzRzIpOQt2lOACMV2DbOslG2xr6nyLuRSv0Hq7TF24i7iLQj
         wr0+LysPRGXT/52Ob/QTEgzfVQAyLB7b4Nr4Zk1yt5PV0TPGy2TUwJw4d4oUDxy5uPxc
         0o9w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:message-id:date:mime-version:user-agent:subject
         :content-language:to:references:from:in-reply-to
         :content-transfer-encoding;
        bh=Lg1U9iEn8ivMzkiCJM7JMAkBMkmiGpCfqfB+XZKp73k=;
        b=okvWrUieXFeoVX+VmhynxX6Kg2QL7EvGBeRyI/tVXJc1SZkcSoFmJrZhb86ogVrUHZ
         8rCY4xwMRV6O85vrB2dhYmHa33gqrmcQ437oSu5ZLfmTzH+bVTsry/slBjx6Q5XhSCW4
         PiEWYUd0t0tMqaurTHODkBYTQz8TXyaEl3SiHw6MlXPvBYZR+NFlYzLJ3RU8Xni1orNb
         5Dy+FFA5fOsNMpQtAZfLUeeHb9H3Y4ysIgLJ4pWvypQxmhbnJla1bnD5ezC5k/Y6GYgA
         gYK5PVJeXETGdWDY47+Lw5OCV7aMZ8R5i0CVjHoSeP0deBy1SsG6zAY+Kb3N4IxdCm5I
         FU3Q==
X-Gm-Message-State: AOAM532Cgk/8HIm8ffHtWsEvbG5yJDuUBrenaFuzVcg37G3eObpTi+jR
	ogr3fUyb3eoWaYkCYu6G4v4=
X-Google-Smtp-Source: ABdhPJwBaZY2/IEN+/YWtHiKIfABXOA27deozLBVk0bV0aDWeyLNZcaosOlwzljqsO34UiNQ0mN07w==
X-Received: by 2002:a05:6870:d1c8:b0:f3:2788:9397 with SMTP id b8-20020a056870d1c800b000f327889397mr24026251oac.283.1654540253053;
        Mon, 06 Jun 2022 11:30:53 -0700 (PDT)
Received: from [10.0.2.15] (cpe-70-114-247-242.austin.res.rr.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id d22-20020a056830045600b00608b8e6fad5sm8086945otc.76.2022.06.06.11.30.52
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Mon, 06 Jun 2022 11:30:52 -0700 (PDT)
Message-ID: <522505f6-bf75-d30e-945c-6da6a256a40f@gmail.com>
Date: Mon, 6 Jun 2022 13:18:39 -0500
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:91.0) Gecko/20100101
 Thunderbird/91.3.0
Subject: Re: Fix bug when stdin is closed
Content-Language: en-US
To: Greg Depoire--Ferrer <greg@gregdf.com>, ell@lists.linux.dev
References: <20220507235434.11693-1-greg@gregdf.com>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20220507235434.11693-1-greg@gregdf.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi Greg,

On 5/7/22 18:54, Greg Depoire--Ferrer wrote:
> Running iwd with FD 0 (stdin) closed fails because ell considers epoll_fd of 0 to mean failure. The first commit fixes
> that bug.
> 
> However, it still won't work because ell/dhcp6-transport.c has a bug where it closes a uninitialized FD (FD 0 on my
> machine) and that would cause an infinite loop because the epoll_wait call was returning EBADF. The second commit fixes
> that bug.
> 
> I noticed that ell/dhcp-transport.c is prone to the same mistake as the udp_fd field is not initialized on construction,
> but I don't know if the close can actually be called before the udp_fd field is set. Just to be sure, the third commit
> initializes it.
> 

Good catch(es)!  Patches 1 & 2 applied, thanks!  See my reply regarding patch 3.

Regards,
-Denis
