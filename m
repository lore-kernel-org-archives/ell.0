Received: from mail-oa1-f42.google.com (mail-oa1-f42.google.com [209.85.160.42])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7B3252563
	for <ell@lists.linux.dev>; Thu,  7 Apr 2022 15:23:02 +0000 (UTC)
Received: by mail-oa1-f42.google.com with SMTP id 586e51a60fabf-d6ca46da48so6656860fac.12
        for <ell@lists.linux.dev>; Thu, 07 Apr 2022 08:23:02 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=message-id:date:mime-version:user-agent:subject:content-language:to
         :references:from:in-reply-to:content-transfer-encoding;
        bh=SvnsBiMoLZ0iS8ANMv5x3qb+I+SQM/bpArkJiSIoBJw=;
        b=eI0gTAz/85mdhIZlw0lmNG6UEi7wY0/rcRs+rj0T39vT1d+u4CIerHS8FUACLUkQ0W
         wzgp1D4cxDU1d2MUbHKDLuJ0fBG6bWxXylpXyqCRCkMUO1s/PUNH4Ik6e75x8daRaj8B
         D5Y4g2Bjqmi0F9OagUxjsFknm4xrvFsp/fsVFrHYwxwpCUdkN/NjSXpwYkQGN1MTQzRe
         vV93Dg/S6qnrPYQkSVfivJsIKGctFjj4ldhBn2IbDzJj0aXJu+Z7ePhXqnOgcZWNJ1FA
         Kv+nWiXJqbuXvoITqaaj8r1erOjE8OXvcHUNxfsNBbi2PZTsFK4GTw8zE5dA3h9brqA/
         I1dw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:message-id:date:mime-version:user-agent:subject
         :content-language:to:references:from:in-reply-to
         :content-transfer-encoding;
        bh=SvnsBiMoLZ0iS8ANMv5x3qb+I+SQM/bpArkJiSIoBJw=;
        b=UrwIO2tLNXmlrM7vlZeKP5lYJ85IAWfW+WbYGFJUAaTSuBCq7bSvGy23LeMD25UlWR
         osrAIXuUO3C0lBmQ5MqY8+3GEPPqVdZRpJy4zTca9HdljDRbY5FtoaezAR0PN8/UEUoh
         UbpvSOrfYKYeaALP7kGlQUApYFI+ZagKQ26funp9uljxDkvvYq7cwEj+RamYL5CNz91j
         v2Rk564HGrY35TSjJFQAFa7HWeiowXkiQUueGibB11p0y7keTs5gVX+7NRsEkLgi/BH2
         1YX36ZeTICX0PEAznXEooeSLifUQTOoun/V5+XjopoRYguuLy2xri9BXxOdsqCqTGGbo
         7sqw==
X-Gm-Message-State: AOAM533MNb650x6pcI6rLPiVaTj+cGBBiOOLWWN64HOXli+UCr0aOzCQ
	9v4d94UdLs2Zwp7nesq/IZk=
X-Google-Smtp-Source: ABdhPJzzm1saKDlsSAI2WHNi8jE8C3r7RxJ5uuOHQVZ7wC67ZCtO++X7QjGxxlzyPEHduSHhGAPs+Q==
X-Received: by 2002:a05:6870:f713:b0:d2:8adb:aaeb with SMTP id ej19-20020a056870f71300b000d28adbaaebmr6594155oab.111.1649344980625;
        Thu, 07 Apr 2022 08:23:00 -0700 (PDT)
Received: from [10.0.2.15] (cpe-70-114-247-242.austin.res.rr.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id k124-20020aca3d82000000b002ef4c5bb9dbsm7572633oia.0.2022.04.07.08.23.00
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Thu, 07 Apr 2022 08:23:00 -0700 (PDT)
Message-ID: <32c624bf-aecb-9675-09d7-e6856798cd57@gmail.com>
Date: Thu, 7 Apr 2022 10:22:58 -0500
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:91.0) Gecko/20100101
 Thunderbird/91.3.0
Subject: Re: [PATCH] dbus-util: fix fixed-array file descriptor check
Content-Language: en-US
To: John Keeping <john@metanate.com>, ell@lists.linux.dev
References: <20220407112212.3433989-1-john@metanate.com>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20220407112212.3433989-1-john@metanate.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi John,

On 4/7/22 06:22, John Keeping wrote:
> The code does not match the comment here since 'n' is the type code for
> a signed 16-bit integer.  Change to use the correct type code for file
> descriptors to match the intent expressed by the comment.
> ---
>   ell/dbus-util.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
> 

Nice catch.  Applied, thanks.

Regards,
-Denis

