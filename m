Received: from mail-oo1-f41.google.com (mail-oo1-f41.google.com [209.85.161.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 863191AAB3
	for <ell@lists.linux.dev>; Fri, 12 Jan 2024 17:11:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="NxqPVnoU"
Received: by mail-oo1-f41.google.com with SMTP id 006d021491bc7-59883168a83so1691405eaf.2
        for <ell@lists.linux.dev>; Fri, 12 Jan 2024 09:11:35 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1705079494; x=1705684294; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :from:to:cc:subject:date:message-id:reply-to;
        bh=hhEC4pSwvcJZ2ybrsWcBft47bSieRegSfK93zLQ6PQo=;
        b=NxqPVnoURfVNTk6GNmv4voi1vYecFo1BfOO9wxlwwP/Q5y3gs6Jr2YCAzeKqGbg3Kb
         bKmk3KUsfnr8M2U/IIlFyH/7oGFv2slqrkkZhMSdoivHK1WyXpBJj1HCtLyYOx3pf8rH
         vGEoJqFg05jcbbhOvU/DN7pCmd975JHpZsPYTMI5KR6uSMrw7sjvK2Q6wJnB+PT+ADgE
         gPpuoAByCm3qTZGq6GlEL7SfwlpOLBgYTXOd60p250DlMSDlw4P5UCtsqMNKgWncv9eJ
         9uaK9ZntVwxwk3aSV8wCiFmV2GB8S1ROIrwpNAfUfJV/qnPpcQ6FmtGHE9LcrJCKXO87
         G3OA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1705079494; x=1705684294;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=hhEC4pSwvcJZ2ybrsWcBft47bSieRegSfK93zLQ6PQo=;
        b=t2jG927OKUcP99KQUIKZLAcEVBP3WZjScNpdp7p+c1EuHDGKWXla5f3IjuRNgQV4PB
         fvFFAxhfjyIl9WM3R5/hyyNRo1FjFDf0HucotfCZnlIBF7FcKM+pzkER9cRlAl9b40JY
         6f0+hzD9glrd/MX2pQ5FrmSFmvWPcWdRU32nMN2U3arcwStgnZBKReMsSmMv77rhIbia
         eHPJbImi6EQy8E7bymNB7HwBbWp3MUrzmuDO7yFMDwWzCd/7Rxc4vNd8b31YyG8QVQn7
         vO7pZrckBoZnElLpG5fPWqKszE3ylbCjWGfzyz2t6WQEO/pM4LYWOM8cfqdpYghJoIm/
         oUQA==
X-Gm-Message-State: AOJu0YxUSIOyQutfdG562sKZEIlJdvKH+IJ2zhVzzuHhNAUwInIcicy2
	xLnm0xqawdaVwDADSmJ/BrawzW1kOr8=
X-Google-Smtp-Source: AGHT+IEF1mKJhKtICzW2XXcNU827FdxxDBR1csZXc8Ns2BMUsE5IRa3781wxTMB/t2hX4cuFWWPQ8g==
X-Received: by 2002:a05:6820:609:b0:598:8344:c86 with SMTP id e9-20020a056820060900b0059883440c86mr1013823oow.14.1705079494490;
        Fri, 12 Jan 2024 09:11:34 -0800 (PST)
Received: from [172.16.49.130] (070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id v190-20020a4a5ac7000000b00595a3e41e2csm764381ooa.37.2024.01.12.09.11.33
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Fri, 12 Jan 2024 09:11:34 -0800 (PST)
Message-ID: <55a3b50e-637b-4df1-960b-a4af96002e78@gmail.com>
Date: Fri, 12 Jan 2024 11:11:33 -0600
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH v2] dhcp: fix overflow causing retries to stop
Content-Language: en-US
To: James Prestwood <prestwoj@gmail.com>, ell@lists.linux.dev
References: <20240111133331.1423853-1-prestwoj@gmail.com>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20240111133331.1423853-1-prestwoj@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi James,

On 1/11/24 07:33, James Prestwood wrote:
> If DHCP is in a SELECTING/REQUESTING state and the number of attempts
> reached a value where 2 << attempts overflowed an unsigned int the
> next timeout would become zero, causing DHCP to never retry without
> any event notification.
> 
> Roughly 2 minutes has passed when we reach >5 attempts so it makes
> little sense to retry indefinitely, at least without notifying the
> upper layers (which could decided to retry themselves).

Okay, but '5' is just a magic number in the code with no context.  Lets avoid that.

Can we make this limit configurable?  Say between 3..30?  For iwd, even 2 
minutes might be too long.

Regards,
-Denis
