Content-Type: multipart/mixed; boundary="===============1958610683428286280=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH 1/2] cert-crypto: pragma false positive
 (-Wmaybe-uninitialized)
Date: Fri, 10 Jun 2022 12:16:11 -0500
Message-ID: <1ea3b31f-13d9-ba52-6ba7-48ee4535d09e@gmail.com>
In-Reply-To: 20220610171132.334641-1-prestwoj@gmail.com

--===============1958610683428286280==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

On 6/10/22 12:11, James Prestwood wrote:
> On musl-gcc 'bmpstring' was detected as maybe uninitialized. This
> is actually a false positive since the usage is guarded by
> if (p_len) but the compiler isn't aware. Pragma to ignore this
> warning.
> =

> ell/cert-crypto.c: In function 'cert_pkcs12_pbkdf':
> ell/cert-crypto.c:246:17: error: 'bmpstring' may be used uninitialized in=
 this function [-Werror=3Dmaybe-uninitialized]
>    246 |                 explicit_bzero(bmpstring, passwd_len);
> ---
>   ell/cert-crypto.c | 3 +++
>   1 file changed, 3 insertions(+)
> =


Both applied, thanks.

Regards,
-Denis

--===============1958610683428286280==--

