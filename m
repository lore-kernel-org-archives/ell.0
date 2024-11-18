Received: from mail-oa1-f50.google.com (mail-oa1-f50.google.com [209.85.160.50])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7D66C13B7B3
	for <ell@lists.linux.dev>; Mon, 18 Nov 2024 18:15:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.160.50
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1731953757; cv=none; b=U8rSfKE9Gsjo7Qdm/SqGTDS1zNlN0iDLYEDl7IJVcSo0lyoID4iKh66HrsnhhlelweQ6RqzVSyQVMAn1OkuSn544uY4xUnZojy0cD0h/ZBbstxCQB7MlpEnvuIBve/8MVIpK6GBMmARZ29kxd4HFEgnNjK0kj54PGTNTuDDE/1Q=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1731953757; c=relaxed/simple;
	bh=K2ejIigfWdvvqn4DAY/GhQVRk5lAq75ZBsp9lQO7xts=;
	h=Message-ID:Date:MIME-Version:Subject:To:References:From:
	 In-Reply-To:Content-Type; b=cDf/w6AiFvtjtP7n9oCA+DzpHD0gP7vUHF2AuAJbPTl+AfL6kZCrDnpmAO3JsdlPyw3FsMN9zXv8/+ghPE7S9U+gXhlnzcxL5tnhn5BstJZ6Lq49CceALekrzk5ROvA24fuWCtYR+w01umaWdLkxnDkPc25myMdErSrJi5ywFv4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=Jdk/5F/C; arc=none smtp.client-ip=209.85.160.50
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Jdk/5F/C"
Received: by mail-oa1-f50.google.com with SMTP id 586e51a60fabf-29645a83b1bso1620462fac.1
        for <ell@lists.linux.dev>; Mon, 18 Nov 2024 10:15:56 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1731953755; x=1732558555; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id:from
         :to:cc:subject:date:message-id:reply-to;
        bh=XCQF+v/b7WdRJhT8jLOJcPaXQHQHwiCUmWK7t2gfsDU=;
        b=Jdk/5F/C52i08umDXSzww9df0L9y0FmV+wIhPYH4MHlWmZQVE2A1kkxXaxVKS6DsZ7
         nR3pBo7KWhoGBPP667EsUm4FPgp+MA51I1gRuo5xCM88s5VsQ9F44fgoRmtPbx2B0zZO
         rg4QH/mBplgYU1yps/pBV3BnsPfb6hhVSIW4/yehg0aedVE3sjcWC9YnivwwX84DqlPs
         3CW8MPBFhYO1OqEqytd0KnPj4AUDV0T7icup6kULgTaJYVRyJuyCv/nJOnH3sxfXynFp
         exmVCJo/+hVD5RaEnxHzhEZk60457ozwmbnXiqfNDfjDBSZ42gMM2m7C1sh8ieTfSugl
         swug==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1731953755; x=1732558555;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=XCQF+v/b7WdRJhT8jLOJcPaXQHQHwiCUmWK7t2gfsDU=;
        b=DfGLUkkIIpJgCET2Uu+PV4McXSwdBcPspQw4HqnuCNvNWYgB1GB7idVCSz/2JxJ6DW
         +M9ZeNwnJWSqGwtRWCX/6jGDBNkwX4UC+y7AXCnxBpTfMVMOm1QVZjWUwp5Qr4qyFttE
         jCl9e6WCXqBF9SOGMAD+yVY7svPK8X9QsbCPz/HrSI6vpbiEXs+xFaG8kRKuG7hi1Ky5
         nvbNXyyk/x4Uhp0v2GjH9M28+PXfTnPgrWtRJONdQ237AF1rUZmcQcs+1diVzhr8ASG9
         0WHuyRgKwvpk/bD6mt6vgTJF5+KgIqRjTlsxoxJxPs81ramFMmwgUf2zAyLRH7XJq5dQ
         RD/Q==
X-Forwarded-Encrypted: i=1; AJvYcCUkDcDNdrQqHlnJmU+imNSShDOxOBKJVXa/u5bJqXX5yjo9RcuCX+SAERANGp77E5/z39E=@lists.linux.dev
X-Gm-Message-State: AOJu0YxqSvII8DQIXaQmEBd+m1rOUGVeKtI9ofPKdMYl9bNjV3Zqfx5x
	PD2avwcKeEN2D/P6O4u6QolWrHj9id+EAmpTTrXXSappPQYNnAgn
X-Google-Smtp-Source: AGHT+IGtj8MVyy0rCw5oG2PMoFv+x1QemBZYzr+PZfZ3D5S+aCmDdsWBpFcN/93BDHtrO5IlxqqqZw==
X-Received: by 2002:a05:6870:568f:b0:284:ff51:58ad with SMTP id 586e51a60fabf-2962e154892mr12084157fac.27.1731953755467;
        Mon, 18 Nov 2024 10:15:55 -0800 (PST)
Received: from [192.168.1.22] (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id 586e51a60fabf-29651852ab6sm2844470fac.9.2024.11.18.10.15.54
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Mon, 18 Nov 2024 10:15:54 -0800 (PST)
Message-ID: <5175124b-904e-4a4a-934a-5e7d198dff0e@gmail.com>
Date: Mon, 18 Nov 2024 12:15:53 -0600
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH 1/4] settings: fix -std=c23 build failure
To: Sergei Trofimovich <slyich@gmail.com>, ell@lists.linux.dev
References: <20241117001814.2149181-1-slyich@gmail.com>
Content-Language: en-US
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20241117001814.2149181-1-slyich@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi Sergei,

On 11/16/24 6:18 PM, Sergei Trofimovich wrote:
> gcc-15 switched to -std=c23 by default:
> 
>      https://gcc.gnu.org/git/?p=gcc.git;a=commitdiff;h=55e3bd376b2214e200fa76d12b67ff259b06c212
> 
> As a result `ell` fails the build as:
> 
>      ell/settings.c: In function 'l_settings_get_embedded_value':
>      ell/settings.c:1521:24: error: incompatible types when returning type '_Bool' but 'const char *' was expected
>       1521 |                 return false;
>            |                        ^~~~~
> 
> The change uses poiter instead of a bool to return the zero value.
> ---
>   ell/settings.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
> 

All applied, thanks.

Regards,
-Denis
