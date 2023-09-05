Received: from mail-oo1-f45.google.com (mail-oo1-f45.google.com [209.85.161.45])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 992147E
	for <ell@lists.linux.dev>; Tue,  5 Sep 2023 03:28:49 +0000 (UTC)
Received: by mail-oo1-f45.google.com with SMTP id 006d021491bc7-5717f7b932aso1375269eaf.0
        for <ell@lists.linux.dev>; Mon, 04 Sep 2023 20:28:49 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20221208; t=1693884529; x=1694489329; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:references:cc:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :from:to:cc:subject:date:message-id:reply-to;
        bh=DNjUlgAvwfw+Xi4y7mBO9wOdpF2nlNtBX55gmXB56b0=;
        b=cFTuFvXfL4H8MVx4yWZNP9uGcU9sLO+gIeUCL0f+VkK4pcUD/LW3GF3oKbSM3kj/Ab
         gx1BSJJHC8B7DPfxmE2bSy2tHmmbMiFW8o85xkNx197c5rBdxcigH+eJDlkuMgVX8wLy
         J4hfSHhNhpgsDDDSlCnnf1EYaNoJgBZswrMm1m/on0YCGM2V4WRNyxL17wc1CYSV3EgN
         nARhinlQpbr7EYzQYF4IP9AaeS9zISiIvfHCe/lqO7GNyBla7UHkVC4BdrwNMclTg7x7
         Oao3Jo24FAAY/uuz9+D8nPzFvav42nn4GuU6myIQcUGnJtTLptZbYxnbbMxl6FK/Y+iK
         8EiA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20221208; t=1693884529; x=1694489329;
        h=content-transfer-encoding:in-reply-to:from:references:cc:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=DNjUlgAvwfw+Xi4y7mBO9wOdpF2nlNtBX55gmXB56b0=;
        b=eHLrN5mJYfMNp8W8oAH1bq+mppKgKjnmDWuMQI1zv2zPqXVAgWQgmIYCGBsyLn0J59
         94lJnOSt52CyS+LlGzlPJRnS0OYdpNFlINZF4bDsXEDf/kLBRKWFkabieO2wUtpPmpeS
         /qooffxz2xVS1LsfPvAzNGiM3X7xzhpaKsR5pADCwj4h/HxKn8xh3e2eMdnIEGUt6A22
         eAtnInVsIqI9tNlGyR8BeOOwslqQ5hKe9T0NHC2hJ3Fh0vRc+s6WJyVMKkZ2/a3XNQCV
         85HN8w0aBLjL5OoWZc3gSqvsh4ninMy/fwwGRj84Vi1gxL3L7Pgk2KWa9cxElkKEEI8i
         30IQ==
X-Gm-Message-State: AOJu0Yz/LPcWPxfwbKjMrk6jTWDf1vVUucSwBoo/OzkgGbEBQUiliK+x
	jUxcZq1Ylf4knmhnp7URqIQ=
X-Google-Smtp-Source: AGHT+IHGImQ2o9sqc3QP3HDdpVmIGECAWOnGw/DzDKInH94WDHJ6RQA/7j5uajbXRiH0W00xOJXeCg==
X-Received: by 2002:a4a:92d5:0:b0:571:281a:ef7 with SMTP id j21-20020a4a92d5000000b00571281a0ef7mr9467700ooh.7.1693884529131;
        Mon, 04 Sep 2023 20:28:49 -0700 (PDT)
Received: from [172.16.49.130] (cpe-70-114-247-242.austin.res.rr.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id v62-20020a4a5a41000000b005634ef4f1c0sm5547027ooa.31.2023.09.04.20.28.48
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Mon, 04 Sep 2023 20:28:48 -0700 (PDT)
Message-ID: <1becf44b-d4c1-9445-2282-66b8361641e5@gmail.com>
Date: Mon, 4 Sep 2023 22:28:47 -0500
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:102.0) Gecko/20100101
 Thunderbird/102.13.0
Subject: Re: [PATCH] unit: skip sysctl test if sysfs is not available
Content-Language: en-US
To: Finn Behrens <me@kloenk.dev>, ell@lists.linux.dev
Cc: dev@leona.is
References: <526DA75D-01AB-4D85-BF5C-5F25E5C39480@kloenk.dev>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <526DA75D-01AB-4D85-BF5C-5F25E5C39480@kloenk.dev>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi Finn,

On 9/4/23 02:57, Finn Behrens wrote:
> Some build environments that build in a mount namespace do not mount
> sysfs which makes sysctl and l_sysctl_* fail. Skip the test, if
> the file does not exists.
> ---
>   unit/test-sysctl.c | 12 +++++++++++-
>   1 file changed, 11 insertions(+), 1 deletion(-)
> 

Applied, thanks.

Regards,
-Denis

