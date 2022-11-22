Received: from mail-oi1-f175.google.com (mail-oi1-f175.google.com [209.85.167.175])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 96453746C
	for <ell@lists.linux.dev>; Tue, 22 Nov 2022 17:05:59 +0000 (UTC)
Received: by mail-oi1-f175.google.com with SMTP id r76so16449388oie.13
        for <ell@lists.linux.dev>; Tue, 22 Nov 2022 09:05:59 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :from:to:cc:subject:date:message-id:reply-to;
        bh=vPbNYjgkPjvW+wWfe4Ny9G3w+6S/I2LDUWBold7jGtk=;
        b=MxA4uzOeETjTObHP5CI+eNhsXBU4hHH0v2VQCgEwq+Wf04UiFZswIVP/xm08cC4ptI
         Ei9g4II6B4hGPxouQG7DPJwzVibOAFcXyJn2vlhYquL1/Uj5FgfHAR8X7HCQLBsl3vR+
         30goxjJdsCSKU85pfAuXflJP/lIwDDk26Z2S+ywIbLfmxEQSCY562nfXt5VX+MbfUfsa
         o5WBxGrvaJ/EjTI4/kRkaRZAmThPpYaF2xS5rc3rj+n6ObG8dCKQRGlpQN74q26nkei3
         wYgY4/SLYvrESm2XchSz6hyQgAycXhkFMqX1iCeWGRN2fNw6GjlHt+hbh1aKYXpPDWjH
         nORQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=vPbNYjgkPjvW+wWfe4Ny9G3w+6S/I2LDUWBold7jGtk=;
        b=pADnKSylI1RqsSZs1MyoeKIYqJvNfDZU/SfNc4ZeNDDw9abLTxUm+T6EXiWxa6x8rF
         XffVmgrJE8KNBKB1W5/zWjU8j1veEPQRA7F3yUesDdMDs4pQK0/xhqGlfGbFfR9/cF2R
         Tj5fO7pPcW/Tdl30guFElio6UiG8mNwTjhz8h3mGAvea3nJWZik1ipEQdkKqQWGRRrpE
         Iyqwk+rpBEEsiYZZMZ1k2vaJR+tbEP9hCYVbjD30tyL7ZS7uRQ+Fu3S+CZ7jD+OFSoIa
         +4Ayfap6wGfFqGfd0X8xH5CXhsbEdJOsF1HYrMnbeynDJSGZ5rxkaJATVzEaAqVKuhYL
         h/GQ==
X-Gm-Message-State: ANoB5pn12iFq+CGPSOoYozI12P+2TS+Yvn2t5LhYog1cjB578ykp1/+7
	80BOou+0sF38BwtUiwK4HYPT6ho5R3U=
X-Google-Smtp-Source: AA0mqf5DkGVuOifvs4jiv7dOpIbEYlwallT+90rQmIJ1IiyTCqQ7d80K5iO8lum4VLm5F5Y0nfz2ew==
X-Received: by 2002:a54:4796:0:b0:355:7ae5:4fe with SMTP id o22-20020a544796000000b003557ae504femr5761570oic.54.1669136758705;
        Tue, 22 Nov 2022 09:05:58 -0800 (PST)
Received: from [10.0.2.15] (cpe-70-114-247-242.austin.res.rr.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id f38-20020a05687089a600b00141a2618121sm7700757oaq.56.2022.11.22.09.05.57
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Tue, 22 Nov 2022 09:05:57 -0800 (PST)
Message-ID: <325d9738-a755-2a54-1e78-7792e818a1cf@gmail.com>
Date: Tue, 22 Nov 2022 10:53:03 -0600
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:91.0) Gecko/20100101
 Thunderbird/91.11.0
Subject: Re: [RFC 4/8] checksum: add l_checksum_new_hmac_from_key_id
Content-Language: en-US
To: James Prestwood <prestwoj@gmail.com>, ell@lists.linux.dev
References: <20221118211624.19298-1-prestwoj@gmail.com>
 <20221118211624.19298-5-prestwoj@gmail.com>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20221118211624.19298-5-prestwoj@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi James,

On 11/18/22 15:16, James Prestwood wrote:
> Same as l_checksum_new_hmac but uses a key ID rather than a
> key directly.
> ---
>   ell/checksum.c | 17 +++++++++++++++++
>   ell/checksum.h |  2 ++
>   ell/ell.sym    |  1 +
>   3 files changed, 20 insertions(+)
> 

<snip>

> @@ -213,6 +217,19 @@ LIB_EXPORT struct l_checksum *l_checksum_new_hmac(enum l_checksum_type type,
>   					&checksum_hmac_algs[type]);
>   }
>   
> +struct l_checksum *l_checksum_new_hmac_from_key_id(enum l_checksum_type type,
> +							int32_t key_id)

Missing LIB_EXPORT?

> +{
> +	if (!is_valid_index(checksum_hmac_algs, type) ||
> +			!checksum_hmac_algs[type].name)
> +		return NULL;
> +
> +	return checksum_new_common(checksum_hmac_algs[type].name,
> +					ALG_SET_KEY_BY_KEY_SERIAL,
> +					&key_id, sizeof(key_id),
> +					&checksum_hmac_algs[type]);
> +}
> +
>   /**
>    * l_checksum_clone:
>    * @checksum: parent checksum object

Regards,
-Denis
