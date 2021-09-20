Content-Type: multipart/mixed; boundary="===============5833159817040821677=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: AIO support
Date: Mon, 20 Sep 2021 11:31:03 -0500
Message-ID: <0949c1b4-ee95-9dc4-1565-814bef66fb33@gmail.com>
In-Reply-To: 26ba7ca3-b836-6dfc-9379-f069d51e055c@maurer.systems

--===============5833159817040821677==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Simon,

Please no top-posting.

On 9/20/21 11:00 AM, Simon Maurer wrote:
> Hi Denis,
> =

> Yes I agree, but I still need the the syscall wrappers, because glibc doe=
sn't =


Can't we syscall() in ell, like we do with keyctl in key.c?

> provide them. So bundling it with ell and make libaio a private library o=
f ell =

> seams to be a good solution for me.

That would not be our first choice.

Regards,
-Denis
--===============5833159817040821677==--

