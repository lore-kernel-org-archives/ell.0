Received: from mail-qt1-f177.google.com (mail-qt1-f177.google.com [209.85.160.177])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0F4D626A0E0
	for <ell@lists.linux.dev>; Thu, 27 Feb 2025 15:02:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.160.177
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1740668530; cv=none; b=JV8j0csrmulTUNewU1MFZJNFAQ942VuWPr1iGCU/EfVUBLkqIMwLGqwXNUpQztPLvzTgk8o91m1pYnstuW7YBXImgUw/137A3AIXUDMkX5HRfq40+3N/4zvevZKc7AfV+gZfzhA/cgwhM3UMI2roIgkVN0KlxEHbkP2yW9crrC8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1740668530; c=relaxed/simple;
	bh=KoDS7RWpKsCrDFiDfNwLwIlVr41775wnikNCtL1m9dk=;
	h=Message-ID:Date:MIME-Version:Subject:To:References:From:
	 In-Reply-To:Content-Type; b=Xc0W9VlbsFHiZJuzclPjKMOoIcOyzp3p++1u+WDyQRi+mJ1jpzmLE4jSiVxeeXTiMqs1swV/gqtakmLkD4Xh6WG89eKDlKX6rXpOAq0/swX6l6WUGads31A+hU7OTOtHfIb9T8vx2xfx+d2vHY2ei6WFVWtFPToHO2BzP2pwf2Y=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=IiNZ+5O0; arc=none smtp.client-ip=209.85.160.177
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="IiNZ+5O0"
Received: by mail-qt1-f177.google.com with SMTP id d75a77b69052e-47210ab1283so14182541cf.1
        for <ell@lists.linux.dev>; Thu, 27 Feb 2025 07:02:08 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1740668528; x=1741273328; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id:from
         :to:cc:subject:date:message-id:reply-to;
        bh=taCtzd70KvUi2V+G73d05wetJvUe8dV9kgcs4gGF8jU=;
        b=IiNZ+5O0mVRMjh4oPaeLd5Kmnjq45CFpFLS8gFweLhC5sBK9z9gLgPaXR2hXSF8v2F
         qNZTk43cdaZx0EMGGgmqLQ+45ftZ15Zt5gma+aWZthReZTqR4vru8lQspoiBdnY7wMeb
         Q4YrnVWUUUkhtKsTbgnuLcXNbZCCKzJYgT7bRSbULTa4HqNiHD6m6jSbDBfwd3eFyBA0
         rsjMaZ7kODFuKxt5kkuVrNDCI0k8h7tEq/d29D1AqKNjm/uQKRJjckNyzNIYZZYLV09w
         LL55V1MEUSlrm7QA9vQtPOX3KddLFz2Evkk8bWzxd3iKWC5ojO3ZCoYR2LA6PorqMTJZ
         nm0A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1740668528; x=1741273328;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=taCtzd70KvUi2V+G73d05wetJvUe8dV9kgcs4gGF8jU=;
        b=h301psC0ROEaxRZ1rpTSyealAeIaJkWkFYRWSAWn8j/jprdZ0b09C/HJg7TdCbOkv1
         xmTYAD4HWhUPOFyuZhN5JHH9RSfbSLUptsoNFVlGje4eNwxO6SeDx33Z7QqbcPzfIrsj
         ZOKWYEYeYrtrRfaTWggUC+owq1r0k8m5WjdhbDqYVP9eYYOAu82UPUPrR/sq+Un5NkJC
         LsoJ5JrwKkLs5ZDA5sevBMsdedS79ia9UGFS9RJQd/xv5cus0wz57ec660ugsWJYeepA
         Uik7S/4WR+XVP1X/t18WOXVRBgULT0ZjYKBRjRcfhaZT/bOPmzP7FZrrsU5nMeeWxPDc
         iy3A==
X-Forwarded-Encrypted: i=1; AJvYcCXzMMy0+0Pb3wWYeTIlnCfnTzqvnlV7rneSdvO7X/WstpJDt41daxWSyqGk8qgTd0hPqlI=@lists.linux.dev
X-Gm-Message-State: AOJu0YwxxUn8mQYdykyZkJdTuZul1TcHNQl7UaxVa8cSta7ig1Tcsnzv
	i62A2RAKX78yPdA7Ty1b8QqzHkRJVSuXwoEsxBy+eLXL2fKZdV8VMvcqdQ==
X-Gm-Gg: ASbGnctcLLLBk0R09ljDb6iDSTQ7gR2QBedbB8NK/OXz8fzTbc9WhdPwzBxFtzfEV9z
	w4eaqesWkLsu7qURsE8FkiOzLTRcigMpb9gMN3F4HtNczMoCCCFrnKoh3TwY0HEsI5T0AaV1EP3
	YN6BeYKzLOiQIxdCgYKqQnRj4Nc+bveQEcfNLJmB4SvlXR1XONtCQrYhC90/68pS7bQ3IKfL7qB
	oRrQgd1vpSaqUItA9EyQ7Ygzd69wQW4TsEnO94f++aNgRwVTKVmKYwBRgAFi/Gs3TiWSnP5HxG0
	mnbbqxTrTZVRDtvR8BDpgUMvmss21Q==
X-Google-Smtp-Source: AGHT+IEujwY6NuDpDE08QwOttnA/vXCbCoL2ucLUt9kcoEtJ4q2QQ9SHStz6LYQ+V6E2bWdqXDJN6Q==
X-Received: by 2002:ac8:5a92:0:b0:472:2df:6ff1 with SMTP id d75a77b69052e-4737721a964mr205117791cf.13.1740668527772;
        Thu, 27 Feb 2025 07:02:07 -0800 (PST)
Received: from [10.100.121.195] ([152.193.78.90])
        by smtp.gmail.com with ESMTPSA id d75a77b69052e-4747242e3adsm11705121cf.65.2025.02.27.07.02.06
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Thu, 27 Feb 2025 07:02:07 -0800 (PST)
Message-ID: <68de70e9-336b-49ad-bcb9-a714cd37bb9f@gmail.com>
Date: Thu, 27 Feb 2025 07:02:05 -0800
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: Missing basename in util/test-path.c on musl-based systems
To: NHO <jy6x2b32pie9@yahoo.com>, ell@lists.linux.dev
References: <647ff8e8-caa7-4b26-8780-1e8308e19e5b.ref@yahoo.com>
 <647ff8e8-caa7-4b26-8780-1e8308e19e5b@yahoo.com>
Content-Language: en-US
From: James Prestwood <prestwoj@gmail.com>
In-Reply-To: <647ff8e8-caa7-4b26-8780-1e8308e19e5b@yahoo.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

Hi,

On 2/23/25 8:43 AM, NHO wrote:
> In systems using musl as libc, eg. certain Gentoo profiles, tests of 
> ell fail to build, with error:
> clang -DHAVE_CONFIG_H -I.    -fvisibility=hidden 
> -DUNITDIR=\""./unit/"\" -DCERTDIR=\""./unit/"\" -O2 -pipe 
> -fsigned-char -Wno-unknown-warning-option -Wno-unknown-pragmas -c -o 
> unit/test-path.o unit/test-path.c
> unit/test-path.c:65:9: error: call to undeclared function 'basename'; 
> ISO C99 and later do not support implicit function declarations 
> [-Wimplicit-function-declaration]
>    65 |         base = basename(tmp_path);
>       |                ^
> unit/test-path.c:65:9: note: did you mean 'l_basename'?
> ./ell/path.h:20:13: note: 'l_basename' declared here
>    20 | const char *l_basename(const char *path);
>       |             ^
> unit/test-path.c:65:7: error: incompatible integer to pointer 
> conversion assigning to 'char *' from 'int' [-Wint-conversion]
>    65 |         base = basename(tmp_path);
>       |              ^ ~~~~~~~~~~~~~~~~~~
> 2 errors generated.
>
> Musl doesn't have GNU basename() in the string.h, only POSIX in libgen.h
> See also: Gentoo bug https://bugs.gentoo.org/942788
> second error appears to be a false positive.
>
I just sent a patch updating this test to use ELL's internal 
implementation, l_basename(). This should fix the build on musl.

Thanks,

James

