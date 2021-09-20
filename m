Content-Type: multipart/mixed; boundary="===============6845436584754128810=="
MIME-Version: 1.0
From: Marcel Holtmann <marcel at holtmann.org>
To: ell at lists.01.org
Subject: Re: AIO support
Date: Mon, 20 Sep 2021 11:20:57 +0200
Message-ID: <F69C075D-F359-4924-822A-0F5457F31B03@holtmann.org>
In-Reply-To: e64463ea-34af-1911-14b3-19fa69a239c2@maurer.systems

--===============6845436584754128810==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Simon,

> I'm looking now into libaio. POSIX AIO is implemented in libc with user t=
hreads, while libaio uses linux native syscalls. Maybe I can also get rid o=
f signal usage. IMHO non-blocking file access / async IO is quite important=
 for embedded applications and it would be nice to have this feature in ell.

have you looked into using l_idle for providing async read/write callbacks =
that way. I have the feeling that AIO is total overkill for embedded applic=
ations.

Regards

Marcel

--===============6845436584754128810==--

