Received: from mail-ot1-f46.google.com (mail-ot1-f46.google.com [209.85.210.46])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8B514158531
	for <ell@lists.linux.dev>; Wed, 28 Aug 2024 19:10:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.46
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1724872253; cv=none; b=GRdJMUtocdFh3S+TnuHOQNhx5jg8IKciACTyhVEdLQA8q5djuGIRU9To4iA1+KQs4RFiTdwt02tYoCfN4xWW/cirjZQnpOd2hKUp375JAxmYMuRHdvRrCZ+bteqz+jlR/kxHFEvDgmf+K1pVZqFeATxFXux292FNvlmAxFdSP6A=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1724872253; c=relaxed/simple;
	bh=cStxGnAJRJddFzkz5oQfupMy/7kSn73Aigod5ZtCHOA=;
	h=Message-ID:Date:MIME-Version:Subject:To:References:From:
	 In-Reply-To:Content-Type; b=HRklF6DUbf6JSEyoz3TckxliiiL+u/GLDckiDkVlt73n9KmTUli5q5TCQA+ZTT9Uu2BB/NbGAtVjwJ1UwrrHXviHfkaxzeLSyaB7HIamV23K+3+2OWKqYA7X3hHhBMc5U7nAl0ILC+niiW8mdZOe/zGVMy9/ViFUkHNhDw1YNMw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=fHVp4QPj; arc=none smtp.client-ip=209.85.210.46
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="fHVp4QPj"
Received: by mail-ot1-f46.google.com with SMTP id 46e09a7af769-70f5a9bf18bso254435a34.2
        for <ell@lists.linux.dev>; Wed, 28 Aug 2024 12:10:52 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1724872252; x=1725477052; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id:from
         :to:cc:subject:date:message-id:reply-to;
        bh=Oio3GD5HdwecA6t4UnIOvQXF1PnW+StbkJA0SjZvbsY=;
        b=fHVp4QPjHFVU5khblYaG1PuG0noYUsGTnJMMztC2i6jKiRuRnthufCPDPO+Ed4nlxN
         QCoSobl/oX8Pc0qL5pk8DCc7oTQMpaXp+xNkm9sVg/hHhYC8jm+kJTVPMh7pkAsB8Res
         fHwvUkT/bGgKDpEM6EETwnTLYBt5aaw/eO2qpvBTRbI2NrzjIfxSCan74ktP9N1ULhs4
         RdlndsND4qJbpFcAAbfl2twZyI5YlREvjU/W6lcL44w0Ug2Hab0wG+dYVgyblCuzOiyP
         9GBpd1HBCvJ6DgcTXyyCpvqHgbAGn+g3TxJLYFZwhs2rcli9DQ6az/4HQ+LM+BO/xa6f
         1aSw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1724872252; x=1725477052;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=Oio3GD5HdwecA6t4UnIOvQXF1PnW+StbkJA0SjZvbsY=;
        b=kdjGtTmHhmU80WTflSIZ7JCAhwWcBCNy0eJkwYtqeM+5FyVq1D3AHE12LYVW7OTGGx
         aI4N3juz1LP4hGhsGL+uwEAAUC98bixxBgPLPp2O/4PSqT2uiI2VCaF32tMYEsoasU+K
         2K/XPaPEJ00mz1D7pyycdY4oKHvgPZxdLsVLaIuvCFGy12rnkaSBucT3/GazDa9ORAXt
         td7hm2ur8yM3PMEBe719jZBNOlQ9yTLb6kTSg0gBB/G0Iwnx2Aes/jAA3XnLp2jUKmcQ
         MLXL0SXruLTZYU4qJU5tqJub8g3A5tR0xAIP90FgO2t/VdKhBHYx0EUcxNLIqIqJCIVX
         1I1g==
X-Forwarded-Encrypted: i=1; AJvYcCXK//5sz7Wgervu5oCGk2cnrvfJmgFYS1GdKFOU37bK07bl51m9AtQ9OG2aREnafz8N16c=@lists.linux.dev
X-Gm-Message-State: AOJu0YxTVMVxuUW9Cg6Il+1jqUQeTBgnxmi6wQPONUGbNYXCfNcofSlv
	k7dQxayVySwj45M2wqLt/vb87ao8BifzxtoqeOOz9Ige44JlZqCBKkGJWQ==
X-Google-Smtp-Source: AGHT+IEFuC+QI697iz+5eZkt8mRVQMp6rGM5Y4eSfaj5BmXTWMembi3JAUULNp9Ks+ix2OnGvTRhGA==
X-Received: by 2002:a05:6830:2702:b0:708:f1ad:c4bf with SMTP id 46e09a7af769-70f5c466ff0mr552596a34.27.1724872251571;
        Wed, 28 Aug 2024 12:10:51 -0700 (PDT)
Received: from [192.168.1.22] (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id 006d021491bc7-5dccc6cfa35sm2727885eaf.38.2024.08.28.12.10.50
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Wed, 28 Aug 2024 12:10:50 -0700 (PDT)
Message-ID: <d9d4662c-42ce-441b-a623-e2bdae4c5a3b@gmail.com>
Date: Wed, 28 Aug 2024 14:10:49 -0500
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH] timeout: add l_timeout_get_remaining
To: James Prestwood <prestwoj@gmail.com>, ell@lists.linux.dev
References: <20240828164341.875578-1-prestwoj@gmail.com>
Content-Language: en-US
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20240828164341.875578-1-prestwoj@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi James,

> +LIB_EXPORT bool l_timeout_get_remaining(struct l_timeout *timeout,
> +						uint64_t *remaining)

Lets call this l_timeout_remaining()

> +{
> +	struct itimerspec current;
> +
> +	if (unlikely(!timeout))
> +		return false;
> +
> +	if (timerfd_gettime(timeout->fd, &current) < 0)
> +		return false;
> +
> +	if (remaining)
> +		*remaining = current.it_value.tv_sec * L_USEC_PER_SEC +
> +				current.it_value.tv_nsec / L_NSEC_PER_USEC;

Can we use _time_from_timespec?  Or maybe add that to time-private.h?

> +
> +	return true;
> +}

Regards,
-Denis

