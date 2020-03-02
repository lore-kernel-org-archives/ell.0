Content-Type: multipart/mixed; boundary="===============7357062356835575323=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/4] time: Add timespec to microseconds converter
Date: Mon, 02 Mar 2020 15:34:49 -0600
Message-ID: <27cdcb4f-0af4-dc01-a69d-3b583630a3bb@gmail.com>
In-Reply-To: <20200302212817.15524-2-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7357062356835575323==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Ossama,

On 3/2/20 3:28 PM, Ossama Othman wrote:
> Implement a new function, l_timespec_to_usecs(), that checks for
> integer overflow in the multiplication and addition operations that
> occur during the conversion of the timespec members to microseconds.
> ---
>   ell/ell.sym |  1 +
>   ell/time.c  | 24 ++++++++++++++++++++++++
>   ell/time.h  |  3 +++
>   3 files changed, 28 insertions(+)

ell/time.c: In function =E2=80=98l_timespec_to_usecs=E2=80=99:
ell/time.c:48:2: error: ISO C90 forbids mixed declarations and code =

[-Werror=3Ddeclaration-after-statement]
    48 |  uint64_t usecs =3D t->tv_sec * L_USEC_PER_SEC;
       |  ^~~~~~~~
ell/time.c:51:29: error: comparison of integer expressions of different =

signedness: =E2=80=98long long unsigned int=E2=80=99 and =E2=80=98__time_t=
=E2=80=99 {aka =E2=80=98const long =

int=E2=80=99} [-Werror=3Dsign-compare]
    51 |  if (usecs / L_USEC_PER_SEC !=3D t->tv_sec)
       |                             ^~
cc1: all warnings being treated as errors


> =

> diff --git a/ell/ell.sym b/ell/ell.sym
> index 0c83b87..776a94c 100644
> --- a/ell/ell.sym
> +++ b/ell/ell.sym
> @@ -526,6 +526,7 @@ global:
>   	l_ecdh_generate_key_pair;
>   	l_ecdh_generate_shared_secret;
>   	/* time */
> +	l_timespec_to_usecs;
>   	l_time_now;
>   	/* gpio */
>   	l_gpio_chips_with_line_label;
> diff --git a/ell/time.c b/ell/time.c
> index 6150d03..becf985 100644
> --- a/ell/time.c
> +++ b/ell/time.c
> @@ -30,6 +30,30 @@
>   #include "time.h"
>   #include "private.h"
>   =

> +/**
> + * l_timespec_to_usecs() - convert timespec value to microseconds
> + * @t: pointer to timespec value to be converted to microseconds.
> + *
> + * Convert the timespec value @t to microseconds, being careful to
> + * avoid integer overflows during the conversion.
> + *
> + * Return: Number of microseconds in @t, UINT64_MAX on overflow, and
> + *         zero if @t is NULL.
> + */
> +LIB_EXPORT uint64_t l_timespec_to_usecs(const struct timespec *t)
> +{
> +	if (!t)
> +		return 0;
> +
> +	uint64_t usecs =3D t->tv_sec * L_USEC_PER_SEC;
> +
> +	/* check overflow */
> +	if (usecs / L_USEC_PER_SEC !=3D t->tv_sec)

There has to be a better way than this division...

> +		return UINT64_MAX;
> +
> +	return l_time_offset(usecs, t->tv_nsec / L_NSEC_PER_USEC);
> +}
> +
>   /**
>    * l_time_now:
>    *
> diff --git a/ell/time.h b/ell/time.h
> index 6976280..6011b80 100644
> --- a/ell/time.h
> +++ b/ell/time.h
> @@ -38,6 +38,9 @@ extern "C" {
>   #define L_NSEC_PER_USEC 1000ULL
>   #define L_TIME_INVALID ((uint64_t) -1)
>   =

> +struct timespec;
> +
> +uint64_t l_timespec_to_usecs(const struct timespec *t);
>   uint64_t l_time_now(void);
>   =

>   static inline bool l_time_after(uint64_t a, uint64_t b)
> =


Regards,
-Denis
--===============7357062356835575323==--

