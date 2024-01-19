Received: from mail-oa1-f47.google.com (mail-oa1-f47.google.com [209.85.160.47])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 71FD75381
	for <ell@lists.linux.dev>; Fri, 19 Jan 2024 03:14:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.160.47
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1705634048; cv=none; b=na9t7iG4Id6jBlGEevzzbeh+eDho025rrhodFqQTwMN/N0CNfahHWjWRxdjVT87PpsEZlbNY+mZJM94aS7AulYbAewQl1c01Ylvsz0Ys0wbB5sWrM+HL1u8tbXuxylEdx5petV2Y/Mc4a8/Dt8w7bDiKqqX9JmpqzFqzanyd1HI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1705634048; c=relaxed/simple;
	bh=yATlcUZOvnX3OLz1ZptYJdvFIPbqf2fqS56E4dvswKA=;
	h=Message-ID:Date:MIME-Version:Subject:To:References:From:
	 In-Reply-To:Content-Type; b=U5uHL1KSiKmcj31L2Gy5LHBreAFYfqhgMOcFhD1sQPb2TUJfP0Cff371nb9JukfjZd6MPJ7PtwAMRRr9lqxnpzvS62Np4qwlQVKL80BHeoZFhD+iNv+upZdnRa01Q3xBwMczvpWz/fLsp6GmvrE8W1qNC6Onc1x0dLG0IXFScvs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=AqKGyYRr; arc=none smtp.client-ip=209.85.160.47
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="AqKGyYRr"
Received: by mail-oa1-f47.google.com with SMTP id 586e51a60fabf-20536d5c5c7so281636fac.2
        for <ell@lists.linux.dev>; Thu, 18 Jan 2024 19:14:07 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1705634046; x=1706238846; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :from:to:cc:subject:date:message-id:reply-to;
        bh=wdekujmW7l2iV9zzIZzgpmtIQHOYjPhos9zAslE3bTc=;
        b=AqKGyYRrpGLoeDScBK9hAB35aCi6Wy1M3XowBEZUDtnCaewrw7dSJww+G7wAxBuiZd
         OFFxId7KdTlNMwO6R1iTcRZTYTXlcahsu+8JfftzRktI4Hr8fC9II8f3De0YPYOcFWKC
         dBJGj8eWRJQpsr45u3khlSFbGi+sqznG/CXxyxekj07tO+ofrIp5bx0hi+W6ZPaHhGfq
         qINlEKSSjjXZRlxzRfhmcfRDYTqPQQZ9XdSlfZzsGQSmAHpZSH5LV/i8C5Co2X2ZH9lc
         uY6EqlORp9lWe/yMTTYqwauPZ4LHbzBLfLkWpTXA/ykhDBzeuRoxJrwun7V8WU8S+/tu
         a1Dw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1705634046; x=1706238846;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=wdekujmW7l2iV9zzIZzgpmtIQHOYjPhos9zAslE3bTc=;
        b=XgaNmD7ugKUHsSZFyKqKvMSQSFi7g4dH854UB5b+R4N+0zDWlpqmjzxYex5xmcQQoy
         YA78nmdK53LbGQ0Jhff+W6I2kHonyD2drbQD7tFyKVpfshsNSAngakSkxpGQ6AIaXWhO
         LPZP2kab74mgijjd1SNZUjinKYWqmczyIniF9jL48vi+zuyyGnyCxn3LSdwcMTsWIDa2
         mL4O/SYK7KNIfRb8noPddE4F9hp+YJqDBOXrRuObTD88GH8TZEcsQVAWTzbP/N1H8kJa
         mmJU8FGh9c12qop6GG2wOmK064H9JM0I2CoDZsumq4y8W28LoueEDMlL27KOYFmUCXAQ
         zBng==
X-Gm-Message-State: AOJu0Yy7kpHHwTBWSTFKZKrhZznVK5UpdrSWgL2DDD6bu5CsVSeVuleZ
	TT1Zw/iAZnchsP+EYxGS7ZMmSwdRP/nbWZx36pbuaiaUVC/9Cgtt
X-Google-Smtp-Source: AGHT+IG0iKFXPBDKVGex8NK7smV+19sRnCyTFXd2pS8iEjTZFTAwqzRiZlmNK7QJ5l4tAmqjs8y3yg==
X-Received: by 2002:a05:6870:4e01:b0:210:9985:7894 with SMTP id pl1-20020a0568704e0100b0021099857894mr1908403oab.106.1705634046199;
        Thu, 18 Jan 2024 19:14:06 -0800 (PST)
Received: from [172.16.49.130] (070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id qc3-20020a056871e7c300b00210afb409d1sm708814oac.30.2024.01.18.19.14.05
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Thu, 18 Jan 2024 19:14:05 -0800 (PST)
Message-ID: <6e9a67ae-fa62-4ada-a50a-a6a3c1856531@gmail.com>
Date: Thu, 18 Jan 2024 21:14:04 -0600
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH v3] dhcp: add settable max attempts, fix timeout overflow
 to zero
Content-Language: en-US
To: James Prestwood <prestwoj@gmail.com>, ell@lists.linux.dev
References: <20240118150818.49012-1-prestwoj@gmail.com>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20240118150818.49012-1-prestwoj@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi James,

On 1/18/24 09:08, James Prestwood wrote:
> If DHCP is in a SELECTING/REQUESTING state and the number of attempts
> reached a value where 2 << attempts overflowed an unsigned int the
> next timeout would become zero, causing DHCP to never retry without
> any event notification.
> 
> The number of attempts will now be configurable, but limited to
> between 3 and 30 which prevents the bit shift from overflowing
> 'next_timeout' and provides some ultimate threshold where DHCP will
> fail instead of try indefinitely.
> 
> A new event was added (L_DHCP_CLIENT_EVENT_MAX_ATTEMPTS_REACHED) to
> notify netconfig of the situation. Netconfig will then send a failure
> event and the consumer can decide how to proceed.
> 
> Fixes: f130c448 ("dhcp: Introduce timeout fuzzing")
> ---
>   ell/dhcp.c      | 35 ++++++++++++++++++++++++++++++++---
>   ell/dhcp.h      |  3 +++
>   ell/ell.sym     |  1 +
>   ell/netconfig.c |  6 ++++++
>   4 files changed, 42 insertions(+), 3 deletions(-)
> 

Applied, thanks.

Regards,
-Denis

