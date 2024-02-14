Received: from mail-oo1-f42.google.com (mail-oo1-f42.google.com [209.85.161.42])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4FCE241C6B
	for <ell@lists.linux.dev>; Wed, 14 Feb 2024 16:40:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.161.42
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1707928834; cv=none; b=FvTBlNaYqBW8Enz1HhVgyxXheOuzJCXXZDhJTJ070XxuArAW7e2Ep7zPUHV+eLUFZ1U+L7jtFZFPaVGRgnziWVWrNAdcQTD/npIqp4+O8uSMK5I9TKnr+RAP9tSiU61sXumnBy/FO6outEVvGDDkV2FBcjivbXVea7Ckok0ovqU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1707928834; c=relaxed/simple;
	bh=Y6iGpwoWwzkEqm6uMisTcgwhSDW2k2ASOJlowlC7BBg=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=nXcTyvN19GT6QBCeLaJL6IvzHMEylS9m36LpBszKfTxYLgCwupAni2yQxUicvvN+7Sad6QgwEIYnlkDldTp45/Yui8160ZrmsZNBj0FysyBlg+aYJdfq+bly4ETDkB0TdNQo8jmr2BD/LoWGtKrQ5BASb0q4yIW5TQE2ksNjENY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=NYLgj4en; arc=none smtp.client-ip=209.85.161.42
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="NYLgj4en"
Received: by mail-oo1-f42.google.com with SMTP id 006d021491bc7-59883168a83so2154072eaf.2
        for <ell@lists.linux.dev>; Wed, 14 Feb 2024 08:40:31 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1707928830; x=1708533630; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:references:cc:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :from:to:cc:subject:date:message-id:reply-to;
        bh=dJH4fVUg9hHshXu+WqW6ShKT2IDJ2V//Js0ooy/kdOM=;
        b=NYLgj4enWpHI858CkHsUYz3IkU6X+nOjsAYFqP0OECY//xPNXGNSSlV39gWV1KPDAH
         tQLIHD5JFKEao6XleASO1iucqz64kUMqY/iw4n1WJL7a2HMXcSgZWIEdRli8QvnL41Yw
         teuz7O5d4ykFiPSq3Osot/t+Tj7l3sPrJoro6i/6KKKh0tTTjxizoxNDiFI15ZMHZTfI
         tuTL1z8SZMP9NgsC5881D/57WrkqLt3rzIqPHFqh4EOny8UwBUy9dB/boBamX+JVQpif
         ywVUI0nB3hdpaQN6pHJgnrDZuJgsY/eNOnYNBlWKpCUxpJDFXxTvfpQ6CgP+qhedbu4m
         NnvQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1707928830; x=1708533630;
        h=content-transfer-encoding:in-reply-to:from:references:cc:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=dJH4fVUg9hHshXu+WqW6ShKT2IDJ2V//Js0ooy/kdOM=;
        b=CRu4WLfKOdpCHva1akGD6lNTdJ93+EtCMTH61dQOugdPSBjsaAkny6qpno+FE+dl5u
         EYeX+Pyp+h3kKAvg9LbiYpuemrih7GfkU6t99TmnjZeLVrE9z/1CvMnkud2MeZUbOjl0
         Q6I30gldkBLtF+76V+HO7Vu4LZ0A9zAZ+rNN6pAF+Wa7qjRhg6opB/aka1zW55J3IZQ6
         dQIoVKYwEQswfdyR2933ApXUM3T7lz2SLWCWDVogrkkqNj6i2sRk/iTO8ehIy2hb91Nd
         Xh228PN8rmqyyopzlsSUx5x2mNvvdpFPTEG6LXVJ/QmMW0eOas7XgxhKfvSAfxWQF9oU
         F+sg==
X-Forwarded-Encrypted: i=1; AJvYcCUWjv02XREeZ5+gERWvDdBRaz7lUS0q4dAn2lqMpX7elnQTDAyy6t7COCrwxOImzi1DyaDRDipsJoxED2i6/ts7KBPT
X-Gm-Message-State: AOJu0YyxFkZzv7PqOBFfA0A14nV+BT2JtPeuAYgU+LF6qFUaJCsqhNyP
	s8St911Dy7eshMfdURn/Ta1WnRCEhBRSm+BNocIFELdXjBMOt/wq
X-Google-Smtp-Source: AGHT+IHtGSr/XeGZ57FPh8shynrX5x+5O2+0pmeMbLSNJOFXNb1laOwEKJsD+zHlmHpwQUSVvWvPiA==
X-Received: by 2002:a4a:6210:0:b0:59a:8f1f:4c76 with SMTP id x16-20020a4a6210000000b0059a8f1f4c76mr3260269ooc.9.1707928830290;
        Wed, 14 Feb 2024 08:40:30 -0800 (PST)
X-Forwarded-Encrypted: i=1; AJvYcCW8aaf/z2h1hQZEn3Nw1byXGYHrgiMfd+ESMC2L0793OUyq4FwEVL3z2MhJPj7C/1rdoJ1XTfIwdenKN/lkeyjkyXcA
Received: from [172.16.49.130] (070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id z22-20020a4a9c96000000b0059d544fc027sm889945ooj.35.2024.02.14.08.40.29
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Wed, 14 Feb 2024 08:40:29 -0800 (PST)
Message-ID: <5645df71-5fa8-497e-b5cd-b21557aa9bb3@gmail.com>
Date: Wed, 14 Feb 2024 10:40:28 -0600
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH] log: add l_notice
Content-Language: en-US
To: Marcel Holtmann <marcel@holtmann.org>
Cc: James Prestwood <prestwoj@gmail.com>, ell@lists.linux.dev
References: <20240213131619.828613-1-prestwoj@gmail.com>
 <0D7EFC7E-C3D9-43E0-823E-6C06498C6B3D@holtmann.org>
 <da1ddff5-80c7-46a4-9187-6cd8d5b2854b@gmail.com>
 <3129778E-09AF-46D9-97DE-44EC89C996DB@holtmann.org>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <3129778E-09AF-46D9-97DE-44EC89C996DB@holtmann.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi Marcel,

On 2/14/24 10:27, Marcel Holtmann wrote:
> Hi Denis,
> 
>>>> #define L_LOG_WARNING 4
>>>> +#define L_LOG_NOTICE 5
>>>> #define L_LOG_INFO 6
>>>> #define L_LOG_DEBUG 7
>>> for what? What is the difference to just use l_info?
>>
>> Per conversation on Slack, James wants to categorize certain messages for easier searching.  Since NOTICE level exists, I suggested it would fit the usecase.
> 
> I never really liked having many different levels. That was the reason I left l_notice out initially. I see no real benefit of it except us discussing "is this suppose to be l_info and l_notice" and in the end it will be just random.

There will always be some of that.  Each project will have to calibrate 
individually, but I don't see a problem exposing this inside ell.

In iwd we use l_info for purely informational messages, like hardware 
capabilities.  Most users won't care.  l_notice would be used for things like 
roaming decision logic and other messages that do not warrant a l_warn / 
l_error.  I think it is a nice in-between actually, particularly on non-user 
facing systems.

Regards,
-Denis
