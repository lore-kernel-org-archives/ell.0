Content-Type: multipart/mixed; boundary="===============4334939989065308875=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 0/2] drop RC4 support
Date: Mon, 03 Aug 2020 16:48:33 -0500
Message-ID: <a8c1b496-51b2-7228-a7f9-a8e6f73e27b5@gmail.com>
In-Reply-To: <20200803105449.124714-1-ardb@kernel.org>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4334939989065308875==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Ard,

On 8/3/20 5:54 AM, Ard Biesheuvel wrote:
> RC4 support in libell is based on the ecb(arc4) skcipher exposed by the
> Linux crypto API, which is an odd beast given that it does not
> distinguish between the key and the IV, and therefore does not fit the
> skcipher API very well.
> =

> Now that work is underway in the linux-crypto kernel community to
> implement chained requests for skciphers, we are running into problems
> with this: the state that needs to be kept between skcipher requests to
> implement chaining is currently kept in the TFM object (which holds the
> key) in the case of ecb(arc4), and moving this into the request object
> (to match the way chaining is implemented for other skcipher modes) may
> enable key reuse (and thus IV reuse in the ARC4 case), which amount to
> catastrophic failure for any stream cipher.
> =

> So in order to address this in a safe and robust manner, we intend to
> retire the ecb(arc4) skcipher entirely on the Linux side. This obviously
> requires work in the userland side as well, hence this series.
> =

> Ard Biesheuvel (2):
>    tls: remove support for RC4 cipher suites
>    cipher: remove obsolete arc4 support
> =

>   ell/cipher.c       |  8 +--
>   ell/cipher.h       |  4 +-
>   ell/tls-suites.c   | 41 ++------------
>   unit/test-cipher.c | 56 --------------------
>   unit/test-tls.c    |  3 +-
>   5 files changed, 11 insertions(+), 101 deletions(-)
> =


Both applied (minus the S-o-B lines).

Regards,
-Denis
--===============4334939989065308875==--

