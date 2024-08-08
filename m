Received: from mail-oa1-f44.google.com (mail-oa1-f44.google.com [209.85.160.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2441218E778
	for <ell@lists.linux.dev>; Thu,  8 Aug 2024 14:19:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.160.44
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1723126745; cv=none; b=ZFZhDxDNURRlzThtm73Xj9tObvWK/qtE0LIcnYAnFBx7d3e3FoAkpBuwV2LVn8T0vp6LJyClYC2EpRYM83d6TG4CsD8mzcbIUvpJQTcMGI1z6joFWoLruVyCcQhWRdcj9IwE6eg/0pgpOW1DSn4HUiMJjt1B+C5JkmGFiXkFnAg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1723126745; c=relaxed/simple;
	bh=IJ99y8ZNndVDvsyvcPVhQH60tofm+JcxTZ15v9oBD7s=;
	h=Message-ID:Date:MIME-Version:Subject:To:References:From:
	 In-Reply-To:Content-Type; b=a1r+n/BSQdAWB+JtWDJHenKdsWpz1GaO9LJDq7dV2lHLpGGHTI5ePP8Bs1AsPCZGsR6HcSwxl+y05mFkGY4v7wo7wATvlHcjKCY5/xhZBOzZvTwg7fNc+Yt8SBYW2zNaDpvJ+dylz0NmmbVuPdglFLRqrCUcNSECpr3rUs+FHSc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=d4cgeawy; arc=none smtp.client-ip=209.85.160.44
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="d4cgeawy"
Received: by mail-oa1-f44.google.com with SMTP id 586e51a60fabf-260f033fda3so646832fac.3
        for <ell@lists.linux.dev>; Thu, 08 Aug 2024 07:19:02 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1723126742; x=1723731542; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id:from
         :to:cc:subject:date:message-id:reply-to;
        bh=9kHZh+reGiRh1OhSS43w0LRsL4aOBt0Mmgu8aocVNV8=;
        b=d4cgeawymwnRpYcs4d8cqNsEOEOFxnsf1qzUY8gdW5ZQt3iPQTyz1G7mOE2SoaC2BS
         F8ivQpFrw3fbW2ZC2XrU5TB2WZL+nK600hNtyZOO9J+89X56SHJdNrRHHSpcO9m5LKeS
         1UUqIuN5nLq9QOE8LOSjvKhwvE1CXwCKz9n9ZkOeg0KVoS5WfCWdUwc4bs+gBmEdw/bz
         12gqSRtJh1mpi6jh+MePJOpGcqIR25QdzGx0EQcE7XCakDFjdlsZ1ybMbSf4ipJg9jhX
         zfY5+vWgfCX2+/L4Wpg/aJ+3m/rgpcqHwp2OnUIlTFWipt1J+UbxGd0cM9SZUmc9CQVk
         LUbg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1723126742; x=1723731542;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=9kHZh+reGiRh1OhSS43w0LRsL4aOBt0Mmgu8aocVNV8=;
        b=ZtbZP+IlGL6v/Z45B7z1vFE1mZP7nhQfwUBlNP7MIsIWQA+8eeaSSQ5TdYQb/Ojl0N
         Z/FOLwkiR8+7wFOx0Qx3A71N4H7uAHRVwDZZfF31eFmx2HXQLsMEECSiLQOMISlhz9it
         YiSGBN00MOgyGp19xs5xwKm1L6LZEZlJkUfMZcNzBLnoQdv0kmc2suYvgYc7MXZ2rUDv
         hwKe/pi3vsfle84H5cXRdrLZMjT2GeZcNmswYPYPAe30v18NeIJW9WLhI1SLvvLsvs5t
         P7rvMbShNwSS8Q6mQtXJHDQ63LZ49KvAjXNpB1IxKXu3FSabGRoIRwaJ6kxIb+BiseCg
         +PgQ==
X-Forwarded-Encrypted: i=1; AJvYcCUS4rzUekDaa9F9Gu+33ND+mkcpipghpODa5XtdRapnLaDCVQq7zu61aYxW4mm2Zo6CFviJWbhMhnQjwhNKb9nZCiel
X-Gm-Message-State: AOJu0YzYe4eNkFMY1AUIrO+PZQ3bydHzQhEZkNTsX9d2ha0FPIhFxxsl
	KqDwtCQieds9aPRQPpAdII7ZYZOFeQvBamXn8WTcXvzFqt2vXQ8B
X-Google-Smtp-Source: AGHT+IHd3NLBHtVW//mh3uyObK4PC/efZs1pFkub+1QJCUYnQUo0XS3KyGA1+3MSOuMJqRuDVKOSLQ==
X-Received: by 2002:a05:6870:b015:b0:25e:2a65:59cf with SMTP id 586e51a60fabf-2692b69dbd3mr2080676fac.22.1723126742030;
        Thu, 08 Aug 2024 07:19:02 -0700 (PDT)
Received: from [192.168.1.22] (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id 46e09a7af769-70a3a7767f7sm5454015a34.80.2024.08.08.07.19.01
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Thu, 08 Aug 2024 07:19:01 -0700 (PDT)
Message-ID: <a2d889d2-a859-4600-99ed-d51ed61bca13@gmail.com>
Date: Thu, 8 Aug 2024 09:19:00 -0500
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH 2/2] dbus: add l_dbus_object_set_data()
To: James Prestwood <prestwoj@gmail.com>, ell@lists.linux.dev
References: <20240807175943.170002-1-prestwoj@gmail.com>
 <20240807175943.170002-2-prestwoj@gmail.com>
Content-Language: en-US
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20240807175943.170002-2-prestwoj@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi James,

On 8/7/24 12:59 PM, James Prestwood wrote:
> Modifies the user data of an existing DBus object.
> ---
>   ell/dbus.c  | 13 +++++++++++++
>   ell/dbus.h  |  2 ++
>   ell/ell.sym |  1 +
>   3 files changed, 16 insertions(+)
> 

<snip>

> diff --git a/ell/ell.sym b/ell/ell.sym
> index 0dad73f..aafc0a4 100644
> --- a/ell/ell.sym
> +++ b/ell/ell.sym
> @@ -225,6 +225,7 @@ global:
>   	l_dbus_object_add_interface;
>   	l_dbus_object_remove_interface;
>   	l_dbus_object_get_data;
> +        l_dbus_object_set_data;
>   	l_dbus_object_manager_enable;
>   	l_dbus_add_disconnect_watch;
>   	l_dbus_add_service_watch;

Seems we use tabs here, not spaces.  I fixed that and applied both.  Thanks.

Regards,
-Denis
