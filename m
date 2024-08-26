Received: from mail-ot1-f53.google.com (mail-ot1-f53.google.com [209.85.210.53])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 627E93C17
	for <ell@lists.linux.dev>; Mon, 26 Aug 2024 15:38:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.53
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1724686721; cv=none; b=PW9Tt2hqRWiN4IeuCWqHuM8VPZai/8F3tuzyrGpu2wH8oBibU7n6Y+L5+ofiHWfkkX/qmiKmoJCuXH2Asryw+UJwGVdh8v91ELtnkrrhBN1H8c6y1x5doLGgqhu+O8p4ECBEa4UFiz0+jaI5g8RnGHrvVawVnROaq3yrlW9wxqo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1724686721; c=relaxed/simple;
	bh=UCo0nws+e10ETOu7YJoX5ZZDtJf9kGV8BBdRy5Z3IQQ=;
	h=Message-ID:Date:MIME-Version:Subject:To:References:From:
	 In-Reply-To:Content-Type; b=cqhqB3+uXrHy64ZH/ID+P/OZJqz1fIJ1CEXeXkmp4nA3J03faXbFFydtUo33NkaEiLowrjiUJowGY0Gakwo73E96i+jjQwOmO3SMk9rJ4Gno5o8yG2j+70Wy5h+jNKOcIlrluuEM6Gn5B9z4JWsfRFyjrfMEJsU4iAtTgqCYRfE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=e0/5c4gP; arc=none smtp.client-ip=209.85.210.53
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="e0/5c4gP"
Received: by mail-ot1-f53.google.com with SMTP id 46e09a7af769-70df4b5cdd8so3593666a34.1
        for <ell@lists.linux.dev>; Mon, 26 Aug 2024 08:38:40 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1724686719; x=1725291519; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id:from
         :to:cc:subject:date:message-id:reply-to;
        bh=IiCPlekEnPSm3hl002uYF7HyeePqQTVLmML1oom0C9M=;
        b=e0/5c4gPWAetoJf1P1qfZmg0QwlxlUHGE5hqQk7xBYQHukQM5roUgG48JFamOLhSdg
         Fmt3Rem+U61UwOAoz+uEmreaDDXpPE2JfO00dZx9Ic7C7Y5juuqTZKzCdVVE+UDaQd6i
         JnP4GzPkPCn6ipCKEeg61ykK64TGkVh8FtaYUieAFbnF3a45GIKXhQPE/irr/6I5WdMo
         3r2fFGRTYtL1xgOns3ze9UEVG7Grml3kE6SWFVgz3uvqEccByB8EYkcCbPPHcP0F9O+2
         CqhELZsDHzZb4NFezD++EHpR4zDDYqyKCZtQzzdl0WkCMK+biVdzZPWIZo9KuqNkfuUg
         A0Zw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1724686719; x=1725291519;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=IiCPlekEnPSm3hl002uYF7HyeePqQTVLmML1oom0C9M=;
        b=eReyTZNDFMZXWfgdzt0RXp92tOXC9R+HJr0dgzsJh8tVB3xJ1n+/t52WL64F1xYdH5
         eqL+1usN0XzQTZh1pMosDdsxXpJ6TA4Cz429Sf519oVyQvJbdm0yD2V/KSu/5KdfsSt2
         F+DuomcJURaqEhTtohv/BnYvIZLKA8JO7OnAv+ynJqzIfLCoCT4xlvApSQR7XCrtr6Yb
         BPfPwyKM1YrsD2S37BBOL/2weSLLUpKMhjyd9N3BpuoF/0b/zzCpOitXmt8jRge3t7yb
         LHxuW7JbJQjNHN9P3Cs6kHuhTs9q2rf9GiwrEwuL1K1huNVoocKER9TNjbxhlNPw+HRw
         y/Kg==
X-Forwarded-Encrypted: i=1; AJvYcCWOehfjdZMFlIss/VGsWQwuFhQmfxI7MJXlBlpR+rRTsWfRunAUT/mWmIAeXpk76ASpuIY=@lists.linux.dev
X-Gm-Message-State: AOJu0YxIVfIJLfmXLkDbwxpGnjwUZo9qTQcXJwNmmYiqWJgvqgmR7j4H
	p9q4Oovs+eVnAVfyQCX/P77my58UOUc3G171GPLTyoqS57gz+PuM
X-Google-Smtp-Source: AGHT+IF7iiTJD2gIu3XrXn0Vx2dwDPYJrebsiGHXZ+SEyoJyjjN56GjsCDtFK6zaTAbhC/DUz0yxuA==
X-Received: by 2002:a05:6830:6384:b0:709:3792:5e0a with SMTP id 46e09a7af769-70e0eb6cb5fmr13092881a34.17.1724686719310;
        Mon, 26 Aug 2024 08:38:39 -0700 (PDT)
Received: from [192.168.1.22] (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id 46e09a7af769-70e03b6024esm1944843a34.63.2024.08.26.08.38.38
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Mon, 26 Aug 2024 08:38:39 -0700 (PDT)
Message-ID: <14a637ae-0f31-4429-963a-5f5012841ee0@gmail.com>
Date: Mon, 26 Aug 2024 10:38:37 -0500
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: missing header files
To: Andreas Radke <andyrtr@mailbox.org>, ell@lists.linux.dev
References: <20240826143746.7ae0fa86@workstation64.local>
Content-Language: en-US
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20240826143746.7ae0fa86@workstation64.local>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi Andreas,

On 8/26/24 7:38 AM, Andreas Radke wrote:
> Using "make install" target seems to not install some of the header
> files. I've run into missing ell/useful.h for recent iwd build from git
> master.

ell/useful.h and ell/asn1-private.h are special.  They're copied from the ell 
tree when iwd is built.  Even if using shared ell, you need to setup ell as 
described in the README

> 
> Can you clarify whether all these header files should be installed when
> building a distribution package and please make the Makefile install
> those that are expected to be present on the system.
> 

These files are included in the distribution package.
[denkenz@archdev iwd]$ tar -Jtvf iwd-2.19.tar.xz | grep useful
-rw-r--r-- denkenz/denkenz   1979 2024-08-16 10:31 iwd-2.19/ell/useful.h
[denkenz@archdev iwd]$ tar -Jtvf iwd-2.19.tar.xz | grep asn1
-rw-r--r-- denkenz/denkenz   4406 2024-08-16 10:31 iwd-2.19/ell/asn1-private.h

> cp ell/*.h "$pkgdir"/usr/include/ell/ shows these additional files now:
> 
> /usr/include/ell/asn1-private.h
> /usr/include/ell/cert-private.h
> /usr/include/ell/dbus-private.h
> /usr/include/ell/dhcp-private.h
> /usr/include/ell/dhcp6-private.h
> /usr/include/ell/ecc-private.h
> /usr/include/ell/gvariant-private.h
> /usr/include/ell/icmp6-private.h
> /usr/include/ell/main-private.h
> /usr/include/ell/missing.h
> /usr/include/ell/net-private.h
> /usr/include/ell/netlink-private.h
> /usr/include/ell/pem-private.h
> /usr/include/ell/private.h
> /usr/include/ell/rtnl-private.h
> /usr/include/ell/siphash-private.h
> /usr/include/ell/time-private.h
> /usr/include/ell/tls-private.h
>   usr/include/ell/useful.h

None of these files are to be installed by ell, they're not part of the public API.

Regards,
-Denis
