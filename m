Content-Type: multipart/mixed; boundary="===============7725231043536612111=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/2] avoid using inet_ntoa()
Date: Mon, 07 Jun 2021 13:41:30 -0500
Message-ID: <2e2233ef-f787-9290-54db-1a1bc508eba4@gmail.com>
In-Reply-To: <CAJ6EMK04dtBF3JmHNmmBgin1cjLZXSGQc71M3sBLSyLS03ib+w@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7725231043536612111==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Davide,

> that might be useful for other future=C2=A0CLIENT_DEBUG() users.
> =


Fair enough,  Wish there was a printf extension for ipv4 and ipv6 addresses=
 like =

printk uses...  Oh well.

> =

> yes, it seems to look better - I will also fix this.
> By the=C2=A0way, looking at the inet_ntop() documentation [1], I think th=
at I can =

> also avoid things like
> =

>  =C2=A0 =C2=A0inet_ntop(AF_INET, &ia, buf, INET_ADDRSTRLEN) ? : "(inv)";
> =

> because=C2=A0the first argument is hardcoded to AF_INET and also we are s=
ure that =

> 'buf' is INET_ADDRSTRLEN long.
> Under these conditions, the return value=C2=A0of inet_ntop() should alway=
s be 'buf'. =

> Correct?

I would assume so.  You can tell for sure by looking at glibc implementatio=
n for =

example.

Oh, one other thing.  Have you checked the scope rules for GCC statement =

expressions?  inet_ntoa uses a static buffer (which glibc further enhances =
by =

marking it as thread-specific storage).  So the returned pointer is guarant=
eed =

to be valid after inet_ntoa returns.  The statement expression doesn't seem=
 to =

do that, so that seems suspicious?

Regards,
-Denis
--===============7725231043536612111==--

