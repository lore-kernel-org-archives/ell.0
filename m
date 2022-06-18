Received: from mail-lj1-f178.google.com (mail-lj1-f178.google.com [209.85.208.178])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BD9A67B
	for <ell@lists.linux.dev>; Sat, 18 Jun 2022 00:38:41 +0000 (UTC)
Received: by mail-lj1-f178.google.com with SMTP id c30so6287573ljr.9
        for <ell@lists.linux.dev>; Fri, 17 Jun 2022 17:38:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=vCJp9mTex/5DjbYUt+hXLuAk7/PcD+7hw4+3hwOYNuM=;
        b=K+kflhxp6p+FY/uT0iqiV5l3PjKKg8XB2eaNf7xDcWAizBqNd6YvVxhZzLc0jNtoLO
         lhW8y1XDrNR9xBEJTaFE0ZRjdXOhu6walT8+yOlxzDWmTt5aFnZAx+h990X634DKJnIk
         B9C07oyyutTvz+fqn7zNUJcipuep/kzlS8d3XrW6EGNZfllT57VMKn7NpWZsegccQ2W6
         TZ9fqx2d9Hh0wsnlTGTVpS1eG7NVBT6JlmXV45paYH6HlMV+Kuw7NgPUEfPc7iHTVxBK
         yZC3WUNUK5bcm2R4LDbn6lprhhztBDN4AgBtOZKtkNXydVCpYYE+VDUPlLbjQRHxD3rE
         pjEw==
X-Gm-Message-State: AJIora9+cxZ95Z1CweOI7K9U+rKbLdkr/1JAyakJpyVdZ54KLnqTlDL6
	yokpA1bbMO8T+niG/INLNZYw2PhnLi8RyA==
X-Google-Smtp-Source: AGRyM1velmXdESK5XPp7veV641dcvo7rmbP25I42XyeH3RZ/wjtK1UK6M8TjWumK9OVNGJDgeqiSFw==
X-Received: by 2002:a05:651c:1542:b0:249:5d86:3164 with SMTP id y2-20020a05651c154200b002495d863164mr6474559ljp.500.1655512719440;
        Fri, 17 Jun 2022 17:38:39 -0700 (PDT)
Received: from mail-lj1-f172.google.com (mail-lj1-f172.google.com. [209.85.208.172])
        by smtp.gmail.com with ESMTPSA id e10-20020a19674a000000b004796e1555eesm817124lfj.199.2022.06.17.17.38.38
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Fri, 17 Jun 2022 17:38:38 -0700 (PDT)
Received: by mail-lj1-f172.google.com with SMTP id h23so6305990ljl.3
        for <ell@lists.linux.dev>; Fri, 17 Jun 2022 17:38:38 -0700 (PDT)
X-Received: by 2002:a2e:a792:0:b0:255:8bcb:7d36 with SMTP id
 c18-20020a2ea792000000b002558bcb7d36mr6122268ljf.218.1655512718299; Fri, 17
 Jun 2022 17:38:38 -0700 (PDT)
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <20220615224739.1936538-1-andrew.zaborowski@intel.com>
 <20220615224739.1936538-7-andrew.zaborowski@intel.com> <da1459dd-2402-161e-b24f-f55a02356a31@gmail.com>
In-Reply-To: <da1459dd-2402-161e-b24f-f55a02356a31@gmail.com>
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Date: Sat, 18 Jun 2022 02:38:26 +0200
X-Gmail-Original-Message-ID: <CAOq732KHUW1zSHR1G6=fK9yhYiHYeOLCZ3jUAmSt_NUGTJroLw@mail.gmail.com>
Message-ID: <CAOq732KHUW1zSHR1G6=fK9yhYiHYeOLCZ3jUAmSt_NUGTJroLw@mail.gmail.com>
Subject: Re: [PATCH 07/14] netconfig: Add getters for DNS addresses and domain names
To: Denis Kenzior <denkenz@gmail.com>
Cc: ell@lists.01.org, ell@lists.linux.dev
Content-Type: text/plain; charset="UTF-8"

Hi Denis,

On Fri, 17 Jun 2022 at 18:32, Denis Kenzior <denkenz@gmail.com> wrote:
> Hi Andrew,
>
> On 6/15/22 17:47, Andrew Zaborowski wrote:
> > ---
> >   ell/ell.sym     |  2 ++
> >   ell/netconfig.c | 64 +++++++++++++++++++++++++++++++++++++++++++++++++
> >   ell/netconfig.h |  2 ++
> >   3 files changed, 68 insertions(+)
> >
>
> So I applied all patches in this series

Great.

> except this one.  Just a minor nit here:
>
> > diff --git a/ell/ell.sym b/ell/ell.sym
> > index 50f8909..d74e8c9 100644
> > --- a/ell/ell.sym
> > +++ b/ell/ell.sym
> > @@ -757,6 +757,8 @@ global:
> >       l_netconfig_apply_rtnl;
> >       l_netconfig_get_addresses;
> >       l_netconfig_get_routes;
> > +     l_netconfig_get_dns_list;
> > +     l_netconfig_get_domain_names;
> >   local:
> >       *;
> >   };
> > diff --git a/ell/netconfig.c b/ell/netconfig.c
> > index ce5bfe3..94faef0 100644
> > --- a/ell/netconfig.c
> > +++ b/ell/netconfig.c
> > @@ -1425,3 +1425,67 @@ LIB_EXPORT const struct l_queue_entry *l_netconfig_get_routes(
> >
> >       return l_queue_get_entries(netconfig->routes.current);
> >   }
> > +
> > +/* Returns a new strv array to be freed by the caller */
> > +LIB_EXPORT char **l_netconfig_get_dns_list(struct l_netconfig *netconfig)
> > +{
> > +     char **ret = NULL;
> > +     const struct l_dhcp_lease *v4_lease;
> > +     const struct l_dhcp6_lease *v6_lease;
> > +
> > +#define CONCAT(dest, src, free)              \
>
> Why do we define this in the function body itself?  That seems weird for a macro
> that is used outside of this function.

True, I could have placed it before the function start.

>
> > +     do {                            \
> > +             char **tmp = src;       \
> > +             tmp = free ? tmp : l_strv_copy(tmp);    \
> > +             if (!dest)              \
> > +                     dest = tmp;     \
> > +             else if (tmp) {         \
> > +                     unsigned int destlen = l_strv_length(dest);     \
> > +                     unsigned int srclen = l_strv_length(tmp);       \
> > +                     dest = l_realloc(dest, sizeof(char *) * \
> > +                             (destlen + srclen + 1));        \
> > +                     memcpy(dest + destlen, tmp, sizeof(char *) *    \
> > +                                     (srclen + 1));  \
> > +                     l_free(tmp);    \
> > +             }                       \
> > +     } while (0)
>
> But really, can't we just turn this macro into a static convenience function
> instead?  Let the compiler decide whether inlining is appropriate.

Ok.

Best regards
