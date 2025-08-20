Received: from mail-ot1-f45.google.com (mail-ot1-f45.google.com [209.85.210.45])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8A249322A1C
	for <ell@lists.linux.dev>; Wed, 20 Aug 2025 16:14:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.45
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1755706481; cv=none; b=fA0nui6sWqPum8qlV3L3Kr7uyNGRendvq3aZDEp3jzEag0kHTGkU/mr79SPwJpKyl/1ZoKEowwhH9gouxZ7WypWxayCIKbsOJBn+WSTtdQWwABQknc0m3LEb0ZevlC9+zccS3lRodBBWtbe7sR9SbCUh84WjQH+mrULg93WgBjE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1755706481; c=relaxed/simple;
	bh=yJjOzWRSKxhx5IDWrWvBmvOzWWUdI/m4ndxdQjHyGZg=;
	h=Message-ID:Date:MIME-Version:Subject:To:References:From:
	 In-Reply-To:Content-Type; b=E5FhAi0fwTu+iNGVyZtpSpe2O8/0nalj/A3FcxQadGBRl1wt+EF4nW/XcMlud6g6AXnU1pJ7COqgz4Br/L6oAq77RjsNno0SCep7jlbS07gmKPyZDmKnntHisS2WPeMMIT72WDwXNZQ/c/TPIfY1CHeLDgl1RV+ya6akaJTRYy0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=U+aFUP2l; arc=none smtp.client-ip=209.85.210.45
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="U+aFUP2l"
Received: by mail-ot1-f45.google.com with SMTP id 46e09a7af769-7438200b29cso1290024a34.3
        for <ell@lists.linux.dev>; Wed, 20 Aug 2025 09:14:39 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1755706478; x=1756311278; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id:from
         :to:cc:subject:date:message-id:reply-to;
        bh=P+10ZH83X4osTUwNV6jLYbeplC0QFz78ySstW3rb8zs=;
        b=U+aFUP2lESSyYJ3ilAeQR3W9+jyFgtvS1NBGeNlwuv7FwQjeFBOKCl+C5DO+JzAN+o
         8L0SsY0P76VEbzodxYZH1nBpaI91HLS5APNPogpm7Xp/ICcxN11JRqED+GgmN3t6A/bN
         McQaddHL1Z6WFdbzlDc+2zW8Hrxz+q+YzHkgENfJe3gpDqELVAdxJ5bAwcGVD/8n129U
         5FcNeLKR6PBEmt++K8cXvSFptoyHUAEfaHma6zveRUYopFsCBWVqcr4BMZSt3Ni9oPEJ
         yHNhaM3tn/9Qi0sTKGcm4WaOiY+JBSouYnssp3tx7CfERz4ZMwa5U9HvoscpEZCFU6L+
         ZMrA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1755706478; x=1756311278;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=P+10ZH83X4osTUwNV6jLYbeplC0QFz78ySstW3rb8zs=;
        b=JyRJ6PNer5vta+9Hha7/hlMV62x2fe4IHX0idsTTiXpxkWjQBI5z2/A+YeK1VvKXYG
         cpjh3/3+0OmcGNaGopSchCP/j+ByTLrlKJ5nZ1JmofUaZBfIdDpLlxBZxssPcJ/mdF9A
         w3O9HuseYxEHdFzMyVeR2NPbPxFSPassF4foiXvfygJkE2lrUa3PlIIJLh0o94zGFfG0
         uLfzSoHY7EnkPKh0iBAD9mTchkaDuliKj7HHDWKDHP9NOG6qG57DfAlN66Vi9Qh3o+cV
         5N7jdbatMKo04musmeFAx1jt8AwL9rPTq3/mLHzNVVVlAMps6HiWAYMty0KdQ1Wcxrcs
         MnFg==
X-Forwarded-Encrypted: i=1; AJvYcCWy5IAHhj5hbXtzq66iU4DrM23NcEnDRVsjEr4J5gfkD6XS0Q/+deW3kt5MP0mYIQh0MN8=@lists.linux.dev
X-Gm-Message-State: AOJu0YyYNCNVeuBz5Wjh5fOZc5h6BXrJcjVcnYMPGZ6wA9CanbIjE0W+
	mqgM7EFL/UIvzg1ttIGzIDazQXwKM/wrnEXf51WR4eFNFZDfsHOLQQE0mFCIfw==
X-Gm-Gg: ASbGncv7MpC9JAsU+yw9Aeoicav8bom/3qEn4CWSBAT4Jh5ddI3FQ+NEgO52FK0Qpzi
	3562BQ8xysGvzbJlz26IbRmRbamwYBUEwZM7n3ZVcEjYqinVvWDU72QkqtdiAw1WJnc29/fQos9
	ceR4ZgZICqb9n7i55qLTxeoSm68QBl+HxpHykujshPmPzAg2/XpT4s0b/lQIr1NzM40e1KVa+Dz
	QdVUhiv72NbcVFcTRf8fSZxfUEHEjtFjjxhyL8M8YeZ7ttYXSDjryWzvjxCNg/GYe+DRbqrOZNZ
	BB9gMV8SeWepiEp1omz9eP69IkW4j1gnqu52QY5qYzC1SnyFs7yy0fQBqJs12ti+xGVkQXeLjRq
	wVlnQjAdeq0jx6giKJEZgO4hv0X01wmxAyzQWUa/iHZmsMuuKTHGPUAe4fdfzdpxlnAUpMfvc3Z
	s9EnP3NAkfSA==
X-Google-Smtp-Source: AGHT+IGl2qgNyxZFkTYIWrFicXfvzxmV8NOsORzmO4oHKAu530ZtugpLOynu1UoiQ58YwZUfumnfcA==
X-Received: by 2002:a05:6830:4997:b0:742:fc4d:6615 with SMTP id 46e09a7af769-744ebc036c7mr1911516a34.18.1755706478286;
        Wed, 20 Aug 2025 09:14:38 -0700 (PDT)
Received: from [172.16.49.130] (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id 006d021491bc7-61d9af7ae01sm267432eaf.2.2025.08.20.09.14.37
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Wed, 20 Aug 2025 09:14:38 -0700 (PDT)
Message-ID: <f1948e15-c78a-4498-ba8b-04f4015eb041@gmail.com>
Date: Wed, 20 Aug 2025 11:14:36 -0500
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH] tls: Fix possible memory leak
To: Bastien Nocera <hadess@hadess.net>, ell@lists.linux.dev
References: <20250820141403.800412-1-hadess@hadess.net>
Content-Language: en-US
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20250820141403.800412-1-hadess@hadess.net>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi Bastien,

On 8/20/25 9:13 AM, Bastien Nocera wrote:
> ell/tls-suites.c:784:3: leaked_storage: Variable "other_public" going out of scope leaks the storage it points to.
> ---
>   ell/tls-suites.c | 1 +
>   1 file changed, 1 insertion(+)
> 

Applied, thanks.

Regards,
-Denis
