Content-Type: multipart/mixed; boundary="===============7514726133105813813=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 07/17] Add cert.{c,h} for basic X509 certificate operations.
Date: Fri, 24 Jul 2015 05:26:48 +0200
Message-ID: <1437708410-28075-7-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1437708410-28075-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7514726133105813813==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Loading, extracting specific information pieces (those used by TLS)
and cryptographic verification functions are implemented.  Only RSA-based
PKCS#1 digital signatures are supported.
---
 Makefile.am        |   5 +-
 ell/cert-private.h |  25 +++
 ell/cert.c         | 618 +++++++++++++++++++++++++++++++++++++++++++++++++=
++++
 ell/cert.h         |  64 ++++++
 ell/ell.h          |   1 +
 5 files changed, 712 insertions(+), 1 deletion(-)
 create mode 100644 ell/cert-private.h
 create mode 100644 ell/cert.c
 create mode 100644 ell/cert.h

diff --git a/Makefile.am b/Makefile.am
index aab2f9e..576641f 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -36,7 +36,8 @@ pkginclude_HEADERS =3D ell/ell.h \
 			ell/hwdb.h \
 			ell/cipher.h \
 			ell/random.h \
-			ell/uintset.h
+			ell/uintset.h \
+			ell/cert.h
 =

 lib_LTLIBRARIES =3D ell/libell.la
 =

@@ -77,6 +78,8 @@ ell_libell_la_SOURCES =3D $(linux_headers) \
 			ell/random.c \
 			ell/uintset.c \
 			ell/asn1-private.h \
+			ell/cert-private.h \
+			ell/cert.c \
 			ell/rsa-private.h \
 			ell/rsa.c
 =

diff --git a/ell/cert-private.h b/ell/cert-private.h
new file mode 100644
index 0000000..e0e65e4
--- /dev/null
+++ b/ell/cert-private.h
@@ -0,0 +1,25 @@
+/*
+ *
+ *  Embedded Linux library
+ *
+ *  Copyright (C) 2011-2014  Intel Corporation. All rights reserved.
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
+void pkcs1_write_digest_info(enum l_checksum_type type,
+				uint8_t *out, size_t *out_len,
+				const uint8_t *hash, size_t hash_len);
diff --git a/ell/cert.c b/ell/cert.c
new file mode 100644
index 0000000..ff9bf66
--- /dev/null
+++ b/ell/cert.c
@@ -0,0 +1,618 @@
+/*
+ *  Embedded Linux library
+ *
+ *  Copyright (C) 2015  Intel Corporation. All rights reserved.
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
+ */
+
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif
+
+#define _GNU_SOURCE
+#include <sys/types.h>
+#include <sys/stat.h>
+#include <fcntl.h>
+#include <unistd.h>
+#include <sys/mman.h>
+
+#include "util.h"
+#include "private.h"
+#include "cipher.h"
+#include "checksum.h"
+#include "cert-private.h"
+#include "cert.h"
+#include "asn1-private.h"
+#include "rsa-private.h"
+
+#define PEM_CERT_START		"-----BEGIN CERTIFICATE-----"
+#define PEM_CERT_END		"-----END CERTIFICATE-----"
+
+/* PKCS#1 key headers (default in OpenSSL 1.0.1+) */
+/* TODO: also support PKCS#8 keys (OpenSSL <=3D 0.9.8 default) */
+#define PEM_PRIVKEY_START	"-----BEGIN PRIVATE KEY-----"
+#define PEM_PRIVKEY_END		"-----END PRIVATE KEY-----"
+
+#define PEM_RSA_PRIVKEY_START	"-----BEGIN RSA PRIVATE KEY-----"
+#define PEM_RSA_PRIVKEY_END	"-----END RSA PRIVATE KEY-----"
+
+#define PEM_ENC_PRIVKEY_START	"-----BEGIN ENCRYPTED PRIVATE KEY-----"
+#define PEM_ENC_PRIVKEY_END	"-----END ENCRYPTED PRIVATE KEY-----"
+
+static size_t pem_decode(const uint8_t *buf, size_t size, uint8_t *out)
+{
+	const uint8_t *ptr;
+	int offset =3D 0;
+	uint16_t reg =3D 0;
+	char *end_marker;
+	int end_marker_len;
+
+	if (!memcmp(buf, PEM_CERT_START, strlen(PEM_CERT_START))) {
+		end_marker =3D PEM_CERT_END;
+		end_marker_len =3D strlen(PEM_CERT_END);
+
+		buf +=3D strlen(PEM_CERT_START);
+		size -=3D strlen(PEM_CERT_START);
+	} else if (!memcmp(buf, PEM_PRIVKEY_START, strlen(PEM_PRIVKEY_START))) {
+		end_marker =3D PEM_PRIVKEY_END;
+		end_marker_len =3D strlen(PEM_PRIVKEY_END);
+
+		buf +=3D strlen(PEM_PRIVKEY_START);
+		size -=3D strlen(PEM_PRIVKEY_START);
+	} else if (!memcmp(buf, PEM_ENC_PRIVKEY_START,
+				strlen(PEM_ENC_PRIVKEY_START))) {
+		end_marker =3D PEM_ENC_PRIVKEY_END;
+		end_marker_len =3D strlen(PEM_ENC_PRIVKEY_END);
+
+		buf +=3D strlen(PEM_ENC_PRIVKEY_START);
+		size -=3D strlen(PEM_ENC_PRIVKEY_START);
+	} else if (!memcmp(buf, PEM_RSA_PRIVKEY_START,
+				strlen(PEM_RSA_PRIVKEY_START))) {
+		end_marker =3D PEM_RSA_PRIVKEY_END;
+		end_marker_len =3D strlen(PEM_RSA_PRIVKEY_END);
+
+		buf +=3D strlen(PEM_RSA_PRIVKEY_START);
+		size -=3D strlen(PEM_RSA_PRIVKEY_START);
+	} else
+		return 0;
+
+	/* Base64-decode everything up to a PEM_CERT_END */
+
+	for (ptr =3D buf; ptr < buf + size; ptr++)
+		if (*ptr =3D=3D ' ' || *ptr =3D=3D '\t' || *ptr =3D=3D '\r' || *ptr =3D=
=3D '\n')
+			/* Whitespace */
+			continue;
+		else if (*ptr =3D=3D end_marker[0] &&
+				ptr + end_marker_len <=3D buf + size &&
+				!memcmp(ptr, end_marker, end_marker_len))
+			/* PEM end marker */
+			break;
+		else if (*ptr =3D=3D '=3D')
+			/* Final padding */
+			break;
+		else if ((*ptr >=3D 'A' && *ptr <=3D 'Z') ||
+				(*ptr >=3D 'a' && *ptr <=3D 'z') ||
+				(*ptr >=3D '0' && *ptr <=3D '9') ||
+				*ptr =3D=3D '+' || *ptr =3D=3D '/') {
+			/* Base64 character */
+
+			if (out) {
+				reg <<=3D 6;
+				if (*ptr >=3D 'A' && *ptr <=3D 'Z')
+					reg |=3D *ptr - 'A' + 0;
+				else if (*ptr >=3D 'a' && *ptr <=3D 'z')
+					reg |=3D *ptr - 'a' + 26;
+				else if (*ptr >=3D '0' && *ptr <=3D '9')
+					reg |=3D *ptr - '0' + 52;
+				else if (*ptr =3D=3D '+')
+					reg |=3D 62;
+				else if (*ptr =3D=3D '/')
+					reg |=3D 63;
+
+				if ((offset & 3) =3D=3D 1)
+					*out++ =3D reg >> 4;
+				else if ((offset & 3) =3D=3D 2)
+					*out++ =3D reg >> 2;
+				else if ((offset & 3) =3D=3D 3)
+					*out++ =3D reg >> 0;
+			}
+
+			offset++;
+		} else
+			/* Bad character */
+			return 0;
+
+	if (offset & 3)
+		if ((offset & 3) =3D=3D 1 || ptr =3D=3D buf + size || *ptr !=3D '=3D')
+			/* Uneven number of bytes and no padding */
+			return 0;
+
+	return offset * 3 / 4;
+}
+
+LIB_EXPORT struct l_cert *l_cert_decode(const uint8_t *buf, size_t size)
+{
+	struct l_cert *cert;
+	size_t der_size;
+
+	/*
+	 * Only check if certificate body starts with a PEM begin line,
+	 * if so decode it as PEM (base64) otherwise assume it's in DER
+	 * format already.
+	 */
+	if (size > strlen(PEM_CERT_START) + strlen(PEM_CERT_END) &&
+			!memcmp(buf, PEM_CERT_START, strlen(PEM_CERT_START))) {
+		/* Find the size of the decoded DER body */
+		der_size =3D pem_decode(buf, size, NULL);
+		if (!der_size)
+			return NULL;
+
+		cert =3D l_malloc(sizeof(*cert) + der_size);
+		cert->size =3D der_size;
+		cert->asn1 =3D (void *) cert + sizeof(*cert);
+		cert->issuer =3D NULL;
+
+		pem_decode(buf, size, cert->asn1);
+
+		goto check;
+	}
+
+	cert =3D l_malloc(sizeof(*cert) + size);
+	cert->size =3D size;
+	cert->asn1 =3D (void *) cert + sizeof(*cert);
+	cert->issuer =3D NULL;
+
+	memcpy(cert->asn1, buf, size);
+
+check:
+	if (!cert->size || cert->asn1[0] !=3D ASN1_ID_SEQUENCE) {
+		l_free(cert);
+		cert =3D NULL;
+	}
+
+	return cert;
+}
+
+LIB_EXPORT struct l_cert *l_cert_load_file(const char *filename)
+{
+	int fd;
+	struct stat st;
+	uint8_t *data;
+	struct l_cert *cert;
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
+	cert =3D l_cert_decode(data, st.st_size);
+
+	munmap(data, st.st_size);
+	close(fd);
+
+	return cert;
+}
+
+LIB_EXPORT bool l_cert_find_certchain(struct l_cert *cert,
+					const char *cacert_filename)
+{
+	/*
+	 * TODO: Load the CA certificate and find a chain from cert up to
+	 * that CA certificate, store that entire chain in a linked list using
+	 * the .issuer fields in each certificate.  We might also want to
+	 * accept a directory of trusted CA certs (/etc/ssl/certs by default)
+	 * and find a chain to any of those CAs.
+	 *
+	 * This is unimplemented which means that only certificates issued
+	 * directly by given root CA will work as they're already complete
+	 * certchains.
+	 */
+
+	return true;
+}
+
+struct asn1_oid {
+	uint8_t asn1_len;
+	uint8_t asn1[10];
+};
+
+static const struct pkcs1_encryption_oid {
+	enum l_cert_key_type key_type;
+	struct asn1_oid oid;
+} pkcs1_encryption_oids[] =3D {
+	{ /* rsaEncryption */
+		L_CERT_KEY_RSA,
+		{ 9, { 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01, 0x01 } },
+	},
+};
+
+static const struct rsadsi_encryption_algorithm_oid {
+	enum l_cipher_type cipher_type;
+	struct asn1_oid oid;
+} rsadsi_encryption_algorithm_oids[] =3D {
+	{ /* des-EDE3-CBC */
+		L_CIPHER_DES3_EDE_CBC,
+		{ 8, { 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x03, 0x07 } },
+	},
+};
+
+static const struct pkcs1_signature_algorithm_oid {
+	enum l_checksum_type hash_type;
+	int hash_len;
+	enum l_cert_key_type key_type;
+	struct asn1_oid oid;
+} pkcs1_signature_algorithm_oids[] =3D {
+	{ /* md5WithRSAEncryption */
+		L_CHECKSUM_MD5, 16,
+		L_CERT_KEY_RSA,
+		{ 9, { 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01, 0x04 } },
+	},
+	{ /* sha1WithRSAEncryption */
+		L_CHECKSUM_SHA1, 20,
+		L_CERT_KEY_RSA,
+		{ 9, { 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01, 0x05 } },
+	},
+	{ /* sha256WithRSAEncryption */
+		L_CHECKSUM_SHA256, 32,
+		L_CERT_KEY_RSA,
+		{ 9, { 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01, 0x0b } },
+	},
+	{ /* sha384WithRSAEncryption */
+		L_CHECKSUM_SHA384, 48,
+		L_CERT_KEY_RSA,
+		{ 9, { 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01, 0x0c } },
+	},
+	{ /* sha512WithRSAEncryption */
+		L_CHECKSUM_SHA512, 64,
+		L_CERT_KEY_RSA,
+		{ 9, { 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01, 0x0d } },
+	},
+};
+
+static bool verify_single(struct l_cert *cert, struct l_cert *cacert)
+{
+	uint8_t *issuer, *ca_subject;
+	int issuer_len, ca_subject_len;
+	uint8_t *sig_type1, *sig_type2;
+	int i, ca_key_len;
+	size_t len1, len2;
+	uint8_t *certificate, *start, *ca_pubkey, *signature;
+	struct l_checksum *checksum;
+	struct l_rsa *rsa;
+	uint8_t hash[64];
+	bool result;
+	uint8_t digest_info[128], expected[128];
+	size_t digest_info_len;
+
+	/* First make sure the certificate claims to be issued by the CA */
+
+	issuer =3D l_cert_find_dn(cert, true, &issuer_len);
+	ca_subject =3D l_cert_find_dn(cacert, false, &ca_subject_len);
+
+	if (!issuer || !ca_subject || issuer_len !=3D ca_subject_len ||
+			memcmp(issuer, ca_subject, issuer_len))
+		return false;
+
+	/* Find out the signature type */
+
+	sig_type1 =3D der_find_elem_by_path(cert->asn1, cert->size, ASN1_ID_OID,
+						&len1, 0, 0, 2, 0, -1);
+	if (!sig_type1)
+		return false;
+
+	for (i =3D 0; i < (int) L_ARRAY_SIZE(pkcs1_signature_algorithm_oids); i++)
+		if (len1 =3D=3D pkcs1_signature_algorithm_oids[i].oid.asn1_len &&
+				!memcmp(sig_type1,
+					pkcs1_signature_algorithm_oids[i].oid.
+					asn1, len1))
+			break;
+	if (i =3D=3D L_ARRAY_SIZE(pkcs1_signature_algorithm_oids))
+		return false;
+
+	/*
+	 * Check if the signature AlgorithmIdentifier in TBSCertificate is
+	 * identical with the signatureAlgorithm in Certificate, and if
+	 * it's consistent with the public key type in the CA certificate.
+	 */
+	sig_type2 =3D der_find_elem_by_path(cert->asn1, cert->size, ASN1_ID_OID,
+						&len2, 0, 1, 0, -1);
+	if (!sig_type2 || len1 !=3D len2 || memcmp(sig_type1, sig_type2, len1))
+		return false;
+
+	if (pkcs1_signature_algorithm_oids[i].key_type !=3D
+			l_cert_get_pubkey_type(cacert))
+		return false;
+
+	/* Compute the hash of the TBSCertificate part */
+
+	start =3D der_find_elem_by_path(cert->asn1, cert->size, ASN1_ID_SEQUENCE,
+					&len1, 0, -1);
+	certificate =3D der_find_elem_by_path(start, len1, ASN1_ID_SEQUENCE,
+						&len1, 0, -1);
+
+	checksum =3D l_checksum_new(pkcs1_signature_algorithm_oids[i].hash_type);
+	if (!checksum)
+		return false;
+
+	/* Hash the entire SEQUENCE TLV including the T and the L */
+	l_checksum_update(checksum, start, certificate + len1 - start);
+	l_checksum_get_digest(checksum, hash,
+				pkcs1_signature_algorithm_oids[i].hash_len);
+
+	l_checksum_free(checksum);
+
+	pkcs1_write_digest_info(pkcs1_signature_algorithm_oids[i].hash_type,
+				digest_info, &digest_info_len, hash,
+				pkcs1_signature_algorithm_oids[i].hash_len);
+
+	/* Verify the signature against the hash using the CA's public key */
+
+	ca_pubkey =3D l_cert_find_pubkey(cacert, &ca_key_len);
+	if (!ca_pubkey)
+		return false;
+
+	signature =3D der_find_elem_by_path(cert->asn1, cert->size,
+						ASN1_ID_BIT_STRING, &len1,
+						0, 2, -1);
+	if (!signature || len1 < 10)
+		return false;
+
+	/* Skip the BIT STRING metadata byte */
+	signature +=3D 1;
+	len1 -=3D 1;
+
+	rsa =3D l_rsa_pkcs1_v1_5_new(ca_pubkey, ca_key_len);
+	if (!rsa)
+		return false;
+
+	result =3D l_rsa_verify(rsa, signature, expected, len1, digest_info_len);
+
+	l_rsa_free(rsa);
+
+	if (!result || memcmp(digest_info, expected, digest_info_len))
+		return false;
+
+	/*
+	 * A CRL / OCSP check would go here.  Other checks we should have:
+	 * start & expiration date, unknown X509v3 extensions, CA:TRUE
+	 * presence in the CA cert.
+	 */
+
+	return true;
+}
+
+/*
+ * Verify a certificate chain internal consistency and optionally against
+ * a CA certificate if not NULL.
+ */
+LIB_EXPORT bool l_cert_verify_certchain(struct l_cert *certchain,
+					struct l_cert *ca_cert)
+{
+	while (certchain) {
+		/*
+		 * Every certificate except the last in the chain (which may
+		 * be the root CA or not) must be trusted by its issuer.
+		 */
+		if (certchain->issuer)
+			if (!verify_single(certchain, certchain->issuer))
+				return false;
+
+		/*
+		 * At least one certificate in the chain must be trusted by
+		 * our CA if known.
+		 */
+		if (ca_cert)
+			if (verify_single(certchain, ca_cert))
+				ca_cert =3D NULL;
+
+		certchain =3D certchain->issuer;
+	}
+
+	return !ca_cert;
+}
+
+LIB_EXPORT void l_cert_free_certchain(struct l_cert *cert)
+{
+	struct l_cert *next;
+
+	while (cert) {
+		next =3D cert->issuer;
+		l_free(cert);
+		cert =3D next;
+	}
+}
+
+LIB_EXPORT uint8_t *l_cert_find_dn(struct l_cert *cert, bool issuer,
+					int *name_len)
+{
+	uint8_t *name;
+	size_t len;
+
+	name =3D der_find_elem_by_path(cert->asn1, cert->size, ASN1_ID_SEQUENCE,
+			&len, 0, 0, issuer ? 3 : 5, -1);
+	if (name)
+		*name_len =3D len;
+
+	return name;
+}
+
+static bool der_oid_match(uint8_t *seq, size_t seq_len,
+				const struct asn1_oid *oid)
+{
+	uint8_t *ptr, tag;
+	size_t oid_len;
+
+	ptr =3D der_find_elem(seq, seq_len, 0, &tag, &oid_len);
+
+	return ptr && tag =3D=3D ASN1_ID_OID && oid_len =3D=3D oid->asn1_len &&
+		!memcmp(oid->asn1, ptr, oid_len);
+}
+
+static const struct asn1_oid dn_organization_name_oid =3D { 3,
+	{ 0x55, 0x04, 0x0a } };
+static const struct asn1_oid dn_common_name_oid =3D { 3,
+	{ 0x55, 0x04, 0x03 } };
+
+LIB_EXPORT uint8_t *l_cert_dn_find_printable_name(uint8_t *dn, int dn_len,
+							int *printable_name_len)
+{
+	uint8_t *end =3D dn + dn_len;
+	uint8_t *set, *seq, *name =3D NULL, tag, name_tag;
+	size_t len, name_len;
+
+	while (dn < end) {
+		set =3D der_find_elem(dn, end - dn, 0, &tag, &len);
+		if (!set)
+			break;
+
+		dn =3D set + len;
+		if (tag !=3D ASN1_ID_SET)
+			continue;
+
+		/* TODO: iterate over the set? */
+		seq =3D der_find_elem(set, len, 0, &tag, &len);
+		if (!seq || tag !=3D ASN1_ID_SEQUENCE)
+			continue;
+
+		if (der_oid_match(seq, len, &dn_organization_name_oid)) {
+			/*
+			 * This our first priority so override any name found
+			 * so far.
+			 */
+			name =3D der_find_elem(seq, len, 1, &name_tag, &name_len);
+			break;
+		} else if (der_oid_match(seq, len, &dn_common_name_oid) &&
+				!name)
+			name =3D der_find_elem(seq, len, 1, &name_tag, &name_len);
+	}
+
+	if (!name || (name_tag !=3D ASN1_ID_PRINTABLESTRING &&
+				name_tag !=3D ASN1_ID_UTF8STRING))
+		return NULL;
+
+	*printable_name_len =3D name_len;
+	return name;
+}
+
+LIB_EXPORT uint8_t *l_cert_find_pubkey(struct l_cert *cert, int *pubkey_le=
n)
+{
+	uint8_t *key;
+	size_t len;
+
+	key =3D der_find_elem_by_path(cert->asn1, cert->size, ASN1_ID_BIT_STRING,
+			&len, 0, 0, 6, 1, -1);
+	if (!key || len < 10)
+		return NULL;
+
+	/* Skip the BIT STRING metadata byte */
+	key +=3D 1;
+	len -=3D 1;
+
+	*pubkey_len =3D len;
+	return key;
+}
+
+LIB_EXPORT enum l_cert_key_type l_cert_get_pubkey_type(struct l_cert *cert)
+{
+	uint8_t *key_type;
+	size_t key_type_len;
+	int i;
+
+	key_type =3D der_find_elem_by_path(cert->asn1, cert->size, ASN1_ID_OID,
+			&key_type_len, 0, 0, 6, 0, 0, -1);
+	if (!key_type)
+		return L_CERT_KEY_UNKNOWN;
+
+	for (i =3D 0; i < (int) L_ARRAY_SIZE(pkcs1_encryption_oids); i++)
+		if (key_type_len =3D=3D pkcs1_encryption_oids[i].oid.asn1_len &&
+				!memcmp(key_type,
+					pkcs1_encryption_oids[i].oid.asn1,
+					key_type_len))
+			break;
+	if (i =3D=3D L_ARRAY_SIZE(pkcs1_encryption_oids))
+		return L_CERT_KEY_UNKNOWN;
+
+	return pkcs1_encryption_oids[i].key_type;
+}
+
+static const uint8_t pkcs1_digest_info_md5_start[] =3D {
+	0x30, 0x20, 0x30, 0x0c, 0x06, 0x08, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d,
+	0x02, 0x05, 0x05, 0x00, 0x04, 0x10,
+};
+static const uint8_t pkcs1_digest_info_sha1_start[] =3D {
+	0x30, 0x21, 0x30, 0x09, 0x06, 0x05, 0x2b, 0x0e, 0x03, 0x02, 0x1a, 0x05,
+	0x00, 0x04, 0x14,
+};
+static const uint8_t pkcs1_digest_info_sha256_start[] =3D {
+	0x30, 0x31, 0x30, 0x0d, 0x06, 0x09, 0x60, 0x86, 0x48, 0x01, 0x65, 0x03,
+	0x04, 0x02, 0x01, 0x05, 0x00, 0x04, 0x20,
+};
+static const uint8_t pkcs1_digest_info_sha384_start[] =3D {
+	0x30, 0x41, 0x30, 0x0d, 0x06, 0x09, 0x60, 0x86, 0x48, 0x01, 0x65, 0x03,
+	0x04, 0x02, 0x02, 0x05, 0x00, 0x04, 0x30,
+};
+static const uint8_t pkcs1_digest_info_sha512_start[] =3D {
+	0x30, 0x51, 0x30, 0x0d, 0x06, 0x09, 0x60, 0x86, 0x48, 0x01, 0x65, 0x03,
+	0x04, 0x02, 0x03, 0x05, 0x00, 0x04, 0x40,
+};
+
+void pkcs1_write_digest_info(enum l_checksum_type type,
+				uint8_t *out, size_t *out_len,
+				const uint8_t *hash, size_t hash_len)
+{
+	switch (type) {
+	case L_CHECKSUM_MD5:
+		memcpy(out, pkcs1_digest_info_md5_start,
+				sizeof(pkcs1_digest_info_md5_start));
+		*out_len =3D sizeof(pkcs1_digest_info_md5_start);
+		break;
+	case L_CHECKSUM_SHA1:
+		memcpy(out, pkcs1_digest_info_sha1_start,
+				sizeof(pkcs1_digest_info_sha1_start));
+		*out_len =3D sizeof(pkcs1_digest_info_sha1_start);
+		break;
+	case L_CHECKSUM_SHA256:
+		memcpy(out, pkcs1_digest_info_sha256_start,
+				sizeof(pkcs1_digest_info_sha256_start));
+		*out_len =3D sizeof(pkcs1_digest_info_sha256_start);
+		break;
+	case L_CHECKSUM_SHA384:
+		memcpy(out, pkcs1_digest_info_sha384_start,
+				sizeof(pkcs1_digest_info_sha384_start));
+		*out_len =3D sizeof(pkcs1_digest_info_sha384_start);
+		break;
+	case L_CHECKSUM_SHA512:
+		memcpy(out, pkcs1_digest_info_sha512_start,
+				sizeof(pkcs1_digest_info_sha512_start));
+		*out_len =3D sizeof(pkcs1_digest_info_sha512_start);
+		break;
+	}
+
+	memcpy(out + *out_len, hash, hash_len);
+	*out_len +=3D hash_len;
+}
diff --git a/ell/cert.h b/ell/cert.h
new file mode 100644
index 0000000..bbea5eb
--- /dev/null
+++ b/ell/cert.h
@@ -0,0 +1,64 @@
+/*
+ *  Embedded Linux library
+ *
+ *  Copyright (C) 2015  Intel Corporation. All rights reserved.
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
+ */
+
+#ifndef __ELL_CERT_H
+#define __ELL_CERT_H
+
+#ifdef __cplusplus
+extern "C" {
+#endif
+
+struct l_cert {
+	size_t size;
+	uint8_t *asn1;
+	struct l_cert *issuer;
+};
+
+enum l_cert_key_type {
+	L_CERT_KEY_RSA,
+	L_CERT_KEY_UNKNOWN,
+};
+
+/* Certificate and certificate chain operations */
+
+struct l_cert *l_cert_decode(const uint8_t *buf, size_t size);
+
+struct l_cert *l_cert_load_file(const char *filename);
+
+bool l_cert_find_certchain(struct l_cert *cert, const char *cacert_filenam=
e);
+
+bool l_cert_verify_certchain(struct l_cert *certchain, struct l_cert *ca_c=
ert);
+
+void l_cert_free_certchain(struct l_cert *cert);
+
+uint8_t *l_cert_find_dn(struct l_cert *cert, bool issuer, int *name_len);
+
+uint8_t *l_cert_dn_find_printable_name(uint8_t *dn, int dn_len,
+					int *printable_name_len);
+
+uint8_t *l_cert_find_pubkey(struct l_cert *cert, int *pubkey_len);
+
+enum l_cert_key_type l_cert_get_pubkey_type(struct l_cert *cert);
+
+#ifdef __cplusplus
+}
+#endif
+
+#endif /* __ELL_CERT_H */
diff --git a/ell/ell.h b/ell/ell.h
index a5baf0d..2c88216 100644
--- a/ell/ell.h
+++ b/ell/ell.h
@@ -38,6 +38,7 @@
 #include <ell/cipher.h>
 #include <ell/random.h>
 #include <ell/uintset.h>
+#include <ell/cert.h>
 =

 #include <ell/netlink.h>
 #include <ell/genl.h>
-- =

2.1.4


--===============7514726133105813813==--

