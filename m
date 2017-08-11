Content-Type: multipart/mixed; boundary="===============7357826586237452664=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 08/10] pem: Support encrypted keys in
 l_pem_load_private_key
Date: Fri, 11 Aug 2017 15:23:55 -0500
Message-ID: <757437fc-6fa1-6cbf-97a5-be2597ef847b@gmail.com>
In-Reply-To: <20170810231016.29445-8-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7357826586237452664==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 08/10/2017 06:10 PM, Andrew Zaborowski wrote:
> Add support for loading PKCS#8 encrypted private key files (those
> generated with "openssl pkcs8 ..." or "openssl pkey ..." commands, not
> "openssl rsa ..." commands).  The 'encrypted' parameter can be used to
> check if a password is required to decode the key if the caller knows
> nothing about the key other than the file path.
> ---
>   ell/pem.c | 90 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++=
++-----
>   ell/pem.h |  4 +--
>   ell/tls.c |  1 +
>   3 files changed, 86 insertions(+), 9 deletions(-)
> =

> diff --git a/ell/pem.c b/ell/pem.c
> index d1f180e..058b8b8 100644
> --- a/ell/pem.c
> +++ b/ell/pem.c
> @@ -36,6 +36,8 @@
>   #include "pem.h"
>   #include "base64.h"
>   #include "string.h"
> +#include "asn1-private.h"
> +#include "cipher.h"
>   =

>   #define PEM_START_BOUNDARY	"-----BEGIN "
>   #define PEM_END_BOUNDARY	"-----END "
> @@ -232,11 +234,15 @@ LIB_EXPORT uint8_t *l_pem_load_certificate(const ch=
ar *filename, size_t *len)
>   =

>   LIB_EXPORT uint8_t *l_pem_load_private_key(const char *filename,
>   						const char *passphrase,
> +						bool *encrypted,
>   						size_t *len)
>   {
>   	uint8_t *content;
>   	char *label;
>   =

> +	if (encrypted)
> +		*encrypted =3D false;
> +

So we set encrypted even if we fail?  Right now you're not even using =

this parameter, so I wonder if we should maybe introduce a new function, =

like l_pem_is_encrypted() instead?

>   	content =3D l_pem_load_file(filename, 0, &label, len);
>   =

>   	if (!content)

Rest looks good.

Regards,
-Denis

--===============7357826586237452664==--

