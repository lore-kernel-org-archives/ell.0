Received: from mail-oa1-f42.google.com (mail-oa1-f42.google.com [209.85.160.42])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 475CA1E487
	for <ell@lists.linux.dev>; Thu, 16 May 2024 19:36:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.160.42
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1715888196; cv=none; b=B0hnhZD6sFyJ8+k/XPJFUcNdbGRX1TLK4+00BJ0DWK8MsqcW51B5HHGebrBVPCZaKOZUC3xOylf/81NlelCeYsuOs/JbVZBnbxlcJRBoiY+S6yOo6JSKUA8A+g035h0oFR8EX5+GZ52OLmPTZA7Kj5WhAUlYy7/uODI9fgthrRs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1715888196; c=relaxed/simple;
	bh=pCkXwun47n817nEdSLtm6qnLfQutPfbi8fLoBhUHUlg=;
	h=Message-ID:Date:MIME-Version:Subject:To:References:From:
	 In-Reply-To:Content-Type; b=cXiozRMa3YjHPdEGQFrVZEVW3X9zi4WtR6Y2bTXps9wBnLi+wSzK9UR6mrKz3nSrLc21FGJ8Eha48QrqPDz545o+C0lVHisqZV6quHz6Bldx8BBuzf0skLMIkPbpIx6Ui6bK56ksz/0e17MN7XOUDmN+Yb7Zzls6PXFIp9xml3s=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=iL6Sb0jJ; arc=none smtp.client-ip=209.85.160.42
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="iL6Sb0jJ"
Received: by mail-oa1-f42.google.com with SMTP id 586e51a60fabf-2454156db8bso561407fac.3
        for <ell@lists.linux.dev>; Thu, 16 May 2024 12:36:35 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1715888194; x=1716492994; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id:from
         :to:cc:subject:date:message-id:reply-to;
        bh=o1Punaibyf+tu1WSiWMz6HGTONPxBRo/u64fPh9061Y=;
        b=iL6Sb0jJxToedAT7f03x4LFk/ymLY0eh4/Kp8wOZzP/BTk+NpfAFEUqoN+8lf3retH
         /PH5vuEtaG5J/2HgFiJz1/xsY7pA3wsbQADUjk0jXhJT5hIoKInaFQVbIF6pcBmX4HrE
         u5gXly19d4ZHdgaZwd/Fh66HeYxevlEu6khFn7W4oMbtxWpjIAtwSmyhC/I0jnSC95Ny
         LVnhTxjHHdzby7NxkF4AeekhU1W+T8JrTiLuFdbF35qi1MPWD1VxYwrPa753hMPNhOeu
         puPFfGYuRJuPWF8vs4cBCGNgANMCz6VqMkcmiY4c+UPJHzVwea8dHERDnXFZLQXffHQ5
         vS5w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1715888194; x=1716492994;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=o1Punaibyf+tu1WSiWMz6HGTONPxBRo/u64fPh9061Y=;
        b=qq73E8H64A26cpL3ZygKMLyOqyHWu49FXcPaDQ0bPinoLRVDo4KQJox8LObZZqPpXf
         nLgoGcIephsAk6nZhSkqIcLssp+arVF23Rth3RLIZ8D87LMN+GYB3mDWCl5Wxv84fGlX
         jfeWeWbNo+CK1D+oz5LFgH/SjHwyX250NNqAbOKV/3XZvUSewTjLCaQS5AKkd6Z5YDbh
         /RQuELK6qGe/F2SRlesYGn0reCRx086j/s48WbXZWwxAOSii6HAfZgsegjTCJouox+Pg
         7+pEwNeEM2kC5H1/o+9HURkZ1vvnE8O2ETvYRuDIbPNv44jDMEMAfOKcajmWvLT9sL3i
         JWHg==
X-Forwarded-Encrypted: i=1; AJvYcCW/9kRfRtUbrrO0fhY+EfTrNI7F8WzeMJ05EeLqqnvsfAUd/Zgv18bB+d3oM/A2sLheCDMA1uJX2vtxVCagfBooDlWP
X-Gm-Message-State: AOJu0YwQJIwT+p4qmWXlw124MdbcmXReIR/xYXG5S7TKopSweoTbApeY
	gAJnjwidHyviEiy9h8V0ZNQkgMizJ6fCs5gzV/Dj+DMzCQruVqvNZUoi/A==
X-Google-Smtp-Source: AGHT+IHleSvjSFnfvnuDTvmmVY/2JMYnV/BEQctmlLp7k7XF04fHYUvcbG+poIZqdeugkOl9ni6x/w==
X-Received: by 2002:a05:6870:c0c8:b0:22d:fc00:9580 with SMTP id 586e51a60fabf-24172a72f2dmr21528971fac.16.1715888194138;
        Thu, 16 May 2024 12:36:34 -0700 (PDT)
Received: from [192.168.1.21] (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id 586e51a60fabf-2412acd6656sm3690319fac.51.2024.05.16.12.36.33
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Thu, 16 May 2024 12:36:33 -0700 (PDT)
Message-ID: <80fb1b89-e093-455a-b607-8b0d7400e03c@gmail.com>
Date: Thu, 16 May 2024 14:36:32 -0500
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH 2/2] unit: add testing for dbus-over-tcp
To: Ram Subramanian <ram.subramanian@getcruise.com>, ell@lists.linux.dev
References: <20240513175826.2363352-1-ram.subramanian@getcruise.com>
 <20240513175826.2363352-2-ram.subramanian@getcruise.com>
Content-Language: en-US
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20240513175826.2363352-2-ram.subramanian@getcruise.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

On 5/13/24 12:58 PM, Ram Subramanian wrote:
> Co-authored-by: Ramon Ribeiro <rhpr@cesar.org.br>

Since the unit test was all yours, I removed this line.

> ---
>   unit/dbus.conf   |   2 +
>   unit/test-dbus.c | 118 +++++++++++++++++++++++++++++++++--------------
>   2 files changed, 85 insertions(+), 35 deletions(-)
> 

<snip>

> @@ -135,18 +154,19 @@ static void request_name_callback(struct l_dbus_message *message,
>   	const char *error, *text;
>   	uint32_t result;
>   
> +	req_name_cb_called = true;
> +
>   	if (l_dbus_message_get_error(message, &error, &text)) {
>   		l_error("error=%s", error);
>   		l_error("message=%s", text);
> -		goto done;
> +		test_assert(false);
>   	}
>   
> -	if (!l_dbus_message_get_arguments(message, "u", &result))
> -		goto done;
> +	test_assert(l_dbus_message_get_arguments(message, "u", &result));
>   
>   	l_info("request name result=%d", result);
>   
> -done:
> +	tests_completed ++;

I moved this to test_dbus() and fixed up the style (no spaces before ++).

Applied, thanks.

Regards,
-Denis
