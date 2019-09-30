Content-Type: multipart/mixed; boundary="===============0191221494958200682=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH v2 1/6] pem: remove index argument
Date: Mon, 30 Sep 2019 15:17:14 -0700
Message-ID: <20190930221719.786-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0191221494958200682==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This argument seems to always be hard coded to zero.
---
 ell/pem.c | 41 ++++++++++++++++++-----------------------
 ell/pem.h |  5 ++---
 2 files changed, 20 insertions(+), 26 deletions(-)

diff --git a/ell/pem.c b/ell/pem.c
index 352d461..721a05b 100644
--- a/ell/pem.c
+++ b/ell/pem.c
@@ -124,7 +124,7 @@ static bool is_end_boundary(const uint8_t *buf, size_t =
buf_len,
 	return true;
 }
 =

-static uint8_t *pem_load_buffer(const uint8_t *buf, size_t buf_len, int in=
dex,
+static uint8_t *pem_load_buffer(const uint8_t *buf, size_t buf_len,
 				char **type_label, size_t *len,
 				const uint8_t **endp)
 {
@@ -149,24 +149,19 @@ static uint8_t *pem_load_buffer(const uint8_t *buf, s=
ize_t buf_len, int index,
 			if (label)
 				base64_data =3D eol;
 		} else if (is_end_boundary(buf, eol - buf, label, label_len)) {
-			if (index =3D=3D 0) {
-				data =3D l_base64_decode(
-						(const char *) base64_data,
-						buf - base64_data, len);
-				if (!data)
-					return NULL;
-
-				*type_label =3D l_strndup((const char *) label,
-							label_len);
+			data =3D l_base64_decode(
+					(const char *) base64_data,
+					buf - base64_data, len);
+			if (!data)
+				return NULL;
 =

-				if (endp)
-					*endp =3D eol + 1;
+			*type_label =3D l_strndup((const char *) label,
+							label_len);
 =

-				return data;
-			}
+			if (endp)
+				*endp =3D eol + 1;
 =

-			base64_data =3D NULL;
-			index--;
+			return data;
 		}
 =

 		if (eol =3D=3D buf + buf_len)
@@ -189,10 +184,10 @@ static uint8_t *pem_load_buffer(const uint8_t *buf, s=
ize_t buf_len, int index,
 }
 =

 LIB_EXPORT uint8_t *l_pem_load_buffer(const uint8_t *buf, size_t buf_len,
-					int index, char **type_label,
+					char **type_label,
 					size_t *out_len)
 {
-	return pem_load_buffer(buf, buf_len, index, type_label, out_len, NULL);
+	return pem_load_buffer(buf, buf_len, type_label, out_len, NULL);
 }
 =

 struct pem_file_info {
@@ -232,7 +227,7 @@ static void pem_file_close(struct pem_file_info *info)
 	close(info->fd);
 }
 =

-LIB_EXPORT uint8_t *l_pem_load_file(const char *filename, int index,
+LIB_EXPORT uint8_t *l_pem_load_file(const char *filename,
 					char **type_label, size_t *len)
 {
 	struct pem_file_info file;
@@ -241,7 +236,7 @@ LIB_EXPORT uint8_t *l_pem_load_file(const char *filenam=
e, int index,
 	if (pem_file_open(&file, filename) < 0)
 		return NULL;
 =

-	result =3D pem_load_buffer(file.data, file.st.st_size, index,
+	result =3D pem_load_buffer(file.data, file.st.st_size,
 					type_label, len, NULL);
 	pem_file_close(&file);
 	return result;
@@ -300,7 +295,7 @@ LIB_EXPORT struct l_queue *l_pem_load_certificate_list_=
from_data(
 		char *label;
 		struct l_cert *cert;
 =

-		der =3D pem_load_buffer(ptr, end - ptr, 0, &label, &der_len, &ptr);
+		der =3D pem_load_buffer(ptr, end - ptr, &label, &der_len, &ptr);
 =

 		if (!der || strcmp(label, "CERTIFICATE")) {
 			if (der)
@@ -470,7 +465,7 @@ LIB_EXPORT struct l_key *l_pem_load_private_key_from_da=
ta(const void *buf,
 	if (encrypted)
 		*encrypted =3D false;
 =

-	content =3D pem_load_buffer(buf, buf_len, 0, &label, &len, NULL);
+	content =3D pem_load_buffer(buf, buf_len, &label, &len, NULL);
 =

 	if (!content)
 		return NULL;
@@ -505,7 +500,7 @@ LIB_EXPORT struct l_key *l_pem_load_private_key(const c=
har *filename,
 	if (encrypted)
 		*encrypted =3D false;
 =

-	content =3D l_pem_load_file(filename, 0, &label, &len);
+	content =3D l_pem_load_file(filename, &label, &len);
 =

 	if (!content)
 		return NULL;
diff --git a/ell/pem.h b/ell/pem.h
index 41583e2..da5e273 100644
--- a/ell/pem.h
+++ b/ell/pem.h
@@ -33,9 +33,8 @@ struct l_cert;
 struct l_certchain;
 =

 uint8_t *l_pem_load_buffer(const uint8_t *buf, size_t buf_len,
-				int index, char **type_label, size_t *out_len);
-uint8_t *l_pem_load_file(const char *filename, int index,
-				char **type_label, size_t *len);
+				char **type_label, size_t *out_len);
+uint8_t *l_pem_load_file(const char *filename, char **type_label, size_t *=
len);
 =

 struct l_certchain *l_pem_load_certificate_chain(const char *filename);
 struct l_certchain *l_pem_load_certificate_chain_from_data(const void *buf,
-- =

2.17.1

--===============0191221494958200682==--

