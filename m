Content-Type: multipart/mixed; boundary="===============5331019142845941343=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 4/5] ell: Make tls-private.h header self-contained.
Date: Mon, 29 Oct 2018 15:49:52 -0500
Message-ID: <2b306d44-5d15-3594-431d-fd42802dd678@gmail.com>
In-Reply-To: <20181029200715.28427-5-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5331019142845941343==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Ossama,

On 10/29/2018 03:07 PM, Ossama Othman wrote:
> Add a missing struct iovec forward declaration, and include the
> appropriate headers in tls-private.h to make it self-contained.  This
> simplifies its use so that files that include it need not be forced to
> include other headers it requires.
> ---
>   ell/cipher.h      | 1 +
>   ell/tls-private.h | 4 ++++
>   2 files changed, 5 insertions(+)
> =

> diff --git a/ell/cipher.h b/ell/cipher.h
> index d787f33..6b43458 100644
> --- a/ell/cipher.h
> +++ b/ell/cipher.h
> @@ -27,6 +27,7 @@
>   extern "C" {
>   #endif
>   =

> +struct iovec;
>   struct l_cipher;
>   =

>   enum l_cipher_type {
> diff --git a/ell/tls-private.h b/ell/tls-private.h
> index 8cf5be9..0da7d21 100644
> --- a/ell/tls-private.h
> +++ b/ell/tls-private.h
> @@ -20,6 +20,10 @@
>    *
>    */
>   =

> +#include <ell/checksum.h>
> +#include <ell/cipher.h>
> +#include <ell/tls.h>
> +

Hmm, our general practice is not to include anything inside private =

headers, so this goes fully counter to that practice.  Why is =

tls-private.h being used anyway?

>   /* Only TLS 1.2 supported */
>   #define TLS_V12		((3 << 8) | 3)
>   #define TLS_V11		((3 << 8) | 2)
> =


Regards,
-Denis

--===============5331019142845941343==--

