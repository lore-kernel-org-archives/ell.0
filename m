Received: from mail-oo1-f53.google.com (mail-oo1-f53.google.com [209.85.161.53])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D626E2232A
	for <ell@lists.linux.dev>; Fri, 14 Jun 2024 16:15:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.161.53
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1718381724; cv=none; b=TbJhNZGrIEUuvRcWs4PogW5S4PtN7948Z22KFgu6oBbyhtE+12GWcdo27NkKlhUAu/6rLfzRpFcyT51glQaA6QtZGP3Z2Hcs+GLxh+il8jvi6sssTFr8s7pokMMk2LONwM1g9JwWKHEW2iPYiMEwH7F2whPSwKbV2VSeNVrtFYI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1718381724; c=relaxed/simple;
	bh=ZB5B1EPVvObD1cW5fJkJPyFZ9DDcDP+RyLyHR2LQ+D8=;
	h=Message-ID:Date:MIME-Version:Subject:To:References:From:
	 In-Reply-To:Content-Type; b=OblWXb+99x/28Q1le39nK90dejDy3mn4Fg3LdS1DE2DBcQ0fj4iW39SM6LkehwRTQBI4zUVX7VHtWlmmmgpTXaeFl0C0pKvjhmT9orzI+WNtDORzDOhaiFousQXN7tUvTTESjYwrrwgmANHIHfEF59RiLtuDdYosdjkNmsmXPoE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=C9ZB40+s; arc=none smtp.client-ip=209.85.161.53
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="C9ZB40+s"
Received: by mail-oo1-f53.google.com with SMTP id 006d021491bc7-5ba33b08550so1145173eaf.2
        for <ell@lists.linux.dev>; Fri, 14 Jun 2024 09:15:22 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1718381722; x=1718986522; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id:from
         :to:cc:subject:date:message-id:reply-to;
        bh=aEP6R46Pg4jIrCfapiEYs9AKEncg+l8XYGiuWirFnjY=;
        b=C9ZB40+s+PJ/ROgC+U9YaiqFnmcM39B0mFpmq7NMZzi6Iu+7BogJ/cX9W9uS2eTmxe
         mYiQOMCjfBfQAGLeAO4biH5l0IQR/pdMRJAxHCjVrIK+efD/TRPXoPJBdAdkDiDbXuVe
         brJfmtLuWdSpcoTyF4utrjFu/wGuZHvsRijFSj9NNY76L7tGVjkB0NHnjocMsDEbEXem
         M2lCDvpEwOa7shJkeX3gYSfQpM5hN30ykZ6v6EyOo43AQI77LCUIMz2Qph6XNfYX1fRw
         ueauCT9CwGTDNqDTSa+nD0pSsJMrk+Sk5F2KDMFo65jQDSGSqfWFc3pBrBUaTQZbmzH0
         H2fw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1718381722; x=1718986522;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=aEP6R46Pg4jIrCfapiEYs9AKEncg+l8XYGiuWirFnjY=;
        b=Ir6SoPyrIfGCyR9ZJ2Ioi0OiXl+uPdNV7LThuKd7PskDcJse+qw6ObdIX2GaZiTDQ8
         bdLNy2q8XqMJfQzcH2dRHSc86mRGTYM//NpudSdDwt5NdUIT7lvKB5MwuUXaXuLME72z
         oqiEAtPbLakVj75J0qktg0QfgNkRV3RIx13IwE4SspHFXsl84Rjf6zH7oCKCXR1ehngJ
         6YuKwhudb2fAFDkvrT0ps1WLsdHACjMCqUUbmJx8/8dmHvMeK9i6nHEKWXF14oUxigBL
         /p0pNNfPpLEivZESiVgTL/iIMfVxWSXYXYdb2GMZ2bVzgBb3ax4xRA7G8nu+LgcWxLtT
         ytlg==
X-Forwarded-Encrypted: i=1; AJvYcCU+LpoqGqE3HE4kKk7JZ0vYx4zZN6bGIAZWLn2f45czlLzarQ1Xh6nAExlWAuCIIwOU4bDWGdMzB34MMV+1FbZ6ZioB
X-Gm-Message-State: AOJu0Yxf5JAadBiXcsN4ZRotQOU/i8mxiYYC7Zzqi/h8q+0yiPKq3eZT
	B94JHmzSLZpbocLuFAWFX1jITXu4+Q6QFlRMvmfIEgS1/qq18dGU
X-Google-Smtp-Source: AGHT+IEK1en+UI7EGcHcVONBvCp+bkN621vJs7PpczeqqeEsht0vUzi+cUT6OMDPXVKhjO75ip1azg==
X-Received: by 2002:a05:6820:555:b0:5bb:672:405f with SMTP id 006d021491bc7-5bdadc577acmr3194725eaf.7.1718381721749;
        Fri, 14 Jun 2024 09:15:21 -0700 (PDT)
Received: from [192.168.1.21] (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id 006d021491bc7-5bdbcf8980asm30685eaf.30.2024.06.14.09.15.21
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Fri, 14 Jun 2024 09:15:21 -0700 (PDT)
Message-ID: <f3ab488c-f6e2-4afd-b2df-508a3d7d0eb6@gmail.com>
Date: Fri, 14 Jun 2024 11:15:20 -0500
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: New tests fail with parallel make
To: "Kohler, Benjamin" <bkohler@gentoo.org>, ell@lists.linux.dev
References: <20f687ff-38ed-4f8a-9a61-cb698ddf0452@gentoo.org>
 <c11b87a0-df30-4515-9963-05418e03dc55@gentoo.org>
Content-Language: en-US
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <c11b87a0-df30-4515-9963-05418e03dc55@gentoo.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

Hi Ben,

On 6/11/24 6:43 AM, Kohler, Benjamin wrote:
> Hello,
> 
> I'm seeing new test failures on dbus tests when using more than 3 make jobs.  My 
> default here is MAKEOPTS="-j4" and it's consistently failing. It seems to 
> succeed with  with "-j3" or lower. Failing tests are:
> 
> FAIL: unit/test-dbus-message-fds
> FAIL: unit/test-dbus
> 

Indeed.  DBus tests use a well-known path to start a private dbus daemon, so 
they will fail if ran in parallel.  See:

[denkenz@archdev ell]$ grep -R TEST_BUS_ADDRESS *
unit/test-dbus.c:#define TEST_BUS_ADDRESS_UNIX "unix:path=/tmp/ell-test-bus"
unit/test-dbus.c:#define TEST_BUS_ADDRESS_TCP "tcp:host=127.0.0.1,port=14046"
unit/test-dbus.c:	l_test_add("Using a unix socket", test_dbus, 
TEST_BUS_ADDRESS_UNIX);
unit/test-dbus.c:	l_test_add("Using a tcp socket", test_dbus, TEST_BUS_ADDRESS_TCP);
unit/test-dbus-properties.c:#define TEST_BUS_ADDRESS "unix:path=/tmp/ell-test-bus"
unit/test-dbus-properties.c:		dbus = l_dbus_new(TEST_BUS_ADDRESS);
unit/test-dbus-message-fds.c:#define TEST_BUS_ADDRESS "unix:path=/tmp/ell-test-bus"
unit/test-dbus-message-fds.c:		dbus = l_dbus_new(TEST_BUS_ADDRESS);

> At least part of the problem seems to be starting more than one dbus-daemon 
> instance on the same IP/port.
> 

Right.  Our CI runs make check without parallelization, so we never see this. 
I'm not sure if there's a way to force automake to run the test suite serially?

ChatGPT suggested adding this to Makefile.am:
AM_TESTS_ENVIRONMENT = TESTSUITEFLAGS='-j1

But that didn't work.  Maybe others have better ideas?  My knowledge of automake 
is limited.

We could also possibly make the bus address unique for each test?

Regards,
-Denis
