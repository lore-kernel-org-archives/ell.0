Received: from mail-oi1-f178.google.com (mail-oi1-f178.google.com [209.85.167.178])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7970C1AD9C9
	for <ell@lists.linux.dev>; Thu, 20 Jun 2024 15:02:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.178
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1718895721; cv=none; b=M+baV8aQj2XcKkUO2JEZ4LL++B3VYl3Zoe98MxIYkpZ/fA8TcOwCSNxm1n5FQNJh2z/2rqJAnlB4hV+kfko7IqtqYYe+QBLpcI0lTJUCOx/aY6/hQyBQc5Zq2qNlzSY9OSKX3EC+bmuocTT7+uaXVeTjBUupp1/XImRNnVtmtzk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1718895721; c=relaxed/simple;
	bh=zrILH9SyDflNk88zbrchRdhb8nKgPSSFXdVZSsRauis=;
	h=Message-ID:Date:MIME-Version:Subject:To:References:From:
	 In-Reply-To:Content-Type; b=CAUNH7qcaPGnn6q894P/x60Aw7CjPZihScV9Qu4AnnF2QWdy9eQvQKd8DOQbs1LjfsJudWiOQECrF2Ncl5lWWbzBX6nA5pNqmvaQkNyH9CloLZwRyWHKbg+g8o2apGVIWBTAJuf4Z4rXJZGtChEFLZ96m8SXBXGQhuK4hs0v25E=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=OcdtWaXn; arc=none smtp.client-ip=209.85.167.178
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="OcdtWaXn"
Received: by mail-oi1-f178.google.com with SMTP id 5614622812f47-3d22378c59eso552401b6e.1
        for <ell@lists.linux.dev>; Thu, 20 Jun 2024 08:02:00 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1718895719; x=1719500519; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id:from
         :to:cc:subject:date:message-id:reply-to;
        bh=Qv9/sJDN3BD3tZD8L9DZUJOWPAzbKlRpPuuBqpDzAbE=;
        b=OcdtWaXn3WCMgygl6NHyefjao6n2KUp5oVc9M0/AtLxP420w9SX0mPKH3dy43jUdCH
         SOYyGV+GtJuLuC/9OPtpWBNhHzLDsAktRnG5MjNymE8hPWi5Qy7PKGgQQpt0+DSrd9jY
         BTXptsWAWPOk9A9w1Mk2niw9s5rCfkg3Pyc65ddn8ZvaxOeBrHk8jJvDtjOO0I3wprL4
         OxgjTMQmbbTWux1Qc1JwQ6N5pj+AvBsgIKso6v57/EfUNXn0OJ6n9L4gxu44JUpm5xet
         YYTTkBCIemgUohni1bmGG9RxTL3KzkEBqHN8ONqDEEhOuzbHBqzSNnIgcfjRGsvpMrG3
         YvqQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1718895719; x=1719500519;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=Qv9/sJDN3BD3tZD8L9DZUJOWPAzbKlRpPuuBqpDzAbE=;
        b=f/lswYNOt1Si3g71r/LEwpzQ8HGHr+qLK6G67qZV7fpsLihk/hLffkBwgpNzUv3leI
         jIXYdiHkWhrClBQG9pRm+2XKoEkNpOJpQDhNd2Diu2IVhIfKftSgUund2VL96HV90rzv
         OtexTgOv+a0keL7VtuS8AuSKe/sThxx/dOT6PbEV52onpUXv2qkDlmtx7RFlP6DLNbBK
         kxDMjkrhJDhKq75RjH2xkfem+sHH11b48EiQAiIS8Yf3LOLl0G3wsAfB8nswuOy6EfY/
         ytfzSHfr9IGGdUA9/mBAxnU9O+8WOp3Vjz8xYZf1PR1OEpXa7wZHCuTPzHJ6EqvbOsI9
         KAUQ==
X-Forwarded-Encrypted: i=1; AJvYcCU0/Zj4PdbFgDRAl9X5WY2NmKoxm/XJF0oFhdi2kUdx+2L47okiV2O7RXJj6yEy0RpT1G4dU4uiLoWYGxZ4NABGvAVv
X-Gm-Message-State: AOJu0Yxly2rSHGTJsxya1i/Dlk1TMHRsvm4Z4LdhWPEiuTU5Nz9q81jQ
	z9JPLDOz28w2a+0Qu+oIKsgNimBSPWLx+phrfggLm5MusyeGPqTynQ1rPQ==
X-Google-Smtp-Source: AGHT+IGJbNPxxyApG+9RwNiwfN0p2zT3v8XbdG3GHKO+0Sm/KsIRtu4kYmvZAPWhCCp0fvn4CnRByw==
X-Received: by 2002:a05:6808:150c:b0:3d2:1fdd:286f with SMTP id 5614622812f47-3d51badba4cmr6313352b6e.49.1718895719535;
        Thu, 20 Jun 2024 08:01:59 -0700 (PDT)
Received: from [192.168.1.21] (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id 5614622812f47-3d2475e5072sm2545482b6e.9.2024.06.20.08.01.59
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Thu, 20 Jun 2024 08:01:59 -0700 (PDT)
Message-ID: <d5240471-542a-40b5-920f-2d47dbafe5e9@gmail.com>
Date: Thu, 20 Jun 2024 10:01:57 -0500
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH] unit: don't specify tcp hostname in dbus config
To: =?UTF-8?Q?Martin_Hundeb=C3=B8ll?= <martin@geanix.com>, ell@lists.linux.dev
References: <20240617122939.1249697-1-martin@geanix.com>
Content-Language: en-US
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20240617122939.1249697-1-martin@geanix.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

Hi Martin,

On 6/17/24 7:29 AM, Martin Hundebøll wrote:
> Testing dbus with no network interfaces available on the host fails
> with:
>    dbus-daemon[291]: Failed to start message bus: Failed to lookup host/port: "*:14046": Name or service not known (-2)
> 
> Seems like "*" isn't a valid hostname in such cases:
>    https://bugs.freedesktop.org/show_bug.cgi?id=28979
> 
> According to the linked issue, the fix is to simply omit the host= and
> bind= parameters in the config.
> ---
>   unit/dbus.conf | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
> 

Applied, thanks.

Regards,
-Denis

