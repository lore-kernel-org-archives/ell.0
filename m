Received: from mail-oo1-f54.google.com (mail-oo1-f54.google.com [209.85.161.54])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 387AD157480
	for <ell@lists.linux.dev>; Thu, 16 May 2024 19:33:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.161.54
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1715888002; cv=none; b=GgOWbM3ARyVBfHj/eE1wfa+MeF71xMoomt/H7oEz+oDyuaDTmDim0pI6kuiBfk7fe3V3WYTkW2JM8LhtRTMo6A39O6rEsOp6SORSdEpTOKhqxR7UpkqBelAu8rWtV5al7xMbAKbUDVyDau0115QS8yVKe+b6zIAVxGyoIZuUyHQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1715888002; c=relaxed/simple;
	bh=AI09q75YsdHnG/U3Ry2MSz1dgmmuKwfi0u60EPNa/9s=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=NqcpNUXTNvzVzqBIwVPQp82bwaDNQz57gPN27QOJAiCC+ulJ34p6mXa0t79XQOOgC1jDPPp8UA5nkiH5U4D17P8a1dLUUJU/EmjiiWrVbo4uNKygf060CfmSTSjFQoiZ6Cgsd8SxlH+R8nAXVvPpQuPWXvofmBaelHrx1SAo5Ks=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=VG67pPVN; arc=none smtp.client-ip=209.85.161.54
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="VG67pPVN"
Received: by mail-oo1-f54.google.com with SMTP id 006d021491bc7-5b2cc8c4b8aso373193eaf.1
        for <ell@lists.linux.dev>; Thu, 16 May 2024 12:33:20 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1715888000; x=1716492800; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:cc:to:subject:user-agent:mime-version:date:message-id
         :from:to:cc:subject:date:message-id:reply-to;
        bh=SnIz9ebwkEhUVzQGqWgZ5bQyYtnCwHh1SrKAmunDjX4=;
        b=VG67pPVNmNVq7ACbc1EPOxLTA9UNM4ZBJj4MCz2IUyuqDifaLbyZcNRCefRVG37vcX
         e3SOENjRadxb4MMu/7sxuIfNiX8lMXOxZPgakUp08U9AWli6aEuuFP1aXTg+rxF5UQRK
         mlvLXkXWuj7dlfuUsq1lu15CSiz9PHzWYeNo0DFLh7lJJNAWzFRmlqd2XMQWPaSh36Wy
         Mgo5lmDORhCaX1qZ5pMWCv50d3Z+PPkhNy3SrJRVGTMX9M801YNRlBG04JHRdQsoDloJ
         wDW7aYcWA0D+g7KOSQF1ACc3zTdvCwzSMSW56wMe0gpwsLY3J9z3P7y+fEixXSwn5Yit
         cwCQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1715888000; x=1716492800;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:cc:to:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=SnIz9ebwkEhUVzQGqWgZ5bQyYtnCwHh1SrKAmunDjX4=;
        b=ZOwtK4ggPvjzLMkgSbpBMib3S/JF225tbW9fuBSwDe0BVcu8pKLbcy853LQSzFnXsY
         1OZxlgT2GFw5/fAI0FpOBNUtAbEYNgBLLi+6RUP9Tn80sdFFh/G8Kt2dL60HOZjea9xw
         lUGdJpXUlmqFUsalup5oGGRVYeqb0s+Go47nrd6mIpK5W4bLbEL33R0MRgOxswrD9m6r
         Q4D+5N4fy7XZmJUBIO0//U86gIgtvf/DfQtdtsvjtoAXrsZCUxeVgE+dWqKwqLuCoyX3
         TQUorJiJLGvj1B05r/ChC0cWWJCtjEj+G2pTYYxs2iFRNzpTl9FcPO385gn8adQ0P3d+
         qKGA==
X-Forwarded-Encrypted: i=1; AJvYcCW6e/qMCo7HZ2drWfF0HqmfqZG9f6NFj2Uqkfj6UQe3hQhe9Ujnu+bUCu1DHSfVpeGdfV/Ki4lXOawdwYcfQ4re7+l6
X-Gm-Message-State: AOJu0YyxpW1cut5C9gG1PIEpvFosGK+FQH98kTr2tyoqVcJVM1+dzyBn
	VEr1X3BEjX3esqEMGBN5q2+reV1sO7aaSD8eHQmBb8m7smqtjo3CvT8iXA==
X-Google-Smtp-Source: AGHT+IGcX/E4yb8DLGHjefM8Jwykz1/dqr8lQ9oyfOGyVuD8Dd48dhj9rX+dqsnALVxcQ+AERW3vTA==
X-Received: by 2002:a4a:a9c6:0:b0:5ac:9f7d:3b3f with SMTP id 006d021491bc7-5b28187f23amr21467873eaf.3.1715888000077;
        Thu, 16 May 2024 12:33:20 -0700 (PDT)
Received: from [192.168.1.21] (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id 006d021491bc7-5b277bef476sm3242530eaf.19.2024.05.16.12.33.19
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Thu, 16 May 2024 12:33:19 -0700 (PDT)
Message-ID: <c96a0eec-f312-4f04-9dad-28f511239f55@gmail.com>
Date: Thu, 16 May 2024 14:33:18 -0500
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH 1/2] dbus: add dbus-over-tcp support
To: Ram Subramanian <ram.subramanian@getcruise.com>, ell@lists.linux.dev
Cc: Ramon Ribeiro <rhpr@cesar.org.br>
References: <20240513175826.2363352-1-ram.subramanian@getcruise.com>
Content-Language: en-US
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20240513175826.2363352-1-ram.subramanian@getcruise.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi Ram,

On 5/13/24 12:58 PM, Ram Subramanian wrote:
> l_dbus_new() will now accept tcp endpoints, however it will only accept
> a numeric address for 'host'; it will not resolve hostnames. This is so
> we can avoid a potential long, blocking call to getaddrinfo().
> 
> The connect() call to the host is also non-blocking. This means that
> auth will not happen until you start the event loop (with a call to
> l_main_run() et. al.).
> 
> Co-authored-by: Ramon Ribeiro <rhpr@cesar.org.br>
> ---
>   ell/dbus.c | 111 +++++++++++++++++++++++++++++++++++++++++++++++++++++
>   1 file changed, 111 insertions(+)

<snip>

> +static struct l_dbus *setup_tcp(char *params)
> +{
> +	char *host = NULL;
> +	char *port = NULL;
> +	char *family = NULL;
> +	struct addrinfo hints = { 0 };
> +	struct addrinfo *res;
> +	struct addrinfo *iter;
> +	struct l_dbus *dbus;
> +

CI caught this one:

Clang Build
Test ID: clang
Desc: Build IWD using clang compiler
Duration: 72.29 seconds
Result: FAIL

Output:

ell/dbus.c:1217:19: error: variable 'dbus' is used uninitialized whenever 'for' 
loop exits because its condition is false [-Werror,-Wsometimes-uninitialized]
         for (iter = res; iter; iter = iter->ai_next) {
                          ^~~~
ell/dbus.c:1241:9: note: uninitialized use occurs here
         return dbus;
                ^~~~
ell/dbus.c:1217:19: note: remove the condition if it is always true
         for (iter = res; iter; iter = iter->ai_next) {
                          ^~~~
ell/dbus.c:1178:21: note: initialize the variable 'dbus' to silence this warning
         struct l_dbus *dbus;
                            ^
                             = NULL
1 error generated.
make[1]: *** [Makefile:2560: ell/dbus.lo] Error 1
make[1]: *** Waiting for unfinished jobs....
make: *** [Makefile:1716: all] Error 2

So I changed this line to read:
struct l_dbus *dbus = NULL;

Applied, thanks.

Regards,
-Denis
