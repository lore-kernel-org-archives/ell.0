Received: from mail-ot1-f41.google.com (mail-ot1-f41.google.com [209.85.210.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4C0AC1BDDA
	for <ell@lists.linux.dev>; Wed, 11 Oct 2023 14:56:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="UbCXg2t/"
Received: by mail-ot1-f41.google.com with SMTP id 46e09a7af769-6c67060fdfbso5009981a34.2
        for <ell@lists.linux.dev>; Wed, 11 Oct 2023 07:56:00 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1697036159; x=1697640959; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :from:to:cc:subject:date:message-id:reply-to;
        bh=SmL9Vq+dmOBvqitHJOA9MnA95s/5hSmcEs2pH/hhYjU=;
        b=UbCXg2t/QSk3w3xFlSzbTw2uOYl+sFE0OOO2ZOudSo/IEwjik6eUiiPGuPIx/8qXtq
         17uh5S1OH7lZjL6dZpGFrti4bQtoPbhzerzPNVxCGX/L0+9qZ/y8kZS+uITmnApz7J6f
         2jdGd4xBRGPz8Oy13Cxc+d0tZB9/+9jiB4GAoRinOvgiJLF2KlVvRClmn2D4flkyIf6b
         9ruEZaO1R9aW359Tglprax8hlaIE+xGswdUazPKcolPrKNi0Ih7UBHRiVMT702dL7+ro
         bXHPR01IYN757ew79HnI8jqZJDjVvX54IGf+c461M7N9oGWGEDCGcsbcOMY8zbDim1h+
         ZyAw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1697036159; x=1697640959;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=SmL9Vq+dmOBvqitHJOA9MnA95s/5hSmcEs2pH/hhYjU=;
        b=q5eVz1KCtnVvzTGyGdIpcbw8c+qOJdHh19rrU/ztfROiLOSJq+xzogY2afXMIrFQSk
         sMptLhwlj5Bm7nfuhpIqkd0Yb6T68lMlogO6RB32nGTwdH13VaeGofdt+sUuQra/7cE2
         uXXQlQ28ntF2WZb0AkPqkMbYiI6CSQ8sM3LJXg+8jhjW5r/pd0aA7Onn8lAxcW0i3Cut
         EsUOa3fA9+J6snhuGNcg6OPPZfZcx8odH0/a2rI5I93AHlU9H01wLf3H1n7133j88KpG
         zkWyS1duqP8Oso4GZcSR3RUQ1MOhR513z2/sFFqV80lDzIMHNUi1EZkbMRsNOjZ0gLOv
         0P3g==
X-Gm-Message-State: AOJu0YzvbWiIS3U5+m5gQPuYF6YAidQdoXZSrSXUVBBKacSUxB95OIsu
	EvlCy3oQFRCUdy2ox/FEu8U=
X-Google-Smtp-Source: AGHT+IG+1pnJSgIybQ6DhWoKYjcuBUnzGIqWPHBy8HisNbJMP9FWV+KxhVu1Ng1GANuIOWtpXXpLRg==
X-Received: by 2002:a05:6870:2b06:b0:1e9:83ae:a128 with SMTP id ld6-20020a0568702b0600b001e983aea128mr3995841oab.32.1697036158349;
        Wed, 11 Oct 2023 07:55:58 -0700 (PDT)
Received: from [172.16.49.130] (cpe-70-114-247-242.austin.res.rr.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id zf39-20020a0568716aa700b001e126575e1bsm1452oab.34.2023.10.11.07.55.57
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Wed, 11 Oct 2023 07:55:57 -0700 (PDT)
Message-ID: <bc8f7101-6deb-4016-8244-3ecdd13869aa@gmail.com>
Date: Wed, 11 Oct 2023 09:55:56 -0500
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH v2 1/2] ecc: fix incorrect derivation of compressed points
Content-Language: en-US
To: James Prestwood <prestwoj@gmail.com>, ell@lists.linux.dev
References: <20231010142506.261152-1-prestwoj@gmail.com>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20231010142506.261152-1-prestwoj@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi James,

On 10/10/23 09:25, James Prestwood wrote:
> The logic was inversed here and was performing a subtraction if:
>   - Y was even and type == BIT0
>   - Y was odd and type == BIT1
> 
> This is not correct according to the ANSI spec. IWD relied on this
> API but had matching incorrect logic so things "worked" up until
> a compressed point needed to be parsed from an source that
> explicitly specified the type (e.g. an ASN1 DER in DPP). All other
> uses (PWD/SAE) the point type was only used to force a subtraction
> so since both locations used the incorrect logic the points would
> compute correctly.
> ---
>   ell/ecc.c | 18 +++++++++++++++++-
>   1 file changed, 17 insertions(+), 1 deletion(-)
> 

Both applied, thanks.

Regards,
-Denis

