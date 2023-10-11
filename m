Received: from mail-oa1-f46.google.com (mail-oa1-f46.google.com [209.85.160.46])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7A9D120332
	for <ell@lists.linux.dev>; Wed, 11 Oct 2023 15:26:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="bLTh6INu"
Received: by mail-oa1-f46.google.com with SMTP id 586e51a60fabf-1dcead29b3eso4330042fac.3
        for <ell@lists.linux.dev>; Wed, 11 Oct 2023 08:26:20 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1697037979; x=1697642779; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :from:to:cc:subject:date:message-id:reply-to;
        bh=ZcelBApYnf/0pp0QC1EZSV0a2/4UqdB5v6Np3PQgFdg=;
        b=bLTh6INu6NUljEiy7/wq2RfarLNoqW2vqGDJvgz7HmpnCGUSmMCoLqvX7/JKSU1PP0
         oFwbjyWFC05q+9DRWluY27PM0cS3eGF3KxRf0Ox1d9LsDk9XZLZSnnBS9pwQA++tabQ4
         6DVueMPPVi0828Yqt0jageniIFAFbJKRVzN76VAXUR2okphq5X1tqJvk0+Xgo1i8e51P
         ipHyy79Ck9sZV3jt/hczNeQJS26Jp1JT+lgwoEfjAJTVhRlQvSWDlnf+R9yDqEG59gAV
         22AyBnVEy11ULAC53q1/CzKOEgsCx0KtQxnRMlsHzaWK3XA+WkI8bcGc4jQ60NzZLQy0
         pkZw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1697037979; x=1697642779;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=ZcelBApYnf/0pp0QC1EZSV0a2/4UqdB5v6Np3PQgFdg=;
        b=QLBsz4fyvqwiAATZ4OltL8gBgJxxtmQE0GbhtcAQarzIDoLrceJhHWgU3npVAf/pr9
         yAYsNKRR9IvL57S5HC5ToofiBUEsaLEqlOLc7YiAimorh7p6PdWracN8vvQ6u4xvIDKH
         ahmqhkiDweiXUOJGmTrOR59VRtQ9KLzu1cPoomgZbw6+m1k4gAW8nXHQwGFwpf25g9ST
         Vt8ZAPaR4FrbLPR4lHk/R3clb8du+scL6vQu9awcWIgv3DvKPN5baTPyDDs5gD/w/sbl
         Bn3gx//Jl51HFAcIiDlvomaApiXTtDyGrEstLjzjmCB54MS8Fd7aRAyjAAvd5A4iS9fU
         uDyQ==
X-Gm-Message-State: AOJu0YyEhFdjrBhLqlJYIEg+uHkdxLgh1CwyoLsn7k38Xpwcd73pfCDc
	3cJk8rTtl5rRfA55lAfXD2VgSa/hH0M=
X-Google-Smtp-Source: AGHT+IEequSu45u4e3BhpFliedkoQfUGhJ8SqGxyoO/RGsmrKtduN/5Mx6uF0nTVBY2tvQ/rc0VVtQ==
X-Received: by 2002:a05:6870:89a5:b0:1c8:c27f:7d9b with SMTP id f37-20020a05687089a500b001c8c27f7d9bmr24798328oaq.27.1697037979585;
        Wed, 11 Oct 2023 08:26:19 -0700 (PDT)
Received: from [172.16.49.130] (cpe-70-114-247-242.austin.res.rr.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id ef9-20020a0568701a8900b001e12f685592sm3123oab.13.2023.10.11.08.26.18
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Wed, 11 Oct 2023 08:26:19 -0700 (PDT)
Message-ID: <05d05c63-eb1b-4d57-8fd7-4dcbc96caf6f@gmail.com>
Date: Wed, 11 Oct 2023 10:26:17 -0500
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH v2 2/2] unit: update test-ecc with compressed point bug
 fix
Content-Language: en-US
To: James Prestwood <prestwoj@gmail.com>, ell@lists.linux.dev
References: <20231010142506.261152-1-prestwoj@gmail.com>
 <20231010142506.261152-2-prestwoj@gmail.com>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20231010142506.261152-2-prestwoj@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi James,

On 10/10/23 09:25, James Prestwood wrote:
> ---
>   unit/test-ecc.c | 16 ++++++++--------
>   1 file changed, 8 insertions(+), 8 deletions(-)


Not related to this, but unit tests for ell no longer pass:
PASS: unit/test-pem
./build-aux/test-driver: line 112: 218850 Aborted                 (core dumped) 
"$@" >> "$log_file" 2>&1
FAIL: unit/test-tls
./build-aux/test-driver: line 112: 218865 Aborted                 (core dumped) 
"$@" >> "$log_file" 2>&1
FAIL: unit/test-key
============================================================================
Testsuite summary for ell 0.59
============================================================================
# TOTAL: 44
# PASS:  42
# SKIP:  0
# XFAIL: 0
# FAIL:  2
# XPASS: 0
# ERROR: 0

[denkenz@archdev ell]$ uname -a
Linux archdev 6.5.3-arch1-1 #1 SMP PREEMPT_DYNAMIC Wed, 13 Sep 2023 08:37:40 
+0000 x86_64 GNU/Linux

Regards,
-Denis
