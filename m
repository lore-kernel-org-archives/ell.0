Received: from mail-ot1-f53.google.com (mail-ot1-f53.google.com [209.85.210.53])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B0687ED0
	for <ell@lists.linux.dev>; Tue, 22 Nov 2022 16:56:37 +0000 (UTC)
Received: by mail-ot1-f53.google.com with SMTP id p27-20020a056830319b00b0066d7a348e20so9659107ots.8
        for <ell@lists.linux.dev>; Tue, 22 Nov 2022 08:56:37 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :from:to:cc:subject:date:message-id:reply-to;
        bh=8Gfbe88FJcsN7NsST5aLQUGaKZ2iNmDn/dCOlpMf1B8=;
        b=SXxHx3KrIa4B5xQSbXKzLL9PaHkloqodi7zxPEF9F7ptFma4DD4o86PbtaMmEknpul
         krKFZM1r1CgPFh9Pfm4hF7GLWTSigT1AJ9EYBX7d/MLDAhQRlUckKM0T4eYVd1M1Awxr
         XxDpBEu7jaUzcxPPs9v+q/9MmJoidUA6q6wh4Ka/ved+9B9o/ROcj4glhmNRGZ4RprYn
         N6/wTq41TgEtZcNjDCtHA7bqkweNLbzFGBlmohueIs8JD7ov9UeuZfnVivqSQapn4QLp
         ndaXBXeSZt6/44Ia2IVvoNHpoB0OIpPDlDqiYnzGxgcPu7bVrCoCxi2iyO3tWJa1kkRP
         TC6Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=8Gfbe88FJcsN7NsST5aLQUGaKZ2iNmDn/dCOlpMf1B8=;
        b=5ZGMXiMGLfFMt8VxMwj+4Fhbjukwpgm4QkcRs20+tacybyu+2tiIc2scKqeuf5x6an
         iCDsD/3s2JVTNYHCsgHrRHiqYCaUHHtddKjdl9bR+71UxT+hZjcg44py1Ksx5dYTqocZ
         rBKV4lRQGiwaK2M3Qy/iHBG09YBiNPayoKZ8y0wZbLYgXxBkBJoFaBrGaKmiTYzqCRH+
         V3QkwThzgMJ7A+jaQvWqOECPZOdi+KpFj0niC0qUvm1E/XANKdEyadKD8osMM1wcZH57
         r7t8vwfgROyyKlV3yq+lrRZjjOGisu97OOso+sM8TS8tQONUsdIEPwJFCihTrIQIWuKR
         7gKg==
X-Gm-Message-State: ANoB5pkjoj6L/m2lZ8g1v9m/QG1la3ZXj3eTRKYy7kHHauT6pjZNVt02
	Lxq+ettkn0fu78feEthaBdA=
X-Google-Smtp-Source: AA0mqf6SCUTfItgLed9KoRWZQ9b0XRPMQxE3BfsacvNuPuEdovM+/vocXFrv5OU4x1M03d6sz8mxeQ==
X-Received: by 2002:a9d:7f0d:0:b0:66c:9183:20e2 with SMTP id j13-20020a9d7f0d000000b0066c918320e2mr2360384otq.260.1669136196744;
        Tue, 22 Nov 2022 08:56:36 -0800 (PST)
Received: from [10.0.2.15] (cpe-70-114-247-242.austin.res.rr.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id x45-20020a05683040ad00b0066871c3adb3sm6294971ott.28.2022.11.22.08.56.35
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Tue, 22 Nov 2022 08:56:35 -0800 (PST)
Message-ID: <f4f33ae6-ba6f-e19a-89cb-6ba5c9a101f1@gmail.com>
Date: Tue, 22 Nov 2022 10:43:42 -0600
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:91.0) Gecko/20100101
 Thunderbird/91.11.0
Subject: Re: [RFC 1/8] key: add l_key_search
Content-Language: en-US
To: James Prestwood <prestwoj@gmail.com>, ell@lists.linux.dev
References: <20221118211624.19298-1-prestwoj@gmail.com>
 <20221118211624.19298-2-prestwoj@gmail.com>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20221118211624.19298-2-prestwoj@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi James,

On 11/18/22 15:16, James Prestwood wrote:
> Search for a key by type, keyring name, and description. Returns the
> key ID or an error if not found.
> ---
>   ell/ell.sym |  1 +
>   ell/key.c   | 46 ++++++++++++++++++++++++++++++++++++++++++++++
>   ell/key.h   |  3 +++
>   3 files changed, 50 insertions(+)
> 

<snip>

> @@ -283,6 +303,32 @@ static bool setup_internal_keyring(void)
>   	return true;
>   }
>   
> +LIB_EXPORT int32_t l_key_search(enum l_key_type type, const char *keyring,

How likely are we to search some custom keyring?  Wouldn't we generally be 
searching a user/default user session keyrings?

> +					const char *description)
> +{
> +	long keyring_id;
> +	long key_id;
> +
> +	if (unlikely((size_t)type >= L_ARRAY_SIZE(key_type_names)))
> +		return -EINVAL;
> +
> +	if (unlikely(!keyring || !description))
> +		return -EINVAL;
> +
> +	/* Find the ID of the keyring */
> +	keyring_id = kernel_key_request("keyring", keyring);
> +	if (keyring_id < 0)
> +		return -ENOENT;
> +
> +	/* Search for the key by type/description */
> +	key_id = kernel_key_search(keyring_id, key_type_names[type],
> +					description);
> +	if (key_id < 0)
> +		return -ENOENT;
> +
> +	return key_id;
> +}
> +
>   LIB_EXPORT struct l_key *l_key_new(enum l_key_type type, const void *payload,
>   					size_t payload_length)
>   {

Regards,
-Denis
