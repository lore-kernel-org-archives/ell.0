Received: from mail-oi1-f177.google.com (mail-oi1-f177.google.com [209.85.167.177])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A1AF2171092
	for <ell@lists.linux.dev>; Fri, 27 Jun 2025 21:42:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.177
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1751060564; cv=none; b=HOSoHaHyEjqsBIrgfgFGO6aRI0LtebswfvpRookB17eA8lXGLIBe6xbKEEG8RVXQ7RQYjL9eQ4Uf1YWJQgfFMCUH+mosUmz6gG7atcFd4A6F+t0XAmj9vfGjHF902lRe2q8+BcWGNfTWaXb9G06tS77Vf9i10jI4FQTi3mgwXBM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1751060564; c=relaxed/simple;
	bh=CZzj8PxjNEZDpEBUeIQ0mgpQ66pmuyH1po8M/UAnt1k=;
	h=Message-ID:Date:MIME-Version:Subject:To:References:From:
	 In-Reply-To:Content-Type; b=aq2xT5HdAaDZmIMhXr99GSeKflLHNHmeNgDRANEAUCTSqVmNg+hTSPYT9Ph2S/iMQ/+ddQsQYXr/slk75uveIZCrS1cm+4t7XTR1vqwnvCGarBfqV51CN7yE1TOCe9BVesEHc6NGb00LNyq4BZQECotW20X66Vpa+sOnR2ict4o=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=h6VdT1tQ; arc=none smtp.client-ip=209.85.167.177
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="h6VdT1tQ"
Received: by mail-oi1-f177.google.com with SMTP id 5614622812f47-4067ac8f6cdso262137b6e.2
        for <ell@lists.linux.dev>; Fri, 27 Jun 2025 14:42:42 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1751060562; x=1751665362; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id:from
         :to:cc:subject:date:message-id:reply-to;
        bh=f2KDWJyJjJ+C4EDBUg9q8VqGjDGgMAa9J81w/qebjpo=;
        b=h6VdT1tQNQY0hZPE439dibRIM31ByITuncwxZtbDlzPqGaQnbnWetkZfc5LOvGRmGL
         QP0jddo2jJgK+TU9YuUJLMb5bviwvlU1W3qmDgpwIP0u+OUJyr974zX68RkZ+BuzEyJv
         WN85RHvndjock6Va86+JwA0GBJPJQ2EzQjU10QiUvygPdMqDL03e9VTkLUyYBaHNcSSV
         q7dSMpHZeRCFatII1NZYCdjYzIG20dESlNfGEO3+GHJCtXJ0mdKTee1UrWLZkTPFEBn5
         UmbD4rvZ0+Rnq5ZohkmrZ86pzyuHzSfOY60TJmikgJ3WxvAs77mgGZj9MuSykArX+wL/
         1S1g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1751060562; x=1751665362;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=f2KDWJyJjJ+C4EDBUg9q8VqGjDGgMAa9J81w/qebjpo=;
        b=foRuLRhLEz9la1r0qXPEjzi1rhtOiocME8nc/kFxctTywkoq9vkFZyoHt1pfi1EPFo
         HGrV/rN/bNr+JRxLEaTw26JgR3tqBBkLxEejS7AE4xaApC9hAm2gYSxB34kuuSH4OC2H
         h87HqZMyu8tRZbfHma1riMUjWuEAebM/XuFAB3bDvHCK+ax8ZHlKx/U7Lag4cLYt659R
         5Yiib4JBlLCDIL2snLa537W+8wHt2LZdoM/5y/2QMqR+baq3Y5MeAlekwywsF3gWZfSK
         nm5M1OAPp3S/vt4UkHKsV4sV+nOPDUHfgUP7Iuq3tkcep4GrR/vLEvsOk7AoDP1Tfa4W
         z/iQ==
X-Forwarded-Encrypted: i=1; AJvYcCVcbKMA98qLAbMeE87F0IiytwiN46hgq2XXZQL8Gacxta+MDt6jy+VT8xxgAxqOLlsq3y8=@lists.linux.dev
X-Gm-Message-State: AOJu0YxJJwYdLGmfYworhSfBie9qcYuRK6PYjVwj/GZhC0p25BRvLwDF
	373IJSSapyJN8ofNlD/4LhPKD3T9Y2KvHWySiRemQU8KeJVXgusctX0eFeNEkw==
X-Gm-Gg: ASbGncvMbIwTJfouUqSQPZutyWwpe1YLxljN3JRNAuz8BZth0hDkUWvtwlV5LMtWIle
	B+lobHikecH9C3GJ0kKFjmvSUXQOq4BDTEjaCPcTJmJV6f1YjTuO3Ihhuc0E8tF1yRPaltF4q+C
	Fr3wyuxAJAx+Mn1vIJxEl/E/BIl/dCQ1cYYQT3+iHtfwfeY1BIo92/gESDlzFqB3gXf6venYRFE
	DSPR+NJHzMEG0dvIgfrq+9oDio42AdE8RTAhjvZWC5p8hntsUaX3XooaGXiGvF3h+CMMk6TpX7f
	1MlEcHXHTCDTsuwhkiQUERvEruDnucZfy0m5mc2XVupq7TsbvxRxiA3lRKAoteUIm2V9v4SqUk3
	xptyIhsd/U/nkJ6uSYRs2VLqg9p8=
X-Google-Smtp-Source: AGHT+IGtwt7wQYangCykwdEbEhAA8nZTXcEX+oevrq00P+Ak+5Ks37kJ/AbsHFiDjDUDUJo53zH2Yw==
X-Received: by 2002:a05:6808:15a0:b0:3fa:82f6:f74d with SMTP id 5614622812f47-40b33e20e41mr3625815b6e.23.1751060561629;
        Fri, 27 Jun 2025 14:42:41 -0700 (PDT)
Received: from [192.168.1.21] (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id 5614622812f47-40b3243deeesm524479b6e.48.2025.06.27.14.42.40
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Fri, 27 Jun 2025 14:42:41 -0700 (PDT)
Message-ID: <b8251acb-3b6b-4e66-b7ed-d6741009fdaf@gmail.com>
Date: Fri, 27 Jun 2025 16:42:39 -0500
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH 1/4] dbus-filter: avoid NULL pointer dereference after
 removing all rules
To: Christian Eggers <ceggers@arri.de>, ell@lists.linux.dev
References: <20250625131432.19974-1-ceggers@arri.de>
Content-Language: en-US
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20250625131432.19974-1-ceggers@arri.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi Christian,

On 6/25/25 8:14 AM, Christian Eggers wrote:
> l_dbus_register() is called by _dbus_filter_new() directly before the
> first filter rule is added (so filter->root is only transitional NULL).
> Later, if all filter rules have been removed, filter->root is
> permanently NULL which causes NULL pointer dereference in
> _dbus_filter_dispatch() / filter_dispatch_match_recurse().
> 
> I get this situation after creating a D-Bus proxy and destroying the
> proxy later (so that no filter rules are left, but the D-Bus' filter is
> still registered).
> ---
>   ell/dbus-filter.c | 3 ++-
>   1 file changed, 2 insertions(+), 1 deletion(-)
> 

All applied.  Thanks for these!

Regards,
-Denis
