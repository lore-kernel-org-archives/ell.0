Received: from mail-qk1-f181.google.com (mail-qk1-f181.google.com [209.85.222.181])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E803118AEA
	for <ell@lists.linux.dev>; Fri, 26 Jul 2024 17:55:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.222.181
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1722016507; cv=none; b=YzzFHS5ec7tvezJhXeY1oOaLeBn0s4ot0jaC2FYBYHxd6wC2Lnox9qsW1WdIvhw1Ybp+pbcg5d9YoYXnukSEckr5GjzQT4jlPSe189vx3hiuZYhVHT9ZCxOjWS3KYd2NtJhQVHjSxvZBBqEt14nXu0OWyEr06wMskDhQW6wZCkA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1722016507; c=relaxed/simple;
	bh=4uPc2CEvBpjUAFZMtOBr/3ysvv7a3tmQNQoQssCLy5U=;
	h=Message-ID:Date:MIME-Version:Subject:To:References:From:
	 In-Reply-To:Content-Type; b=oQMZcT9KOycgtw7taXAUrJTdj//GriFtRymUpsmVfrVYJFZpSK/fyiFFrNj+dLny1VYM93Ng5gm2YhlbdBgTILxeuUkoFJmqBopLWEHCb4chUx/uW1GXchtjdnOPJzosGexfkMj4iLh4NzyyDVDD7QdiZ+jJgkOtVYPI/C2dL5s=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=AIS56kSd; arc=none smtp.client-ip=209.85.222.181
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="AIS56kSd"
Received: by mail-qk1-f181.google.com with SMTP id af79cd13be357-7a1d984ed52so64715585a.0
        for <ell@lists.linux.dev>; Fri, 26 Jul 2024 10:55:05 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1722016505; x=1722621305; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id:from
         :to:cc:subject:date:message-id:reply-to;
        bh=uhaIA6BmmqWQhK2C6J4T76NIZenCKRCf7Tm91k7dpTw=;
        b=AIS56kSdpWPDoi6HA2fQ7ZfLbB+s2z0hcql8vVl9+LEgc1LGX59gvhwZMkax9eB90m
         vhHJWdMetxx/AyrIFRY7ff18NRgjYBPII0amo7cH7xpeUuAQxR9/Woonz6J0BlnfdMlT
         RErb5rEadAqCO0c4FJAggamXYJnb4O2KUE1nhpqvrYFOPCv++LZPeImJih9wabDfIUew
         CQ3q70/1yVxUly44WR5DhwVdUSUTH+QXKbW2kqFK0ovsftRH3vKda3B9OItz8IDMr2TB
         b4IDAWYXPE8y2lqr0LpTgMWYU5mN0JRJTx0tEZ26PbQBF9mXzMkGXF7f/boBzoPccmqS
         aNcQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1722016505; x=1722621305;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=uhaIA6BmmqWQhK2C6J4T76NIZenCKRCf7Tm91k7dpTw=;
        b=u+JnXTRVmz4+bdLxAymF/NkHPJu6OEMCLppf+rsWuldCqc4oKI9irXQSzu9xvAanQ9
         L4nHbnxH+GSjaMl8ncykwilS7ahAVCJqdoTQjpEXz/eoEMstjCZy+t07Px8XpPZoFPU4
         YIZOW/dognlEorYK1nIdoVyVDdH7lDP4RQe3kFS7Hu4Wsv3WxYd4pOhpc2RNFP9sLeqW
         vsIP/BjcQ1pNxDRHAfiTn6X7g2zA2Hi1afrjkAtnzgQyFQlejyiD9kjtyQBOO6Ywg+xv
         raacCdffd1rqsZwU78XSdcx0PA9OgoefOSn2KKD2p9RaT39pxHjLsOixVLUmT/nrEIGt
         JMlg==
X-Forwarded-Encrypted: i=1; AJvYcCWd/Z9CM5R7IsuwCwirXyyAJkpJuTgz5fLE+/ijctY0bb/YGeujuyYc1iomS3l4WDNuZofRXFmyXVJxnbpZ1x1zYpxE
X-Gm-Message-State: AOJu0YzKNlzCX56V/Qm0mtWEXxyVTqTRulAkbgZURfJpFfm0pW0l9hdS
	IrkcULe/yYvDYoAV0v36rKz01mqKcIYNTN7lbBq6PoIpCzzjZY/p
X-Google-Smtp-Source: AGHT+IE9gx1pmTjuaOLkDAREfUAm+cZsZYCTf0C+yXJ52/gwo687+waqX+E14ILbGQo1WcPkXmXzOw==
X-Received: by 2002:a05:620a:4488:b0:79f:741:5d56 with SMTP id af79cd13be357-7a1e522f8b6mr65393285a.6.1722016504559;
        Fri, 26 Jul 2024 10:55:04 -0700 (PDT)
Received: from [10.100.121.195] ([152.193.78.90])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-7a1e146a506sm59815785a.4.2024.07.26.10.55.03
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Fri, 26 Jul 2024 10:55:04 -0700 (PDT)
Message-ID: <e60cc267-481f-4a0e-83f8-8f0e49290d97@gmail.com>
Date: Fri, 26 Jul 2024 10:55:02 -0700
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH 1/7] netlink: Remove pointless checks
To: Denis Kenzior <denkenz@gmail.com>, ell@lists.linux.dev
References: <20240726161232.146982-1-denkenz@gmail.com>
Content-Language: en-US
From: James Prestwood <prestwoj@gmail.com>
In-Reply-To: <20240726161232.146982-1-denkenz@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi Denis,

On 7/26/24 9:12 AM, Denis Kenzior wrote:
> command_queue, command_pending and command_lookup structures are always
> initialized at construction time and are not destroyed until l_netlink
> destruction.  There's no need to check whether they ar valid.
> ---
>   ell/netlink.c | 8 --------
>   1 file changed, 8 deletions(-)
>
> diff --git a/ell/netlink.c b/ell/netlink.c
> index 024740b62fc3..26c31679e4c7 100644
> --- a/ell/netlink.c
> +++ b/ell/netlink.c
> @@ -410,10 +410,6 @@ LIB_EXPORT unsigned int l_netlink_send(struct l_netlink *netlink,
>   	if (unlikely(!netlink))
>   		return 0;
>   
> -	if (!netlink->command_queue || !netlink->command_pending ||
> -						!netlink->command_lookup)
> -		return 0;
> -
>   	if (flags & 0xff)
>   		return 0;
>   
> @@ -471,10 +467,6 @@ LIB_EXPORT bool l_netlink_cancel(struct l_netlink *netlink, unsigned int id)
>   	if (unlikely(!netlink || !id))
>   		return false;
>   
> -	if (!netlink->command_queue || !netlink->command_pending ||
> -						!netlink->command_lookup)
> -		return false;
> -
>   	command = l_hashmap_remove(netlink->command_lookup, L_UINT_TO_PTR(id));
>   	if (!command)
>   		return false;

These all look good to me visually, assuming they pass autotests (once 
the update to IWD/netdev is done)

Thanks,

James


