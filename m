Content-Type: multipart/mixed; boundary="===============5374287412569649146=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 4/7] pem: Add l_pem_load_certificate_list utility
Date: Thu, 01 Nov 2018 03:12:17 +0100
Message-ID: <20181101021220.19073-4-andrew.zaborowski@intel.com>
In-Reply-To: <20181101021220.19073-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5374287412569649146==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

l_pem_load_certificate_list loads all the certificates in a file with
multiple concatenated PEM structures.  This could also be done
previously by calling l_pem_load_file with consecutive index values
until it returned an error, this is a faster way to load all of the
certificates.
---
 ell/pem.c | 83 +++++++++++++++++++++++++++++++++++++++++++++++++++++--
 ell/pem.h |  8 ++++++
 2 files changed, 88 insertions(+), 3 deletions(-)

diff --git a/ell/pem.c b/ell/pem.c
index e24dd7d..1c5c986 100644
--- a/ell/pem.c
+++ b/ell/pem.c
@@ -39,6 +39,7 @@
 #include "asn1-private.h"
 #include "pkcs5-private.h"
 #include "cipher.h"
+#include "queue.h"
 =

 #define PEM_START_BOUNDARY	"-----BEGIN "
 #define PEM_END_BOUNDARY	"-----END "
@@ -119,7 +120,8 @@ static bool is_end_boundary(const uint8_t *buf, size_t =
buf_len,
 }
 =

 static uint8_t *pem_load_buffer(const uint8_t *buf, size_t buf_len, int in=
dex,
-				char **type_label, size_t *len)
+				char **type_label, size_t *len,
+				size_t *consumed)
 {
 	const uint8_t *base64_data =3D NULL, *label =3D NULL, *eol;
 	uint8_t *data;
@@ -152,6 +154,9 @@ static uint8_t *pem_load_buffer(const uint8_t *buf, siz=
e_t buf_len, int index,
 				*type_label =3D l_strndup((const char *) label,
 							label_len);
 =

+				if (consumed)
+					*consumed =3D eol + 1 - buf;
+
 				return data;
 			}
 =

@@ -178,7 +183,7 @@ LIB_EXPORT uint8_t *l_pem_load_buffer(const uint8_t *bu=
f, size_t buf_len,
 					int index, char **type_label,
 					size_t *out_len)
 {
-	return pem_load_buffer(buf, buf_len, index, type_label, out_len);
+	return pem_load_buffer(buf, buf_len, index, type_label, out_len, NULL);
 }
 =

 LIB_EXPORT uint8_t *l_pem_load_file(const char *filename, int index,
@@ -205,7 +210,7 @@ LIB_EXPORT uint8_t *l_pem_load_file(const char *filenam=
e, int index,
 		return NULL;
 	}
 =

-	result =3D pem_load_buffer(data, st.st_size, index, type_label, len);
+	result =3D pem_load_buffer(data, st.st_size, index, type_label, len, NULL=
);
 =

 	munmap(data, st.st_size);
 	close(fd);
@@ -233,6 +238,78 @@ LIB_EXPORT uint8_t *l_pem_load_certificate(const char =
*filename, size_t *len)
 	return content;
 }
 =

+static void pem_element_free(void *data)
+{
+	struct l_pem_list_element *element =3D data;
+
+	l_free(element->content);
+	l_free(element);
+}
+
+LIB_EXPORT struct l_queue *l_pem_load_certificate_list(const char *filenam=
e)
+{
+	int fd;
+	struct stat st;
+	uint8_t *data;
+	size_t start =3D 0;
+	struct l_queue *result =3D NULL;
+
+	fd =3D open(filename, O_RDONLY);
+	if (fd < 0)
+		return NULL;
+
+	if (fstat(fd, &st) < 0) {
+		close(fd);
+
+		return NULL;
+	}
+
+	data =3D mmap(NULL, st.st_size, PROT_READ, MAP_SHARED, fd, 0);
+	if (data =3D=3D MAP_FAILED) {
+		close(fd);
+
+		return NULL;
+	}
+
+	while (1) {
+		uint8_t *certificate;
+		size_t len, consumed;
+		char *label;
+		struct l_pem_list_element *element;
+
+		certificate =3D pem_load_buffer(data + start, st.st_size - start, 0,
+						&label, &len, &consumed);
+		if (!certificate)
+			goto done;
+
+		if (strcmp(label, "CERTIFICATE")) {
+			l_free(certificate);
+			break;
+		}
+
+		l_free(label);
+		element =3D l_malloc(sizeof(struct l_pem_list_element));
+		element->content =3D certificate;
+		element->len =3D len;
+
+		if (!result)
+			result =3D l_queue_new();
+
+		l_queue_push_tail(result, element);
+		start +=3D consumed;
+	}
+
+	/* Error occured */
+	l_queue_destroy(result, pem_element_free);
+	result =3D NULL;
+
+done:
+	munmap(data, st.st_size);
+	close(fd);
+
+	return result;
+}
+
 /**
  * l_pem_load_private_key
  * @filename: path string to the PEM file to load
diff --git a/ell/pem.h b/ell/pem.h
index 93282a3..9cead5c 100644
--- a/ell/pem.h
+++ b/ell/pem.h
@@ -27,12 +27,20 @@
 extern "C" {
 #endif
 =

+struct l_queue;
+
+struct l_pem_list_element {
+	uint8_t *content;
+	size_t len;
+};
+
 uint8_t *l_pem_load_buffer(const uint8_t *buf, size_t buf_len,
 				int index, char **type_label, size_t *out_len);
 uint8_t *l_pem_load_file(const char *filename, int index,
 				char **type_label, size_t *len);
 =

 uint8_t *l_pem_load_certificate(const char *filename, size_t *len);
+struct l_queue *l_pem_load_certificate_list(const char *filename);
 =

 uint8_t *l_pem_load_private_key(const char *filename, const char *passphra=
se,
 				bool *encrypted, size_t *len);
-- =

2.19.1


--===============5374287412569649146==--

