Received: from mail-pj1-f50.google.com (mail-pj1-f50.google.com [209.85.216.50])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 91BAC6AA8
	for <ell@lists.linux.dev>; Wed, 10 May 2023 15:44:06 +0000 (UTC)
Received: by mail-pj1-f50.google.com with SMTP id 98e67ed59e1d1-24dec03ad8fso5335691a91.1
        for <ell@lists.linux.dev>; Wed, 10 May 2023 08:44:06 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20221208; t=1683733446; x=1686325446;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to;
        bh=+oHYdkPuhp0DLOXB/F/0GU/By51HEnbYb0ExuZkMNGo=;
        b=XxBq6CdHpm3UHJ6B/nc6LZDwpV9/CXQLyW5vBMttY/94tBPWfJd6YLvcWEtsLif0Ib
         mMqlK9oAvy9+8gLNZ4DJAzw1Epq7Tz9M1IaL9cXtwToBfDgqAMeBeoRhW0ZrWXc8VEH1
         qeI8Nxo0i/TpOvPw5o4G8dyDECLPvUmGkiybnU04ZpS5fOdJbABeLc0fbu6Ia1aYT+y6
         iTgQ7PP8nDI/eUBj+JsJjXHraCebRJO4sjI4NbAf8e/MilfUjMUnjNY7BcpeVDrvIJC3
         9CF73XANFLyGr1mHLq5ehZvEbPdDqHGxY2fhMuu7NTtX6hI6CnBir4QGqiHKGB6Fhe0G
         ROhA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20221208; t=1683733446; x=1686325446;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=+oHYdkPuhp0DLOXB/F/0GU/By51HEnbYb0ExuZkMNGo=;
        b=g1Rie32PjSm/42yas/hzf+hjapeDmZQ3r8XFe6MomimMCJL2Ct+KKuDikxVik9Akj6
         YiSpcH5OpwGeWoalmtV3ts5wFExVPtwRpr82TDb8XhQUMOu3mJB325emPWZq8PzX8UbP
         TMAN60Y39VtdKj+wKsUGQIHWoyDrz8BO9aeKSvDtm0VIbVadVBBmnNWWOmcpXPkC/BSH
         TtkM+2BaC/JBPNX0O6Zgttzydy+qpo/wxzjIjuDKnaB6cWZ6jo4L/CJuHmKM8R+394uH
         OGJ8+vtLFYoLFhBBCPe5uTkILjRz+LmHpXiXOdSri8wDoSWtBK/Wy+Qe4MKknwofxZ/d
         /h/g==
X-Gm-Message-State: AC+VfDxYqzjGP2cdUsF2l4iu6BUdE6pplL8DMPLvwQ4UD0unSwE1+akM
	KyMtWUJNPt3MbRk+sc55O2gl1igrW/NlD5WudOJSPbna
X-Google-Smtp-Source: ACHHUZ6nBo7Js7C3U95eZSoLU+tvVL7UYKJuTYsEntN3MMC14oA/56LC6YEwZwhK5Innq1OFET9kUXr4JRXR0xeR90Y=
X-Received: by 2002:a17:90b:1243:b0:24e:1df5:103f with SMTP id
 gx3-20020a17090b124300b0024e1df5103fmr18852092pjb.42.1683733445976; Wed, 10
 May 2023 08:44:05 -0700 (PDT)
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <20230428122025.117834-1-fusibrandon13@gmail.com> <517bc712-06cf-98c2-c799-eda3d2a9db36@gmail.com>
In-Reply-To: <517bc712-06cf-98c2-c799-eda3d2a9db36@gmail.com>
From: Brandon Cheo Fusi <fusibrandon13@gmail.com>
Date: Wed, 10 May 2023 16:43:54 +0100
Message-ID: <CAEVJM+pD_CafRK=B+OXqJZHx-MDz-PsCRDkO43fji1VmZ_cjew@mail.gmail.com>
Subject: Re: [PATCH] ell: Make public headers compilable with C++
To: Denis Kenzior <denkenz@gmail.com>
Cc: Marcel Holtmann <marcel@holtmann.org>, ell@lists.linux.dev
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi Dennis,

Sorry for the delay in responding.

Thanks for pointing that out. Wouldn't it be better to not assume an
array of 6+ bytes and instead
do NULL and size checking in the implementations?

Regards,
Brandon

On Sun, Apr 30, 2023 at 7:24=E2=80=AFPM Denis Kenzior <denkenz@gmail.com> w=
rote:
>
> Hi Brandon,
>
> On 4/28/23 07:20, Brandon Cheo Fusi wrote:
> > This patch allows ell/ell.h to be included in C++ code by removing
> > 'only C' features. These comprise
> >
> > i)  implicit casts from void* to other types which are now made
> >      explicit
> > ii) C99 Static array indices.
>
> <snip>
>
> >   bool l_icmp6_client_set_address(struct l_icmp6_client *client,
> > -                                     const uint8_t addr[static 6]);
> > +                                     const uint8_t addr[]);
>
> You can't really do that because l_icmp6_client_set_address implementatio=
n
> doesn't do any NULL/size checking.  It assumes an array of 6+ bytes.  And=
 that
> is sort of the whole point of using the 'static 6' syntax.
>
> Maybe there's a way to come up with an alternative declaration, using
> '__attribute__ nonnull'?  Perhaps combined with using a pointer to an arr=
ay?
>
> >   uint32_t l_rtnl_set_mac(struct l_netlink *rtnl, int ifindex,
> > -                                     const uint8_t addr[static 6],
> > +                                     const uint8_t addr[],
> >                                       bool power_up,
> >                                       l_netlink_command_func_t cb,
> >                                       void *user_data,
>
> Same comments here.
>
> Regards,
> -Denis
