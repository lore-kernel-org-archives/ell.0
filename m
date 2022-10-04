Received: from mail-oa1-f42.google.com (mail-oa1-f42.google.com [209.85.160.42])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3749533D9
	for <ell@lists.linux.dev>; Tue,  4 Oct 2022 17:44:42 +0000 (UTC)
Received: by mail-oa1-f42.google.com with SMTP id 586e51a60fabf-1322fa1cf6fso10025644fac.6
        for <ell@lists.linux.dev>; Tue, 04 Oct 2022 10:44:42 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :from:to:cc:subject:date;
        bh=Z+8BYPHPlpo6MnAg400j7CucDBZBAJS5GElTB9xb3J8=;
        b=G6H6o5wtQdjXoeUM87VNWuBbDhC1kmLbb6JAaf7CjHtSF1h+u+QkHXFX+RqWI+gBYg
         Tsbe0w0ce066VA7qKcN6cp1GXJMrvZ9JA8TMy8lOc7hDdA5uu781ON7po67l/DAWybci
         m42sUoQe7O+pFuTK9Ma2Khgmb42GoUwo86vjVYR/Bic7vm81KUjGTWs2hH7NGPZPiIE8
         tKXhUWXp+V6KGkWSxn49SvTItERGaOjHF+Xhr5HABonDp09jkZPBZX/+ZZAa2Yzv93UO
         r+JoYeL27g5pglYEVtIX1DHRRS1hsYibWrb461SUctc9XyUwUsmVW9fSwqpRVn//zJC6
         N4bw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date;
        bh=Z+8BYPHPlpo6MnAg400j7CucDBZBAJS5GElTB9xb3J8=;
        b=eFiB1na94AZrqJZY1CD8JjrKB6+4J2eeQe4zt8RUIUaEG3Qj59bFvzLCNfIiq09wy+
         F7JS2fMw7yH31gtsZpwisxfDBRh7lx1LxFEbP8w7XYkeElR+e9eJRSINTQbBbDIVh2/V
         hBBH75CQaWIvDuQj21xOEDA1ObL5mX4uGia/P5bu8kF6aEVFfe7e0OArWGgdXu5IHq7V
         Ur8wfVd/ewXA9rnjXOLMV+UqyRu7ywh1+wh+2bPDXCTaRFNj8SLy5yTkGPH3y8BmMe2+
         k//xiy845yV3IRzfNijikyDUHSsGdhU3n7GP5cx+iqd6k2Y6TnLwWCmrKXucqQCjE3Wq
         MHig==
X-Gm-Message-State: ACrzQf1+TPtQ//eqRXSDRDAd+wlO9O1AFTy5wLgemfyfpgtog1r3A72M
	TnTt7dOVrTsjt2QXTTbDHhQIds+CTl8=
X-Google-Smtp-Source: AMsMyM67oHwG3UDxt1guQZ8l1zjnYF0WrA6rhnFYY6Xyqd2u67zV+tcEsWBGyNXpiKu2VOoSK7ZI1Q==
X-Received: by 2002:a05:6870:3389:b0:131:94ab:fb63 with SMTP id w9-20020a056870338900b0013194abfb63mr494321oae.41.1664905481218;
        Tue, 04 Oct 2022 10:44:41 -0700 (PDT)
Received: from [10.0.2.15] (cpe-70-114-247-242.austin.res.rr.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id y40-20020a056870b02800b0012d130c2fdasm3907836oae.48.2022.10.04.10.44.39
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Tue, 04 Oct 2022 10:44:40 -0700 (PDT)
Message-ID: <a31e8c29-1d21-e5d5-08b5-3c681039f2fa@gmail.com>
Date: Tue, 4 Oct 2022 12:44:38 -0500
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:91.0) Gecko/20100101
 Thunderbird/91.11.0
Subject: Re: [PATCH 1/5] dhcp6: Fix emitting LEASE_OBTAINED in stateless mode
Content-Language: en-US
To: Andrew Zaborowski <andrew.zaborowski@intel.com>, ell@lists.linux.dev
References: <20221003222847.699047-1-andrew.zaborowski@intel.com>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20221003222847.699047-1-andrew.zaborowski@intel.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi Andrew,

On 10/3/22 17:28, Andrew Zaborowski wrote:
> Make sure we emit the LEASE_OBTAINED and not LEASE_RENEWED event after
> obtaining a reply to an Information-Request.  Only set
> client->request_na in stateful mode so as not to require the NA in the
> lease object when we're later validating it.  Fix switching to BOUND
> state after dhcp6_client_receive_reply() returns BOUND.
> ---
>   ell/dhcp6.c | 11 +++++++----
>   1 file changed, 7 insertions(+), 4 deletions(-)
> 

All applied, thanks.

Regards,
-Denis

