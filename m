Content-Type: multipart/mixed; boundary="===============7149988955444110852=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 2/4] pem: Add pem_write_certificate_chain
Date: Thu, 17 Dec 2020 13:32:09 -0600
Message-ID: <719043d6-db51-5e4f-5ce2-993315d59f2c@gmail.com>
In-Reply-To: <20201217013225.821303-2-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7149988955444110852==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 12/16/20 7:32 PM, Andrew Zaborowski wrote:
> ---
>   ell/pem-private.h |  5 +++++
>   ell/pem.c         | 50 +++++++++++++++++++++++++++++++++++++++++++++++
>   2 files changed, 55 insertions(+)
> =


<snip>

> diff --git a/ell/pem.c b/ell/pem.c
> index 1b995d5..321bc3e 100644
> --- a/ell/pem.c
> +++ b/ell/pem.c
> @@ -45,6 +45,7 @@
>   #include "cipher.h"
>   #include "cert-private.h"
>   #include "missing.h"
> +#include "io.h"

Is this really needed?

>   #include "pem-private.h"
>   =

>   #define PEM_START_BOUNDARY	"-----BEGIN "
> @@ -364,6 +365,55 @@ LIB_EXPORT struct l_certchain *l_pem_load_certificat=
e_chain(
>   	return pem_list_to_chain(list);
>   }
>   =

> +static bool pem_write_one_cert(struct l_cert *cert, void *user_data)
> +{
> +	int *fd =3D user_data;
> +	const uint8_t *der;
> +	size_t der_len;
> +	struct iovec iov[3];
> +	ssize_t r;
> +
> +	der =3D l_cert_get_der_data(cert, &der_len);
> +
> +	iov[0].iov_base =3D "-----BEGIN CERTIFICATE-----\n";
> +	iov[0].iov_len =3D strlen(iov[0].iov_base);
> +	iov[1].iov_base =3D l_base64_encode(der, der_len, 64, &iov[1].iov_len);

Is this being leaked?

> +	iov[2].iov_base =3D "\n-----END CERTIFICATE-----\n";
> +	iov[2].iov_len =3D strlen(iov[2].iov_base);
> +	r =3D L_TFR(writev(*fd, iov, 3));
> +
> +	if (r =3D=3D (ssize_t) (iov[0].iov_len + iov[1].iov_len + iov[2].iov_le=
n))
> +		return false;
> +
> +	close(*fd);

Maybe the close should be in pem_write_certificate_chain()?

> +
> +	if (r < 0)
> +		*fd =3D -errno;
> +	else
> +		*fd =3D -EIO;
> +
> +	return true;
> +}
> +

Regards,
-Denis
--===============7149988955444110852==--

