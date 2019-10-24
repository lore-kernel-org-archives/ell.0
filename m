Content-Type: multipart/mixed; boundary="===============7472585605622445378=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: Re: [PATCH] random: Seed the fallback random number generator
Date: Thu, 24 Oct 2019 10:04:04 -0700
Message-ID: <alpine.OSX.2.21.1910241001030.50341@mjmartin-mac01.local>
In-Reply-To: <20191024165749.19904-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7472585605622445378==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable


On Thu, 24 Oct 2019, Ossama Othman wrote:

> The random() PRNG is used as a fallback in case of getrandom() syscall
> failure.  However, the PRNG was not seeded prior to initial use,
> resulting in the same predictable sequence of numbers being generated.
> Explicitly seed the PRNG on initial use with random data retrieved
> from the ELF binary loader to decrease predictability.
> ---
> ell/random.c | 19 ++++++++++++++++++-
> 1 file changed, 18 insertions(+), 1 deletion(-)
>
> diff --git a/ell/random.c b/ell/random.c
> index 0b5b09e..99aa06e 100644
> --- a/ell/random.c
> +++ b/ell/random.c
> @@ -28,6 +28,8 @@
> #include <errno.h>
> #include <unistd.h>
> #include <stdlib.h>
> +#include <time.h>
> +#include <sys/auxv.h>
> #include <sys/syscall.h>
>
> #include "random.h"
> @@ -95,11 +97,26 @@ LIB_EXPORT uint32_t l_getrandom_uint32(void)
> {
> 	int ret;
> 	uint32_t u;
> +	static unsigned int seed =3D 0;  /* For fallback PRNG. */
>
> 	ret =3D getrandom(&u, sizeof(u), GRND_NONBLOCK);
>
> 	if (ret =3D=3D sizeof(u))
> 		return u;
>
> -        return random() * RAND_MAX + random();
> +	if (seed =3D=3D 0) {
> +		/*
> +		 * Seed the fallback PRNG below with the
> +		 * process-specific random data supplied by the
> +		 * kernel, skipping the canary in the first half.
> +		 */
> +		unsigned long addr =3D
> +			getauxval(AT_RANDOM) + sizeof(void *);

getauxval is a nonstandard glibc extension, so there needs to be a way to =

fall back to something else (or skip this) for other C libraries.

> +
> +		seed =3D *((unsigned long *) addr) ^ time(NULL);
> +
> +		srandom(seed);
> +	}
> +
> +	return random() * RAND_MAX + random();
> }
> -- =

> 2.20.1
> _______________________________________________
> ell mailing list -- ell(a)lists.01.org
> To unsubscribe send an email to ell-leave(a)lists.01.org
>

--
Mat Martineau
Intel
--===============7472585605622445378==--

