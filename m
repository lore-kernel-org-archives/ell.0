Received: from mail-ot1-f43.google.com (mail-ot1-f43.google.com [209.85.210.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7A5B31AA3C5
	for <ell@lists.linux.dev>; Tue, 30 Jul 2024 19:09:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.43
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1722366553; cv=none; b=q2MMix2GpZBtF3yYx20MQnLJWY6h1c6oKIYDXBY7JwImHN2Z2Zb0rf7J5tbyABw+jz5V/vozP0JeB30Z2tt0/6zoVS9DNPn5fuCBbgVRC/YQS00Oi6wLUpm2Gd2DQV7ivLd9ZOix9gu6UuqwzjaMiCnHFkGEmfuM4rMn+Ugapig=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1722366553; c=relaxed/simple;
	bh=NKgUCH1ytem1JaZbMSabl9znPJBOiqdHiAPBy1wkBOU=;
	h=Message-ID:Date:MIME-Version:Subject:To:References:From:
	 In-Reply-To:Content-Type; b=pl1bBHorTHwjOUfq7zTO2tgxeyHpbt/RhVATTY927Z/oibvgongyACfsXinEwAnuI42V38FOLP4Nro8MpXnmzkCem3OB6ZqaO+YLaciYicwLBFz0AudJItKRagzLsKSoe7vYVFheia+z/apQXCVNL/99FoJX+6lfpGsqnh8Ia9w=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=cxE3QRF4; arc=none smtp.client-ip=209.85.210.43
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="cxE3QRF4"
Received: by mail-ot1-f43.google.com with SMTP id 46e09a7af769-70940c9657dso2335401a34.1
        for <ell@lists.linux.dev>; Tue, 30 Jul 2024 12:09:12 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1722366551; x=1722971351; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id:from
         :to:cc:subject:date:message-id:reply-to;
        bh=dWsT9YoFylf130tQOWhbGbsDXMRP8B+yQoLyTdBIhC4=;
        b=cxE3QRF4q6Iik2geAS4M6drRLm/YOGX+dyZz17HmyEpSETlWtYOr/COCv2gOtwVbez
         mXbJcnTeoeQUUqU69VR/1EseAIMYQ2B7RRJUxJPO1gvyjsu3A0iDjO/zbBfpYh/e38eS
         CCoXkRsrkCmzS5XKq83msVjHWw7JCecUVoFtufwPXt+rYX5IIQRX/ojcoUvBHNAe8VkU
         DGrREwTriIhf+lOO60wESC1V1wwKp3eIQOrD14qWXDaJUuGuMj0oMw8swVkcy3E0WHcy
         N2j0+tkPztDO4l8iJxseWSmwXyklZ669RGg91uqRFhZ7lEYUbovqQ39RHjCD2w5ZpQz3
         rkuw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1722366551; x=1722971351;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=dWsT9YoFylf130tQOWhbGbsDXMRP8B+yQoLyTdBIhC4=;
        b=phu4ZFkyZz2/fNXQEgfUIUqq3r5RS+RTmDPh93P5bfddtsu+3pM4rNbF83H6Du2A7y
         nCJOpJjmW/wHjxBCL7KOrvBft5UKmbglq4jS98RhWu/PVNSF0ZuMQhahF92O+vZ0bnvP
         AlKXQNDTkAaGqf9DVR2l51ptxWc0opxbtyi2R1GCNI2UI9YLh2ow+hP5AkDZI7NbBnFe
         mJB0qkKqoAquNMSiArUkFIF5wJm2mkfsU4riFrdihCMguKN8suAG2IIwEcZ3CyS0SdSb
         vylN16TRVKWFwdFG42XbAZKzIh0exWEKa87VPg8slw7LdxbSo+/5kBol1INEKnhqkGUU
         Nnhw==
X-Forwarded-Encrypted: i=1; AJvYcCU65zb+wxkGXx677Kbx4eG05hGDGOXAKwxOBTIORjKjJJfy6U8UQ6KmM4re3rixM0hr52KjiphcaK5uNNljcBsdtHEC
X-Gm-Message-State: AOJu0YxP3txZjM5LR/H8YW9hS9hBvH9XEQVBz4JvDgZsUTCBF340i0Q+
	nuLfC25MYWcbYQKLRtgG0rW1lTv0AmhV+PsOn9Ny/8jtgIUWuno1
X-Google-Smtp-Source: AGHT+IGccEPCO/fQ95oWbFETZPiMAy9ujfiGft30UUXpW0SxbnJvW33Ts78eWjEeqRz0zQoBSM9ffw==
X-Received: by 2002:a05:6830:6c0d:b0:709:4def:6a47 with SMTP id 46e09a7af769-7094def6c85mr9408302a34.17.1722366551488;
        Tue, 30 Jul 2024 12:09:11 -0700 (PDT)
Received: from [192.168.1.22] (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id 46e09a7af769-7095ad4e8c6sm529471a34.3.2024.07.30.12.09.11
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Tue, 30 Jul 2024 12:09:11 -0700 (PDT)
Message-ID: <d256564c-62ab-4b84-9d0c-a02456d00e2d@gmail.com>
Date: Tue, 30 Jul 2024 14:09:10 -0500
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH] unit: pragma test_address to fix GCC warning on musl-libc
To: James Prestwood <prestwoj@gmail.com>, ell@lists.linux.dev
References: <20240730165138.274112-1-prestwoj@gmail.com>
Content-Language: en-US
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20240730165138.274112-1-prestwoj@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi James,

On 7/30/24 11:51 AM, James Prestwood wrote:
> This appears to be a compiler bug causing an array-bounds warning:
> 
> unit/test-rtnl.c: In function 'test_address':
> unit/test-rtnl.c:285:13: error: offset '2305843009213693948' outside bounds of constant string [-Werror=array-bounds]
>    285 | static void test_address(const void *data)
>        |             ^~~~~~~~~~~~
> unit/test-rtnl.c:215:36: note: 'address' declared here
>    215 | static const struct l_rtnl_address address = {
>        |                                    ^~~~~~~
> 
> There is nothing visually wrong with the code, and it appears to be
> having an issue with the "label" member, which is a simple constant
> string. Doing things like adding a member before "label" or making
> "address" not const seems to make it go away, making it really
> appear as if the compiler is confused.
> 
> Fix this by adding a pragma for that test function.
> ---
>   unit/test-rtnl.c | 3 +++
>   1 file changed, 3 insertions(+)
> 

Applied, thanks.

Regards,
-Denis

