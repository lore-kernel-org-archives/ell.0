Content-Type: multipart/mixed; boundary="===============6795078082851565711=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 2/5] settings: Include strings.h for strcasecmp() proto
Date: Mon, 29 Oct 2018 15:53:45 -0500
Message-ID: <2c3be9ee-5d44-1dba-9398-fc0d0d304342@gmail.com>
In-Reply-To: <20181029200715.28427-3-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6795078082851565711==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Ossama,

On 10/29/2018 03:07 PM, Ossama Othman wrote:
> Restricting the C standard supported by compiler, e.g. to C99, can
> prevent some function prototypes from being indirectly pulled in, as
> is the case for strcasecmp().  Include <strings.h> to explicitly pull
> in its prototype.
> ---
>   ell/settings.c | 1 +
>   1 file changed, 1 insertion(+)
> =

> diff --git a/ell/settings.c b/ell/settings.c
> index 539263b..08a7748 100644
> --- a/ell/settings.c
> +++ b/ell/settings.c
> @@ -26,6 +26,7 @@
>   =

>   #include <stdio.h>
>   #include <stdlib.h>
> +#include <strings.h>  // strcasecmp

We don't use C++ style comments, so I just removed that one and applied =

this patch.

Regards,
-Denis

>   #include <errno.h>
>   #include <sys/types.h>
>   #include <sys/stat.h>
>=20

--===============6795078082851565711==--

