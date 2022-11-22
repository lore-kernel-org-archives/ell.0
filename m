Received: from mail-oi1-f171.google.com (mail-oi1-f171.google.com [209.85.167.171])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CF7A5A491
	for <ell@lists.linux.dev>; Tue, 22 Nov 2022 16:59:55 +0000 (UTC)
Received: by mail-oi1-f171.google.com with SMTP id q186so16446271oia.9
        for <ell@lists.linux.dev>; Tue, 22 Nov 2022 08:59:55 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :from:to:cc:subject:date:message-id:reply-to;
        bh=0Ckh+ib5E8DxYUI6TzfvwxVyMFTE3sYUxo61MrjrPpU=;
        b=CNIzQOZETcU3aQOy9I9OPdsj6wX/6cdYEXEC8pHUUVqZzzL7yeyVcoQBavnTxgj8Ei
         L0awLdkwEqtQfgU5f2r0mqsnhGJugAi0xCCAupEJWA1xW3N4KFlMdQzje/L9JylB09Mq
         fGq+icDgwny554wboOtPJ57ZWOBe3Ejf2a/8r8m26yGIDnpnrz5jzQVNN7/PKci9Nz/T
         vcnukyCMrmK/Nm6vTDk7tnuFre2WaDbTHHk0piyHBhHpmfwTg264ezFpZCkhK1lruGls
         RG5a0vC7u1OmY5vCcsdR9BXguHcGPwQtzvy8Jxc04EJ2Q1PCYrYnkaOA0ID3Z+Vpso39
         YYaw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=0Ckh+ib5E8DxYUI6TzfvwxVyMFTE3sYUxo61MrjrPpU=;
        b=dkhfguovlsmUARWs/TZRywXht2Kw+ayVYTBEasfTD2jHrt+aW1W10tElSIZrUHDInl
         f1jCBGcMqul5l9ttOpIs56/2h5JwBz6tlMLWkpJ+TEHPlAGtZbrEZCeWotprpjKm3hHq
         MIuGFSb+b0SK9E1degg2t3KmdNNAJzZBIiI5KeD7QF+DNq8I3h/YdMFzO4Hy7lLdUr3j
         PeFGkkpcwjvfj/WzH6XbyP94baKBiEGerQkiGDBvud2wparoa/CvpShNNVjBOsOquCRb
         9CRwIuxEtimIRd/n+Ycq24PixX6HY9RAYeMXkTJkxXBEJg929LyX9dNZ8w2d/RXFD2Tq
         dOoA==
X-Gm-Message-State: ANoB5plgdUFNzVzURCzpuad6Z7WfIcIJUng1mTQcb+43o1Rnw/9pSRUA
	jhe6avaeBotbFB27O/0KstWO1pB3XG0=
X-Google-Smtp-Source: AA0mqf7Ab4ImF5w8ceZDPGAPSy1oS+T1Hp3eiihVSInAUXh4WkcA3TxXGZEofP7Xv359QNqaslIWEQ==
X-Received: by 2002:a05:6808:180a:b0:35a:58c7:7f5f with SMTP id bh10-20020a056808180a00b0035a58c77f5fmr2207604oib.252.1669136394998;
        Tue, 22 Nov 2022 08:59:54 -0800 (PST)
Received: from [10.0.2.15] (cpe-70-114-247-242.austin.res.rr.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id v15-20020a4aad8f000000b004805b00b2cdsm5337972oom.28.2022.11.22.08.59.53
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Tue, 22 Nov 2022 08:59:54 -0800 (PST)
Message-ID: <e20d4df9-d148-fe81-6c72-5237d4f74ac8@gmail.com>
Date: Tue, 22 Nov 2022 10:46:55 -0600
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:91.0) Gecko/20100101
 Thunderbird/91.11.0
Subject: Re: [RFC 3/8] checksum: commonize checksum creation
Content-Language: en-US
To: James Prestwood <prestwoj@gmail.com>, ell@lists.linux.dev
References: <20221118211624.19298-1-prestwoj@gmail.com>
 <20221118211624.19298-4-prestwoj@gmail.com>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20221118211624.19298-4-prestwoj@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi James,

On 11/18/22 15:16, James Prestwood wrote:
> The various checksums were using virutally the same init code. Make
> this common which will make initialization by key ID much simpler
> to add.
> ---
>   ell/checksum.c | 103 ++++++++++++++++++-------------------------------
>   1 file changed, 37 insertions(+), 66 deletions(-)
> 

Applied, thanks.

Regards,
-Denis

