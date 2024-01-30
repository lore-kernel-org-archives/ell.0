Received: from mail-oi1-f179.google.com (mail-oi1-f179.google.com [209.85.167.179])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4611E1D55F
	for <ell@lists.linux.dev>; Tue, 30 Jan 2024 02:39:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.179
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1706582357; cv=none; b=UEWvxPLXiNHu6FRl60kTo80VbOAY11xMkot724p6UEOfEMZlpHJ+lW8ozWGSYffS++cD5QG9Th5RIOoxQH63WsNTHLPuCmuu2RqBPRWDwoWLDRiRkARlR9VnJhoR+6DgN/KDBx9FUohQg9UxWmqgEWx7Bv1gSonod01qzLxqQO0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1706582357; c=relaxed/simple;
	bh=LkT6CJfSd1TdWpUjCGlc5kFesoSo6L7tZGpIlK/aqW8=;
	h=Message-ID:Date:MIME-Version:Subject:To:References:From:
	 In-Reply-To:Content-Type; b=lTpqO4u3+xtrwkegnUNpUosLP3MUBvlya1pTxwbso1BgwqpHD8MRQTVVGGPLQZb7zGVShOayw4mdQT8DcB35Qjgmkx7cOowvZQU3Iq4PA08XyAr9WUhr6bb4s2Pw8k13MxUm3TxxK8YD0lZfU6fNRmUdX7tbBUUdrd6LSeO+wSc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=QZYTyOIX; arc=none smtp.client-ip=209.85.167.179
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="QZYTyOIX"
Received: by mail-oi1-f179.google.com with SMTP id 5614622812f47-3be5973913bso599939b6e.3
        for <ell@lists.linux.dev>; Mon, 29 Jan 2024 18:39:15 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1706582355; x=1707187155; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :from:to:cc:subject:date:message-id:reply-to;
        bh=JjM601C1clW+/RuvBuc/nIfIc9uEshBz9bxNWd9D80U=;
        b=QZYTyOIXShIWcHiYIGhNl00vebejHWeVbJhSVRINU3qk2+G0uFD1pXKwx4uVgvJpQ4
         HvTr6poUDPExYogGGfk2j3g9gR6oIcBo7ZD4UZ9R61gYitxQZcMJTyaEp4fIMmD1YH7Q
         D/Mkz0phLcXKngbSMLZOJ7j6VCO9DevAR7sPj4rEx0WcxraYL3l8hMwJMce0A+9kCiTX
         osF8/7JWmCUzMrY9TMZpWhrKJ4kimGWM/6scyPL13GWI7/WVKHakfG6UOy+6dJUSLtFS
         v1QEONr17skn33g9+TvRWiDivFUYRP12TJeC9w9o6b3orktDhoowj59iyKMQhy09soIa
         E31g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1706582355; x=1707187155;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=JjM601C1clW+/RuvBuc/nIfIc9uEshBz9bxNWd9D80U=;
        b=AZDSqrG8zhmT1eWtbOgWJEWDLFyumDyQoDHO8E5O+SMd702xzDnI+oLG/C6x8wRn6W
         hFA8sLlkJepqjycpG0r619I/9eBt9ohwqfBB6TW/BiNYVQdQXD+lcjpX0oysz0D4D8C6
         04nxMmCsjF4Pdsg6fAyMD8zcbs43AM3AMCErYokMb7vnkV2PqdsImMwviOyAp8exSBgk
         u5+1AVsg76IAZzsc+MpFJs88a9YowF+OHBfejPtdkr2rHqFhBBy2jNkB1e8Q67KY/UMq
         9K8L/aBCgpSpardqRLUtbSrwIRpHU1dDUaoeY0/3m4tuBTTqx9U2iksGgrJxEqoXuT/S
         Vhcw==
X-Gm-Message-State: AOJu0Yy5hLw0Bzzbn2PzkKr2Hmjp6UHmS5GPsjg56vg/Pd+SS46g9lcJ
	PxeePDicxj3rPBI19Lhh2E4KY5mj1N3ena1teAvzTwyzgw48Mye9IT1jjoTQ
X-Google-Smtp-Source: AGHT+IGT9GL1J/DN0NB8QZpSjtgJwACGkMGaMcJv3T22fEXq9gXC77ulxSrHcAf7RSIVe4sdqcFuNA==
X-Received: by 2002:a05:6808:200b:b0:3be:4cfd:6567 with SMTP id q11-20020a056808200b00b003be4cfd6567mr2936230oiw.28.1706582354943;
        Mon, 29 Jan 2024 18:39:14 -0800 (PST)
Received: from [172.16.49.130] (070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id db12-20020a056808408c00b003bdbd3c0f5fsm1654013oib.11.2024.01.29.18.39.14
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Mon, 29 Jan 2024 18:39:14 -0800 (PST)
Message-ID: <ad33eefa-78ba-4420-a27d-854a8dcc006c@gmail.com>
Date: Mon, 29 Jan 2024 20:39:13 -0600
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH 1/2] dir: Add l_dir_create
Content-Language: en-US
To: ell@lists.linux.dev
References: <20240129194139.714209-1-denkenz@gmail.com>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20240129194139.714209-1-denkenz@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

On 1/29/24 13:41, Denis Kenzior wrote:
> ---
>   ell/dir.c   | 52 ++++++++++++++++++++++++++++++++++++++++++++++++++++
>   ell/dir.h   |  2 ++
>   ell/ell.sym |  1 +
>   3 files changed, 55 insertions(+)
> 

All applied.

Regards,
-Denis

