Received: from mail-io1-f53.google.com (mail-io1-f53.google.com [209.85.166.53])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4ED9A5C88
	for <ell@lists.linux.dev>; Fri, 22 Jul 2022 21:24:13 +0000 (UTC)
Received: by mail-io1-f53.google.com with SMTP id q14so4560186iod.3
        for <ell@lists.linux.dev>; Fri, 22 Jul 2022 14:24:13 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=message-id:date:mime-version:user-agent:subject:content-language:to
         :references:from:in-reply-to:content-transfer-encoding;
        bh=NeTW7a3b9Zm+rrXrdNwk8R0o+N9lLyuJx/J2Q7Gfnrg=;
        b=en9z8hUk3S2aHI4ikfXKFLmCqqFrSmdEeDWv5B4oYfNlH9+xqtztKCMOu4sX/LiGnH
         ImZazR0TK7C5peizgkUGYyNexkTfsHTXkCk/XZskrTlDyrresIpIpRT230WMqHQoWSt3
         sKaye3yFHV9nvUoupGyKsZr+UJ+otzsez3OzzytqIzF/G6Z/fwB9c4llz9DEyTmjOlo3
         zPoERdmf/F6Vr0S889JaWqd51jk0VqlEIbVemnVyvU2h9SL+pdx4S8kW7oEU8uE5EbOw
         sPG759x9gH/ZiTm6oyD6G/z4XojQCS946tbFk3Bh742C8l2VNB7/iEW5I5x3jAoWdOzy
         tG0Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:message-id:date:mime-version:user-agent:subject
         :content-language:to:references:from:in-reply-to
         :content-transfer-encoding;
        bh=NeTW7a3b9Zm+rrXrdNwk8R0o+N9lLyuJx/J2Q7Gfnrg=;
        b=FkLd4Kayo1SRUBt7uRrkjpnDs8hOOsNGjintpTYS3pSm4xr/H5cI5H7/cMvbvTjYI8
         T3u34xySzc5EwFInrlB3N6kxLsLCBaOoMac8HDne+DWQdx3tjQCFgOKr7djfKpp+Z43o
         wcTNXJkUjyMtEwnHMwPg+EL/mulfjw0vkjDUMiOiQc8fMRAwDXs47bzsO62ABDg7f6Us
         Dnkl/WhnaYoCLkshrg+lIY0vo+TDB2UPXjzSVSK3CkAJX4gHCNj2cywMW91sAEYGeATa
         E3FeoS/gSByuGiaYogb0mhyQMSUkmipUyDxxvykok6MNAXSY7sB6DzuVVtHORLfS2Pfx
         xuXg==
X-Gm-Message-State: AJIora+Fp+vjQtFFG9DEWE+uqIjRn2VD4wzp1NR0+iNf3kUSBHr5twwi
	baxoTMwrsROyUvyDqi7USys=
X-Google-Smtp-Source: AGRyM1tbWCDIT5NlgU8D8gW/hdizDcWaD4ykt7iSnktcvrMVCF/IyWjPesfju1CmxHspA9UEjKJVsg==
X-Received: by 2002:a6b:bf46:0:b0:669:c998:6b48 with SMTP id p67-20020a6bbf46000000b00669c9986b48mr577314iof.67.1658525052400;
        Fri, 22 Jul 2022 14:24:12 -0700 (PDT)
Received: from [10.0.2.15] ([136.32.1.70])
        by smtp.googlemail.com with ESMTPSA id d10-20020a5d888a000000b0066958ec56d9sm2689522ioo.40.2022.07.22.14.24.11
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Fri, 22 Jul 2022 14:24:12 -0700 (PDT)
Message-ID: <f77b972f-cc43-e68f-243a-b6d7b6db48a9@gmail.com>
Date: Fri, 22 Jul 2022 16:09:36 -0500
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:91.0) Gecko/20100101
 Thunderbird/91.11.0
Subject: Re: [PATCH 1/2] uintset: add l_uintset_subtract
Content-Language: en-US
To: James Prestwood <prestwoj@gmail.com>, ell@lists.linux.dev
References: <20220722202747.1193490-1-prestwoj@gmail.com>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20220722202747.1193490-1-prestwoj@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi James,

On 7/22/22 15:27, James Prestwood wrote:
> This subtracts set_b from set_a, and returns the new set.
> ---
>   ell/ell.sym   |  1 +
>   ell/uintset.c | 37 +++++++++++++++++++++++++++++++++++++
>   ell/uintset.h |  3 +++
>   3 files changed, 41 insertions(+)
> 

Both applied, thanks.

Regards,
-Denis

