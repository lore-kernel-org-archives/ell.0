Received: from mail-oi1-f174.google.com (mail-oi1-f174.google.com [209.85.167.174])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2E1DC10797
	for <ell@lists.linux.dev>; Wed,  9 Nov 2022 20:25:32 +0000 (UTC)
Received: by mail-oi1-f174.google.com with SMTP id q83so8354087oib.10
        for <ell@lists.linux.dev>; Wed, 09 Nov 2022 12:25:32 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :from:to:cc:subject:date:message-id:reply-to;
        bh=xvFlk6VspplkBve7Z51sAxb608l++FZ1U7UYznaWNm4=;
        b=WlsMkHhzq1a+6hl1RKOBTNW1fJC4F6APQJmRE+vRog5y+PljnrTXU0b+haqzIBql4Z
         lk8LYFjWiptYnF74z7vUikUjjkC729VnECiBAIxA2Km0ncFPHobFYuMj2kbtuPgiSIK+
         f0GHWGnro6RUp9EKj08P8sNBXcev7zqCgC14/k8vka9Me7kUozVCV0CxvOUn0EebLksj
         5DVl0q5lLPcMCUM1SkF3S6pdvEPMqGWCsUix+w0+C4dgcHXBExLm++ufhzHReAtYcorY
         rrVRuhHyxzvRCv+jnG/ei77qYz7fyWFE1x3r+qq6ZoNK6Yfj4VFKHKh2vqIg9xL3Ek+L
         +PKg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=xvFlk6VspplkBve7Z51sAxb608l++FZ1U7UYznaWNm4=;
        b=cuL4WLJVR/CW6tpqbO6a7177wMYJ0SM/hcYhX6tpbDggvqW4QAhUNRvP39wUiL/0Gv
         YoROAaXQKNgFEe1pHLUfuQ1zaWvu6PRoHOtHwhX00C0Hw+H4LIx4pEjVmDknKvt4wbJ7
         7L5kUOnQFHz/noAKjNilaTrC9n09Ft+XkhpzCLGnIrD6I9d/Csr+ZbhMrq5c4rFhtHXz
         Y66uT1YaGc3xDyF8pEfAo0gke5dctoIFleU9OeMOMnfUQYfa8s32GhULFFV+AvRqHXyR
         j4X0agx+aYZ7p0xC4R+jXVQYxlmCUn1oXBfIMdAhz4b9pZYVdIH2CJX9JSWvMaR/aR8K
         7bZg==
X-Gm-Message-State: ACrzQf1oMdEN5k7UQ84ywMqCbue1sF0lXqrSOrSctsmPmNagdLjHMLQp
	PLp5AHjwHuwRmxN0Z1x0lH/ULtHHHgY=
X-Google-Smtp-Source: AMsMyM505drhopQ0+iXZSTp1e1N8pSm/jijyTWgky/2AA+dEhAEMBjUnTnXfXVMPeD+mPqNSepnA9w==
X-Received: by 2002:a54:4098:0:b0:35a:296f:9479 with SMTP id i24-20020a544098000000b0035a296f9479mr24468861oii.130.1668025531147;
        Wed, 09 Nov 2022 12:25:31 -0800 (PST)
Received: from [10.0.2.15] (cpe-70-114-247-242.austin.res.rr.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id q5-20020a9d6645000000b0066c15490a55sm5657477otm.19.2022.11.09.12.25.30
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Wed, 09 Nov 2022 12:25:30 -0800 (PST)
Message-ID: <c0659db1-4cb8-4950-6ac5-6504457f8d18@gmail.com>
Date: Wed, 9 Nov 2022 14:25:29 -0600
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:91.0) Gecko/20100101
 Thunderbird/91.11.0
Subject: Re: [PATCH 1/4] tls: Allow ServerHello extensions when resuming
 session
Content-Language: en-US
To: Andrew Zaborowski <andrew.zaborowski@intel.com>, ell@lists.linux.dev
References: <20221109174746.569046-1-andrew.zaborowski@intel.com>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20221109174746.569046-1-andrew.zaborowski@intel.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi Andrew,

On 11/9/22 11:47, Andrew Zaborowski wrote:
> While, as the spec notes, most extensions are not used during the
> resumption of a cached session (are offered in the ClientHello but are
> ignored and not be included in the ServerHello), this not a rule so allow
> each extension to decide whether to skip adding itself to the ServerHello.
> 
> Specifically those extensions should rather be ignored by the server
> when it is parsing the ClientHello but at that point we don't yet know
> whether we'll allow the session to be resumed so instead the ServerHello
> writer callbacks decide whether to reply or not.  As an example RFC 4492
> Section 4 says: "In the case of session resumption, the server simply
> ignores the Supported Elliptic Curves Extension and the Supported Point
> Formats Extension appearing in the current ClientHello message.  These
> extensions only play a role during handshakes negotiating a new session."
> ---
>   ell/tls-extensions.c |  9 +++++++++
>   ell/tls.c            | 31 ++++++++++---------------------
>   2 files changed, 19 insertions(+), 21 deletions(-)
> 

All applied, thanks.

Regards,
-Denis

