Received: from mail-oo1-f43.google.com (mail-oo1-f43.google.com [209.85.161.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C6E7849638
	for <ell@lists.linux.dev>; Fri, 14 Jun 2024 18:51:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.161.43
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1718391112; cv=none; b=L91bbKEFO8Jbia9tw8MiLVxB2y3QxhsUrDmjNTsWL6aPNp/A4nEedjou6khCxOT9K9afzwm0Pwqb9szFjBy4NAgwj6pakKKnabFZEVxraDMIUwYLX6KFQIpM5hdqJbEASk/jhxGRSTijYQAqEof2lS87S5q36fEYNGC0xkWkW9I=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1718391112; c=relaxed/simple;
	bh=UWVzJuoCKplUP8hgztYimM2PjNK3I1L76uxGS4zksPA=;
	h=Message-ID:Date:MIME-Version:Subject:To:References:From:
	 In-Reply-To:Content-Type; b=qXfknOc/yDR5ixor+qsoYAWiHub+IYXsl3faBC2mdlELZBmcFPqLJlCjRYWuVKqqLtJuLHFq7SidHOPNSTSD8iiSV2T3x+Lk5cS0MsI0NvMRJsc8dbdRvI6aOhtK8c0+pN0KvShNIAq86U7QBxSlpRdRg8P8jYu4/pgxFpl9DcE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=Y6QeCTnW; arc=none smtp.client-ip=209.85.161.43
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Y6QeCTnW"
Received: by mail-oo1-f43.google.com with SMTP id 006d021491bc7-5b97b5822d8so1197112eaf.3
        for <ell@lists.linux.dev>; Fri, 14 Jun 2024 11:51:50 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1718391110; x=1718995910; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id:from
         :to:cc:subject:date:message-id:reply-to;
        bh=0Gzyq1IUu+nnkybgGfYS0I/Mr73dUzKhzSmai/PpECs=;
        b=Y6QeCTnWfpNXs5vaLXj90C9TedFAsJzRHh6rgvhJnkc6R15trGPMoXaI5DPkT91RCh
         b8h4OTE4r9l0NwCwXaKEJc1mdJhilEYBwiooq5vLOAs6tk97mzzRYZi6G8oIh/NXO6pF
         RgwIWoJx4w4rDWfkx8vWcVdYc4u7cXjphw06GmXOZiYir8Rx+ziu6VNlrt4IwrEskZTw
         FQpzwTeUiIyDbhEQlLXVSYf0+tBknH1Fd2Xp1qorLHtnSdmob2d5vNkWWKbSmsoMe5Qs
         qPy5bbRH51DeoP+dm6/FcBClofg2y6bI5PbHGGajKwBgKf1dy3HFgKMLT/o0xSog/ORj
         qbaQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1718391110; x=1718995910;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=0Gzyq1IUu+nnkybgGfYS0I/Mr73dUzKhzSmai/PpECs=;
        b=l2Ue0oCbWwaD4Rs9MXe8yYY5wJd9JnyRTgVsjdl/Q/A3RIqsY16jA2VU1m9gUQeoce
         E2VwvfwkGbtCF5eXdnezslfgajfc49bdoU1zq1T/+gEG+uSMp5sG4wJ6Sdg8qC21e6Rh
         PHWLFBSpLCU9Sj+oUbt7QAGfm03Tn+Dz3POkmihsQ1pi53DJOWd8jYc3iGbwPd/u04Dy
         ssxsu7kLKUyXk8XeoiOw85U2kwstXz9OSTAWUMNgl59XEY1FfnK3oOEvbMdypz19VJgD
         62lU/iDwbJbhDSawUjceP63eQlgEFpEluYRTUGTIqSMzvfxo+9nOpRYmrvDOYqZYp0tq
         k+Zw==
X-Gm-Message-State: AOJu0YxgLgTg5j949Hn5tj0sHSmW5Q2VPuLyrzd56o5yIa4sigGp0xGO
	1THWaUvBze9kRUOhxzrIoI0tvLmfuo6jt1KH0z7Uf6OBduckWroieYlzYA==
X-Google-Smtp-Source: AGHT+IFbntVZSTeUSzJL1gi/cfp1/ciohkoF/r9+i0SVg6WY/pT+xBcwaIH2NfMc3CT1NvC2+Ygz1w==
X-Received: by 2002:a05:6820:1ad4:b0:5b9:fc9f:6a6c with SMTP id 006d021491bc7-5bdad9fd485mr3823757eaf.0.1718391109775;
        Fri, 14 Jun 2024 11:51:49 -0700 (PDT)
Received: from [192.168.1.21] (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id 006d021491bc7-5bd5e19ebb6sm548516eaf.25.2024.06.14.11.51.49
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Fri, 14 Jun 2024 11:51:49 -0700 (PDT)
Message-ID: <c516f9ae-1d32-4b84-a657-9ab57f27dfaf@gmail.com>
Date: Fri, 14 Jun 2024 13:51:48 -0500
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH] sysctl: Add setter / getter for char settings
To: ell@lists.linux.dev
References: <20240614160847.1085476-1-denkenz@gmail.com>
Content-Language: en-US
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20240614160847.1085476-1-denkenz@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

On 6/14/24 11:08 AM, Denis Kenzior wrote:
> ---
>   ell/ell.sym  |  2 ++
>   ell/sysctl.c | 24 ++++++++++++++++++++++++
>   ell/sysctl.h |  5 +++++
>   3 files changed, 31 insertions(+)
> 

Applied

