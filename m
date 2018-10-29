Content-Type: multipart/mixed; boundary="===============2943909187349000157=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 5/5] tools: Only include required ELL headers.
Date: Mon, 29 Oct 2018 15:51:45 -0500
Message-ID: <90a1819c-49d9-4ab1-8ba3-241047c6c676@gmail.com>
In-Reply-To: <20181029200715.28427-6-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2943909187349000157==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Ossama,

On 10/29/2018 03:07 PM, Ossama Othman wrote:
> Limit build side effects caused by enabling or disabling C library
> features through C standard related compiler flags (e.g. -std=3Dc99) by
> only including the required ELL headers.
> ---
>   tools/certchain-verify.c | 5 ++++-
>   1 file changed, 4 insertions(+), 1 deletion(-)
> =

> diff --git a/tools/certchain-verify.c b/tools/certchain-verify.c
> index 1800f68..e8d8374 100644
> --- a/tools/certchain-verify.c
> +++ b/tools/certchain-verify.c
> @@ -26,13 +26,16 @@
>   #include <errno.h>
>   #include <stdint.h>
>   #include <stdbool.h>
> +#include <stdlib.h>
> +#include <string.h>
>   #include <sys/types.h>
>   #include <sys/stat.h>
>   #include <fcntl.h>
>   #include <unistd.h>
>   #include <sys/mman.h>
>   =

> -#include <ell/ell.h>
> +#include <ell/log.h>
> +#include <ell/util.h>

I actually don't like this.  This is just a normal ell application, so =

it should just #include <ell/ell.h> and be done with it.

>   #include "ell/tls-private.h"
>   =

>   static int load_cert_chain(const char *file, struct tls_cert **certchai=
n)
> =


Regards,
-Denis

--===============2943909187349000157==--

