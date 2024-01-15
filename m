Received: from mail-oi1-f177.google.com (mail-oi1-f177.google.com [209.85.167.177])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 38BD710E3
	for <ell@lists.linux.dev>; Mon, 15 Jan 2024 14:30:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="E5fzbx5T"
Received: by mail-oi1-f177.google.com with SMTP id 5614622812f47-3bd489d75b7so2612253b6e.0
        for <ell@lists.linux.dev>; Mon, 15 Jan 2024 06:30:48 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1705329048; x=1705933848; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :from:to:cc:subject:date:message-id:reply-to;
        bh=VsSzaCwduOchzn1+pVq+Hh7TjtvGHZY8b8V7Q1YhHxM=;
        b=E5fzbx5TXaJbgrs44Gx+SYslxlrYsy4m96BJ8Q+EhIDp1Hx0ighAAn0XJf5rhcEVQb
         eLo3F3yh/XcVs7pN+HcnRHq0+QW/UvqCgXiMP4GArc7i1rnbPPXKKkh6tkv+tUoZjMcz
         mQoBPKWL7Lnc3lIiHT4HBW7UrfWv+iYHsrT0KwlVMLFLeMUM/UDFx0OUdmcls8pdH6kD
         5OCozbbNrPkn+jMZ2degipB+jj23Ygg22m3ilRf2fSr8hhjOMNAZqedM+fJi1o4qbqLb
         wlCwtS4vREJnCd0TnYVeCSMDM/wtYECSYip799p0XUrEJyQNBiS+qaNeW6MvFaPa7Bwx
         37ig==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1705329048; x=1705933848;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=VsSzaCwduOchzn1+pVq+Hh7TjtvGHZY8b8V7Q1YhHxM=;
        b=OtQx3XtMPpcqC2TSB9dX/preLmOn0YjPIchxGEdXHgkyzGEBFXB4MZzQMqVFESh3TO
         +c3lYe2OPH71ngFwWRQ92CMtvCEiUWiKn55h/xnC7TskCFHVNFz6/GaehvAmo6gYjy4W
         Hq/3wG3NvbN54sh5V21ujOwLfZSTZCvP99M+FfZ/hurZ2bxlUgzj3KkVj7kD6reKbs/z
         32BgSsMd3ZnyT3aMxvBte8F6f6e3knUkOlZqcMwTLHwLy71ow0o5HFhGK3jH4qs55mUy
         EtG0+h5hh8ln2onHBg7nslcecWv6QddK1g3+K7hGEOZ/hMsz+nS5rZ8mteymBYfkXyxa
         PwXQ==
X-Gm-Message-State: AOJu0YyBArkCpWioefnLydfp3bML18mPXf+gKqZM2hZloo5vCpFHGlez
	pJq84bPiHiMmp8YI0y1Gb1g=
X-Google-Smtp-Source: AGHT+IGay6eSbzvu0sAskKRLseoIVas3CXwPLjRW87iD085p7MdrbKq2afHBa1zveP10bX7eeR9ZGw==
X-Received: by 2002:a05:6808:120a:b0:3bd:44fa:d8a8 with SMTP id a10-20020a056808120a00b003bd44fad8a8mr4417425oil.40.1705329048167;
        Mon, 15 Jan 2024 06:30:48 -0800 (PST)
Received: from [172.16.49.130] (070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id z26-20020a056808065a00b003bd4e1835bdsm1365512oih.12.2024.01.15.06.30.47
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Mon, 15 Jan 2024 06:30:47 -0800 (PST)
Message-ID: <7d4efee9-1893-4242-897e-3df5dd1ef515@gmail.com>
Date: Mon, 15 Jan 2024 08:30:47 -0600
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
 <55a3b50e-637b-4df1-960b-a4af96002e78@gmail.com>
 <f7dff903-8614-4fc6-ba1c-93fa4788973d@gmail.com>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <f7dff903-8614-4fc6-ba1c-93fa4788973d@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

Hi James,

On 1/14/24 10:12, James Prestwood wrote:
> Hi Denis,
> 
> On 1/12/24 9:11 AM, Denis Kenzior wrote:
>> Hi James,
>>
>> On 1/11/24 07:33, James Prestwood wrote:
>>> If DHCP is in a SELECTING/REQUESTING state and the number of attempts
>>> reached a value where 2 << attempts overflowed an unsigned int the
>>> next timeout would become zero, causing DHCP to never retry without
>>> any event notification.
>>>
>>> Roughly 2 minutes has passed when we reach >5 attempts so it makes
>>> little sense to retry indefinitely, at least without notifying the
>>> upper layers (which could decided to retry themselves).
>>
>> Okay, but '5' is just a magic number in the code with no context. Lets avoid 
>> that.
>>
>> Can we make this limit configurable?  Say between 3..30?  For iwd, even 2 
>> minutes might be too long.
> 
> I'm thinking it may be better to leave the default unlimited retries but add a 
> configurable time limit versus retry limit. Setting based on retries isn't 
> intuitive a) because 99% of people have no idea what the backoff algorithm is, 
> and b) time limits are fuzzed so its not an exact amount of time.

Hopefully we know enough to tune the retries :)

> 
> I say this because if we want to include netconfig into IWD's Connect() DBus 
> method return we kinda need a way to define a time limit as opposed to guessing 
> how long 2-3 retries will actually take. We, potentially, could iterate through 
> several BSS's and fail extending the time to connect, then start DHCP. We would 
> need a way to limit netconfig to within the DBus method timeout (25 seconds 

DBus method timeouts don't exist on the protocol level.  ell doesn't even let 
you specify a method timeout for that reason.  Some libraries use a locally 
generated timeout by default (such as libdbus-1), but such libraries usually 
provide a way to specify an arbitrary timeout, or even disable it.

The problem with such timeouts is that when a library-local timeout is hit, 
creating a fake dbus method reply, there's no way to tell the callee.  In the 
case of iwd, it will just continue its Connect() operation since nothing 
happened as far as it is concerned.  Any dbus method timeouts are up to the 
application to deal with correctly...

Also, having dhcp use its own timeout incurs a cost of an extra file-descriptor. 
  Not worth it.

> IIRC), including how long all the connect attempts took prior. Maybe I'm 
> overthinking it but theoretically we could hit the method timeout limit so we 
> may want to add handling for it, which would be easier if we did the above with 
> a timeout versus retries.

All we can do is document that Connect might be a long-running operation (should 
be obvious) for the reasons you outline.

Regards,
-Denis
