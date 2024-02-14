Received: from mail-oo1-f52.google.com (mail-oo1-f52.google.com [209.85.161.52])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F1BB35FDD5
	for <ell@lists.linux.dev>; Wed, 14 Feb 2024 16:18:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.161.52
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1707927530; cv=none; b=XsNMjD0j+RJbIHP/G6qYwvFuj+/clh21opBRPOdy9hzFC2C4wDHfMTblNyikR9SYA2HUhZpWwu//hCoWIGIQCT7HXbyGjIQvw3Bx6ZZS4zVx+J0yNeRJ/GUZGxXZFuFL21YSTDW1lKJNFqoAbMnRVDgxaxgac3Vrs1+DE46nmnA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1707927530; c=relaxed/simple;
	bh=6QjA6/KqHugxg43wabZrAn5gIyfRuBn8z4wQp+P3yNo=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=Z+/eDw4aJDOkXVMtxXVyPIkBLZtN7Fi+TePb7+k508iu39zG1jHEA6re9NwwXeexzO+xf2dT/nIehorEUzzZu6mnmHobv9xMxrq+R6F7brw317rXb+EjKvqslYLLP5H3gE8Nb2sMGVu/nDaS9B0ris0ddap2w4ZzTvyl6Pp2Puk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=bQ1tOboO; arc=none smtp.client-ip=209.85.161.52
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="bQ1tOboO"
Received: by mail-oo1-f52.google.com with SMTP id 006d021491bc7-5986d902ae6so3041807eaf.3
        for <ell@lists.linux.dev>; Wed, 14 Feb 2024 08:18:48 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1707927528; x=1708532328; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:references:cc:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :from:to:cc:subject:date:message-id:reply-to;
        bh=g/lnDb0MMfMwFkfUw88h5Sx/XFez2Z2KOeYTE5GfBqA=;
        b=bQ1tOboOKmw5nV05nTO0E+R0XX7a2o4gBxzgXF74+lIrpGUTf0bicEvJg097SdLkPF
         lsEv9SpmHTjd5GD7f/ivE2x5MiUpmN1QDdZo2vT5NJkHfuNnG4XJtLaD2uzdSt82nzAv
         mpNB1Gfq9h8fIsR0ah3Vid3tKopQSm6Khve1MXGvCKGzmS+3YGvLDvPBneB5BxUTHVyo
         clrBXQkn2AjzLKpBIeCzVgRLrZvnpkAiDESJjEquwVeIZJZJ5+A5qst/nThjcW3o8d5p
         D8wZN65v/UAhBpG5dngyz3dKOl9vzwuzhfNC8enRPx5+zKB2gwnM57xslw6XPtX8O69H
         eN6g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1707927528; x=1708532328;
        h=content-transfer-encoding:in-reply-to:from:references:cc:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=g/lnDb0MMfMwFkfUw88h5Sx/XFez2Z2KOeYTE5GfBqA=;
        b=aVIJlLG8/3eWwII6Ly+9ti+5C1CWApaa4Nv+dys2nBaMtCUVHZ3qnyLnWcMNjKl4KI
         c6iUnH/R4Qd/C8Ha9XLlKVXAwx4p199IHs0TaYi4ypIiDcL0oVYdyu9VP8qGEdQ6/JG4
         7hXu+Zxo4rBKFkW378gjzUB9e7TjeubuytD+9P1wZg+ol21Q2VRMmLXvfzD142LrKsEp
         ye06O9tJsSG9JkoAwG2Y2q9V9c5kDroJx13bV+f346aHEZXPOJEn0NowJ1lPuucq2g0m
         56LL+PVEYM2e9BOvmeI3jC6p6G/uK/xEQMby7tOb4L2/+KKUogn4HEFX6mezvRDmcVJ+
         iyHg==
X-Gm-Message-State: AOJu0YxYy8yXktgEcbIe+XxoFPMi7tSuu+ga/sQkTFYihkx2OzExpL5H
	TEpzwZD4elajT3l5WbK1oi/5lg9BsxAlM9dFhCZrkQIudVjzS5NL
X-Google-Smtp-Source: AGHT+IH8WXUZn6EIPXQiqKGc6dqwquf5TEGC9KxwdYFZzYHKZ7CFakv+qqpdNVY37EI2EF+wn4c43Q==
X-Received: by 2002:a4a:9d16:0:b0:59f:74ce:6a5c with SMTP id w22-20020a4a9d16000000b0059f74ce6a5cmr1027705ooj.8.1707927527078;
        Wed, 14 Feb 2024 08:18:47 -0800 (PST)
X-Forwarded-Encrypted: i=1; AJvYcCWIQlqFZWQa3cwZabBl62GR2bqobgnmIiZSAppqNjyjI2Aw1bmKQ7R8kSNt3naLf226SESGTCcey9ndYCoUyw1NWWQ=
Received: from [172.16.49.130] (070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id g25-20020a4a2519000000b0059a826dcf53sm869240ooa.40.2024.02.14.08.18.46
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Wed, 14 Feb 2024 08:18:46 -0800 (PST)
Message-ID: <da1ddff5-80c7-46a4-9187-6cd8d5b2854b@gmail.com>
Date: Wed, 14 Feb 2024 10:18:45 -0600
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH] log: add l_notice
Content-Language: en-US
To: Marcel Holtmann <marcel@holtmann.org>,
 James Prestwood <prestwoj@gmail.com>
Cc: ell@lists.linux.dev
References: <20240213131619.828613-1-prestwoj@gmail.com>
 <0D7EFC7E-C3D9-43E0-823E-6C06498C6B3D@holtmann.org>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <0D7EFC7E-C3D9-43E0-823E-6C06498C6B3D@holtmann.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi Marcel,

>> #define L_LOG_WARNING 4
>> +#define L_LOG_NOTICE 5
>> #define L_LOG_INFO 6
>> #define L_LOG_DEBUG 7
> 
> for what? What is the difference to just use l_info?

Per conversation on Slack, James wants to categorize certain messages for easier 
searching.  Since NOTICE level exists, I suggested it would fit the usecase.

Regards,
-Denis
