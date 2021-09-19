Content-Type: multipart/mixed; boundary="===============1854639028434899567=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: AIO support
Date: Sun, 19 Sep 2021 13:00:44 -0500
Message-ID: <15045604-1991-c85c-5654-2c8f1cfd3c95@gmail.com>
In-Reply-To: 61f114ce-ed19-980d-8b97-1eb3b30eee51@maurer.systems

--===============1854639028434899567==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Simon,

On 9/19/21 12:12 PM, Simon Maurer wrote:
> Hi
> Awesome library! Thank you very much. I'm using it for an embedded linux =


Glad you like it!

> application with not so strict real time constraints. Problem is, I need =
non =

> blocking file access, because the memory card on my system is quite slow.=
 It =

> turns out that this whole non-blocking access doesn't work for files, so =
now I'm =


Can you elaborate?  I always thought
fcntl(fd, F_SETFL, O_NONBLOCK);

would enable non-blocking behavior on files just fine?  Or is this an issue=
 with =

a particular driver?

> using the POSIX AIO interface and I've integrated it into ELL:
> https://github.com/mausys/ell/blob/master/ell/aio.c
> (But needs to be linked against rt)
> This is just a draft and it also works on top of ELL, but maybe other =

> applications need this too.
> =


Thanks, I'll take a peek later during the week.

Regards,
-Denis
--===============1854639028434899567==--

