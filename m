Content-Type: multipart/mixed; boundary="===============7310410557626328788=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH v2 3/6] pem: convert l_pem_load_buffer to take void*
Date: Mon, 30 Sep 2019 15:17:16 -0700
Message-ID: <20190930221719.786-3-prestwoj@gmail.com>
In-Reply-To: <20190930221719.786-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7310410557626328788==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This handles both cases of PEM's being loaded as text data and
as raw bytes. is_{start,end}_boundary was also converted.
---
 ell/pem.c | 55 ++++++++++++++++++++++++++++++-------------------------
 ell/pem.h |  4 ++--
 2 files changed, 32 insertions(+), 27 deletions(-)

diff --git a/ell/pem.c b/ell/pem.c
index 721a05b..671f162 100644
--- a/ell/pem.c
+++ b/ell/pem.c
@@ -49,11 +49,12 @@
 #define PEM_START_BOUNDARY	"-----BEGIN "
 #define PEM_END_BOUNDARY	"-----END "
 =

-static const uint8_t *is_start_boundary(const uint8_t *buf, size_t buf_len,
+static const void *is_start_boundary(const void *buf, size_t buf_len,
 					size_t *label_len)
 {
 	const uint8_t *start, *end, *ptr;
 	int prev_special, special;
+	const uint8_t *buf_ptr =3D buf;
 =

 	if (buf_len < strlen(PEM_START_BOUNDARY))
 		return NULL;
@@ -74,7 +75,7 @@ static const uint8_t *is_start_boundary(const uint8_t *bu=
f, size_t buf_len,
 	end =3D start;
 	prev_special =3D 1;
 =

-	while (end < buf + buf_len && l_ascii_isprint(*end)) {
+	while (end < buf_ptr + buf_len && l_ascii_isprint(*end)) {
 		special =3D *end =3D=3D ' ' || *end =3D=3D '-';
 =

 		if (prev_special && special)
@@ -89,11 +90,11 @@ static const uint8_t *is_start_boundary(const uint8_t *=
buf, size_t buf_len,
 		end--;
 =

 	/* Check we have a "-----" (RFC7468 section 2) */
-	if (end + 5 > buf + buf_len || memcmp(end, "-----", 5))
+	if (end + 5 > buf_ptr + buf_len || memcmp(end, "-----", 5))
 		return NULL;
 =

 	/* Check all remaining characters are horizontal whitespace (WSP) */
-	for (ptr =3D end + 5; ptr < buf + buf_len; ptr++)
+	for (ptr =3D end + 5; ptr < buf_ptr + buf_len; ptr++)
 		if (*ptr !=3D ' ' && *ptr !=3D '\t')
 			return NULL;
 =

@@ -102,33 +103,36 @@ static const uint8_t *is_start_boundary(const uint8_t=
 *buf, size_t buf_len,
 	return start;
 }
 =

-static bool is_end_boundary(const uint8_t *buf, size_t buf_len,
-				const uint8_t *label, size_t label_len)
+static bool is_end_boundary(const void *buf, size_t buf_len,
+				const char *label, size_t label_len)
 {
+	const uint8_t *buf_ptr =3D buf;
 	size_t len =3D strlen(PEM_END_BOUNDARY) + label_len + 5;
 =

 	if (buf_len < len)
 		return false;
 =

-	if (memcmp(buf, PEM_END_BOUNDARY, strlen(PEM_END_BOUNDARY)) ||
-			memcmp(buf + strlen(PEM_END_BOUNDARY),
+	if (memcmp(buf_ptr, PEM_END_BOUNDARY, strlen(PEM_END_BOUNDARY)) ||
+			memcmp(buf_ptr + strlen(PEM_END_BOUNDARY),
 				label, label_len) ||
-			memcmp(buf + (len - 5), "-----", 5))
+			memcmp(buf_ptr + (len - 5), "-----", 5))
 		return false;
 =

 	/* Check all remaining characters are horizontal whitespace (WSP) */
 	for (; len < buf_len; len++)
-		if (buf[len] !=3D ' ' && buf[len] !=3D '\t')
+		if (buf_ptr[len] !=3D ' ' && buf_ptr[len] !=3D '\t')
 			return false;
 =

 	return true;
 }
 =

-static uint8_t *pem_load_buffer(const uint8_t *buf, size_t buf_len,
+static uint8_t *pem_load_buffer(const void *buf, size_t buf_len,
 				char **type_label, size_t *len,
 				const uint8_t **endp)
 {
-	const uint8_t *base64_data =3D NULL, *label =3D NULL, *eol;
+	const char *buf_ptr =3D buf;
+	const char *base64_data =3D NULL, *eol;
+	const char *label =3D NULL;
 	uint8_t *data;
 	size_t label_len =3D 0;
 =

@@ -139,19 +143,21 @@ static uint8_t *pem_load_buffer(const uint8_t *buf, s=
ize_t buf_len,
 	 * are not confused for actual PEM "textual encoding".
 	 */
 	while (buf_len) {
-		for (eol =3D buf; eol < buf + buf_len; eol++)
+		for (eol =3D buf_ptr; eol < buf_ptr + buf_len; eol++)
 			if (*eol =3D=3D '\r' || *eol =3D=3D '\n')
 				break;
 =

 		if (!base64_data) {
-			label =3D is_start_boundary(buf, eol - buf, &label_len);
+			label =3D is_start_boundary(buf, eol - buf_ptr,
+							&label_len);
 =

 			if (label)
 				base64_data =3D eol;
-		} else if (is_end_boundary(buf, eol - buf, label, label_len)) {
+		} else if (is_end_boundary(buf_ptr, eol - buf_ptr, label,
+							label_len)) {
 			data =3D l_base64_decode(
 					(const char *) base64_data,
-					buf - base64_data, len);
+					buf_ptr - base64_data, len);
 			if (!data)
 				return NULL;
 =

@@ -159,19 +165,19 @@ static uint8_t *pem_load_buffer(const uint8_t *buf, s=
ize_t buf_len,
 							label_len);
 =

 			if (endp)
-				*endp =3D eol + 1;
+				*endp =3D (uint8_t *)eol + 1;
 =

 			return data;
 		}
 =

-		if (eol =3D=3D buf + buf_len)
+		if (eol =3D=3D buf_ptr + buf_len)
 			break;
 =

-		buf_len -=3D eol + 1 - buf;
-		buf =3D eol + 1;
+		buf_len -=3D eol + 1 - buf_ptr;
+		buf_ptr =3D eol + 1;
 =

-		if (buf_len && *eol =3D=3D '\r' && *buf =3D=3D '\n') {
-			buf++;
+		if (buf_len && *eol =3D=3D '\r' && *buf_ptr =3D=3D '\n') {
+			buf_ptr++;
 			buf_len--;
 		}
 	}
@@ -183,9 +189,8 @@ static uint8_t *pem_load_buffer(const uint8_t *buf, siz=
e_t buf_len,
 	return NULL;
 }
 =

-LIB_EXPORT uint8_t *l_pem_load_buffer(const uint8_t *buf, size_t buf_len,
-					char **type_label,
-					size_t *out_len)
+LIB_EXPORT uint8_t *l_pem_load_buffer(const void *buf, size_t buf_len,
+					char **type_label, size_t *out_len)
 {
 	return pem_load_buffer(buf, buf_len, type_label, out_len, NULL);
 }
diff --git a/ell/pem.h b/ell/pem.h
index da5e273..1c93e7a 100644
--- a/ell/pem.h
+++ b/ell/pem.h
@@ -32,8 +32,8 @@ struct l_key;
 struct l_cert;
 struct l_certchain;
 =

-uint8_t *l_pem_load_buffer(const uint8_t *buf, size_t buf_len,
-				char **type_label, size_t *out_len);
+uint8_t *l_pem_load_buffer(const void *buf, size_t buf_len, char **type_la=
bel,
+				size_t *out_len);
 uint8_t *l_pem_load_file(const char *filename, char **type_label, size_t *=
len);
 =

 struct l_certchain *l_pem_load_certificate_chain(const char *filename);
-- =

2.17.1

--===============7310410557626328788==--

