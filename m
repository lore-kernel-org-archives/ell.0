Content-Type: multipart/mixed; boundary="===============7062931394123731154=="
MIME-Version: 1.0
From: d. caratti <davide.caratti@gmail.com>
Subject: Re: [PATCH 1/2] avoid using inet_ntoa()
Date: Wed, 09 Jun 2021 12:18:17 +0200
Message-ID: <CAJ6EMK3_SOd-ET_mSJE5ZHij99Sso-s4GxbMpefGzMBg8v7yVw@mail.gmail.com>
In-Reply-To: <26c18f62-d8c3-0fe7-6e2d-c26f69407518@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7062931394123731154==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Il giorno mar 8 giu 2021 alle ore 18:22 Denis Kenzior
<denkenz@gmail.com> ha scritto:
>
> Hi Davide,
>
> On 6/8/21 7:46 AM, d. caratti wrote:
> > Il giorno lun 7 giu 2021 alle ore 20:41 Denis Kenzior
> > <denkenz@gmail.com> ha scritto:
> >
> >>
> >> I would assume so.  You can tell for sure by looking at glibc implemen=
tation for
> >> example.

this:

https://sourceware.org/git/?p=3Dglibc.git;a=3Dblob;f=3Dresolv/inet_ntop.c;h=
=3Dc4d38c0f951013e51a4fc6eaa8a9b82e146abe5a;hb=3DHEAD

yes, the ternary operator is not needed as long as the address family
is hardcoded to AF_INET and 'buf ' fits the size of 'tmp' in
inet_ntop4().

> >> Oh, one other thing.  Have you checked the scope rules for GCC stateme=
nt
> >> expressions?  inet_ntoa uses a static buffer (which glibc further enha=
nces by
> >> marking it as thread-specific storage).  So the returned pointer is gu=
aranteed
> >> to be valid after inet_ntoa returns.  The statement expression doesn't=
 seem to
> >> do that, so that seems suspicious?
> >
> > ... you are right. GCC documentation [1] says:
> >
> > "In a statement expression, any temporaries created within a statement
> > are destroyed at that statement=E2=80=99s end."
> >
>
> That is what I was afraid of.
>
> > so, we can't do IP_STR() that way. And using inet_ntop() + static
> > buffer, like it's done by iproute2 [2] would actually
> > silence the rpminspect warning I'm seeing, but not fix the actual
> > problem: AFAIK use of a static buffer is one of the 2 reasons why
> > inet_ntoa() has been "obsoleted".
>
> That would be unfortunate.  I'm really not sure whether this needs to be =
'fixed'
> anyway.  ell is meant for single-threaded, event driven apps.  So our use=
 of
> inet_ntoa is just fine.  In fact we do similar stuff all over the place.

there's nothing wrong with using inet_ntoa() as long as the caller
doesn't need to be "IPv6 friendly" and concurrency is not an issue.
However,
this would result in disabling the whole fedora "badfuncs" CI, that
now is failing just because of inet_ntoa().

> > At this point, probably the cleanest thing to do is to replace
> > IP_STR() with a proper call to inet_ntop(), preceded by declaration of
> > buf[INET_ADDRSTRLEN] (like it's already done in some hunks of this
> > patch). Luckily, it's just 10 places (versus 6 users of inet_ntoa(),
> > still looks feasible).
>
> Perhaps we can do something similar to MAC_STR instead?

that's  similar to the NIPQUAD / NIPQUAD_FMT thing that was done in
Linux before the %pI4 format specified was introduced in printk (
https://git.kernel.org/pub/scm/linux/kernel/git/netdev/net.git/commit/?id=
=3D3685f25de1b0447fff381c420de
) :

#include <stdio.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#define IP "%u.%u.%u.%u"
#define IP_STR(uint_ip) ((unsigned char *) &uint_ip)[0], \
                        ((unsigned char *) &uint_ip)[1], \
                        ((unsigned char *) &uint_ip)[2], \
                        ((unsigned char *) &uint_ip)[3]

int main(int argc, const char *argv[])
{
        struct in_addr ia =3D { .s_addr =3D 0x010200c0 };
        char buf[INET_ADDRSTRLEN];

        printf("test 0 %s\n", inet_ntoa(ia));
        printf("test 1 %s\n", inet_ntop(AF_INET, &ia, buf, INET_ADDRSTRLEN)=
);
        printf("test 2 " IP "\n", IP_STR(ia.s_addr));

        return 0;
}


> > Il giorno lun 7 giu 2021 alle ore 20:41 Denis Kenzior
> > <denkenz@gmail.com> ha scritto:
> >>
> >>> that might be useful for other future CLIENT_DEBUG() users.
> >>>
> >>
> >> Fair enough,  Wish there was a printf extension for ipv4 and ipv6 addr=
esses like
> >> printk uses...  Oh well.
> >
> > yes, that would really make this game less boring :)
> >
> > [1] https://gcc.gnu.org/onlinedocs/gcc/Statement-Exprs.html
> > [2] https://github.com/shemminger/iproute2/blob/main/lib/utils.c#L980-L=
1020
> >
>
> Yep, that's the other thing we can do.  Just re-implement inet_ntoa or ma=
ke our
> own version that covers v4/v6 with a static buffer.  Not sure that is any=
 better
> than just using inet_ntoa though ;)

what about converting inet_ntoa() into inet_ntop(), and re-writing
IP_STR() as above?
thanks!

-- =

davide
--===============7062931394123731154==--

