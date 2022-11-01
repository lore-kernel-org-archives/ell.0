Received: from mail-oi1-f177.google.com (mail-oi1-f177.google.com [209.85.167.177])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9A6FB7C
	for <ell@lists.linux.dev>; Tue,  1 Nov 2022 14:05:00 +0000 (UTC)
Received: by mail-oi1-f177.google.com with SMTP id g10so15970412oif.10
        for <ell@lists.linux.dev>; Tue, 01 Nov 2022 07:05:00 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :from:to:cc:subject:date:message-id:reply-to;
        bh=WiPUltcqHBomisq7qVugMMD4lVYdDmRKfIM3IO4j/GA=;
        b=CO9LquISk2LjczJT0RuYNxLCXatDnFdT7YpYrp1jJX9BZIVnivnHEmUZpDJVFrTuf0
         5g3WDDahkxsB5SBR9XRlw+3GrmsIqkp8M2cCjH0iSVy/ViH+Als2ljzx9evfXWUYsgNt
         4FxZMYQXeFTRgCcjbfUMqeSIeqBEZDerawEV1H6eBLYT7sXCRB6yoWxNv0aKAywt33P7
         NWvhCDeEc7ZNYy2iRZF/fO4rjy3A5e7H7A6dSUiFKMKOC4lOke+NE7sXqSD8zgqvPgW5
         2TF56f23lpR/7AucG03jKgsQZ1VLNcTYt8Lc987B/60/oDv1AEdw8pmiGYDGdrVhL1XK
         /EcQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=WiPUltcqHBomisq7qVugMMD4lVYdDmRKfIM3IO4j/GA=;
        b=VRyRzFQ0CTjX7YBZeJfeK1AQydmxGker899UBToj/0QPUzcVRF+eU3qShMYuyi9RYA
         wElVKduZ7y75xHz4Z4HA1jhomkzxMAvMI8Y39RAHv51hADoluFQGfguuFR41lLNoa3BT
         4PqbuCT3kARiekEkF4dp5OGq9Mjq0ZO5DK6FwdXeAM6E5S6P6LwNBTgdMxu6J9ZxLcOK
         dEv0M/YaW8YWhaaS0d7Do6eJV44bsQrzrfLhXUS2rbNSW7DXimKmz5/hbS//ka21/Zf7
         EzlfoPlk6IoMQZ4EfHvDV3xpevlLi28YjB7PyLe8BZ/+kZa7xSZeNd2hx8OVygCy4JvG
         j6Hg==
X-Gm-Message-State: ACrzQf1wRd44VUAdVQJLLf8gqkt/R4HG0YI4CmJfh+dMmD3XWxbPO0jF
	wg8xm5IoW+uAaKOING/aT2g=
X-Google-Smtp-Source: AMsMyM5AB+yOGhvoBEpMkssPnB03RqZpkrxhdyF1vnBYws4uw6lcW7d28setAx7X/pyAP1t8ccUxow==
X-Received: by 2002:aca:dbd5:0:b0:35a:13a4:c1e3 with SMTP id s204-20020acadbd5000000b0035a13a4c1e3mr101225oig.200.1667311499690;
        Tue, 01 Nov 2022 07:04:59 -0700 (PDT)
Received: from [10.0.2.15] (cpe-70-114-247-242.austin.res.rr.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id q10-20020a4aa88a000000b0049bdee12662sm1207805oom.6.2022.11.01.07.04.58
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Tue, 01 Nov 2022 07:04:58 -0700 (PDT)
Message-ID: <a1b6179d-4472-1924-65f1-e49631972bf0@gmail.com>
Date: Tue, 1 Nov 2022 09:04:51 -0500
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:91.0) Gecko/20100101
 Thunderbird/91.11.0
Subject: Re: [PATCH 2/4] cert: Check validity dates in l_certchain_verify
Content-Language: en-US
To: Andrew Zaborowski <andrew.zaborowski@intel.com>, ell@lists.linux.dev
References: <20221031105342.2660357-1-andrew.zaborowski@intel.com>
 <20221031105342.2660357-2-andrew.zaborowski@intel.com>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20221031105342.2660357-2-andrew.zaborowski@intel.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

On 10/31/22 05:53, Andrew Zaborowski wrote:
> Check the validity start and end dates of every certificate in the chain
> being verified (must all be valid) and every trusted CA certificate
> (ignore invalid ones, use the valid ones if any left).  The dates are
> checked against current CLOCK_REALTIME value.  There may be use cases
> for verifying a certificate chain without looking at the dates at all,
> such as when the system clock hasn't been initialized in early boot and
> that can be added if there's an actual user for that.  Until now we've
> almost fully relied on the kernel to do all the verification and
> consistency checks on the certificates and the kernel does not look at
> validity dates.
> 
> Do these checks only in l_certchain_verify rather than directly in
> l_cert_load_container_file() or l_pem_load_certificate_chain_from_data()
> because 1. users may want to parse and display information about expired
> certificates for a UI.  2. l_certchain_verify also returns a debug error
> string which is going to be very helpful in diagnosing user issues from
> logs, unlike the loader functions.  3. in some usages there may be a
> longer periods of time between certchain loading, CA certificate loading
> and/or verifying the chain against the CAs, and we mainly care about
> them being valid at the time of the verification.
> ---
>   ell/cert.c | 159 ++++++++++++++++++++++++++++++++++++++++++-----------
>   1 file changed, 126 insertions(+), 33 deletions(-)

<snip>

> @@ -655,22 +684,81 @@ LIB_EXPORT bool l_certchain_verify(struct l_certchain *chain,
>   	struct l_key *prev_key = NULL;
>   	int verified = 0;
>   	int ca_match = 0;
> -	int i = 0;
> +	int i;
>   	static char error_buf[200];

I bumped this to 1024 since gcc was complaining:
ell/cert.c: In function 'l_certchain_verify':
ell/cert.c:865:30: error: '%s' directive output may be truncated writing up to 
99 bytes into a region of size between 47 and 166 [-Werror=format-truncation=]
   865 |                 RETURN_ERROR("Linking certificate %i / %i failed, %s%s",
       |                              ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   866 |                                 verified + 1, total, str1, str2);
       |                                                            ~~~~
ell/cert.c:672:64: note: in definition of macro 'RETURN_ERROR'
   672 |                     snprintf(error_buf, sizeof(error_buf), msg, ## args); \
       |                                                            ^~~

ell/cert.c:865:69: note: format string is defined here
   865 |               RETURN_ERROR("Linking certificate %i / %i failed, %s%s",
       |                                                                   ^~

ell/cert.c:672:25: note: 'snprintf' output between 35 and 253 bytes into a 
destination of size 200
   672 |                         snprintf(error_buf, sizeof(error_buf), msg, ## 
args); \
       | 
^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ell/cert.c:865:17: note: in expansion of macro 'RETURN_ERROR'
   865 |                 RETURN_ERROR("Linking certificate %i / %i failed, %s%s",
       |                 ^~~~~~~~~~~~

> +	int total = 0;
> +	uint64_t now;
> +	_auto_(l_free) struct l_cert **ca_certs_valid = NULL;
> +	int ca_certs_total_count = 0;
> +	int ca_certs_valid_count = 0;
>   

All 4 applied, thanks.

Regards,
-Denis
