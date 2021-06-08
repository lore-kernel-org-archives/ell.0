Content-Type: multipart/mixed; boundary="===============7192205027887215480=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/2] avoid using inet_ntoa()
Date: Tue, 08 Jun 2021 11:22:02 -0500
Message-ID: <26c18f62-d8c3-0fe7-6e2d-c26f69407518@gmail.com>
In-Reply-To: <CAJ6EMK2R79xpJ4yNUNONZWgrwpx4aWr6QVOt6meMPUG6SVYFRg@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7192205027887215480==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Davide,

On 6/8/21 7:46 AM, d. caratti wrote:
> Il giorno lun 7 giu 2021 alle ore 20:41 Denis Kenzior
> <denkenz@gmail.com> ha scritto:
> =

>>
>> I would assume so.  You can tell for sure by looking at glibc implementa=
tion for
>> example.
>>
>> Oh, one other thing.  Have you checked the scope rules for GCC statement
>> expressions?  inet_ntoa uses a static buffer (which glibc further enhanc=
es by
>> marking it as thread-specific storage).  So the returned pointer is guar=
anteed
>> to be valid after inet_ntoa returns.  The statement expression doesn't s=
eem to
>> do that, so that seems suspicious?
> =

> ... you are right. GCC documentation [1] says:
> =

> "In a statement expression, any temporaries created within a statement
> are destroyed at that statement=E2=80=99s end."
> =


That is what I was afraid of.

> so, we can't do IP_STR() that way. And using inet_ntop() + static
> buffer, like it's done by iproute2 [2] would actually
> silence the rpminspect warning I'm seeing, but not fix the actual
> problem: AFAIK use of a static buffer is one of the 2 reasons why
> inet_ntoa() has been "obsoleted".

That would be unfortunate.  I'm really not sure whether this needs to be 'f=
ixed' =

anyway.  ell is meant for single-threaded, event driven apps.  So our use o=
f =

inet_ntoa is just fine.  In fact we do similar stuff all over the place.

> =

> At this point, probably the cleanest thing to do is to replace
> IP_STR() with a proper call to inet_ntop(), preceded by declaration of
> buf[INET_ADDRSTRLEN] (like it's already done in some hunks of this
> patch). Luckily, it's just 10 places (versus 6 users of inet_ntoa(),
> still looks feasible).

Perhaps we can do something similar to MAC_STR instead?

> =

> Il giorno lun 7 giu 2021 alle ore 20:41 Denis Kenzior
> <denkenz@gmail.com> ha scritto:
>>
>>> that might be useful for other future CLIENT_DEBUG() users.
>>>
>>
>> Fair enough,  Wish there was a printf extension for ipv4 and ipv6 addres=
ses like
>> printk uses...  Oh well.
> =

> yes, that would really make this game less boring :)
> =

> [1] https://gcc.gnu.org/onlinedocs/gcc/Statement-Exprs.html
> [2] https://github.com/shemminger/iproute2/blob/main/lib/utils.c#L980-L10=
20
> =


Yep, that's the other thing we can do.  Just re-implement inet_ntoa or make=
 our =

own version that covers v4/v6 with a static buffer.  Not sure that is any b=
etter =

than just using inet_ntoa though ;)

Regards,
-Denis
--===============7192205027887215480==--

