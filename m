Received: from mail-oa1-f48.google.com (mail-oa1-f48.google.com [209.85.160.48])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7797776026
	for <ell@lists.linux.dev>; Wed, 15 Oct 2025 14:03:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.160.48
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1760536986; cv=none; b=H0q2za5lT4K2t2xPN/H/hs4fW2DeKu1CtdVyXrHHrG8x4xF/a0VZAu3rJ+So/WlRIWZkthCodBnkPjzgwv1D3B5K60hVPfjxaLdZ4SxTsZDRtTcymGvLF00V3MVfZ30xDQcWcFYzkxzVBiqO3DZBOQHnVvXNYhbf+u6vCSK++yc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1760536986; c=relaxed/simple;
	bh=SY+Gte6MxJQnzcirwfxjYPiN4NkOqlWlSQ1FH9Q+QMM=;
	h=Message-ID:Date:MIME-Version:Subject:To:References:From:
	 In-Reply-To:Content-Type; b=XqBTGgsiXqEbusTkra6tB0qzsyW7NaH4BE6z2JXzicYMvgQ1+zeRJOGKZ515f/+ziMaB6MesOuJg2+UnXlXq0pP+2SBt47trGmA2Kp2HW6SIHeLRlgTRcK1ONG9MFdEOSqH/t4LkA38hvroSSM6tKf0d3pEmPCrz27kskswb+nY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=jdiw1rQ0; arc=none smtp.client-ip=209.85.160.48
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="jdiw1rQ0"
Received: by mail-oa1-f48.google.com with SMTP id 586e51a60fabf-36f51ac0595so1787652fac.2
        for <ell@lists.linux.dev>; Wed, 15 Oct 2025 07:03:05 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1760536984; x=1761141784; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id:from
         :to:cc:subject:date:message-id:reply-to;
        bh=kqn0ijQ3tJvT7e4co+XfnqrzIgKrNI2mSwG/NITlDUU=;
        b=jdiw1rQ0x4PjUaQisue2GP+xd3TjH6IXSuOK85iW5x+CVE4CQ6vV5Yu4PFxtr5gfAf
         OcHXHS0DuJt3TC1tiB9jogXzx90yA+BrYZfa8ZPu5qAXX+18faSdZ73g/EU9JU3v8mX6
         CgAw5QLrsmmsAPK8FaY9WcuETofV57RJJD9q0ZSfx4JAi1ON5Vn/kFcVVY0gt79aOoVK
         zQ8LJ8SPO41Q96U77X7/94vxtA6fOodxJBSvSTWA7s1zt4ekteBxJ2CjNXYW3Sj25QOl
         THmXMxaHTj3mjtYEJQ/ZymfLXhT4EfixPBgyLAcQMPHOJ9+3FeT0lj89I1eOCM9N8huM
         z3rA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1760536984; x=1761141784;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=kqn0ijQ3tJvT7e4co+XfnqrzIgKrNI2mSwG/NITlDUU=;
        b=aZT9uiAWE30uIs/1fA2y3Jh2jtxwVY+qTt9I6wh4cWM2uln7S3NPNmNgxv5vjifYBl
         6ZYP6XOv89eLiFMuRNIsBcXxnUq9DzcJxFRHCgvGMeUPt1K6UQ69YjAAUx8V6reO5dIw
         9AcB62puddAmABIhfA60fiWhqiwPNvwsWYWI8H1+Pr0nvDL3nN4u/3k9qQD9pTRGsKQP
         TFhoEOsAVTFrQJQ9ZbWG/PFkOd9yPjyJ0QPSsm7je5RAKIZMfFckWAOFSw/XPtJ84iQ7
         Pe6+VLT/0G54mfRuNYTydXqgtMZ+GLmW+0bzMdCBaJz1/XiPyeRA6oeleTvBeh+ri42l
         5EPQ==
X-Forwarded-Encrypted: i=1; AJvYcCVPirv1qMR0/yXPn0XWZDN8ipvXvEwGv/NYI8rbJEFeOhZJ2mwrCluPZI+WpngFqfg99yg=@lists.linux.dev
X-Gm-Message-State: AOJu0Yx4CTK22lMqjCyKqYOa8pV24shLB4M3IY1qcL7T/OgRIGsuUWFs
	WhztCBcNPypUXC6fTVv1Ci8LdIzkFX38V89tJtzq91sjNP6MgoSvx6Jf5akyeA==
X-Gm-Gg: ASbGncvjZoq42zQivZS2nXjEDdttbZwMGKw+qRtwjn4/kTWpXJFzur2Go1WNm5pyuB/
	33gRG6D/BTGcYOBotxQAU95lEnHURayCfPc42XAF0EQZBaFSGXNHNExKjtveK6gSAXs6SvtoUdG
	4JidhKT3+AR0qMoJZKjQQOzQen/zi70OUVbafTf8631fFCmC9xJlOOHJlLxHHdY6aX0IwzgiKjb
	pNXWSByjV3HnJvBskB7eVPIZjmYe6UFLLW0lGJ+jC+UCiPuBYWKkCozGYrFUHeWlGhj/nQgTRsE
	lXogK7EH3QIIh3hQL46ICVavQz6dDtGUXgtTWJp3B8Fx3EqThJAZH9bnXL1dEzkDTSC+CEW7f89
	rWFtszuUVDhPOfNK+bTzvFGskfxpB3AloMrJnZZm0Fa7Km82jO4YLyzC0oH5NGbbv
X-Google-Smtp-Source: AGHT+IGwc0uvirEmN3SgvSrifil5UePMZKVVPEohDLJPcEOe6va9OpGKqbT5JcdCCNRqScuA2yeazw==
X-Received: by 2002:a05:6870:e241:b0:37a:4e25:be38 with SMTP id 586e51a60fabf-3c0f89d0925mr12763996fac.24.1760536983662;
        Wed, 15 Oct 2025 07:03:03 -0700 (PDT)
Received: from [172.16.49.130] ([70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id 586e51a60fabf-3c8c8bd683fsm5364560fac.12.2025.10.15.07.03.02
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Wed, 15 Oct 2025 07:03:03 -0700 (PDT)
Message-ID: <2ce34bd7-a39b-4859-a4cf-d9411949c3e9@gmail.com>
Date: Wed, 15 Oct 2025 09:03:01 -0500
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH 1/4] main: connect instead of binding to systemd notify
 socket
To: =?UTF-8?Q?Martin_Hundeb=C3=B8ll?= <martin@geanix.com>, ell@lists.linux.dev
References: <20251010092005.2283540-1-martin@geanix.com>
Content-Language: en-US
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20251010092005.2283540-1-martin@geanix.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

On 10/10/25 4:20 AM, Martin Hundebøll wrote:
> Binding is for the server (i.e. systemd), while connecting is for the
> client (i.e. ell).
> ---
>   ell/main.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
> 

All applied, thanks Martin.

Regards,
-Denis
