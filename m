Received: from mail-ot1-f53.google.com (mail-ot1-f53.google.com [209.85.210.53])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3350A29A0
	for <ell@lists.linux.dev>; Sun,  5 Jan 2025 02:12:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.53
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1736043158; cv=none; b=g1GGyk7c+4rIIidmx8QLUjFbHgke+67GNXSrlVPATBSi1EO9BaBKpyiK/2db8M6k8Mpmn7oU/JIS4zmR0o6gDSNpUPYlOuINH8XxBb4IfrdKVMN5T3e+E0NPMcamEUjHm3jrj8hMgvPtMv6VssOaRnXa9qbq5lnjceZAAaibvcw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1736043158; c=relaxed/simple;
	bh=Z9Bs+vLFDjpMNdc3qrCp7GrwScsKadem+3PBzzoqqeE=;
	h=Message-ID:Date:MIME-Version:Subject:To:References:From:
	 In-Reply-To:Content-Type; b=d0UFKI7mP1R4RQKf7BYbFI5vlQkkLE6eidQ6zpV9/SeuLrE914Ncv15CVl7aWNzIHZ0RPDiyijI5F74KTLlH5Rj9K794i+uUXDiBMhMFI6PCyMzCaMcMK00s6CFe5GiqV2nEmKRmLNFczZ8CtrrV3tnkmDCRfEXJ3JxS3lQVPh8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=k4R31+Zc; arc=none smtp.client-ip=209.85.210.53
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="k4R31+Zc"
Received: by mail-ot1-f53.google.com with SMTP id 46e09a7af769-71ddc7325beso813313a34.3
        for <ell@lists.linux.dev>; Sat, 04 Jan 2025 18:12:36 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1736043156; x=1736647956; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id:from
         :to:cc:subject:date:message-id:reply-to;
        bh=pYxSPvNtK+awI4BQrgvySu7wWkE6+1cRFJhx1zMXsx4=;
        b=k4R31+ZcMlXBbK2BQd4SjMTP4SwzcLxojXHeCmd75PZ5E/RUAE7hAN/p9yDJxUJ+nl
         78yxmjch4W3Or2nrw1wJwOscMFi63f2vGOSykZg2/LtaPbJZ42PnPpHszFw6Q+NI95H6
         A1IyexxqhJ6n3eHTKhTqhG7S9X2j43W2QaVzQXVZkK2u/ZXfQIAgO9ugdmL7liGFXITt
         He+gShwsya9yj5GvXNU8+myPY4GaWTvr594lQK+EWeDNz8lHIEs8ekhjbs9c3NBfdpCv
         9sh6E7dU4GByYexAgSV1Vh38e/8Uv4mzVZM7Aa7jhWKFibN10WFxmNqWdp3srL7SQwCM
         HDCA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1736043156; x=1736647956;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=pYxSPvNtK+awI4BQrgvySu7wWkE6+1cRFJhx1zMXsx4=;
        b=YLf33S6cBXuhRdQaWqldX/Fun//4mBVNBFu55q6z1T60O7NoF8VbblSU2cfJJieFXy
         9EEqc3pfXzwTYifsnh/2Zvu2YnEAeokPvMZSnRQTniDejeyAcBxGXHUICE5WvndczTIF
         jgscFdF8UsxUnNxrLjj6ADVM3s8zxendY0zSAaoMQQDLkdWoFzOXVg8CIsw8PLAtP7qS
         e8vKX4hS6CdJrgrsVv6i8WMipXHa9cRVnTww67EPmPVa8rEAU7ogJNLkuRm7AIGBN1Ro
         HjKtAoZxoV2xczXwH4bhUF5wR/fCK9pIaIZYEyhx21B0E0aEf52+WIUmXJJwSp4PV0gk
         TztA==
X-Forwarded-Encrypted: i=1; AJvYcCXXy0e0ry1aXzFbZSD78gvHLt2ZdMZOsVakFz2W1YdGwDOc7zPR1JP6+SnoM99A4sRwMWk=@lists.linux.dev
X-Gm-Message-State: AOJu0Yymx0EXzWpaF6ykDToi4dMORtwkQtw5Gpv807dWpVz2AEPfFv8j
	LqoLg19CfJEm2Epg3dZacHSka3EPMQcAJFgU0zYoXR2KZ+G72dMlZBakdw==
X-Gm-Gg: ASbGncvkEGDYWxCJsayl/LpatWaPGNaMbYpMsNgmiW76Ol8BvykTjy1aidysPLyrQBu
	0P3WGiRzTDE2ptRe+NOV7rdqKNoTGgQpfLdci9KNCANA4kLLBMJH8JMJF5NNp5wcm/m44khC60Z
	R5G2LUyrC27MWrGRsEfaviAFWbzgydIV9CQrkWbT4vk4H4pJbItAFot51IvWPaAubjQ0rntn/BL
	MPhbUMMOuQwHmIsiHyjEJsviMt2gf1KV8q9Rpp0Usneeyc58q0zH9fIB6ufhqBrqbNvg8ZCUMSW
	QJR5kZtOhGND+qQ3msvTLg==
X-Google-Smtp-Source: AGHT+IGLYnyN6U9BigCEdm+FgLvSFi+8GuEcXO5Mv1+A1zISt/1+S/eoFii96DM1BJDtO8pXFhkHSg==
X-Received: by 2002:a05:6830:2656:b0:71d:f239:c0a7 with SMTP id 46e09a7af769-720ff8b038amr36347771a34.19.1736043156076;
        Sat, 04 Jan 2025 18:12:36 -0800 (PST)
Received: from [192.168.1.25] (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id 46e09a7af769-71fc99d116fsm9025697a34.64.2025.01.04.18.12.35
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Sat, 04 Jan 2025 18:12:35 -0800 (PST)
Message-ID: <832d1760-bd6d-47b0-b48b-8756264aa615@gmail.com>
Date: Sat, 4 Jan 2025 20:12:34 -0600
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH] dbus: fix use of `va_arg` with incorrect type
To: Artem Sinkevich <artsin666@gmail.com>, ell@lists.linux.dev
References: <20241227185530.99708-1-artsin666@gmail.com>
Content-Language: en-US
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20241227185530.99708-1-artsin666@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi Artem,

On 12/27/24 12:55 PM, Artem Sinkevich wrote:
> `rule_len` is computed by iterating over `enum l_dbus_match_type`
> (32-bit wide) variadic arguments, but the function also takes
> `const char *` (usually 64-bit wide) arguments. Count the arguments
> in the same way as they are used below to fix undefined behavior.
> ---
>   ell/dbus.c | 8 +++++++-
>   1 file changed, 7 insertions(+), 1 deletion(-)
> 

Applied, thanks!

Regards,
-Denis
