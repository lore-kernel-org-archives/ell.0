Content-Type: multipart/mixed; boundary="===============0976607626407291387=="
MIME-Version: 1.0
From: Othman, Ossama <ossama.othman@intel.com>
Subject: RE: [PATCH] util: Fix C++ invalid pointer conversion
Date: Tue, 10 Nov 2020 01:07:28 +0000
Message-ID: <36e83abf99be4ae6940ef0aa075dba44@intel.com>
In-Reply-To: <20201106170951.159439-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0976607626407291387==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Apologies for the duplicate patches.

-Ossama

> -----Original Message-----
> From: Ossama Othman <ossama.othman@gmail.com>
> Sent: Friday, November 06, 2020 9:10 AM
> To: ell(a)lists.01.org
> Cc: Othman, Ossama <ossama.othman@intel.com>
> Subject: [PATCH] util: Fix C++ invalid pointer conversion
> =

> Cast the void* arguments of l_secure_memcmp() to uint8_t* during
> assignment to the latter.  C++ doesn't allow assignment of a void* to
> a pointer of another type without a cast.  This allows <ell/util.h> to
> once again be used in C++ code.
> ---
>  ell/util.h | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> =

> diff --git a/ell/util.h b/ell/util.h
> index 0b3e1a8..f3dd57a 100644
> --- a/ell/util.h
> +++ b/ell/util.h
> @@ -351,8 +351,8 @@ const char *l_util_get_debugfs_path(void);
>  static inline int l_secure_memcmp(const void *a, const void *b,
>  					size_t size)
>  {
> -	const volatile uint8_t *aa =3D a;
> -	const volatile uint8_t *bb =3D b;
> +	const volatile uint8_t *aa =3D (const uint8_t *) a;
> +	const volatile uint8_t *bb =3D (const uint8_t *) b;
>  	int res =3D 0, diff, mask;
> =

>  	/*
> --
> 2.25.1

--===============0976607626407291387==--

