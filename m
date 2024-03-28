Received: from mail-ot1-f54.google.com (mail-ot1-f54.google.com [209.85.210.54])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BE74A20DC4
	for <ell@lists.linux.dev>; Thu, 28 Mar 2024 22:31:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.54
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1711665116; cv=none; b=oTju7HGMmoD68wEmi77btLDLcoCSI36KxpvYi+KOiMHQgZu4Ay9AEAsN7v2jitJnCojhAx9UBYWVo/HWXRoi1nHrnddrjj4ksvFOdqUvpYDMT40nubys1Yi4SvFhFbXfvQZpLR5yjI+7THkavxGahN/+vTo5zzujzkMSJhC4zW4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1711665116; c=relaxed/simple;
	bh=ThQdp0GGZak16futbDFSQgsUpKKDmw2t/znMtSyJqZM=;
	h=Message-ID:Date:MIME-Version:Subject:To:References:From:
	 In-Reply-To:Content-Type; b=CVXd54Kg7xWyefS7KM5PFE4Birmy2x0wsvU9WNxVqzqlfU6MRUSsjIEf86kw16J9RRmVYoOs3yUlE4mo5TeZN7Ul2ec568aJokOMCILuvB4f6XyG23I8XEEJiwUDlxYIwTCv0GXbldlH2hDeBdaCVC/pEUQ4urio1CA+FUCNhP4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=ky9l3t8t; arc=none smtp.client-ip=209.85.210.54
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ky9l3t8t"
Received: by mail-ot1-f54.google.com with SMTP id 46e09a7af769-6e6d063e88bso921334a34.3
        for <ell@lists.linux.dev>; Thu, 28 Mar 2024 15:31:54 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1711665114; x=1712269914; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :from:to:cc:subject:date:message-id:reply-to;
        bh=DJr4LJEfVbVgDK0Kzd/4WLM68eW66G2nd1DdZL1qjQ8=;
        b=ky9l3t8tAdgMeGIW158XG32QE1+8XDFmQwKeJDkEw++7/GpSpwKffaFvJJjj8D4bjq
         +T0nQUcRpv5oHpPEdUy1AYekKBc7cq4kFxuVZWBFwaHawAHLKpSV1wL6DSkAZaI3ecRx
         bQFWs/VLfwZMBvxcxpolvYfyqzKKTfz8GuURI5l+FZcmrezfPbR3gfhqUzAtuaHP4GHW
         MQOBEuK1f+kRsTbFtONrUpCSZabaphsg94bvmUk6eRYMiOZVtJJwK6kwCtrj/VpnoaOe
         H8S831yY1xF9n6cGq5l1EIf5N8mh4Wa5gajnThiBieELvEFusXZam5ZaYpGzfv6k5xW6
         GQpw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1711665114; x=1712269914;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=DJr4LJEfVbVgDK0Kzd/4WLM68eW66G2nd1DdZL1qjQ8=;
        b=Lf9HbMzB8DPZkBDTFKbQ3YDtBApd/sHFF1v5vd1wG42ztVnwxoDoUEz90PK+B9B7mp
         VG9UXJS5lwQliCotPeguVAmpXkxadHlHAWBHVf2eq00KIVgUYCRDdCXbMm1ImMCDHbEG
         qcH08kbZpxFUxRyqt08W6ovhy4I26Uk2EpzhGQ+4Ca20Wzg5e1z0edqwoRA2zqf7WCHl
         J+pIr/589YsUpXIpbBbc/8hR+JyRwNeN3ogdAYEy5fAaUTYQesTOKC55Z9uAh8/ObeKF
         1XbJNuOZLIxJim0SISf/smzaYJotML6EQqXcZaU2XSPr6DWC982JDb/qzDE6pFsBidUt
         6LgA==
X-Forwarded-Encrypted: i=1; AJvYcCU79MatuNIgdSM550DicCUz479JCqucCs4GvfuS0wZGK8BI0pTcByHgk4+4agS24Nih53/1wI55TBbixMqSBwygGuXk
X-Gm-Message-State: AOJu0Yy6n8/RwOK5gAqNbvW3bJcnpntWBzKgbU0BwHgDWNVCVIpbXlae
	wLA8MtJ8z0yvcQn1vLPmvIkwo1VtZDdPzlB8j0PTZepm4NVzTQwBtAQ53NeF
X-Google-Smtp-Source: AGHT+IEysBnEBehwRDUnJC7ycuFjXINXpVzLqOQne7y0zWe65PlOd4jRWzG5vW90t3/ZGrrlVptbog==
X-Received: by 2002:a05:6830:f8b:b0:6e6:aa83:8213 with SMTP id ez11-20020a0568300f8b00b006e6aa838213mr732801otb.15.1711665113760;
        Thu, 28 Mar 2024 15:31:53 -0700 (PDT)
Received: from [192.168.1.22] (070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id l12-20020a0568301d6c00b006e6e40cae43sm394572oti.73.2024.03.28.15.31.53
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Thu, 28 Mar 2024 15:31:53 -0700 (PDT)
Message-ID: <ca540900-42a8-49a9-b7b9-869ac802c874@gmail.com>
Date: Thu, 28 Mar 2024 17:31:52 -0500
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH] util: Add portable casting preprocessor macros.
Content-Language: en-US
To: Grant Erickson <gerickson@nuovations.com>, ell@lists.linux.dev
References: <20240328172546.123434-1-gerickson@nuovations.com>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20240328172546.123434-1-gerickson@nuovations.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi Grant,

On 3/28/24 12:25, Grant Erickson wrote:
> ELL itself is a pure C source-based project and is compiled as such.
> However, if ELL headers and interfaces end up getting integrated with
> and compiled in a C++ environment, certain assignments within ELL inline
> header functions may be flagged by the C++ compiler as errors or
> warnings.
> 
> The added casting preprocessor macros are generally useful across any
> source based that might want to leverage them from ELL. However, within
> ELL, they should be used in inline header functions where such functions
> may be consumed in either a C or C++ environment with a  towards
> L_PERMISSIVE_CAST where possible. Since L_PERMISSIVE_CAST is not a cast
> at all in C, it will not mask otherwise-legitimate warnings in that
> environment.
> ---
>   ell/util.h | 33 ++++++++++++++++++++++++++++-----
>   1 file changed, 28 insertions(+), 5 deletions(-)
> 

Applied, thanks.

Regards,
-Denis

