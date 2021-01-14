Content-Type: multipart/mixed; boundary="===============2564930781391706731=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] cert: Fix warning of possible uninitialized var
Date: Thu, 14 Jan 2021 15:35:27 -0600
Message-ID: <73a12eac-a80c-3472-caee-0567a0d19ba0@gmail.com>
In-Reply-To: <20210114211602.329103-1-brian.gix@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2564930781391706731==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Brian,

On 1/14/21 3:16 PM, Brian Gix wrote:
> ell/cert-crypto.c: In function =E2=80=98cert_pkcs12_pbkdf=E2=80=99:
> ell/cert-crypto.c:244:3: error: =E2=80=98bmpstring=E2=80=99 may be used u=
ninitialized in this function [-Werror=3Dmaybe-uninitialized]
>    244 |   explicit_bzero(bmpstring, passwd_len);
>        |   ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

What compiler are you seeing this on?

> ---
>   ell/cert-crypto.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
> =

> diff --git a/ell/cert-crypto.c b/ell/cert-crypto.c
> index 6eb4e14..b3d3000 100644
> --- a/ell/cert-crypto.c
> +++ b/ell/cert-crypto.c
> @@ -194,7 +194,7 @@ uint8_t *cert_pkcs12_pbkdf(const char *password,
>   {
>   	/* All lengths in bytes instead of bits */
>   	size_t passwd_len =3D password ? 2 * strlen(password) + 2 : 0;
> -	uint8_t *bmpstring;
> +	uint8_t *bmpstring =3D NULL;

So generally I don't like this type of fix because it just hides problems. =
 The =

issues with bmpstring use seem to be a bit more complex than that.

>   	/* Documented as v(ceiling(s/v)), usually will just equal v */
>   	unsigned int s_len =3D (salt_len + hash->v - 1) & ~(hash->v - 1);
>   	/* Documented as p(ceiling(s/p)), usually will just equal v */
> =


Andrew:

Why is p_len initialized to be non-zero.  In particular, this block:

         for (j =3D passwd_len; j < p_len; j +=3D passwd_len, ptr +=3D pass=
wd_len)
                 memcpy(ptr, bmpstring, passwd_len);

would seem to copy from an uninitialized bmpstring even if password is NULL.

Regards,
-Denis
--===============2564930781391706731==--

