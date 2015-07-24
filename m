Content-Type: multipart/mixed; boundary="===============8478271577115595411=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 08/17] cert: Add RSA private key utilities.
Date: Fri, 24 Jul 2015 05:26:49 +0200
Message-ID: <1437708410-28075-8-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1437708410-28075-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8478271577115595411==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/cert.c | 164 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++=
++++
 ell/cert.h |  10 ++++
 2 files changed, 174 insertions(+)

diff --git a/ell/cert.c b/ell/cert.c
index ff9bf66..9c257de 100644
--- a/ell/cert.c
+++ b/ell/cert.c
@@ -560,6 +560,170 @@ LIB_EXPORT enum l_cert_key_type l_cert_get_pubkey_typ=
e(struct l_cert *cert)
 	return pkcs1_encryption_oids[i].key_type;
 }
 =

+static uint8_t *l_cert_decode_key(const uint8_t *buf_in, size_t size_in,
+					size_t *size_out,
+					const char *passphrase, bool *encrypted)
+{
+	uint8_t *bin;
+	size_t bin_size;
+
+	if (size_in > strlen(PEM_ENC_PRIVKEY_START) +
+			strlen(PEM_ENC_PRIVKEY_END) &&
+			!memcmp(buf_in, PEM_ENC_PRIVKEY_START,
+				strlen(PEM_ENC_PRIVKEY_START))) {
+		*encrypted =3D true;
+
+		if (!passphrase)
+			return NULL;
+	} else if (size_in > strlen(PEM_PRIVKEY_START) +
+			strlen(PEM_PRIVKEY_END) &&
+			!memcmp(buf_in, PEM_PRIVKEY_START,
+				strlen(PEM_PRIVKEY_START))) {
+		*encrypted =3D false;
+	} else if (size_in > strlen(PEM_RSA_PRIVKEY_START) +
+			strlen(PEM_RSA_PRIVKEY_END) &&
+			!memcmp(buf_in, PEM_RSA_PRIVKEY_START,
+				strlen(PEM_RSA_PRIVKEY_START))) {
+		*encrypted =3D false;
+	} else {
+		*encrypted =3D false;
+
+		return NULL;
+	}
+
+	/* Find the size of the decoded DER body */
+	bin_size =3D pem_decode(buf_in, size_in, NULL);
+	if (!bin_size)
+		return NULL;
+
+	bin =3D l_malloc(bin_size);
+	pem_decode(buf_in, size_in, bin);
+
+	if (!*encrypted) {
+		*size_out =3D bin_size;
+		return bin;
+	}
+
+	/*
+	 * If encrypted we need to parse the AlgorithmIdentifier and its
+	 * parameters, the key derivation function, its parameters, etc (TODO).
+	 */
+	l_cert_free_key(bin, bin_size);
+
+	return NULL;
+}
+
+LIB_EXPORT uint8_t *l_cert_load_key_file(const char *filename,
+						const char *passphrase,
+						size_t *len,
+						bool *encrypted)
+{
+	int fd;
+	struct stat st;
+	uint8_t *data;
+	uint8_t *key;
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
+	key =3D l_cert_decode_key(data, st.st_size, len, passphrase, encrypted);
+
+	munmap(data, st.st_size);
+	close(fd);
+
+	return key;
+}
+
+LIB_EXPORT void l_cert_free_key(uint8_t *key, size_t len)
+{
+	if (key) {
+		memset(key, 0, len);
+		l_free(key);
+	}
+}
+
+/*
+ * Extract a ASN1 RsaKey-formatted public+private key structure in the
+ * form used in the kernel.  It is simpler than the PKCS#1 form as it only
+ * contains the N, E and D integers and also correctly parses as a PKCS#1
+ * RSAPublicKey.
+ */
+LIB_EXPORT uint8_t *l_cert_extract_rsakey(uint8_t *pkcs1_key,
+						size_t pkcs1_key_len,
+						size_t *out_len)
+{
+	uint8_t *key, *ptr, *ver, *n, *e, *d;
+	uint8_t tag;
+	size_t ver_len, n_len, e_len, d_len;
+	int pos;
+
+	/* Unpack the outer SEQUENCE */
+	pkcs1_key =3D der_find_elem(pkcs1_key, pkcs1_key_len, 0, &tag,
+					&pkcs1_key_len);
+	if (!pkcs1_key || tag !=3D ASN1_ID_SEQUENCE)
+		return NULL;
+
+	/* Check if the version element if present */
+	ver =3D der_find_elem(pkcs1_key, pkcs1_key_len, 0, &tag, &ver_len);
+	if (!ver || tag !=3D ASN1_ID_INTEGER)
+		return NULL;
+
+	pos =3D (ver_len =3D=3D 1 && ver[0] =3D=3D 0x00) ? 1 : 0;
+
+	n =3D der_find_elem(pkcs1_key, pkcs1_key_len, pos + 0, &tag, &n_len);
+	if (!n || tag !=3D ASN1_ID_INTEGER)
+		return NULL;
+
+	e =3D der_find_elem(pkcs1_key, pkcs1_key_len, pos + 1, &tag, &e_len);
+	if (!e || tag !=3D ASN1_ID_INTEGER)
+		return NULL;
+
+	d =3D der_find_elem(pkcs1_key, pkcs1_key_len, pos + 2, &tag, &d_len);
+	if (!d || tag !=3D ASN1_ID_INTEGER)
+		return NULL;
+
+	/* New SEQUENCE length including tags and lengths */
+	*out_len =3D 1 + (n_len >=3D 0x80 ? n_len >=3D 0x100 ? 3 : 2 : 1) + n_len=
 +
+		1 + (e_len >=3D 0x80 ? e_len >=3D 0x100 ? 3 : 2 : 1) + e_len +
+		1 + (d_len >=3D 0x80 ? d_len >=3D 0x100 ? 3 : 2 : 1) + d_len;
+	ptr =3D key =3D l_malloc(*out_len);
+
+	*ptr++ =3D ASN1_ID_SEQUENCE;
+	write_asn1_definite_length(&ptr, *out_len);
+
+	*ptr++ =3D ASN1_ID_INTEGER;
+	write_asn1_definite_length(&ptr, n_len);
+	memcpy(ptr, n, n_len);
+	ptr +=3D n_len;
+
+	*ptr++ =3D ASN1_ID_INTEGER;
+	write_asn1_definite_length(&ptr, e_len);
+	memcpy(ptr, e, e_len);
+	ptr +=3D e_len;
+
+	*ptr++ =3D ASN1_ID_INTEGER;
+	write_asn1_definite_length(&ptr, d_len);
+	memcpy(ptr, d, d_len);
+	ptr +=3D d_len;
+
+	*out_len =3D ptr - key;
+	return key;
+}
+
 static const uint8_t pkcs1_digest_info_md5_start[] =3D {
 	0x30, 0x20, 0x30, 0x0c, 0x06, 0x08, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d,
 	0x02, 0x05, 0x05, 0x00, 0x04, 0x10,
diff --git a/ell/cert.h b/ell/cert.h
index bbea5eb..b4d8b57 100644
--- a/ell/cert.h
+++ b/ell/cert.h
@@ -57,6 +57,16 @@ uint8_t *l_cert_find_pubkey(struct l_cert *cert, int *pu=
bkey_len);
 =

 enum l_cert_key_type l_cert_get_pubkey_type(struct l_cert *cert);
 =

+/* Private keys */
+
+uint8_t *l_cert_load_key_file(const char *filename, const char *passphrase,
+				size_t *len, bool *encrypted);
+
+void l_cert_free_key(uint8_t *key, size_t len);
+
+uint8_t *l_cert_extract_rsakey(uint8_t *pkcs1_key, size_t pkcs1_key_len,
+				size_t *out_len);
+
 #ifdef __cplusplus
 }
 #endif
-- =

2.1.4


--===============8478271577115595411==--

