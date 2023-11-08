Received: from mail-oi1-f179.google.com (mail-oi1-f179.google.com [209.85.167.179])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9504138DE3
	for <ell@lists.linux.dev>; Wed,  8 Nov 2023 23:56:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Nwt7RoXM"
Received: by mail-oi1-f179.google.com with SMTP id 5614622812f47-3b6ad461599so170307b6e.1
        for <ell@lists.linux.dev>; Wed, 08 Nov 2023 15:56:52 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1699487811; x=1700092611; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:references:cc:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :from:to:cc:subject:date:message-id:reply-to;
        bh=Q0WGSTAA8tzzHowPUfV7t37PdrYJ9Nkh2gQF+IX5G6I=;
        b=Nwt7RoXMiI4yj4+GRbYs6xse18mnzlJARsNLKqj13gpwctWinTJUzaio9NJyoLPQMH
         C7l767kTng0X3yJMz7W4QWWT/bboXKvfPg6SzreOyEDEz1rOCrNzj6w9bquIOL0kvUBb
         y90hQmvpS3tyiG69vwAfvcb20DL0+2qqG9Eg/EhTYLHUEuDqXyg49e3zv92vfOUMwv6u
         2MTB9zf9DNxvrz7RMlwr5uY0+aUvHJaotIPh8WJ1bm8hxldqxsxcrouQFvGQaK74f65Z
         Q4VU08rbem/M6P8eojZeoOipU/JJOxNARhwjdY0gbB2Enj1on137KZxVT5v4PDP0CEdv
         HH3A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1699487811; x=1700092611;
        h=content-transfer-encoding:in-reply-to:from:references:cc:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=Q0WGSTAA8tzzHowPUfV7t37PdrYJ9Nkh2gQF+IX5G6I=;
        b=sz5T2zn1DLl6S7nD6GypQPe9Xw3pibqXncm5ZZUFWs0kfB9zfJvgRB/gUvtrrCowRI
         rjL8TZNsmnsNuc3t4hlS+9z84H6ZsKO5f0gvhboiXgOXqWdrDtHU+l/fWZKdSSc6a5+V
         hF4137Fm2FevFquvPKbVvrgL2AR45JtIn9NRxjc1/T7uVcWtJ4KHX67bXceWfNwJA46j
         tVCnGiGGByhdpX1FtQCmO2rT9JqboyZXJK3tU2+pF3oxYdT4j7weBJpqJKAdommQ/T+Z
         N4PspEnRfH/qwxs76KGIAqY5kZIlLJlsPC/3S79KqEkYl83AFiuIxlR/5/xpCwo+c7A9
         BBDA==
X-Gm-Message-State: AOJu0YxCKo5heQtCaXNq9uPojR2FyewbamBAn3AtOYpvqTVFk7Kp1NUW
	J7sfR0X0HbvNgNK30sKu+mh8fkj9588=
X-Google-Smtp-Source: AGHT+IGFJlOvwcAhOsht4CbFwSycb56aDr4GCipPJsGbe8/YXvf6s9mjNzWn0Yg0gvMtWb2H7wtuKQ==
X-Received: by 2002:a05:6808:1992:b0:3b5:6533:d2cb with SMTP id bj18-20020a056808199200b003b56533d2cbmr112945oib.46.1699487811573;
        Wed, 08 Nov 2023 15:56:51 -0800 (PST)
Received: from [172.16.49.130] (cpe-70-114-247-242.austin.res.rr.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id m25-20020a05680806d900b003b2f2724c48sm2046771oih.11.2023.11.08.15.56.50
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Wed, 08 Nov 2023 15:56:50 -0800 (PST)
Message-ID: <2b9a12a2-87a9-4e10-b24d-77268369d01d@gmail.com>
Date: Wed, 8 Nov 2023 17:56:48 -0600
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: ELL 0.59 Does Not Compile against Linux-4.9.212 and/or GLibC-2.28
Content-Language: en-US
To: Grant Erickson <gerickson@nuovations.com>, ell@lists.linux.dev
Cc: Marcel Holtmann <marcel@holtmann.org>
References: <EE577BA9-358B-44E1-BC6E-810EBFA4998F@nuovations.com>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <EE577BA9-358B-44E1-BC6E-810EBFA4998F@nuovations.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi Grant,

On 11/8/23 15:21, Grant Erickson wrote:
> ELL Community:
> 
> Over on the connman mailing list, Marcel and Denis have been advocating, rightly so, for iwd over wpa_supplicant for Wi-Fi.
> 
> Is there a kernel version expectation of ELL?
> 

For the most part, no.  It should work with pretty old kernels.  But most of our 
development started post 4.15 or so.  If you need iwd to work with EAP, then 
4.19 is required.  Otherwise, older kernels should work fine.

> For the current project I am engaged on, the kernel is locked at linux-4.9.212, glibc-2.28, and GCC 8.2. With that combination, I have found that the absolutely latest version of ELL I can build is 0.28. Regrettably, iwd requires a more recent version than that. However, neither the version of ELL that iwd embeds nor the latest independent version of ELL, 0.59 compile against the aforementioned combination. I see the following errors:

Try the 4 patches I sent out.  Depending on your openssl version, you might see 
some weirdness there.  The detection logic seems to not work on _really_ old 
openssl versions.

Regards,
-Denis
