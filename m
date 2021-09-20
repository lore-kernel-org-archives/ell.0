Content-Type: multipart/mixed; boundary="===============1300907073864071489=="
MIME-Version: 1.0
From: Simon Maurer <mail at maurer.systems>
To: ell at lists.01.org
Subject: Re: AIO support
Date: Mon, 20 Sep 2021 16:00:49 +0000
Message-ID: <26ba7ca3-b836-6dfc-9379-f069d51e055c@maurer.systems>
In-Reply-To: 6dcafff5-5cc5-4cb1-de41-9a76ae5ed217@gmail.com

--===============1300907073864071489==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

Yes I agree, but I still need the the syscall wrappers, because glibc =

doesn't provide them. So bundling it with ell and make libaio a private =

library of ell seams to be a good solution for me.

Regards,
Simon

On 9/20/21 3:29 PM, Denis Kenzior wrote:
> Hi Simon,
> =

> On 9/20/21 10:23 AM, Simon Maurer wrote:
>> I wrote a little "proof of concept" for using ell with libaio:
>> https://github.com/mausys/ellaio/blob/main/aio.c
>> No more signals and threads. Also libaio is LGPL too, so it could be =

>> bundled with ell.
> =

> libaio seems to be a small convenience wrapper around linux system calls =

> (~500 lines).=C2=A0 Why not use io_submit, io_setup, etc directly for the =

> parts you need?
> =

> Regards,
> -Denis

--===============1300907073864071489==--

