Content-Type: multipart/mixed; boundary="===============4350906745710841240=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 1/5] pem: add _from_data variants to pem APIs
Date: Fri, 27 Sep 2019 12:30:05 -0700
Message-ID: <20190927193009.30262-2-prestwoj@gmail.com>
In-Reply-To: <20190927193009.30262-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4350906745710841240==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Loading cert chains/lists, and private keys was only possible to
do from a file, or as a raw buffer (e.g. from the network). This
patch adds 3 new APIs:

l_pem_load_certificate_chain_from_data
l_pem_load_certificate_list_from_data
l_pem_load_private_key_from_data

These expect the input data just as if it was read in from a PEM
file (BEGIN/END included).
---
 ell/ell.sym |   3 ++
 ell/pem.c   | 141 +++++++++++++++++++++++++++++++++++++---------------
 ell/pem.h   |   7 +++
 3 files changed, 111 insertions(+), 40 deletions(-)

diff --git a/ell/ell.sym b/ell/ell.sym
index 709a0b4..e02f0fe 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -362,9 +362,12 @@ global:
 	/* pem */
 	l_pem_load_buffer;
 	l_pem_load_certificate_chain;
+	l_pem_load_certificate_chain_from_data;
 	l_pem_load_certificate_list;
+	l_pem_load_certificate_list_from_data;
 	l_pem_load_file;
 	l_pem_load_private_key;
+	l_pem_load_private_key_from_data;
 	/* pkcs5 */
 	l_pkcs5_pbkdf1;
 	l_pkcs5_pbkdf2;
diff --git a/ell/pem.c b/ell/pem.c
index 1e51fc5..e268f50 100644
--- a/ell/pem.c
+++ b/ell/pem.c
@@ -247,10 +247,8 @@ LIB_EXPORT uint8_t *l_pem_load_file(const char *filena=
me, int index,
 	return result;
 }
 =

-LIB_EXPORT struct l_certchain *l_pem_load_certificate_chain(
-							const char *filename)
+static struct l_certchain *pem_list_to_chain(struct l_queue *list)
 {
-	struct l_queue *list =3D l_pem_load_certificate_list(filename);
 	struct l_certchain *chain;
 =

 	if (!list)
@@ -265,17 +263,36 @@ LIB_EXPORT struct l_certchain *l_pem_load_certificate=
_chain(
 	return chain;
 }
 =

-LIB_EXPORT struct l_queue *l_pem_load_certificate_list(const char *filenam=
e)
+LIB_EXPORT struct l_certchain *l_pem_load_certificate_chain_from_data(
+						const void *buf, size_t len)
 {
-	struct pem_file_info file;
-	const uint8_t *ptr, *end;
-	struct l_queue *list =3D NULL;
+	struct l_queue *list =3D l_pem_load_certificate_list_from_data(buf, len);
 =

-	if (pem_file_open(&file, filename) < 0)
+	if (!list)
+		return NULL;
+
+	return pem_list_to_chain(list);
+}
+
+LIB_EXPORT struct l_certchain *l_pem_load_certificate_chain(
+							const char *filename)
+{
+	struct l_queue *list =3D l_pem_load_certificate_list(filename);
+
+	if (!list)
 		return NULL;
 =

-	ptr =3D file.data;
-	end =3D file.data + file.st.st_size;
+	return pem_list_to_chain(list);
+}
+
+LIB_EXPORT struct l_queue *l_pem_load_certificate_list_from_data(
+						const void *buf, size_t len)
+{
+	const uint8_t *ptr, *end;
+	struct l_queue *list =3D NULL;
+
+	ptr =3D buf;
+	end =3D buf + len;
 =

 	while (ptr && ptr < end) {
 		uint8_t *der;
@@ -309,47 +326,35 @@ LIB_EXPORT struct l_queue *l_pem_load_certificate_lis=
t(const char *filename)
 		l_queue_push_tail(list, cert);
 	}
 =

-	pem_file_close(&file);
 	return list;
 =

 error:
 	l_queue_destroy(list, (l_queue_destroy_func_t) l_cert_free);
-	pem_file_close(&file);
 	return NULL;
 }
 =

-/**
- * l_pem_load_private_key
- * @filename: path string to the PEM file to load
- * @passphrase: private key encryption passphrase or NULL for unencrypted
- * @encrypted: receives indication whether the file was encrypted if non-N=
ULL
- *
- * Load the PEM encoded RSA Private Key file at @filename.  If it is an
- * encrypted private key and @passphrase was non-NULL, the file is
- * decrypted.  If it's unencrypted @passphrase is ignored.  @encrypted
- * stores information of whether the file was encrypted, both in a
- * success case and on error when NULL is returned.  This can be used to
- * check if a passphrase is required without prior information.
- *
- * Returns: An l_key object to be freed with an l_key_free* function,
- * or NULL.
- **/
-LIB_EXPORT struct l_key *l_pem_load_private_key(const char *filename,
-						const char *passphrase,
-						bool *encrypted)
+LIB_EXPORT struct l_queue *l_pem_load_certificate_list(const char *filenam=
e)
 {
-	uint8_t *content;
-	char *label;
-	size_t len;
-	struct l_key *pkey =3D NULL;
+	struct pem_file_info file;
+	struct l_queue *list =3D NULL;
 =

-	if (encrypted)
-		*encrypted =3D false;
+	if (pem_file_open(&file, filename) < 0)
+		return NULL;
 =

-	content =3D l_pem_load_file(filename, 0, &label, &len);
+	list =3D l_pem_load_certificate_list_from_data(file.data,
+							file.st.st_size);
+	pem_file_close(&file);
 =

-	if (!content)
-		return NULL;
+	return list;
+}
+
+static struct l_key *pem_load_private_key(uint8_t *content,
+						size_t len,
+						char *label,
+						const char *passphrase,
+						bool *encrypted)
+{
+	struct l_key *pkey =3D NULL;
 =

 	/*
 	 * RFC7469- and PKCS#8-compatible label (default in OpenSSL 1.0.1+)
@@ -452,3 +457,59 @@ err:
 	l_free(label);
 	return pkey;
 }
+
+LIB_EXPORT struct l_key *l_pem_load_private_key_from_data(const void *buf,
+							size_t buf_len,
+							const char *passphrase,
+							bool *encrypted)
+{
+	uint8_t *content;
+	char *label;
+	size_t len;
+
+	if (encrypted)
+		*encrypted =3D false;
+
+	content =3D pem_load_buffer(buf, buf_len, 0, &label, &len, NULL);
+
+	if (!content)
+		return NULL;
+
+	return pem_load_private_key(content, len, label, passphrase, encrypted);
+}
+
+
+/**
+ * l_pem_load_private_key
+ * @filename: path string to the PEM file to load
+ * @passphrase: private key encryption passphrase or NULL for unencrypted
+ * @encrypted: receives indication whether the file was encrypted if non-N=
ULL
+ *
+ * Load the PEM encoded RSA Private Key file@@filename.  If it is an
+ * encrypted private key and @passphrase was non-NULL, the file is
+ * decrypted.  If it's unencrypted @passphrase is ignored.  @encrypted
+ * stores information of whether the file was encrypted, both in a
+ * success case and on error when NULL is returned.  This can be used to
+ * check if a passphrase is required without prior information.
+ *
+ * Returns: An l_key object to be freed with an l_key_free* function,
+ * or NULL.
+ **/
+LIB_EXPORT struct l_key *l_pem_load_private_key(const char *filename,
+						const char *passphrase,
+						bool *encrypted)
+{
+	uint8_t *content;
+	char *label;
+	size_t len;
+
+	if (encrypted)
+		*encrypted =3D false;
+
+	content =3D l_pem_load_file(filename, 0, &label, &len);
+
+	if (!content)
+		return NULL;
+
+	return pem_load_private_key(content, len, label, passphrase, encrypted);
+}
diff --git a/ell/pem.h b/ell/pem.h
index fc5b019..41583e2 100644
--- a/ell/pem.h
+++ b/ell/pem.h
@@ -38,11 +38,18 @@ uint8_t *l_pem_load_file(const char *filename, int inde=
x,
 				char **type_label, size_t *len);
 =

 struct l_certchain *l_pem_load_certificate_chain(const char *filename);
+struct l_certchain *l_pem_load_certificate_chain_from_data(const void *buf,
+								size_t len);
 struct l_queue *l_pem_load_certificate_list(const char *filename);
+struct l_queue *l_pem_load_certificate_list_from_data(const void *buf,
+							size_t len);
 =

 struct l_key *l_pem_load_private_key(const char *filename,
 					const char *passphrase,
 					bool *encrypted);
+struct l_key *l_pem_load_private_key_from_data(const void *buf, size_t len,
+						const char *passphrase,
+						bool *encrypted);
 =

 #ifdef __cplusplus
 }
-- =

2.17.1


--===============4350906745710841240==--

