Content-Type: multipart/mixed; boundary="===============1836744898068447785=="
MIME-Version: 1.0
From: d. caratti <davide.caratti@gmail.com>
Subject: Re: [PATCH 1/2] avoid using inet_ntoa()
Date: Tue, 08 Jun 2021 14:46:48 +0200
Message-ID: <CAJ6EMK2R79xpJ4yNUNONZWgrwpx4aWr6QVOt6meMPUG6SVYFRg@mail.gmail.com>
In-Reply-To: <2e2233ef-f787-9290-54db-1a1bc508eba4@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1836744898068447785==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Il giorno lun 7 giu 2021 alle ore 20:41 Denis Kenzior
<denkenz@gmail.com> ha scritto:

>
> I would assume so.  You can tell for sure by looking at glibc implementat=
ion for
> example.
>
> Oh, one other thing.  Have you checked the scope rules for GCC statement
> expressions?  inet_ntoa uses a static buffer (which glibc further enhance=
s by
> marking it as thread-specific storage).  So the returned pointer is guara=
nteed
> to be valid after inet_ntoa returns.  The statement expression doesn't se=
em to
> do that, so that seems suspicious?

... you are right. GCC documentation [1] says:

"In a statement expression, any temporaries created within a statement
are destroyed at that statement=E2=80=99s end."

so, we can't do IP_STR() that way. And using inet_ntop() + static
buffer, like it's done by iproute2 [2] would actually
silence the rpminspect warning I'm seeing, but not fix the actual
problem: AFAIK use of a static buffer is one of the 2 reasons why
inet_ntoa() has been "obsoleted".

At this point, probably the cleanest thing to do is to replace
IP_STR() with a proper call to inet_ntop(), preceded by declaration of
buf[INET_ADDRSTRLEN] (like it's already done in some hunks of this
patch). Luckily, it's just 10 places (versus 6 users of inet_ntoa(),
still looks feasible).

Il giorno lun 7 giu 2021 alle ore 20:41 Denis Kenzior
<denkenz@gmail.com> ha scritto:
>
> > that might be useful for other future CLIENT_DEBUG() users.
> >
>
> Fair enough,  Wish there was a printf extension for ipv4 and ipv6 address=
es like
> printk uses...  Oh well.

yes, that would really make this game less boring :)

[1] https://gcc.gnu.org/onlinedocs/gcc/Statement-Exprs.html
[2] https://github.com/shemminger/iproute2/blob/main/lib/utils.c#L980-L1020
--===============1836744898068447785==--

