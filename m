Received: from mail-oi1-f177.google.com (mail-oi1-f177.google.com [209.85.167.177])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 06077611B
	for <ell@lists.linux.dev>; Tue,  9 Jan 2024 04:27:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="J+47Gvl7"
Received: by mail-oi1-f177.google.com with SMTP id 5614622812f47-3bc4f49a3b6so3025113b6e.1
        for <ell@lists.linux.dev>; Mon, 08 Jan 2024 20:27:57 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1704774477; x=1705379277; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :from:to:cc:subject:date:message-id:reply-to;
        bh=QLqsBahbFR18hsMjIk+8yN8hETm36IGzvIxw5VT7V6E=;
        b=J+47Gvl76SIadkt0h2Y3BwDHLEkW055NS0TwTlK8ynpVfcb2ux2+xiwtrTDfiZSTEs
         kwQsNm5HU93cPjtxo2rgz+a1/EJm8HseCn8FCrbrBIaCy0YevWaed1pUi+tLQNIaPWUa
         dUW723BARXmojXzHSpzmmz9SUArLIczBaWITvLqQwLcwhahezhERa8KatIi5xTd9EJeb
         qrp8vu8GBpYZNuztxWgSJDpwtWuX93X4AfkerurF6/MGZEijiQqgvkXhbQCn/0i2kqM6
         UixY4ayP9SE/mTINzHPTi1zOCVHYxoCar04ySXMOJjoMNtisLYFASiAggx23Pg+xsgSe
         xdxQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1704774477; x=1705379277;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=QLqsBahbFR18hsMjIk+8yN8hETm36IGzvIxw5VT7V6E=;
        b=A7OMS6owAu8es0QDItkFHhXSrmBtkjzEWwBr301fT1L91ZeNFUuXo+NQAJqRK9hdAY
         2wqqYolrfzFomoHSlS4TDNmdLjePqey78sI7yPyPfeXwwGbYYeK7/7B8FCNyVz/3BW4n
         UR1bFkpifhptDQlKNj1hvgI+hkBQ5M4OaLRpC7uRpSN5AsycMx1676gxrvVNARIacQ1r
         0vgONUPbMSElLNxWGQ9iSEask8rjXezLV+MT5PvZIDdPBBLKP32goXF+p/xzcKAz0X2i
         rx+ryJtNIReGr7ffidcqkn0ErEjCSURoVDK2Dh9n99SVVq0hFiVBPo/rcRvZeaSUqJy2
         bo7w==
X-Gm-Message-State: AOJu0Yyu0tPpDDfO0re+qcc1LLk1sJ4rrMWQO3xR4U7fSm8js0SGogfY
	eGmdcWsj/ZtiUyTC+sEfx8I=
X-Google-Smtp-Source: AGHT+IE8igeQsHb+NBj5wS3Ii0kNWNkEsqA3GW4ixNenI4MARTHAp3rxyFT2GLxifXc65q3kmQfmgg==
X-Received: by 2002:a05:6808:171a:b0:3bc:3699:3634 with SMTP id bc26-20020a056808171a00b003bc36993634mr6334855oib.13.1704774476989;
        Mon, 08 Jan 2024 20:27:56 -0800 (PST)
Received: from [172.16.49.130] (070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id 20-20020aca0f14000000b003bd3c3de58esm105863oip.47.2024.01.08.20.27.56
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Mon, 08 Jan 2024 20:27:56 -0800 (PST)
Message-ID: <894bfef2-52fd-4f99-b257-1e637388a375@gmail.com>
Date: Mon, 8 Jan 2024 22:27:55 -0600
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
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20240109040621.1248647-1-prestwoj@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi James,

On 1/8/24 22:06, James Prestwood wrote:
> If DHCP is in a SELECTING/REQUESTING state and the number of attempts
> reached a value where 2 << attempts overflowed an unsigned int the
> next timeout would become zero, causing DHCP to never retry.
> 
> Since 5 attempts results in a value of 64 we can instead just limit
> the attempts to 5, and set next_timeout to 64 after that as the spec
> requires.

Overflowing next_timeout implies that discovery is taking ~25 minutes?  I think 
I'd rather we gave up and sent a NO_LEASE event after retries hits a certain max 
number?

Regards,
-Denis
