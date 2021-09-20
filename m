Content-Type: multipart/mixed; boundary="===============5620653877886095211=="
MIME-Version: 1.0
From: Simon Maurer <mail at maurer.systems>
To: ell at lists.01.org
Subject: Re: AIO support
Date: Mon, 20 Sep 2021 15:23:27 +0000
Message-ID: <2971a78b-4b0c-de53-2653-5c9494592890@maurer.systems>
In-Reply-To: df76867b-8820-a7f5-5f7b-1d5f09e133d6@maurer.systems

--===============5620653877886095211==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

I wrote a little "proof of concept" for using ell with libaio:
https://github.com/mausys/ellaio/blob/main/aio.c
No more signals and threads. Also libaio is LGPL too, so it could be =

bundled with ell.

Regards
Simon
--===============5620653877886095211==--

