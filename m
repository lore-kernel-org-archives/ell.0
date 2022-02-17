Content-Type: multipart/mixed; boundary="===============6500809843915527471=="
MIME-Version: 1.0
From: James Prestwood <prestwoj at gmail.com>
To: ell at lists.01.org
Subject: [PATCH] base64: refactor l_base64_decode and validate bytes consumed
Date: Wed, 16 Feb 2022 16:35:21 -0800
Message-ID: <20220217003521.1671260-1-prestwoj@gmail.com>

--===============6500809843915527471==
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
 ell/base64.c | 25 +++++++++----------------
 1 file changed, 9 insertions(+), 16 deletions(-)

diff --git a/ell/base64.c b/ell/base64.c
index e430470..340550f 100644
--- a/ell/base64.c
+++ b/ell/base64.c
@@ -33,7 +33,7 @@ LIB_EXPORT uint8_t *l_base64_decode(const char *in, size_=
t in_len,
 {
 	const char *ptr, *in_end =3D in + in_len;
 	uint8_t *out_buf, *out;
-	int base64_len =3D 0, pad_len;
+	int base64_len =3D 0, pad_len =3D 0;
 	uint16_t reg =3D 0;
 =

 	for (ptr =3D in; ptr < in_end; ptr++)
@@ -42,32 +42,25 @@ LIB_EXPORT uint8_t *l_base64_decode(const char *in, siz=
e_t in_len,
 			continue;
 		else if (*ptr =3D=3D '=3D')
 			/* Final padding */
-			break;
-		else if (l_ascii_isalnum(*ptr) || *ptr =3D=3D '+' || *ptr =3D=3D '/')
+			pad_len++;
+		else if (!pad_len && (l_ascii_isalnum(*ptr) || *ptr =3D=3D '+' ||
+					*ptr =3D=3D '/'))
 			/* Base64 character */
 			base64_len++;
 		else
 			/* Bad character */
 			return NULL;
 =

-	in_end =3D ptr;
+	if (ptr !=3D in_end)
+		return NULL;
+
+	in_end =3D ptr - pad_len;
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
+	if (pad_len !=3D ((4 - base64_len) & 3))
 		return NULL;
 =

 	*n_written =3D base64_len * 3 / 4;
-- =

2.34.1

--===============6500809843915527471==--

