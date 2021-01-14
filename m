Content-Type: multipart/mixed; boundary="===============8735283711023209468=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/3] cert: Split l_cert_load_container_file
Date: Thu, 14 Jan 2021 19:50:56 +0100
Message-ID: <20210114185057.2035125-2-andrew.zaborowski@intel.com>
In-Reply-To: <20210114185057.2035125-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8735283711023209468==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Move the DER file format detection and loading into one function and the
PEM detection and loading into another, splitting the
l_cert_load_container_file code into three functions.
---
 ell/cert.c | 272 +++++++++++++++++++++++++++++++----------------------
 1 file changed, 158 insertions(+), 114 deletions(-)

diff --git a/ell/cert.c b/ell/cert.c
index cf81931..c26051f 100644
--- a/ell/cert.c
+++ b/ell/cert.c
@@ -1374,147 +1374,112 @@ error:
 	return false;
 }
 =

-/*
- * Look at a file, try to detect which of the few X.509 certificate and/or
- * private key container formats it uses and load any certificates in it as
- * a certificate chain object, and load the first private key as an l_key
- * object.
- *
- * Currently supported are:
- *  PEM X.509 certificates
- *  PEM PKCS#8 encrypted and unencrypted private keys
- *  PEM legacy PKCS#1 encrypted and unencrypted private keys
- *  Raw X.509 certificates (.cer, .der, .crt)
- *  PKCS#12 certificates
- *  PKCS#12 encrypted private keys
- *
- * The raw format contains exactly one certificate, PEM and PKCS#12 files
- * can contain any combination of certificates and private keys.
- *
- * The password must have been validated as UTF-8 (use l_utf8_validate)
- * unless the caller knows that no PKCS#12-defined encryption algorithm
- * or MAC is used.
- *
- * Returns false on "unrecoverable" errors, and *out_certchain,
- * *out_privkey and *out_encrypted (if provided) are not modified.  However
- * when true is returned, *out_certchain and *out_privkey (if provided) may
- * be set to NULL when nothing could be loaded only due to missing passwor=
d,
- * and *out_encrypted (if provided) will be set accordingly.  It will also
- * be set on success to indicate whether the password was used.
- * *out_certchain and/or *out_privkey will also be NULL if the container
- * was loaded but there were no certificates or private keys in it.
- */
-LIB_EXPORT bool l_cert_load_container_file(const char *filename,
+static int cert_try_load_der_format(const uint8_t *content, size_t content=
_len,
 					const char *password,
 					struct l_certchain **out_certchain,
 					struct l_key **out_privkey,
 					bool *out_encrypted)
 {
-	struct pem_file_info file;
-	const char *ptr;
-	size_t len;
-	bool error =3D true;
-	bool done =3D false;
-	struct l_certchain *certchain =3D NULL;
-	struct l_key *privkey =3D NULL;
-	bool encrypted =3D false;
+	const uint8_t *seq;
+	size_t seq_len;
+	const uint8_t *elem_data;
+	size_t elem_len;
+	uint8_t tag;
 =

-	if (unlikely(!filename))
-		return false;
+	if (!(seq =3D asn1_der_find_elem(content, content_len,
+					0, &tag, &seq_len)))
+		/* May not have been a DER file after all */
+		return -ENOMSG;
 =

-	if (pem_file_open(&file, filename) < 0)
-		return false;
+	/*
+	 * See if the first sub-element is another sequence, then, out of
+	 * the formats that we currently support this can only be a raw
+	 * certificate.  If integer, it's going to be PKCS#12.  If we wish
+	 * to add any more formats we'll probably need to start guessing
+	 * from the filename suffix.
+	 */
+	if (!(elem_data =3D asn1_der_find_elem(seq, seq_len,
+						0, &tag, &elem_len)))
+		return -ENOMSG;
 =

-	if (file.st.st_size < 1)
-		goto close;
+	if (tag =3D=3D ASN1_ID_SEQUENCE) {
+		if (out_certchain) {
+			struct l_cert *cert;
 =

-	/* See if we have a DER sequence tag at the start */
-	if (file.data[0] =3D=3D ASN1_ID_SEQUENCE) {
-		const uint8_t *seq_data;
-		const uint8_t *elem_data;
-		size_t elem_len;
-		uint8_t tag;
+			if (!(cert =3D l_cert_new_from_der(content, content_len)))
+				return -EINVAL;
 =

-		if (!(seq_data =3D asn1_der_find_elem(file.data, file.st.st_size,
-							0, &tag, &len)))
-			goto not_der_after_all;
+			*out_certchain =3D certchain_new_from_leaf(cert);
 =

+			if (out_privkey)
+				*out_privkey =3D NULL;
+
+			return 0;
+		}
+
+		return -EINVAL;
+	}
+
+	if (tag =3D=3D ASN1_ID_INTEGER) {
 		/*
-		 * See if the first sub-element is another sequence, then, out
-		 * of the formats that we currently support this can only be a
-		 * raw certificate.  If integer, it's going to be PKCS#12.  If
-		 * we wish to add any more formats we'll probably need to start
-		 * guessing from the filename suffix.
+		 * Since we don't support public key-protected PKCS#12
+		 * modes, we always require the password at least for the
+		 * integrity check.  Strictly speaking encryption may not
+		 * actually be in use.  We also don't support files with
+		 * different integrity and privacy passwords, they must
+		 * be identical if privacy is enabled.
 		 */
-		if (!(elem_data =3D asn1_der_find_elem(seq_data, len,
-							0, &tag, &elem_len)))
-			goto not_der_after_all;
+		if (out_encrypted)
+			*out_encrypted =3D true;
 =

-		if (tag =3D=3D ASN1_ID_SEQUENCE) {
-			if (out_certchain) {
-				struct l_cert *cert;
+		if (!password) {
+			if (!out_encrypted)
+				return -EINVAL;
 =

-				if (!(cert =3D l_cert_new_from_der(file.data,
-							file.st.st_size)))
-					goto close;
+			if (out_certchain)
+				*out_certchain =3D NULL;
 =

-				error =3D false;
-				certchain =3D certchain_new_from_leaf(cert);
-			}
+			if (out_privkey)
+				*out_privkey =3D NULL;
 =

-			goto close;
+			return 0;
 		}
 =

-		if (tag =3D=3D ASN1_ID_INTEGER) {
-			/*
-			 * Since we don't support public key-protected PKCS#12
-			 * modes, we always require the password at least for
-			 * the integrity check.  Strictly speaking encryption
-			 * may not actually be in use.  We also don't support
-			 * files with different integrity and privacy
-			 * passwords, they must be identical if privacy is
-			 * enabled.
-			 */
-			encrypted =3D true;
+		if (cert_parse_pkcs12_pfx(seq, seq_len, password,
+						out_certchain, out_privkey))
+			return 0;
+		else
+			return -EINVAL;
+	}
 =

-			if (!password) {
-				error =3D !out_encrypted;
-				done =3D true;
-				goto close;
-			}
+	return -ENOMSG;
+}
 =

-			error =3D !cert_parse_pkcs12_pfx(seq_data, len, password,
-							out_certchain ?
-							&certchain : NULL,
-							out_privkey ?
-							&privkey : NULL);
-			goto close;
-		}
-	}
+static bool cert_try_load_pem_format(const char *content, size_t content_l=
en,
+					const char *password,
+					struct l_certchain **out_certchain,
+					struct l_key **out_privkey,
+					bool *out_encrypted)
+{
+	bool error =3D false;
+	bool done =3D false;
+	struct l_certchain *certchain =3D NULL;
+	struct l_key *privkey =3D NULL;
+	bool encrypted =3D false;
 =

-not_der_after_all:
-	/*
-	 * RFC 7486 allows whitespace and possibly other data before the
-	 * PEM "encapsulation boundary" so rather than check if the start
-	 * of the data looks like PEM, we fall back to this format if the
-	 * data didn't look like anything else we knew about.
-	 */
-	ptr =3D (const char *) file.data;
-	len =3D file.st.st_size;
-	error =3D false;
-	while (!done && !error && len) {
+	while (!done && !error && content_len) {
 		uint8_t *der;
 		size_t der_len;
 		char *type_label;
 		char *headers;
 		const char *endp;
 =

-		if (!(der =3D pem_load_buffer(ptr, len, &type_label, &der_len,
-						&headers, &endp)))
+		if (!(der =3D pem_load_buffer(content, content_len, &type_label,
+						&der_len, &headers, &endp)))
 			break;
 =

-		len -=3D endp - ptr;
-		ptr =3D endp;
+		content_len -=3D endp - content;
+		content =3D endp;
 =

 		if (out_certchain && L_IN_STRSET(type_label, "CERTIFICATE")) {
 			struct l_cert *cert;
@@ -1587,9 +1552,6 @@ next:
 		l_free(headers);
 	}
 =

-close:
-	pem_file_close(&file);
-
 	if (error) {
 		if (certchain)
 			l_certchain_free(certchain);
@@ -1611,3 +1573,85 @@ close:
 =

 	return true;
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
+ *  PEM PKCS#8 encrypted and unencrypted private keys
+ *  PEM legacy PKCS#1 encrypted and unencrypted private keys
+ *  Raw X.509 certificates (.cer, .der, .crt)
+ *  PKCS#12 certificates
+ *  PKCS#12 encrypted private keys
+ *
+ * The raw format contains exactly one certificate, PEM and PKCS#12 files
+ * can contain any combination of certificates and private keys.
+ *
+ * The password must have been validated as UTF-8 (use l_utf8_validate)
+ * unless the caller knows that no PKCS#12-defined encryption algorithm
+ * or MAC is used.
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
+	bool error =3D true;
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
+		int err;
+
+		err =3D cert_try_load_der_format(file.data, file.st.st_size,
+						password, out_certchain,
+						out_privkey, out_encrypted);
+		if (!err) {
+			error =3D false;
+			goto close;
+		}
+
+		if (err !=3D -ENOMSG)
+			goto close;
+
+		/* Try PEM */
+	}
+
+	/*
+	 * RFC 7486 allows whitespace and possibly other data before the
+	 * PEM "encapsulation boundary" so rather than check if the start
+	 * of the data looks like PEM, we fall back to this format if the
+	 * data didn't look like anything else we knew about.
+	 */
+	if (cert_try_load_pem_format((const char *) file.data, file.st.st_size,
+					password, out_certchain, out_privkey,
+					out_encrypted))
+		error =3D false;
+
+close:
+	pem_file_close(&file);
+	return !error;
+}
-- =

2.27.0

--===============8735283711023209468==--

