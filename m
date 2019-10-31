Content-Type: multipart/mixed; boundary="===============0610911716139046129=="
MIME-Version: 1.0
From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] genl: Include system header to fix build warning
Date: Thu, 31 Oct 2019 07:14:45 +0100
Message-ID: <AB1D2E09-A59D-4140-BDA2-438553386643@holtmann.org>
In-Reply-To: <20191030201607.21168-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0610911716139046129==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

> The l_genl_msg_append_attrv() declaration in genl.h uses struct iovec *,
> but there's no guarantee that sys/uio.h has been included already (and
> the genl user might not need that header itself). Within the ell code,
> uio.h is already included by util.h which prevents build errors in ell
> itself.
> ---
> ell/genl.h | 1 +
> 1 file changed, 1 insertion(+)
> =

> diff --git a/ell/genl.h b/ell/genl.h
> index 5df688b..3a37ed5 100644
> --- a/ell/genl.h
> +++ b/ell/genl.h
> @@ -26,6 +26,7 @@
> #include <stdbool.h>
> #include <stddef.h>
> #include <stdint.h>
> +#include <sys/uio.h>

I would rather forward declare struct iovec than including a header from a =
public ELL header.

Regards

Marcel

--===============0610911716139046129==--

