Received: from mail-ot1-f42.google.com (mail-ot1-f42.google.com [209.85.210.42])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AA8AD405C8
	for <ell@lists.linux.dev>; Tue, 17 Oct 2023 15:00:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="lVbPz9ib"
Received: by mail-ot1-f42.google.com with SMTP id 46e09a7af769-6c63117a659so3500130a34.0
        for <ell@lists.linux.dev>; Tue, 17 Oct 2023 08:00:24 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1697554823; x=1698159623; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :from:to:cc:subject:date:message-id:reply-to;
        bh=i6bG84N3HQVSmZ5KY6XN6tww0WaLmWjzKH8bnyiOCEA=;
        b=lVbPz9ibQ/Xoswm4cucGK1dbSdpdhw8GHhIVkMQFB4aapupsb0fkVSbZFdxnXjSwUp
         x4SlHvCI4nV/KxE0gHmM4QE5Brni8QjF13AJL1c2eUvfbDOrRxuag3SCGXzzgFKW5tjO
         8iUrjKxuFMZbRiG1JkghTbBbIUGBJVrFMFgjYmCnBF3AJGA0Cgoim5+mtScoEvBUiBJE
         836zZGRacvV/c9Q0GcxmQ9UJvzM4NdHkQBBHzCzMTJMgEEnEC7xkVnXXAkSEblWmU5cu
         7TrXTk/hpf1xkaowHDBTLf8kXl6YxFL9QOMNjwcQxr4lIBg6gEcYaIXBHTzDY7Q0TNgP
         NO0g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1697554823; x=1698159623;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=i6bG84N3HQVSmZ5KY6XN6tww0WaLmWjzKH8bnyiOCEA=;
        b=DGLBAN0EApdiu5Iod2GVeK0smt6qxByC0WaiXEl85G1YyghYWy7/Jd7WrEfiLcVHu8
         eenEyM5+Rn+H+0UYHTzpMqlDM+jMBfUChND2ENGfp7gNSAp56yjtqfbyKKAG/InsMqFW
         G4VedH9wA6ZW8jULBpdgKUYNsvYgtkqQ4cmxab3FUwuzcy+wXBHvLMpk6OW1W9lhyB9t
         fvmUc1V4Nayc/PJ0z+eYhbO1g+NbukeHF9ul1CKL6+8qhGoMiya1OkE2hyx2IpR9aNno
         9G1/4vTjlDAS9Lo67RxHTAw0IMhuSvr8x8pa8fnJBsgzsUf/F5SM2IvmDcnO9xUIHYAP
         nWew==
X-Gm-Message-State: AOJu0Yz6is2nbPbtNLfLwyQ5tTvYv/ZvjEqrV/qQ5BZQpYMPBIhij2jX
	/LgmjJy4M3gsKx7EJVfC+DI=
X-Google-Smtp-Source: AGHT+IFWUtSrY9oqmaOWDf+f15marvEVvhSmCyvNo50h7RqFV/RJwoSCF+UfQAr7NEvDhQI/cDFHQw==
X-Received: by 2002:a05:6870:4e07:b0:1c8:b870:4e22 with SMTP id pl7-20020a0568704e0700b001c8b8704e22mr2495892oab.3.1697554823420;
        Tue, 17 Oct 2023 08:00:23 -0700 (PDT)
Received: from [172.16.49.130] (cpe-70-114-247-242.austin.res.rr.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id k4-20020a056870350400b001ea98995f7bsm89462oah.39.2023.10.17.08.00.22
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Tue, 17 Oct 2023 08:00:22 -0700 (PDT)
Message-ID: <f7022832-76e3-4ae3-860d-994cf9b63c84@gmail.com>
Date: Tue, 17 Oct 2023 10:00:21 -0500
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH] ecc: add l_ecc_point_is_infinity
Content-Language: en-US
To: James Prestwood <prestwoj@gmail.com>, ell@lists.linux.dev
References: <20231012133812.139893-1-prestwoj@gmail.com>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20231012133812.139893-1-prestwoj@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi James,

On 10/12/23 08:38, James Prestwood wrote:
> When creating a point from raw data the validity and if
> infinity is checked but there doesn't exist any way to check
> a point for infinity after doing some arithmetic on it. Some
> specs requires a resulting point be checked for infinity.
> ---
>   ell/ecc.c   | 5 +++++
>   ell/ecc.h   | 1 +
>   ell/ell.sym | 1 +
>   3 files changed, 7 insertions(+)

Applied, thanks.

Regards,
-Denis

