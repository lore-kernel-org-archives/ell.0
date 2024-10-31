Received: from mail-oi1-f176.google.com (mail-oi1-f176.google.com [209.85.167.176])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9DC9F1D07A1
	for <ell@lists.linux.dev>; Thu, 31 Oct 2024 21:45:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.176
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1730411120; cv=none; b=EFZF9d73dtLdyZQp/B/xb+ktmFoOFQEyuzQhvOtV3FYqIMbuZjyXMW7l2K+DZRAK7GlzCtynS3l8mftG+sxgCqHnnKxkryTLnM+RGc+pURIZ8hc7J2YhPR0zNQOpd2zl6eHf9Coz2ls7wVifDhx+7JaCFJEwGmtGqGfiXKyHU5Y=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1730411120; c=relaxed/simple;
	bh=Hg3wIN9JU5xzgGZyIscv0nItj5hugSTGgCqp+ZVmZhk=;
	h=Message-ID:Date:MIME-Version:Subject:To:References:From:
	 In-Reply-To:Content-Type; b=n5tpqK6zWnZnilHDsLtVcbMyT/mV1i+OKlYB/d4pqwwvTq7LvHD7Gqliu7iYaTjIn3zQmchgia60az+JF3F487nYmX/xp9iUKJM9q2Y0Epwb8V6yVaob8oBRBNC5URL1tcokFrVB4ODxt+xF6j4mNFQSA3wKwBAMvdGEbeh/xcE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=Xog0l90c; arc=none smtp.client-ip=209.85.167.176
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Xog0l90c"
Received: by mail-oi1-f176.google.com with SMTP id 5614622812f47-3e601b6a33aso891041b6e.0
        for <ell@lists.linux.dev>; Thu, 31 Oct 2024 14:45:14 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1730411113; x=1731015913; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id:from
         :to:cc:subject:date:message-id:reply-to;
        bh=iPhu62EydUie3YQePSrT+1+Xm0Fr7oTp50gAnI6zxJE=;
        b=Xog0l90crCIA+4o/wsyDfVCIR8INYHdc+kLhm/nqrc6E1o5D7IR4TQxKPfDtlgJeF7
         tKTX5fDk8GS8pCe1Kf4jexC8VyYizqBLpHSjxgQE5p4bZZYAm3ZJJUnq3JqVuCMVrkj5
         O2Ad4cAbofeglvEifAZdnEYB2YZ6GA3aq6tl9zAOyh+QkVgUOFuJz1lpZlLhOuthaOSf
         7KA0ByeK2bwE0pSfCcTLNi4lDkLmdYoRFy0aQTdrfKuxdJ4d9oA0T7HRH6ceXKpGoWKI
         HhlMNTwGy6WG+xKNYSGuulr2H34aTmzuQeafEo86gc4t9BI6iyc6dULsmYCJRAwyYVsX
         g1Zw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1730411113; x=1731015913;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=iPhu62EydUie3YQePSrT+1+Xm0Fr7oTp50gAnI6zxJE=;
        b=JB5z5nkN/g7yCH5q+s+KA+l1UF/bQXy0OwuFp7PpWQtw1W5zSO0FIL/EXWWINXMRdC
         DnI8GawLWBqoBLdirpxuwF/Xn1tkDHXSlCkMBCyLGEOtlBRdYE9WwQxrYW/9xzOklAki
         tg67hBJj3zyWZ4YBhxs8xrGJei0h289BGkol4NmFbArzKd5Noq6GITl6BOEebWb1Pqxw
         XfjcWloS855rL08WeLN+Gc66ZVJc3BIZbWGJAkD0VHjX2z/EqMkzl7DN79b+pRv5mY1G
         oruGjOr3zrmV67LyNBbmIOAI+JUGgMBqEIFey/uqOGUZiMD3ufI/MrKEMIg0VwBWmCIP
         /2ng==
X-Gm-Message-State: AOJu0YxR7RYxOBIlUyhObJtlJNr8jYd2B4ZwjQUpPzOubkmv2TCTnLaX
	bgjAVKmSJnFkrQ1XB+hqSLIM88GEQtQoxaU+y0IWDO15omYyYXGjF6304g==
X-Google-Smtp-Source: AGHT+IG/5y0plBUqCci9M1adZMf39h6LqP1L2MVf3zn0np2OjjUATTIghTfwDZnOpdVW0JTqscNYfQ==
X-Received: by 2002:a05:6808:1305:b0:3e6:5134:be25 with SMTP id 5614622812f47-3e6608d8232mr3997219b6e.26.1730411113364;
        Thu, 31 Oct 2024 14:45:13 -0700 (PDT)
Received: from [192.168.1.22] (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id 5614622812f47-3e6611c2de9sm554215b6e.24.2024.10.31.14.45.12
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Thu, 31 Oct 2024 14:45:12 -0700 (PDT)
Message-ID: <bb896f7f-0bf1-487d-a638-f468bd720dbb@gmail.com>
Date: Thu, 31 Oct 2024 16:45:11 -0500
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH v3 2/3] util: Add l_memcpy
To: ell@lists.linux.dev
References: <20241031202627.1548592-1-denkenz@gmail.com>
 <20241031202627.1548592-2-denkenz@gmail.com>
Content-Language: en-US
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20241031202627.1548592-2-denkenz@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

On 10/31/24 3:26 PM, Denis Kenzior wrote:
> Some callers use memcpy without checking whether the size 'n' is 0 and
> src is NULL.  'src' is declared as non-null and can thus cause
> sanitizers to complain.  Having 'src' as NULL is fine as long as 'n' is
> 0.  Add a new l_memcpy function to take care of this case.
> ---
>   ell/util.h | 10 ++++++++++
>   1 file changed, 10 insertions(+)
> 

Applied

