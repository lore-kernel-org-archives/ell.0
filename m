Content-Type: multipart/mixed; boundary="===============1676566238445129892=="
MIME-Version: 1.0
From: Simon Maurer <mail at maurer.systems>
To: ell at lists.01.org
Subject: Re: AIO support
Date: Mon, 20 Sep 2021 09:14:22 +0000
Message-ID: <e64463ea-34af-1911-14b3-19fa69a239c2@maurer.systems>
In-Reply-To: 81f5657e-111b-84ed-48f3-5e90d6bdbf75@maurer.systems

--===============1676566238445129892==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

I'm looking now into libaio. POSIX AIO is implemented in libc with user =

threads, while libaio uses linux native syscalls. Maybe I can also get =

rid of signal usage. IMHO non-blocking file access / async IO is quite =

important for embedded applications and it would be nice to have this =

feature in ell.

Regards
Simon
--===============1676566238445129892==--

