Received: from mail-oa1-f53.google.com (mail-oa1-f53.google.com [209.85.160.53])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B7DC57C
	for <ell@lists.linux.dev>; Mon,  6 Jun 2022 18:29:28 +0000 (UTC)
Received: by mail-oa1-f53.google.com with SMTP id 586e51a60fabf-e5e433d66dso20156067fac.5
        for <ell@lists.linux.dev>; Mon, 06 Jun 2022 11:29:28 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=message-id:date:mime-version:user-agent:subject:content-language:to
         :references:from:in-reply-to:content-transfer-encoding;
        bh=ElOC9x09YAYpzL584/WbhSfgD0FN+3llkvymaaGIJVo=;
        b=n+UTHmq9A1JCB0z+0gLdkyuFUuDFkGcqTlEGd61FIB3SM8mfBHkfWC5Dn0+JelmZhN
         PMD2I0yfDX+lg1XXmIVgAQnEHFZpyRYASKJ2O1isSB9/ElFdOFgC7/QQxHsiP6y1BiR3
         tNbiAgEgcY/dUBfCPHowF1O1YWuN9+8oMUwR6WDUf+swNmMHnfQ8PJie33FzXsdRXvlZ
         ybqfDfFCUdeQEfPyNjDHc+ouuodD50HJJyC2LcXKbALRfSPQwnDbxhzdGMDn6qVnInZt
         pmpsDzj8U59sxNYySzQ/ApMRpliqNoJHQ05srANfipjpik80MR/UrlBUhhoxZsmOQeLm
         SzNQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:message-id:date:mime-version:user-agent:subject
         :content-language:to:references:from:in-reply-to
         :content-transfer-encoding;
        bh=ElOC9x09YAYpzL584/WbhSfgD0FN+3llkvymaaGIJVo=;
        b=NIPavk6+raYA8cSjskBhtfUsjjX36iCF3YB42enqoAfrkudkYLIPXhFUOsLbi01yGW
         HMeFjdTrnrJluCnQBoE/WQVolMDNZM6d+8bktwCIbleTaWPlJsOFwTErO40p9MkuxHGK
         50R29kkV7YxqTS7HCZefeV0Z8qOefLm7JSmMomX4AQ77sYYCplhgvfK6QXf3gIQc3UPg
         afUTimtNwJYO7T38OpUfmRAbOo2WFB7c3qr7PSBywa8XBqTdlOFIqsoGSQ6Udq49rK/l
         QeOm9LTXVARJY9oVbNgP0zDVnBaoKxEDgopDxLHRklQH48KYFQVo09iIP4TxxTtW1fEu
         NjWw==
X-Gm-Message-State: AOAM531i4hN3vtHAnVarWPNd+W7k7hEzP2ih/BOOWXE1EKEZYNlsZaEH
	9B+wHen+dndcv5FDPo+RwuE=
X-Google-Smtp-Source: ABdhPJxfxKeUChLQvbt2sGX6zYen1kRxq/2Kw59LgMdk+kmjQqqUvE5XXjElJhx5cuRPM84BgdE6rA==
X-Received: by 2002:a05:6870:828c:b0:f5:f122:f440 with SMTP id q12-20020a056870828c00b000f5f122f440mr15071990oae.168.1654540167725;
        Mon, 06 Jun 2022 11:29:27 -0700 (PDT)
Received: from [10.0.2.15] (cpe-70-114-247-242.austin.res.rr.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id x15-20020a05680801cf00b0032e85fdbb2asm2292918oic.36.2022.06.06.11.29.26
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Mon, 06 Jun 2022 11:29:27 -0700 (PDT)
Message-ID: <d9136de0-9732-d2b6-0243-45509d74db4e@gmail.com>
Date: Mon, 6 Jun 2022 13:17:28 -0500
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:91.0) Gecko/20100101
 Thunderbird/91.3.0
Subject: Re: [PATCH 3/3] dhcp-transport: Initialize the udp_fd field
Content-Language: en-US
To: Greg Depoire--Ferrer <greg@gregdf.com>, ell@lists.linux.dev
References: <20220507235434.11693-1-greg@gregdf.com>
 <20220507235434.11693-4-greg@gregdf.com>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20220507235434.11693-4-greg@gregdf.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi Greg,

On 5/7/22 18:54, Greg Depoire--Ferrer wrote:
> Initialize the udp_fd field to -1 in _dhcp_default_transport_new to
> prevent future mistakes where a random FD is closed when the transport
> is closed before the field is initialized.
> ---
>   ell/dhcp-transport.c | 1 +
>   1 file changed, 1 insertion(+)
> 

This mailing list isn't quite live yet, so I somehow managed to miss this 
series.  Sorry about that.  Wish I didn't since it would have saved me some time :(

Anyhow, there was a related fix applied as commit:

f5fccbab31e6 ("dhcp-transport: Do not leak fds during bind")

Regards,
-Denis
