Content-Type: multipart/mixed; boundary="===============9100357206707487621=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: AIO support
Date: Fri, 24 Sep 2021 09:21:21 -0500
Message-ID: <f07404c6-ab34-c7f8-77fe-9b01a7839bc1@gmail.com>
In-Reply-To: 1e731fd1-e512-f4fe-6199-2dba54323b11@maurer.systems

--===============9100357206707487621==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Simon,

On 9/24/21 3:36 AM, Simon Maurer wrote:
> I started testing the aio interface for ell and it seems to work, except =
it's =

> not asynchronous. Turns out libaio works only under certain circumstances:
> http://lse.sourceforge.net/io/aio.html

yes, this was a widely reported criticism.  I assume O_DIRECT is not applic=
able =

to your use case?

> So it's useless. There is a newer alternative called io_uring, but only f=
or =

> newer kernels (5.1) and not available to my target system. I will go back=
 to the

Honestly, for ell, io_uring would be much more interesting to support.  Wit=
h =

maybe a fallback to aio or a threaded/blocking implementation for older ker=
nels.

> POSIX AIO and use SIGEV_THREAD (writing an eventfd in the notify function=
) =

> instead of SIGEV_SIGNAL.
> =


You still have to contend with librt use, which I think Marcel was against.

Regards,
-Denis
--===============9100357206707487621==--

