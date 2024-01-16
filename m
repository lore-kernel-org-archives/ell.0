Received: from mail-oa1-f54.google.com (mail-oa1-f54.google.com [209.85.160.54])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7989A1C68D
	for <ell@lists.linux.dev>; Tue, 16 Jan 2024 16:13:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="F4C0GKVh"
Received: by mail-oa1-f54.google.com with SMTP id 586e51a60fabf-204235d0913so6434387fac.1
        for <ell@lists.linux.dev>; Tue, 16 Jan 2024 08:13:31 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1705421610; x=1706026410; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :from:to:cc:subject:date:message-id:reply-to;
        bh=NUJ32oUaz8HIBRUawX3f5+FHGQ+lLcdH6OuHlIyuMas=;
        b=F4C0GKVh945Z3MVRMzvahAYlpW/kC7sriQ41lVtxTwJmZw78RQak2woz0ZgAWIM4WA
         9v5sFdwYjXFVymU3uAEiw9BJ5vjwas7eRKmSwTfF6m4eogKHcCc16owjjKErtheJTNYg
         9Y1FC2XwS2Ruz88Mb9KxdDlWDL3Lwc7WZEMEt+SOnzqvhwsBql6KxdBAEfWl5Lw/w3Nh
         A+Jwi82Y8kzX7RSYMo5htuyl9z0o20bDopGl6//fIp9sZBpKZRcTecaDg7QrpgB1zXZg
         Itbzmeig1CszV+V4hhSg/YvpCzrdAEs+ffZKzhECtGxfeKNOt4r0Sb688uILV7vIj/0o
         IpBw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1705421610; x=1706026410;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=NUJ32oUaz8HIBRUawX3f5+FHGQ+lLcdH6OuHlIyuMas=;
        b=AhBQwkRwIGF5pjeOI/AYc2kkuEa9dHQYgcmp+/4JwTaFEoGEt8KnoO2zU2hWPccldx
         Pa+flROWNKaJJb8u8qh8avkDYB/zzMSpBdzefp7PqTBjTnnItiTspq+yhKuyrfGs3g0L
         QO/x4zOWjVE48aGy4MzC3S7FnN9/3651L12yq97DES/ow/aVSHSP/pGhagC9C8X0j/hg
         GU+uU9N6gx2BYcvoSmIQrT1zlkny+2MDoH7ZoqUl1qzItnQN68tL6uB59HQYF7Fn2Gl4
         u4FShQVih0mlkHk88HES25UibAWJo2dCaoe5dvDkEyhwDSmMYOSYZSBr9kbiiPSC1QNB
         1UIQ==
X-Gm-Message-State: AOJu0YzTd64MYRWxH5LiB7q3Zz1cNRJj9w3cp9f4mTUPqwQYW3FpeKw6
	Djxc1vROJFS+4xcqLepi4nRNdAK/8Ro=
X-Google-Smtp-Source: AGHT+IEifgiAJsL/UU/EXFp1CBQukKiKH5Y16a37EyrOnSFrbbzi7Xy/TSmmcrmcoF8vUix6qNSWvw==
X-Received: by 2002:a05:6870:9513:b0:206:a3d2:8325 with SMTP id u19-20020a056870951300b00206a3d28325mr7176521oal.54.1705421610382;
        Tue, 16 Jan 2024 08:13:30 -0800 (PST)
Received: from [172.16.49.130] (070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id qb12-20020a056871e78c00b0020807d8d26esm1464125oac.27.2024.01.16.08.13.29
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Tue, 16 Jan 2024 08:13:30 -0800 (PST)
Message-ID: <9e9aeb2b-7e2b-4c24-b439-3bd31bf3f1c0@gmail.com>
Date: Tue, 16 Jan 2024 10:13:29 -0600
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
 <7d4efee9-1893-4242-897e-3df5dd1ef515@gmail.com>
 <a578bd10-9d47-402b-931c-5ca23aacb6a7@gmail.com>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <a578bd10-9d47-402b-931c-5ca23aacb6a7@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi James,

> 
> So from an ELL perspective I'm fine adding a retries setter (though timeout 
> makes more intuitive sense IMO) but I do want to explain some issues I see with 
> utilizing this in IWD, and doing netconfig prior to the DBus method return.

I disagree here.  For the dhcp_client, max retries is a much clearer 'lever' to 
adjust than the overall timeout.  As you said earlier, with fuzzing the number 
of retries in a given period can vary.  If the upper layers want to enforce a 
given timeout, they can do so anyway.

> 
> Adding netconfig into the mix would greatly increase the likelihood of a DBus 
> method timeout in "semi-normal" cases depending on the retry limit chosen. I 
> understand the dilemma you explained above but I do think IWD should try its 
> best to stay within the default DBus method timeout of 25 seconds. Trying to do 

You'll have to explain why you make this assertion?  If DBus bindings being used 
don't allow setting an infinite timeout, get better bindings.  I don't see any 
need to force iwd into fitting into this arbitrary 25 second limit.  And anyway, 
Connect() already can invoke Agent methods, which can take arbitrarily long 
anyway.  So netconfig is the least of your problems.

> this while also doing netconfig seems difficult unless we really cut down the 
> allowed retries, which has is drawbacks as poor RF could easily drop a few 
> frames and we could quickly get up to 25 seconds with the nature of the DHCP 
> timeouts and if the wifi association took a while (multiple BSS retries).

Do you have any data / examples to back up this assertion?

> 
> I'm also not sure if a DBus method timeout is going to break or cause weird 
> behavior with Connman/NetworkManager etc. And even if its handled, what exactly 

Not if they're written properly.

> should they do in this case? Will DHCP complete? should they re-issue connect 
> which could return -EBUSY? What happens when IWD does reply and a timeout has 
> already occurred? It really opens up a lot of possibilities here.

That is why I said that timeout handling has to be handled by the application. 
Most I've seen in real life do this poorly since there is usually a fundamental 
misunderstanding of how D-Bus works under the hood.

In practice, locally generated timeouts like the one used by default in 
libdbus-1 are just a bad idea.  I have no clue why they were added originally. 
If you have a misbehaving service on your bus which leaks messages, you will end 
up clogging D-Bus at some point and only a service restart will fix that.  Your 
service always has to reply to the message.  If you trust your running-as-root 
services to do the right thing, then adding arbitrary timeouts just gets in the way.

The fact that the timeout happened is unknown to the dbus peer.  It will 
continue as if nothing happened, and if well-behaved will generate a reply 
message eventually.  This has to happen for proper functioning of D-Bus.  The 
dbus-daemon will track that reply and forward it to the caller.  The caller's 
dbus implementation will just drop it on the floor since the reply-to serial 
number is no longer on the pending list.

So your iwd client has only two choices:
1. Call Connect() with no timeout and trust iwd to do the right thing.
2. Handle timeouts by trying to abort the connection somehow.  Perhaps via 
Station.Disconnect().  But that has its own side-effects.
3. If a timeout happens, assume iwd service is dead and restart it.

Hint: Option 1 or 3 is preferred

Regards,
-Denis
