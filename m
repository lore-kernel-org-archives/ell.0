Content-Type: multipart/mixed; boundary="===============1015866176259153264=="
MIME-Version: 1.0
From: Simon Maurer <mail at maurer.systems>
To: ell at lists.01.org
Subject: Re: AIO support
Date: Sun, 19 Sep 2021 19:43:38 +0000
Message-ID: <4eac85e0-0529-4dcc-5e7b-31101d2dae71@maurer.systems>
In-Reply-To: 15045604-1991-c85c-5654-2c8f1cfd3c95@gmail.com

--===============1015866176259153264==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,


On 9/19/21 6:00 PM, Denis Kenzior wrote:
> Hi Simon,
> =

> On 9/19/21 12:12 PM, Simon Maurer wrote:
>> Hi
>> Awesome library! Thank you very much. I'm using it for an embedded linux =

> =

> Glad you like it!
> =

>> application with not so strict real time constraints. Problem is, I =

>> need non blocking file access, because the memory card on my system is =

>> quite slow. It turns out that this whole non-blocking access doesn't =

>> work for files, so now I'm =

> =

> Can you elaborate?=C2=A0 I always thought
> fcntl(fd, F_SETFL, O_NONBLOCK);
> =

> would enable non-blocking behavior on files just fine?=C2=A0 Or is this a=
n =

> issue with a particular driver?
> =


I tested it and never got EAGAIN. I found this in the man page of open =

for the flag O_NONBLOCK or O_NDELAY:

"Note  that this flag has no effect for regular files and block devices; =

that is, I/O operations will (briefly) block when device activity is =

required, regardless of whether O_NONBLOCK is set.  Since O_NONBLOCK =

semantics might eventually be implemented, applications should not =

depend  upon  blocking  behavior  when specifying this flag for regular =

files and block devices."

An alternative could be preadv2 with the flag RWF_NOWAIT. But it is only =

available since linux 4.14 and we are using an older kernel. Also epoll =

doesn't wait for preadv2.


>> using the POSIX AIO interface and I've integrated it into ELL:
>> https://github.com/mausys/ell/blob/master/ell/aio.c
>> (But needs to be linked against rt)
>> This is just a draft and it also works on top of ELL, but maybe other =

>> applications need this too.
>>
> =

> Thanks, I'll take a peek later during the week.
> =

> Regards,
> -Denis

Best regards,
Simon
--===============1015866176259153264==--

