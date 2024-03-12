Received: from mail-ot1-f47.google.com (mail-ot1-f47.google.com [209.85.210.47])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BCEF2944D
	for <ell@lists.linux.dev>; Tue, 12 Mar 2024 03:12:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.47
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1710213168; cv=none; b=EubREZBQVFIn3tNSrggDxUO6BVucryqW2UTxPtwQM1b6SZDNmbXWpuXxNc+zgQH9NOsMH0Yuez+iIMw0xjNf0LxJCDUpBx9RMO/8s8OBmQoi0W2LUW/oM64AIIuUjSVRkILyr3vwIJRB4NfBq57ZAlXwmewi8G4aPuBCnWc5R3U=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1710213168; c=relaxed/simple;
	bh=aycdbmZ1uIRthl88g7XdDTabFq6KisA1AArE9lS3350=;
	h=Message-ID:Date:MIME-Version:Subject:To:References:From:
	 In-Reply-To:Content-Type; b=ADrpSWbtTzgwDLwf4SnjvmBwEZDo84leVN4wqIKcIpzHO2L7uttd3YPA/AavTbSmjngKDw2pSJWMrdUjLlL8BxxopzmNmcTbPQ8NeWRGCiyXEMwr8cvPyOYqlIMT8UCFBE8624hBkba1A4qoeY0oMD6CMSxWUU1r+bk6luALC5A=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=ALp79cw8; arc=none smtp.client-ip=209.85.210.47
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ALp79cw8"
Received: by mail-ot1-f47.google.com with SMTP id 46e09a7af769-6e519d73850so2545024a34.2
        for <ell@lists.linux.dev>; Mon, 11 Mar 2024 20:12:46 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1710213166; x=1710817966; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :from:to:cc:subject:date:message-id:reply-to;
        bh=Mr03+8AayUNInhvHYKEGBwYA2YdoM0nYrrkrZuW7Y5o=;
        b=ALp79cw8ACYna3UFaijtDj3Fc9bEB9qawWoFMH3RgJvXitW07hPXJ6ygoyDESpzZus
         /tTr+nrzK3w4ohmXrX8WKFUl8/fxCheFStSskwd4gAneZlYjM8xVZ89eSztc5WKdnMwB
         jZXF0u+P99U0KELZbT6VQcrT0eH3YLJ9GBI1K6IAxHNezxQNaspDNyQNyWW7Bz5H+8su
         oB5B++jc4swiu3iL0VN3jlThF32OXVvaL5Ifm5g9oRnPAC+wEhIFIW5CFQhX6KYbbJ9b
         jJmSdum/SsQjwH802ed7KJuUfgq1StRfVpEu8x2T1boiMDJrFmMVDiComgQ43BkvYG4z
         8Rrw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1710213166; x=1710817966;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=Mr03+8AayUNInhvHYKEGBwYA2YdoM0nYrrkrZuW7Y5o=;
        b=U5/Nn8XSVVcgvyTuvfY48I5wSWB/ljyxKjJDBQfyWo1ymzd3wNoRc5QB5BL1rcDX6P
         kHrhxl1j20zW9Ia95TTKVznIa1sfIN9DdNPa/SSUFtqJ6bnUjAOP30bq5CaCjOjF5e6Z
         jurN9Bd3bnj21hXaGMdmX8NkL38vDVkJvE8Z0xXRLss6uaT1UHtDvD3NcC40CTzc6Kwb
         v9D7WdYF5DbsGsAOH1prEl25kIa495qPYZQolMOpucMj7Ust9nr6RKluxd7CoU/b6x17
         L5DcjS2xcXry3aoY4FAFT2fu/kWudN2y0jxLQsJSVRw5aqsfZRqNJ4pw63T2YiLl5qc+
         grAA==
X-Forwarded-Encrypted: i=1; AJvYcCUY3eVpk0NjVvVL5d8BvcDYb/7NBHeEGRQJ1i+Vpbcv5GLxU9dAzUDj8eMo/jMhHe8UxJfTCrYYPZlQlys4VJX1fOMm
X-Gm-Message-State: AOJu0YynAVyPMNb2FC68eZLiclaUBue1i4xfZtzDOx0XDgv0+dnlLOVP
	cI1AEXfWINCwI9r2mTbV9PY0opUXJlrUgkAi/TZrCyEWCRrqCV/fgsN3F1v7
X-Google-Smtp-Source: AGHT+IGQOGvxcksSBo9u5GgSci6/Je5aQs8TLwRX9dYIaJ4ERxLvAoc6TeOoxN6TC1lYGs3r9pORyg==
X-Received: by 2002:a05:6870:d182:b0:220:f92f:5bf7 with SMTP id a2-20020a056870d18200b00220f92f5bf7mr8282301oac.50.1710213165668;
        Mon, 11 Mar 2024 20:12:45 -0700 (PDT)
Received: from [192.168.0.50] (ip174-73-27-232.no.no.cox.net. [174.73.27.232])
        by smtp.googlemail.com with ESMTPSA id hb9-20020a056870780900b00221df0eb6f9sm1276799oab.28.2024.03.11.20.12.45
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Mon, 11 Mar 2024 20:12:45 -0700 (PDT)
Message-ID: <ad6421be-e29b-4a67-88b3-48bfb6dd1f8d@gmail.com>
Date: Mon, 11 Mar 2024 22:12:45 -0500
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH 1/5] cert: remove usused elem_data variable
Content-Language: en-US
To: James Prestwood <prestwoj@gmail.com>, ell@lists.linux.dev
References: <20240305132807.85724-1-prestwoj@gmail.com>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20240305132807.85724-1-prestwoj@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi James,

On 3/5/24 07:28, James Prestwood wrote:
> This was being set in the if block, but never used after that.
> Instead just check the return value directly.
> ---
>   ell/cert.c | 4 +---
>   1 file changed, 1 insertion(+), 3 deletions(-)
> 

All applied, thanks.

Regards,
-Denis

