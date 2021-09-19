Content-Type: multipart/mixed; boundary="===============3450091035488648425=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: AIO support
Date: Sun, 19 Sep 2021 16:11:09 -0500
Message-ID: <7c57da7d-6ac9-6a63-62fd-42453f7bedf9@gmail.com>
In-Reply-To: 4eac85e0-0529-4dcc-5e7b-31101d2dae71@maurer.systems

--===============3450091035488648425==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Simon,

>> Can you elaborate?=C2=A0 I always thought
>> fcntl(fd, F_SETFL, O_NONBLOCK);
>>
>> would enable non-blocking behavior on files just fine?=C2=A0 Or is this =
an issue =

>> with a particular driver?
>>
> =

> I tested it and never got EAGAIN. I found this in the man page of open fo=
r the =

> flag O_NONBLOCK or O_NDELAY:
> =

> "Note=C2=A0 that this flag has no effect for regular files and block devi=
ces; that =

> is, I/O operations will (briefly) block when device activity is required, =

> regardless of whether O_NONBLOCK is set.=C2=A0 Since O_NONBLOCK semantics=
 might =

> eventually be implemented, applications should not depend=C2=A0 upon=C2=
=A0 blocking  =

> behavior=C2=A0 when specifying this flag for regular files and block devi=
ces."
> =


Ah, indeed.  I think I even knew that, sorry for the noise.

> An alternative could be preadv2 with the flag RWF_NOWAIT. But it is only =

> available since linux 4.14 and we are using an older kernel. Also epoll d=
oesn't =

> wait for preadv2.

Right, epoll will just simply return immediately on regular files.  Have yo=
u =

tried using a timer or l_idle to drive the reading?  Is there ioctl(fd, =

FIONREAD, ...) or equivalent that could be used not to block?

Regards,
-Denis
--===============3450091035488648425==--

