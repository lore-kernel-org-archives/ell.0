Content-Type: multipart/mixed; boundary="===============0341292004251059376=="
MIME-Version: 1.0
From: Simon Maurer <mail at maurer.systems>
To: ell at lists.01.org
Subject: Re: AIO support
Date: Mon, 20 Sep 2021 10:22:30 +0000
Message-ID: <df76867b-8820-a7f5-5f7b-1d5f09e133d6@maurer.systems>
In-Reply-To: F69C075D-F359-4924-822A-0F5457F31B03@holtmann.org

--===============0341292004251059376==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Marcel,

No, because I don't believe it will work. I think the underlying problem =

is the difference between streams and files. When a process creates a =

stream (e.g. socket), the kernel creates a buffer and can start =

receiving data from an external source. This buffer can be accessed =

non-blocking from the process and the kernel can signal to the process =

when data was received. If the process opens a file, the kernel doesn't =

know what the process will do next (read or write, offset of the file, =

transfer size). So the kernel doesn't read/write any bytes unless the =

process sends a command to the kernel. And the POSIX read/write =

functions on files are always blocking. That leaves us with using =

multi-threading (POSIX AIO) or other linux specific syscalls (libaio, =

preadv2).

Regards
Simon

On 9/20/21 9:20 AM, Marcel Holtmann wrote:
> Hi Simon,
> =

>> I'm looking now into libaio. POSIX AIO is implemented in libc with user =
threads, while libaio uses linux native syscalls. Maybe I can also get rid =
of signal usage. IMHO non-blocking file access / async IO is quite importan=
t for embedded applications and it would be nice to have this feature in el=
l.
> =

> have you looked into using l_idle for providing async read/write callback=
s that way. I have the feeling that AIO is total overkill for embedded appl=
ications.
> =

> Regards
> =

> Marcel
>=20

--===============0341292004251059376==--

