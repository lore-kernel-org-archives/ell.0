Received: from mail-ot1-f48.google.com (mail-ot1-f48.google.com [209.85.210.48])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5307117ADF7
	for <ell@lists.linux.dev>; Mon, 26 Aug 2024 19:20:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.48
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1724700023; cv=none; b=mcqTgVVqiDGhfzk9Qg4HGF1XErYDn9M4DDdjSnipOcj5Va/hZNOhMbhrgBZGoPXiu/pgWkyVujG58zT0qey5eQv9XxqNWaDbk1lWE9R8AgCWbeUY8/hJN3lDT6n6uu76m8P4xbUmNrTfrrm8432r2NYuU7W5CfXS/PvirjhvbYA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1724700023; c=relaxed/simple;
	bh=K2T0RxUzkGthm8tGf91TM6tRzCmmBKqKr5a3kI6bJp8=;
	h=Message-ID:Date:MIME-Version:Subject:To:References:From:
	 In-Reply-To:Content-Type; b=MGMJwoSMa5VbkW+vP5iGepbyMT4anCEwo/pSqAiGHYnqenAKSNEEtvTHxel9tGDSKBu5McenlLmG81X/cfH76Ffgw7dFucQsVAk4AejHy2EkzvbTBeO1fDApTXR+RSJZpyMtcH8frFylO/P8Ms5KvIMIGbMLF0bjLFueFKvNU18=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=lpHQnjuw; arc=none smtp.client-ip=209.85.210.48
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="lpHQnjuw"
Received: by mail-ot1-f48.google.com with SMTP id 46e09a7af769-709428a9469so4505213a34.3
        for <ell@lists.linux.dev>; Mon, 26 Aug 2024 12:20:22 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1724700021; x=1725304821; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id:from
         :to:cc:subject:date:message-id:reply-to;
        bh=FJgE8BGjvUOzuYnFbNPtxrdUIa1zGn/AabXJfs61IxE=;
        b=lpHQnjuwol7DnQPqckCgs+g6kjD3LC/ZH9mYKT1Em4rWZuWYLZxGF7nlPCeIk0ziRB
         siPspDvag12vcvV5s5pGHLzKCkdA+GlrPl9r+uXZccK9miWJUHC2WBAZy9EwuPxi9T4P
         BvvRoWVh7SgGjYpVnf8BJxbl9+FBIzOKdecMBBOorDn8V0+OTg1hSmP50kQZG+m+UJ0L
         B6Z2dF2JpJUs6ORUesQH0MGPuEFqMvKfoqtFpEJFIzkrz3cva0D+nntDxwD+SR4LnuDp
         hCjoD2yOXH15iuVCuIklrRnc8npHkJluyZZyEYAlNnXuvEIq0EByu2DEffo8SI4HMTZl
         mzSA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1724700021; x=1725304821;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=FJgE8BGjvUOzuYnFbNPtxrdUIa1zGn/AabXJfs61IxE=;
        b=DVNu5ZDM9Wj4GvfJ7QlgWasW4zY9zj0nmJV5knhSYvRC1HKYHyjSk9oOY3C2MxAhR1
         gaAGpeP46ctLgiUypvsm68omeBBeg4gUEemQa/nOVilR639Tlij9SBDFV14kuUtKMf9D
         dg/IjQ9f2meZlCHdS3OytJDqCqpl8F8xoyxlbxkfwStT3KKfxe618Ta9NmUIL0vnVtXM
         ESu4BHBCb1yIxLkqbWK5YdBBM4g/5AQbKRR5kaHiA/hYzpOCD901Gc8D+NIHk4L+0C3m
         3O+/Cujm1vDS0LvJuU4andwqK4xEzzmSO7D1B55o9WCv5gOlVSIfZheog4rM/xZkYkYl
         B1BA==
X-Forwarded-Encrypted: i=1; AJvYcCWrmkOg1Df3e6FXG6R/F/HFmIbcaOgyWA9/xXUrrJn5O0nwCBEaJA90n+ZjpFUgNUN3qh4=@lists.linux.dev
X-Gm-Message-State: AOJu0Yw5obDFbN70Il5iKd+fmR09iHpRl/Hhviokw4eWvhjuxkAF7vb5
	UD29j11aSctjJ6DCRRFfD8zkQ4nImGuA/7ulvjHB7Kcjn3LCYWNi
X-Google-Smtp-Source: AGHT+IEQ5XFw1mQXXkrq3B4wycXNFbfiVFm2Gnp14s/lcFwFJr3C7WUmgQCJL8H5kpnDjJ8YmoyrFQ==
X-Received: by 2002:a05:6830:6d8d:b0:708:b46d:5c76 with SMTP id 46e09a7af769-70e0eb37c6amr14559404a34.17.1724700021403;
        Mon, 26 Aug 2024 12:20:21 -0700 (PDT)
Received: from [192.168.1.22] (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id 46e09a7af769-70e03b6058esm2014422a34.58.2024.08.26.12.20.20
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Mon, 26 Aug 2024 12:20:21 -0700 (PDT)
Message-ID: <83a579fd-1f2a-403d-a3e4-e447b3885d62@gmail.com>
Date: Mon, 26 Aug 2024 14:20:20 -0500
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
 <f321352f-641d-4fb8-ad8c-3480c97992cc@gmail.com>
 <b7a1d7fd-a42a-48f0-8c1f-c5cc19b15a9f@gmail.com>
 <5b232f87-2fd9-445f-8650-66a05ad18217@gmail.com>
Content-Language: en-US
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <5b232f87-2fd9-445f-8650-66a05ad18217@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

Hi Rajdeep,

> 
> So, I compiled ell with a bit more info:
> 
> Program received signal SIGSEGV, Segmentation fault.
> 0x00007ffff7f3e17c in l_netlink_send (netlink=0x55555563bc60, message=0x12, 
> function=0x0, user_data=0x555555651e50, destroy=0x10) at ell/netlink.c:413
> 413             if (unlikely(message->nest_level))
> 
> a bit more backtrace:
> 
> #0  0x00007ffff7f3e17c in l_netlink_send (netlink=0x55555563bc60, message=0x12, 
> function=0x0, user_data=0x555555651e50, destroy=0x10) at ell/netlink.c:413
> #1  0x000055555556d53d in ?? ()
> #2  0x00005555555ae380 in ?? ()
> #3  0x00007ffff7f40014 in process_unicast (genl=<optimized out>, 
> nlmsg=0x7fffffffc140) at ell/genl.c:860
> #4  received_data (io=<optimized out>, user_data=0x55555563b8b0) at ell/genl.c:972
> #5  0x00007ffff7f3c2ac in io_callback (fd=<optimized out>, events=1, 
> user_data=0x55555563b800) at ell/io.c:105
> #6  0x00007ffff7f3b495 in l_main_iterate (timeout=<optimized out>) at 
> ell/main.c:461
> #7  0x00007ffff7f3b55c in l_main_run () at ell/main.c:508
> #8  l_main_run () at ell/main.c:490
> #9  0x00007ffff7f3b77b in l_main_run_with_signal (callback=<optimized out>, 
> user_data=0x0) at ell/main.c:630
> #10 0x000055555555fd13 in ?? ()
> #11 0x00007ffff7d0ae08 in ?? () from /usr/lib/libc.so.6
> #12 0x00007ffff7d0aecc in __libc_start_main () from /usr/lib/libc.so.6
> #13 0x0000555555560575 in ?? ()
> 
> Let me know if you need more info.

I suspect that this is a binary compatibility problem.  ell API is not stable, 
so ell + iwd are released in tandem.  ell 0.68 breaks certain netlink APIs.  iwd 
2.19 requires ell 0.67.  iwd 2.20 will require ell 0.68, etc.

Regards,
-Denis

