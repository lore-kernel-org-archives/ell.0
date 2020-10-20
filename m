Content-Type: multipart/mixed; boundary="===============0130171068920056758=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v5 01/12] util: add l_memeq/l_memeqzero
Date: Mon, 19 Oct 2020 19:42:02 -0500
Message-ID: <a36214fc-1428-b8d4-302a-36d5ca9101ea@gmail.com>
In-Reply-To: <20201019232814.1541221-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0130171068920056758==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

On 10/19/20 6:28 PM, James Prestwood wrote:
> Utility functions for testing if memory equals a byte, or zero.
> ---
>   ell/ell.sym |  2 ++
>   ell/util.h  | 16 ++++++++++++++++
>   2 files changed, 18 insertions(+)
> =

> diff --git a/ell/ell.sym b/ell/ell.sym
> index 5268b48..0b0a6cc 100644
> --- a/ell/ell.sym
> +++ b/ell/ell.sym
> @@ -20,6 +20,8 @@ global:
>   	l_util_hexdumpv;
>   	l_util_debug;
>   	l_util_get_debugfs_path;
> +	l_memeq;
> +	l_memeqzero;

No need to put static inline functions here.  Only ones marked by LIB_EXPOR=
T go =

here.

>   	/* test */
>   	l_test_init;
>   	l_test_run;
> diff --git a/ell/util.h b/ell/util.h
> index ca894c7..a8b52ad 100644
> --- a/ell/util.h
> +++ b/ell/util.h
> @@ -391,6 +391,22 @@ static inline int l_secure_memcmp(const void *a, con=
st void *b,
>   	return res;
>   }
>   =

> +static inline bool l_memeq(const uint8_t *field, size_t size, uint8_t by=
te)
> +{
> +	size_t i;
> +
> +	for (i =3D 0; i < size; i++)
> +		if (field[i] !=3D byte)
> +			return false;
> +
> +	return true;
> +}
> +

I modified this patch slightly to make this function not inline for future =

optimizations.

> +static inline bool l_memeqzero(const uint8_t *field, size_t size)
> +{
> +	return l_memeq(field, size, 0);
> +}
> +
>   #ifdef __cplusplus
>   }
>   #endif
> =


Applied, thanks.

Regards,
-Denis
--===============0130171068920056758==--

