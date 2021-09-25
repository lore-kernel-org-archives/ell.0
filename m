Content-Type: multipart/mixed; boundary="===============5665892417560230119=="
MIME-Version: 1.0
From: Simon Maurer <mail at maurer.systems>
To: ell at lists.01.org
Subject: Re: AIO support
Date: Sat, 25 Sep 2021 19:37:16 +0200
Message-ID: <cfbb7a4a-120f-2429-0ca1-5edeaee9e495@maurer.systems>
In-Reply-To: f07404c6-ab34-c7f8-77fe-9b01a7839bc1@gmail.com

--===============5665892417560230119==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis

On 9/24/21 4:21 PM, Denis Kenzior wrote:

>> I started testing the aio interface for ell and it seems to work, =

>> except it's not asynchronous. Turns out libaio works only under =

>> certain circumstances:
>> http://lse.sourceforge.net/io/aio.html
> =

> yes, this was a widely reported criticism.=C2=A0 I assume O_DIRECT is not =

> applicable to your use case?

I tried to open the file with O_DIRECT, but still got no asynchronous =

operations. I don't know what the problem was, NVMe, btrfs, ... also I =

tried it on an usb stick with FAT32. Anyway, if it's only working under =

certain conditions it's useless and dangerous for real time =

applications. I can't expect the user of my aio interface to be an =

expert in Linux filesystems and knowing all the restrictions of aio.

> =

> Honestly, for ell, io_uring would be much more interesting to support.  =

> With maybe a fallback to aio or a threaded/blocking implementation for =

> older kernels.

I might write an io_uring implementation in the future. But since =

io_uring is not available on my target system, I have to stick with =

POSIX AIO. A lot of Linux BSPs are only available for outdated kernel.

Regards,
Simon
--===============5665892417560230119==--

