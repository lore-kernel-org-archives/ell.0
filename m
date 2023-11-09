Received: from mail-ot1-f44.google.com (mail-ot1-f44.google.com [209.85.210.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3EE001CFB9
	for <ell@lists.linux.dev>; Thu,  9 Nov 2023 15:46:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="jc3joBVw"
Received: by mail-ot1-f44.google.com with SMTP id 46e09a7af769-6ce2eaf7c2bso576959a34.0
        for <ell@lists.linux.dev>; Thu, 09 Nov 2023 07:46:44 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1699544803; x=1700149603; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:references:cc:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :from:to:cc:subject:date:message-id:reply-to;
        bh=ysyzhW9F7BBGSzBROSDCv0+VCjm/UPWiJRZgMFS5TJA=;
        b=jc3joBVwWYU9M+o8NJ7USrzL6SEEZxPa0qv7K++kIrOdhb3RGzpz4ixORLxt/5kNFR
         8EvtkQoKX7zrsQzxYnpmK98PHmtrWkF/MfDQl+CqObMdv9uTyaTCYE/dS4XZKnyQLeK3
         YjGq3dKxsZEGDOQS5ThYfS7ivbDsUC9KOLDMOTwVCJpVNl/RYvv+B58F1KIT7xDOUBaz
         Aq5x377jKgk2UV7PJCIYZBeAY9V4aeIC/mhCB8cWPeSh29sZ9rQVU3UygRd+gQrrNmoj
         Tm0JM3RJ7Q+RweRIkAKapGs9v0wPQbN0LDItY4A43OUl6rd2Z8uYE4n5WsqqwHzEnR+r
         i5xA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1699544803; x=1700149603;
        h=content-transfer-encoding:in-reply-to:from:references:cc:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=ysyzhW9F7BBGSzBROSDCv0+VCjm/UPWiJRZgMFS5TJA=;
        b=Wpe9VdUftNFM+gJ4ruknIRxSVdMrjnfjhbN1Cyl79fTEqMDir6RhjddhQJqQSaEWs7
         Ay2pQ12xf4/c24QSJT8/MQcgzUbFTDlBNFc11zhytZsMioWSknfdncaeXx4B2SGVR0BF
         S0g1kY3oj05I9VTmbn5YEfPsPtYI+pkhc2xrvqhBoxNtc9DySSN9VYshBcIfaxoAtiE2
         JcdcTUFZJDux4XrIU8eRVZmZbyRzvrz7o8iYuC7m4AgkxiCQTTJ15Lhqb9IpSxBFyvo+
         8Vta9VPj+s3deyUVO16JbvNj7206Gcau4R0f1EiRztN7y5dTznB/muulWJgW4PamxFpY
         4w8w==
X-Gm-Message-State: AOJu0YwBWq2eDkBi7AMK8jM392kiZhRgmVBVLIT7CqL8Utwc8s7qmRrj
	NAsMIAcjfw1YnNI2YJfQumT2jD47U10=
X-Google-Smtp-Source: AGHT+IGCeNwFiZS/KSG/vhRu2SORUAL6Lzr7sOnZDsqAFvItay6aRl2+6n3/T8EcX+QyOWAI/nUFPA==
X-Received: by 2002:a9d:5e90:0:b0:6d3:19bf:2d16 with SMTP id f16-20020a9d5e90000000b006d319bf2d16mr5283029otl.12.1699544803278;
        Thu, 09 Nov 2023 07:46:43 -0800 (PST)
Received: from [172.16.49.130] (cpe-70-114-247-242.austin.res.rr.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id bg19-20020a056830361300b006ce2ec1d000sm2240716otb.59.2023.11.09.07.46.41
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Thu, 09 Nov 2023 07:46:42 -0800 (PST)
Message-ID: <72d523b6-ee3c-4aa1-a6db-79b8127f6455@gmail.com>
Date: Thu, 9 Nov 2023 09:46:40 -0600
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH 2/4] netlink: Fix compilation on really old platforms
Content-Language: en-US
To: Marcel Holtmann <marcel@holtmann.org>
Cc: ell@lists.linux.dev
References: <20231108234544.1050199-1-denkenz@gmail.com>
 <20231108234544.1050199-2-denkenz@gmail.com>
 <E3F4E4B3-9FA9-4592-BE11-8BB99D55E091@holtmann.org>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <E3F4E4B3-9FA9-4592-BE11-8BB99D55E091@holtmann.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

Hi Marcel,

>> -linux_headers = linux/gpio.h
>> +linux_headers = linux/gpio.h linux/netlink.h
> 
> so while we could do this, I really don’t like it. Running after upstream netlink.h changes is something I rather not keep doing. For the nl80211.h header this is semi-ok, but I rather not keep doing that for all netlink headers.

We don't really need to run after them, the EXT_ACK support has been in there fr 
some time.  The problem is that EXT_ACK uses a ton of other attributes missing 
from linux-headers circa 2016.  The missing #defines are easy enough to add to 
missing.h, but the problem is this one:

+enum nlmsgerr_attrs {
+       NLMSGERR_ATTR_UNUSED,
+       NLMSGERR_ATTR_MSG,
+       NLMSGERR_ATTR_OFFS,
+       NLMSGERR_ATTR_COOKIE,
+       NLMSGERR_ATTR_POLICY,
+       NLMSGERR_ATTR_MISS_TYPE,
+       NLMSGERR_ATTR_MISS_NEST,
+
+       __NLMSGERR_ATTR_MAX,
+       NLMSGERR_ATTR_MAX = __NLMSGERR_ATTR_MAX - 1
+};

That is an enumeration.  Maybe we could write a configure-time test for this, 
but that's a pain...

Same situation with rtnetlink.h, RTA_EXPIRES is an enum, so a configure-time 
test is required.

Regards,
-Denis
