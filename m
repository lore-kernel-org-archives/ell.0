Content-Type: multipart/mixed; boundary="===============8778848197102123993=="
MIME-Version: 1.0
From: Simon Maurer <mail at maurer.systems>
To: ell at lists.01.org
Subject: Re: AIO support
Date: Mon, 20 Sep 2021 08:15:17 +0000
Message-ID: <81f5657e-111b-84ed-48f3-5e90d6bdbf75@maurer.systems>
In-Reply-To: 3C5C7E56-11E3-4A13-B011-8D61BF746D60@holtmann.org

--===============8778848197102123993==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Marcel

On 9/19/21 7:59 PM, Marcel Holtmann wrote:
> Hi Simon,
> =

>>>> Awesome library! Thank you very much. I'm using it for an embedded lin=
ux
>>> Glad you like it!
>>>> application with not so strict real time constraints. Problem is, I ne=
ed non blocking file access, because the memory card on my system is quite =
slow. It turns out that this whole non-blocking access doesn't work for fil=
es, so now I'm
>>> Can you elaborate?  I always thought
>>> fcntl(fd, F_SETFL, O_NONBLOCK);
>>> would enable non-blocking behavior on files just fine?  Or is this an i=
ssue with a particular driver?
>>
>> I tested it and never got EAGAIN. I found this in the man page of open f=
or the flag O_NONBLOCK or O_NDELAY:
>>
>> "Note  that this flag has no effect for regular files and block devices;=
 that is, I/O operations will (briefly) block when device activity is requi=
red, regardless of whether O_NONBLOCK is set.  Since O_NONBLOCK semantics m=
ight eventually be implemented, applications should not depend  upon  block=
ing  behavior  when specifying this flag for regular files and block device=
s."
>>
>> An alternative could be preadv2 with the flag RWF_NOWAIT. But it is only=
 available since linux 4.14 and we are using an older kernel. Also epoll do=
esn't wait for preadv2.
> =

> I am a bit cautious about aio_write etc. since it requires you to link wi=
th -lrt according to the manpage. We actually wanted to keep it at just -lc=
 since that helps in case of other C libraries besides glibc.

I don't like that either. If I am informed correctly librt is part of =

glibc and in verison 2.34, librt is not needed anymore. MUSL supports =

POSIX AIO, but neither android bionic nor ulibc implemented it. I =

thought of making aio an optional part of ell, and handle the different =

cases in the configure script.

> =

> That you require signal handling inside the API is something that worries=
 me additionally. Even with signalfd, doing any complex signal handling bes=
ides SIGTERM is kinda messy. I think that AIO support might be better done =
outside of ELL.

Signal handling in my aio implementation is optional and the signal just =

triggers l_aio_poll, which checks all outstanding requests. The problem =

I had with the signalhandling was when multiple requests were completed =

at the same time (between epoll_wait calls), the signal handler was =

executed only once. My first approach was to send request information =

with the signal but that failed for multiple requests. My patch earlier =

made this information available to the user, but independet of AIO =

handling, I still think it might be a good idea to make siginfo =

available to the user.

> =

> What kind of file-reading or file-writing are you doing that you need AIO=
 support anyway? You can actually poll() a file fd. You just have to do it =
carefully so it doesn=E2=80=99t become a busy loop. Have you tried just usi=
ng l_idle to only read/write when we having nothing else going on in our ma=
inloop?
> =

> Regards
> =

> Marcel
> _______________________________________________
> ell mailing list -- ell(a)lists.01.org
> To unsubscribe send an email to ell-leave(a)lists.01.org
> =


Regards
Simon
--===============8778848197102123993==--

