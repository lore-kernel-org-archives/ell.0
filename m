Received: from mail-ot1-f43.google.com (mail-ot1-f43.google.com [209.85.210.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BAC43158204
	for <ell@lists.linux.dev>; Fri, 31 May 2024 15:13:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.43
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1717168385; cv=none; b=AVmpM7eu28TwKRxXEskqHweNtw7XWLdgwy7gzX8GQuqGRn8lzGVGHDxbgrQ8lVzdjKNudBejWp69B5ikUxGJ8240Npy9D0A/vvsWDnI0cTKvXVwt7vzRIgJgGQDg8b3K6IiuQNYTLlyqG0NpnI5SzBl2qNH5ZjzvuBfFVtTnsfE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1717168385; c=relaxed/simple;
	bh=Z4t2jFDG9eXJgjFgL5W0Ch7k2+RlouQLC67scXGz3ZQ=;
	h=Message-ID:Date:MIME-Version:Subject:To:References:From:
	 In-Reply-To:Content-Type; b=gQtruZv3kp8RLCoj61ldLCnRIkgUwWBE+yrPi/oF7Q6FVefMfA97ytke5TD8IBGWCDkZZc3xiBxsBgIqFlqjS7/ToLpEpShRAeslqTXe0wXyC01rso0OY3xGwGE4ZJS4LUeR4sFyqQH/IddqlxP8PXFBTE2F8VZ83QI46xCCtEw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=Otk+R2Sy; arc=none smtp.client-ip=209.85.210.43
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Otk+R2Sy"
Received: by mail-ot1-f43.google.com with SMTP id 46e09a7af769-6f89b16d081so1264157a34.3
        for <ell@lists.linux.dev>; Fri, 31 May 2024 08:13:03 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1717168383; x=1717773183; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id:from
         :to:cc:subject:date:message-id:reply-to;
        bh=IjSpgyuZkLOR5btH++ykVJR+hxnbCv3el0C0GYBFLXw=;
        b=Otk+R2Sy0BTpnms5b3Y6B8L8CkpntlL5WAAg06NL9HI3j8F/U9xX3KNFdYrHgHMMQl
         ItpRION94/yR6EbTFyDoH/GLKmTkWDcXZD47Lj6ulnEN4kW2AnLWJGyraThdXL7B2JhB
         zWooSxqoyZWnn52peHTBHE6U1xzSjYzSx86CoXWpuPdv1UDQxIvaw1w9WpAE95H7rwZL
         ekrb0CzqT5XjBWS32xeD1YvCdQ7xLh6+PG4lDKsee4FUHQw2AgtM7ZidcdP5j+wwZS9I
         l053bfEVpY8tEd0C0mF9U8jj8uU8lxpk0xIRbkGQ+UwNl/0tFumfxMAUeSq7Agnn+Y7m
         F+rQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1717168383; x=1717773183;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=IjSpgyuZkLOR5btH++ykVJR+hxnbCv3el0C0GYBFLXw=;
        b=PN1GAcNMPxLxG2jOaxHhVkkZ9r4ypyO58Bkb43vyVy7EWN2xQ9P/MYFv6GzS/+AEcZ
         GOx5/ZmirSOq5CBVrgnOv6g14uEaVVKJvuCyA2rHapTpD5w95s3PtTzPwsnAmrq/DRXn
         tOzXM0yvsxAMHPTastA6phpkHJxabBniwT4v4Z2ac8lKPCsY3n81tZl+sZ9KgzCzxlRK
         fqNQajO+PEefytvWkOBTksUY3y2CtYq3p4/WCZuz2cSRghrYwo5SJuQvck5HCFt4mUtT
         HsrgQfImlQHpZ5jTl+giUaIM2sL//Crz8H6U0mOFTaXHPHF40ErNFaYN4RS+D7OfWF0I
         vTiQ==
X-Forwarded-Encrypted: i=1; AJvYcCXZ5jd7tQftXnQvP3pxi2XWq4QK864Y2jRUcy+UKpS9dujnjHqCsg3yWJANrXjLqwu8qPE/95TEbBa5pSJO0S2PgGTL
X-Gm-Message-State: AOJu0YwfJETyVGzu837ull8tDkJ4Tb+drs79gHQIBYz3frt6lvIk9ZY0
	Wlr+75EjJfjZZqdaEfoOKsILsXUigpSrSb3WD44Kv78B8fJKrrFx
X-Google-Smtp-Source: AGHT+IGUDx8QqiVSPhfYqVaWfrqRGM7Tin4Ne6ZMOd6XK1U4xqiTorPh/GPG4i8H4/TUeyiyj9swkA==
X-Received: by 2002:a05:6870:a2cf:b0:250:6e6c:b1f0 with SMTP id 586e51a60fabf-2508bfb10a9mr2622979fac.37.1717168382751;
        Fri, 31 May 2024 08:13:02 -0700 (PDT)
Received: from [192.168.1.21] (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id 46e09a7af769-6f91054fb68sm365767a34.45.2024.05.31.08.13.02
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Fri, 31 May 2024 08:13:02 -0700 (PDT)
Message-ID: <f8e25271-1376-48f6-b5c8-b5312e56fcd4@gmail.com>
Date: Fri, 31 May 2024 10:13:01 -0500
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH 1/3] acd: move l_acd_stop ahead of EVENT_CONFLICT
To: James Prestwood <prestwoj@gmail.com>, ell@lists.linux.dev
References: <20240531145554.601087-1-prestwoj@gmail.com>
Content-Language: en-US
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20240531145554.601087-1-prestwoj@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

On 5/31/24 9:55 AM, James Prestwood wrote:
> Stopping ACD after the event callback results in an invalid read if
> the callback destroyed the ACD object. Stopping ACD prior resolves
> this and is consistent with other call sites.
> ---
>   ell/acd.c | 4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
> 

All applied, thanks.

Regards,
-Denis

