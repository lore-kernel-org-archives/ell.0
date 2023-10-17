Received: from mail-ot1-f49.google.com (mail-ot1-f49.google.com [209.85.210.49])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2CDF4EBE
	for <ell@lists.linux.dev>; Tue, 17 Oct 2023 15:26:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="GjVJZZy4"
Received: by mail-ot1-f49.google.com with SMTP id 46e09a7af769-6ccfe703184so356179a34.0
        for <ell@lists.linux.dev>; Tue, 17 Oct 2023 08:26:55 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1697556414; x=1698161214; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :from:to:cc:subject:date:message-id:reply-to;
        bh=MB2mqyF2FWCuiYaeH7yV3VUPw+bdk06pcsfrpY5kBOE=;
        b=GjVJZZy4j9oarsZH8hnt+iermELkRnUHm6IpquWYXNTlnqJ/OEOtr4lis5t8D2/nas
         U+nUT0BnZSDQEL80s+8zHxOdneJcA2HZGDjXnnptEBDyxHzv6qk4Olf1Vn3OqXPhEonF
         s0XthqlaHN7bmNvTJpAvMKttHqvequ7wC562/UqYLkWGkjMa6H6bMHc8z5CuQZJgCpp8
         tZlF9L4noM/gSPopM4nEOBMtrb0mySe9vSbwwaOgz2wfP94879cHJNrjpl5ZjuPWlLsc
         FZpgF2edzjes7YN3A9PocDv1oGuUEEgifbiGpO0yaciq1Lyio9HSTJ0wUvtxWIAsaNNx
         NAlw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1697556414; x=1698161214;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=MB2mqyF2FWCuiYaeH7yV3VUPw+bdk06pcsfrpY5kBOE=;
        b=jM0reH4WOdxYglcvbtqaL7EDSpDa28L/ISsvfhPdkUBG89GEB2rzHHx9Xoo8+47Ghl
         6gTtko7O83jBDzIGZY56cNGYNm8brAQ6uGjNfVV3CDwkxtBy3u6pfk1oqYe2gxQxRS1T
         Dge9jP9IQAbs/TiBRaF0RDfiGTxfXDaAc4vkQT6hYW1bw5cK3rgpsbAjdfUjrfADJWZQ
         W77+R7kVfkLwIit7bx/mbBbN62jJFTjqilRLKqfEnr4CPKI4QnockCkSFY7iYVCwXLCz
         /13A8qmP2tGQJ83QDBf3OOuNhZMRuFjPuxM2gmcEzCDU2c1f7fn/1ZNhqjnbphlRA/Hu
         bd1A==
X-Gm-Message-State: AOJu0Yw5V+riLHxhF4qqx4lupKL5Pu7+sBNswx8UHq6+nUopNAgMwi0b
	vrmZpMjrhJ023OQCqHk6ITJnVgShmEo=
X-Google-Smtp-Source: AGHT+IEyEmpy+gYgFRFuUdd16LY6P6nDNdxP8tmonrZt1fcLIMzSP5EDwnndfujN7uJPfT6QPSWZbQ==
X-Received: by 2002:a05:6830:348a:b0:6b9:350e:4051 with SMTP id c10-20020a056830348a00b006b9350e4051mr3447527otu.4.1697556414296;
        Tue, 17 Oct 2023 08:26:54 -0700 (PDT)
Received: from [172.16.49.130] (cpe-70-114-247-242.austin.res.rr.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id o11-20020a9d410b000000b006af913c1044sm299562ote.16.2023.10.17.08.26.53
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Tue, 17 Oct 2023 08:26:53 -0700 (PDT)
Message-ID: <aeb71836-df9b-456d-8f0d-c782c3a70fc8@gmail.com>
Date: Tue, 17 Oct 2023 10:26:52 -0500
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: =?UTF-8?B?UmU6IFtQQVRDSF0gZ2VubDogZml4IOKAmGF0dHJfZ3JwLm5leHRfbGVu?=
 =?UTF-8?Q?=E2=80=99_may_be_used_uninitialized?=
Content-Language: en-US
To: Lyubimov Maxim <m.lyubimov@aqsi.ru>, ell@lists.linux.dev
References: <4103d54928605fb3d2a573ba6890395b4a155138.camel@aqsi.ru>
 <a07bc07e-a2ae-4a3a-8698-190cd758955c@gmail.com>
 <08b740ec5ea8936c49c4242b59e33aba475a6fe4.camel@aqsi.ru>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <08b740ec5ea8936c49c4242b59e33aba475a6fe4.camel@aqsi.ru>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi Maxim,

> 
> Lyubimov Maxim. Okay, I'll fix the config.
> 

Ok, I force-pushed an update with Author: Maxim Lyubimov <m.lyubimov@aqsi.ru>

>> Something in your mail server is messing with the text format.  I had
>> to
>> manually edit the patch so it would apply properly (by e.g. removing
>> the newline
>> before this '{').  Please fix that since I can't do this for more
>> than the
>> simplest patches.
> 
> I wanted to ask what git-send-email configuration should be used to
> send patches correctly?

I'm not aware of any special git-send-email configuration.  Mine is simply:

[sendemail]
        smtpencryption = tls
        smtpserver = smtp.gmail.com
        smtpuser = denkenz@gmail.com
        smtpserverport = 587

It may be the outgoing mail server you're using is doing something 'smart'.

Regards,
-Denis

