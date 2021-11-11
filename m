Content-Type: multipart/mixed; boundary="===============0777661572562451339=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH] log: Set retain attribute on __ell_debug
Date: Thu, 11 Nov 2021 12:47:58 -0600
Message-ID: <8ee36d26-5741-43bd-57ad-5429f2c9c9dd@gmail.com>
In-Reply-To: 20211111030742.2005152-1-i@maskray.me

--===============0777661572562451339==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Fangrui,

On 11/10/21 9:07 PM, Fangrui Song wrote:
> LLD 13 and GNU ld 2.37 support -z start-stop-gc which allows garbage
> collection of C identifier name sections despite the __start_/__stop_
> references. GNU ld before 2015-10 had the behavior as well. Simply set
> the retain attribute so that GCC 11 (if configure-time binutils is 2.36
> or newer)/Clang 13 will set the SHF_GNU_RETAIN section attribute to
> prevent garbage collection.
> =

> Without the patch, there are linker errors with -z start-stop-gc (LLD def=
ault):
> =

> ```
> ld.lld: error: undefined symbol: __start___ell_debug
>>>> referenced by log.c
>>>>                log.o:(register_debug_section) in archive ell/.libs/lib=
ell-private.a
> ```
> ---
>   ell/log.h | 8 +++++++-
>   1 file changed, 7 insertions(+), 1 deletion(-)
> =


We do not use C++ style comments, so I just changed those over to C-style /=
* */ =

block.  Applied, thanks!

Regards,
-Denis
--===============0777661572562451339==--

