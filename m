Content-Type: multipart/mixed; boundary="===============8588593238525267032=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: AIO support
Date: Mon, 20 Sep 2021 10:29:38 -0500
Message-ID: <6dcafff5-5cc5-4cb1-de41-9a76ae5ed217@gmail.com>
In-Reply-To: 2971a78b-4b0c-de53-2653-5c9494592890@maurer.systems

--===============8588593238525267032==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Simon,

On 9/20/21 10:23 AM, Simon Maurer wrote:
> I wrote a little "proof of concept" for using ell with libaio:
> https://github.com/mausys/ellaio/blob/main/aio.c
> No more signals and threads. Also libaio is LGPL too, so it could be bund=
led =

> with ell.

libaio seems to be a small convenience wrapper around linux system calls (~=
500 =

lines).  Why not use io_submit, io_setup, etc directly for the parts you ne=
ed?

Regards,
-Denis
--===============8588593238525267032==--

