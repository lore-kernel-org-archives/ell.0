Received: from mail-oo1-f51.google.com (mail-oo1-f51.google.com [209.85.161.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A66EA82863
	for <ell@lists.linux.dev>; Mon, 26 Aug 2024 18:46:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.161.51
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1724697971; cv=none; b=iYnrnIrvu9l/J20MDeQR5TnzG6dRWKCkPARKiu8jGhl02w6+iLLV5uhP4f30p2Z6HLxZ7nz9Z/MJ4OITuOdzzyHTtXF86Qgtd/r/49X+0RXXibK8QZX+LMX8WqUzkwdmuttA8mvLPB7vfk86K1/ANIUS+jVrb5RD432i554qzCU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1724697971; c=relaxed/simple;
	bh=vJWbY0pMEU/84KDoOHKSqoVv0aLn7f9FEuVQGZovA6U=;
	h=Message-ID:Date:MIME-Version:Subject:To:References:From:
	 In-Reply-To:Content-Type; b=VJU2oSqY9g2GyueyyFF0Ns4cSL8vR090pqW6MdHMeczGHUc9ugUOAPtafr4DgDHGuKsQj9g1XxNdkkh8jpPVyxdByiDzU0rCxsL2eXpcFDCYOHkcZXHjvT1FCO9c98iMoG8YQ/Br6YAUoFJChqu0LiMeEx3PHD4UPQnf8a1h2+c=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=Ej7FRK7d; arc=none smtp.client-ip=209.85.161.51
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Ej7FRK7d"
Received: by mail-oo1-f51.google.com with SMTP id 006d021491bc7-5d5de0e47b9so3036428eaf.0
        for <ell@lists.linux.dev>; Mon, 26 Aug 2024 11:46:09 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1724697968; x=1725302768; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id:from
         :to:cc:subject:date:message-id:reply-to;
        bh=sP/7EjlpA2ZefFXmgvw8ahDT3eWma525QyeP6JGieCg=;
        b=Ej7FRK7d0dzGB2dv2O/XyHXKRNugSTteTYKKoWR0etMGI3R79RAH1PnwC+l/CWdkS3
         k36FYLI6ciSUaYYiXHE1AA/A69GRfL4utmi1Y8jahYD7fjqmyh11lX23+rno0CQYyMxC
         oLPu1K5vvZ0yieLK+yeUoePzg2F21bWYn62RLure4N8TCuDWS/FHQZMEEdCU3BcQb3uS
         y6SlMZUo8FnFyWTX51FydIj/CblVMWO5SInPsQL3VPfv3SjMjvPmlxsboD8O6EwbSCC9
         05RGwe+oj6ffWd3T0thPKPXBnnhax8xO3v6joF/9wzEwmbtRvbAMTHPzT2zevZDRUcRm
         tngw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1724697968; x=1725302768;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=sP/7EjlpA2ZefFXmgvw8ahDT3eWma525QyeP6JGieCg=;
        b=iFPz06kkzSQNkfIit7B1s1X8zsJe4Nt1kLck2FnV/QqC+x85aQaRs3GVn/P9XVAuJ5
         GhhbSj3hHGGq7bH4ZrHjUIwua0iQakVweS9HeP1fgAQMwfDZfGjBN/ofozqsvkConZEN
         xtWqx/UIS/gw7+ynLQlm91TLXsqG50ADycc/q5WENuIahsIxmd8twf4WMfBlZkno62/M
         Y4G6p+KWnhdsd4Xu8EgcLWv20FszltB+u9rHX/BaI+MVrzJOvQdw/nAmc/HPgRzf54L+
         6430VMs/cP+DtDCPi7m4BNpKIvRJ5Bn6t8TVzohWIzPAW3ejfw5IsUMshspfSvu3k7OS
         1tzg==
X-Forwarded-Encrypted: i=1; AJvYcCX/R5B6xVctxko4ZpYqkd/077Wr+Q9Xef1GIUs78zRzcjQtR0K6NDIHfx6OHKGF3AauvPw=@lists.linux.dev
X-Gm-Message-State: AOJu0YxCuQ9tj5YybiwEUQJ7+b3cG12cBX9d0u5ADKQbs3hLzJmZ6IGx
	4GznyXRZpR/xlcgMnGVOlTw8FM5T1nweziqBbOaCTv2A4ReVov0m
X-Google-Smtp-Source: AGHT+IFxIgLqC64b6Dfu1teuRa+URFeqj1V/LUEjL/CeqIRYqI9EgzRkbkGDMBJk3TomorIzo5cK2A==
X-Received: by 2002:a05:6820:1caa:b0:5c4:144b:1ff9 with SMTP id 006d021491bc7-5dcc625b9bfmr10058418eaf.5.1724697968588;
        Mon, 26 Aug 2024 11:46:08 -0700 (PDT)
Received: from [192.168.1.22] (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id 006d021491bc7-5dcb5e01a59sm2080939eaf.22.2024.08.26.11.46.07
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Mon, 26 Aug 2024 11:46:08 -0700 (PDT)
Message-ID: <f321352f-641d-4fb8-ad8c-3480c97992cc@gmail.com>
Date: Mon, 26 Aug 2024 13:46:06 -0500
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: Segmentation Fault in iwd with ell 0.68 Due to l_netlink_send()
To: Rajdeep Malakar <rajdeepm.dev@gmail.com>, ell@lists.linux.dev
References: <d16d043c-aa5c-4fb8-8df6-8c109c6239bf@gmail.com>
Content-Language: en-US
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <d16d043c-aa5c-4fb8-8df6-8c109c6239bf@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

Hi Rajdeep,

On 8/26/24 1:14 PM, Rajdeep Malakar wrote:
> Hi,
> 
> I’m encountering a segmentation fault in iwd after upgrading the ell library 
> from version 0.67 to 0.68. The issue seems to be related to the l_netlink_send() 
> function in the ell library.

Thanks for the report.  Do you have a backtrace you can share by any chance?

Regards,
-Denis
