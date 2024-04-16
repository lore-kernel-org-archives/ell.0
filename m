Received: from mail-oo1-f45.google.com (mail-oo1-f45.google.com [209.85.161.45])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F2D3013848E
	for <ell@lists.linux.dev>; Tue, 16 Apr 2024 19:07:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.161.45
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1713294446; cv=none; b=N1Qrq0Dt4VeqnVeJeBN7D/KVHTMzuV6PFJTzrLL4L7xIoysPdP0RVP03XhMJgvhSuKXSdEr4R2DtFvYKDrS81S/aYv+JR29Yrwc7vmCJXYuTzjXkCducE9psa6YHlMQYIUW3+LcIrBnXLU6b71Lp7x6d/yP6htXZroJqZVwr0DU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1713294446; c=relaxed/simple;
	bh=c11unVBFutOkKNaEKVuB8McSOJn91hFKMOqalQLoYYw=;
	h=Message-ID:Date:MIME-Version:Subject:To:References:From:
	 In-Reply-To:Content-Type; b=Nf498EGUOJpodkPp/XPDFHMXTWGCbeCVBE7y+pQWQBJMzCuJVLs3TkJ84CFDIp2AFZ15WH45Y6URA7JfxOVbu0nl1XkoHsk63Kl1sz0e2TcRKQBoUUY2JLcUACzYiUAfUN0tth6y1CLj/Ns3qVxqeXWLWhWASwjIlesFkFbKZxQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=Ou9kXNMO; arc=none smtp.client-ip=209.85.161.45
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Ou9kXNMO"
Received: by mail-oo1-f45.google.com with SMTP id 006d021491bc7-5acc9e07664so739093eaf.1
        for <ell@lists.linux.dev>; Tue, 16 Apr 2024 12:07:24 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1713294444; x=1713899244; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :from:to:cc:subject:date:message-id:reply-to;
        bh=yoToXJrwj5ZLQnQ1koovb2kno80MM5f0tN6prg3A778=;
        b=Ou9kXNMO4/SWXihNcyi0ysisl0i5b38gCA2x03FK4P/Xoe7+3O0+RuH/1AHr04Sc8I
         kziKwPCG1FfUTcDiUAjeDmEC5z+vW+9/xcr0Fe+DgqwLxa3VkSj6A3Z9W1tHpQVlukpA
         DAtHa7aKPAb8vn4gm6PfB8HECcomJwwKbSCJqajC8Qp9sDoQD7IXQ0g2KfKbXi8r30Qd
         C5Hv98Ihlgxv81JcA7lX5870VOUD4X7Vflw6Jjitu2nvn9zR9E+ScMniGphfkzGMst06
         KQrzVMxTd5Q8UXRixSGFHAmy7ADRWP+Pn6/SsDgS6ZVFCAB+foRTwRXtdj4pStA7prWe
         4HGw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1713294444; x=1713899244;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=yoToXJrwj5ZLQnQ1koovb2kno80MM5f0tN6prg3A778=;
        b=te9PNV99LATPGl2fqWonec7KThLS3+vxJSsNPwknX13LYBy5vgqrk/zDxROFo+Ujjn
         Lh50EIiBZJXVR0Uv67GPHllRWkRElANVENEG59GdmLQqTtPi3X3OfjpYkkUaI4duuTaN
         jquw5p4qygX3i1QX3CjJQFRvQVY4248CPOZrT4Laa4UR+rN9dXawtvKhjkk8iTKeN6cx
         p5vL02LwBqz34gOhoL/ej2va4L6bv5G/+UDqfHPcr9m5FxYEetbvoT0iSW71F6OMDi1H
         jxYQfEH34Qr4fHGmmgJAkVpPEAH2Rcy9MzdwvrtguvM8Ho6twwTQf8NBNE5iOMigxrWC
         31wQ==
X-Gm-Message-State: AOJu0YyzwLlAg4gpl7slk07yDyvZUWRiORRQDN0ZwbAfjF2PUbVhCjZm
	bFN6BFpzxdnK+yH966txMo48gtjgSsNzrK1EXC8zPE8hVpWafcF2xnxgnA==
X-Google-Smtp-Source: AGHT+IHzaRcs2aizr6eDXAteeyLjsA7eMZI2GQJCbeewi88cwM4HdvYM39qittusLKKkAT0XqBwV7Q==
X-Received: by 2002:a05:6820:209:b0:5aa:5206:30aa with SMTP id bw9-20020a056820020900b005aa520630aamr15156067oob.7.1713294443862;
        Tue, 16 Apr 2024 12:07:23 -0700 (PDT)
Received: from [192.168.1.22] ([70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id v10-20020a4a314a000000b005a9cc037b79sm2757052oog.43.2024.04.16.12.07.23
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Tue, 16 Apr 2024 12:07:23 -0700 (PDT)
Message-ID: <ed309815-edb1-4c7d-b7b1-b04980522be2@gmail.com>
Date: Tue, 16 Apr 2024 14:07:22 -0500
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH v2 1/4] util: Remove confusing static keyword use
Content-Language: en-US
To: ell@lists.linux.dev
References: <20240416142458.3353383-1-denkenz@gmail.com>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20240416142458.3353383-1-denkenz@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

On 4/16/24 09:24, Denis Kenzior wrote:
> '__n' is declared as static const which is confusing since it
> would imply that __n is only initialized once.  This works out in the
> end since the macro used in a separate anonymous block, but some compilers
> (i.e. clang) will generate a symbol table entry for '__n'.  This is not
> needed since the expression is always constant.
> 
> Declare '__n' as a const size_t instead since that is the type produced
> by the sizeof() operation used by L_ARRAY_SIZE.
> 
> While here, also declare '__i' as size_t to match '__n'.
> 
> Fixes: 4a9f6388dd7f ("util: Add L_IN_SET macros")
> ---
>   ell/util.h | 4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
> 

Applied.


