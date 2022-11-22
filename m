Received: from mail-pf1-f169.google.com (mail-pf1-f169.google.com [209.85.210.169])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 554A4746C
	for <ell@lists.linux.dev>; Tue, 22 Nov 2022 17:16:38 +0000 (UTC)
Received: by mail-pf1-f169.google.com with SMTP id x66so6355995pfx.3
        for <ell@lists.linux.dev>; Tue, 22 Nov 2022 09:16:38 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:to:from:subject:message-id:from:to:cc:subject:date
         :message-id:reply-to;
        bh=e/fYYlSj7SfcyA+qYgOeyl7GlLMvL5zYuePTt6i/CtE=;
        b=I7kWB2e74P+3AX1UEo3eIWFq96Jt3OsmGbAX/2w/Bjnv///AVNjvBgPhRydIlKuZix
         TlPwq+Me8RDLx98WVOaWKSLzgOBahiubfXs31XbKnmU7P+RcVq1k3Z53L1joNuZPGgm3
         m632h4pZxNCoFMTY0Lw3wRMCTTxhsrblRj46TTB4LamKybdLCduoax3suC9hbHyL9o/R
         Aa/nVdxkQ9z2uoZK8nd6GH2aH+qh7XuEXaU0DrsrndNR4nJQl+YjUAaxYrrfQxFl2CPu
         ciAHkQuPU9TfObkKnXNYLDc5PR1qj1Zay4azbxNdzm0C0x3ZcMhuGXGyvxD6RWeXUnEv
         EBmA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:to:from:subject:message-id:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to;
        bh=e/fYYlSj7SfcyA+qYgOeyl7GlLMvL5zYuePTt6i/CtE=;
        b=E9Xh+vagGCEH24xRjGEIdWct+49OXCLbyCSuAPXnU2O/rcqlK8+3tY3AA+hq/uR1NT
         DDgB5JiRsDWXZrgOQncmYmC1SpAonLpXIa7LHxiQBP3l4Q5/hoa5UHNgL/TaxOyT155W
         VCtscYjDLN4cVYWb4cdJ5o89D8U9TL+J9NKfvY5RiAgIx5kA3uVL7JYg7Sm9DrYSH47y
         TTOH3FjXYJMnrc0+kbRKI0sY6pDcLMiWH5Xsy8EKedmYx+4c1l2Q8TFzwFaDSMtSz9fc
         NNJdbwQAMVH8vzB4AwslEZOgw9zYv2N9CiE5Z336rvHOGqOEMN2lfeqYITQqPRHhvwnw
         tQpA==
X-Gm-Message-State: ANoB5pmuGAmxl5nlHdEFGJ6iL2ZgRnVuNlRScp3KEAruej//wl4wZlEe
	b2d5zX4nJ0YpTgURR0aladrpaLf5f58=
X-Google-Smtp-Source: AA0mqf7XpeQaZfagSQXZkkbfMPlgsDYHLAwvLCCL9BBAYKmxmYABkyh7RlO6q8W598fvBwHpzcppcQ==
X-Received: by 2002:a62:e80b:0:b0:56e:ad31:b98b with SMTP id c11-20020a62e80b000000b0056ead31b98bmr9219934pfi.40.1669137397586;
        Tue, 22 Nov 2022 09:16:37 -0800 (PST)
Received: from [192.168.254.55] ([50.39.160.234])
        by smtp.gmail.com with ESMTPSA id q4-20020a17090311c400b001865c298588sm12229895plh.258.2022.11.22.09.16.36
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 22 Nov 2022 09:16:37 -0800 (PST)
Message-ID: <176cde43f3fe383fbb096eeb3b4f7be8b212a19f.camel@gmail.com>
Subject: Re: [RFC 1/8] key: add l_key_search
From: James Prestwood <prestwoj@gmail.com>
To: Denis Kenzior <denkenz@gmail.com>, ell@lists.linux.dev
Date: Tue, 22 Nov 2022 09:16:36 -0800
In-Reply-To: <f4f33ae6-ba6f-e19a-89cb-6ba5c9a101f1@gmail.com>
References: <20221118211624.19298-1-prestwoj@gmail.com>
	 <20221118211624.19298-2-prestwoj@gmail.com>
	 <f4f33ae6-ba6f-e19a-89cb-6ba5c9a101f1@gmail.com>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.40.4 (3.40.4-5.fc34) 
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

On Tue, 2022-11-22 at 10:43 -0600, Denis Kenzior wrote:
> Hi James,
> 
> On 11/18/22 15:16, James Prestwood wrote:
> > Search for a key by type, keyring name, and description. Returns
> > the
> > key ID or an error if not found.
> > ---
> >   ell/ell.sym |  1 +
> >   ell/key.c   | 46 ++++++++++++++++++++++++++++++++++++++++++++++
> >   ell/key.h   |  3 +++
> >   3 files changed, 50 insertions(+)
> > 
> 
> <snip>
> 
> > @@ -283,6 +303,32 @@ static bool setup_internal_keyring(void)
> >         return true;
> >   }
> >   
> > +LIB_EXPORT int32_t l_key_search(enum l_key_type type, const char
> > *keyring,
> 
> How likely are we to search some custom keyring?  Wouldn't we
> generally be 
> searching a user/default user session keyrings?

I was just leaning on the side of flexibility. I don't really care
either way but figured an extra argument was fine even if we end up
calling it with "user".

> 
> > +                                       const char *description)
> > +{
> > +       long keyring_id;
> > +       long key_id;
> > +
> > +       if (unlikely((size_t)type >= L_ARRAY_SIZE(key_type_names)))
> > +               return -EINVAL;
> > +
> > +       if (unlikely(!keyring || !description))
> > +               return -EINVAL;
> > +
> > +       /* Find the ID of the keyring */
> > +       keyring_id = kernel_key_request("keyring", keyring);
> > +       if (keyring_id < 0)
> > +               return -ENOENT;
> > +
> > +       /* Search for the key by type/description */
> > +       key_id = kernel_key_search(keyring_id,
> > key_type_names[type],
> > +                                       description);
> > +       if (key_id < 0)
> > +               return -ENOENT;
> > +
> > +       return key_id;
> > +}
> > +
> >   LIB_EXPORT struct l_key *l_key_new(enum l_key_type type, const
> > void *payload,
> >                                         size_t payload_length)
> >   {
> 
> Regards,
> -Denis


