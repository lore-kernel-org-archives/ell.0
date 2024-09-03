Received: from mail-ot1-f50.google.com (mail-ot1-f50.google.com [209.85.210.50])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C9155186E51
	for <ell@lists.linux.dev>; Tue,  3 Sep 2024 15:05:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.50
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1725375961; cv=none; b=Nz2mg04GiW5/3asujBRwzXBhEvp1gyDk9mDnELPck2q5CHKuubyu0omeFbaFRUiOU/5W+BNX5kCXKMWzWKXvvukb6za2Y/ci+gJ7kud1p4JKJxGb1I8fKk5PKQtw/JWEeXoA1xvKvAD5hU9GQZPGy8DeDjQIp6bBoO+e5EbSaT8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1725375961; c=relaxed/simple;
	bh=vW9hsz11rLUazFj3DzYHgNMWxSq9U37BH+8JYOB7GJo=;
	h=Message-ID:Date:MIME-Version:Subject:To:References:From:
	 In-Reply-To:Content-Type; b=qbi2Gi0JBbAErRkl+wFoItD+W0Qdi4NYxoq2HuEwrWqtahmMNaeZ5m91QkMmAByjSSrTZfsjsP3Ogrv5oaVvJmXBj18LhRm9t0aqtrDFLuCuX6/lxBa2I/XFg5E/Y+iLt0pDH9gklGM2idtK9kPN4UDcwlOpXY4SuUAVBOsjRsc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=ddrliZ8d; arc=none smtp.client-ip=209.85.210.50
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ddrliZ8d"
Received: by mail-ot1-f50.google.com with SMTP id 46e09a7af769-710ac7041c8so501032a34.1
        for <ell@lists.linux.dev>; Tue, 03 Sep 2024 08:05:59 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1725375959; x=1725980759; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id:from
         :to:cc:subject:date:message-id:reply-to;
        bh=AZeZnmno7g+wxg7EeQHdBjS7iMezwGsImqf+NIXSUqc=;
        b=ddrliZ8dmSCyJaoJyT/xtfQurVx48DGhPYYSrNqaX2XDWFxk3hkYM3lcRSn20PUHS9
         6cgpqgV4jRrr0cLyhwYfrohdyXSOohYvn+AVETwVBL/qoMOX1LYHxdrL3EOCrD5pg5mt
         tLXMwLgXdG/GE/vWkBlAnLgq5B8tm9nGb9RfAaXCLk1GyvUiqzVkL4OHRa2xXfCCxMJm
         cUKVYrvyt8d/HFNSXxYV71L9NqLYMufAOIp67oIegUhqlxcYEyfNypc7Euu1kVAifNtW
         PLoSLnDV/TNmFfr4fqnv0QhYOd0Y3cH3V8kgmBdLFSpxrSxF9PVSbs2kO2ALFsD/0iZE
         NC5w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1725375959; x=1725980759;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=AZeZnmno7g+wxg7EeQHdBjS7iMezwGsImqf+NIXSUqc=;
        b=navqu/unOCclu8JiusBTjYEAzlODjanqycsr338KvWlHpnuHR4qU5zQwm3qsMFx4iE
         kQGjQIa/8asju/8qHfwulufMj28gTf1jK0Vf9I/2liBKWMSt5o2pcD3mKrw8kgmNKCZb
         I5TWeSiaD7o71la5sV/0QEMcF5D717kxQ2Mo320BbeLSDKArkeKyVC8X8Kg0aWYbRCeb
         przQwUxZTMwNhmvzsC3xM1N/Lerre5crKhskJ7zHZeDNZREEy+EydiZPnwYDNMrEyI0u
         j+ZoMvKTgo0nR4U29ZglqGcKuA0gfWeVXOVxY2Ldfckld9/k+pq4fMXE0Iql81GRJdzB
         dbsw==
X-Forwarded-Encrypted: i=1; AJvYcCVgeQKjuMM/0RQMcf0pJuuZm9GCQcylcAjHdqODUXmbSOKxmOcYhtXcl0RmdogJxQuokek=@lists.linux.dev
X-Gm-Message-State: AOJu0Yy/oPhJFeYqdvOBnssyHpBJQBRP1Ob1eYx+QEU3ACZIR6FCtCG/
	ikjxskJJ9OyVLlT1Pa3PgDI4EfBUghTe6V+n4Dh2c/CCDq7IyulR
X-Google-Smtp-Source: AGHT+IGgH/tXitPpn+sdEnX7PxzHXjM1DV8OIvLupcKOuE10JFcLWRP4YuAIfBSBDWZ1z6wQiVEtQw==
X-Received: by 2002:a05:6830:3496:b0:70f:6f81:d258 with SMTP id 46e09a7af769-70f7118c193mr12664157a34.31.1725375958771;
        Tue, 03 Sep 2024 08:05:58 -0700 (PDT)
Received: from [192.168.1.22] (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id 46e09a7af769-710a84850e3sm535566a34.9.2024.09.03.08.05.57
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Tue, 03 Sep 2024 08:05:58 -0700 (PDT)
Message-ID: <976af136-bd64-43d2-a26f-5c2d7f8913ba@gmail.com>
Date: Tue, 3 Sep 2024 10:05:57 -0500
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH 1/2] time: expose _time_from_timespec in time-private.h
To: James Prestwood <prestwoj@gmail.com>, ell@lists.linux.dev
References: <20240829112549.24935-1-prestwoj@gmail.com>
Content-Language: en-US
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20240829112549.24935-1-prestwoj@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi James,

On 8/29/24 6:25 AM, James Prestwood wrote:
> ---
>   ell/time-private.h | 1 +
>   ell/time.c         | 2 +-
>   2 files changed, 2 insertions(+), 1 deletion(-)

all applied, thanks.

Regards,
-Denis

