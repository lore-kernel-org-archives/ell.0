Received: from mail-oi1-f170.google.com (mail-oi1-f170.google.com [209.85.167.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 671677E
	for <ell@lists.linux.dev>; Sun, 14 Jan 2024 16:12:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="gZUMbzxb"
Received: by mail-oi1-f170.google.com with SMTP id 5614622812f47-3bb53e20a43so5690046b6e.1
        for <ell@lists.linux.dev>; Sun, 14 Jan 2024 08:12:31 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1705248750; x=1705853550; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id:from
         :to:cc:subject:date:message-id:reply-to;
        bh=mSxL0X3JRdYlMawJJJTsGktK9hAa9JFIMIHHd59zx1o=;
        b=gZUMbzxbq2wiyOTtwP4zI/6uy1GJtJKK0+Iu3FUtoJuIvkBU12e+M5XsbFENXF4uBY
         kZ1l2V+B5A4oZqWaMVV8UA4E/kjFWOPzp4Z0Y1bPj0z1RvN2AK8Qo70m/75H/XIK36AK
         msZ9faTf6PGfc5wXRcEcBl1TCXjxrnWC1oGuqEsn+Hk2Ul9SEySHYXaFfIZ1FFzE9H9G
         R0rd+FVGs5Jl9TOUKdPZTsRQAj6rCoEeOpoKaTHNbKulRLyjh5MDys824Bvl6jj9KVJ+
         EaCTJPzYlzBoudy5t5TK9sBhizFbrA2V6qWknCx10SK+GsX0UOnN328q4eJQSDpAVVD5
         8wBg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1705248750; x=1705853550;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=mSxL0X3JRdYlMawJJJTsGktK9hAa9JFIMIHHd59zx1o=;
        b=LRaV3z7MWdDMejb+dqWNstuAIl6A4WtHXp6dZZkOLGfWTXmB1yzd6DvjLPT7U7taEW
         Q7ZB2BxZp08gojKeVrY/DoLu4OqfVeAamh5mKoBbaYRwQAi3zadCZ8/4DreDDO4Otxnu
         0pMdc997vCtHxyV06e91yKc75QoVQSWMIXvTilDX67NpOpuhEZfYi48NomrG1kzeF5Nc
         oK79AzwuKIooYQoUS9wY8E1RucLwUPWc9HSNNIpsbxPwaL16cQR1M500CLTs4HQFvOv1
         l4YNE38v7s7b5ONbvxMIvNp51ffF6lq4aAUI+3/ztOcTyDhTa/JGqHnhpbK/CT53UZR3
         4TEA==
X-Gm-Message-State: AOJu0YxY82uYhGV8hm7J6spns+vhHHAcDnLFSY3AEINr0QbtKFSbanmQ
	nri7CCwOHD9r7L6cYqrDGPSXVKU8pXU=
X-Google-Smtp-Source: AGHT+IH/2uElWZSOBjwJS5IsN77jxp3Kz7PY/1yUxrqea8b21Wg1TxQ/0huWAlM9yxfc9hhYPsKNPA==
X-Received: by 2002:a05:6358:1996:b0:172:dd11:bfa8 with SMTP id v22-20020a056358199600b00172dd11bfa8mr4828590rwn.30.1705248750068;
        Sun, 14 Jan 2024 08:12:30 -0800 (PST)
Received: from [192.168.254.38] ([50.39.172.77])
        by smtp.gmail.com with ESMTPSA id qi17-20020a17090b275100b0028e245501e7sm3512998pjb.4.2024.01.14.08.12.29
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Sun, 14 Jan 2024 08:12:29 -0800 (PST)
Message-ID: <f7dff903-8614-4fc6-ba1c-93fa4788973d@gmail.com>
Date: Sun, 14 Jan 2024 08:12:26 -0800
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH v2] dhcp: fix overflow causing retries to stop
To: Denis Kenzior <denkenz@gmail.com>, ell@lists.linux.dev
References: <20240111133331.1423853-1-prestwoj@gmail.com>
 <55a3b50e-637b-4df1-960b-a4af96002e78@gmail.com>
Content-Language: en-US
From: James Prestwood <prestwoj@gmail.com>
In-Reply-To: <55a3b50e-637b-4df1-960b-a4af96002e78@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

Hi Denis,

On 1/12/24 9:11 AM, Denis Kenzior wrote:
> Hi James,
>
> On 1/11/24 07:33, James Prestwood wrote:
>> If DHCP is in a SELECTING/REQUESTING state and the number of attempts
>> reached a value where 2 << attempts overflowed an unsigned int the
>> next timeout would become zero, causing DHCP to never retry without
>> any event notification.
>>
>> Roughly 2 minutes has passed when we reach >5 attempts so it makes
>> little sense to retry indefinitely, at least without notifying the
>> upper layers (which could decided to retry themselves).
>
> Okay, but '5' is just a magic number in the code with no context. Lets 
> avoid that.
>
> Can we make this limit configurable?  Say between 3..30?  For iwd, 
> even 2 minutes might be too long.

I'm thinking it may be better to leave the default unlimited retries but 
add a configurable time limit versus retry limit. Setting based on 
retries isn't intuitive a) because 99% of people have no idea what the 
backoff algorithm is, and b) time limits are fuzzed so its not an exact 
amount of time.

I say this because if we want to include netconfig into IWD's Connect() 
DBus method return we kinda need a way to define a time limit as opposed 
to guessing how long 2-3 retries will actually take. We, potentially, 
could iterate through several BSS's and fail extending the time to 
connect, then start DHCP. We would need a way to limit netconfig to 
within the DBus method timeout (25 seconds IIRC), including how long all 
the connect attempts took prior. Maybe I'm overthinking it but 
theoretically we could hit the method timeout limit so we may want to 
add handling for it, which would be easier if we did the above with a 
timeout versus retries.

Thanks,

James

>
> Regards,
> -Denis
