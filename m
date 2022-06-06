Received: from mail-oa1-f44.google.com (mail-oa1-f44.google.com [209.85.160.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ADDB233CB
	for <ell@lists.linux.dev>; Mon,  6 Jun 2022 20:43:24 +0000 (UTC)
Received: by mail-oa1-f44.google.com with SMTP id 586e51a60fabf-fb1ae0cd9cso10013897fac.13
        for <ell@lists.linux.dev>; Mon, 06 Jun 2022 13:43:24 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=message-id:date:mime-version:user-agent:subject:content-language:to
         :references:from:in-reply-to:content-transfer-encoding;
        bh=VsQAKuDCEr2QSjZZiuxs+JOxmoOC/VPv5dKGLOIuQ1w=;
        b=R8OHKAsbRWmQqvLIERAACEChfe4SkI8DTnOoJ/037NIkcp25aae426paBcoSznJQb0
         L+EVg25o/VY+WOuFD9vL4bDECUPiTprRw+MRFpiwqkU/Wj8cSub9PiX2FcA8fM1NyMGg
         9fdFNqmm+kAn2Y8OXtVF4X3GXHhyQuHB4TId79uGQV1B0s3AP1zXrF/peB88hBVqpknA
         j0w36Mj5WpTkh49yZBNncTGDhrdnTTR58UrjxYDC+J1pWZnLu43pPGW/5C5JafWaRLoF
         3qXntmpVuqzwWp25Mxf+nwUnEbXqPAOiuYwXyTuAMbua44HgMaPSZroVaHTS+/ixEwT7
         aYag==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:message-id:date:mime-version:user-agent:subject
         :content-language:to:references:from:in-reply-to
         :content-transfer-encoding;
        bh=VsQAKuDCEr2QSjZZiuxs+JOxmoOC/VPv5dKGLOIuQ1w=;
        b=2lYSvrhoCM+j2/T4fRdTDrj8rvicRkZEq/utGJLdli0Lt1fy9HOBk8vYI728cFkw8o
         IxmsKyO8CbrnCnjw1sV6Ku5HcoEpgYv3kXHeu/kcT3kZOY3OoGi/vV6tvaA56k7ytvb5
         AORgZWhfGiaFe6ejUn1KbwRE8AXczMSEwBU48czUOVwYdBVcXIOoPSTB9lgZHIdi1yzS
         f0SGd81p2aiosE+NT6rgjGPdcZetkcKZ81cFpS/jO0yrmy6QydcR/rA8F6i9FoblMKVw
         DPxELyo7JWxcrth32vMVo4v+YTrM4HzOLk8QKbPhPuT/xp+vkPvJrH2d6O928XzED8ZM
         Lhvg==
X-Gm-Message-State: AOAM533bN+4Aib6yAGYFIYJ9vgLKFapfRrB6JwbOo/hhlrUrGSyWcYiW
	I3LNYR1rY5Q5K3V5L6Cd5AENefgF4P5cwWd6
X-Google-Smtp-Source: ABdhPJygEK5tAjPwtI9/p0rs0U8PRK+Nm81qfIEBY4wooKvHNBQ6Nn4IWvQXyOZZg8gNfD2vK6cFQg==
X-Received: by 2002:a05:6870:9586:b0:f1:d7f9:f0da with SMTP id k6-20020a056870958600b000f1d7f9f0damr30214064oao.259.1654548203770;
        Mon, 06 Jun 2022 13:43:23 -0700 (PDT)
Received: from [10.0.2.15] (cpe-70-114-247-242.austin.res.rr.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id n13-20020a4a848d000000b0041b52f42fb5sm5101926oog.47.2022.06.06.13.43.22
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Mon, 06 Jun 2022 13:43:22 -0700 (PDT)
Message-ID: <27ac41fd-527c-f1d2-6e4a-620023e62f9d@gmail.com>
Date: Mon, 6 Jun 2022 15:26:46 -0500
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:91.0) Gecko/20100101
 Thunderbird/91.3.0
Subject: Re: [PATCH] build: fix time.h related breakage on musl
Content-Language: en-US
To: =?UTF-8?Q?Milan_P=2e_Stani=c4=87?= <mps@arvanta.net>, ell@lists.linux.dev
References: <20220606200539.28575-1-mps@arvanta.net>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20220606200539.28575-1-mps@arvanta.net>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

Hi Milan,

On 6/6/22 15:05, Milan P. Stanić wrote:
> missing time.h for struct timeval usage
> forward declaration of struct timeval in time-private.h
> ---
>   ell/dhcp-transport.c  | 1 +
>   ell/dhcp6-transport.c | 1 +
>   ell/icmp6.c           | 1 +
>   ell/time-private.h    | 2 +-
>   ell/time.c            | 1 +
>   5 files changed, 5 insertions(+), 1 deletion(-)
> 

Applied, thanks!

Regards,
-Denis

