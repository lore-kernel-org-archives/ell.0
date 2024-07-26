Received: from mail-oa1-f52.google.com (mail-oa1-f52.google.com [209.85.160.52])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 120D246BF
	for <ell@lists.linux.dev>; Fri, 26 Jul 2024 19:31:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.160.52
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1722022278; cv=none; b=MIV8WJfol/lplYOBdExH6GOo/su8iy/LbYZtnjZhEY+STpVAAGWeSXRwWn8HK4v5XDdAshF/lSzIBxwcr+DmirXWRORd9WKCMbyhApdlMxFvdYIyN/MCIAV3zXJGKyInmg6vy8BZMAgfKDD/u+ujCk5my7n6hMA8jcKK8Y2WRRc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1722022278; c=relaxed/simple;
	bh=zFuzHSOB7B5rx+Cekez9I0iyDQ1aLqAm3v37q8ZOf1o=;
	h=Message-ID:Date:MIME-Version:Subject:To:References:From:
	 In-Reply-To:Content-Type; b=LM8dwAdt5RX2BKpOLauye5PNBy0RNVcpQGg4lYZ171ugBa3ANGILB+OEcQrAMqAfU9NJ1m0E9CtQfhR76w2FMD0CUrzzv4a9fxTMkst7TT53zaIISY/JA9GQCxDsv3hhm8QrTvnFQPoGlwmunZYoYv3Fg0GgEvzpOSZuwHurx1g=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=SMtZJA9S; arc=none smtp.client-ip=209.85.160.52
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="SMtZJA9S"
Received: by mail-oa1-f52.google.com with SMTP id 586e51a60fabf-26119999171so1126238fac.2
        for <ell@lists.linux.dev>; Fri, 26 Jul 2024 12:31:16 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1722022276; x=1722627076; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id:from
         :to:cc:subject:date:message-id:reply-to;
        bh=3il1pe65Mq8A9NG+s7Y+HvfyOoBBdFTlKYPb2B4mkjA=;
        b=SMtZJA9Sw1j6v+JumYFm/4Ai0lh4JaFvJnl5OzgiAH8zfn3mO8KHp9z0fZNvi5eta1
         8wKDQeg6UmrL+9ZD2g9hwj1dWU/TrY17AeCxHpNLb2Aof6dwi41EtL9Ql1OWaV9vElq5
         xa1U2M8LOTDnS62P8WAHbCiw9E+DDh7sepuqGTb11/C5dQwexo9RSg/umihZLeemUxgr
         YkMOrNC8iD5qIHFw+2oTfRx1l3YC55cgBworgEThd+nn4jk1c7NFSjzQtiDEJ5FM80Du
         gQcY3pOpdNur2U+mGyTBfLhu1ngxUn+CtJrUeH7d4n2t/Eke4CT3yV+SvZ1YW/1EaSlV
         oLVg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1722022276; x=1722627076;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=3il1pe65Mq8A9NG+s7Y+HvfyOoBBdFTlKYPb2B4mkjA=;
        b=qDjo/KR4McA9f7llI87EB0lgg0X+uxvRIa23qulf0DTg+MrIw5thdu7iXG3Kd3akHs
         S7w0fNPOp2WUJ0tsy0FdpEHxg+RDgjaqnkCMTrfjyQD5cKtFXgpEbZ85oVrQM8lLs0Ui
         +J3U+tBeUWZRSxFtPKpco3YRYKVGt8N0wyuCHuQ+1gj7Jcoj/ennOKjlZzN66r7UfuVI
         6LgKSiF2lH1f1pLux4WbRRB6UsXn6pXuLGsaPTW24hrLg7364loAzq1jtk42fM21/uuL
         I6qrPeakJCVHFGmYFRDG/voiEN8Y/6wkMUmkVozpDK3dn00OtBts+qHU6RCCDEmRl+Gw
         PYPw==
X-Forwarded-Encrypted: i=1; AJvYcCV4ybSzI/0UCg58K70LWFWvPUoFLfBPBqBJljfIiq/ENiADoEB7oSXWH4Yebj2AqxpxmTxGZBB265kVkcurkhkMTCBj
X-Gm-Message-State: AOJu0YzUiS4iCEND+JK4s/MrwUdWzklLKvTwAgq1XbXULurbuFbPuQV4
	Ljs6KSgloney4U4goZSuclqrbTAZ9xxvnU/rQ4ifYTXcD1BSTHhF
X-Google-Smtp-Source: AGHT+IGkIkxYcJjzs/yqPbJM5gBQt/mY3iZCireCxOec7FtlCxWADAcLzIZCfo/iL5k4TJRnlpmB+A==
X-Received: by 2002:a05:6870:2247:b0:260:e2ea:e680 with SMTP id 586e51a60fabf-267d4d1666bmr956146fac.10.1722022276122;
        Fri, 26 Jul 2024 12:31:16 -0700 (PDT)
Received: from [192.168.1.22] (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id 586e51a60fabf-2653e640030sm780099fac.16.2024.07.26.12.31.15
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Fri, 26 Jul 2024 12:31:15 -0700 (PDT)
Message-ID: <b43d6bbe-4fbd-4da9-a874-f6df6c69e774@gmail.com>
Date: Fri, 26 Jul 2024 14:31:13 -0500
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH 1/7] netlink: Remove pointless checks
To: James Prestwood <prestwoj@gmail.com>, ell@lists.linux.dev
References: <20240726161232.146982-1-denkenz@gmail.com>
 <e60cc267-481f-4a0e-83f8-8f0e49290d97@gmail.com>
Content-Language: en-US
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <e60cc267-481f-4a0e-83f8-8f0e49290d97@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi James,

> 
> These all look good to me visually, assuming they pass autotests (once the 
> update to IWD/netdev is done)
>

autotests seem to pass locally (with some usual test-runner flakiness), so I'll 
push this out and send the iwd patchset in a bit.  I do need to merge the iwd 
monitor patch first though.  Have you looked at that one?

Regards,
-Denis

