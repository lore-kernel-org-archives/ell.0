Received: from mail-qk1-f181.google.com (mail-qk1-f181.google.com [209.85.222.181])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8768A747E
	for <ell@lists.linux.dev>; Mon, 19 Sep 2022 23:57:04 +0000 (UTC)
Received: by mail-qk1-f181.google.com with SMTP id s9so599428qkg.4
        for <ell@lists.linux.dev>; Mon, 19 Sep 2022 16:57:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:x-gm-message-state:from:to:cc:subject:date;
        bh=t3FMRagCsg7AVEpmN+j0A1Yqefdanx/7sdMiyEp1RgU=;
        b=JcunKG/F6UgdJAMZwz2RoSVJ7tH045rxBTXETroBwJl5j7ttz1VcDcbKOsHwr4wqU6
         daYm4STpW/VygVChi26AIMHrbfff9eyaJId53nkLhJL0+OOONdHjRmZlwWGzJSqavmdw
         l5qpBPqJakmQKqDD7z0N8NXk/o+6swd6nTit5hHFxhy/JZG9fnBGlzf+/EefCaRCvx56
         QEb47jBDCdd8iXadSc7mjTgIXxVYqOm8dvnzmcD2q6fZQ7IJVSosoWXBJfn2wDBpoVaO
         0H7MMXxedWk+cFh6UCRgGamUujHfpd68jVnQv8jJWNnKOSwt+K5MXsmQriSMy8U8e13I
         mcFg==
X-Gm-Message-State: ACrzQf0eThoSoInCO4cMXBQi/tLKJI3L9J4TwxCMhxG3lrMow8VXxIyH
	5/2vduBDzLi+ARc0S+0PeHVXWdqB0EPDkA==
X-Google-Smtp-Source: AMsMyM4jvSFIprlzWsyPj81ZM5pzDXyr/ugkhAw7EcqUpEnlNpHjtmjHaODuy8rWBssDnfYsMFPBzw==
X-Received: by 2002:a05:620a:1189:b0:6cb:c4ae:9057 with SMTP id b9-20020a05620a118900b006cbc4ae9057mr14861167qkk.601.1663631823263;
        Mon, 19 Sep 2022 16:57:03 -0700 (PDT)
Received: from mail-yw1-f174.google.com (mail-yw1-f174.google.com. [209.85.128.174])
        by smtp.gmail.com with ESMTPSA id n7-20020a372707000000b006b5bf5d45casm12940881qkn.27.2022.09.19.16.57.02
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Mon, 19 Sep 2022 16:57:03 -0700 (PDT)
Received: by mail-yw1-f174.google.com with SMTP id 00721157ae682-349c4310cf7so8681177b3.3
        for <ell@lists.linux.dev>; Mon, 19 Sep 2022 16:57:02 -0700 (PDT)
X-Received: by 2002:a0d:dec4:0:b0:34d:167e:8221 with SMTP id
 h187-20020a0ddec4000000b0034d167e8221mr3761836ywe.339.1663631822729; Mon, 19
 Sep 2022 16:57:02 -0700 (PDT)
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <20220919133105.3129080-1-andrew.zaborowski@intel.com>
 <20220919133105.3129080-7-andrew.zaborowski@intel.com> <393c900e-f48c-d397-8388-51e5ca25050b@gmail.com>
In-Reply-To: <393c900e-f48c-d397-8388-51e5ca25050b@gmail.com>
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Date: Tue, 20 Sep 2022 01:56:51 +0200
X-Gmail-Original-Message-ID: <CAOq732JQmp_GuQagrvcksZZCrqDcUyQTDwdxbBu3WEPetahn1Q@mail.gmail.com>
Message-ID: <CAOq732JQmp_GuQagrvcksZZCrqDcUyQTDwdxbBu3WEPetahn1Q@mail.gmail.com>
Subject: Re: [PATCH 7/7] netconfig: Control optimistic DAD
To: Denis Kenzior <denkenz@gmail.com>
Cc: ell@lists.linux.dev
Content-Type: text/plain; charset="UTF-8"

Hi Denis,

On Mon, 19 Sept 2022 at 20:59, Denis Kenzior <denkenz@gmail.com> wrote:
> > @@ -1724,7 +1737,8 @@ static void netconfig_ifaddr_ipv6_added(struct l_netconfig *nc,
> >       struct in6_addr in6;
> >       _auto_(l_free) char *ip = NULL;
> >
> > -     if (ifa->ifa_flags & IFA_F_TENTATIVE)
> > +     if ((ifa->ifa_flags & IFA_F_TENTATIVE) &&
> > +                     !(ifa->ifa_flags & IFA_F_OPTIMISTIC))
> >               return;
>
> This implies that we set the link local address even if it is still OPTIMISTIC.
>   Do we now need to update icmp6_send_router_solicitation() logic to make sure
> we do not include SLLAO from optimistic addresses?

Good point.  I'll add an extra l_icmp6_client_set_link_local_address()
parameter to indicate whether the address is optimistic and make sure
we call it again after DAD finishes.

Best regards
