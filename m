Received: from mail-oi1-f169.google.com (mail-oi1-f169.google.com [209.85.167.169])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4FAA3EBC
	for <ell@lists.linux.dev>; Wed,  8 Nov 2023 02:24:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="HAslFe+w"
Received: by mail-oi1-f169.google.com with SMTP id 5614622812f47-3b512dd7d5bso4372682b6e.1
        for <ell@lists.linux.dev>; Tue, 07 Nov 2023 18:24:25 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1699410264; x=1700015064; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :from:to:cc:subject:date:message-id:reply-to;
        bh=uTkYaUa/Iw1uwM5cQ4pfiv288+V+B30WTTbmk1aN/aI=;
        b=HAslFe+wN/Aizx3YaRioQlfmbnSpUfQVhMY1DTd7/XQU7v29dkzqUXawCzQn3exHHS
         PvemVLSPHcEEQLq/X8KVEFdQS4+UjcINf3AjedGUnlOa07YO8krz812eYZaXma97hsdR
         1UGEpmlRR+uV8FhF079Ol05/qak/glKltRi6BxVEqMoK4OV2m82fcxdM+lpL5viFc716
         6nqSnLz8ZG8v3PPt26tKwTHvN1tcOdZR3KBUJIEFyRUyJZEGFz6e52YhjIy3NxUUypgM
         v4Z9T4Zwegi5lgj0MZ/H7HyOCXVO9mvNbdSVsLqYi4JXFixlqo7Fv/0cl4jGZUBw+kSF
         zrWg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1699410264; x=1700015064;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=uTkYaUa/Iw1uwM5cQ4pfiv288+V+B30WTTbmk1aN/aI=;
        b=txWnhJRS9/gtZZz0UE8pYtZdiFi7oWdpIhs7DRHHp7KaxfSqIo1JIUrCgg5x9uWENY
         NH6j92GeynmqJTz/foBOS/EWESsqW+I1EtSVgbOyNQh1qx7RG7CHJzGZyMFbm6LBJvao
         pDk4r2ReVEVF0rndVaRKW8tNyOiZClyftJj2E1RRAolsoolCptcMS9h9NPPSakZfAsGx
         YM2IDRE7zGMCtCIHtEP537h+Bw+g63SlO2xKFRuK0A1Lc1Hi6Q2eIcxCCsgeErK+KJRi
         x1aT1xw1XviptmXSWS4hhR9RyKo8rmiLY9aXM5RLzTyoFMrNMt64XiLc8tNBsdFbVKOG
         AmdA==
X-Gm-Message-State: AOJu0YwDXBVfrKoqAwE2oqu1SEN/QXJ9DVNRFdpWlxksbI5NbyUvcLYn
	kpq7JWzYSPFo61XkTkVJu2nYFzYWPDI=
X-Google-Smtp-Source: AGHT+IFF+w1rmErnnyR89gpufk14q4jyeqa/A7qUizJlQVEP4dINigS1NDe48WYf8MDQIM2ptm1Cvg==
X-Received: by 2002:a05:6808:2218:b0:3b5:e67c:b79b with SMTP id bd24-20020a056808221800b003b5e67cb79bmr991448oib.19.1699410264162;
        Tue, 07 Nov 2023 18:24:24 -0800 (PST)
Received: from [172.16.49.130] (cpe-70-114-247-242.austin.res.rr.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id s14-20020a0568080b0e00b003a9cd23980esm1777064oij.8.2023.11.07.18.24.23
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Tue, 07 Nov 2023 18:24:23 -0800 (PST)
Message-ID: <a1025299-8afa-45d5-9f84-6d790e79f3ef@gmail.com>
Date: Tue, 7 Nov 2023 20:24:22 -0600
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH] ecc: Add helper for multiplying a scalar with a curve
 generator
Content-Language: en-US
To: Marcel Holtmann <marcel@holtmann.org>, ell@lists.linux.dev
References: <20231106190638.296812-1-marcel@holtmann.org>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20231106190638.296812-1-marcel@holtmann.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi Marcel,

On 11/6/23 13:06, Marcel Holtmann wrote:
> The SPAKE2+ key exchange protocol requires the ability to multiply a
> random number with the curve generator. Instead of exposing the curve
> generator expose a helper function that provides the multiplication.
> ---
>   ell/ecc.c   | 12 ++++++++++++
>   ell/ecc.h   |  2 ++
>   ell/ell.sym |  1 +
>   3 files changed, 15 insertions(+)
> 

Applied, thanks.

Regards,
-Denis

