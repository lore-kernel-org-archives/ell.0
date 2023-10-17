Received: from mail-oo1-f41.google.com (mail-oo1-f41.google.com [209.85.161.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A1E0E44474
	for <ell@lists.linux.dev>; Tue, 17 Oct 2023 15:08:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="nZKbqc/1"
Received: by mail-oo1-f41.google.com with SMTP id 006d021491bc7-57e40f0189aso3047680eaf.1
        for <ell@lists.linux.dev>; Tue, 17 Oct 2023 08:08:06 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1697555285; x=1698160085; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :from:to:cc:subject:date:message-id:reply-to;
        bh=/uQQrpTGBQ3g19Eddrpd6ymty7zaE4bf/hLqYDyz52k=;
        b=nZKbqc/1BC7j8cUlSf/TcvyZtB3QQVOm9Jb518URnzsmtMfL0rV6aFBQDES/iyZO3Y
         rG+WYBGF6Ucb0ZAQaS88GmwaLTB2UQh1HjnFO2NbtaEQKFL8avYvFLrLZqfEvhCO9LnI
         ADnScmUJa7uAaD3v5fNslW491KjYLrmGSh/g1iTeiYSIPgAi521p2dzutAcGa0/Zg4so
         602h/BuVUdXnKCyNuy4Fz1cxyqSXv/zyI/noq8CLXXkmX1N1GjAubpug3aCd3+906lSE
         dj08XbXgti3JNARKG9N1hMmCxYTq3geOxIWrR++8wMm/QWLN8F06rndcUP99vNSwPlpd
         b7tw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1697555285; x=1698160085;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=/uQQrpTGBQ3g19Eddrpd6ymty7zaE4bf/hLqYDyz52k=;
        b=UPxwEgBV56qswuqDIQ/85gASrRtfHmj31djAz3iKYR2YXmglLQY5xAhOAKjPL831tV
         b7tnyS8v3NHJsYtOtrxcRkgxzmPwpCTUpYY3OixpCqMXEgmQu+7/ZNnjmP2gitqVnUC4
         31Rflt7X7eOJojRT1xAS5zos+IEHU97QfL/wACjSN1DAGdJxvKHZMcC4v6B+SwmUGqvN
         y6Uwh4KDsuPo2nhWrbJNSad9yv/ydC4wT04fpVVMrBz722eJhJqJxg3ssHlgn7gXqmcQ
         OGu0feqbBJI8Xjf2bVy9aXAr9WFnrLk9IL2CiXzCOuPxwk+PpGBpKRIHYiuGMan7aS40
         kvqQ==
X-Gm-Message-State: AOJu0Yx1jyrnCf3CdAtQRWnsBmykIIzm91M4ZPzFVbarkgHAIupiw+09
	DN/fx8f49/etW5FVoq9rMmudL3TOXvI=
X-Google-Smtp-Source: AGHT+IGZKOTelYw1iymB21Ny8R3/LdPOtJ3lBPbt3uwV1soKiB7zl5wBulWg7pRsK9ugThl+gqNegA==
X-Received: by 2002:a4a:4304:0:b0:57b:77bb:6b19 with SMTP id k4-20020a4a4304000000b0057b77bb6b19mr2243552ooj.4.1697555285500;
        Tue, 17 Oct 2023 08:08:05 -0700 (PDT)
Received: from [172.16.49.130] (cpe-70-114-247-242.austin.res.rr.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id h23-20020a9d6017000000b006b9848f8aa7sm292416otj.45.2023.10.17.08.08.04
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Tue, 17 Oct 2023 08:08:05 -0700 (PDT)
Message-ID: <a07bc07e-a2ae-4a3a-8698-190cd758955c@gmail.com>
Date: Tue, 17 Oct 2023 10:08:03 -0500
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: =?UTF-8?B?UmU6IFtQQVRDSF0gZ2VubDogZml4IOKAmGF0dHJfZ3JwLm5leHRfbGVu?=
 =?UTF-8?Q?=E2=80=99_may_be_used_uninitialized?=
Content-Language: en-US
To: MaxLyubimov <m.lyubimov@aqsi.ru>, ell@lists.linux.dev
References: <4103d54928605fb3d2a573ba6890395b4a155138.camel@aqsi.ru>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <4103d54928605fb3d2a573ba6890395b4a155138.camel@aqsi.ru>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

Hi Max,

On 10/16/23 13:39, MaxLyubimov wrote:
> make --no-print-directory all-am
>    CC       ell/genl.lo
> ell/genl.c: In function ‘parse_cmd_newfamily.part.0’:
> ell/genl.c:1728:5: error: ‘attr_grp.next_len’ may be used uninitialized
> in this function [-Werror=maybe-uninitialized]
>   1728 |  if (!NLA_OK(nla, attr->next_len))
>        |     ^
> ell/genl.c:268:22: note: ‘attr_grp.next_len’ was declared here
>    268 |   struct l_genl_attr attr_grp;
>        |                      ^~~~~~~~
> ell/genl.c:1732:14: error: ‘attr_grp.next_data’ may be used
> uninitialized in this function [-Werror=maybe-uninitialized]
>   1732 |   *type = nla->nla_type & NLA_TYPE_MASK;
>        |           ~~~^~~~~~~~~~
> ell/genl.c:268:22: note: ‘attr_grp.next_data’ was declared here
>    268 |   struct l_genl_attr attr_grp;
>        |                      ^~~~~~~~
> ell/genl.c:1728:5: error: ‘attr_op.next_len’ may be used uninitialized
> in this function [-Werror=maybe-uninitialized]
>   1728 |  if (!NLA_OK(nla, attr->next_len))
>        |     ^
> ell/genl.c:240:22: note: ‘attr_op.next_len’ was declared here
>    240 |   struct l_genl_attr attr_op;
>        |                      ^~~~~~~
> ell/genl.c:1732:14: error: ‘attr_op.next_data’ may be used
> uninitialized in this function [-Werror=maybe-uninitialized]
>   1732 |   *type = nla->nla_type & NLA_TYPE_MASK;
>        |           ~~~^~~~~~~~~~
> ell/genl.c:240:22: note: ‘attr_op.next_data’ was declared here
>    240 |   struct l_genl_attr attr_op;
>        |                      ^~~~~~~
> cc1: all warnings being treated as errors
> make[1]: *** [Makefile:4032: ell/genl.lo] Error 1
> make: *** [Makefile:2348: all] Error 2
> ---
>   ell/genl.c | 6 ++++--
>   1 file changed, 4 insertions(+), 2 deletions(-)
> 

I added a space between 'Max' and 'Lyubimov' in your author tag.  Tell me if 
this was incorrect.  If it was correct, can you please fix your git config?

> diff --git a/ell/genl.c b/ell/genl.c
> index def3790..33ecc4d 100644
> --- a/ell/genl.c
> +++ b/ell/genl.c
> @@ -240,7 +240,8 @@ static void family_ops(struct l_genl_family_info
> *info,
>   		struct l_genl_attr attr_op;
>   		uint32_t id = 0, flags = 0;
>   
> -		l_genl_attr_recurse(attr, &attr_op);
> +		if (!l_genl_attr_recurse(attr, &attr_op))
> +			continue;
>   
>   		while (l_genl_attr_next(&attr_op, &type, &len, &data))
> {

Something in your mail server is messing with the text format.  I had to 
manually edit the patch so it would apply properly (by e.g. removing the newline 
before this '{').  Please fix that since I can't do this for more than the 
simplest patches.

>   			switch (type) {
> @@ -269,7 +270,8 @@ static void family_mcast_groups(struct
> l_genl_family_info *info,
>   		const char *name = NULL;
>   		uint32_t id = 0;
>   
> -		l_genl_attr_recurse(attr, &attr_grp);
> +		if (!l_genl_attr_recurse(attr, &attr_grp))
> +			continue;
>   
>   		while (l_genl_attr_next(&attr_grp, &type, &len, &data))
> {
>   			switch (type) {
> 
> 

Applied, thanks.

Regards,
-Denis
