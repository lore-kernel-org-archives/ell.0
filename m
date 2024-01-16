Received: from mail-qv1-f51.google.com (mail-qv1-f51.google.com [209.85.219.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B98601CA89
	for <ell@lists.linux.dev>; Tue, 16 Jan 2024 17:06:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1705424772; cv=none; b=eVrAXgvVqt7kkoOIVaGO9eiPmWYwaE/G7Ytvw65LnPdZ/yoNgrvZp2V/1zDWaz2IvzihtmZHCUJbuKuZXha5yGSR4E+DlkTzEMqxlZky5A/FKLbfH4p9sf8orLNgHNFYnwtW9A7N1zv4sk9wfyAVyG9SmIWl/OuhwTO6qDfXwl4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1705424772; c=relaxed/simple;
	bh=5FbLWIgBM/QCQU9OSUymCC4KyaQ3nSB//FVt8Izdp80=;
	h=Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Google-Smtp-Source:X-Received:Received:
	 Message-ID:Date:MIME-Version:User-Agent:Subject:Content-Language:
	 To:References:From:In-Reply-To:Content-Type:
	 Content-Transfer-Encoding; b=dqbJS5S3s9NAAGeuXsAwTmrZ3KwAShd9BSQXsz0Wady+vQvL/y6vKN0jZTJHbqPhkZJtjqkgmafb8u6yJ1h5VZD0cmA63L/xEKE+HfBtXq8I4S7iRavBtu1yYES0BSL29GpG6jMYJuvvLGW0R4LkcmjiuldgpoJmOzCVEGSCXPE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=PbxLf1ZM
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="PbxLf1ZM"
Received: by mail-qv1-f51.google.com with SMTP id 6a1803df08f44-68137fd70b4so29150666d6.2
        for <ell@lists.linux.dev>; Tue, 16 Jan 2024 09:06:10 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1705424769; x=1706029569; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :from:to:cc:subject:date:message-id:reply-to;
        bh=45Mz5Rn9enTNcmugfYxAfex02LdEKYZN+ByRgJgBeaU=;
        b=PbxLf1ZMRkJ7dDFpXTSRbEVUNosh9blQMLXBNYAydXhsoQvHx+TkA+abeC2eIBKxvi
         kw2i1/hhSNSBv9NoypcP+v/Txyh8hRt62W+c2rJMRhq3zI42Asm0XW44eO8qVxau/nss
         0qh3vGHJo/w9j45/VSKFOZjaQ8OEV8K+/vwHxGc+KvgdmpbDlKcH6PZEneI7m8wtn+lL
         L9b8c9JHPaVHKyBC6nEJ4kASDoco+d1waGXRtGzWnCdTwrLw4YyRvpc7gr27Yk91oj5I
         o+Z4WiSsa/KmVKCxe0VVYCOBYmlLfqIpfG0weYgFxyxiYaSOuestuPux6awfARLr/a27
         WhOw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1705424769; x=1706029569;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=45Mz5Rn9enTNcmugfYxAfex02LdEKYZN+ByRgJgBeaU=;
        b=tdlnVRvqGxKxbcGcyAxWkooiq7oySsr1WcjCoiXoNYvoGHj5OEixQSramS0Qfi68H5
         zisEdZKImNkbev6yXtBrPHPq4gZnV9gx13bXiZncsTmlvdfg6FjpkmU572iI+9pCIbKP
         TyIInmFuyKgRJdo+gA83Fmk+GDEjwKhn22cYoSC9BxUKDSaQ+lfexzj37X3BU+2iZTci
         C6JCVXGHg+kH3Xl2dSGCMOTGU9ZIHkoaD0VNdGPVidrhvdUHExzEsph8dKEAEr5g2cMA
         Ivpoda6TeZDniFSqBqz8Vo9uN6N69uyqdKLe+qCzP3QuQHD8CBluvNRtljVHRsOT7veE
         ZvZQ==
X-Gm-Message-State: AOJu0YyM7W3PmVh8AQVPZUxS+8u/1uheN9V2WGcm/u5F2IjoMiNOZymA
	L3l6voBnonKbjcldSeHzNKmYnJTbRcU=
X-Google-Smtp-Source: AGHT+IEX5Xvn+cOIy7QGg+gNv4O1gEhqhF2Xp0aUk7/aj3vBXTfpOMiI9cW6rs/gRHnVbgWPM3Tw8Q==
X-Received: by 2002:a05:6214:519d:b0:67f:b8a5:2eb5 with SMTP id kl29-20020a056214519d00b0067fb8a52eb5mr7659569qvb.101.1705424769506;
        Tue, 16 Jan 2024 09:06:09 -0800 (PST)
Received: from [10.102.4.159] ([208.195.13.130])
        by smtp.gmail.com with ESMTPSA id i12-20020a056214030c00b0067f812c4a58sm4270336qvu.60.2024.01.16.09.06.08
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Tue, 16 Jan 2024 09:06:09 -0800 (PST)
Message-ID: <5df697dc-7c11-49dc-82a5-251d05165870@gmail.com>
Date: Tue, 16 Jan 2024 09:06:07 -0800
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
 <a578bd10-9d47-402b-931c-5ca23aacb6a7@gmail.com>
 <9e9aeb2b-7e2b-4c24-b439-3bd31bf3f1c0@gmail.com>
From: James Prestwood <prestwoj@gmail.com>
In-Reply-To: <9e9aeb2b-7e2b-4c24-b439-3bd31bf3f1c0@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

Hi Denis,

On 1/16/24 8:13 AM, Denis Kenzior wrote:
> Hi James,
>
>>
>> So from an ELL perspective I'm fine adding a retries setter (though 
>> timeout makes more intuitive sense IMO) but I do want to explain some 
>> issues I see with utilizing this in IWD, and doing netconfig prior to 
>> the DBus method return.
>
> I disagree here.  For the dhcp_client, max retries is a much clearer 
> 'lever' to adjust than the overall timeout.  As you said earlier, with 
> fuzzing the number of retries in a given period can vary.  If the 
> upper layers want to enforce a given timeout, they can do so anyway.
>
>>
>> Adding netconfig into the mix would greatly increase the likelihood 
>> of a DBus method timeout in "semi-normal" cases depending on the 
>> retry limit chosen. I understand the dilemma you explained above but 
>> I do think IWD should try its best to stay within the default DBus 
>> method timeout of 25 seconds. Trying to do 
>
> You'll have to explain why you make this assertion?  If DBus bindings 
> being used don't allow setting an infinite timeout, get better 
> bindings.  I don't see any need to force iwd into fitting into this 
> arbitrary 25 second limit.  And anyway, Connect() already can invoke 
> Agent methods, which can take arbitrarily long anyway.  So netconfig 
> is the least of your problems.
Just based on the bindings we use for test-runner and the bindings I've 
been using recently (dbus_next), both have a 25 second method timeout. 
It appears that "dbus" (what we use in test-runner) might let you 
specify a timeout, not sure about dbus_next. I just wanted to 
communicate that a timeout is common across these bindings, for better 
or worse. If we don't want to conform to that, that's fine.
>
>> this while also doing netconfig seems difficult unless we really cut 
>> down the allowed retries, which has is drawbacks as poor RF could 
>> easily drop a few frames and we could quickly get up to 25 seconds 
>> with the nature of the DHCP timeouts and if the wifi association took 
>> a while (multiple BSS retries).
>
> Do you have any data / examples to back up this assertion?
We have seen DHCP take 10-15 seconds due to dropped frames. All I'm 
saying is that just a few dropped frames can drastically increase the 
time. If we don't care about the arbitrary 25 second timeout, then this 
is fine, I just was pointing that out.
>
>>
>> I'm also not sure if a DBus method timeout is going to break or cause 
>> weird behavior with Connman/NetworkManager etc. And even if its 
>> handled, what exactly 
>
> Not if they're written properly.
>
>> should they do in this case? Will DHCP complete? should they re-issue 
>> connect which could return -EBUSY? What happens when IWD does reply 
>> and a timeout has already occurred? It really opens up a lot of 
>> possibilities here.
>
> That is why I said that timeout handling has to be handled by the 
> application. Most I've seen in real life do this poorly since there is 
> usually a fundamental misunderstanding of how D-Bus works under the hood.
Ok, I'll definitely add handling for this, hopefully everything else 
using Connect() already handles it.
>
> In practice, locally generated timeouts like the one used by default 
> in libdbus-1 are just a bad idea.  I have no clue why they were added 
> originally. If you have a misbehaving service on your bus which leaks 
> messages, you will end up clogging D-Bus at some point and only a 
> service restart will fix that.  Your service always has to reply to 
> the message.  If you trust your running-as-root services to do the 
> right thing, then adding arbitrary timeouts just gets in the way.
>
> The fact that the timeout happened is unknown to the dbus peer. It 
> will continue as if nothing happened, and if well-behaved will 
> generate a reply message eventually.  This has to happen for proper 
> functioning of D-Bus.  The dbus-daemon will track that reply and 
> forward it to the caller.  The caller's dbus implementation will just 
> drop it on the floor since the reply-to serial number is no longer on 
> the pending list.
>
> So your iwd client has only two choices:
> 1. Call Connect() with no timeout and trust iwd to do the right thing.
> 2. Handle timeouts by trying to abort the connection somehow. Perhaps 
> via Station.Disconnect().  But that has its own side-effects.
> 3. If a timeout happens, assume iwd service is dead and restart it.
>
> Hint: Option 1 or 3 is preferred
>
> Regards,
> -Denis
