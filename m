Received: from mail-oi1-f175.google.com (mail-oi1-f175.google.com [209.85.167.175])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0FF471C3A
	for <ell@lists.linux.dev>; Fri,  1 Jul 2022 15:21:46 +0000 (UTC)
Received: by mail-oi1-f175.google.com with SMTP id w193so3941423oie.5
        for <ell@lists.linux.dev>; Fri, 01 Jul 2022 08:21:46 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=message-id:date:mime-version:user-agent:subject:content-language:to
         :references:from:in-reply-to:content-transfer-encoding;
        bh=C2ajNJ2OaCtvfcMYPSAGuga3DZ/fyB68ysZ9YBr9RxE=;
        b=ASvNeJHalZoFZqGg07C5opLIUUsudmPhWpsM1revRlSh8/780siHnKPOUkfaip+iXa
         bFv6q1trN3qQ0wWikXcDiUBIQLQcqav3HlVSKeWpt1w1N/dhghgGAvZkXZtmZhugsTp9
         yVkV6WsnR9odgvcuFBYVM8OsNoFdLUsosYut+VLGH+3kU/i5kBNPTzdl0fmHI5Up5dt6
         aOJDplwY8ROipOiMNOprcNANS7CFEJ/3iPx5UUpuvZGwL7IjxFofkTB6lkH9CpTH5PY7
         EwWjtyRWbsupnxk5Ld2mzSt9bwlMDHYuvo4otDI7XHWE+OFNJIJlpQUxpzAS4jGGK/a7
         LdCw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:message-id:date:mime-version:user-agent:subject
         :content-language:to:references:from:in-reply-to
         :content-transfer-encoding;
        bh=C2ajNJ2OaCtvfcMYPSAGuga3DZ/fyB68ysZ9YBr9RxE=;
        b=SbH7XQIvw+T9W0XiGYbbv+AfCOKC9Uw+c2NWCpVflLt5kqqhgHSDuSsqi2T5+MElk6
         Hn+ucf9SGwP4wXU1Hm9C2ci6TSZDPu6KRH4ZJ50UbinaDeUYVGOgJ5ROaY9Sii6jM9wW
         tXpJjHoSAMiwT6RE86bry2o7qmkVGW/ZSYwrkhiqYfss7Qe2HEbdLyRt8pmp9KE866wl
         4smlSQMWJjw5QdjBgEPyKXfIO33uCxLHRePZu37xbhIVuupqvAu5OAfWn3mblVH8qj/r
         0DbEIJl//iJcXY4fYypOgQqvAy6bVLhmiu7+EuFXVj+gYBx2xhmyf38Unfj9homoNlqw
         8EOQ==
X-Gm-Message-State: AJIora9xNGycQ103hi+5lTn3XbIvR9BNkv9Aln1pBqMm20sNEuGlF5vF
	OKyaPbPG4HzpsTgnOisxNIU=
X-Google-Smtp-Source: AGRyM1up4vlFGeIShwjHtEvJtFKGL3k6+g1ClLkMQsjBUOpUJRInTsRFjVjo/4TumcRuy80b2B4Xuw==
X-Received: by 2002:a05:6808:1a13:b0:335:870b:324e with SMTP id bk19-20020a0568081a1300b00335870b324emr10100947oib.297.1656688906098;
        Fri, 01 Jul 2022 08:21:46 -0700 (PDT)
Received: from [10.0.2.15] (cpe-70-114-247-242.austin.res.rr.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id q30-20020a056808201e00b003351d035f77sm1759507oiw.47.2022.07.01.08.21.45
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Fri, 01 Jul 2022 08:21:45 -0700 (PDT)
Message-ID: <670bbd3a-2d83-85ca-477e-b0c18054d551@gmail.com>
Date: Fri, 1 Jul 2022 10:11:30 -0500
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:91.0) Gecko/20100101
 Thunderbird/91.3.0
Subject: Re: [PATCH 1/4] dhcp: Set lease->bound_time before emitting event
Content-Language: en-US
To: Andrew Zaborowski <andrew.zaborowski@intel.com>, ell@lists.linux.dev
References: <20220701133237.2887854-1-andrew.zaborowski@intel.com>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20220701133237.2887854-1-andrew.zaborowski@intel.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi Andrew,

On 7/1/22 08:32, Andrew Zaborowski wrote:
> The event handler for L_DHCP_CLIENT_EVENT_LEASE_OBTAINED/RENEWED will
> want to use the new lease->bound_time value for expiry time calculation
> to we need to set it before we emit the events in the DHCP ACK handler.
> ---
>   ell/dhcp.c | 3 +--
>   1 file changed, 1 insertion(+), 2 deletions(-)
> 

All applied, thanks.

Regards,
-Denis

