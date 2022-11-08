Received: from mail-oi1-f172.google.com (mail-oi1-f172.google.com [209.85.167.172])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3BBA68BE7
	for <ell@lists.linux.dev>; Tue,  8 Nov 2022 15:49:55 +0000 (UTC)
Received: by mail-oi1-f172.google.com with SMTP id s206so15940575oie.3
        for <ell@lists.linux.dev>; Tue, 08 Nov 2022 07:49:55 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :from:to:cc:subject:date:message-id:reply-to;
        bh=c6YXHjUXTtl3UuFuQ7gqA77dGITQHSAcg2pwXextM0I=;
        b=awpuiTiBdY04kl8/ocTXkVCn0sSMjb5V+2eWf+AIKBDaGmUyFT64Qi9CTPNOI1xO1W
         ENgUNnOul27qY9XnURYupsFSXM4X4SXD7QNGKLSlrr/HJ8eTjx44BkcrYfA7HiyRpftE
         xgwalusxYEFjBaDIY+K3n5HU/hRtFO0mVJijd+m0m/rI43yFIvOCoYjx/bn1LreHPite
         rzcoiePehr4MpRlJ+SBYeXjriTulWgA68bDob5tvO5JPupbTlOQQkMnAIe6cWRtG1A96
         1xBrbKc74tt32V6YrpVkiWVeZvUWqAhRFxK7Xrk83H22JdGXmuSqauvtWfZ16cDk9sgo
         i2VQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=c6YXHjUXTtl3UuFuQ7gqA77dGITQHSAcg2pwXextM0I=;
        b=d0TrWVwl0rGf9Tq/S6HJ5Vk7xaZ1tI2f+/Ulje1TkEfsYaFDz32VnlEothCT9vmzNo
         cEGCOsCVAyzOyZAJ/A4NSnhvvFRzl0c2B8vLlLDnf3EEVFfVbm+kELteSYSKWRc3EYXC
         kmh57uj9aQ4PtutE6s5EIyZhNIeRmRpA+R/B1lBRE/ry0X62/lc9FZFjLqUMBJQQpbp5
         MZ98hyire80Pc6jFksMcXJQE1g0eR5FGNMWpERn1Ta62E7x8A5ookalC/GR3wdSByhmZ
         HvW4Ia6n948dg3R+6fNi6u+7dLMtIiI0jr20xLbgNTjnXnGRW8orT8/o8v1BEJtaFUrw
         a5mw==
X-Gm-Message-State: ANoB5pkbP7mKVPHYaNud4YqXuwluWVJi7KR0ZzCyTLMeWBOTpcom4mGw
	A2fTvXmOHZR8+Ck1tsh8Ccg=
X-Google-Smtp-Source: AA0mqf5U+EbmSRK1Av2QqLdsQOL/aFrZTdc+drlgsHT7GCDzI1hhlM8xWeiVTHYWRSTBzpnMel+ilQ==
X-Received: by 2002:a05:6808:23c1:b0:35a:83c6:e6bd with SMTP id bq1-20020a05680823c100b0035a83c6e6bdmr6525832oib.33.1667922594372;
        Tue, 08 Nov 2022 07:49:54 -0800 (PST)
Received: from [10.0.2.15] (cpe-70-114-247-242.austin.res.rr.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id s13-20020a056870610d00b0011f22e74d5fsm4777573oae.20.2022.11.08.07.49.53
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Tue, 08 Nov 2022 07:49:53 -0800 (PST)
Message-ID: <72e1944f-9a16-a010-20ef-5c4788ed97f2@gmail.com>
Date: Tue, 8 Nov 2022 09:49:52 -0600
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:91.0) Gecko/20100101
 Thunderbird/91.11.0
Subject: Re: [PATCH 1/3] tls: Refactor session storage for server mode
Content-Language: en-US
To: Andrew Zaborowski <andrew.zaborowski@intel.com>, ell@lists.linux.dev
References: <20221107113012.328918-1-andrew.zaborowski@intel.com>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20221107113012.328918-1-andrew.zaborowski@intel.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi Andrew,

On 11/7/22 05:30, Andrew Zaborowski wrote:
> In TLS server mode we will need to store multiple session states in the
> session cache instead of only one like on the client.  While the
> l_tls_set_session_cache() method is new use to opportunity to make
> incompatible changes: add the cache size limit parameter and strip "TLS"
> prefix from the setting names in the cache's l_settings object since the
> group name can include this part of the context without duplicating it
> across settings.  Rename the group_name parameter to group_prefix since
> in server mode there will be a settings group per session cached so that
> we can use identical keys for each session.  When removing a session
> remove the whole group rather than individual settings potentially
> leaving an empty group.  Factor out the session loading code common to
> client and server into a function.  When saving a server side session
> state skip the SessionID setting since the session ID is in the group
> name as the primary index.  Add a boolean parameter to
> tls_forget_cached_session() to suppress the update_cb callback if
> needed, to allow the caller to make a single callback after multiple
> changes are made in the session cache instead of calling back after each
> individual change.
> ---
>   ell/tls-private.h |   3 +-
>   ell/tls.c         | 228 ++++++++++++++++++++++++++--------------------
>   ell/tls.h         |   3 +-
>   3 files changed, 133 insertions(+), 101 deletions(-)
> 

All applied, thanks.

Regards,
-Denis

