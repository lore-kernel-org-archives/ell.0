Received: from mail-oi1-f175.google.com (mail-oi1-f175.google.com [209.85.167.175])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EC6AB173
	for <ell@lists.linux.dev>; Mon, 20 Dec 2021 17:40:18 +0000 (UTC)
Received: by mail-oi1-f175.google.com with SMTP id p4so16846862oia.9
        for <ell@lists.linux.dev>; Mon, 20 Dec 2021 09:40:18 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=message-id:date:mime-version:user-agent:subject:content-language:to
         :cc:references:from:in-reply-to:content-transfer-encoding;
        bh=ZMbyKnyFNvToQUVkeG6wPaC1M5wPekou8tEOIEbnZsg=;
        b=pAcODMPW7qKyJDvM61jzxStkh0I2hWGAEJYN7saeAduG/OSLJLhejmEaQHastvsop1
         AZ/55TjUkBaXX3nbfdQyFwVO7/rnbSJQ6W4FW/YkwTVBJr7Zj6i8t7WoEsX1icmqp8KM
         OyrjKfe6T2chrBatLZK08t7agKuAiQCJY+1VFSBpR7JbIu4uVfqh0haVi1nSJTuN2eMG
         m4OmjGNUPUa2sNpuvZb3ONv840N2NZ8hXS29Pu4EvB9u6eq8QFDDG1VFMvp6uotg2yz5
         82V9gLKtEHk0HLUOZRQN8yr2Mhu10OZujzt08L0t3XQ57kKgWVTi3+Rn1YndT9FRzTId
         pD9w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:message-id:date:mime-version:user-agent:subject
         :content-language:to:cc:references:from:in-reply-to
         :content-transfer-encoding;
        bh=ZMbyKnyFNvToQUVkeG6wPaC1M5wPekou8tEOIEbnZsg=;
        b=gGqX+Dvc3ub2V0fVc6r9oP3zRQHbNZhF9TysoXQYxG0cokQY7dpBmUwgc9rw85zNr/
         qEHoI49rDKNYyvas+7j3bRtAwbxJBcVawaSLtbOknQCLQZ2wQZ2UYeAIfJu6UgoUWH5x
         SYuyzahi1fQeSH8MXZBe1Kj7eEivnov/DXL1CuJ+h1rCmFzQny4RzG4ntfV5UBviOYdk
         iqxx95PFfgHmAHS03uF9n3zvl4zBt3tIJhjuGv4AmElvuqmiUbQKA/T/3/A1hMuCKnuP
         kyZxlvHemexNfSXkEG5m9ZTLr6d3KISkgCtpoPdhcgfEA4XIRq2ALRKOTiFskg5y5XPZ
         dmQg==
X-Gm-Message-State: AOAM532Ak3xBS8ktaCydxW5DyRH+x0dCLpwZDSertDrpXWJXow1nb+TO
	DyjHaTIcqkrUA8Hi/nIWdTU=
X-Google-Smtp-Source: ABdhPJxvWGk8O5rWdq3BDRSaIytMAaeRvTpS5yDH2o+BmcjuECNQyDCbLxiD2sDuRYKq/ExoiHTMDw==
X-Received: by 2002:a05:6808:ecc:: with SMTP id q12mr35100oiv.122.1640022018161;
        Mon, 20 Dec 2021 09:40:18 -0800 (PST)
Received: from [10.0.2.15] ([136.32.93.51])
        by smtp.googlemail.com with ESMTPSA id j187sm3550565oih.5.2021.12.20.09.40.16
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Mon, 20 Dec 2021 09:40:17 -0800 (PST)
Message-ID: <22f8694d-5f26-89ff-421e-0f0582032765@gmail.com>
Date: Mon, 20 Dec 2021 11:29:09 -0600
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:91.0) Gecko/20100101
 Thunderbird/91.3.0
Subject: Re: [PATCH] README: Remove stray '@' from mailing list email
Content-Language: en-US
To: Ossama Othman <ossama.othman@gmail.com>, ell@lists.linux.dev
Cc: Ossama Othman <ossama.othman@intel.com>
References: <20211218042150.115073-1-ossama.othman@intel.com>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20211218042150.115073-1-ossama.othman@intel.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi Ossama,

On 12/17/21 22:21, Ossama Othman wrote:
> ---
>   README | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
> 

Applied, thanks.

Regards,
-Denis

