Content-Type: multipart/mixed; boundary="===============4507802258112372951=="
MIME-Version: 1.0
From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH v4 3/5] ecdh: moved ECDH from IWD
Date: Sun, 09 Dec 2018 12:17:02 +0100
Message-ID: <D881DA72-0823-43E7-985B-A6FC07658AD3@holtmann.org>
In-Reply-To: <20181207203009.5843-3-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4507802258112372951==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

> Moved the ECDH implementation from IWD. API changes were made to utilize
> l_ecc_point/l_ecc_constant types, as well as the curve object. Some sanity
> checks were also added to ensure random keys were within the allowable ra=
nge.
> ---
> Makefile.am |   3 +-
> ell/ecdh.c  | 106 ++++++++++++++++++++++++++++++++++++++++++++++++++++
> ell/ecdh.h  |  51 +++++++++++++++++++++++++
> ell/ell.h   |   1 +
> 4 files changed, 160 insertions(+), 1 deletion(-)
> create mode 100644 ell/ecdh.c
> create mode 100644 ell/ecdh.h

you forgot to update ell/ell.sym with the new exported symbols.

> =

> diff --git a/Makefile.am b/Makefile.am
> index 42caeb7..238fd90 100644
> --- a/Makefile.am
> +++ b/Makefile.am
> @@ -50,7 +50,8 @@ pkginclude_HEADERS =3D ell/ell.h \
> 			ell/net.h \
> 			ell/dhcp.h \
> 			ell/cert.h \
> -			ell/ecc.h
> +			ell/ecc.h \
> +			ell/ecdh.h
> =

> lib_LTLIBRARIES =3D ell/libell.la
> =

> diff --git a/ell/ecdh.c b/ell/ecdh.c
> new file mode 100644
> index 0000000..beb1590
> --- /dev/null
> +++ b/ell/ecdh.c
> @@ -0,0 +1,106 @@
> +/*
> + *
> + *  Embedded Linux library
> + *
> + *  Copyright (C) 2018 Intel Corporation. All rights reserved.
> + *
> + *  This library is free software; you can redistribute it and/or
> + *  modify it under the terms of the GNU Lesser General Public
> + *  License as published by the Free Software Foundation; either
> + *  version 2.1 of the License, or (at your option) any later version.
> + *
> + *  This library is distributed in the hope that it will be useful,
> + *  but WITHOUT ANY WARRANTY; without even the implied warranty of
> + *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
> + *  Lesser General Public License for more details.
> + *
> + *  You should have received a copy of the GNU Lesser General Public
> + *  License along with this library; if not, write to the Free Software
> + *  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-130=
1  USA
> + *
> + */
> +

The HAVE_CONFIG_H block is missing.

> +#include <stdint.h>
> +
> +#include "private.h"
> +#include "ecc-private.h"
> +#include "ecc.h"
> +#include "ecdh.h"
> +#include "random.h"
> +
> +/*
> + * Some sane maximum for calculating the public key. This *shouldn't* ev=
er be
> + * reached in normal conditions.
> + */
> +#define ECDH_MAX_ITERATIONS 20
> +
> +/*
> + * IETF draft-jivsov-ecc-compact-00 Section 4.2.1
> + *
> + * The following algorithm calculates a key pair {k, Q=3Dk*G=3D(x,y)}, w=
here k is
> + * the private key and Q=3D(x,y) is the public key.
> + *
> + * Black box generation:
> + *     1. Generate a key pair {k, Q=3Dk*G=3D(x,y)} with KG
> + *     2. if( y !=3D min(y,p-y) ) goto step 1
> + *     3. output {k, Q=3D(x,y)} as a key pair
> + */
> +LIB_EXPORT bool l_ecdh_generate_key_pair(const struct l_ecc_curve *curve,
> +					struct l_ecc_constant **out_private,
> +					struct l_ecc_point **out_public)
> +{
> +	bool compliant =3D false;
> +	int iter =3D 0;
> +	uint64_t p2[L_ECC_MAX_DIGITS];
> +
> +	_ecc_calculate_p2(curve, p2);
> +
> +	*out_public =3D l_ecc_point_new(curve);
> +
> +	while (!compliant && iter++ < ECDH_MAX_ITERATIONS) {
> +		*out_private =3D l_ecc_constant_new_random(curve);
> +
> +		_ecc_point_mult(*out_public, &curve->g, (*out_private)->c,
> +					NULL, curve->p);
> +
> +		/* ensure public key is compliant */
> +		if (_vli_cmp((*out_public)->y, p2, curve->ndigits) >=3D 0) {
> +			compliant =3D true;
> +			break;
> +		}
> +
> +		l_ecc_constant_free(*out_private);
> +	}
> +
> +	if (!compliant) {
> +		l_ecc_point_free(*out_public);
> +		return false;
> +	}
> +
> +	return true;
> +}
> +
> +LIB_EXPORT bool l_ecdh_generate_shared_secret(const struct l_ecc_curve *=
curve,
> +				const struct l_ecc_constant *private_key,
> +				const struct l_ecc_point *other_public,
> +				struct l_ecc_constant **secret)
> +{
> +	struct l_ecc_constant *z;
> +	struct l_ecc_point *product;
> +
> +	if (unlikely(!curve))
> +		return false;
> +
> +	z =3D l_ecc_constant_new_random(curve);
> +
> +	product =3D l_ecc_point_new(curve);
> +
> +	_ecc_point_mult(product, other_public, private_key->c, z->c, curve->p);
> +
> +	*secret =3D _ecc_constant_new(curve, product->x, curve->ndigits * 8);
> +
> +	l_ecc_point_free(product);
> +	l_ecc_constant_free(z);
> +
> +	return true;
> +}
> diff --git a/ell/ecdh.h b/ell/ecdh.h
> new file mode 100644
> index 0000000..154a431
> --- /dev/null
> +++ b/ell/ecdh.h
> @@ -0,0 +1,51 @@
> +/*
> + *
> + *  Embedded Linux library
> + *
> + *  Copyright (C) 2018 Intel Corporation. All rights reserved.
> + *
> + *  This library is free software; you can redistribute it and/or
> + *  modify it under the terms of the GNU Lesser General Public
> + *  License as published by the Free Software Foundation; either
> + *  version 2.1 of the License, or (at your option) any later version.
> + *
> + *  This library is distributed in the hope that it will be useful,
> + *  but WITHOUT ANY WARRANTY; without even the implied warranty of
> + *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
> + *  Lesser General Public License for more details.
> + *
> + *  You should have received a copy of the GNU Lesser General Public
> + *  License along with this library; if not, write to the Free Software
> + *  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-130=
1  USA
> + *
> + */
> +#ifndef __ELL_ECDH_H
> +#define __ELL_ECDH_H
> +
> +#ifdef __cplusplus
> +extern "C" {
> +#endif
> +
> +#include =E2=80=9Cecc.h"

We don=E2=80=99t include other header files. Forward define the structs if =
really needed.

> +
> +/*
> + * Generate a private/public key pair. private/public are out parameters=
 and
> + * must be freed.
> + */
> +bool l_ecdh_generate_key_pair(const struct l_ecc_curve *curve,
> +					struct l_ecc_constant **out_private,
> +					struct l_ecc_point **out_public);
> +/*
> + * Generate a shared secret from a private/public key. secret is an out
> + * parameters and must be freed.
> + */
> +bool l_ecdh_generate_shared_secret(const struct l_ecc_curve *curve,
> +				const struct l_ecc_constant *private_key,
> +				const struct l_ecc_point *other_public,
> +				struct l_ecc_constant **secret);
> +
> +#ifdef __cplusplus
> +}
> +#endif
> +
> +#endif /* __ELL_ECDH_H */
> diff --git a/ell/ell.h b/ell/ell.h
> index 7bc26bc..aab6417 100644
> --- a/ell/ell.h
> +++ b/ell/ell.h
> @@ -58,3 +58,4 @@
> #include <ell/dhcp.h>
> #include <ell/cert.h>
> #include <ell/ecc.h>
> +#include <ell/ecdh.h>

Regards

Marcel


--===============4507802258112372951==--

