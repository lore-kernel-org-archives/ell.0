Received: from mail-qt1-f172.google.com (mail-qt1-f172.google.com [209.85.160.172])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 538531BDE7
	for <ell@lists.linux.dev>; Tue, 16 Jan 2024 14:11:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="jGI4bsRS"
Received: by mail-qt1-f172.google.com with SMTP id d75a77b69052e-429c9c4c572so30850981cf.1
        for <ell@lists.linux.dev>; Tue, 16 Jan 2024 06:11:51 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1705414310; x=1706019110; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :from:to:cc:subject:date:message-id:reply-to;
        bh=fVzpwEoQfPtPjQzv2VpGt6AxRskaVqhxxi4Srse+Jnk=;
        b=jGI4bsRSIlUw32cTU3dxo1V029FOaFRcELdn12lUgOGdQboW4oSTJipQahAslPYQ2u
         r/xayhOKrlnbi0ou6CEQxLMABEJhxYsvfJ4z9KEE5g28gT/FRtcyDS8miGiyQBROanUA
         E0jhLu8/amrH8Q1ZIg5BYnoTi7mIc22steSj5wvAKMyOLedY7z9AHhDYf1cR4TTsufus
         yixFGXy2yl2ShVJKNkaW/8JzqlquaP4y2zDpe6JiVjS0QqDnkEJVtIXJ1EXwo5RQGGlR
         hQiD2Yrva+mhIcjDuS0Tp7NG6yx9851cHJBnGHzpLgzmCSG51+Xy8Gr0LyB7RF1i0rzR
         Citg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1705414310; x=1706019110;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=fVzpwEoQfPtPjQzv2VpGt6AxRskaVqhxxi4Srse+Jnk=;
        b=rG7+MOtzsT8ZDMGg7Dcr5PHkmG80lln0TOcIWCbLjblq8qZIphouGCBfqOE7QxKe0m
         dbeG7UBHVzT5PAtwR3DleOhpysoVusYWQUe9HkpSTdUGEbdJlHq184dh9NmvBYmalfS5
         yMezifpSjTCM/gnOLFfo08i7gJtwOeXc2fCzpBE1u3dD08/NA1jlKuISoaCU5ZmodzaQ
         HdMSjrsomixBLNy0Be/rAnvZy1KV9euDP2fa3rHZ/KKTBz6arUxzTfrd5HPcI4/N816v
         i389oCryvkRSydSKm5Xi7GQ0aEMr6RO7a2XKcoPSdeXtck3fhqs5Z+4/+McnM9J7tav5
         EcAQ==
X-Gm-Message-State: AOJu0YwegB10AsZxZs9qdpSKP/hozYUTn8PZYEXkesDfb2Db7EjupSbD
	9XduUYjsHPtgcqB3lOr44hynCx1IaAs=
X-Google-Smtp-Source: AGHT+IH8/J1+ajWgpU0jtaK3NcwjqlHeOoj3yuLolPdYNp4mB+l+aZHlVpKxTG+2uHzYoiRX8idPqw==
X-Received: by 2002:a05:622a:134a:b0:429:f7cd:dc2f with SMTP id w10-20020a05622a134a00b00429f7cddc2fmr2893308qtk.90.1705414310124;
        Tue, 16 Jan 2024 06:11:50 -0800 (PST)
Received: from [10.102.4.159] ([208.195.13.130])
        by smtp.gmail.com with ESMTPSA id z11-20020a05622a124b00b0042991cda66asm4874696qtx.14.2024.01.16.06.11.49
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Tue, 16 Jan 2024 06:11:49 -0800 (PST)
Message-ID: <a578bd10-9d47-402b-931c-5ca23aacb6a7@gmail.com>
Date: Tue, 16 Jan 2024 06:11:48 -0800
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH v2] dhcp: fix overflow causing retries to stop
Content-Language: en-US
To: Denis Kenzior <denkenz@gmail.com>, ell@lists.linux.dev
References: <20240111133331.1423853-1-prestwoj@gmail.com>
 <55a3b50e-637b-4df1-960b-a4af96002e78@gmail.com>
 <f7dff903-8614-4fc6-ba1c-93fa4788973d@gmail.com>
 <7d4efee9-1893-4242-897e-3df5dd1ef515@gmail.com>
From: James Prestwood <prestwoj@gmail.com>
In-Reply-To: <7d4efee9-1893-4242-897e-3df5dd1ef515@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

Hi Denis,

On 1/15/24 6:30 AM, Denis Kenzior wrote:
> Hi James,
>
> On 1/14/24 10:12, James Prestwood wrote:
>> Hi Denis,
>>
>> On 1/12/24 9:11 AM, Denis Kenzior wrote:
>>> Hi James,
>>>
>>> On 1/11/24 07:33, James Prestwood wrote:
>>>> If DHCP is in a SELECTING/REQUESTING state and the number of attempts
>>>> reached a value where 2 << attempts overflowed an unsigned int the
>>>> next timeout would become zero, causing DHCP to never retry without
>>>> any event notification.
>>>>
>>>> Roughly 2 minutes has passed when we reach >5 attempts so it makes
>>>> little sense to retry indefinitely, at least without notifying the
>>>> upper layers (which could decided to retry themselves).
>>>
>>> Okay, but '5' is just a magic number in the code with no context. 
>>> Lets avoid that.
>>>
>>> Can we make this limit configurable?  Say between 3..30?  For iwd, 
>>> even 2 minutes might be too long.
>>
>> I'm thinking it may be better to leave the default unlimited retries 
>> but add a configurable time limit versus retry limit. Setting based 
>> on retries isn't intuitive a) because 99% of people have no idea what 
>> the backoff algorithm is, and b) time limits are fuzzed so its not an 
>> exact amount of time.
>
> Hopefully we know enough to tune the retries :)
I was more saying in the context of someone using the ELL API, not 
specifically for IWD.
>
>>
>> I say this because if we want to include netconfig into IWD's 
>> Connect() DBus method return we kinda need a way to define a time 
>> limit as opposed to guessing how long 2-3 retries will actually take. 
>> We, potentially, could iterate through several BSS's and fail 
>> extending the time to connect, then start DHCP. We would need a way 
>> to limit netconfig to within the DBus method timeout (25 seconds 
>
> DBus method timeouts don't exist on the protocol level.  ell doesn't 
> even let you specify a method timeout for that reason. Some libraries 
> use a locally generated timeout by default (such as libdbus-1), but 
> such libraries usually provide a way to specify an arbitrary timeout, 
> or even disable it.
>
> The problem with such timeouts is that when a library-local timeout is 
> hit, creating a fake dbus method reply, there's no way to tell the 
> callee.  In the case of iwd, it will just continue its Connect() 
> operation since nothing happened as far as it is concerned.  Any dbus 
> method timeouts are up to the application to deal with correctly...
>
> Also, having dhcp use its own timeout incurs a cost of an extra 
> file-descriptor.  Not worth it.
>
>> IIRC), including how long all the connect attempts took prior. Maybe 
>> I'm overthinking it but theoretically we could hit the method timeout 
>> limit so we may want to add handling for it, which would be easier if 
>> we did the above with a timeout versus retries.
>
> All we can do is document that Connect might be a long-running 
> operation (should be obvious) for the reasons you outline.

So from an ELL perspective I'm fine adding a retries setter (though 
timeout makes more intuitive sense IMO) but I do want to explain some 
issues I see with utilizing this in IWD, and doing netconfig prior to 
the DBus method return.

Adding netconfig into the mix would greatly increase the likelihood of a 
DBus method timeout in "semi-normal" cases depending on the retry limit 
chosen. I understand the dilemma you explained above but I do think IWD 
should try its best to stay within the default DBus method timeout of 25 
seconds. Trying to do this while also doing netconfig seems difficult 
unless we really cut down the allowed retries, which has is drawbacks as 
poor RF could easily drop a few frames and we could quickly get up to 25 
seconds with the nature of the DHCP timeouts and if the wifi association 
took a while (multiple BSS retries).

I'm also not sure if a DBus method timeout is going to break or cause 
weird behavior with Connman/NetworkManager etc. And even if its handled, 
what exactly should they do in this case? Will DHCP complete? should 
they re-issue connect which could return -EBUSY? What happens when IWD 
does reply and a timeout has already occurred? It really opens up a lot 
of possibilities here.

This would have to be an IWD 3.0 change, but adding netconfig as a DBus 
state may be the better decision here. Then netconfig could take much 
longer (maybe user configurable), and we avoid/lessen the risk of method 
timeouts. To me this is similar to how Scan() works where the method 
returns quickly, but the caller then needs to wait for the scanning 
property before getting results.

Thanks,

James

> Regards,
> -Denis
