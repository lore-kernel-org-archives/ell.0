Received: from mail-pg1-f172.google.com (mail-pg1-f172.google.com [209.85.215.172])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7322E3222
	for <ell@lists.linux.dev>; Tue, 22 Nov 2022 18:34:39 +0000 (UTC)
Received: by mail-pg1-f172.google.com with SMTP id b62so14827425pgc.0
        for <ell@lists.linux.dev>; Tue, 22 Nov 2022 10:34:39 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:to:from:subject:message-id:from:to:cc:subject:date
         :message-id:reply-to;
        bh=Ujs0zXABENyAj1HfmySIylqCszr86Fw0aYerKmdB0KU=;
        b=YiBUdtBBb8m8zX0XTBmOfhT95VRti7C2qGjH3RFHPtdWYRSM3Ljh1HPfeljRUyGPKv
         Co+OyvwnCQE0XEK+EyU3Hdudn8q+avdcntCZRG7GNuwbKI2i/L7jXqJf/9QD8krZxZpR
         mWV0qhP4o2jeRS3nWhcqHnAkLpQFfox1Oh6YVNAAQx3nGUhXL+5rIoziYBng2pzFy1Co
         jxhVnoSvt78FHbGEt2dMC2CiL0KOsG3yQjeRZ3+T+lC0zGZgitkffYxdJpfGzZG7UPcW
         64SbIMuBbFL5ApguB1O694c2wTNH7RbkjdhwqISfiHkXnpxuPGgz3ie0lXvvU52wnWNJ
         B32A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:to:from:subject:message-id:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to;
        bh=Ujs0zXABENyAj1HfmySIylqCszr86Fw0aYerKmdB0KU=;
        b=EaqEgTad1oP4ZOHmOhCOR6q3hZFyq3qFNfpAbUhOoPyylEjgghO75yebWdfWZtDuOy
         C/q55eNTcMt0LsK+AgPSzNNFsqEQ4zQKVk8DImR7spNSLl0xbJHBCaqH/cVraEf7wUbO
         IrhpnZ+A5M0qZx5TDHp3s6vHHySKKl30tppJFhVbdDT0JmkCpveJ4HFii+gDZu9t2B/f
         POotJi++wjbH5TogrwB6de1AEIpmhmqJj3rBPE+ulVL9bje6uhkbVkAZluEt6Ocyefxy
         cY+peX35oAqnXakyyxWhzrT2v4GRgGhSx02f+Qn5+m6kswXjBGIEoy061qN5F2SHcoL+
         aVdg==
X-Gm-Message-State: ANoB5pnaEYJ0kwELm03EQb3J+Zfht4ITsRBpWt+q0DaoIX14XnHVXep1
	79hruTR6RKEUIb96qwUNH1I=
X-Google-Smtp-Source: AA0mqf7fFZ6UPDUrY2xGuzm2kwjyi9xX1ILLjKcZJkXoZBpGCTfsxwsW9PPmCRM2GCCQQx/Pcxmdzw==
X-Received: by 2002:a63:165d:0:b0:473:f7cd:6603 with SMTP id 29-20020a63165d000000b00473f7cd6603mr4303184pgw.336.1669142078806;
        Tue, 22 Nov 2022 10:34:38 -0800 (PST)
Received: from [192.168.254.55] ([50.39.160.234])
        by smtp.gmail.com with ESMTPSA id nk5-20020a17090b194500b0021891961cdcsm7285135pjb.43.2022.11.22.10.34.38
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 22 Nov 2022 10:34:38 -0800 (PST)
Message-ID: <7e5b6d604a2d4314495c02c84c91255aa41fe487.camel@gmail.com>
Subject: Re: [RFC 1/8] key: add l_key_search
From: James Prestwood <prestwoj@gmail.com>
To: Denis Kenzior <denkenz@gmail.com>, ell@lists.linux.dev
Date: Tue, 22 Nov 2022 10:34:38 -0800
In-Reply-To: <ba521a25-fd9b-189c-a607-02cd897cae32@gmail.com>
References: <20221118211624.19298-1-prestwoj@gmail.com>
	 <20221118211624.19298-2-prestwoj@gmail.com>
	 <f4f33ae6-ba6f-e19a-89cb-6ba5c9a101f1@gmail.com>
	 <176cde43f3fe383fbb096eeb3b4f7be8b212a19f.camel@gmail.com>
	 <ba521a25-fd9b-189c-a607-02cd897cae32@gmail.com>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.40.4 (3.40.4-5.fc34) 
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

On Tue, 2022-11-22 at 11:09 -0600, Denis Kenzior wrote:
> Hi James,
> 
> > > > +LIB_EXPORT int32_t l_key_search(enum l_key_type type, const
> > > > char
> > > > *keyring,
> > > 
> > > How likely are we to search some custom keyring?  Wouldn't we
> > > generally be
> > > searching a user/default user session keyrings?
> > 
> > I was just leaning on the side of flexibility. I don't really care
> > either way but figured an extra argument was fine even if we end up
> > calling it with "user".
> 
> So this function would perform some sort of !strcmp conversion
> between "user" 
> and KEY_SPEC_USER_KEYRING?  That's fine I suppose.

Ah, I kinda overlooked the fact the user keyring is actually named
something like "_uid.foo". And in theory "user" could be an actual
custom keyring... So defaulting to KEYS_SPEC_USER_KEYRING seems like
the most logical option, and if we need custom keyrings we could add
l_keyring_search().

> 
> Regards,
> -Denis


