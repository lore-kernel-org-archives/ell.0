Received: from mail-oa1-f46.google.com (mail-oa1-f46.google.com [209.85.160.46])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1628449638
	for <ell@lists.linux.dev>; Fri, 14 Jun 2024 18:51:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.160.46
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1718391081; cv=none; b=l0Qtgx38yoclzMcfrben/ReigVMvZNFNAJStVu4Lhw0cGKHF9roGCwYPf/5udyh3btERGvW/OY1jfKk81vh36vSD9rZdB5kFBoggakb9brn8ZYRWlW8PNR2j3CU/mSKnK1816oH3vxGBCuZizrPzlgISWVH6JlNx/GuDnTSG5bI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1718391081; c=relaxed/simple;
	bh=e2P3Rh5OdDI30caRGqwqChCkrTCR1QOHXkj5OwHIyBs=;
	h=Message-ID:Date:MIME-Version:Subject:To:References:From:
	 In-Reply-To:Content-Type; b=DGYqnrYpEkt25UwuMowEH6bodpPMHevLsMvTUh0kWSfpi2QeSid//GDQVXkRjliwTf4Aml0LdGIqyCn0Apsi7+RsJX9x2z5/zsJEvrjbbYJF0Ar5Knxg5aWJGjwCEVnvcJ65ypCAchEO9jCUIqWwoYkZWpypuAX8geaYmMK5ax8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=mwiMerpx; arc=none smtp.client-ip=209.85.160.46
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="mwiMerpx"
Received: by mail-oa1-f46.google.com with SMTP id 586e51a60fabf-24c9f73ccaaso1379216fac.1
        for <ell@lists.linux.dev>; Fri, 14 Jun 2024 11:51:19 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1718391079; x=1718995879; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id:from
         :to:cc:subject:date:message-id:reply-to;
        bh=EHnUSxiA62QZpBPpmtVmSOr0529S1KyJPJKYTCVMly0=;
        b=mwiMerpxTcqYU2/U/N6fWQ5FRxhpyc0VpV/dIB/aUmw0A1L8swjsLKtQanJ1U8lxC7
         ZamVDXxUH/BenRAwKMZW1dh0ef8EbxZQYD1lAlaO+uqSglcNCxKvErqP+gcv8k3BDrse
         pfIc2KzCbeQ/q6V17KMCrkUSL+T2jlOWAfZ0dKfp9K77+WKbmYdJl4OvUgaB6DeJSnLw
         rbRvUS9q7eYIBXfi1HY/DVW/1JInl2035MGEOtC2uVMnuagnE+tHozb2RpA8UHS2wxf8
         tPbREnV9Et4wnwyG43dPHJ8qgXlrVFKxu12Cqu8yhBvu5Pa1XjOad+NScEPIyuH2eMBp
         mnqw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1718391079; x=1718995879;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=EHnUSxiA62QZpBPpmtVmSOr0529S1KyJPJKYTCVMly0=;
        b=MiC14N2uY4yXipTe+OA4oCqf4vFpZ49jeztw77LAJzy8tVrStW2WDc4cJP3cvpsBDY
         4t0Pt9xd+9avuBBfepvKDoeHvltKf8TebJdIj7///zUlI7vlkC41o2bzbQMca6dE4Wvu
         8ngxqBMmG1mE+Dx1s1wGWdUlIqk/0uslqwy3dQdUSvJFSAgfLdDRxC1S4SpeKzhyoIs1
         OQN3uCNJi9gslWXdquOGKe7s1h9dhVnff1F+pwzn/XT7oBilL105JZBN8XorsuwttZaA
         jsZgxEl8RFGsoLe5aI6faoneJqwWm70TkzMEY2h2Dn70Cp6PQ8RFO33IlURwI/2hh0Ui
         Scsg==
X-Gm-Message-State: AOJu0YwFucHNKvCTZdFnVeiCkCW4rbFi20taP4QUSRCeZojq11qazUHG
	2ni9ZHdwYhcQBQ+FG5zn62xWZkTUGASks6Xoo8+CzrwNL4rlmJFwF9FhXw==
X-Google-Smtp-Source: AGHT+IHkr7+vAD4FGSSOewYiTTh/3pdT4I6GLpxtjByWPu33XGMJ/TOjzGhPwS0OeVBY4xV7GDuZFA==
X-Received: by 2002:a05:6870:b618:b0:254:c617:a9a0 with SMTP id 586e51a60fabf-25842c137e7mr4098004fac.50.1718391078872;
        Fri, 14 Jun 2024 11:51:18 -0700 (PDT)
Received: from [192.168.1.21] (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id 586e51a60fabf-2567a9a7d31sm1086810fac.14.2024.06.14.11.51.18
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Fri, 14 Jun 2024 11:51:18 -0700 (PDT)
Message-ID: <6ab82eab-29ff-4055-b0e7-ba47e9b3d35f@gmail.com>
Date: Fri, 14 Jun 2024 13:51:17 -0500
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH] genl: re-implement unicast_watch using l_notifylist
To: ell@lists.linux.dev
References: <20240531212408.738767-1-denkenz@gmail.com>
Content-Language: en-US
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20240531212408.738767-1-denkenz@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

On 5/31/24 4:23 PM, Denis Kenzior wrote:
> ---
>   ell/genl.c | 122 ++++++++++++++++++-----------------------------------
>   1 file changed, 40 insertions(+), 82 deletions(-)

Applied

