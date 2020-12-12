Content-Type: multipart/mixed; boundary="===============2674641262489571583=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 3/5] pem: Add l_pem_load_container_file
Date: Sat, 12 Dec 2020 01:50:58 +0100
Message-ID: <20201212005100.578174-3-andrew.zaborowski@intel.com>
In-Reply-To: <20201212005100.578174-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2674641262489571583==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add a function that takes a file path and detects what X.509 certificate
and/or private key format it uses and parses it accordingly.  This is to
make it easier for clients to support multiple file formats, including
raw X.509 certificates -- without this they would have to load the
contents of the file and call l_cert_new_from_der().
l_pem_load_container can also be used instead of
l_pem_load_certificate_chain() and l_pem_load_private_key().

This function can now load binary certificate files which are not PEM
but there wasn't a better place for it than pem.c.  I guess the name
could also be improved to imply that it's for certificate and private
key container files, but I couldn't come up with a name that isn't too
long.

This function treats PEM files as containers that can have both private
keys and certificates at the same time, openssl can parse such files and
also produces such files in some situations and they may have some good
uses.
---
 ell/ell.sym |   1 +
 ell/pem.c   | 157 ++++++++++++++++++++++++++++++++++++++++++++++++++--
 ell/pem.h   |   5 ++
 3 files changed, 158 insertions(+), 5 deletions(-)

diff --git a/ell/ell.sym b/ell/ell.sym
index d94b585..03c46d0 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -415,6 +415,7 @@ global:
 	l_pem_load_file;
 	l_pem_load_private_key;
 	l_pem_load_private_key_from_data;
+	l_pem_load_container_file;
 	/* pkcs5 */
 	l_pkcs5_pbkdf1;
 	l_pkcs5_pbkdf2;
diff --git a/ell/pem.c b/ell/pem.c
index 1b995d5..90d06fb 100644
--- a/ell/pem.c
+++ b/ell/pem.c
@@ -195,7 +195,7 @@ const char *pem_next(const void *buf, size_t buf_len, c=
har **type_label,
 =

 static uint8_t *pem_load_buffer(const void *buf, size_t buf_len,
 				char **out_type_label, size_t *out_len,
-				char **out_headers)
+				char **out_headers, const char **out_endp)
 {
 	size_t base64_len;
 	const char *base64;
@@ -203,7 +203,7 @@ static uint8_t *pem_load_buffer(const void *buf, size_t=
 buf_len,
 	uint8_t *ret;
 =

 	base64 =3D pem_next(buf, buf_len, &label, &base64_len,
-				NULL, false);
+				out_endp, false);
 	if (!base64)
 		return NULL;
 =

@@ -262,7 +262,7 @@ static uint8_t *pem_load_buffer(const void *buf, size_t=
 buf_len,
 LIB_EXPORT uint8_t *l_pem_load_buffer(const void *buf, size_t buf_len,
 					char **type_label, size_t *out_len)
 {
-	return pem_load_buffer(buf, buf_len, type_label, out_len, NULL);
+	return pem_load_buffer(buf, buf_len, type_label, out_len, NULL, NULL);
 }
 =

 struct pem_file_info {
@@ -315,7 +315,8 @@ static uint8_t *pem_load_file(const char *filename, cha=
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
@@ -888,7 +889,7 @@ LIB_EXPORT struct l_key *l_pem_load_private_key_from_da=
ta(const void *buf,
 	if (encrypted)
 		*encrypted =3D false;
 =

-	content =3D pem_load_buffer(buf, buf_len, &label, &len, &headers);
+	content =3D pem_load_buffer(buf, buf_len, &label, &len, &headers, NULL);
 =

 	if (!content)
 		return NULL;
@@ -933,3 +934,149 @@ LIB_EXPORT struct l_key *l_pem_load_private_key(const=
 char *filename,
 	return pem_load_private_key(content, len, label, passphrase, headers,
 					encrypted);
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
+ */
+LIB_EXPORT void l_pem_load_container_file(const char *filename,
+					const char *password,
+					struct l_certchain **out_certchain,
+					struct l_key **out_privkey,
+					bool *out_encrypted)
+{
+	struct pem_file_info file;
+	const char *ptr;
+	size_t len;
+	bool error =3D false;
+
+	if (out_encrypted)
+		*out_encrypted =3D false;
+
+	if (out_certchain)
+		*out_certchain =3D NULL;
+
+	if (out_privkey)
+		*out_privkey =3D NULL;
+
+	if (unlikely(!filename))
+		return;
+
+	if (pem_file_open(&file, filename) < 0)
+		return;
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
+				*out_certchain =3D certchain_new_from_leaf(cert);
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
+	while (!error && len) {
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
+		if (!strcmp(type_label, "CERTIFICATE")) {
+			struct l_cert *cert;
+
+			if (!out_certchain)
+				goto next;
+
+			if (!(cert =3D l_cert_new_from_der(der, der_len))) {
+				l_certchain_free(*out_certchain);
+				*out_certchain =3D NULL;
+				error =3D true;
+				goto next;
+			}
+
+			if (!*out_certchain)
+				*out_certchain =3D certchain_new_from_leaf(cert);
+			else
+				certchain_link_issuer(*out_certchain, cert);
+
+			goto next;
+		}
+
+		/* Only use the first private key found */
+		if (out_privkey && !*out_privkey) {
+			*out_privkey =3D pem_load_private_key(der, der_len,
+								type_label,
+								password,
+								headers,
+								out_encrypted);
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
+}
diff --git a/ell/pem.h b/ell/pem.h
index 1c93e7a..ce5af04 100644
--- a/ell/pem.h
+++ b/ell/pem.h
@@ -50,6 +50,11 @@ struct l_key *l_pem_load_private_key_from_data(const voi=
d *buf, size_t len,
 						const char *passphrase,
 						bool *encrypted);
 =

+void l_pem_load_container_file(const char *filename, const char *password,
+				struct l_certchain **out_certchain,
+				struct l_key **out_privkey,
+				bool *out_encrypted);
+
 #ifdef __cplusplus
 }
 #endif
-- =

2.27.0

--===============2674641262489571583==--

