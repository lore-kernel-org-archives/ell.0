Received: from mail-oa1-f41.google.com (mail-oa1-f41.google.com [209.85.160.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6985A33CC
	for <ell@lists.linux.dev>; Mon, 18 Jul 2022 18:04:14 +0000 (UTC)
Received: by mail-oa1-f41.google.com with SMTP id 586e51a60fabf-10cf9f5b500so24673220fac.2
        for <ell@lists.linux.dev>; Mon, 18 Jul 2022 11:04:14 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=message-id:date:mime-version:user-agent:subject:content-language:to
         :cc:references:from:in-reply-to:content-transfer-encoding;
        bh=8wF1g2UW0EtX9r1cPJpojZnpgyWPol0IUU0iwFmbYSw=;
        b=hTC3W2ZmlxtZLp9EGmQAee7uhj70g48StxVi3a+gsIZuSS0gI7gci0hQMJLGodXVPO
         h1lIThWVtUMW8eHFrfZ7leqhRzFyhdlmG1wk7A9FoJKzK4F11aeomZtILPCT32NNvApU
         /FDSWtVbueaoitccBPy+8as/UyLuFLEzZgSidvYnf2mnk2OLak7cBNWAiGAfnHJDWUIw
         DNrztB8rY7QWHWBjP0ooz52Q6aVQNssLbd4QRPcLP+LFyF8uHrO5MM6CyIW65/sZi1PV
         qIMjAd/WyzC5jtaNZg+EqqQcjJw5pUpKPOdHyJ8UsPtxXgMvBd88DWtV0vUdy8mbfcKC
         YqEQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:message-id:date:mime-version:user-agent:subject
         :content-language:to:cc:references:from:in-reply-to
         :content-transfer-encoding;
        bh=8wF1g2UW0EtX9r1cPJpojZnpgyWPol0IUU0iwFmbYSw=;
        b=M4qpX5PwXvh9U1mMQbQDpKzx6n98a+oS5RIi3+RM5MIEUcVsNIWfKQQkb+ytxrQfaA
         ooeG0QUr888mj+FkevlEd+n9PER8HEoOqgngf3C97K2V8OTmsMipTBWJTQr4AFiubg+v
         g0c49MN1hfasTXBtuz5R1aYILEi4A0ofMnWERCy4zIS/bAck7dy1/9oKeq1C/3n3S01H
         jdHKYWbzClHo74ujlM7iFCpAuHug/4L/Duj9AK0mjudHQLvjh/Yi+VbOFtOq5jCaBrQ2
         I60gPRPNSezg9i+wByBIZ67gilM+xZtMPihy6lRhm/5i3bHxby9Q9LJGzVzAG+zzzNZw
         gSZQ==
X-Gm-Message-State: AJIora8uLLTdTF6i2/AmdTpzClyrP4zj2ruQkShwMV28gB1lV+U7Z2nT
	Vi14bHzXiKX36wOFbl5jFEn1GjCIl/U=
X-Google-Smtp-Source: AGRyM1u374iohKuQfffmcmjBfGmpMC5fQDGpDTEow5zyUBjDVM9l6OIUND03WNSJh0rI993rwm+JYQ==
X-Received: by 2002:a54:468a:0:b0:33a:3be2:8bd6 with SMTP id k10-20020a54468a000000b0033a3be28bd6mr10569573oic.280.1658167453406;
        Mon, 18 Jul 2022 11:04:13 -0700 (PDT)
Received: from [10.0.2.15] (216.106.68.145.reverse.socket.net. [216.106.68.145])
        by smtp.googlemail.com with ESMTPSA id cb1-20020a056830618100b00616c46f6daasm5326929otb.31.2022.07.18.11.04.12
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Mon, 18 Jul 2022 11:04:13 -0700 (PDT)
Message-ID: <e7579b3f-0b6c-6afe-1af7-6db46976151e@gmail.com>
Date: Mon, 18 Jul 2022 12:59:07 -0500
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:91.0) Gecko/20100101
 Thunderbird/91.11.0
Subject: Re: [PATCH 4/9] tls: Support peer certificates that use ECDSA
Content-Language: en-US
To: Mat Martineau <mathew.j.martineau@linux.intel.com>
Cc: ell@lists.linux.dev
References: <20220718160222.10634-1-denkenz@gmail.com>
 <20220718160222.10634-4-denkenz@gmail.com>
 <b26fe3bf-fb39-65c-cdbc-784ee4cdb4a@linux.intel.com>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <b26fe3bf-fb39-65c-cdbc-784ee4cdb4a@linux.intel.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

Hi Mat,

>      default:

Indeed.

> here to get it to build. Details below.
> 
>> +        TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
>> +                "Unknown public key type");
>> +        return;
>> +    }
>> +
>> +    if (!l_key_get_info(tls->peer_pubkey, format_type, checksum_type,
>> +                &tls->peer_pubkey_size, &dummy)) {
> 
> The ell (standalone, bootstrap-configure) build fails here with gcc12/Fedora36:
> 
> ell/tls.c:2061:14: error: 'checksum_type' may be used uninitialized 
> [-Werror=maybe-uninitialized]
> ell/tls.c:2061:14: error: 'format_type' may be used uninitialized 
> [-Werror=maybe-uninitialized]
> 
> Apparently gcc12 can't track that -Werror=switch-enum is in use in combination 
> with -Werror=maybe-uninitialized, and doesn't understand that the switch 
> statement above does guarantee initialization.
> 

GCC seems a bit silly here.  Not sure adding 'default:' is any better since we 
use these warnings defensively in case a new enumeration is added and not handled.

Anyhow, I fixed this slightly differently in v2 out shortly.  Thanks for testing.

Regards,
-Denis
