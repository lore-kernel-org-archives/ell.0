Content-Type: multipart/mixed; boundary="===============3401038244968995213=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH v2 4/6] pem: refactor to expose pem iterator privately
Date: Mon, 30 Sep 2019 15:17:17 -0700
Message-ID: <20190930221719.786-4-prestwoj@gmail.com>
In-Reply-To: <20190930221719.786-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3401038244968995213==
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
---
 ell/pem-private.h |  31 ++++++++++++++
 ell/pem.c         | 103 ++++++++++++++++++++++++++++++----------------
 2 files changed, 98 insertions(+), 36 deletions(-)
 create mode 100644 ell/pem-private.h

diff --git a/ell/pem-private.h b/ell/pem-private.h
new file mode 100644
index 0000000..0073e65
--- /dev/null
+++ b/ell/pem-private.h
@@ -0,0 +1,31 @@
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
+				size_t *len);
diff --git a/ell/pem.c b/ell/pem.c
index 671f162..530d8c5 100644
--- a/ell/pem.c
+++ b/ell/pem.c
@@ -45,10 +45,25 @@
 #include "cipher.h"
 #include "cert-private.h"
 #include "missing.h"
+#include "pem-private.h"
 =

 #define PEM_START_BOUNDARY	"-----BEGIN "
 #define PEM_END_BOUNDARY	"-----END "
 =

+/*
+ * Gets the base64 data offset of a PEM string (advances past BEGIN tag)
+ */
+#define PEM_BASE64_OFFSET(pem, label) \
+	(pem + strlen(label) + strlen("-----BEGIN -----\n"))
+
+/*
+ * Gets the base64 length from a PEM string. This takes the total PEM leng=
th
+ * and subtracts the length of the BEGIN and END tags
+ */
+#define PEM_BASE64_LEN_OFFSET(label, len) \
+	(len - (strlen(label) + strlen(label) + \
+	strlen("-----BEGIN -----\n") + strlen("-----END -----\n")))
+
 static const void *is_start_boundary(const void *buf, size_t buf_len,
 					size_t *label_len)
 {
@@ -126,48 +141,36 @@ static bool is_end_boundary(const void *buf, size_t b=
uf_len,
 	return true;
 }
 =

-static uint8_t *pem_load_buffer(const void *buf, size_t buf_len,
-				char **type_label, size_t *len,
-				const uint8_t **endp)
+const char *pem_next(const void *buf, size_t buf_len, char **type_label,
+				size_t *len)
 {
 	const char *buf_ptr =3D buf;
-	const char *base64_data =3D NULL, *eol;
+	const char *eol;
 	const char *label =3D NULL;
-	uint8_t *data;
 	size_t label_len =3D 0;
+	const char *start =3D NULL;
 =

-	/*
-	 * The base64 parser uses the RFC7468 laxbase64text grammar but we
-	 * do full checks on the encapsulation boundary lines, i.e. no
-	 * leading spaces allowed, making sure quoted text and similar
-	 * are not confused for actual PEM "textual encoding".
-	 */
 	while (buf_len) {
 		for (eol =3D buf_ptr; eol < buf_ptr + buf_len; eol++)
 			if (*eol =3D=3D '\r' || *eol =3D=3D '\n')
 				break;
 =

-		if (!base64_data) {
-			label =3D is_start_boundary(buf, eol - buf_ptr,
+		if (!start) {
+			label =3D is_start_boundary(buf_ptr, eol - buf_ptr,
 							&label_len);
-
 			if (label)
-				base64_data =3D eol;
-		} else if (is_end_boundary(buf_ptr, eol - buf_ptr, label,
-							label_len)) {
-			data =3D l_base64_decode(
-					(const char *) base64_data,
-					buf_ptr - base64_data, len);
-			if (!data)
+				start =3D label - strlen("-----BEGIN ");
+			else
 				return NULL;
 =

-			*type_label =3D l_strndup((const char *) label,
-							label_len);
+		} else if (start && is_end_boundary(buf_ptr, eol - buf_ptr,
+							label, label_len)) {
+			*len =3D eol - start + 1;
 =

-			if (endp)
-				*endp =3D (uint8_t *)eol + 1;
+			if (type_label)
+				*type_label =3D l_strndup(label, label_len);
 =

-			return data;
+			return start;
 		}
 =

 		if (eol =3D=3D buf_ptr + buf_len)
@@ -182,17 +185,35 @@ static uint8_t *pem_load_buffer(const void *buf, size=
_t buf_len,
 		}
 	}
 =

-	/* If we found no label signal EOF rather than parse error */
-	if (!base64_data && endp)
-		*endp =3D NULL;
-
 	return NULL;
 }
 =

+static uint8_t *pem_load_buffer(const uint8_t *buf, size_t buf_len,
+				char **type_label, size_t *len)
+{
+	const char *pem =3D (const char *)buf;
+	size_t out_len;
+
+	/*
+	 * The base64 parser uses the RFC7468 laxbase64text grammar but we
+	 * do full checks on the encapsulation boundary lines, i.e. no
+	 * leading spaces allowed, making sure quoted text and similar
+	 * are not confused for actual PEM "textual encoding".
+	 */
+
+	pem =3D pem_next(buf, buf_len, type_label, &out_len);
+	if (!pem)
+		return NULL;
+
+	return l_base64_decode(PEM_BASE64_OFFSET(pem, *type_label),
+				PEM_BASE64_LEN_OFFSET(*type_label, out_len),
+				len);
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
@@ -242,7 +263,7 @@ LIB_EXPORT uint8_t *l_pem_load_file(const char *filenam=
e,
 		return NULL;
 =

 	result =3D pem_load_buffer(file.data, file.st.st_size,
-					type_label, len, NULL);
+					type_label, len);
 	pem_file_close(&file);
 	return result;
 }
@@ -297,17 +318,27 @@ LIB_EXPORT struct l_queue *l_pem_load_certificate_lis=
t_from_data(
 	while (ptr && ptr < end) {
 		uint8_t *der;
 		size_t der_len;
-		char *label;
+		char *label =3D NULL;
 		struct l_cert *cert;
+		size_t out_len =3D 0;
+		const char *pem;
+
+		pem =3D pem_next(ptr, len, &label, &out_len);
+		if (!pem)
+			break;
+
+		der =3D l_base64_decode(PEM_BASE64_OFFSET(pem, label),
+					PEM_BASE64_LEN_OFFSET(label, out_len),
+					&der_len);
 =

-		der =3D pem_load_buffer(ptr, end - ptr, &label, &der_len, &ptr);
+		ptr +=3D out_len;
 =

 		if (!der || strcmp(label, "CERTIFICATE")) {
 			if (der)
 				l_free(label);
 			l_free(der);
 =

-			if (!ptr)	/* EOF */
+			if (ptr >=3D end)	/* EOF */
 				break;
 			else
 				goto error;
@@ -470,7 +501,7 @@ LIB_EXPORT struct l_key *l_pem_load_private_key_from_da=
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

--===============3401038244968995213==--

