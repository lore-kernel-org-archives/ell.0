Received: from mail-lf1-f47.google.com (mail-lf1-f47.google.com [209.85.167.47])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E54DE2F24
	for <ell@lists.linux.dev>; Mon,  9 Jan 2023 12:21:45 +0000 (UTC)
Received: by mail-lf1-f47.google.com with SMTP id m6so12632600lfj.11
        for <ell@lists.linux.dev>; Mon, 09 Jan 2023 04:21:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=D0e3x7itN9s99rIxPnNY781dLpYPfTM5IxTYxOmBOwM=;
        b=YYQDLBjMAaVNDMBSzIoSKYTvBO/xG7iPZfHREC9PhMkHX5T1pk0Vns+6uvk9oix2AJ
         4kejOFt6ll/Egs1mmyvrVXCdf3NsE1t48qjNSz6nse8Sga8f3VZZ3igSNYDBsGunvlcd
         E0BU6DrXQJq5aqGTG5pJFsrH0kh0qRy85BXQ+URnDvYZ/LBYgKzHcch9Y+lHUCYZcWqJ
         MuXxlBZcxRNg/uc12ZKEsEO3UnCgdiNRNVw3eBJygchslfHV7+ttV0HYpEXP1axIyZt5
         Tx6rocNpdm28sopkg1rlYoH7moUdXrjwOtjpp0/vkSWWJJVXpA0rXPt3Goxtdf1PRVoh
         xITg==
X-Gm-Message-State: AFqh2kp937FH9miz24v/WKGD0ZiqpOUCV7j71TmpoAEf934KD06/f1Wa
	HIYH5BvWP+5qOIB7dI2zxCjgKYVFH8ZqIw==
X-Google-Smtp-Source: AMrXdXu8UjQO+nMNVV6B8TYR5e/w0VTrHcdpuJLDNASxVhtjgVPNqcOobo1FjgsXKOcwFcq0wiIqCA==
X-Received: by 2002:a05:6512:23a9:b0:4cb:4371:f14d with SMTP id c41-20020a05651223a900b004cb4371f14dmr6725635lfv.17.1673266903402;
        Mon, 09 Jan 2023 04:21:43 -0800 (PST)
Received: from mail-lj1-f170.google.com (mail-lj1-f170.google.com. [209.85.208.170])
        by smtp.gmail.com with ESMTPSA id u4-20020a05651220c400b004b4b600c093sm1587087lfr.92.2023.01.09.04.21.42
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Mon, 09 Jan 2023 04:21:42 -0800 (PST)
Received: by mail-lj1-f170.google.com with SMTP id n5so8124870ljc.9
        for <ell@lists.linux.dev>; Mon, 09 Jan 2023 04:21:42 -0800 (PST)
X-Received: by 2002:a2e:a882:0:b0:280:51a:7297 with SMTP id
 m2-20020a2ea882000000b00280051a7297mr1156595ljq.49.1673266902018; Mon, 09 Jan
 2023 04:21:42 -0800 (PST)
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <20230103220250.717876-3-marcel@holtmann.org> <CAOq732KFvqDu94GGkUfBBszgR-yrCqUj2Lqx3=oPGdKDem0Zjw@mail.gmail.com>
 <1E8A2AE4-86F5-4D0A-A0A0-DC0359466523@holtmann.org>
In-Reply-To: <1E8A2AE4-86F5-4D0A-A0A0-DC0359466523@holtmann.org>
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Date: Mon, 9 Jan 2023 13:21:29 +0100
X-Gmail-Original-Message-ID: <CAOq732KFWmSjq1LWzpQ_V4ZQVjEZ4WUHcyGzZ5UXHc6TH9UvRA@mail.gmail.com>
Message-ID: <CAOq732KFWmSjq1LWzpQ_V4ZQVjEZ4WUHcyGzZ5UXHc6TH9UvRA@mail.gmail.com>
Subject: Re: [PATCH 3/3] tls: Add support l_tls_set_alpn_list() and ALPN extension
To: Marcel Holtmann <marcel@holtmann.org>
Cc: ell@lists.linux.dev
Content-Type: text/plain; charset="UTF-8"

Hi Marcel,

On Thu, 5 Jan 2023 at 16:15, Marcel Holtmann <marcel@holtmann.org> wrote:
> >> +static bool tls_alpn_server_absent(struct l_tls *tls)
> >> +{
> >> +       if (!tls->alpn_list)
> >> +               return false;
> >
> > I believe this returning false will break most usages of l_tls.
>
> can you elaborate why? When are you allowed to return false.

false here means that the extension should have been present, i.e. we
signal an error.  If the extension code thinks we're fine to proceed
it returns true.

This also makes the unit test fail.

Best regards and happy new year
