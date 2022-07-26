Received: from mail-oa1-f43.google.com (mail-oa1-f43.google.com [209.85.160.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8013C538E
	for <ell@lists.linux.dev>; Tue, 26 Jul 2022 17:29:32 +0000 (UTC)
Received: by mail-oa1-f43.google.com with SMTP id 586e51a60fabf-10d8880d055so19440259fac.8
        for <ell@lists.linux.dev>; Tue, 26 Jul 2022 10:29:32 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=message-id:date:mime-version:user-agent:subject:content-language:to
         :references:from:in-reply-to:content-transfer-encoding;
        bh=tAP2hKTi/I24vh26JZ97aUnrTjWPUe1aoF3BywCmHIw=;
        b=IsGsyFTZjJxi24CXhv/8XgbnTODUyo7NsepjFtZqY21zXud4CBQGEZOkaZK91GhNBZ
         xP819Cp2eCXUx7PQdKT5O7rzSxuiaTvysodI5pygDI7UclTb6vYtcDAPr0f0x7hhVu9u
         2Re6eTj9MNtHmamxhRHMU9FJKgBlp16GSHFJ7rMISBZAPXirez2C+nhJEOC20ATkD6mC
         h+pv56yU+6PLPudhYt8MtXiAhB3hhyIV6sRrqxU81zKogCfiFsf4+pHaSU6FV4gDF/zs
         /s1ddNW6RxB6j4MPwbfNp3ICVwNqkvV2koveT2Jr5p0rGeNDr1lp8qvLMp6jbkaI/Rtn
         a2LA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:message-id:date:mime-version:user-agent:subject
         :content-language:to:references:from:in-reply-to
         :content-transfer-encoding;
        bh=tAP2hKTi/I24vh26JZ97aUnrTjWPUe1aoF3BywCmHIw=;
        b=Ob1fZ7fWVitNoWIB3Dadn/PUPEKqCMBhW1O+CY2+LWemeBHZuuThNksY5FjzPmQyIG
         DZXQ4iCdoNabwnRHdvRNK7hjObvms0lIb/hiIiD4UP0JkRZd+kKEsakr9zZRUD64cUSM
         OJg35rwDUI2UGNwQJJihmmZk2uB9CNMyfvlkNQmsLqhVnKDUIgnaZZeeMPY/eb9+4IyA
         yJx+78sFBuBrNCMMYK2GboNxQDHTbEFoyJoaBEnhTleuCQfBczCLB2Kw7C1w+yCGeTV9
         40Cjxc44WwxFmgV7OibVcdiWmjpmcqcA9L+UwFoYrc10Nwd7Kq3yzfmEVhpJ8Oi4j0Cl
         srbw==
X-Gm-Message-State: AJIora+6WZ3o2IBVpi7UAor06sXGQQg+K1oI0wsbAvwIScqRyd4cLLyk
	mMW5w09OYgjkbz4W45rpOAg=
X-Google-Smtp-Source: AGRyM1uYpj95WcWHdeEuTx2jCR1JLMeuj9CDlyZDMfqEx8uyL8fQq09G/Cf22Y9jqZzvTgfKz8NVfw==
X-Received: by 2002:a05:6870:339a:b0:f2:d065:be1f with SMTP id w26-20020a056870339a00b000f2d065be1fmr151542oae.69.1658856571557;
        Tue, 26 Jul 2022 10:29:31 -0700 (PDT)
Received: from [10.0.2.15] (cpe-70-114-247-242.austin.res.rr.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id o6-20020a9d6d06000000b0061c309b1dc2sm6370111otp.39.2022.07.26.10.29.30
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Tue, 26 Jul 2022 10:29:31 -0700 (PDT)
Message-ID: <7fb212bf-ec4a-00a3-5e76-3e101ee9f67a@gmail.com>
Date: Tue, 26 Jul 2022 12:08:28 -0500
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:91.0) Gecko/20100101
 Thunderbird/91.11.0
Subject: Re: [PATCH 1/2] genl: make l_genl_attr_recurse take a const pointer
Content-Language: en-US
To: James Prestwood <prestwoj@gmail.com>, ell@lists.linux.dev
References: <20220726163500.6171-1-prestwoj@gmail.com>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20220726163500.6171-1-prestwoj@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi James,

On 7/26/22 11:34, James Prestwood wrote:
> The outer attribute iterator should be const since its not being
> modified.
> ---
>   ell/genl.c | 2 +-
>   ell/genl.h | 3 ++-
>   2 files changed, 3 insertions(+), 2 deletions(-)
> 

Both applied, thanks.

Regards,
-Denis

