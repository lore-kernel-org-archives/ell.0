Received: from mail-oi1-f173.google.com (mail-oi1-f173.google.com [209.85.167.173])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0FF193B795
	for <ell@lists.linux.dev>; Tue,  9 Jan 2024 17:49:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="WB0pcz7c"
Received: by mail-oi1-f173.google.com with SMTP id 5614622812f47-3bb9b28acb4so2855823b6e.2
        for <ell@lists.linux.dev>; Tue, 09 Jan 2024 09:49:52 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1704822592; x=1705427392; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :from:to:cc:subject:date:message-id:reply-to;
        bh=PQpVcVuNr37q5/WKf+61mJZ5mxGfqaFVPKOxIXwqxNQ=;
        b=WB0pcz7cwryQG51xgwXL2GaE3afClSbdEIC/hej3EBeUhRMwQPJ7mzQlXV5oXRH8xV
         tgG0DvsNOJ0OVCRYrnzI2qE4HRw/iu23IQO+8SvDs0t0iWsMpv/6wYLBlzfULrbbi1cM
         1vPmRZOwwmmJTw2xrx+pXCyuf8sxmHsF9KL9WEn2jpla2jGbgfyYa6jp4yyS/8+nAR5v
         SPLE4rXJToJW0iOBRK40IsoAaWxtPAT02eYrffn44u+ea0fMNLyA0JziWgMh7e32GNIs
         oB7pM3FhLrWFncWLX/ZYa57e2UlXXvjIFR4QQzgqzO8n2WYuj3D0XvOksi7HzoZj7Gr/
         t62g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1704822592; x=1705427392;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=PQpVcVuNr37q5/WKf+61mJZ5mxGfqaFVPKOxIXwqxNQ=;
        b=Sbqk6YJre0J2uC9ridMzbcW0n/2ip3XoCAL+4IyU4gLySFfaGAOPL9Tjm75qKKy2HT
         0BK9XRWUNtjwscwMFjCXgMvog88zedsQnF5318JwRnMJMaf8hOJ2aDQ866L7+KwapQxU
         3gkwxti9ldDyUU/0RsG/Bs5bPD6sqHmnULAc8KsgVZfbHI4JrpnKD7AgfRcRwY2eenh5
         PVuoGdOCKQ3K6fr+aqPVKQVn2PR4N9APvcNSFQKHKxU5chKyfrcPb77fIq/HHTAMhPrX
         57inqA2e4BTKVEnr8MDbEOgkeewQ8RFYAMnPi98DFG47EBfpgM2mXOPNZNwbMmvAxLwF
         jU8Q==
X-Gm-Message-State: AOJu0Yx7onmsLoOaKBSnIi5Q0uXtyJ2ezDdbozaI9XnxaL7G1x3gOI5h
	FBbZT1km0V+s16qoDnBWyq8=
X-Google-Smtp-Source: AGHT+IHYScHDBAMQwEJslmgChs+TMNvHCoEcDVCnTcP8+KPlNwC0Amy5o6TY02GHzIAmya6NMe/5pQ==
X-Received: by 2002:a05:6808:f10:b0:3bd:40f1:b867 with SMTP id m16-20020a0568080f1000b003bd40f1b867mr972321oiw.109.1704822592120;
        Tue, 09 Jan 2024 09:49:52 -0800 (PST)
Received: from [172.16.49.130] (070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id k26-20020a05680808da00b003bbb7cfe26csm410106oij.50.2024.01.09.09.49.51
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Tue, 09 Jan 2024 09:49:51 -0800 (PST)
Message-ID: <74b8d264-fb28-4a2d-84e6-669c61616b8c@gmail.com>
Date: Tue, 9 Jan 2024 11:49:51 -0600
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH] dhcp: fix overflow causing retries to stop
Content-Language: en-US
To: James Prestwood <prestwoj@gmail.com>, ell@lists.linux.dev
References: <20240109040621.1248647-1-prestwoj@gmail.com>
 <894bfef2-52fd-4f99-b257-1e637388a375@gmail.com>
 <5daea0fc-f020-44e7-af2a-e034b9a1c148@gmail.com>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <5daea0fc-f020-44e7-af2a-e034b9a1c148@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

Hi James,

On 1/9/24 06:18, James Prestwood wrote:
> Hi Denis,
> 
> On 1/8/24 8:27 PM, Denis Kenzior wrote:
>> Hi James,
>>
>> On 1/8/24 22:06, James Prestwood wrote:
>>> If DHCP is in a SELECTING/REQUESTING state and the number of attempts
>>> reached a value where 2 << attempts overflowed an unsigned int the
>>> next timeout would become zero, causing DHCP to never retry.
>>>
>>> Since 5 attempts results in a value of 64 we can instead just limit
>>> the attempts to 5, and set next_timeout to 64 after that as the spec
>>> requires.
>>
>> Overflowing next_timeout implies that discovery is taking ~25 minutes?  I 
>> think I'd rather we gave up and sent a NO_LEASE event after retries hits a 
>> certain max number?
> 
> Yep, this is whats happening, the DHCP server is down. Obviously we could change 
> the logic, but NO_LEASE appears to just restart the DHCP client, i.e. no real 

I'm not sure why netconfig does that actually.  From the comment it seems like 
it expects NO_LEASE event when the old address could not be obtained.  But, if I 
recall correctly, ell's dhcp client implementation only includes the old address 
when using RENEW or REBIND, and never on a fresh dhcp_client_start()-up due to 
privacy policy.

In the end, it is up to netconfig to implement a policy it wants.  Re-starting 
discovery is a valid policy, but I think in iwd's case, we should have netconfig 
treat 'NO_LEASE' as a DHCP server going down / server not present.  Having a max 
number of retries can facilitate that.  For example, if we're connecting and 
reach max_attempts of 6 or so, then give up and have iwd fail the connection.

> difference between trying discovery forever. Should we add another event, 
> L_DHCP_CLIENT_EVENT_TIMEOUT?

l_dhcp_client sends NO_LEASE when it gets a NAK and there's no point in 
continuing without further intervention (or configuration change).  Server not 
responding seems to fall into the same category, but we can also add an event 
explicitly for this.  Maybe MAX_DISCOVER_ATTEMPTS_REACHED?

Regards,
-Denis
