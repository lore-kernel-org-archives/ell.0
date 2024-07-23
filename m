Received: from mail-ot1-f49.google.com (mail-ot1-f49.google.com [209.85.210.49])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5ACD3149C78
	for <ell@lists.linux.dev>; Tue, 23 Jul 2024 23:51:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.49
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1721778688; cv=none; b=STEHQFXXuCA8vhr5S/56pmVwdAX3vCTNok2CCHc+ezbQjlWndmGtpySJoAQjhspCgID5VhA0Y/va97Dxv2p3JOmiKh/b3UhPRGhI3amQH+hquMkYlFdYeBWFPhtQdHOFGB2CNvx1oyKcab0H8atp/dhaztvjiPWnE4NwkidzZPM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1721778688; c=relaxed/simple;
	bh=MfkJQa5FLwHEY8L7AxiCmtpQXFQPd+pZX+SuSKoJS7c=;
	h=Message-ID:Date:MIME-Version:Subject:To:References:From:
	 In-Reply-To:Content-Type; b=S7NfvHYcKUCvzN6H4SdCQJh23pKGgZ2fCu+oaYMl4fnY7gMGkyuW48MXFfQrUq95aRF6QH+37qLOS2r3RsSq0p40BH4aoP+yPyG7TbgeFEkIveW9iGOG16D4B1+3wF42+CAw9e53suCdZXXethtQyBPa3VgjHp/p6xdFbOyMLFE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=h+B6DCNa; arc=none smtp.client-ip=209.85.210.49
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="h+B6DCNa"
Received: by mail-ot1-f49.google.com with SMTP id 46e09a7af769-70445bb3811so2943531a34.1
        for <ell@lists.linux.dev>; Tue, 23 Jul 2024 16:51:27 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1721778686; x=1722383486; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id:from
         :to:cc:subject:date:message-id:reply-to;
        bh=TOEbu9nwLCttidCQj+ZlcY/9dUR4kJZLMFNt2Jmt+zw=;
        b=h+B6DCNae5hOd6P3nl2rFBxY8CUczTaZ96htMaXQrqTR+1On7Phu1rjGkooDG5w5j+
         ddl5bhD0ZVctZp9zFBOQVzHzGg08KuwEMRWekYjiAIFvJXhb02ACa7wLqw246E0bldrx
         tdnQ8btLorcrLkS2R7CcOgwgo8K2XfDh5GzTQ377Ps6aF3G9UYl4JvECHWpMmnhquyfu
         j//EjqQJJuMORRhjmKwqJ0eJoOrKDSQbMaZIyOHqVwUArxcEcDnOcbm605DNl7OjgA/O
         RoJq9yt3q5zeSl9g5uNZgaLql2umcODlE/nyj6Y2AkR/5hGR1obx4dCocgYGSVykAq8t
         Ka5A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1721778686; x=1722383486;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=TOEbu9nwLCttidCQj+ZlcY/9dUR4kJZLMFNt2Jmt+zw=;
        b=MBend4GYIryqUgnDbu7BE1gyGIix48DMOWgeNI0jOdwVHwv0ygnC1aWUAORCOJc0i3
         jv4JG2f8LCYjOmfyJ0I1nXXoDwFvzP1Bu3yCF16APHtkRByTgTxwrMLXG3hXtdv5/dRg
         5vY50S/9OnPvSCdVKUleBgLOFGFXPmHHjX66co15XmtRuLaBeSchWHe2GgD2yMde8dYu
         gWzm75/rRfNrwlzxn0gMzLCzEgJfdWO45GpWkq3H+xfJ9kOnNdrVXjHjBPPCaTTIp67K
         8SiQZsXwUqtVRVfL+o7o935zw2r96nYhCUBlhJtwX5QfTYCZ/jFYDbG69fynGDTZM9bD
         UrLg==
X-Gm-Message-State: AOJu0Yy3t6LQU/63yj7a6BezZ0ZOcv68yzcXAiWtCuGXOW21A+fi8qv8
	nyhWyF7Hn4po7IhYJ6L3N1AielS3RLwl28d27e18fhtWgF0MrAzNXdip7w==
X-Google-Smtp-Source: AGHT+IFc0PNzOAJS2STHdHdeCJ7kOxfKCLS7PpErXzj+abgbU3sqH1pDMUM2XZS5F4rUx2bZxq1hgg==
X-Received: by 2002:a05:6830:210c:b0:703:6b2f:6d19 with SMTP id 46e09a7af769-709234a5a8cmr1905198a34.33.1721778686030;
        Tue, 23 Jul 2024 16:51:26 -0700 (PDT)
Received: from [192.168.1.22] (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id 46e09a7af769-708f5f97f39sm2224367a34.0.2024.07.23.16.51.25
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Tue, 23 Jul 2024 16:51:25 -0700 (PDT)
Message-ID: <4822a185-5487-4910-a555-d200a5f6330d@gmail.com>
Date: Tue, 23 Jul 2024 18:51:24 -0500
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH 01/12] useful: Add utility to find the next power of two
To: ell@lists.linux.dev
References: <20240722190443.43196-1-denkenz@gmail.com>
Content-Language: en-US
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20240722190443.43196-1-denkenz@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

On 7/22/24 2:04 PM, Denis Kenzior wrote:
> ---
>   ell/useful.h | 6 ++++++
>   1 file changed, 6 insertions(+)
> 

Applied

