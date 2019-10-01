Content-Type: multipart/mixed; boundary="===============3376189997983233299=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH v4 1/3] pem: refactor to expose pem iterator privately
Date: Tue, 01 Oct 2019 14:21:46 -0700
Message-ID: <20191001212148.19721-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3376189997983233299==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This refactors pem.c to expose a new internal API, pem_next. This
API will allow iteration/parsing of PEM(s). Other APIs in pem.c were
updated to use pem_next.

pem_next behaves similar to pem_load_buffer, except it does not do
any base64 decoding. Instead it just returns the start of the PEM as
a string, and the length as an out parameter. This allows simple
PEM iteration loops. Strictly for pem.c usage we decode the base64
string in the loop, but settings.c will need this for parsing PEMs
from settings files and returning the PEM as a full string, including
the start/end tags.

endp was removed from pem_load_buffer as it was no longer being used.
---
 ell/pem-private.h | 32 ++++++++++++++++++++
 ell/pem.c         | 77 ++++++++++++++++++++++++++++++++---------------
 2 files changed, 85 insertions(+), 24 deletions(-)
 create mode 100644 ell/pem-private.h

-v4:
 * Added 'stict' argument to pem_next. =


diff --git a/ell/pem-private.h b/ell/pem-private.h
new file mode 100644
index 0000000..bb0127f
--- /dev/null
+++ b/ell/pem-private.h
@@ -0,0 +1,32 @@
+/*
+ *
+ *  Embedded Linux library
+ *
+ *  Copyright (C) 2019  Intel Corporation. All rights reserved.
+ *
+ *  This library is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU Lesser General Public
+ *  License as published by the Free Software Foundation; either
+ *  version 2.1 of the License, or (at your option) any later version.
+ *
+ *  This library is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ *  Lesser General Public License for more details.
+ *
+ *  You should have received a copy of the GNU Lesser General Public
+ *  License along with this library; if not, write to the Free Software
+ *  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 =
 USA
+ *
+ */
+
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif
+
+#define _GNU_SOURCE
+#include <sys/types.h>
+
+const char *pem_next(const void *buf, size_t buf_len, char **type_label,
+				size_t *len, size_t *base64_len,
+				const char **endp, bool strict);
diff --git a/ell/pem.c b/ell/pem.c
index c2bf7ba..79e4d07 100644
--- a/ell/pem.c
+++ b/ell/pem.c
@@ -45,6 +45,7 @@
 #include "cipher.h"
 #include "cert-private.h"
 #include "missing.h"
+#include "pem-private.h"
 =

 #define PEM_START_BOUNDARY	"-----BEGIN "
 #define PEM_END_BOUNDARY	"-----END "
@@ -126,15 +127,15 @@ static bool is_end_boundary(const void *buf, size_t b=
uf_len,
 	return true;
 }
 =

-static uint8_t *pem_load_buffer(const void *buf, size_t buf_len,
-				char **type_label, size_t *len,
-				const uint8_t **endp)
+const char *pem_next(const void *buf, size_t buf_len, char **type_label,
+				size_t *len, size_t *base64_len,
+				const char **endp, bool strict)
 {
 	const char *buf_ptr =3D buf;
 	const char *base64_data =3D NULL, *eol;
 	const char *label =3D NULL;
-	uint8_t *data;
 	size_t label_len =3D 0;
+	const char *start =3D NULL;
 =

 	/*
 	 * The base64 parser uses the RFC7468 laxbase64text grammar but we
@@ -148,26 +149,28 @@ static uint8_t *pem_load_buffer(const void *buf, size=
_t buf_len,
 				break;
 =

 		if (!base64_data) {
-			label =3D is_start_boundary(buf, eol - buf_ptr,
+			label =3D is_start_boundary(buf_ptr, eol - buf_ptr,
 							&label_len);
-
-			if (label)
+			if (label) {
+				start =3D label - strlen("-----BEGIN ");
 				base64_data =3D eol;
-		} else if (is_end_boundary(buf_ptr, eol - buf_ptr, label,
-							label_len)) {
-			data =3D l_base64_decode(
-					(const char *) base64_data,
-					buf_ptr - base64_data, len);
-			if (!data)
-				return NULL;
+			} else if (strict)
+				break;
+		} else if (start && is_end_boundary(buf_ptr, eol - buf_ptr,
+							label, label_len)) {
+			if (len)
+				*len =3D eol - start + 1;
 =

-			*type_label =3D l_strndup((const char *) label,
-							label_len);
+			if (type_label)
+				*type_label =3D l_strndup(label, label_len);
+
+			if (base64_len)
+				*base64_len =3D buf_ptr - base64_data - 1;
 =

 			if (endp)
-				*endp =3D (uint8_t *)eol + 1;
+				*endp =3D eol + 1;
 =

-			return data;
+			return base64_data;
 		}
 =

 		if (eol =3D=3D buf_ptr + buf_len)
@@ -189,10 +192,24 @@ static uint8_t *pem_load_buffer(const void *buf, size=
_t buf_len,
 	return NULL;
 }
 =

+static uint8_t *pem_load_buffer(const void *buf, size_t buf_len,
+				char **type_label, size_t *len)
+{
+	size_t base64_len;
+	const char *base64;
+
+	base64 =3D pem_next(buf, buf_len, type_label, NULL, &base64_len,
+				NULL, false);
+	if (!base64)
+		return NULL;
+
+	return l_base64_decode(base64, base64_len, len);
+}
+
 LIB_EXPORT uint8_t *l_pem_load_buffer(const void *buf, size_t buf_len,
 					char **type_label, size_t *out_len)
 {
-	return pem_load_buffer(buf, buf_len, type_label, out_len, NULL);
+	return pem_load_buffer(buf, buf_len, type_label, out_len);
 }
 =

 struct pem_file_info {
@@ -242,7 +259,7 @@ LIB_EXPORT uint8_t *l_pem_load_file(const char *filenam=
e,
 		return NULL;
 =

 	result =3D pem_load_buffer(file.data, file.st.st_size,
-					type_label, len, NULL);
+					type_label, len);
 	pem_file_close(&file);
 	return result;
 }
@@ -288,7 +305,7 @@ LIB_EXPORT struct l_certchain *l_pem_load_certificate_c=
hain(
 LIB_EXPORT struct l_queue *l_pem_load_certificate_list_from_data(
 						const void *buf, size_t len)
 {
-	const uint8_t *ptr, *end;
+	const char *ptr, *end;
 	struct l_queue *list =3D NULL;
 =

 	ptr =3D buf;
@@ -297,10 +314,22 @@ LIB_EXPORT struct l_queue *l_pem_load_certificate_lis=
t_from_data(
 	while (ptr && ptr < end) {
 		uint8_t *der;
 		size_t der_len;
-		char *label;
+		char *label =3D NULL;
 		struct l_cert *cert;
+		size_t out_len =3D 0;
+		const char *base64;
+		size_t base64_len;
+
+		base64 =3D pem_next(ptr, len, &label, &out_len, &base64_len,
+					&ptr, false);
+		/* if ptr is set but we got NULL, this was a parse error */
+		if (!base64 && ptr)
+			goto error;
+
+		if (!base64)
+			break;
 =

-		der =3D pem_load_buffer(ptr, end - ptr, &label, &der_len, &ptr);
+		der =3D l_base64_decode(base64, base64_len, &der_len);
 =

 		if (!der || strcmp(label, "CERTIFICATE")) {
 			if (der)
@@ -470,7 +499,7 @@ LIB_EXPORT struct l_key *l_pem_load_private_key_from_da=
ta(const void *buf,
 	if (encrypted)
 		*encrypted =3D false;
 =

-	content =3D pem_load_buffer(buf, buf_len, &label, &len, NULL);
+	content =3D pem_load_buffer(buf, buf_len, &label, &len);
 =

 	if (!content)
 		return NULL;
-- =

2.17.1

--===============3376189997983233299==--

