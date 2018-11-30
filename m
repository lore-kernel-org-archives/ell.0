Content-Type: multipart/mixed; boundary="===============5621669261451197603=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/9] ecc: moved ecc from IWD into ell
Date: Thu, 29 Nov 2018 21:20:56 -0600
Message-ID: <e6d80379-01c9-b711-646d-ac23336d06a1@gmail.com>
In-Reply-To: <20181129220808.22151-1-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5621669261451197603==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

On 11/29/2018 04:08 PM, James Prestwood wrote:
> IWD had its own implementation for ECC and math operations. Eventually
> TLS will indirectly require this (via ECDH) so it made sense to move
> everything into ell. Some changes had to be made to the original file
> to accomidate the ell style.
> =

> The original file (ecc.c) required some changes. The ecc_point type
> is now exposed as l_ecc_point. Several vli_ functions were prefixed
> with "_" so they could be exposed privately. All ecc functions
> that needed to be exposed as library API's were prefixed with l_ecc,
> and changed to take a l_ecc_curve object, explained below.
> =

> A new type was also added, l_ecc_curve, which holds all the information
> for a given curve. Users will call l_curve_get(int group) to get a
> supported curve object. This curve object can then be passed to all
> l_ecc API's which avoids the need for the user to know any of the
> curve parameters (prime, g, n, b, etc.) or vli lengths. Some of these
> parameters may still need to be obtained, so several getters were added
> as well.
> =

> When using any of the l_ecc API's, any vli integers should be
> created as a uint64_t array of size L_ECC_MAX_DIGITS. This ensures
> that the integer will support all supported curves. L_ECC_MAX_DIGITS
> should also be updated if any larger bit size curves are added.
> ---
>   Makefile.am       |    8 +-
>   ell/ecc-private.h |   50 ++
>   ell/ecc.c         | 1288 +++++++++++++++++++++++++++++++++++++++++++++
>   ell/ecc.h         |   84 +++
>   ell/ell.h         |    1 +
>   5 files changed, 1429 insertions(+), 2 deletions(-)
>   create mode 100644 ell/ecc-private.h
>   create mode 100644 ell/ecc.c
>   create mode 100644 ell/ecc.h
> =


So just commenting on the high-level API for now.  Overall my impression =

is that it is still exposing too much low-level details.  Can we get =

away with exposing less?

> diff --git a/ell/ecc.h b/ell/ecc.h
> new file mode 100644
> index 0000000..0601780
> --- /dev/null
> +++ b/ell/ecc.h
> @@ -0,0 +1,84 @@
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
> +
> +struct l_ecc_curve;
> +
> +struct l_ecc_point {
> +	uint64_t x[L_ECC_MAX_DIGITS];
> +	uint64_t y[L_ECC_MAX_DIGITS];
> +	unsigned int ndigits;

You might want to just store the pointer to the ecc_curve here and make =

your life easier in the rest of the API.

> +};

Do you really want to expose this?

> +
> +struct l_ecc_curve *l_ecc_curve_get(unsigned int group);

const struct l_ecc_curve *?

> +
> +unsigned int l_ecc_curve_get_ndigits(struct l_ecc_curve *curve);

const struct?

Is this one really needed, or can it be kept private?

> +
> +const uint64_t *l_ecc_curve_get_prime(struct l_ecc_curve *curve);
> +

As above

> +const uint64_t *l_ecc_curve_get_b(struct l_ecc_curve *curve);

And here

> +struct l_ecc_point *l_ecc_curve_get_generator(struct l_ecc_curve *curve);

And here?

> +void l_ecc_point_set(struct l_ecc_curve *curve, struct l_ecc_point *p,
> +			void *x, void *y);

Should this be something like:

struct l_ecc_point *l_ecc_point_new(const struct l_ecc_curve *curve, =

const void *data, size_t len);

Where I would assume data is in big endian or whatever canonical =

exchange format.

> +bool l_ecc_point_multiply(struct l_ecc_curve *curve, struct l_ecc_point =
*ret,
> +				struct l_ecc_point *p, uint64_t *scalar,
> +				uint64_t *initial_z);
> +bool l_ecc_point_add(struct l_ecc_curve *curve, struct l_ecc_point *ret,
> +			struct l_ecc_point *p, struct l_ecc_point *q);
> +bool l_ecc_valid_point(struct l_ecc_curve *curve, struct l_ecc_point *po=
int);
> +void l_ecc_be2native(struct l_ecc_curve *curve, uint64_t *dest,
> +			uint64_t *bytes);
> +
> +void l_ecc_native2be(struct l_ecc_curve *curve, uint64_t *dest,
> +			uint64_t *native);

So this may be just size_t l_ecc_point_to_be(struct l_ecc_point *point, =

void *dest, size_t dest_len);

> +void l_ecc_compute_y_sqr(struct l_ecc_curve *curve, uint64_t *y_sqr,
> +				uint64_t *x);
> +bool l_ecc_compute_y(struct l_ecc_curve *curve, uint64_t *y, uint64_t *x,
> +			uint8_t y_bit);
> +
> +bool l_ecc_compute_scalar(struct l_ecc_curve *curve, uint64_t *scalar,
> +				uint64_t *rand, uint64_t *mask);
> +
> +bool l_ecc_point_inverse(struct l_ecc_curve *curve, struct l_ecc_point *=
point);
> +
> +bool l_ecc_compute_residue(struct l_ecc_curve *curve,
> +					uint64_t *qr_or_qnr, bool residue);
> +
> +bool l_ecc_is_quadradic_residue(struct l_ecc_curve *curve,
> +					uint64_t *value, uint64_t *qr,
> +					uint64_t *qnr);
> +bool l_ecc_integer_add(struct l_ecc_curve *curve, uint64_t *ret, uint64_=
t *a,
> +			uint64_t *b);
> +

All these uint64_t * things scare me.  Can we not expose these =

operations and expose something a bit more higher level?

Regards,
-Denis

--===============5621669261451197603==--

