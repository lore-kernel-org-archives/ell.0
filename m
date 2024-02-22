Received: from mail-ot1-f45.google.com (mail-ot1-f45.google.com [209.85.210.45])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BF67C14AD33
	for <ell@lists.linux.dev>; Thu, 22 Feb 2024 14:49:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.45
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1708613402; cv=none; b=R4MWjzpyLlJtNukzaXUOaJu1RVIFxEttaGt8FNqMx5PAEI5DXsO7ORLNU8Og7F7W7DJETpjoyRF6mQ9+oZL/lZsDoqrJSrlmdwRxlChShwAAX/JSD7+Kr8s+UDM06Z/+jHa81UvWSUUCfPAFp5ba7w1wtw5M4dNfEwpMxgESruc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1708613402; c=relaxed/simple;
	bh=LaVJitB12SLdDMRWIenKcWWUzS/tzAp0zecfjq28Vbk=;
	h=Message-ID:Date:MIME-Version:Subject:To:References:From:
	 In-Reply-To:Content-Type; b=XWe0hwl7r5Tpmr5K77O0mmYTszhaGZ7CgAJVPW7Rlr/Ja5Uo5HF5zvd3W6miQXR7YzWtcy1Wgttrmvqv2W4O4pb0K4nv+WjelxqeRop5EsIYAS3DyZzks8+n9LReB7mOwS1erdsd24CqKsztSrpLmfs6AqSUnvHyU5uR6nOmdoE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=Mg2QM/AX; arc=none smtp.client-ip=209.85.210.45
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Mg2QM/AX"
Received: by mail-ot1-f45.google.com with SMTP id 46e09a7af769-6e47a0fad63so106732a34.1
        for <ell@lists.linux.dev>; Thu, 22 Feb 2024 06:49:45 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1708613382; x=1709218182; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :from:to:cc:subject:date:message-id:reply-to;
        bh=VrVtbicgMby6mDi3IGbCY7IYIRLl2bTi50Dk+Kj8Crw=;
        b=Mg2QM/AXt9M7OolqPzNmYXuHd5Ep0/D6aYd+96kjiqLf0Yr43PfbRsbkVrr23n9Ge4
         +h03gSPSKkpXhidE5XnbH3edbunS/ydtdhTbzirKexnB6kbQqxUmueg3BGJg861m0MPK
         DEH5ld+399frbkAY1IIljGYMVYzgbaGCI8s0tCiDsKcfoCkbFf73U9efFTookhXZXf1q
         l8foifbLZyQ+ohTRl2sF5l9fl3Q9vqAiGb5sPPyq9Cpu0zyg8RGjCAdwU1HoRN45ncYR
         meBI92qArZH9rhC3iISoV1tm85mtvFxTzGNHvYcIYZMPQPBX34D+2Vefw8QjmuP8S1YT
         mT+Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1708613382; x=1709218182;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=VrVtbicgMby6mDi3IGbCY7IYIRLl2bTi50Dk+Kj8Crw=;
        b=i3fiV27FEmeKa8B4b3fm6Z0DTbV4O55Uuhp9ZjlXC0HsSlik1WGGCun3Sr0+XhdDbH
         ixZxHhWHTj7jivgo343TLwqmBizDfwE2VJ+FLdwuZTyFu+lBUT4OXRZk+BzDTMzPSaEL
         a7fkI70zIg6joC9PtpGieVxySQ3Er7IGDDt6Bd044hpFVS6fZdZC7RvS0n5ZCHCXs0jQ
         n9sAozHftzjh/kBc0lUWaWQtQLfyFGtPHnThbu5b63rU7g6S6QQhuRkuvp3AShYj4BFZ
         QJQH5gnx8OAmhSt+4iBoNiyd3VGV98Bzj/GBWKzgsr3CJlsfjbl26ZwrhPpJ+cxrWElB
         490Q==
X-Forwarded-Encrypted: i=1; AJvYcCXjobWSh6l58zkuJGPulU/QVg3zQlkrOYiaSzqiYjiT1JCPJDegUoRyMYdlRyM1wO51sBb1FmYIx/ER4p9cRhKdgwIw
X-Gm-Message-State: AOJu0Yx4a1Y0KRo7UKwMMhajyeJUsDerpmK9HDRcwP7JvI2tIZbLH2LK
	He8JksBxajsZBL2qiyInmj6usSQF5MXWtxzYwb7K/KdWqH9wH0yF
X-Google-Smtp-Source: AGHT+IEd+MBAsmu7jZYbM+0mgIap3PSHgq0yCVFCFNYR4JjQJaU9KxdiYGHMAj0rwaCWgxZV0Ojv4w==
X-Received: by 2002:a05:6830:7318:b0:6e2:e719:ed53 with SMTP id ex24-20020a056830731800b006e2e719ed53mr1361605otb.3.1708613381886;
        Thu, 22 Feb 2024 06:49:41 -0800 (PST)
Received: from [172.16.49.130] (070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id q22-20020a9d6316000000b006e2f3ec7a71sm2030262otk.64.2024.02.22.06.49.41
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Thu, 22 Feb 2024 06:49:41 -0800 (PST)
Message-ID: <bf4e05e5-ec1c-4e30-b29f-8a2ce638d4e8@gmail.com>
Date: Thu, 22 Feb 2024 08:49:40 -0600
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH] pem: fix typo in a conditional in pem_next()
Content-Language: en-US
To: Ram Subramanian <ram.subramanian@getcruise.com>, ell@lists.linux.dev
References: <20240222003549.786095-1-ram.subramanian@getcruise.com>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20240222003549.786095-1-ram.subramanian@getcruise.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi Ram,

On 2/21/24 18:35, Ram Subramanian wrote:
> This conditional is supposed to check if there is an extra (whitespace)
> character after the ending boundary of the PEM. However, it does not
> accomplish that goal as it is written because of a typo.
> ---
>   ell/pem.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
> 

Nice catch.  Applied, thanks.

Regards,
-Denis

