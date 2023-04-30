Received: from mail-oa1-f53.google.com (mail-oa1-f53.google.com [209.85.160.53])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 12CDE3222
	for <ell@lists.linux.dev>; Sun, 30 Apr 2023 18:24:00 +0000 (UTC)
Received: by mail-oa1-f53.google.com with SMTP id 586e51a60fabf-1878f1ebf46so1493771fac.1
        for <ell@lists.linux.dev>; Sun, 30 Apr 2023 11:24:00 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20221208; t=1682879040; x=1685471040;
        h=content-transfer-encoding:in-reply-to:from:references:cc:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :from:to:cc:subject:date:message-id:reply-to;
        bh=7ZrYwlCTAd6AYZjRwcv7nQgRqz/EYx/BTeMmQ+Vatb4=;
        b=I04D5nm2i3u0eMkwH9aPB1gExwsjGqycDlNlWkMlmAPalDLhYLpOqplLKIpDrMI9LI
         cDZjKye8akNIaSA8VAPF2A2Fkf/8oSJejJlfRO1hJ6yDAct1gzp76YwMtR7rMJpESRn1
         u7tNa9gbYZcn7Ni+zkBOhisk8ZvQIEo7hPfzJbR6TxDVBFLD+2PJ6MNaYGJUdTPuhEY2
         BkToSpW7Fw9Nl9dol3oBjh3rnewryE02JkSGcIEBpgEAk7o+CTYuX+lTkIlfM76QI2y7
         MJOq9dfnHfd4I28+HssOJwdr6IYBaFHevlpxxCJYav1o/DHo8PdkVVJH1bO4/2YNI5PV
         HLHQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20221208; t=1682879040; x=1685471040;
        h=content-transfer-encoding:in-reply-to:from:references:cc:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=7ZrYwlCTAd6AYZjRwcv7nQgRqz/EYx/BTeMmQ+Vatb4=;
        b=WxjM+UzbJdxEhETm0Fq1C/qXlvpEKMa7qu8vBwXUe2bm2/P+N3nhWMuMgno0XuBJbx
         O3L+LzzAftXFSmrPqP0OAsUecLDYiCEOScz2dOSRwIGFVv5GU0uquSpRlVXnp2OjKuZE
         ZegoWzmTLp9h6/vpbInIKqWsBV09zfXZX6+EtJXxXI8C9nfOGz8auQrbaVvRNbrC3c/l
         cILEu6FELYhZtyDSvtqLgrMBNorbZXAZ3DzG6wBdwNxpIa5pMMx8rnkw1gl/d8xI6tOS
         tGueR3WkvoEOfnm+5HX6xhkA1StmW7PYlNLGdpOUmoOujFw0GbZ7H8TkyFyByyDUohls
         cumQ==
X-Gm-Message-State: AC+VfDwhmoBfIbwUUobsb9psKpLcXvbC9K1lbULuBLjZwI7p7L1oTt+4
	syspbZbFansEbiBfw2odJLbXVAXop9hF0g==
X-Google-Smtp-Source: ACHHUZ76UsqTFetWKdefnfhaHDCRnL32DrL2WeGkVYw/XfK0vKObW9ugji6Gwchb0THX/+Uu/hX9/g==
X-Received: by 2002:a05:6870:9182:b0:177:dfdb:63 with SMTP id b2-20020a056870918200b00177dfdb0063mr5417609oaf.44.1682879040117;
        Sun, 30 Apr 2023 11:24:00 -0700 (PDT)
Received: from [10.0.2.15] (cpe-70-114-247-242.austin.res.rr.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id i20-20020a4a8d94000000b0052a77e38722sm11918170ook.26.2023.04.30.11.23.59
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Sun, 30 Apr 2023 11:23:59 -0700 (PDT)
Message-ID: <517bc712-06cf-98c2-c799-eda3d2a9db36@gmail.com>
Date: Sun, 30 Apr 2023 13:13:09 -0500
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
To: Brandon Cheo Fusi <fusibrandon13@gmail.com>, marcel@holtmann.org
Cc: ell@lists.linux.dev
References: <20230428122025.117834-1-fusibrandon13@gmail.com>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20230428122025.117834-1-fusibrandon13@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi Brandon,

On 4/28/23 07:20, Brandon Cheo Fusi wrote:
> This patch allows ell/ell.h to be included in C++ code by removing
> 'only C' features. These comprise
> 
> i)  implicit casts from void* to other types which are now made
>      explicit
> ii) C99 Static array indices.

<snip>

>   bool l_icmp6_client_set_address(struct l_icmp6_client *client,
> -					const uint8_t addr[static 6]);
> +					const uint8_t addr[]);

You can't really do that because l_icmp6_client_set_address implementation 
doesn't do any NULL/size checking.  It assumes an array of 6+ bytes.  And that 
is sort of the whole point of using the 'static 6' syntax.

Maybe there's a way to come up with an alternative declaration, using 
'__attribute__ nonnull'?  Perhaps combined with using a pointer to an array?

>   uint32_t l_rtnl_set_mac(struct l_netlink *rtnl, int ifindex,
> -					const uint8_t addr[static 6],
> +					const uint8_t addr[],
>   					bool power_up,
>   					l_netlink_command_func_t cb,
>   					void *user_data,

Same comments here.

Regards,
-Denis
