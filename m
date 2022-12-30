Received: from mail-oa1-f48.google.com (mail-oa1-f48.google.com [209.85.160.48])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3A68D2F24
	for <ell@lists.linux.dev>; Fri, 30 Dec 2022 17:49:04 +0000 (UTC)
Received: by mail-oa1-f48.google.com with SMTP id 586e51a60fabf-1322d768ba7so25446783fac.5
        for <ell@lists.linux.dev>; Fri, 30 Dec 2022 09:49:04 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :from:to:cc:subject:date:message-id:reply-to;
        bh=8mtb9C9n0iOiynD04KBkE33UqUMoDMvwtTJeAZ9GHjE=;
        b=NWflY1U9hX8UUDx5gErX09494zNEngkhrxZQaWNeK28cj1/kBjHLWdn/eE+wrPGoaJ
         86Q8X5n1LsRz9gE4h869HR/hD4SsmMU2vswHeoTKoWd6p9lBwdbTK1/iP7mGV2D3ejQN
         qd+PQQGUGts1+BZTua20fz2PQYSDtMltB8bz3/9HWBb7ZKAsiTEoLx9uGXuTOhIDi9cs
         Z07KNvpIojiNnZ5enzU+CpV9810TPwGBXzxfKQP6w9TvDShGW3Y8H7Tscb7YtbwKg3Mz
         lousDQ+6AHD8+3xKS12rH1isHJzUYPMNFxTj44BBb6xx00Bsl0HghJEYo/GywvsTNuzB
         rMyQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=8mtb9C9n0iOiynD04KBkE33UqUMoDMvwtTJeAZ9GHjE=;
        b=m2CjZy84o4i3nzWVwXs1D83L7kpSt0yyyE7w2Xgrnxc5iB4TYNe35Hon7xzhfH8FTx
         C8Y/ygf3cjCq24RT4QGcSr7s4lcXQAOBRG488XyTLf2c0svRpxcvtiQ6Eldg43MgRFPJ
         2/Op6TbCMt2hictnRdt5hlRibIL6ap4xFbid4fbs6sLcHHHxr9Mhk8YNkF10ArV7aDCn
         zNPjbgrB2FSshG1xO6uyP1EbMtH7Xcjs1/RkxpUYx+ecQXJ0LkQACe4X2mEYXjZ8BFSe
         ds1ckMkUYKY1mVwBSutstMaWU5dv8kDi8+Aj/maFMZBpTPVsF47g9WMepEo/OODkmfwE
         o7Og==
X-Gm-Message-State: AFqh2krJxHgslW52AabDqDLPjzbN6Kl66B6ln/aXcvhBhwYtSrGL5Vlg
	79Y7CYKqvEwtSrOzjvWNjk0=
X-Google-Smtp-Source: AMrXdXtbBBGDtfU72CGrCX+tKgqabJqNhS4Zub11XYa2lUmwVt9ruhjHnGGs+9+KXK1K/CHCjaoi+w==
X-Received: by 2002:a05:6870:9a10:b0:148:1ba3:f0f8 with SMTP id fo16-20020a0568709a1000b001481ba3f0f8mr16776386oab.16.1672422543359;
        Fri, 30 Dec 2022 09:49:03 -0800 (PST)
Received: from [10.0.2.15] (cpe-70-114-247-242.austin.res.rr.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id d5-20020a4ab205000000b004982f2d3c03sm8744815ooo.25.2022.12.30.09.49.02
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Fri, 30 Dec 2022 09:49:02 -0800 (PST)
Message-ID: <cc2ccf1f-3d5f-5827-618f-27dc06c12964@gmail.com>
Date: Fri, 30 Dec 2022 11:35:02 -0600
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:91.0) Gecko/20100101
 Thunderbird/91.11.0
Subject: Re: [PATCH] tls: Add l_tls_get_session_resumed
Content-Language: en-US
To: Andrew Zaborowski <andrew.zaborowski@intel.com>, ell@lists.linux.dev
References: <20221230164701.1095865-1-andrew.zaborowski@intel.com>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20221230164701.1095865-1-andrew.zaborowski@intel.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi Andrew,

On 12/30/22 10:47, Andrew Zaborowski wrote:
> ---
>   ell/ell.sym       |  1 +
>   ell/tls-private.h |  1 +
>   ell/tls.c         | 10 ++++++++++
>   ell/tls.h         |  1 +
>   4 files changed, 13 insertions(+)
> 

Applied, thanks.

Regards,
-Denis

