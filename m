Received: from mail-oo1-f42.google.com (mail-oo1-f42.google.com [209.85.161.42])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 385E42727E2
	for <ell@lists.linux.dev>; Tue,  1 Jul 2025 14:37:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.161.42
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1751380656; cv=none; b=S7Ue8QaOtobz2yj8kdJiI3PJBJXex6a/HcjDOB31D0V1lamAoie3tLT9yu0o3/SbaVZhxIkXYZwkN6DVyYT2uWGZ5R4xVaUrV+oLihf5y3UExiGVhPBK9EeTE2+8NPN+KoBMYiEpnf2JkyWRK4QIoM8/e4tWY60iez4y7EGJCzI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1751380656; c=relaxed/simple;
	bh=5YJTo0w9f4cNGHlqnLF0PVNchascmhq113kSeqB64Ms=;
	h=Message-ID:Date:MIME-Version:Subject:To:References:From:
	 In-Reply-To:Content-Type; b=qSA9l2vsj6BIEV95cQk7vwUSAkxBGUYwSXkQQvmQ5YVlgN17wAI5j5ZRforKYKSsIjnbZjqEoArqNfKrFG6FFEvh4KWXxesc3Rfer2WTzaD2lC6gAfsciZ+105ADk+pmad4e6i0axTzPuW8cyqHr/2kr5Qy4M/st+Zq05I4BaLI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=Im/ojvSw; arc=none smtp.client-ip=209.85.161.42
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Im/ojvSw"
Received: by mail-oo1-f42.google.com with SMTP id 006d021491bc7-611e67c3df2so479421eaf.3
        for <ell@lists.linux.dev>; Tue, 01 Jul 2025 07:37:33 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1751380653; x=1751985453; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id:from
         :to:cc:subject:date:message-id:reply-to;
        bh=cNpvzKwoCo9v4ZbYeISzRFVDHp6gNznyku7InZ0su2c=;
        b=Im/ojvSwshdT0xyDD2YsScKWcLzLnoIA+yHG9/EyjVWUvrKabmy3id+ILO82SN+r/v
         YIXSM45KLcWtuUEFUVPXZkCoGyYYq95erAX7l/ZZ6cLIe3i8KPvct+AC3NM6vX9EhBZF
         AOQ87RcwoMoCIIEU2zD9gM2deyJfES0NT5rTp4MZG+LmXGPFAV8aYF6/G17ivsjDUbK6
         7u03Xvb8bWKkrsvgMjaiFTKOhOZrWC6R0SoFRJvMFx47FhAYJ515wCGpkcq/QsZ6D11K
         mFwep4U2IuShnr/vew5b1oajUQCs8llHGl7Cv6G6WE/4q2xedIpbfdTPn2f0ZB17Le/f
         yCNg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1751380653; x=1751985453;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=cNpvzKwoCo9v4ZbYeISzRFVDHp6gNznyku7InZ0su2c=;
        b=nEMOKDJxWJutuspylUbbVTcb+OOnYT9hI0J03QtZve/Z9GlXXkbElaOigt1qHq/ihn
         ah1yM3L/+K8nAO35IvOhlP1KL6lepHCeNH4fWGwGpfIr9IljDPPj5XSXW3LOzyy9Kn6I
         niewXCbJiy77nPc7Rwp22kpqOrf9EH+QehPzp4WzKKt8VDP8Y/Rz8StA5r+GJ9IJQC+B
         M5q3H+Wu6fUyKmdR5xlhKinw2hyj/YNUKUA75tFA68QzMoORTLiEJiIAd5BojY1LqKBF
         82zerTsBX2b4XBAJV8kSMNzeKd7xcEjQ/AmG7J42tQZreEvSVX/moRUwpye8fm4N/xI4
         uy9g==
X-Forwarded-Encrypted: i=1; AJvYcCVACzSQHr7c65hEZCNABCyEInt40f60x6UceDJFIigMWrQahFqg+lZyrTT456PrHfyqmyE=@lists.linux.dev
X-Gm-Message-State: AOJu0YwMpXzdP9EMAtagwGdiefIt5NjSap9HtBvbYr6mJ8kM8zoida4F
	2BbbwyS1JgJ8d1raM2NL2hp1AAsLSNofqRwQu/1iC8LfN0G55534uOSUOvdmyA==
X-Gm-Gg: ASbGncs7//tZoUshyLPxZNENhwCjK0P2bH81ax6cPoOMFJGaRqo6mKREyhHwxyO15Q2
	Rkve/HDUfFpyhGP8rJt6EGq3FuoAg87bFBBiN4fgOcHN3yGAOaAiz+TWFz5i8TZx0NkAjR/zGDd
	XSFLzaXjfzdcjj6TS6zctPOZgCT3RysZpmlslMxXnhInnSdXeK8SteqdEAcaY4iiP6oYBrKguGP
	9fT97QAqMbw9hl7ZTzvUO9GmPxN5V232cxEX8bMx5OgcX3WoSZk/9rREL0SW1qEfns9XbuWNnNw
	MKv34HOaYJliiKoTZTIP4ECN9fymgzEqjQo+wJCQBgFkTlogZCLYMnPc2nqOfGjWegnVuvAC0HG
	mbbXMtqAKlJLpuWhkMUbkEC4WgI53tKjJUQ/4mg==
X-Google-Smtp-Source: AGHT+IH9p1GiptkpDqIR7q8e3OenNYo3sn28xRTtWVO/BbGL7LRRVlL9J+5hd0g78yypcmXU2ureYA==
X-Received: by 2002:a05:6820:3093:b0:611:ac4e:f140 with SMTP id 006d021491bc7-611b901a6admr11237041eaf.2.1751380652852;
        Tue, 01 Jul 2025 07:37:32 -0700 (PDT)
Received: from [192.168.1.21] (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id 006d021491bc7-611b8582352sm1512217eaf.22.2025.07.01.07.37.32
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Tue, 01 Jul 2025 07:37:32 -0700 (PDT)
Message-ID: <4489ca9a-2bc0-4b5f-9232-f0cbdc8a18b5@gmail.com>
Date: Tue, 1 Jul 2025 09:37:31 -0500
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH] all: Fix typos
To: Bastien Nocera <hadess@hadess.net>, ell@lists.linux.dev
References: <20250701132015.482623-1-hadess@hadess.net>
Content-Language: en-US
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20250701132015.482623-1-hadess@hadess.net>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi Bastien,

On 7/1/25 8:20 AM, Bastien Nocera wrote:
> ---
>   Makefile.am              | 2 +-
>   ell/dbus.c               | 2 +-
>   ell/strv.c               | 2 +-
>   ell/util.h               | 2 +-
>   tools/certchain-verify.c | 2 +-
>   unit/test-dhcp.c         | 2 +-
>   6 files changed, 6 insertions(+), 6 deletions(-)
> 

Applied, thanks.

Regards,
-Denis
