Received: from mail-oa1-f41.google.com (mail-oa1-f41.google.com [209.85.160.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8D41810E1
	for <ell@lists.linux.dev>; Thu,  9 Nov 2023 00:41:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="bUAAwK3m"
Received: by mail-oa1-f41.google.com with SMTP id 586e51a60fabf-1eb7a8e9dd0so148105fac.3
        for <ell@lists.linux.dev>; Wed, 08 Nov 2023 16:41:50 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1699490509; x=1700095309; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:references:cc:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :from:to:cc:subject:date:message-id:reply-to;
        bh=oUjCxGm4CxiAkhTmi/mqQUI9QY0aaC85uUdCJUihahw=;
        b=bUAAwK3mtNjTTwDojLKn3VivMW3SzM9WavMU4gZ8Cdkp+4gwEcMJTjrHhuGitj6/zI
         yvH2OvJjshIganHAb39FVA7wySmUINkn4f1KpEKQxyX7gM0+pkgy1PGbGKyuv98Kr0Ui
         aEFs0iJXBgWJpYXvHkhYWQbij7eSKTrmYIw7ZlkO1dl/o2Uy1AJcCKNHAtpVHLsDjFl8
         FMpQeCJg7NS7GQKV01YmRE9BeCMdH/EagXh16REZd1Nx6HR8vzAFhDzRW7o1010VUhcr
         dCC6lw/62xyt+zCZSXAI+Ebevhj8LI8tgcK2c08eUkKOskLATjtQMkHZSDYhB6eWTEaq
         KWkg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1699490509; x=1700095309;
        h=content-transfer-encoding:in-reply-to:from:references:cc:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=oUjCxGm4CxiAkhTmi/mqQUI9QY0aaC85uUdCJUihahw=;
        b=rbbkQP49n/Qd/qWD59vg4R62hhlxxRAjDlIGcwJHA/r2Hc635CHpJu7nKNMictU1xo
         XVgt3sFD21vbjxHD2EcjFYbeDHl+NCVK7SwY3/lGRnwfxK3iKXPkh9ndUZkvcyw74Deg
         3INkNDJdxNUZ8T5Wtg3STVCKKOd2FAYDsnxb5tjrZe3RYmCAh4IhLaw5fDpZ5BiU8LZq
         ejfbjjChEC6jMytA7IptVIYgxK3PCRiwgNhnP9Y9z/faAK2KxDK8HWXPttCoI6X4cjvD
         ngEY2NWaQq+KLcdseUanwxHnF1SNw6wASjVL824weqTdqTQ1SlaN8whhRLfLMtat198O
         5N0g==
X-Gm-Message-State: AOJu0YzjbRwHUuPXag6XFHDueMlC5Gr4C/UzsnfZFZOChCrzSoQ3hk19
	t9ghEz4YAB2o6+LfaxOEbgbSFMV/7EQ=
X-Google-Smtp-Source: AGHT+IHhSxECsAbkqgmaJcuNPlbxoTj70OcHid8FXrwKhM7jhw+deIVvL+2TEgIgs4TbpP1GUErozw==
X-Received: by 2002:a05:6870:9d0f:b0:1e9:9989:33a5 with SMTP id pp15-20020a0568709d0f00b001e9998933a5mr3983191oab.5.1699490509557;
        Wed, 08 Nov 2023 16:41:49 -0800 (PST)
Received: from [172.16.49.130] (cpe-70-114-247-242.austin.res.rr.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id v3-20020a056870e28300b001f40abd9fdbsm52950oad.2.2023.11.08.16.41.48
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Wed, 08 Nov 2023 16:41:49 -0800 (PST)
Message-ID: <9e8fe433-ffb9-4846-90f9-83cb52e9e4c1@gmail.com>
Date: Wed, 8 Nov 2023 18:41:47 -0600
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: ELL 0.59 Does Not Compile against Linux-4.9.212 and/or GLibC-2.28
Content-Language: en-US
To: Grant Erickson <gerickson@nuovations.com>
Cc: ell@lists.linux.dev, Marcel Holtmann <marcel@holtmann.org>
References: <EE577BA9-358B-44E1-BC6E-810EBFA4998F@nuovations.com>
 <2b9a12a2-87a9-4e10-b24d-77268369d01d@gmail.com>
 <124DF4B5-4611-458F-8F68-E386891838AD@nuovations.com>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <124DF4B5-4611-458F-8F68-E386891838AD@nuovations.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

Hi Grant,

> 
> I’ve no requirement for EAP, so all good there.

Then if openssl gives you trouble, try doing:

have_openssl=no ./configure ...

This will disable certificate tests in ell (which are only useful for EAP).

> 
> Regarding the patches, won’t inclusion of an uprev netlink header result in a -ENOSYS or -EINVAL when those symbols hit the downrev kernel? Or were they privately defined in the 4.x series but not publicly exported?

The EXT_ACK support is purely for debugging.  If we fail to set that option on 
the socket, we ignore it, so that should be safe.

The missing RTA_EXPIRES should hopefully just be ignored by the kernel.  But it 
was introduced in 4.5, so you should be fine ?

Regards,
-Denis
