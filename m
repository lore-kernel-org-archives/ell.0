Received: from mail-oa1-f46.google.com (mail-oa1-f46.google.com [209.85.160.46])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F03A8137928
	for <ell@lists.linux.dev>; Thu, 22 Feb 2024 21:59:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.160.46
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1708639197; cv=none; b=L1nNENediLGtI3WhxnrzuEvS9YWIPd/kmjHiMA4Zc1JDoYE600D/jepCqUsgQgWxdyzOs7Wj7sXCPwvvIXGKJPEykUHHhs3+tkea+qgGxbwTAqZfJUoTtBuPCZz1VZnR6WowYPT0XlGU4g00SZkVAaqD2E647iAqtrw+WQ793Ng=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1708639197; c=relaxed/simple;
	bh=QnZjm5txkRRqFLJwRuy41zHBD7K98d9JUQsQK3y3NpY=;
	h=Message-ID:Date:MIME-Version:Subject:To:References:From:
	 In-Reply-To:Content-Type; b=tkGnjbIOoUp8CSHdgNPjpNcqYDnkmG2LdeCRF6RkfJvHHWPL6HvhFV11pyfY4zDYjgI0+GtbsqpNA9fySyQGEfb6PNhdEwSwSF/UoXvEyFrDrC9bN6JbFB4dcnLSpOumu7tdFny90ep3BBVzsveSGGe0IK828NdJdbF8wif8iuI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=HPD+1EvY; arc=none smtp.client-ip=209.85.160.46
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="HPD+1EvY"
Received: by mail-oa1-f46.google.com with SMTP id 586e51a60fabf-21e8a740439so544434fac.1
        for <ell@lists.linux.dev>; Thu, 22 Feb 2024 13:59:55 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1708639195; x=1709243995; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :from:to:cc:subject:date:message-id:reply-to;
        bh=+z5Ue0cu4iAsx2GtXpgOpr9y7jEAV0+/LSHUwdb5/pY=;
        b=HPD+1EvYEHR8OokDlBbaUZIgYJlX2wg08MLnIZmoX+j8K5PN6L7la9RV0TGqTrF8aq
         KX49kekbLO9WO3IcFLKdecCNgkE9+fdUeTnxETCr6BVbBAr7iJDq7lu+uxps4ey5Ewy+
         6Ue5SZx5qz9gYluS1tpJ/6lUpK4Jb3bCW0lv9HISGFwJrgF2bsrZ2Ue8pGZMKCeig5Pb
         V0CbXeg1LQGXcpXJl3ww4fcFBceCy17cRNvpkydzv/hK9dl3cRArW1xPYb2lGE05ReIi
         vShL/P89q2204JEbT3KEjtn1BgN62y+WmNRvVq6fbk4g/3kHiv1TZczJWV3I+TtaQnoG
         aIqQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1708639195; x=1709243995;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=+z5Ue0cu4iAsx2GtXpgOpr9y7jEAV0+/LSHUwdb5/pY=;
        b=IpKIoDuFNzAgZlTOzzigsNKs+zCRZo5qjpNk+Xjs+kR6YY4SJbmPO1mRJ7ro6ViG51
         oBPEsMbm3GBHl5UJqUVa0GEDaWkEYMeulr34k+2Tyfe/14dJNxF5m/uD2L2Ail8a6pcq
         Ef/gd8AYWz/x4/PjYqGK9wtsN9703QisGguwwctAvASCvHczp0dNrTtXNFwJOAgz/pU/
         /s23UfA5o2J9gy3tsNmq7SgX7WX9pIjI7kual0bqu553HfxGSQkGUvHzgaTWaTs6wNUM
         DCmZ32QGWnE1Cd2oMYCVs6B2qtoxAk1lZUpvxAdNV5qDlTEfBBBxDpTvzzlGZvcrNTy6
         YpmA==
X-Forwarded-Encrypted: i=1; AJvYcCUwvQeiaI8k+cs7JzX9IMhb5xh6aNKUMXsdV+tM7J/X1/ZIYO7kzcJ2j+tatTi4p8hpzSwm6+2N4fKzbLoEvCRyIRcQ
X-Gm-Message-State: AOJu0YwKQqHSuP8arYoQtA9QL6xCrVfHxZRTcgTDG3k3r/ru5jCNQjR5
	5k+HgQWAd2/Uw0tA7I8yk7qYPfZdlo/UvcDNXZO+5XscnOXrV1Qq
X-Google-Smtp-Source: AGHT+IG/viychpDtfTCR1vJBx8AVIKC1bpwjblgbYgSyO9fEMR8M9NT71TOsJCrZSPbGECLdZX5ufw==
X-Received: by 2002:a05:6870:51c8:b0:21e:c34d:1963 with SMTP id b8-20020a05687051c800b0021ec34d1963mr1790483oaj.23.1708639194764;
        Thu, 22 Feb 2024 13:59:54 -0800 (PST)
Received: from [172.16.49.130] (070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id k17-20020a0568301bf100b006e47fd908absm63127otb.5.2024.02.22.13.59.53
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Thu, 22 Feb 2024 13:59:54 -0800 (PST)
Message-ID: <b61c8fda-0b9c-4263-9b20-f4f5effee838@gmail.com>
Date: Thu, 22 Feb 2024 15:59:52 -0600
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH] queue: Fix names of l_queue_match_func_t parameters
Content-Language: en-US
To: Steve Schrock <steve.schrock@getcruise.com>, ell@lists.linux.dev
References: <20240222205327.18929-1-steve.schrock@getcruise.com>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20240222205327.18929-1-steve.schrock@getcruise.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi Steve,

On 2/22/24 14:53, Steve Schrock wrote:
> ---
>   ell/queue.h | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
> 

Applied, thanks.

Regards,
-Denis

