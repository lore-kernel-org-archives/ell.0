Content-Type: multipart/mixed; boundary="===============0987264403102441167=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/5] cert: Add cert.c for certificate types and routines
Date: Thu, 08 Nov 2018 13:06:47 +0100
Message-ID: <20181108120651.32521-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0987264403102441167==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Create a new file for all the generic X.509 certificate utilities so far
living in tls.c and make the l_cert type a public object.  There are
only minor changes from the tls.c code to add accessors, otherwise the
intention is not to make the code perfect and only move the existing
code so that for example pem.c can start returning l_cert objects
directly.
---
 Makefile.am |   6 +-
 ell/cert.c  | 306 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 ell/cert.h  |  57 ++++++++++
 ell/ell.h   |   1 +
 ell/ell.sym |   8 ++
 5 files changed, 376 insertions(+), 2 deletions(-)
 create mode 100644 ell/cert.c
 create mode 100644 ell/cert.h

diff --git a/Makefile.am b/Makefile.am
index 0a8d0f6..a67f0a5 100644
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

@@ -109,7 +110,8 @@ ell_libell_la_SOURCES =3D $(linux_headers) \
 			ell/dhcp-private.h \
 			ell/dhcp.c \
 			ell/dhcp-transport.c \
-			ell/dhcp-lease.c
+			ell/dhcp-lease.c \
+			ell/cert.c
 =

 ell_libell_la_LDFLAGS =3D -no-undefined \
 			-Wl,--version-script=3D$(top_srcdir)/ell/ell.sym \
diff --git a/ell/cert.c b/ell/cert.c
new file mode 100644
index 0000000..82ea005
--- /dev/null
+++ b/ell/cert.c
@@ -0,0 +1,306 @@
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
+	struct l_cert *issuer;
+	struct l_cert *issued;
+	enum l_cert_key_type pubkey_type;
+	size_t asn1_len;
+	uint8_t asn1[0];
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
+	while (cert) {
+		struct l_cert *next =3D cert->issuer;
+
+		l_free(cert);
+		cert =3D next;
+	}
+}
+
+LIB_EXPORT bool l_cert_link_issuer(struct l_cert *cert, struct l_cert *iss=
uer)
+{
+	if (!cert)
+		return false;
+
+	if (issuer && (issuer->issued || cert->issuer))
+		return false;
+
+	if (cert->issuer)
+		cert->issuer->issued =3D NULL;
+
+	cert->issuer =3D issuer;
+	return true;
+}
+
+LIB_EXPORT struct l_cert *l_cert_get_issuer(struct l_cert *cert)
+{
+	return cert->issuer;
+}
+
+LIB_EXPORT const uint8_t *l_cert_get_der_data(struct l_cert *cert,
+						size_t *out_len)
+{
+	*out_len =3D cert->asn1_len;
+	return cert->asn1;
+}
+
+LIB_EXPORT bool l_cert_find_certchain(struct l_cert *cert,
+					struct l_cert *ca_cert)
+{
+	return true;
+}
+
+static void cert_key_cleanup(struct l_key **p)
+{
+	l_key_free_norevoke(*p);
+}
+
+static bool cert_verify_with_keyring(struct l_cert *cert,
+					struct l_keyring *ring,
+					struct l_cert *root,
+					struct l_keyring *trusted)
+{
+	if (!cert)
+		return true;
+
+	if (cert->pubkey_type !=3D L_CERT_KEY_RSA)
+		return false;
+
+	/*
+	 * RFC5246 7.4.2:
+	 * "Because certificate validation requires that root keys be
+	 * distributed independently, the self-signed certificate that
+	 * specifies the root certificate authority MAY be omitted from
+	 * the chain, under the assumption that the remote end must
+	 * already possess it in order to validate it in any case."
+	 */
+	if (!cert->issuer && root && cert->asn1_len =3D=3D root->asn1_len &&
+			!memcmp(cert->asn1, root->asn1, root->asn1_len))
+		return true;
+
+	if (cert_verify_with_keyring(cert->issuer, ring, root, trusted)) {
+		L_AUTO_CLEANUP_VAR(struct l_key *, key, cert_key_cleanup);
+
+		key =3D l_key_new(L_KEY_RSA, cert->asn1, cert->asn1_len);
+		if (!key)
+			return false;
+
+		if (!l_keyring_link(ring, key))
+			return false;
+
+		if (trusted || cert->issuer)
+			return true;
+
+		/*
+		 * If execution reaches this point, it's known that:
+		 *  * No trusted root key was supplied, so the chain is only
+		 *    being checked against its own root
+		 *  * The keyring 'ring' is not restricted yet
+		 *  * The chain's root cert was just linked in to the
+		 *    previously empty keyring 'ring'.
+		 *
+		 * By restricting 'ring' now, the rest of the certs in
+		 * the chain will have their signature validated using 'key'
+		 * as the root.
+		 */
+		return l_keyring_restrict(ring,	L_KEYRING_RESTRICT_ASYM_CHAIN,
+						trusted);
+	}
+
+	return false;
+}
+
+static void cert_keyring_cleanup(struct l_keyring **p)
+{
+	l_keyring_free(*p);
+}
+
+LIB_EXPORT bool l_cert_verify_certchain(struct l_cert *certchain,
+					struct l_cert *ca_cert)
+{
+	L_AUTO_CLEANUP_VAR(struct l_keyring *, ca_ring,
+				cert_keyring_cleanup) =3D NULL;
+	L_AUTO_CLEANUP_VAR(struct l_keyring *, verify_ring,
+				cert_keyring_cleanup) =3D NULL;
+
+	if (!certchain || certchain->pubkey_type !=3D L_CERT_KEY_RSA)
+		return false;
+
+	if (ca_cert && ca_cert->pubkey_type !=3D L_CERT_KEY_RSA)
+		return false;
+
+	if (ca_cert) {
+		L_AUTO_CLEANUP_VAR(struct l_key *, ca_key, cert_key_cleanup);
+		ca_key =3D NULL;
+
+		ca_ring =3D l_keyring_new();
+		if (!ca_ring)
+			return false;
+
+		ca_key =3D l_key_new(L_KEY_RSA, ca_cert->asn1, ca_cert->asn1_len);
+		if (!ca_key || !l_keyring_link(ca_ring, ca_key))
+			return false;
+	}
+
+	verify_ring =3D l_keyring_new();
+	if (!verify_ring)
+		return false;
+
+	/*
+	 * If a CA cert was supplied, restrict verify_ring now so
+	 * everything else in certchain is validated against the CA.
+	 * Otherwise, verify_ring will be restricted after the root of
+	 * certchain is added to verify_ring by
+	 * cert_verify_with_keyring().
+	 */
+	if (ca_ring && !l_keyring_restrict(verify_ring,
+						L_KEYRING_RESTRICT_ASYM_CHAIN,
+						ca_ring)) {
+		return false;
+	}
+
+	return cert_verify_with_keyring(certchain, verify_ring, ca_cert,
+					ca_ring);
+}
+
+LIB_EXPORT enum l_cert_key_type l_cert_get_pubkey_type(struct l_cert *cert)
+{
+	return cert->pubkey_type;
+}
+
+LIB_EXPORT struct l_key *l_cert_get_pubkey(struct l_cert *cert)
+{
+	/* Use kernel's ASN.1 certificate parser to find the key data for us */
+	if (cert->pubkey_type =3D=3D L_CERT_KEY_RSA)
+		return l_key_new(L_KEY_RSA, cert->asn1, cert->asn1_len);
+
+	return NULL;
+}
diff --git a/ell/cert.h b/ell/cert.h
new file mode 100644
index 0000000..4d809be
--- /dev/null
+++ b/ell/cert.h
@@ -0,0 +1,57 @@
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
+#include <stdbool.h>
+
+#include <ell/key.h>
+
+struct l_cert;
+
+enum l_cert_key_type {
+	L_CERT_KEY_RSA,
+	L_CERT_KEY_UNKNOWN,
+};
+
+struct l_cert *l_cert_new_from_der(const uint8_t *buf, size_t buf_len);
+void l_cert_free(struct l_cert *cert);
+
+bool l_cert_link_issuer(struct l_cert *cert, struct l_cert *issuer);
+struct l_cert *l_cert_get_issuer(struct l_cert *cert);
+const uint8_t *l_cert_get_der_data(struct l_cert *cert, size_t *out_len);
+bool l_cert_find_certchain(struct l_cert *cert, struct l_cert *ca_cert);
+bool l_cert_verify_certchain(struct l_cert *certchain, struct l_cert *ca_c=
ert);
+enum l_cert_key_type l_cert_get_pubkey_type(struct l_cert *cert);
+struct l_key *l_cert_get_pubkey(struct l_cert *cert);
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
index 614bc93..d100005 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -432,6 +432,14 @@ global:
 	l_uuid_is_valid;
 	l_uuid_get_version;
 	l_uuid_to_string;
+	/* cert */
+	l_cert_new_from_der;
+	l_cert_free;
+	l_cert_get_der_data;
+	l_cert_find_certchain;
+	l_cert_verify_certchain;
+	l_cert_get_pubkey_type;
+	l_cert_get_pubkey;
 local:
 	*;
 };
-- =

2.19.1


--===============0987264403102441167==--

