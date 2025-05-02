Received: from mail-oi1-f171.google.com (mail-oi1-f171.google.com [209.85.167.171])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B527A15A848
	for <ell@lists.linux.dev>; Fri,  2 May 2025 14:07:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.171
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1746194842; cv=none; b=pta3WzmhzdWH5+sa2c5DtKvxCrkaUI1hCrH8V3EHTFc8CFZf5hbzdbNBmrM7wHMSNghb0WDsB80ZnBI9ubqMvqGbVojUQme3Ekf/yuOfjtoLDWO7X6w+ykrYKsglhxMJufUsULn1lBFDvYAZWDC8chE/FuhxrOKMr3TWWMLP8/8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1746194842; c=relaxed/simple;
	bh=OpXU+Sj2CfHz3UBFhUizqdPkyrbZdJAZWH0deTWzux0=;
	h=Message-ID:Date:MIME-Version:Subject:To:References:From:
	 In-Reply-To:Content-Type; b=MulM+g5E16oZQ1lYofUFSQNiklYtmupod6lvr4aPD11444qbyd59UholbO9H0zGDGHgsmNG5aBauvTQHG01K7X/3pjXNvvpN2+b77Elw/3ffzEJbroSFB9fNpBfLWvJuqKBux6j03KjOOLu9458WI7pYGPwifZo2qLtX8gBpipo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=Ko50TWbq; arc=none smtp.client-ip=209.85.167.171
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Ko50TWbq"
Received: by mail-oi1-f171.google.com with SMTP id 5614622812f47-401e77e5443so1332764b6e.3
        for <ell@lists.linux.dev>; Fri, 02 May 2025 07:07:20 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1746194839; x=1746799639; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id:from
         :to:cc:subject:date:message-id:reply-to;
        bh=5HK0mSWiNehHlE1SNlaX4a7TwwakEkChgjtnZnxuvYw=;
        b=Ko50TWbqKebmxGykTp7KFxIobOOgR8gKGoo3D19OaGkO49RZvhLeQE4Jiz/vrv/SHz
         z9Pn7y6qNh2CfTp8DhZLSO32d9TbZXu2CrF5tIKbEkMh8aaTq9CtGgjuh0qgS4QpjTYY
         4ZNCgMM0f9tlWHlE5A1AD3Y5O0jDa+roBlY9FCIOuaOOAzouDMK6q6N5QkJqwjNoHDpn
         RbkdMFyqyt0mF5ypkhPQThQnv6BCoypmE4zeEEkwIIf0DhpGfywInO8teHjofB9sSPMQ
         a0nnKiJFWQ+EkLelTq5WWe3UNdoL2z5DWNXSe58RpYhc44VSdqdq85+xah+CkFe80YeL
         VGLg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1746194839; x=1746799639;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=5HK0mSWiNehHlE1SNlaX4a7TwwakEkChgjtnZnxuvYw=;
        b=p3xeWbSM9llJOyd7ZPPqUb8VVUIzqvpdOVljHCMfkozR1dxoNNXdcCyw5W0kJYPgHQ
         +I81qUMWfBuH0WlRvjAya4jAuF6L4mZ4CuRz9p8hSagYZDB5YceNRmfvG20uvmvXyIIk
         Og7Zjj8e+Rlb6TycSw9kINtRE2+zgEnoa0qP1nFQBsDZrsLJluojkYYN4nk4DKOIuNer
         lp7Re1MHvHXp+iN07iczIEDDtyhO3lxDzdJY8vCCrUyt+HJAjla5RgPvo9wt8g9XiZDV
         7iri2ChTN0GC0lyHK51kUrOoYRSRQNAJg55gR1R3ISCMV0iFls08vrmnpcOH+qShUXTU
         jHWQ==
X-Forwarded-Encrypted: i=1; AJvYcCVucj1QlKUHWsIQA3EZj2hvzMIlZSDPE9D5yfYMLwrzXivqM2Ys9XUCH4u2tVZM0RIylm4=@lists.linux.dev
X-Gm-Message-State: AOJu0YyTgSZHMOVp8DRrubhWKDLDCeeDJyTNEKTNmjzDJiR9WBaWkttX
	Ce2Mqo3VvzMn3xj+200oFXBk6LuXScp7bYcbDy04VUxUBWeBSMKHrDDK/Q==
X-Gm-Gg: ASbGncsUxQXm1vgJkkZHqunEeewsgo/d4BlxrFr/G5mHtYWf3xvp54neZqnlxere3bg
	dvtJRLyHPSMmzzJ9bTS+vBtg/hfqFnklahwnMEvfr9iJwGbhhnk95M7VCHwpJRlhSbysbmVNKNI
	JGjPZWbXWq7d3YS3bDqkTBP9rgIBJWhaKltxg6jEArmn8QAqJhO8/TERfrb3KyLTqBt5bABYCYZ
	JPAcOKAQty6t4NxV94bQapCcUsS/fcrZNZn4sNaOVdm/tj5wlvJfIfAWci+PgkiEeTeXf2sUnsw
	A4oJj+JAaqxrBhTics1IZSzN6HDIG8xFwgt6RhGaE6eG4mYzm20+WpjJlvvmRbHtGBp/ZJOtofp
	W5/vXyQ==
X-Google-Smtp-Source: AGHT+IF+I911NpxRvgsacqrWN0/CoG34ge4iC/5KEvsVCDfIa2ZsIVVWsMmVmaMy4N5h1GXAwJMTFQ==
X-Received: by 2002:a05:6808:4446:b0:3fc:1f7b:c39f with SMTP id 5614622812f47-4034139fc4cmr1483349b6e.18.1746194839582;
        Fri, 02 May 2025 07:07:19 -0700 (PDT)
Received: from [192.168.1.25] (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id 006d021491bc7-607e7cb1015sm536522eaf.8.2025.05.02.07.07.17
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Fri, 02 May 2025 07:07:17 -0700 (PDT)
Message-ID: <7ae26b10-23d1-4eb8-8305-924b904771c5@gmail.com>
Date: Fri, 2 May 2025 09:07:16 -0500
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH] Add License variable to pkg-config file
To: Nobuhiro Iwamatsu <iwamatsu@nigauri.org>, ell@lists.linux.dev
References: <20250501011508.3917337-1-iwamatsu@nigauri.org>
Content-Language: en-US
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20250501011508.3917337-1-iwamatsu@nigauri.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

On 4/30/25 8:15 PM, Nobuhiro Iwamatsu wrote:
> The pkg-config file has License variable that allows you to set the license for
> the software. This sets 'LGPL-2.1-or-later' as defined in SPDX to License.
> 
> ---
>   ell/ell.pc.in | 1 +
>   1 file changed, 1 insertion(+)
> 

Applied, thanks.

Regards,
-Denis
