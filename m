Content-Type: multipart/mixed; boundary="===============5656638674703207355=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 03/10] tls: Move DER / ASN.1 related definitions to
 asn1-private.h
Date: Fri, 11 Aug 2017 11:17:35 -0500
Message-ID: <c894d349-30e8-1858-08bd-f9b5f73581df@gmail.com>
In-Reply-To: <20170810231016.29445-3-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5656638674703207355==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 08/10/2017 06:10 PM, Andrew Zaborowski wrote:
> Extract those utilities that can be used by pem.c for decoding encrypted
> certificates and possibly other mechanisms.  Introduce the asn1_oid_eq
> macro for comparing OIDs.
> ---
>   ell/asn1-private.h | 118 ++++++++++++++++++++++++++++++++++++++++++++++=
+++++++
>   ell/tls.c          | 102 ++-------------------------------------------
>   2 files changed, 121 insertions(+), 99 deletions(-)
>   create mode 100644 ell/asn1-private.h
> =


We also need the Makefile.am changes.

> diff --git a/ell/asn1-private.h b/ell/asn1-private.h
> new file mode 100644
> index 0000000..c1f1c5d
> --- /dev/null
> +++ b/ell/asn1-private.h
> @@ -0,0 +1,118 @@
> +/*
> + *  Embedded Linux library
> + *
> + *  Copyright (C) 2017  Intel Corporation. All rights reserved.
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
> + */
> +
> +#define ASN1_ID(class, pc, tag)	(((class) << 6) | ((pc) << 5) | (tag))
> +
> +#define ASN1_CLASS_UNIVERSAL	0
> +
> +#define ASN1_ID_SEQUENCE	ASN1_ID(ASN1_CLASS_UNIVERSAL, 1, 0x10)
> +#define ASN1_ID_SET		ASN1_ID(ASN1_CLASS_UNIVERSAL, 1, 0x11)
> +#define ASN1_ID_INTEGER		ASN1_ID(ASN1_CLASS_UNIVERSAL, 0, 0x02)
> +#define ASN1_ID_BIT_STRING	ASN1_ID(ASN1_CLASS_UNIVERSAL, 0, 0x03)
> +#define ASN1_ID_OCTET_STRING	ASN1_ID(ASN1_CLASS_UNIVERSAL, 0, 0x04)
> +#define ASN1_ID_OID		ASN1_ID(ASN1_CLASS_UNIVERSAL, 0, 0x06)
> +#define ASN1_ID_UTF8STRING	ASN1_ID(ASN1_CLASS_UNIVERSAL, 0, 0x0c)
> +#define ASN1_ID_PRINTABLESTRING	ASN1_ID(ASN1_CLASS_UNIVERSAL, 0, 0x13)
> +
> +struct asn1_oid {
> +	uint8_t asn1_len;
> +	uint8_t asn1[10];
> +};
> +
> +#define asn1_oid_eq(oid1, oid2_len, oid2_string) \
> +	((oid1)->asn1_len =3D=3D (oid2_len) && \
> +	 !memcmp((oid1)->asn1, (oid2_string), (oid2_len)))
> +
> +static inline int parse_asn1_definite_length(const uint8_t **buf, > +			=
			size_t *len)

Since this is now a separate (albeit private) module, we should follow =

our usual naming conventions by prefixing with the module name.  So =

should this be asn1_parse_definite_length?

> +{
> +	int n;
> +	size_t result =3D 0;
> +
> +	(*len)--;
> +
> +	if (!(**buf & 0x80))
> +		return *(*buf)++;
> +
> +	n =3D *(*buf)++ & 0x7f;
> +	if ((size_t) n > *len)
> +		return -1;
> +
> +	*len -=3D n;
> +	while (n--)
> +		result =3D (result << 8) | *(*buf)++;
> +
> +	return result;
> +}
> +
> +/* Return index'th element in a DER SEQUENCE */
> +static inline uint8_t *der_find_elem(uint8_t *buf, size_t len_in, int in=
dex,
> +			uint8_t *tag, size_t *len_out)

asn1_der_find_elem?

> +{
> +	int tlv_len;
> +
> +	while (1) {
> +		if (len_in < 2)
> +			return NULL;
> +
> +		*tag =3D *buf++;
> +		len_in--;
> +
> +		tlv_len =3D parse_asn1_definite_length((void *) &buf, &len_in);
> +		if (tlv_len < 0 || (size_t) tlv_len > len_in)
> +			return NULL;
> +
> +		if (index-- =3D=3D 0) {
> +			*len_out =3D tlv_len;
> +			return buf;
> +		}
> +
> +		buf +=3D tlv_len;
> +		len_in -=3D tlv_len;
> +	}
> +}
> +
> +/* Return an element in a DER SEQUENCE structure by path */
> +static inline uint8_t *der_find_elem_by_path(uint8_t *buf, size_t len_in,
> +						uint8_t tag, size_t *len_out,
> +						...)

asn1_der_find_elem_by_path?

> +{
> +	uint8_t elem_tag;
> +	int pos;
> +	va_list vl;
> +
> +	va_start(vl, len_out);
> +
> +	pos =3D va_arg(vl, int);
> +
> +	while (pos !=3D -1) {
> +		buf =3D der_find_elem(buf, len_in, pos, &elem_tag, &len_in);
> +
> +		pos =3D va_arg(vl, int);
> +
> +		if (!buf || elem_tag !=3D (pos =3D=3D -1 ? tag : ASN1_ID_SEQUENCE))
> +			return NULL;
> +	}
> +
> +	va_end(vl);
> +
> +	*len_out =3D len_in;
> +	return buf;
> +}

Otherwise this looks fine.

Regards,
-Denis

--===============5656638674703207355==--

