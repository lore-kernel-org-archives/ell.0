Received: from mail-oi1-f178.google.com (mail-oi1-f178.google.com [209.85.167.178])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B27E016DC28
	for <ell@lists.linux.dev>; Wed, 21 May 2025 16:28:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.178
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1747844920; cv=none; b=XJGb2dllwnDv2O85Q9WCCeqwB7SoBnnvvPAST0VQordeOYNh44JAqqRTkcf9aMaIYMbzDq9RLaC3Fgjgig3xsELOlmcbk5/IR+p31zUHClnuKnHUgSaR2McKSRIFlpX3v1WHb9ZpRDm3NuZjapVfwr2zsHxO5IlkKQQ6f9E/IVk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1747844920; c=relaxed/simple;
	bh=8vrF5DitHXAaS91tv74C2VrLVc70VVx3sIT6ADKEb2Y=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=b6lOWparoghWmvU0MtPt6W2CvgupoY4NDPnLX2+BDq6pzfnCkIn51B4DffNwUlKwM+bQl7Iwwy8RQqwt3Lopb+kywe1KRUl+4CcJOAgTKW0GEsUAhODwyAIBnbqBIFZ6NKJFguisncxme1h/SlSd+UFqXAmgcVoAfQB9YG6Jy94=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=NZTq49Pe; arc=none smtp.client-ip=209.85.167.178
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="NZTq49Pe"
Received: by mail-oi1-f178.google.com with SMTP id 5614622812f47-3fefbbc7dd4so5169625b6e.2
        for <ell@lists.linux.dev>; Wed, 21 May 2025 09:28:38 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1747844918; x=1748449718; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:cc:to:subject:user-agent:mime-version:date:message-id
         :from:to:cc:subject:date:message-id:reply-to;
        bh=RR5WrSlniLMmBMgsiHrE33JVGdU2baz/fOOlBX96AMY=;
        b=NZTq49PenoPphFbaGIKI+IFkkM/vc1ZZhlYhUUkf7fQiqDj4EzJ4oAVQnm+araapBB
         BVjTOG5soMrLjjjrx9OBmaiRmXQrfzJSa5/JIwzZgrH1EkGloLQxC/4rpohc7OM8QYs5
         4pI9rUrSkrmnU75k1GpRvU5l9cOXq8KNkr7/ADQflm40sLJN6y07csmv8VF4GiEPunP9
         Rs4VQ1OEn8sABAlwHmne1V8uHmMGsy34t/Ocjxk819JkoiR2H6B1xYCz08d99JJa9Fxd
         l7FdBHsX6S9uw4ufNKBw0xQGejJnx9OFIwpDfDiRX8TvikNmZ96jMFFvMVXf7Z3ABjBH
         OG7Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1747844918; x=1748449718;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:cc:to:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=RR5WrSlniLMmBMgsiHrE33JVGdU2baz/fOOlBX96AMY=;
        b=sazqJrXF8f9FjGaCYZbL9tmho4E45avYZwmNZ7qsc0eZFfi3yv1L1qjT6dp+4l0aFY
         E0cgqo8hxBiVaqO4hb6/5sm01Wslm0x5ksrf/VgkH81vmygZUifTlA9V7G3HOM6ehRl4
         wWAS1vXUebnhLMqOyQmbEz4t12ke8uL2OWMvTXJH6FBvxMI7Zntp5Be/OxGa/71e+IV/
         C5ThQe4D1nKVVe7pG3qXoykCZvEcH1T0G7k5GAikcVLHSJQ1rcba0Xe7hCqRLSIp4ONT
         B+RL6CZpwcKgXsnmdCsdckUg7yr70lMWbNj/Ykr/W/uflbp+lPjb6c3nmX5e/eIJSqaH
         oSUQ==
X-Forwarded-Encrypted: i=1; AJvYcCUbiMRPHLEVGENpUiJ3o2GFYT+jXVfIfgjvVem9kLQxWR60YrMrIGeiOGJLhIfyRTjJXM4=@lists.linux.dev
X-Gm-Message-State: AOJu0YzjbzOGQQ2L0BzSMjaE1NhK3QGuTdBATlUrRas6P+I++aCqGoQx
	l+WTtUf/UvkC1rILo3F9k2KegEoEcFmKCwSAJNAxlFRwkH0F1WyPlOXPOMJrHA==
X-Gm-Gg: ASbGnctZ6D1DsdktEmiWtnOWlxbmvd/eKFxrJBB/7fiydeW2iHHLB7y7bKKj2pX/Lxp
	aBCLSvssCm7LVqhYZ7T9i/7yxMNvE/voQjNhwPI1qPIopo8UTWBAl71kQZwpByvrYdx891hFZqE
	rajvO37+vZrzg3rmMQhqiJE9klSSRw+PuXn9FKIve5nqhZV62kaYHoKnr4ya5gWKkiFe7kWC3fx
	DK/Lzojvu2dbuypnEiU/C2sljdryrvgVl+JRAl1IoVXipb9Cja2sBo0LMDSoKx1n2LRywotovR8
	2fidLwZiO7SeT8CE8SpEj8yPneohm0Jkj3oeErhR0Kq0n3TqPgI4537seGAzV9Fsj17vJIBHL/k
	zafx+vqWmae8ROXvt
X-Google-Smtp-Source: AGHT+IESyoJ3Pt8ltxknERCVlasA3W4+ULrnF2mF8jftrHpum3qyIkF02/0gvcj3IOckEPpCpbGN3A==
X-Received: by 2002:a05:6808:3c4e:b0:3f8:3eeb:11a3 with SMTP id 5614622812f47-404da71561amr12450156b6e.11.1747844917627;
        Wed, 21 May 2025 09:28:37 -0700 (PDT)
Received: from [192.168.1.25] (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id 5614622812f47-404d98b18a9sm2194285b6e.31.2025.05.21.09.28.36
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Wed, 21 May 2025 09:28:36 -0700 (PDT)
Message-ID: <4866ec9d-c5b8-4578-bd85-01b24e7ef0ba@gmail.com>
Date: Wed, 21 May 2025 11:28:35 -0500
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH 0/2] Fix ECDH P-521 test
To: Sergey Trofimov <sarg@sarg.org.ru>, ell@lists.linux.dev
Cc: marcel@holtmann.org
References: <20250521-more-random-v1-0-997802b3052b@sarg.org.ru>
Content-Language: en-US
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20250521-more-random-v1-0-997802b3052b@sarg.org.ru>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi Sergey,

On 5/21/25 11:16 AM, Sergey Trofimov wrote:
> When building ell, unit/test-ecdh fails 8 out of 10 times. This appears
> to be due to the `l_getrandom` function. The return value of
> `l_getrandom` is not being checked, and the wrapper for `l_getrandom`
> has not enough pre-generated random numbers, causing it to return
> `false`.
> 

Hah, nice find.  Applied, thanks.

Regards,
-Denis
