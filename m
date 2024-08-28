Received: from mail-ot1-f42.google.com (mail-ot1-f42.google.com [209.85.210.42])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D8AEE18787E
	for <ell@lists.linux.dev>; Wed, 28 Aug 2024 15:24:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.42
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1724858692; cv=none; b=faRQawo5naCKnTEwP51mkqbgxfPcPb/PqKsBBzYVibrihxfKjraQDPzafIS2ZD45Lb2RqHcgvt1t80i+tVZSJCuhSO+bPs4I6sIikjNEd25Qt7cc72OL5KEpAbsWFkI8b8dgH6Pm+NpR2B7fBI5zvhWSZbb/9JWWizDT4pRlToo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1724858692; c=relaxed/simple;
	bh=r4uz2n744Aad+7k0UWzSxINOkCc0gBlz3kSMahx+vmA=;
	h=Message-ID:Date:MIME-Version:Subject:To:References:From:
	 In-Reply-To:Content-Type; b=YALqPbbtG4nI9lPOrAIaVN+JGAHn8ljtkKUw46SlSPkIN9/aOfDpwCsqnOXrQMNOVWWI0YHdPXlvwGv3HPpgYw11L3DwPmv586DerXqAUXQnYfBcN7SXJvOhR7hWBJcM2xau4Duze1UY5ocNreOOoelYxOgjRWkqr5bU66CRC+M=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=lGh2BrbB; arc=none smtp.client-ip=209.85.210.42
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="lGh2BrbB"
Received: by mail-ot1-f42.google.com with SMTP id 46e09a7af769-70943b07c2cso5808107a34.1
        for <ell@lists.linux.dev>; Wed, 28 Aug 2024 08:24:50 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1724858690; x=1725463490; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id:from
         :to:cc:subject:date:message-id:reply-to;
        bh=I4wPpiyZTewgbWboAROGyeKWPmTRDmYmZf3ZAzZjEwY=;
        b=lGh2BrbBlAXZMt4QPj/OuwANi0BpED79Mt8GtQ5vf+KrGklB3oFOIcP2ONkm0BO7Xe
         WHMlLm/POhbLrHCXtyNufZyLz37TPsF5B/EeJD9ALeSg3xYXSVWYEDlM4CJ/meOZ1wxE
         36wnKKleADuLuhdS5nr+zCSKxKzrcUU515S7geDmB2nmPYwO0kkrkz66zKHQkiFISCwu
         B2nmAX7KR9Ix7M7rejTR7va5TZFYHpkSm06IARfgh1MWE57dmoOQDMRBLJ2IDJzZkkLU
         /B32lBuvKVTe6QRd2kk8Efc87I8XUd+pVCfetqz9PcYOBSOYyZz8f/VCbqHVzn9Oy6AZ
         NWng==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1724858690; x=1725463490;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=I4wPpiyZTewgbWboAROGyeKWPmTRDmYmZf3ZAzZjEwY=;
        b=KMifcE1SU1iG0E6YPAmmYJtPSk8vEZaqWYoZM1su8YATgAZc7QfGEdDMYuPgzaCJgG
         T6DL4YcQ8lYuAx1ZP3IBprj0CqQ0anuuX18KoSqcjlQF31kiivtk8MPnu/3WkBqqXvJ6
         3s5OiPy7NZcGep63I87lI5wEg89tGrzA3wUbVoyfS3Gh3qrovPpJe/wPKVqfK9q59pWz
         u5Hlxe2Q8J6CWuK8iTq+6IIr9iIXGD6DdC10LolnocLYeCsW+U1IsvDA6UJSJeaAyous
         FHeSoQ0qyr6QVoZa6HQUcuXvkEkEvftwarIJ7AKiCR5tBNdGa8nuSC7iOnOaRnxqgIEk
         fBtw==
X-Gm-Message-State: AOJu0YyzYJrX64cYQKnR20RvTVDLktYkdJCgMwRVeCEsj9M9/fD9BQl7
	/xLw/o87LVw5j+FGeZrpHApxnMuP1sCt9vFePSedQQiJZf06uCRS6v+V0Q==
X-Google-Smtp-Source: AGHT+IEh32kVf6ZKef/dT5wicQI2jziglfAZgSKG06Mr5ruUINd8Zb8W+9nPzgD7j/WrxE++f7G7iA==
X-Received: by 2002:a05:6808:3985:b0:3dd:2c1d:8d08 with SMTP id 5614622812f47-3de2a8d351fmr19348696b6e.31.1724858689717;
        Wed, 28 Aug 2024 08:24:49 -0700 (PDT)
Received: from [192.168.1.22] (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id 5614622812f47-3de2254e517sm3143045b6e.22.2024.08.28.08.24.48
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Wed, 28 Aug 2024 08:24:49 -0700 (PDT)
Message-ID: <4c57e471-b3f5-4e00-a35d-e6658dce7aae@gmail.com>
Date: Wed, 28 Aug 2024 10:24:48 -0500
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH 1/6] netlink: Add l_netlink_iter
To: ell@lists.linux.dev
References: <20240823161553.479576-1-denkenz@gmail.com>
Content-Language: en-US
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20240823161553.479576-1-denkenz@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

On 8/23/24 11:15 AM, Denis Kenzior wrote:
> Move netlink attribute iterator out of genl.c and into netlink.c.  Both
> genl and netlink use the same attribute structure, and is applicable to
> both.  This makes implementing netlink and rtnl message parsers much
> easier.
> 
> In order to keep source compatibility, structure the netlink iterator in
> the same way as the genl iterator.  In the future, the use of genl
> iterators will be removed.
> ---
>   ell/ell.sym   |  5 ++--
>   ell/genl.c    | 76 +++------------------------------------------------
>   ell/genl.h    | 18 +++++++++---
>   ell/netlink.c | 75 ++++++++++++++++++++++++++++++++++++++++++++++++++
>   ell/netlink.h | 15 ++++++++++
>   5 files changed, 111 insertions(+), 78 deletions(-)
> 

All applied

