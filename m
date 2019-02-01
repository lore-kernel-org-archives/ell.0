Content-Type: multipart/mixed; boundary="===============0130247971887437550=="
MIME-Version: 1.0
From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] uuid: Added l_uuid_parse
Date: Fri, 01 Feb 2019 17:15:08 +0100
Message-ID: <35E8B0B5-82F3-4A91-A08E-FA506815851A@holtmann.org>
In-Reply-To: <20190201134617.28831-1-michal.lowas-rzechonek@silvair.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0130247971887437550==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Michal,

> This commit adds API complementary to l_uuid_to_string, allowing parsing
> canonical string representation into a byte array.

I would have called it l_uuid_from_string.

> I've also changed printf/scanf formatting to use PRIx/SCNx macros, for
> better portability.

This should be a separate patch.

> ---
> ell/uuid.c       | 54 ++++++++++++++++++++++++++++++++++++-------
> ell/uuid.h       |  1 +
> unit/test-uuid.c | 60 ++++++++++++++++++++++++++++++++++++++++++++++++
> 3 files changed, 107 insertions(+), 8 deletions(-)
> =

> diff --git a/ell/uuid.c b/ell/uuid.c
> index a4d72fc..26893a5 100644
> --- a/ell/uuid.c
> +++ b/ell/uuid.c
> @@ -25,6 +25,7 @@
> #endif
> =

> #define _GNU_SOURCE
> +#include <inttypes.h>
> #include <stdio.h>
> =

> #include "checksum.h"
> @@ -210,17 +211,54 @@ LIB_EXPORT bool l_uuid_to_string(const uint8_t uuid=
[16],
> {
> 	int n;
> =

> -	n =3D snprintf(dest, dest_size, "%02x%02x%02x%02x-%02x%02x-%02x%02x-"
> -					"%02x%02x-%02x%02x%02x%02x%02x%02x",
> -					uuid[0], uuid[1], uuid[2], uuid[3],
> -					uuid[4], uuid[5],
> -					uuid[6], uuid[7],
> -					uuid[8], uuid[9],
> -					uuid[10], uuid[11], uuid[12],
> -					uuid[13], uuid[14], uuid[15]);
> +	n =3D snprintf(dest, dest_size,
> +			"%02" PRIx8 "%02" PRIx8 "%02" PRIx8 "%02" PRIx8 "-"
> +			"%02" PRIx8 "%02" PRIx8 "-"
> +			"%02" PRIx8 "%02" PRIx8 "-"
> +			"%02" PRIx8 "%02" PRIx8 "-"
> +			"%02" PRIx8 "%02" PRIx8 "%02" PRIx8 "%02" PRIx8 "%02" PRIx8 "%02" PRI=
x8 "",
> +			uuid[0], uuid[1], uuid[2], uuid[3],
> +			uuid[4], uuid[5],
> +			uuid[6], uuid[7],
> +			uuid[8], uuid[9],
> +			uuid[10], uuid[11], uuid[12], uuid[13], uuid[14], uuid[15]);
> =

> 	if (n < 0 || (size_t) n >=3D dest_size)
> 		return false;
> =

> 	return true;
> }
> +
> +LIB_EXPORT bool l_uuid_parse(const char *src, size_t src_size,
> +							 uint8_t uuid[16])
> +{

Don=E2=80=99t bother with src_size parameter. You can use strlen for that s=
ince supporting non null-terminated strings seems rather pointless. You wil=
l required space or null terminator at the end of make sscanf actually work=
 correctly anyway. So I would rather check that the string is long enough t=
o hold an actual UUID text representation and that you have a proper termin=
ator at the end.

Regards

Marcel


--===============0130247971887437550==--

