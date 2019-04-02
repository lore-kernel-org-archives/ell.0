Content-Type: multipart/mixed; boundary="===============2249513371268816434=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] util: Added l_container_of macro
Date: Tue, 02 Apr 2019 10:46:31 -0500
Message-ID: <63836498-8e6f-b8c9-0920-c3ec30f0bcf7@gmail.com>
In-Reply-To: <20190402073654.28012-1-michal.lowas-rzechonek@silvair.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2249513371268816434==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Micha=C5=82,

On 04/02/2019 02:36 AM, Micha=C5=82 'Khorne' Lowas-Rzechonek wrote:
> From: Micha=C5=82 Lowas-Rzechonek <michal.lowas-rzechonek@silvair.com>
> =

> The macro is useful when e.g. scheduling timeouts, where l_timeout
> passed to l_timeout_notify_cb_t is a member of a larger object, and we
> would like to access this object while passing something else as
> user_data.
> ---
>   ell/util.h | 5 +++++
>   1 file changed, 5 insertions(+)
> =

> diff --git a/ell/util.h b/ell/util.h
> index c4ba7f8..95503de 100644
> --- a/ell/util.h
> +++ b/ell/util.h
> @@ -35,6 +35,11 @@
>   extern "C" {
>   #endif
>   =

> +#define l_container_of(ptr, type, member) ({					\
> +		const typeof( ((type *)0)->member ) *__mptr =3D (ptr);	\
> +		(type *)( (char *)__mptr - offsetof(type,member) );		\
> +	})
> +

Is this a copy-paste of the container_of in private.h?  If so, I'm fine =

with this, but you might as well get rid of the one in private.h and =

make the rest of ell use this one.

>   #define likely(x)   __builtin_expect(!!(x), 1)
>   #define unlikely(x) __builtin_expect(!!(x), 0)
>   =

> =


Regards,
-Denis

--===============2249513371268816434==--

