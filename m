Content-Type: multipart/mixed; boundary="===============2139964246679469046=="
MIME-Version: 1.0
From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH v4 1/5] ecc: moved ecc from IWD into ell
Date: Sun, 09 Dec 2018 12:12:29 +0100
Message-ID: <7B5B0376-AD43-4C0E-A454-01F0D2BF67F0@holtmann.org>
In-Reply-To: <20181207203009.5843-1-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2139964246679469046==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

> IWD had its own implementation for ECC and math operations. Eventually
> TLS will indirectly require this (via ECDH) so it made sense to move
> everything into ell. Some changes had to be made to the original file
> to accomidate the ell style.
> =

> The original file (ecc.c) has remained mostly intact, and was put in
> ell/3rdparty/ folder. Any internal vli functions that needed to be
> exposed privately were defined in ecc-private.h. This allows us to
> create a new file ell/ecc.c which holds all the public APIs, as well
> as keep the original ECC unit tests.
> =

> To create a proper set of ECC APIs three new objects were added,
> l_ecc_curve, l_ecc_point and l_ecc_constant. The curve object is used
> to initialize any l_ecc_point/l_ecc_constant. The curve object can
> be obtained with l_ecc_curve_get(int group); This allows ELL to hide
> all the implementation details of the curve (byte size and curve
> parameters).
> =

> With this curve object you can create new points or constants. All
> constructors which take point/constant data expect the input to be in
> BE ordering. This was done because most of the time this data is
> coming from the network. Getting point/constant data back out will
> order the bytes back into BE ordering (internally its stored natively).
> =

> For now, the API set is limited to only what ECDH requires, but future
> patches will add a full set of operations needed for other ECC
> protocols.
> ---
> Makefile.am        |   9 +-
> ell/3rdparty/ecc.c | 934 +++++++++++++++++++++++++++++++++++++++++++++
> ell/ecc-private.h  |  88 +++++
> ell/ecc.c          | 371 ++++++++++++++++++
> ell/ecc.h          |  70 ++++
> ell/ell.h          |   1 +
> 6 files changed, 1471 insertions(+), 2 deletions(-)
> create mode 100644 ell/3rdparty/ecc.c
> create mode 100644 ell/ecc-private.h
> create mode 100644 ell/ecc.c
> create mode 100644 ell/ecc.h
> =

> diff --git a/Makefile.am b/Makefile.am
> index d115360..dd2798d 100644
> --- a/Makefile.am
> +++ b/Makefile.am
> @@ -49,7 +49,8 @@ pkginclude_HEADERS =3D ell/ell.h \
> 			ell/dir.h \
> 			ell/net.h \
> 			ell/dhcp.h \
> -			ell/cert.h
> +			ell/cert.h \
> +			ell/ecc.h
> =

> lib_LTLIBRARIES =3D ell/libell.la
> =

> @@ -112,7 +113,11 @@ ell_libell_la_SOURCES =3D $(linux_headers) \
> 			ell/dhcp-transport.c \
> 			ell/dhcp-lease.c \
> 			ell/cert.c \
> -			ell/cert-private.h
> +			ell/cert-private.h \
> +			ell/ecc-private.h \
> +			ell/ecc.h \
> +			ell/3rdparty/ecc.c \
> +			ell/ecc.c
> =

> ell_libell_la_LDFLAGS =3D -no-undefined \
> 			-Wl,--version-script=3D$(top_srcdir)/ell/ell.sym \
> diff --git a/ell/3rdparty/ecc.c b/ell/3rdparty/ecc.c
> new file mode 100644
> index 0000000..784b3ba
> --- /dev/null
> +++ b/ell/3rdparty/ecc.c
> @@ -0,0 +1,934 @@
> +/*
> + * Copyright (c) 2013, Kenneth MacKay
> + * All rights reserved.
> + *
> + * Redistribution and use in source and binary forms, with or without
> + * modification, are permitted provided that the following conditions are
> + * met:
> + *  * Redistributions of source code must retain the above copyright
> + *   notice, this list of conditions and the following disclaimer.
> + *  * Redistributions in binary form must reproduce the above copyright
> + *    notice, this list of conditions and the following disclaimer in the
> + *    documentation and/or other materials provided with the distributio=
n.
> + *
> + * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
> + * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
> + * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
> + * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
> + * HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
> + * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
> + * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
> + * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
> + * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
> + * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
> + * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
> + */
> +
> +#ifdef HAVE_CONFIG_H
> +#include <config.h>
> +#endif
> +
> +#include <linux/types.h>
> +#include <stdint.h>
> +#include <stdbool.h>
> +
> +#include "../private.h"
> +#include "../ecc.h"
> +#include "../ecc-private.h"
> +#include "../random.h=E2=80=9D

so I am not a big fan of these nested directory structures in the first pla=
ce and especially not a big fan of the 3rdparty thing.

If we modify the source files to make them compile or use our internal defi=
nitions, then it is no longer external code. If it is code that purely exte=
rnal, we can do ell/ecc-external.[ch] or something like that. We can do the=
 same as we do in ell/siphash.c where we take the code as ELL code and ackn=
owledge the original code and its origin.

Lets go back one step and tell me what this is based on? Is this the old Bl=
ueZ code or is this the micro-ecc?

> diff --git a/ell/ecc.h b/ell/ecc.h
> new file mode 100644
> index 0000000..b135724
> --- /dev/null
> +++ b/ell/ecc.h
> @@ -0,0 +1,70 @@
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
> +#ifndef __ELL_ECC_H
> +#define __ELL_ECC_H
> +
> +#ifdef __cplusplus
> +extern "C" {
> +#endif
> +
> +#define L_ECC_MAX_DIGITS 4
> +#define L_ECC_CONSTANT_MAX_BYTES	L_ECC_MAX_DIGITS * 8
> +#define L_ECC_POINT_MAX_BYTES		L_ECC_CONSTANT_MAX_BYTES * 2
> +
> +struct l_ecc_curve;
> +struct l_ecc_point;
> +struct l_ecc_constant;
> +
> +enum l_ecc_point_type {
> +	L_ECC_POINT_TYPE_COMPLIANT =3D 0x01,
> +	L_ECC_POINT_TYPE_COMPRESSED_MINUS =3D 0x02,
> +	L_ECC_POINT_TYPE_COMPRESSED_PLUS =3D 0x03,
> +	L_ECC_POINT_TYPE_FULL =3D 0x04,
> +};
> +
> +const struct l_ecc_curve *l_ecc_curve_get(unsigned int group);
> +
> +bool l_ecc_valid_point(const struct l_ecc_curve *curve,
> +			struct l_ecc_point *point);
> +struct l_ecc_point *l_ecc_point_new(const struct l_ecc_curve *curve);
> +struct l_ecc_point *l_ecc_point_from_data(const struct l_ecc_curve *curv=
e,
> +					enum l_ecc_point_type type,
> +					const void *data, size_t len);
> +
> +ssize_t l_ecc_point_get_x(const struct l_ecc_point *p, void *x, size_t x=
len);
> +ssize_t l_ecc_point_get_data(const struct l_ecc_point *p, void *buf, siz=
e_t len);
> +void l_ecc_point_free(struct l_ecc_point *p);
> +
> +struct l_ecc_constant *l_ecc_constant_new(const struct l_ecc_curve *curv=
e,
> +						void *buf, size_t len);
> +struct l_ecc_constant *l_ecc_constant_new_random(
> +					const struct l_ecc_curve *curve);
> +ssize_t l_ecc_constant_get_data(const struct l_ecc_constant *c, void *bu=
f,
> +					size_t len);
> +void l_ecc_constant_free(struct l_ecc_constant *c);

Do we need such a rich API? Can we start with a smaller one for things we a=
ctually need from it.

Regards

Marcel


--===============2139964246679469046==--

