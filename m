Received: from mail-oi1-f174.google.com (mail-oi1-f174.google.com [209.85.167.174])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D48611DFC1
	for <ell@lists.linux.dev>; Mon, 18 Mar 2024 14:31:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.174
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1710772315; cv=none; b=Dsk+zNCob/b9pb/eNef0Tc84xvmq7jQGSt44xm0h71rz6ZAM2GA/fqIcVj7fCknwc9LQ49WCkpdeHxN9dl+S0FjRLqCjv+c0A3vDo481TKnje0ba186eGamQRc61gpWXdy0Z1Zu40nyIJAM92o5XpnvkbHnsraOKgGM0sh8OUi8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1710772315; c=relaxed/simple;
	bh=01LNUYpp0vkDO8vQ5OhJogq17xYH/X+8IRKNXBIl50E=;
	h=Message-ID:Date:MIME-Version:Subject:To:References:From:
	 In-Reply-To:Content-Type; b=cWaWv/Cnp97mGSzEOhRdUx8V3W+M4dRfX/0P8z6bH1xk9JDUBGvlE/1tO6bXdxpfMoP2kpkJYkgYhYGCBaGkP39n08js09JfW46h4JOOnR1/yFqJDDwjWnZDUOUtOBEDsq9fEE5ddE3IOOreZ9P0IwrGuDeX03jKGfSzJ3qWjdo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=liLi/lv2; arc=none smtp.client-ip=209.85.167.174
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="liLi/lv2"
Received: by mail-oi1-f174.google.com with SMTP id 5614622812f47-3c38335ecd8so1162172b6e.0
        for <ell@lists.linux.dev>; Mon, 18 Mar 2024 07:31:53 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1710772313; x=1711377113; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :from:to:cc:subject:date:message-id:reply-to;
        bh=QKfvx/gBNQ+tn0OLzIY5+QkcVEL0ZgyMTx+iwlFfxIg=;
        b=liLi/lv2rsNT+IXRuCxkjWqlumck3g/irHeu/CjQzrJY7bODGyv9AvNCh5wNprAYGM
         pFgIimquQtxEmyAPdpCVlPXvohJbu7+vgtf1i2iFltcjV/npU8P32VI8ywJRrMkzrUiL
         +h9G8B0hnXZlu3yjqD7ktnYCvEYJrZtjmgzh3HeZgUYsNH0CPVzU2pC4wTJp1EGgI8BU
         USqetXpevzc1M2WfMbFo/H+4DNI7PX0yMI6qCSa0ixoXDcTZ2B2WJDvPV01geSrmMtk/
         sBog6QGWizVqLT8kJP5+S6DBlI8xGbs3xKdOORRur6fbViTwbtDTLnUfyx8NSbNvlFYA
         eiIg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1710772313; x=1711377113;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=QKfvx/gBNQ+tn0OLzIY5+QkcVEL0ZgyMTx+iwlFfxIg=;
        b=o2dykhKwi6wiIm3DvwXK/L0T3HIRgbKWB3vGuucQuTRjFEbxJkknZisoaTvpM9oB52
         zgFUu42NG1dsoEmCFalMpeKzaRwyorHX4JQULvX9GjcWxJvA0e4dWtLrQVa5HpJsMxTa
         VMpsjnGwxUy4lg22wewqApI/6WXcvjzSNroIg6mTzEZoUu9aX56WUFWaaso/bDrzTzib
         TsoyfkkeHPFwNYMzIVCk9sSZ6SKowaa1BM0ZKa5NEAOihHUZ4IWZrILQ+9cYsa+F8k7Q
         xl24wvBVTXg0Co9sotIDbxD4gkRuftL9KGZqLbbTDEGA+HKhzeoXlP9xcVPptZZqfLjw
         v2nQ==
X-Forwarded-Encrypted: i=1; AJvYcCWOZQknVkolycE2eBYl980z4DYf5qgKDX4DrMTUiCfWBGC+HIjzgl5VAV2NOtKyNS7ODE7zAc/oGLHhSw9zQE3PnAqb
X-Gm-Message-State: AOJu0YzSTTlv1emar+0zczEos8wSivPIZHtpH6aZHzch78I74UijZ8Jt
	4JK8MXml33QgyBtOAAt4fmErC8tvviV2UEj/khNxnbQUdaw4k0l9
X-Google-Smtp-Source: AGHT+IEB8TGpyxZTtsCJhj2KPKxC3bD1JVfIHzjslJN2qUvXlKSCOq2WxKMzRLcvZLeW2PeXzeIdBQ==
X-Received: by 2002:a05:6808:1396:b0:3c3:758d:4c56 with SMTP id c22-20020a056808139600b003c3758d4c56mr12409005oiw.43.1710772312866;
        Mon, 18 Mar 2024 07:31:52 -0700 (PDT)
Received: from [192.168.1.22] (070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id z5-20020a056808028500b003c384638dcfsm606368oic.18.2024.03.18.07.31.51
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Mon, 18 Mar 2024 07:31:52 -0700 (PDT)
Message-ID: <d69b0021-9d5b-4e62-82c9-e2d3a361b7de@gmail.com>
Date: Mon, 18 Mar 2024 09:31:50 -0500
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH 1/2] ecc: add l_ecc_scalar_clone
Content-Language: en-US
To: James Prestwood <prestwoj@gmail.com>, ell@lists.linux.dev
References: <20240313164425.690572-1-prestwoj@gmail.com>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20240313164425.690572-1-prestwoj@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi James,

On 3/13/24 11:44, James Prestwood wrote:
> ---
>   ell/ecc.c   | 8 ++++++++
>   ell/ecc.h   | 1 +
>   ell/ell.sym | 1 +
>   3 files changed, 10 insertions(+)

All applied, thanks.

Regards,
-Denis

