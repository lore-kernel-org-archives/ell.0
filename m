Content-Type: multipart/mixed; boundary="===============8913110540613050210=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH] pem.c: do not use rawmemchr()
Date: Thu, 18 Nov 2021 08:31:22 -0600
Message-ID: <a3357996-414f-aa9d-29b4-bbec8543e6f8@gmail.com>
In-Reply-To: 20211118130315.499471-1-alex@linutronix.de

--===============8913110540613050210==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Alexander,

On 11/18/21 7:03 AM, Alexander Kanavin wrote:
> From: Alexander Kanavin <alex.kanavin(a)gmail.com>
> =

> This is a glibc-only function, and causes build failures with
> alternative libc implementations such as musl.

I believe ell builds just fine on musl.  We already have an alternate =

implementation of rawmemchr in ell/missing.h and it should be used automagi=
cally =

in case its absence is detected at configure time.  Is this not working for=
 you ?

> ---
>   ell/pem.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
> =


Regards,
-Denis
--===============8913110540613050210==--

