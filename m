Received: from mail-oi1-f180.google.com (mail-oi1-f180.google.com [209.85.167.180])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CD002200D2
	for <ell@lists.linux.dev>; Thu,  9 Nov 2023 15:29:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="looXO4WX"
Received: by mail-oi1-f180.google.com with SMTP id 5614622812f47-3b587bd1a63so1056372b6e.1
        for <ell@lists.linux.dev>; Thu, 09 Nov 2023 07:29:34 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1699543774; x=1700148574; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :from:to:cc:subject:date:message-id:reply-to;
        bh=MFHMt7d71BFI7tk+JpzGGxoUrAS2Kk4Np3XsAbcHDtA=;
        b=looXO4WXZZA5Qi3Vf+0NicUku2OvWyhEZG/+h8GRX5p7tJxijhT+GfT/CLLqi37g/P
         uIe9GFFKJALvKryO9FPNCDR8oSnQ5EjyYJ3UbvywCx8KwUgidTvPiHma6E4Amwt+hGh2
         sUk8JNF0VkWF6g8EKh7yiTugPWbfBj6tRrxcoR89uW4O18rFnLdUCwAcbbT9qJ93n35Y
         OZXARB+WY1hniWCnJJqz12iX7iK3LRx2BkOmxy0xu7PfaLwaB8AZUdfmnZEp+hLtSpF1
         pRM8W6fGbt2ksev2XbNiDZP4iIdEZLzTFgKcPYtEHNSBqAieXVHRjtGznk7znOMdBxty
         UHuQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1699543774; x=1700148574;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=MFHMt7d71BFI7tk+JpzGGxoUrAS2Kk4Np3XsAbcHDtA=;
        b=qu/7jH5+1ykXxpv4iaZcm90fH70WGA59CKPgJC5JX1K5yQ5Hs9ifYWHeTOFRss0fV7
         MjMXOj9rUW0ZKJkAJ/AleBcTuGNkDQoXNHGFKJH5Lk/XJyG2kNClshxoCVXWH1yD00nP
         Tl4jiJCTZkRo2ipfqt8z8sxCWs6ZqOPdQymSV7sre2LEo8k82sVUDUTP4oLySgTddvvs
         hZdU1pqEO5IqmLATZP4kDATB8ahnaaLmfIn9B8239Azvw7qxeBU+U7/ArlCBXPPM9pRB
         PByhn8OnA7gT/AAhuH/u3Ejh7YDl5uu6lLUmg6VZafxS9Spvu+xdQ0EyKTj3zWltlHKC
         Ea5g==
X-Gm-Message-State: AOJu0YxyTc7S6PDMEup+9PD4TnZ8TO5sWxG/Jr827PLdAGJFu8TVRmNZ
	rATmdsCUsaHPLSuq81L7dbA2CWOm8M8=
X-Google-Smtp-Source: AGHT+IFp3V3poqOeGJve4sVAb8pWimCiaJFyhAPGnKO1RdmtJr3dVFHWO9SZR/VkIJ5XMLUb5ijB1g==
X-Received: by 2002:a05:6808:2a8c:b0:3ad:fd04:87eb with SMTP id fc12-20020a0568082a8c00b003adfd0487ebmr1105541oib.10.1699543773758;
        Thu, 09 Nov 2023 07:29:33 -0800 (PST)
Received: from [172.16.49.130] (cpe-70-114-247-242.austin.res.rr.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id a21-20020a056808129500b003ae540759a0sm2249884oiw.40.2023.11.09.07.29.32
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Thu, 09 Nov 2023 07:29:33 -0800 (PST)
Message-ID: <b96b515b-39d9-4287-9905-938b489a77bd@gmail.com>
Date: Thu, 9 Nov 2023 09:29:31 -0600
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH 1/3] ecc: Make product variable of _vli_mmod_fast const
Content-Language: en-US
To: Marcel Holtmann <marcel@holtmann.org>, ell@lists.linux.dev
References: <20231109142056.12385-1-marcel@holtmann.org>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20231109142056.12385-1-marcel@holtmann.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi Marcel,

On 11/9/23 08:20, Marcel Holtmann wrote:
> ---
>   ell/ecc-external.c | 2 +-
>   ell/ecc-private.h  | 2 +-
>   2 files changed, 2 insertions(+), 2 deletions(-)

All three applied, thanks.

Regards,
-Denis

