Content-Type: multipart/mixed; boundary="===============6593136694139527383=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 2/4] key: Consistently return errno from syscall wrappers
Date: Thu, 21 Jul 2016 15:19:11 -0500
Message-ID: <57912E3F.2070203@gmail.com>
In-Reply-To: <20160720221928.24488-2-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6593136694139527383==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On 07/20/2016 05:19 PM, Mat Martineau wrote:
> ---
>   ell/key.c | 43 ++++++++++++++++++++++++++++++++++++-------
>   1 file changed, 36 insertions(+), 7 deletions(-)
>
> diff --git a/ell/key.c b/ell/key.c
> index 6117e31..60602f9 100644
> --- a/ell/key.c
> +++ b/ell/key.c
> @@ -64,43 +64,72 @@ static const char * const key_type_names[] =3D {
>   static long kernel_add_key(const char *type, const char *description,
>   				const void *payload, size_t len, int32_t keyring)
>   {
> -	return syscall(__NR_add_key, type, description, payload, len, keyring);
> +	long result;
> +
> +	result =3D syscall(__NR_add_key, type, description, payload, len,
> +				keyring);
> +
> +	return result >=3D 0 ? result : -errno;
>   }
>

I get lots of errno undeclared errors after this patch

Looks like #include <errno.h> is missing.

Regards,
-Denis

--===============6593136694139527383==--

