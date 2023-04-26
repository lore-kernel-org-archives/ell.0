Received: from mail-pg1-f177.google.com (mail-pg1-f177.google.com [209.85.215.177])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E93071C29
	for <ell@lists.linux.dev>; Wed, 26 Apr 2023 08:44:35 +0000 (UTC)
Received: by mail-pg1-f177.google.com with SMTP id 41be03b00d2f7-51fcf5d1e44so6769662a12.3
        for <ell@lists.linux.dev>; Wed, 26 Apr 2023 01:44:35 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20221208; t=1682498675; x=1685090675;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to;
        bh=MpQSvCnjBeUMiRy3gO3fmgkPW46VjmLxEZLTJvW7UWM=;
        b=W8BHeyZ1yu6AVxX3HzXtumbFJhTyP7HcyhECaB8oC+TiHH927yxSEUgVIMjh1TSs5l
         cEJna+7nOJ6oplWyBn5DjjSvy1LyklY58usgqdkhceTJf5rjkJ2/vOdMD0F57Y0Id8GE
         va/fm3DwE/KDP6pmDr6rkjYNvLiEralpsXPFmjYJPj/FFbzCGkyOUAGPWeXvFbOgMcJp
         5407DLhKeoYovnKxS7rYMjtQM/CcMog3tfi0o15PK/j7Kp4GXXpxH6gyVb5ZBMhDmqaB
         +FxhtYbQnIGFwfYrH5aw4XiYnUbEaIC0kJIKo7Sev9Wsouzq7MyUro7Aad4sU6QjknK7
         TcOQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20221208; t=1682498675; x=1685090675;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=MpQSvCnjBeUMiRy3gO3fmgkPW46VjmLxEZLTJvW7UWM=;
        b=fJdxBh5aA7n8MRbF0XLZGqbbxF2l0g4DTfG3HoNJsoWyKTtEOV3wgRE0rVhvXHtg9i
         BIAjgGjO/pkx1LdZTL5yRKC/7fMX7BSSSI2Y8Z3Oa3rmGkuIDYrfaxhYLt1q4SZplD7I
         1qgIWo2IjShKxBlkB7TUt8y6LucftpPlQACmCowXiYXZdx/DvFY0f3MXpiIWYK/DscjJ
         gqjU/UbEGtnxnLCvJYDQd09YQzCFAu4IsuvwEmoPwR5sQ7jGpirJQlKjEcFdv3p4OG8X
         NbEQnaG3j54N+SDN6CjeNb5FgMoR1dxiprqbNf3qyGX8NwNTboOqCbE301ijbFwlMMjc
         4MOA==
X-Gm-Message-State: AAQBX9cZpKS31sjWWXM9Byr7wBgcGFpLzf4M/Stl41F7CR4uHn3gKBpV
	igNL7gRjs8LUEvb+3D6gzaTp3AJDMql/1yGo9Ck=
X-Google-Smtp-Source: AKy350ZeXXiDrYJsEC22r91M+ZS1szNJc1vE//KGbm72xYEwt6XpffGghze13z90F+7RIydHwN+IDawKmSKf5EoEfUA=
X-Received: by 2002:a17:90b:291:b0:247:11eb:2941 with SMTP id
 az17-20020a17090b029100b0024711eb2941mr20651940pjb.37.1682498675148; Wed, 26
 Apr 2023 01:44:35 -0700 (PDT)
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <CAEVJM+pjy7k+to4uYCVBsBL9U0DDJzZ08DLtzvO5SrH-PS6Lxg@mail.gmail.com>
 <b0400fee-c228-7505-8e1e-c4aff185da9b@gmail.com> <79F12F42-0936-4661-82BF-DFB4196BBA4E@holtmann.org>
In-Reply-To: <79F12F42-0936-4661-82BF-DFB4196BBA4E@holtmann.org>
From: Brandon Cheo Fusi <fusibrandon13@gmail.com>
Date: Wed, 26 Apr 2023 09:44:22 +0100
Message-ID: <CAEVJM+p_sc865hJEvxWv648EBk978DpF+ChdafCECbi66GHpPQ@mail.gmail.com>
Subject: Re: Static array indices in function parameter declarations
To: Marcel Holtmann <marcel@holtmann.org>
Cc: James Prestwood <prestwoj@gmail.com>, ell@lists.linux.dev
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi Marcel,

Thanks for clearing that up. My goal was to link against -lell from
C++. And the only errors that turned up were the implicit void* casts
(silenced with -fpermissive) and the static array indices thing.

I'll submit a patch before the weekend.

Regards,
Brandon.

On Tue, Apr 25, 2023 at 5:24=E2=80=AFPM Marcel Holtmann <marcel@holtmann.or=
g> wrote:
>
> Hi James,
>
> >> I'm currently using ell for talking to dbus, and have found it way
> >> more convenient and easier to use as compared to gdbus, or any of the
> >> other bindings I've looked at. So many thanks.
> >> The extern "C"  usage in the header files show the library is allowed
> >> to be compiled with C++ code. However the usage of the C99 feature
> >> that allows one to declare the index of the argument array using the
> >> 'static' keyword in some header files (like rtnl.h:110) seems to
> >> prevent this.
> >> Is there a workaround for this issue?  Or should I submit a patch that
> >> removes all usage of this feature.
> >
> > Is this you're only issue compiling ELL with C++ code? I ask because I =
quickly tried:
> >
> > ~/ell$ g++ -o ell/rtnl.o ell/rtnl.c -I.
> >
> > And I got a TON of errors. Mostly void* pointer arithmetic and missing =
casts from void* to other types.
>
> and that was never the goal. You always have to build ELL with a C compil=
er.
>
> That you might be able to link against -lell from a C++ is an option, but
> our work just including the C++ boilerplate in the headers. And then it
> stopped exactly there. So we need external contributions if things do not
> work.
>
> Regards
>
> Marcel
>
