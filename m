Received: from mail-oa1-f51.google.com (mail-oa1-f51.google.com [209.85.160.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5302D5F49A
	for <ell@lists.linux.dev>; Thu,  1 Feb 2024 16:07:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.160.51
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1706803636; cv=none; b=YtqmyJpj8noRtlD5vOxrhk8+iepgadmp/DIIpa4QCN9mYXOrtgizm5I5Y0kfWMNMMLcLeGXc2AKq7Q8O1waEAIhqFijnIPKHcxDb02VkjhVbEfqU94bnukT9gwxBghAwCHoJfm17+XptWpMU2s+VHPJp8s4gYZMAuh5oMoh2RFo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1706803636; c=relaxed/simple;
	bh=Eeck0DF93CQ8n7BN8gQ0uUvqDdFIlF1l12MSMHRBFxw=;
	h=Message-ID:Date:MIME-Version:Subject:To:References:From:
	 In-Reply-To:Content-Type; b=bdDUGH3fbp22o9zNA09ADn5oY8ZMC93o1XhIhmf5Iic/BxEvB+Qz6KVOh/tV4rPJT7NcYdtZaLh6Ax0sMwqPH6Fj7ydLY2y/eBadD9aQ2alXuz2wjDowRf+/cDm2oWvb4gZOgI2OdzG+pzEHEOMKdqhViiThuCw/emqtgyQ3VFw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=bX3oDs9d; arc=none smtp.client-ip=209.85.160.51
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="bX3oDs9d"
Received: by mail-oa1-f51.google.com with SMTP id 586e51a60fabf-218dcbd1584so688137fac.2
        for <ell@lists.linux.dev>; Thu, 01 Feb 2024 08:07:15 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1706803634; x=1707408434; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :from:to:cc:subject:date:message-id:reply-to;
        bh=QDIMmXh7PbqylYx3ymlu2mDZPATwuNW4WbheSgB5XcQ=;
        b=bX3oDs9dSKliMzHma17jg8ztY52P1HtfKSAj/9IglOWVlTguBJj3QX+ABPHrL9cpWn
         zfoGoibnvAgZACLmER3lnWRWwQWEsv9gysp4vX9xsN27u2WISqFogv2wnQK8Umxp4NQG
         c3i7HHm9gF09VQzjL6GH7NxKvBlsaDNrXultNG/UbkNBKAKvZ2NFdsEj72VFC9dC/627
         HluC4mt4bR7nl5lILWrPm0NmK7x85bz+aCtzYGx6h8FjI0pTE6Icam05H4xX3ONCV8Nf
         oibXW2Gk1binwd65qN9F1Xc2oE9pfSCW4im1U37sa8iA1KsA9ZBpFLwracFpBMDsZzth
         RqkQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1706803634; x=1707408434;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=QDIMmXh7PbqylYx3ymlu2mDZPATwuNW4WbheSgB5XcQ=;
        b=bfQHcTyyEVhEkSYbYI89iC66ZiKDQVRbDOpVR0nig51+5DgRD7RZWMHXPPQsj38yec
         SNoTdZavQBzjbz2tbSeW2lqY1aHLfLfoeYaaE/hQl3yn0WVc1sOiGv1EBGWqBir4fPRA
         78kZcXK8I0K1rLu7ZpNdmuQ/qHeAeIKowfwl4HsOoCTiU563NKqsGeeIcQ64GRukcLvT
         OKVfCZB5LVfl1AGKFwLeMjFEnp30jtCVu8P2PahM2+I1E0aPWahoihUby2ohlgxTHT/V
         OKZShz/o3ocB1eOqx3SikW0wlKIkH0z0uGi94JPA6ENsgg5Va+lERv5HlCvXyyWDmFo8
         7Pmw==
X-Gm-Message-State: AOJu0YzeUn1skbmWzDTDkH8DXVeyLWsFSuaNLLmcXhd98vXfEE0vgXk6
	Q1BSnq9Y3i0OtVPtpWXMZ04Wouy/RVdvR+0kD0OLqS4Mu798yGdrprcUuqCT
X-Google-Smtp-Source: AGHT+IFfPBE/pJFeHIeh9YoTh9MLoyhmVHHp6IlHCP1xO2/ZjYiBnQuuGUGFZ3txAzAzFYSyAqNQ3g==
X-Received: by 2002:a05:6870:6c0a:b0:206:85a2:643b with SMTP id na10-20020a0568706c0a00b0020685a2643bmr6202513oab.35.1706803634223;
        Thu, 01 Feb 2024 08:07:14 -0800 (PST)
Received: from [172.16.49.130] (070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id pv16-20020a0568709d9000b00214ccbdc81fsm7690oab.21.2024.02.01.08.07.13
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Thu, 01 Feb 2024 08:07:14 -0800 (PST)
Message-ID: <be187371-208c-4b0a-b564-2edcf104f24c@gmail.com>
Date: Thu, 1 Feb 2024 10:07:13 -0600
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH 1/2] useful: Move close cleanup into ell/util.h
Content-Language: en-US
To: ell@lists.linux.dev
References: <20240201151751.880279-1-denkenz@gmail.com>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20240201151751.880279-1-denkenz@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

On 2/1/24 09:17, Denis Kenzior wrote:
> ---
>   ell/useful.h | 14 --------------
>   ell/util.h   | 11 +++++++++++
>   2 files changed, 11 insertions(+), 14 deletions(-)
> 

Both applied.


