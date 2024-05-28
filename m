Received: from mail-oo1-f50.google.com (mail-oo1-f50.google.com [209.85.161.50])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3541DCA6B
	for <ell@lists.linux.dev>; Tue, 28 May 2024 19:26:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.161.50
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1716924365; cv=none; b=odOvaul54pF793f+ddLaM8RTUduNqY+Yh7tBtMchozrB4Qifgq/unQ0zIr6C1yq8kexr3vRJts6/zsbxYuElwTgp1/ALA3PtIWGQjX9XYnmoPsO8oh5BkMKdroKLk3h34iuDd7bG+KPlc/8aKf9IKzi8V0sE5Msm7t61IIYbprE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1716924365; c=relaxed/simple;
	bh=dLvdkUC28MkmXoSmYrh1EkBbbnbghPcF+OymWlNjKxM=;
	h=Message-ID:Date:MIME-Version:Subject:To:References:From:
	 In-Reply-To:Content-Type; b=ijMNoUswqtlSzuhqNWEZrp9aflA+KUx9D708FpqQ6tGcKvRtuB+uBuacPTbDkrpujR86uDA4TpWVeJK6iutJrEulplW4SgZrCQnHsvpctlGoXdoMqd+b2WF9Wen+8ub+fAoTK35bGz2mbr8XM95niTXjHOeIfcwPcK6hfym1u1o=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=TD6CydKE; arc=none smtp.client-ip=209.85.161.50
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="TD6CydKE"
Received: by mail-oo1-f50.google.com with SMTP id 006d021491bc7-5b9778bb7c8so761984eaf.3
        for <ell@lists.linux.dev>; Tue, 28 May 2024 12:26:03 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1716924363; x=1717529163; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id:from
         :to:cc:subject:date:message-id:reply-to;
        bh=EAtY+PPPkF7ilL0kNQOlGOEqrV/jR+gKZomcfMElKLs=;
        b=TD6CydKEmL2jSIgP7QJtUBktK0L4uuCs6I2AvUYYzpLwAulwWhRPbF7m8MlfhmGsiX
         m0U70WJVxWep1JVbtuGAQppYEg/t846SumzfITobUxp0Dg/d3ZDIo5QKYO7cieQ2GUAp
         mXYwusSQTAg9GIU3rDuFgPKhOBjEsaaWJLmmhQXUeu66A2gOrszcbYYBnSRYhKEwA372
         glSomsOC0l+jJ37wD06QrMwF/cAElJ2AoJyPdI96BaMwMd2IqMoV1+wH+AWaaRZevfa8
         JRYp6+YZAX1k7yCOeBe3UfGkrDwKbQm7timKucajOzS2Cr8wUZfKlCXZFxuG7cjlZDEq
         ltnQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1716924363; x=1717529163;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=EAtY+PPPkF7ilL0kNQOlGOEqrV/jR+gKZomcfMElKLs=;
        b=dJPPqjOs+xqSD4CUixcWRQ9ul+Ge+UwNScrJH8HoLSsINlxzzEivj0p1Cxq+c5u+Xd
         9O2YexkOZr+0fI3BfffahIRk5UkorjMplzCSu2Q46PBl4EcIjZjkqTSFYK69mYT0pvzp
         GPgEgzzvokmEL4UkAqeUkLEsnB5JcEX7bfHbvdrqO0OU2ZBbYV6Ys4eRyDDwwiLhL5IX
         ANqeR9yQPTiwzJeOdslegPjlBVxEeQfEoYe3QiHRSA0osUtSg6qSuHq656DVG/dTmGHL
         QlVWQFAlYh2oBWOsKAwdIWS8M1CHnaIz7dprdMrEENOflU2oodGRpKpWLvqE9wIVy+ob
         p9Jw==
X-Gm-Message-State: AOJu0YwGcPVF5vO7PGQmOBLvPMDsGJ9tgHx8pfcznYOBDZ2X1P3KEgJE
	lOQvQGcER8k49fRIi4xIfNJpoSzJU/BrWH8YSKUjaEDR3DCGKZZWC7TCdg==
X-Google-Smtp-Source: AGHT+IESLC5fDfyC33IAzewUz7Be51nWkaFGh54fgVIB8DpqGIwFH27OHvD9uaTQKYGQ7KSjdlfgnw==
X-Received: by 2002:a05:6820:c09:b0:5b9:8a06:c49 with SMTP id 006d021491bc7-5b98a060dcfmr7704715eaf.2.1716924362921;
        Tue, 28 May 2024 12:26:02 -0700 (PDT)
Received: from [192.168.1.21] (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id 006d021491bc7-5b96c46201esm2284486eaf.6.2024.05.28.12.26.02
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Tue, 28 May 2024 12:26:02 -0700 (PDT)
Message-ID: <019d905e-7a45-449e-83bc-649449ee33f3@gmail.com>
Date: Tue, 28 May 2024 14:26:01 -0500
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH] path: Add l_basename function
To: ell@lists.linux.dev
References: <20240528152542.168844-1-denkenz@gmail.com>
Content-Language: en-US
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20240528152542.168844-1-denkenz@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

On 5/28/24 10:25 AM, Denis Kenzior wrote:
> Many ell based projects use the GNU version (obtained using #define
> _GNU_SOURCE).  Unlike the POSIX version, this version does not modify
> its arguments.  However, some libc implementations such as musl, only
> provide the POSIX implementation.  Implement a version of basename in
> ell.
> ---
>   ell/ell.sym |  1 +
>   ell/path.c  | 19 +++++++++++++++++++
>   ell/path.h  |  2 ++
>   3 files changed, 22 insertions(+)
> 

Applied.

Regards,
-Denis

