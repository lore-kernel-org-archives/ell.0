Content-Type: multipart/mixed; boundary="===============3447233607121563854=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/7] cert: Add cert.c for certificate types and routines
Date: Mon, 19 Nov 2018 19:23:43 +0100
Message-ID: <20181119182348.4562-2-andrew.zaborowski@intel.com>
In-Reply-To: <20181119182348.4562-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3447233607121563854==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Create a new file for all the generic X.509 certificate utilities so far
living in tls.c and make l_cert and l_certchain public objects.  In this
patch we only add the contructors and destructors.  Since there's not
going to be any way to add a certificate to multiple certchains we add
the prev/next pointers for the doubly-linked list implementation
directly to the l_cert structure.  The private certchain constructor is
going to be used by pem file loaders in pem.c and in
tls_parse_certificate_list.
---
 Makefile.am        |   7 +-
 ell/cert-private.h |  24 ++++++
 ell/cert.c         | 199 +++++++++++++++++++++++++++++++++++++++++++++
 ell/cert.h         |  49 +++++++++++
 ell/ell.h          |   1 +
 ell/ell.sym        |   4 +
 6 files changed, 282 insertions(+), 2 deletions(-)
 create mode 100644 ell/cert-private.h
 create mode 100644 ell/cert.c
 create mode 100644 ell/cert.h

diff --git a/Makefile.am b/Makefile.am
index 0a8d0f6..d115360 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -48,7 +48,8 @@ pkginclude_HEADERS =3D ell/ell.h \
 			ell/file.h \
 			ell/dir.h \
 			ell/net.h \
-			ell/dhcp.h
+			ell/dhcp.h \
+			ell/cert.h
 =

 lib_LTLIBRARIES =3D ell/libell.la
 =

@@ -109,7 +110,9 @@ ell_libell_la_SOURCES =3D $(linux_headers) \
 			ell/dhcp-private.h \
 			ell/dhcp.c \
 			ell/dhcp-transport.c \
-			ell/dhcp-lease.c
+			ell/dhcp-lease.c \
+			ell/cert.c \
+			ell/cert-private.h
 =

 ell_libell_la_LDFLAGS =3D -no-undefined \
 			-Wl,--version-script=3D$(top_srcdir)/ell/ell.sym \
diff --git a/ell/cert-private.h b/ell/cert-private.h
new file mode 100644
index 0000000..f89e216
--- /dev/null
+++ b/ell/cert-private.h
@@ -0,0 +1,24 @@
+/*
+ *
+ *  Embedded Linux library
+ *
+ *  Copyright (C) 2018  Intel Corporation. All rights reserved.
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
+struct l_certchain *certchain_new_from_leaf(struct l_cert *leaf);
+void certchain_link_issuer(struct l_certchain *chain, struct l_cert *issue=
r);
diff --git a/ell/cert.c b/ell/cert.c
new file mode 100644
index 0000000..141362f
--- /dev/null
+++ b/ell/cert.c
@@ -0,0 +1,199 @@
+/*
+ *  Embedded Linux library
+ *
+ *  Copyright (C) 2018  Intel Corporation. All rights reserved.
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
+#include <string.h>
+
+#include "private.h"
+#include "key.h"
+#include "asn1-private.h"
+#include "cert.h"
+#include "cert-private.h"
+
+#define X509_CERTIFICATE_POS			0
+#define   X509_TBSCERTIFICATE_POS		  0
+#define     X509_TBSCERT_VERSION_POS		    0
+#define     X509_TBSCERT_SERIAL_POS		    1
+#define     X509_TBSCERT_SIGNATURE_POS		    2
+#define       X509_ALGORITHM_ID_ALGORITHM_POS	      0
+#define       X509_ALGORITHM_ID_PARAMS_POS	      1
+#define     X509_TBSCERT_ISSUER_DN_POS		    3
+#define     X509_TBSCERT_VALIDITY_POS		    4
+#define     X509_TBSCERT_SUBJECT_DN_POS		    5
+#define     X509_TBSCERT_SUBJECT_KEY_POS	    6
+#define       X509_SUBJECT_KEY_ALGORITHM_POS	      0
+#define       X509_SUBJECT_KEY_VALUE_POS	      1
+#define     X509_TBSCERT_ISSUER_UID_POS		    7
+#define     X509_TBSCERT_SUBJECT_UID_POS	    8
+#define     X509_TBSCERT_EXTENSIONS_POS		    9
+#define   X509_SIGNATURE_ALGORITHM_POS		  1
+#define   X509_SIGNATURE_VALUE_POS		  2
+
+struct l_cert {
+	enum l_cert_key_type pubkey_type;
+	struct l_cert *issuer;
+	struct l_cert *issued;
+	size_t asn1_len;
+	uint8_t asn1[0];
+};
+
+struct l_certchain {
+	struct l_cert *leaf;	/* Bottom of the doubly-linked list */
+	struct l_cert *ca;	/* Top of the doubly-linked list */
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
+static bool cert_set_pubkey_type(struct l_cert *cert)
+{
+	const uint8_t *key_type;
+	size_t key_type_len;
+	int i;
+
+	key_type =3D asn1_der_find_elem_by_path(cert->asn1, cert->asn1_len,
+						ASN1_ID_OID, &key_type_len,
+						X509_CERTIFICATE_POS,
+						X509_TBSCERTIFICATE_POS,
+						X509_TBSCERT_SUBJECT_KEY_POS,
+						X509_SUBJECT_KEY_ALGORITHM_POS,
+						X509_ALGORITHM_ID_ALGORITHM_POS,
+						-1);
+	if (!key_type)
+		return false;
+
+	for (i =3D 0; i < (int) L_ARRAY_SIZE(pkcs1_encryption_oids); i++)
+		if (asn1_oid_eq(&pkcs1_encryption_oids[i].oid,
+					key_type_len, key_type))
+			break;
+
+	if (i =3D=3D L_ARRAY_SIZE(pkcs1_encryption_oids))
+		cert->pubkey_type =3D L_CERT_KEY_UNKNOWN;
+	else
+		cert->pubkey_type =3D pkcs1_encryption_oids[i].key_type;
+
+	return true;
+}
+
+LIB_EXPORT struct l_cert *l_cert_new_from_der(const uint8_t *buf,
+						size_t buf_len)
+{
+	const uint8_t *seq =3D buf;
+	size_t seq_len =3D buf_len;
+	size_t content_len;
+	struct l_cert *cert;
+
+	/* Sanity check: outer element is a SEQUENCE */
+	if (seq_len-- < 1 || *seq++ !=3D ASN1_ID_SEQUENCE)
+		return NULL;
+
+	/* Sanity check: the SEQUENCE spans the whole buffer */
+	content_len =3D asn1_parse_definite_length(&seq, &seq_len);
+	if (content_len < 64 || content_len !=3D seq_len)
+		return NULL;
+
+	/*
+	 * We could require the signature algorithm and the key algorithm
+	 * to be one of our supported types here but instead we only
+	 * require that when the user wants to verify this certificate or
+	 * get the public key respectively.
+	 */
+
+	cert =3D l_malloc(sizeof(struct l_cert) + buf_len);
+	cert->issuer =3D NULL;
+	cert->issued =3D NULL;
+	cert->asn1_len =3D buf_len;
+	memcpy(cert->asn1, buf, buf_len);
+
+	/* Sanity check: structure is correct up to the Public Key Algorithm */
+	if (!cert_set_pubkey_type(cert)) {
+		l_free(cert);
+		return NULL;
+	}
+
+	return cert;
+}
+
+LIB_EXPORT void l_cert_free(struct l_cert *cert)
+{
+	l_free(cert);
+}
+
+/*
+ * Note: takes ownership of the certificate.  The certificate is
+ * assumed to be new and not linked into any certchain object.
+ */
+struct l_certchain *certchain_new_from_leaf(struct l_cert *leaf)
+{
+	struct l_certchain *chain;
+
+	chain =3D l_new(struct l_certchain, 1);
+	chain->leaf =3D leaf;
+	chain->ca =3D leaf;
+	return chain;
+}
+
+/*
+ * Note: takes ownership of the certificate.  The certificate is
+ * assumed to be new and not linked into any certchain object.
+ */
+void certchain_link_issuer(struct l_certchain *chain, struct l_cert *ca)
+{
+	ca->issued =3D chain->ca;
+	chain->ca->issuer =3D ca;
+	chain->ca =3D ca;
+}
+
+static struct l_cert *certchain_pop_ca(struct l_certchain *chain)
+{
+	struct l_cert *ca =3D chain->ca;
+
+	if (!ca)
+		return NULL;
+
+	if (ca->issued) {
+		chain->ca =3D ca->issued;
+		ca->issued->issuer =3D NULL;
+		ca->issued =3D NULL;
+	} else {
+		chain->ca =3D NULL;
+		chain->leaf =3D NULL;
+	}
+
+	return ca;
+}
+
+LIB_EXPORT void l_certchain_free(struct l_certchain *chain)
+{
+	while (chain && chain->ca)
+		l_cert_free(certchain_pop_ca(chain));
+
+	l_free(chain);
+}
diff --git a/ell/cert.h b/ell/cert.h
new file mode 100644
index 0000000..aafc0a9
--- /dev/null
+++ b/ell/cert.h
@@ -0,0 +1,49 @@
+/*
+ *
+ *  Embedded Linux library
+ *
+ *  Copyright (C) 2018  Intel Corporation. All rights reserved.
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
+#ifndef __ELL_CERT_H
+#define __ELL_CERT_H
+
+#ifdef __cplusplus
+extern "C" {
+#endif
+
+#include <stddef.h>
+
+struct l_cert;
+struct l_certchain;
+
+enum l_cert_key_type {
+	L_CERT_KEY_RSA,
+	L_CERT_KEY_UNKNOWN,
+};
+
+struct l_cert *l_cert_new_from_der(const uint8_t *buf, size_t buf_len);
+void l_cert_free(struct l_cert *cert);
+
+void l_certchain_free(struct l_certchain *chain);
+
+#ifdef __cplusplus
+}
+#endif
+
+#endif /* __ELL_CERT_H */
diff --git a/ell/ell.h b/ell/ell.h
index ba1928d..4b0eac4 100644
--- a/ell/ell.h
+++ b/ell/ell.h
@@ -56,3 +56,4 @@
 #include <ell/dbus-service.h>
 #include <ell/dbus-client.h>
 #include <ell/dhcp.h>
+#include <ell/cert.h>
diff --git a/ell/ell.sym b/ell/ell.sym
index c21fb21..0e6f8a0 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -432,6 +432,10 @@ global:
 	l_uuid_is_valid;
 	l_uuid_get_version;
 	l_uuid_to_string;
+	/* cert */
+	l_cert_new_from_der;
+	l_cert_free;
+	l_certchain_free;
 local:
 	*;
 };
-- =

2.19.1


--===============3447233607121563854==--

