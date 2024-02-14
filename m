Received: from mail-pf1-f172.google.com (mail-pf1-f172.google.com [209.85.210.172])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E54D2604AB
	for <ell@lists.linux.dev>; Wed, 14 Feb 2024 18:28:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.172
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1707935296; cv=none; b=c62YcUJ0+uOMJvWzPn6Or3mo0wHKLU8SmJLGHOLkytC8ujcZk7M+nBmhZQD5bwX/FelzwBcF+kk7JBWFRkfo/NtUW7eNSAjezqLDYyMB8xZeMJuf/X+uUJeQjqYMAY5lT1FRTqlBWXMNcmrdxZ7ogCGe8Y8fBOOKjnP+HGKekG8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1707935296; c=relaxed/simple;
	bh=42iDTHn+NdgaoKAgQLrde0P8RZPKcceDX7a2sW6ejmg=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=p0POqTEad3Dkw5bdkW8kdJcL4qEKmnAomYAEEOedO2RrZ6TWtXH5lJM7MSjgUOxjXubA1+xjPvJ/mQGmqLdqHk1awsJ8SqBdqIu+AcHa2GeEHti9OEELHamhVGIpNebp2Ud7onPkqjGlYFCJWNSDYFns0+8gfs2D3/BB5hDRInE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=K2X0U7is; arc=none smtp.client-ip=209.85.210.172
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="K2X0U7is"
Received: by mail-pf1-f172.google.com with SMTP id d2e1a72fcca58-6da9c834646so74275b3a.3
        for <ell@lists.linux.dev>; Wed, 14 Feb 2024 10:28:14 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1707935294; x=1708540094; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:references:cc:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :from:to:cc:subject:date:message-id:reply-to;
        bh=UwyCy/buxTprlgtr0IFnSYEr+sJEeyYIfNmc6KWPgv0=;
        b=K2X0U7iserOaPsrUosHJ+g6yZP6r9Jq27niyXKnuv2SjnpuN2xFEsw2dMlYe2QuUnG
         2v5s8cFmA4fTZa9dYs93B8mN2gRFvDmC3+Xik+G6gnwNfFM4FmNUQI9pONUm05SrlB4K
         ZJAxD0JfPB7I9IZCjPNFBTW6wt+6y//RVe/Ku1VgJnFKp5fhp6gUDKoLyBZMeSvZCQJt
         2Wq5COWODnzLCuL8cqIKZzYOeodXc2wD1WEHuVejbVb+TpVw9bnUjJzb+Qx2EOGh/dvj
         9b42j47qJmYLbHrVwRumlm3nTB5FCEQZAeheIge4XDiOztIGxtF9jgXJqUFyz3I97Wvs
         4kzQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1707935294; x=1708540094;
        h=content-transfer-encoding:in-reply-to:from:references:cc:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=UwyCy/buxTprlgtr0IFnSYEr+sJEeyYIfNmc6KWPgv0=;
        b=Jd/4IydgIRWAAGONtov+L6Zm4Qvtb0thdgC6IY81IGZJVNgoefcXXGCJ/NB/bqmVne
         rAECTVmVeXyE74lOF/fbIM/WEZnqfmurYkca7lDXC4hpxv8zIPkmjcCVAFNtnpkmDPAi
         4IG0NpFfQaR/KLDwcBuM01DjdMoyqTPJ6cpN5l3kuE0z9ApiAE12pVPPqnnGElGlz51x
         fjgDBK7546d2O5mYY3FUa45vbn+yoWxmUUJA47/6NfzLfELHfZXqdkNwOA90r1HKTiGw
         szwyoD68NAyTUa7q/2ZeBFnYlpg0Adme09JXO9BzkhF37JkJ6mjg8vgJiWM9sJbBQD5N
         HOXw==
X-Gm-Message-State: AOJu0Ywk9+l3OxDgkuYzv2omO71VVS/VV0v/W6k+G/YINSZnAsojQeEB
	4YKbnWEH/QeRzWMJxRSPwDDsx2YMNzpOD50VTT0SkTcoHHag6k4V
X-Google-Smtp-Source: AGHT+IF2tZxmHiS5xaZTVLhdsbvX7TAO45TLHbvo6e0F+5PfJNq8MCi6PqVcEGsxEKSCKA99qEHCJg==
X-Received: by 2002:a05:6a00:1b48:b0:6e0:3db7:50e9 with SMTP id o8-20020a056a001b4800b006e03db750e9mr3194855pfv.19.1707935294117;
        Wed, 14 Feb 2024 10:28:14 -0800 (PST)
X-Forwarded-Encrypted: i=1; AJvYcCWlIW6oUjA/6AvIb//R5LfTl4PNG583gmkI3GOWgjE43hCBrJuW3Yii/VuwQmub+O3QSZPp6ERUNOf/xbdLgN52jU3q
Received: from [10.102.4.159] ([208.195.13.130])
        by smtp.gmail.com with ESMTPSA id c14-20020a056a00008e00b006e0d21dba81sm6937800pfj.191.2024.02.14.10.28.12
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Wed, 14 Feb 2024 10:28:13 -0800 (PST)
Message-ID: <8d128478-7c2c-45cd-a789-c44dffc2ad15@gmail.com>
Date: Wed, 14 Feb 2024 10:28:11 -0800
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH] log: add l_notice
Content-Language: en-US
To: Denis Kenzior <denkenz@gmail.com>, Marcel Holtmann <marcel@holtmann.org>
Cc: ell@lists.linux.dev
References: <20240213131619.828613-1-prestwoj@gmail.com>
 <0D7EFC7E-C3D9-43E0-823E-6C06498C6B3D@holtmann.org>
 <da1ddff5-80c7-46a4-9187-6cd8d5b2854b@gmail.com>
 <3129778E-09AF-46D9-97DE-44EC89C996DB@holtmann.org>
 <5645df71-5fa8-497e-b5cd-b21557aa9bb3@gmail.com>
 <306317D2-65C4-4299-83C3-DC4C616975C5@holtmann.org>
 <9f0927c8-d4d2-4a10-90df-436823f1d663@gmail.com>
From: James Prestwood <prestwoj@gmail.com>
In-Reply-To: <9f0927c8-d4d2-4a10-90df-436823f1d663@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit


On 2/14/24 8:57 AM, Denis Kenzior wrote:
> James,
>
>>
>> fine, then lets get a section into the coding style document.
>
> Can you come up with something?

Yep sure, but are you talking about IWD's or ELL's coding style 
document? l_log isn't used in ELL so I'm not sure its relevant there, 
and any external project using l_log could really do whatever they want 
with it.

For IWD yes, I planned on adding a coding style section along with my 
patches using l_notice as its going to be reserved for very specific 
use-cases and have some basic syntax requirements for tooling to parse.

Thanks,

James

>
> I've applied this patch, thanks.
>
> Regards,
> -Denis
