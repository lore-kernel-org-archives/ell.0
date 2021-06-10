Content-Type: multipart/mixed; boundary="===============6756905048527106296=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/2] avoid using inet_ntoa()
Date: Thu, 10 Jun 2021 17:12:52 -0500
Message-ID: <8d5a064e-b342-4fb8-ba4e-4f3ab9b2e0b4@gmail.com>
In-Reply-To: <CAJ6EMK3_SOd-ET_mSJE5ZHij99Sso-s4GxbMpefGzMBg8v7yVw@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6756905048527106296==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Davide,

>> That would be unfortunate.  I'm really not sure whether this needs to be=
 'fixed'
>> anyway.  ell is meant for single-threaded, event driven apps.  So our us=
e of
>> inet_ntoa is just fine.  In fact we do similar stuff all over the place.
> =

> there's nothing wrong with using inet_ntoa() as long as the caller
> doesn't need to be "IPv6 friendly" and concurrency is not an issue.
> However,
> this would result in disabling the whole fedora "badfuncs" CI, that
> now is failing just because of inet_ntoa().
> =


Is this a worthy goal in and of itself though?  What other 'badfuncs' are t=
here?

>>> At this point, probably the cleanest thing to do is to replace
>>> IP_STR() with a proper call to inet_ntop(), preceded by declaration of
>>> buf[INET_ADDRSTRLEN] (like it's already done in some hunks of this
>>> patch). Luckily, it's just 10 places (versus 6 users of inet_ntoa(),
>>> still looks feasible).
>>
>> Perhaps we can do something similar to MAC_STR instead?
> =

> that's  similar to the NIPQUAD / NIPQUAD_FMT thing that was done in
> Linux before the %pI4 format specified was introduced in printk (
> https://git.kernel.org/pub/scm/linux/kernel/git/netdev/net.git/commit/?id=
=3D3685f25de1b0447fff381c420de
> ) :
> =

> #include <stdio.h>
> #include <netinet/in.h>
> #include <arpa/inet.h>
> =

> #define IP "%u.%u.%u.%u"
> #define IP_STR(uint_ip) ((unsigned char *) &uint_ip)[0], \
>                          ((unsigned char *) &uint_ip)[1], \
>                          ((unsigned char *) &uint_ip)[2], \
>                          ((unsigned char *) &uint_ip)[3]
> =

> int main(int argc, const char *argv[])
> {
>          struct in_addr ia =3D { .s_addr =3D 0x010200c0 };
>          char buf[INET_ADDRSTRLEN];
> =

>          printf("test 0 %s\n", inet_ntoa(ia));
>          printf("test 1 %s\n", inet_ntop(AF_INET, &ia, buf, INET_ADDRSTRL=
EN));
>          printf("test 2 " IP "\n", IP_STR(ia.s_addr));
> =

>          return 0;
> }
> =


I think this or something like this would be quite reasonable to use in / f=
or =

any debug messages where we print an ip.

> =

>>> Il giorno lun 7 giu 2021 alle ore 20:41 Denis Kenzior
>>> <denkenz@gmail.com> ha scritto:
>>>>
>>>>> that might be useful for other future CLIENT_DEBUG() users.
>>>>>
>>>>
>>>> Fair enough,  Wish there was a printf extension for ipv4 and ipv6 addr=
esses like
>>>> printk uses...  Oh well.
>>>
>>> yes, that would really make this game less boring :)
>>>
>>> [1] https://gcc.gnu.org/onlinedocs/gcc/Statement-Exprs.html
>>> [2] https://github.com/shemminger/iproute2/blob/main/lib/utils.c#L980-L=
1020
>>>
>>
>> Yep, that's the other thing we can do.  Just re-implement inet_ntoa or m=
ake our
>> own version that covers v4/v6 with a static buffer.  Not sure that is an=
y better
>> than just using inet_ntoa though ;)
> =

> what about converting inet_ntoa() into inet_ntop(), and re-writing
> IP_STR() as above?

I guess that would be OK.  We just have to remember to not use inet_ntoa in=
 the =

future...

Regards,
-Denis
--===============6756905048527106296==--

