Received: from mail-oi1-f182.google.com (mail-oi1-f182.google.com [209.85.167.182])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EB7BC173
	for <ell@lists.linux.dev>; Mon, 20 Dec 2021 17:42:21 +0000 (UTC)
Received: by mail-oi1-f182.google.com with SMTP id bf8so16922136oib.6
        for <ell@lists.linux.dev>; Mon, 20 Dec 2021 09:42:21 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=message-id:date:mime-version:user-agent:subject:content-language:to
         :cc:references:from:in-reply-to:content-transfer-encoding;
        bh=kODcMXGXnWNaUXk4f1eVcMirJVDlLLJ/E80RvLBnDi4=;
        b=OozY98JFwMZGl1aDY2h5iMru7la9o7/uqXoo16svEqT1IM+GjFJgexNq5aOQaqxq2A
         1RjE+W/04GnCdChSTLPlIA81+9F19kI3uJZERrbkZpks5Y9jkRZ369PBRARv6Lp5Aph+
         LTJrtIs6xuZ/cY8kPegZ7YphAkBhDq5RX1rJ6NaQtkMVi9RH7sHfaYt4SutDU3NM+4a5
         icv++zNSRWCEFSPGZQP0OsA7PlkBY/R/MKYDRFiYHWkuGQy0vYlcbigYL+giwN1bNSxa
         TbwUkAomcLDkX1nRkCWnE7aBCTL8ULc3cOI/AwQtrzlfd/Kt/eoPzPPT2YJlDKzPL7NH
         k/Tw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:message-id:date:mime-version:user-agent:subject
         :content-language:to:cc:references:from:in-reply-to
         :content-transfer-encoding;
        bh=kODcMXGXnWNaUXk4f1eVcMirJVDlLLJ/E80RvLBnDi4=;
        b=2fsQ+/6B0VW9b/l8L6FExKC0oHQ1dsLZIzDH/IPeJQ6Ruc0iDIyrTbEsfloaaPcf8l
         Fu/6O9dULRyJcrDpWbJzwT84FHCO+sqjDuAnvGLwpMvtY6OalI0ycG2Ea5A/YY6RjQe1
         nojEVBO2du/jbWSNlbLeeZTusSclaOyW4qme1JPborW7pTepwyN5VMtSHFwEZDxHazGq
         gkSnatnjv5SasTLrRQ7gWBmHt+W3hzMDzxbGc7/W5uL/jUDZ7NDJQa8AotbJg+FztcNp
         nLC0vIjAz49jw4D6Xio8b/EFYo3mOZr0Q3bYYBF74IzUVVxuMta3GMdt/+pp9mg4rNSG
         7Thg==
X-Gm-Message-State: AOAM5323b+LlgxwTiXK8KmNTC+O14d3KLOOAkgCx7CMapdJxEsMUPf4q
	jeJTYEoxiOrz7CCExdH2aaCDMKtcDmo=
X-Google-Smtp-Source: ABdhPJzq33KZjCPVR8jsd28lChjY1t9608YraSlcyq2/+4WBh+tRSFTMpYC17ZtYgxPsCqKa8C5XUA==
X-Received: by 2002:a05:6808:1381:: with SMTP id c1mr6456oiw.129.1640022141178;
        Mon, 20 Dec 2021 09:42:21 -0800 (PST)
Received: from [10.0.2.15] ([136.32.93.51])
        by smtp.googlemail.com with ESMTPSA id b1sm3294819otj.5.2021.12.20.09.42.20
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Mon, 20 Dec 2021 09:42:20 -0800 (PST)
Message-ID: <8db36b87-b96a-a0bf-d24b-b7ea2afab01f@gmail.com>
Date: Mon, 20 Dec 2021 11:31:05 -0600
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:91.0) Gecko/20100101
 Thunderbird/91.3.0
Subject: Re: [PATCH 0/3] Fix Valgrind errors
Content-Language: en-US
To: Ossama Othman <ossama.othman@gmail.com>, ell@lists.linux.dev
Cc: Ossama Othman <ossama.othman@intel.com>
References: <20211218041431.114737-1-ossama.othman@intel.com>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20211218041431.114737-1-ossama.othman@intel.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi Ossama,

On 12/17/21 22:14, Ossama Othman wrote:
> Running the ELL test suite through Valgrind triggers a few errors.
> This set of patches addresses three of those errors.
> 
> Ossama Othman (3):
>    dhcp-server: Fix memory leak.
>    unit: Free l_uintset when done.
>    unit: Initialize variables prior to use
> 

All applied, thanks.

Regards,
-Denis

