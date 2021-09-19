Content-Type: multipart/mixed; boundary="===============1154472067986060875=="
MIME-Version: 1.0
From: Marcel Holtmann <marcel at holtmann.org>
To: ell at lists.01.org
Subject: Re: AIO support
Date: Sun, 19 Sep 2021 21:59:30 +0200
Message-ID: <3C5C7E56-11E3-4A13-B011-8D61BF746D60@holtmann.org>
In-Reply-To: 4eac85e0-0529-4dcc-5e7b-31101d2dae71@maurer.systems

--===============1154472067986060875==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Simon,

>>> Awesome library! Thank you very much. I'm using it for an embedded linu=
x =

>> Glad you like it!
>>> application with not so strict real time constraints. Problem is, I nee=
d non blocking file access, because the memory card on my system is quite s=
low. It turns out that this whole non-blocking access doesn't work for file=
s, so now I'm =

>> Can you elaborate?  I always thought
>> fcntl(fd, F_SETFL, O_NONBLOCK);
>> would enable non-blocking behavior on files just fine?  Or is this an is=
sue with a particular driver?
> =

> I tested it and never got EAGAIN. I found this in the man page of open fo=
r the flag O_NONBLOCK or O_NDELAY:
> =

> "Note  that this flag has no effect for regular files and block devices; =
that is, I/O operations will (briefly) block when device activity is requir=
ed, regardless of whether O_NONBLOCK is set.  Since O_NONBLOCK semantics mi=
ght eventually be implemented, applications should not depend  upon  blocki=
ng  behavior  when specifying this flag for regular files and block devices=
."
> =

> An alternative could be preadv2 with the flag RWF_NOWAIT. But it is only =
available since linux 4.14 and we are using an older kernel. Also epoll doe=
sn't wait for preadv2.

I am a bit cautious about aio_write etc. since it requires you to link with=
 -lrt according to the manpage. We actually wanted to keep it at just -lc s=
ince that helps in case of other C libraries besides glibc.

That you require signal handling inside the API is something that worries m=
e additionally. Even with signalfd, doing any complex signal handling besid=
es SIGTERM is kinda messy. I think that AIO support might be better done ou=
tside of ELL.

What kind of file-reading or file-writing are you doing that you need AIO s=
upport anyway? You can actually poll() a file fd. You just have to do it ca=
refully so it doesn=E2=80=99t become a busy loop. Have you tried just using=
 l_idle to only read/write when we having nothing else going on in our main=
loop?

Regards

Marcel

--===============1154472067986060875==--

