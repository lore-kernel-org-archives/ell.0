Received: from mail-oi1-f177.google.com (mail-oi1-f177.google.com [209.85.167.177])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ACC66EA8
	for <ell@lists.linux.dev>; Mon, 22 May 2023 14:34:22 +0000 (UTC)
Received: by mail-oi1-f177.google.com with SMTP id 5614622812f47-38e04d1b2b4so3364106b6e.3
        for <ell@lists.linux.dev>; Mon, 22 May 2023 07:34:22 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20221208; t=1684766062; x=1687358062;
        h=content-transfer-encoding:in-reply-to:from:references:cc:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :from:to:cc:subject:date:message-id:reply-to;
        bh=gKHGcw9JI3n08JQgrvDKyu9ccbD5uy76XzfiXzkDU4A=;
        b=mVigfOYaBYiVnh/xpSVX2tIXupqici14vcSFhBC/x2o0pAuRBIW2Xf0id7FraOLg+G
         ESdfq/l0re5dNFafcgUNQfl6gCVWwVyGqwR6vUhRcaOS6CO/97DGcWGHOk883vRqJrtn
         ANpLVsc15DnGw7cVGzxAfoN4CqIfnT5Q6kUBn52kvz3tUJ1Ua9tT2TzuXDPAO8vKZXcm
         aANTt99JhNlFtykCV0PP4M1UuJXdvI8ANQp5u5F8uDdMyLSn8q+LuySXf0tpDjRcWbOL
         LTlDHmbjP1F2fHXgDt0YuXBF9wF7DmlhT1x/M+3F2TaTRX9SxWLZWRB5sYyNJ8SfnZQP
         YWXQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20221208; t=1684766062; x=1687358062;
        h=content-transfer-encoding:in-reply-to:from:references:cc:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=gKHGcw9JI3n08JQgrvDKyu9ccbD5uy76XzfiXzkDU4A=;
        b=XW1JNKhJc/DuEYCkl5L6/PRLrCb1gEQxrEMXWHOuYcM1VUmFZ65IoZN1UGqxIr3W64
         tzZRUI9wm+iHSX/Loz56EKEBO/tUWHx48gqgcVGx1PTlNKvpoKqAQ10kFW1M/bogPSay
         342wxfo6aNyV0cWAf1iSRenr1ZjEKv8xMrmqJahM1sgcE068Zc4xy9QTw1pyEJpymHJU
         iCqa9F6zQ8C9djcPjfwxDMkL7bf5WEJjl3adGpbp489xUqnDmnvGxFjP0VcewOJz8OwN
         q6B/XHvICWVMeLR67IBQbCj595ufxZXmuDIWotBsqmAEdAHuvCetDBe2pkC96lV67jAP
         vGCw==
X-Gm-Message-State: AC+VfDxKxQAPtig0k4IwgpiyRNOhFYrBAOLqiaqd//UtBpEM4mpj7b3J
	K/s9tTiUlemTbpTRKEaS7u9SKay54Rw=
X-Google-Smtp-Source: ACHHUZ7wrRtTMXZsi21xdh39jaRPxF5nWib5vaHjZ+UHk9Y6RnPfEb0DlNmJZgW6DqgpFrZifMk7hQ==
X-Received: by 2002:aca:1914:0:b0:398:268e:4c7c with SMTP id l20-20020aca1914000000b00398268e4c7cmr367389oii.42.1684766061784;
        Mon, 22 May 2023 07:34:21 -0700 (PDT)
Received: from [10.0.2.15] (cpe-70-114-247-242.austin.res.rr.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id q83-20020acaf256000000b0039600e3376asm2789754oih.1.2023.05.22.07.34.20
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Mon, 22 May 2023 07:34:21 -0700 (PDT)
Message-ID: <2ec7c50c-10e2-396f-9ff2-9b1d3d4b9135@gmail.com>
Date: Mon, 22 May 2023 09:34:19 -0500
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:91.0) Gecko/20100101
 Thunderbird/91.11.0
Subject: Re: [PATCH] ell: Make public headers compilable with C++
Content-Language: en-US
To: Brandon Cheo Fusi <fusibrandon13@gmail.com>
Cc: Marcel Holtmann <marcel@holtmann.org>, ell@lists.linux.dev
References: <20230428122025.117834-1-fusibrandon13@gmail.com>
 <517bc712-06cf-98c2-c799-eda3d2a9db36@gmail.com>
 <CAEVJM+pD_CafRK=B+OXqJZHx-MDz-PsCRDkO43fji1VmZ_cjew@mail.gmail.com>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <CAEVJM+pD_CafRK=B+OXqJZHx-MDz-PsCRDkO43fji1VmZ_cjew@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi Brandon,

No top posting on this list please.

> 
> Thanks for pointing that out. Wouldn't it be better to not assume an
> array of 6+ bytes and instead
> do NULL and size checking in the implementations?
> 

Well, 'better' is in the eyes of the beholder.  Since we're primarily a C 
library, the guarantees that [static 6] syntax provides are 'better' since we 
can avoid unnecessary checking.  This checking is trivial in the end, but still...

This particular syntax also helps with code readability since the user is 
automatically provided an explicit meaning of the function arguments.

I'd like to preserve the latter if there's another suitable alternative.  My 
main point though is that your patch that just changes the signature is not 
enough.  You have to address the implementation and ideally submit patches to 
iwd since you're breaking the API.

Regards,
-Denis
