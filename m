Content-Type: multipart/mixed; boundary="===============0831872869536499070=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 5/8] cert: Add l_cert_load_container_file
Date: Wed, 06 Jan 2021 20:54:43 +0100
Message-ID: <20210106195446.1428769-5-andrew.zaborowski@intel.com>
In-Reply-To: <20210106195446.1428769-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0831872869536499070==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add a function that takes a file path and detects what X.509 certificate
and/or private key format it uses and parses it accordingly.  This is to
make it easier for clients to support multiple file formats, including
raw X.509 certificates -- without this they would have to load the
contents of the file and call l_cert_new_from_der().
l_cert_load_container can also be used instead of
l_pem_load_certificate_chain() and l_pem_load_private_key().

This function can now load binary certificate files which are not PEM,
that's why it's placed in cert.c but a bunch of utilities in pem.c are
exposed in pem-private.h for this function.. It treats PEM files as
containers that can have both private keys and certificates at the same
time, openssl can parse such files and also produces such files in some
situations and they may have some good uses.
---
 ell/cert.c        | 184 ++++++++++++++++++++++++++++++++++++++++++++++
 ell/cert.h        |   5 ++
 ell/ell.sym       |   1 +
 ell/pem-private.h |  18 +++++
 ell/pem.c         |  34 +++------
 5 files changed, 220 insertions(+), 22 deletions(-)

diff --git a/ell/cert.c b/ell/cert.c
index 8f0a4c2..b2bf568 100644
--- a/ell/cert.c
+++ b/ell/cert.c
@@ -30,6 +30,7 @@
 #include "queue.h"
 #include "asn1-private.h"
 #include "cipher.h"
+#include "pem-private.h"
 #include "cert.h"
 #include "cert-private.h"
 =

@@ -737,3 +738,186 @@ struct l_key *cert_key_from_pkcs1_rsa_private_key(con=
st uint8_t *der,
 =

 	return pkey;
 }
+
+/*
+ * Look at a file, try to detect which of the few X.509 certificate and/or
+ * private key container formats it uses and load any certificates in it as
+ * a certificate chain object, and load the first private key as an l_key
+ * object.
+ *
+ * Currently supported are:
+ *  PEM X.509 certificates
+ *  PEM PKCS#8 encrypted and unenecrypted private keys
+ *  PEM legacy PKCS#1 encrypted and unenecrypted private keys
+ *  Raw X.509 certificates (.cer, .der, .crt)
+ *
+ * The raw format contains exactly one certificate, PEM and PKCS#12 files
+ * can contain any combination of certificates and private keys.
+ *
+ * Returns false on "unrecoverable" errors, and *out_certchain,
+ * *out_privkey and *out_encrypted (if provided) are not modified.  However
+ * when true is returned, *out_certchain and *out_privkey (if provided) may
+ * be set to NULL when nothing could be loaded only due to missing passwor=
d,
+ * and *out_encrypted (if provided) will be set accordingly.  It will also
+ * be set on success to indicate whether the password was used.
+ * *out_certchain and/or *out_privkey will also be NULL if the container
+ * was loaded but there were no certificates or private keys in it.
+ */
+LIB_EXPORT bool l_cert_load_container_file(const char *filename,
+					const char *password,
+					struct l_certchain **out_certchain,
+					struct l_key **out_privkey,
+					bool *out_encrypted)
+{
+	struct pem_file_info file;
+	const char *ptr;
+	size_t len;
+	bool error =3D true;
+	bool done =3D false;
+	struct l_certchain *certchain =3D NULL;
+	struct l_key *privkey =3D NULL;
+	bool encrypted =3D false;
+
+	if (unlikely(!filename))
+		return false;
+
+	if (pem_file_open(&file, filename) < 0)
+		return false;
+
+	if (file.st.st_size < 1)
+		goto close;
+
+	/* See if we have a DER sequence tag@the start */
+	if (file.data[0] =3D=3D ASN1_ID_SEQUENCE) {
+		const uint8_t *seq_data;
+		const uint8_t *elem_data;
+		size_t elem_len;
+		uint8_t tag;
+
+		if (!(seq_data =3D asn1_der_find_elem(file.data, file.st.st_size,
+							0, &tag, &len)))
+			goto not_der_after_all;
+
+		/*
+		 * See if the first sub-element is another sequence, then, out
+		 * of the formats that we currently support this can only be a
+		 * raw certificate.  If integer, it's going to be PKCS#12.  If
+		 * we wish to add any more formats we'll probably need to start
+		 * guessing from the filename suffix.
+		 */
+		if (!(elem_data =3D asn1_der_find_elem(seq_data, len,
+							0, &tag, &elem_len)))
+			goto not_der_after_all;
+
+		if (tag =3D=3D ASN1_ID_SEQUENCE) {
+			if (out_certchain) {
+				struct l_cert *cert;
+
+				if (!(cert =3D l_cert_new_from_der(file.data,
+							file.st.st_size)))
+					goto close;
+
+				error =3D false;
+				certchain =3D certchain_new_from_leaf(cert);
+			}
+
+			goto close;
+		}
+	}
+
+not_der_after_all:
+	/*
+	 * RFC 7486 allows whitespace and possibly other data before the
+	 * PEM "encapsulation boundary" so rather than check if the start
+	 * of the data looks like PEM, we fall back to this format if the
+	 * data didn't look like anything else we knew about.
+	 */
+	ptr =3D (const char *) file.data;
+	len =3D file.st.st_size;
+	error =3D false;
+	while (!done && !error && len) {
+		uint8_t *der;
+		size_t der_len;
+		char *type_label;
+		char *headers;
+		const char *endp;
+
+		if (!(der =3D pem_load_buffer(ptr, len, &type_label, &der_len,
+						&headers, &endp)))
+			break;
+
+		len -=3D endp - ptr;
+		ptr =3D endp;
+
+		if (out_certchain && L_IN_STRSET(type_label, "CERTIFICATE")) {
+			struct l_cert *cert;
+
+			if (!(cert =3D l_cert_new_from_der(der, der_len))) {
+				error =3D true;
+				goto next;
+			}
+
+			if (!certchain)
+				certchain =3D certchain_new_from_leaf(cert);
+			else
+				certchain_link_issuer(certchain, cert);
+
+			goto next;
+		}
+
+		/* Only use the first private key found */
+		if (out_privkey && !privkey && L_IN_STRSET(type_label,
+							"PRIVATE KEY",
+							"ENCRYPTED PRIVATE KEY",
+							"RSA PRIVATE KEY")) {
+			privkey =3D pem_load_private_key(der, der_len, type_label,
+							password, headers,
+							&encrypted);
+			if (!privkey) {
+				if (certchain) {
+					l_certchain_free(certchain);
+					certchain =3D NULL;
+				}
+
+				if (password)
+					error =3D true;
+				else
+					error =3D !encrypted || !out_encrypted;
+
+				done =3D true;
+			}
+
+			continue;
+		}
+
+next:
+		explicit_bzero(der, der_len);
+		l_free(der);
+		l_free(type_label);
+		l_free(headers);
+	}
+
+close:
+	pem_file_close(&file);
+
+	if (error) {
+		if (certchain)
+			l_certchain_free(certchain);
+
+		if (privkey)
+			l_key_free(privkey);
+
+		return false;
+	}
+
+	if (out_certchain)
+		*out_certchain =3D certchain;
+
+	if (out_privkey)
+		*out_privkey =3D privkey;
+
+	if (out_encrypted)
+		*out_encrypted =3D encrypted;
+
+	return true;
+}
diff --git a/ell/cert.h b/ell/cert.h
index 8dbb4ab..f3910bb 100644
--- a/ell/cert.h
+++ b/ell/cert.h
@@ -59,6 +59,11 @@ void l_certchain_walk_from_ca(struct l_certchain *chain,
 bool l_certchain_verify(struct l_certchain *chain, struct l_queue *ca_cert=
s,
 			const char **error);
 =

+bool l_cert_load_container_file(const char *filename, const char *password,
+				struct l_certchain **out_certchain,
+				struct l_key **out_privkey,
+				bool *out_encrypted);
+
 bool l_cert_pkcs5_pbkdf1(enum l_checksum_type type, const char *password,
 				const uint8_t *salt, size_t salt_len,
 				unsigned int iter_count,
diff --git a/ell/ell.sym b/ell/ell.sym
index cdbc5e8..aa0c046 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -533,6 +533,7 @@ global:
 	l_certchain_walk_from_leaf;
 	l_certchain_walk_from_ca;
 	l_certchain_verify;
+	l_cert_load_container_file;
 	l_cert_pkcs5_pbkdf1;
 	l_cert_pkcs5_pbkdf2;
 	/* ecc */
diff --git a/ell/pem-private.h b/ell/pem-private.h
index 68e3fcb..c249283 100644
--- a/ell/pem-private.h
+++ b/ell/pem-private.h
@@ -26,12 +26,30 @@
 =

 #define _GNU_SOURCE
 #include <sys/types.h>
+#include <sys/stat.h>
 =

 struct l_certchain;
 =

+struct pem_file_info {
+	int fd;
+	struct stat st;
+	uint8_t *data;
+};
+
+int pem_file_open(struct pem_file_info *info, const char *filename);
+void pem_file_close(struct pem_file_info *info);
+
 const char *pem_next(const void *buf, size_t buf_len, char **type_label,
 				size_t *base64_len,
 				const char **endp, bool strict);
 =

+uint8_t *pem_load_buffer(const void *buf, size_t buf_len,
+				char **out_type_label, size_t *out_len,
+				char **out_headers, const char **out_endp);
+
+struct l_key *pem_load_private_key(uint8_t *content, size_t len, char *lab=
el,
+					const char *passphrase, char *headers,
+					bool *encrypted);
+
 int pem_write_certificate_chain(const struct l_certchain *cert,
 				const char *filename);
diff --git a/ell/pem.c b/ell/pem.c
index 384fb9f..bc2865a 100644
--- a/ell/pem.c
+++ b/ell/pem.c
@@ -25,8 +25,6 @@
 #endif
 =

 #define _GNU_SOURCE
-#include <sys/types.h>
-#include <sys/stat.h>
 #include <fcntl.h>
 #include <unistd.h>
 #include <sys/mman.h>
@@ -192,9 +190,9 @@ const char *pem_next(const void *buf, size_t buf_len, c=
har **type_label,
 	return NULL;
 }
 =

-static uint8_t *pem_load_buffer(const void *buf, size_t buf_len,
+uint8_t *pem_load_buffer(const void *buf, size_t buf_len,
 				char **out_type_label, size_t *out_len,
-				char **out_headers)
+				char **out_headers, const char **out_endp)
 {
 	size_t base64_len;
 	const char *base64;
@@ -202,7 +200,7 @@ static uint8_t *pem_load_buffer(const void *buf, size_t=
 buf_len,
 	uint8_t *ret;
 =

 	base64 =3D pem_next(buf, buf_len, &label, &base64_len,
-				NULL, false);
+				out_endp, false);
 	if (!base64)
 		return NULL;
 =

@@ -261,16 +259,10 @@ static uint8_t *pem_load_buffer(const void *buf, size=
_t buf_len,
 LIB_EXPORT uint8_t *l_pem_load_buffer(const void *buf, size_t buf_len,
 					char **type_label, size_t *out_len)
 {
-	return pem_load_buffer(buf, buf_len, type_label, out_len, NULL);
+	return pem_load_buffer(buf, buf_len, type_label, out_len, NULL, NULL);
 }
 =

-struct pem_file_info {
-	int fd;
-	struct stat st;
-	uint8_t *data;
-};
-
-static int pem_file_open(struct pem_file_info *info, const char *filename)
+int pem_file_open(struct pem_file_info *info, const char *filename)
 {
 	info->fd =3D open(filename, O_RDONLY);
 	if (info->fd < 0)
@@ -295,7 +287,7 @@ static int pem_file_open(struct pem_file_info *info, co=
nst char *filename)
 	return 0;
 }
 =

-static void pem_file_close(struct pem_file_info *info)
+void pem_file_close(struct pem_file_info *info)
 {
 	munmap(info->data, info->st.st_size);
 	close(info->fd);
@@ -314,7 +306,8 @@ static uint8_t *pem_load_file(const char *filename, cha=
r **out_type_label,
 		return NULL;
 =

 	result =3D pem_load_buffer(file.data, file.st.st_size,
-					out_type_label, out_len, out_headers);
+					out_type_label, out_len, out_headers,
+					NULL);
 	pem_file_close(&file);
 	return result;
 }
@@ -645,12 +638,9 @@ cleanup:
 	return cipher;
 }
 =

-static struct l_key *pem_load_private_key(uint8_t *content,
-						size_t len,
-						char *label,
-						const char *passphrase,
-						char *headers,
-						bool *encrypted)
+struct l_key *pem_load_private_key(uint8_t *content, size_t len, char *lab=
el,
+					const char *passphrase, char *headers,
+					bool *encrypted)
 {
 	struct l_key *pkey;
 =

@@ -779,7 +769,7 @@ LIB_EXPORT struct l_key *l_pem_load_private_key_from_da=
ta(const void *buf,
 	if (encrypted)
 		*encrypted =3D false;
 =

-	content =3D pem_load_buffer(buf, buf_len, &label, &len, &headers);
+	content =3D pem_load_buffer(buf, buf_len, &label, &len, &headers, NULL);
 =

 	if (!content)
 		return NULL;
-- =

2.27.0

--===============0831872869536499070==--

