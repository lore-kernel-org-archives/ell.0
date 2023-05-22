Received: from mail-oo1-f51.google.com (mail-oo1-f51.google.com [209.85.161.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C7C5314266
	for <ell@lists.linux.dev>; Mon, 22 May 2023 14:20:17 +0000 (UTC)
Received: by mail-oo1-f51.google.com with SMTP id 006d021491bc7-5552cbcda35so916231eaf.1
        for <ell@lists.linux.dev>; Mon, 22 May 2023 07:20:17 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20221208; t=1684765217; x=1687357217;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :from:to:cc:subject:date:message-id:reply-to;
        bh=jICMtC7wRplVUN2uG014rI6IRwtDRycJO1AB5ViyLzo=;
        b=Inuuc2NExWLg9+fj3CfjPy5Fddrmrgj3t/B6Oixmg4xy4/RcUs77wLqbWrM8id1h7g
         GWRYFm6/O89epWbYIMpNh28Azc25IDLe48ONvZA76vkjYkkuuOHdHfcGnNW/KC3OYNKB
         T/pjzGYx8IATygE3FczWxkS7lU6pXsGEYMY2hUuz81NPYNsr3a61IpKP2EqIG/UvKFmn
         +Gcqhs+QDEvXzQ/6BIYpJrOIoyGZzod/o/NcaJWatLjLhXPuKToQ2/TmIu/EjSY6C6b9
         NiGUXJ/Lw+uwqjT72DuF7gR7y3T6CvMVVBnSIh3SVn+pfFk9pMnOgJqoxBPVb9oFjQyN
         chWw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20221208; t=1684765217; x=1687357217;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=jICMtC7wRplVUN2uG014rI6IRwtDRycJO1AB5ViyLzo=;
        b=frZQfUhlJZjwNfj4nxrW6eW4LLAxFm8p8Fcw3Or72wG6sz1aT0wkil2ysD+8/hea/5
         g1Cr7ZOuxbsI4VVG5BnT3jKF50EkgBSCnYfPuZLhZo7Vh0ZD+g56ouWnlN7FJVXX+ryB
         JhuOGhOtYZZcDEsRxBIqf76o4obGH9xaDNIHCuBT4wiFhuGH/KTN2OuddG7E/YxoDgfZ
         /QFtBYWrcDcdY7woxhLvP2m+BjwykK8bLe3McFw9XjcsU/VKUTghOOMYLTg+LUPBqTtY
         iMoKqrQ/NtcpXlA7G8OKbp1+VOzHuPzZZRd2tXmpL9lPOLihK4U0hKSeyCYvnp/xG7Nb
         HmNQ==
X-Gm-Message-State: AC+VfDzqxNds0JlWLWRQsAfnYBQd+POfXjcVIaIUhIlc7uF+VPeLp1Xs
	em0qRe/wrhO/MqrU7Mcfwh8=
X-Google-Smtp-Source: ACHHUZ7d1jDnMfspBicsE08nxQSMShp9nEFpY/Gji8qhOe49scrzpAXhkh8C5XSTHU8eqqX9xVxH+g==
X-Received: by 2002:a4a:7646:0:b0:555:51fd:a760 with SMTP id w6-20020a4a7646000000b0055551fda760mr1288707ooe.4.1684765216722;
        Mon, 22 May 2023 07:20:16 -0700 (PDT)
Received: from [10.0.2.15] (cpe-70-114-247-242.austin.res.rr.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id w45-20020a4a97b0000000b0051ffe0fe11bsm2668119ooi.6.2023.05.22.07.20.15
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Mon, 22 May 2023 07:20:15 -0700 (PDT)
Message-ID: <f8ebf389-6118-a1da-785e-5c21fcde36f3@gmail.com>
Date: Mon, 22 May 2023 09:20:14 -0500
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:91.0) Gecko/20100101
 Thunderbird/91.11.0
Subject: Re: [PATCH] genl: fix l_genl_family_cancel to wait for NLMSG_DONE
Content-Language: en-US
To: James Prestwood <prestwoj@gmail.com>, ell@lists.linux.dev
References: <20230518164715.275506-1-prestwoj@gmail.com>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20230518164715.275506-1-prestwoj@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi James,

On 5/18/23 11:47, James Prestwood wrote:
> If a genl request was already sent to the kernel a call to
> l_genl_family_cancel would remove it from the pending list
> immediately. This then allowed l_genl_family_send to queue
> another message before the previous/canceled message was
> completed. This is not how l_genl is intended to work.
> 
> Instead we can clean up the request immediately in
> l_genl_family_cancel but not remove it from the queue. This
> will prevent any more messages from being sent until NLMSG_DONE
> was received for the canceled message.
> ---
>   ell/genl.c | 14 +++++++++++++-
>   1 file changed, 13 insertions(+), 1 deletion(-)
> 

Applied, thanks.

Regards,
-Denis

