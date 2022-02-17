Content-Type: multipart/mixed; boundary="===============0861497405069222492=="
MIME-Version: 1.0
From: James Prestwood <prestwoj at gmail.com>
To: ell at lists.01.org
Subject: [PATCH v2 1/2] base64: refactor l_base64_decode and validate bytes
 consumed
Date: Thu, 17 Feb 2022 12:13:04 -0800
Message-ID: <20220217201305.2065223-1-prestwoj@gmail.com>

--===============0861497405069222492==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The way the base64 data was being validated was accurate, but included a
second loop to iterate the padding. There was nothing wrong with this but
for more concise/readable code the padding can be calculated and validated
all after the first loop by incrementing pad_len when '=3D' is found rather
than breaking out. The valid base64 character check did need a slight
modification to also check that pad_len has not been incremented, which
ensures there is no data after the padding (prior this was done by the
second, pad checking, loop).

Then, after the loop, pad_len has been calculated and can be checked against
what was expected based on the valid base64 characters found.

This refactoring also makes checking the bytes consumed much easier since
the first loop iterates until the very end of the base64 data (including
padding).
---
 ell/base64.c | 41 ++++++++++++++++++++++-------------------
 1 file changed, 22 insertions(+), 19 deletions(-)

v2:
 * Fix issue in calculating the end of the base64 data (caused test-pem to
   fail). This was because whitespace was not taken into account which
   could exist between the base64 and padding. Instead the end of the
   base64 data is now saved when the first pad byte is found. This allows
   the second loop to use this as its end condition.

diff --git a/ell/base64.c b/ell/base64.c
index e430470..747d4d5 100644
--- a/ell/base64.c
+++ b/ell/base64.c
@@ -27,56 +27,59 @@
 #include "utf8.h"
 #include "base64.h"
 #include "private.h"
+#include "useful.h"
+
+#include <stdio.h>
 =

 LIB_EXPORT uint8_t *l_base64_decode(const char *in, size_t in_len,
 					size_t *n_written)
 {
 	const char *ptr, *in_end =3D in + in_len;
+	const char *base64_end =3D NULL;
 	uint8_t *out_buf, *out;
-	int base64_len =3D 0, pad_len;
+	int base64_len =3D 0, pad_len =3D 0;
 	uint16_t reg =3D 0;
 =

-	for (ptr =3D in; ptr < in_end; ptr++)
+	for (ptr =3D in; ptr < in_end; ptr++) {
 		if (l_ascii_isspace(*ptr))
 			/* Whitespace */
 			continue;
-		else if (*ptr =3D=3D '=3D')
+		else if (*ptr =3D=3D '=3D') {
 			/* Final padding */
-			break;
-		else if (l_ascii_isalnum(*ptr) || *ptr =3D=3D '+' || *ptr =3D=3D '/')
+			if (!pad_len)
+				base64_end =3D ptr;
+
+			pad_len++;
+		} else if (!pad_len && (l_ascii_isalnum(*ptr) || *ptr =3D=3D '+' ||
+					*ptr =3D=3D '/'))
 			/* Base64 character */
 			base64_len++;
 		else
 			/* Bad character */
 			return NULL;
+	}
 =

-	in_end =3D ptr;
+	if (ptr !=3D in_end)
+		return NULL;
 =

 	if ((base64_len & 3) =3D=3D 1)
 		/* Invalid length */
 		return NULL;
 =

-	pad_len =3D (4 - base64_len) & 3;
-	for (; ptr < in + in_len && pad_len; ptr++)
-		if (l_ascii_isspace(*ptr))
-			/* Whitespace */
-			continue;
-		else if (*ptr =3D=3D '=3D')
-			/* Final padding */
-			pad_len--;
-		else
-			/* Bad character */
-			return NULL;
-	if (pad_len)
+	if (pad_len !=3D align_len(base64_len, 4) - base64_len)
 		return NULL;
 =

+	/* No padding */
+	if (!base64_end)
+		base64_end =3D ptr;
+
 	*n_written =3D base64_len * 3 / 4;
 	out_buf =3D l_malloc(*n_written);
 =

 	out =3D out_buf;
 	base64_len =3D 0;
 =

-	for (ptr =3D in; ptr < in_end; ptr++) {
+	for (ptr =3D in; ptr < base64_end; ptr++) {
 		if (l_ascii_isspace(*ptr))
 			/* Whitespace */
 			continue;
-- =

2.34.1

--===============0861497405069222492==--

