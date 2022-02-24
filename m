Content-Type: multipart/mixed; boundary="===============4048915312874213237=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH v2] utf8: fixed bit shift larger than type size
Date: Wed, 23 Feb 2022 18:05:50 -0600
Message-ID: <112fe158-95ca-aec3-f3c9-95e80ff8c384@gmail.com>
In-Reply-To: 20220223235149.2724651-1-prestwoj@gmail.com

--===============4048915312874213237==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

On 2/23/22 17:51, James Prestwood wrote:
> The C standard requires the bit shift result value width to be greater
> than or equal to the number of bits being shifted, otherwise the behavior
> is undefined. In this case str[0] was being cast to an unsigned char
> (1 byte) but being shifted 24 bits. This resulted, on some compilers,
> with a runtime error:
> =

> runtime error: left shift of 255 by 24 places cannot be represented in ty=
pe 'int'
> =

> Casting str[0] to an unsigned int satisfies the width requirements
> for this bit shift.
> =

> Fixes: 9843abcd84bc ("utf8: cast to avoid left shift of negative value (u=
bsan)")
> ---
>   ell/utf8.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
> =

> v2:
>   * Added Fixes tag
> =


Applied, thanks.

Regards,
-Denis

--===============4048915312874213237==--

