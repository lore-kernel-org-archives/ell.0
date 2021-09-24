Content-Type: multipart/mixed; boundary="===============3201484875133513249=="
MIME-Version: 1.0
From: Simon Maurer <mail at maurer.systems>
To: ell at lists.01.org
Subject: Re: AIO support
Date: Fri, 24 Sep 2021 10:36:23 +0200
Message-ID: <1e731fd1-e512-f4fe-6199-2dba54323b11@maurer.systems>

--===============3201484875133513249==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

I started testing the aio interface for ell and it seems to work, except =

it's not asynchronous. Turns out libaio works only under certain =

circumstances:
http://lse.sourceforge.net/io/aio.html
So it's useless. There is a newer alternative called io_uring, but only =

for newer kernels (5.1) and not available to my target system. I will go =

back to the POSIX AIO and use SIGEV_THREAD (writing an eventfd in the =

notify function) instead of SIGEV_SIGNAL.

Regards,
Simon


--===============3201484875133513249==--

