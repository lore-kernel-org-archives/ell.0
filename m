Received: from mail-pg1-f177.google.com (mail-pg1-f177.google.com [209.85.215.177])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 793B638F80
	for <ell@lists.linux.dev>; Tue,  9 Jan 2024 12:18:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="lewYaQMV"
Received: by mail-pg1-f177.google.com with SMTP id 41be03b00d2f7-5c6ce4dffb5so1074948a12.0
        for <ell@lists.linux.dev>; Tue, 09 Jan 2024 04:18:11 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1704802691; x=1705407491; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id:from
         :to:cc:subject:date:message-id:reply-to;
        bh=7EubSYxNvtQtPL3I+ETlEuZfsHRP/5BkvAjsHViQGfo=;
        b=lewYaQMVLjGgz0JvatKIrVL82hOqRiTXAwLp1iLGcDFwGTv0ata9rpQZPOAa6dM+6Q
         e2G+DL7VERWjE7mAcs1lzCpIrVLL5k42EZHhxE8udze1T7Xh+EpQ4PmggWnuh7FG79kU
         dj3eTj9t5PIUR4OfYHxp8L4A8NdrteLpazpM5J6rOamEnZq9+YZ499xbuy4EW9b6/rLD
         WhLHjU5OOAfdRQIX7FQOnSTr5GxWbp5unTZ3inehci0R//QLJ4mhr6mnp+1fze/9XBwC
         BVUDoHzsuiuCs+tTngoPuXP1UfIhHCFYplIsB1tOnVPy3ztJDUMw8LNXTUY5XBWogApv
         rCPQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1704802691; x=1705407491;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=7EubSYxNvtQtPL3I+ETlEuZfsHRP/5BkvAjsHViQGfo=;
        b=vPbgaWtcHo9wNLYqwn+FoUQUlP6A0mII4hslJhSww5TGZ8rTH9k/RMcKFO9qg9ukl2
         +vQZaeboRczoxyYS5PGIwiaiE0bYIgkgaWuQ5pmaR1iI1UiyvyYL4Df+IYfuemMjxWWA
         yUDiFVbJXPBY392fC17Jy+ciThBNdap0vggb976HsE+JRqFQwQqCBXwAWgH8xgWtEE00
         Ixqe+xP96A65CSeyGqF6WCDaf4wrmLFCsS28wrlCJZbSI+8sWuHMa9wAOQt+gdIw+snl
         2jXK2uius6jRJlYKVeTN4ntRTM9+mO132XECSy6Qz6mhbBzERw0gA5B+fk8/vhMDJrMU
         C5OQ==
X-Gm-Message-State: AOJu0YybOv9RaeNnL731j0KRA6aeRpt+57tAXi+4cUbmZy3USW/ygkm3
	pbW5H6ksGF2GaYLTyg4wbd/ZIMztlbw=
X-Google-Smtp-Source: AGHT+IFPc4KJauSojoKBwBsHaljG1oM+MpX2tJOrpDKwkWx5GXiTjMk22mDjCQdFOunUvJ3yysxaqg==
X-Received: by 2002:a05:6a21:a592:b0:199:f966:eed with SMTP id gd18-20020a056a21a59200b00199f9660eedmr514865pzc.77.1704802690709;
        Tue, 09 Jan 2024 04:18:10 -0800 (PST)
Received: from [192.168.254.82] ([50.39.172.77])
        by smtp.gmail.com with ESMTPSA id pw17-20020a17090b279100b0028da44b2c33sm928517pjb.27.2024.01.09.04.18.10
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Tue, 09 Jan 2024 04:18:10 -0800 (PST)
Message-ID: <5daea0fc-f020-44e7-af2a-e034b9a1c148@gmail.com>
Date: Tue, 9 Jan 2024 04:18:09 -0800
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH] dhcp: fix overflow causing retries to stop
To: Denis Kenzior <denkenz@gmail.com>, ell@lists.linux.dev
References: <20240109040621.1248647-1-prestwoj@gmail.com>
 <894bfef2-52fd-4f99-b257-1e637388a375@gmail.com>
Content-Language: en-US
From: James Prestwood <prestwoj@gmail.com>
In-Reply-To: <894bfef2-52fd-4f99-b257-1e637388a375@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

Hi Denis,

On 1/8/24 8:27 PM, Denis Kenzior wrote:
> Hi James,
>
> On 1/8/24 22:06, James Prestwood wrote:
>> If DHCP is in a SELECTING/REQUESTING state and the number of attempts
>> reached a value where 2 << attempts overflowed an unsigned int the
>> next timeout would become zero, causing DHCP to never retry.
>>
>> Since 5 attempts results in a value of 64 we can instead just limit
>> the attempts to 5, and set next_timeout to 64 after that as the spec
>> requires.
>
> Overflowing next_timeout implies that discovery is taking ~25 
> minutes?  I think I'd rather we gave up and sent a NO_LEASE event 
> after retries hits a certain max number?

Yep, this is whats happening, the DHCP server is down. Obviously we 
could change the logic, but NO_LEASE appears to just restart the DHCP 
client, i.e. no real difference between trying discovery forever. Should 
we add another event, L_DHCP_CLIENT_EVENT_TIMEOUT?

Thanks,

james

>
> Regards,
> -Denis
