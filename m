Content-Type: multipart/mixed; boundary="===============2114483417901027480=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 4/8] pkcs5: Rename to cert-crypto
Date: Wed, 06 Jan 2021 20:54:42 +0100
Message-ID: <20210106195446.1428769-4-andrew.zaborowski@intel.com>
In-Reply-To: <20210106195446.1428769-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2114483417901027480==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

After recent changes pkcs5.c contained cryptographic routines not related
to PKCS#5 because there are ciphers in other standards defined in
similar ways.  From the pkcs5_cipher_from_alg_id() client's point of view
it didn't make sense to call different functions in different files
depending on which standard the Algorithm ID was expected or where any
well known cipher should be accepted.

cert.c and cert-crypto.c will now contain the classes and utilites related
to both certificates and private keys and low-level cryptographics
routines (in cert-crypto.c) related to the public-key cryptography
standard.  PKCS (Public-Key Cryptography Standards) would be a fitting
name but use the name "cert" to not imply that the contents are limited
to the standards created by RSA.

In this patch I rename both the file and the functions.  This is
backwards incompatible and users of the functions need to be updated.
---
 Makefile.am                    |  6 ++--
 ell/{pkcs5.c =3D> cert-crypto.c} | 56 ++++++++++++++++++----------------
 ell/cert-private.h             | 19 ++++++++++++
 ell/cert.c                     |  6 ++--
 ell/cert.h                     |  9 ++++++
 ell/ell.h                      |  1 -
 ell/ell.sym                    |  5 ++-
 ell/pkcs5-private.h            | 38 -----------------------
 ell/pkcs5.h                    | 47 ----------------------------
 ell/tls.c                      |  2 +-
 10 files changed, 65 insertions(+), 124 deletions(-)
 rename ell/{pkcs5.c =3D> cert-crypto.c} (93%)
 delete mode 100644 ell/pkcs5-private.h
 delete mode 100644 ell/pkcs5.h

diff --git a/Makefile.am b/Makefile.am
index ad68e4a..2f9a4ce 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -46,7 +46,6 @@ pkginclude_HEADERS =3D ell/ell.h \
 			ell/tls.h \
 			ell/uuid.h \
 			ell/key.h \
-			ell/pkcs5.h \
 			ell/file.h \
 			ell/dir.h \
 			ell/net.h \
@@ -114,8 +113,6 @@ ell_libell_la_SOURCES =3D $(linux_headers) \
 			ell/tls-suites.c \
 			ell/uuid.c \
 			ell/key.c \
-			ell/pkcs5-private.h \
-			ell/pkcs5.c \
 			ell/file.c \
 			ell/dir.c \
 			ell/net-private.h \
@@ -130,8 +127,9 @@ ell_libell_la_SOURCES =3D $(linux_headers) \
 			ell/dhcp6-lease.c \
 			ell/dhcp-util.c \
 			ell/dhcp-server.c \
-			ell/cert.c \
 			ell/cert-private.h \
+			ell/cert.c \
+			ell/cert-crypto.c \
 			ell/ecc-private.h \
 			ell/ecc.h \
 			ell/ecc-external.c \
diff --git a/ell/pkcs5.c b/ell/cert-crypto.c
similarity index 93%
rename from ell/pkcs5.c
rename to ell/cert-crypto.c
index 25bf431..6eb4e14 100644
--- a/ell/pkcs5.c
+++ b/ell/cert-crypto.c
@@ -2,7 +2,7 @@
  *
  *  Embedded Linux library
  *
- *  Copyright (C) 2017  Intel Corporation. All rights reserved.
+ *  Copyright (C) 2020  Intel Corporation. All rights reserved.
  *
  *  This library is free software; you can redistribute it and/or
  *  modify it under the terms of the GNU Lesser General Public
@@ -35,16 +35,17 @@
 #include "util.h"
 #include "utf8.h"
 #include "asn1-private.h"
-#include "pkcs5.h"
-#include "pkcs5-private.h"
 #include "private.h"
 #include "missing.h"
+#include "cert.h"
+#include "cert-private.h"
 =

 /* RFC8018 section 5.1 */
-LIB_EXPORT bool l_pkcs5_pbkdf1(enum l_checksum_type type, const char *pass=
word,
-				const uint8_t *salt, size_t salt_len,
-				unsigned int iter_count,
-				uint8_t *out_dk, size_t dk_len)
+LIB_EXPORT bool l_cert_pkcs5_pbkdf1(enum l_checksum_type type,
+					const char *password,
+					const uint8_t *salt, size_t salt_len,
+					unsigned int iter_count,
+					uint8_t *out_dk, size_t dk_len)
 {
 	size_t hash_len, t_len;
 	uint8_t t[20 + salt_len + strlen(password)];
@@ -103,10 +104,11 @@ LIB_EXPORT bool l_pkcs5_pbkdf1(enum l_checksum_type t=
ype, const char *password,
 }
 =

 /* RFC8018 section 5.2 */
-LIB_EXPORT bool l_pkcs5_pbkdf2(enum l_checksum_type type, const char *pass=
word,
-				const uint8_t *salt, size_t salt_len,
-				unsigned int iter_count,
-				uint8_t *out_dk, size_t dk_len)
+LIB_EXPORT bool l_cert_pkcs5_pbkdf2(enum l_checksum_type type,
+					const char *password,
+					const uint8_t *salt, size_t salt_len,
+					unsigned int iter_count,
+					uint8_t *out_dk, size_t dk_len)
 {
 	size_t h_len;
 	struct l_checksum *checksum;
@@ -184,9 +186,11 @@ LIB_EXPORT bool l_pkcs5_pbkdf2(enum l_checksum_type ty=
pe, const char *password,
 }
 =

 /* RFC7292 Appendix B */
-uint8_t *pkcs12_pbkdf(const char *password, const struct pkcs12_hash *hash,
-			const uint8_t *salt, size_t salt_len,
-			unsigned int iterations, uint8_t id, size_t key_len)
+uint8_t *cert_pkcs12_pbkdf(const char *password,
+				const struct cert_pkcs12_hash *hash,
+				const uint8_t *salt, size_t salt_len,
+				unsigned int iterations, uint8_t id,
+				size_t key_len)
 {
 	/* All lengths in bytes instead of bits */
 	size_t passwd_len =3D password ? 2 * strlen(password) + 2 : 0;
@@ -301,7 +305,7 @@ uint8_t *pkcs12_pbkdf(const char *password, const struc=
t pkcs12_hash *hash,
 }
 =

 /* RFC7292 Appendix A */
-static const struct pkcs12_hash pkcs12_sha1_hash =3D {
+static const struct cert_pkcs12_hash pkcs12_sha1_hash =3D {
 	.alg =3D L_CHECKSUM_SHA1,
 	.len =3D 20,
 	.u   =3D 20,
@@ -459,7 +463,7 @@ static const struct pkcs5_enc_alg_oid {
 	},
 };
 =

-static struct l_cipher *pkcs5_cipher_from_pbes2_params(
+static struct l_cipher *cipher_from_pkcs5_pbes2_params(
 						const uint8_t *pbes2_params,
 						size_t pbes2_params_len,
 						const char *password)
@@ -597,8 +601,8 @@ static struct l_cipher *pkcs5_cipher_from_pbes2_params(
 =

 	/* RFC8018 section 6.2 */
 =

-	if (!l_pkcs5_pbkdf2(prf_alg, password, salt, salt_len, iter_count,
-				derived_key, key_len))
+	if (!l_cert_pkcs5_pbkdf2(prf_alg, password, salt, salt_len, iter_count,
+					derived_key, key_len))
 		return NULL;
 =

 	cipher =3D l_cipher_new(enc_scheme->cipher_type, derived_key, key_len);
@@ -611,7 +615,7 @@ static struct l_cipher *pkcs5_cipher_from_pbes2_params(
 	return cipher;
 }
 =

-static struct l_cipher *pkcs12_cipher_from_alg_id(
+static struct l_cipher *cipher_from_pkcs12_alg_id(
 				const struct pkcs12_encryption_oid *scheme,
 				const uint8_t *params, size_t params_len,
 				const char *password, bool *out_is_block)
@@ -647,7 +651,7 @@ static struct l_cipher *pkcs12_cipher_from_alg_id(
 		return NULL;
 =

 	key_len =3D scheme->key_length;
-	key =3D pkcs12_pbkdf(password, &pkcs12_sha1_hash, salt, salt_len,
+	key =3D cert_pkcs12_pbkdf(password, &pkcs12_sha1_hash, salt, salt_len,
 				iterations, 1, key_len);
 	if (!key)
 		return NULL;
@@ -678,7 +682,7 @@ static struct l_cipher *pkcs12_cipher_from_alg_id(
 		return NULL;
 =

 	if (scheme->iv_length) {
-		uint8_t *iv =3D pkcs12_pbkdf(password, &pkcs12_sha1_hash,
+		uint8_t *iv =3D cert_pkcs12_pbkdf(password, &pkcs12_sha1_hash,
 						salt, salt_len, iterations, 2,
 						scheme->iv_length);
 =

@@ -699,7 +703,7 @@ static struct l_cipher *pkcs12_cipher_from_alg_id(
 	return cipher;
 }
 =

-struct l_cipher *pkcs5_cipher_from_alg_id(const uint8_t *id_asn1,
+struct l_cipher *cert_cipher_from_pkcs_alg_id(const uint8_t *id_asn1,
 						size_t id_asn1_len,
 						const char *password,
 						bool *out_is_block)
@@ -727,7 +731,7 @@ struct l_cipher *pkcs5_cipher_from_alg_id(const uint8_t=
 *id_asn1,
 		if (out_is_block)
 			*out_is_block =3D true;
 =

-		return pkcs5_cipher_from_pbes2_params(params, params_len,
+		return cipher_from_pkcs5_pbes2_params(params, params_len,
 							password);
 	}
 =

@@ -746,7 +750,7 @@ struct l_cipher *pkcs5_cipher_from_alg_id(const uint8_t=
 *id_asn1,
 		for (i =3D 0; i < L_ARRAY_SIZE(pkcs12_encryption_oids); i++)
 			if (asn1_oid_eq(&pkcs12_encryption_oids[i].oid,
 					oid_len, oid))
-				return pkcs12_cipher_from_alg_id(
+				return cipher_from_pkcs12_alg_id(
 						&pkcs12_encryption_oids[i],
 						params, params_len, password,
 						out_is_block);
@@ -774,8 +778,8 @@ struct l_cipher *pkcs5_cipher_from_alg_id(const uint8_t=
 *id_asn1,
 =

 	/* RFC8018 section 6.1 */
 =

-	if (!l_pkcs5_pbkdf1(pbes1_scheme->checksum_type,
-				password, salt, 8, iter_count, derived_key, 16))
+	if (!l_cert_pkcs5_pbkdf1(pbes1_scheme->checksum_type, password,
+					salt, 8, iter_count, derived_key, 16))
 		return NULL;
 =

 	cipher =3D l_cipher_new(pbes1_scheme->cipher_type, derived_key + 0, 8);
diff --git a/ell/cert-private.h b/ell/cert-private.h
index e792c4c..3fa9c9c 100644
--- a/ell/cert-private.h
+++ b/ell/cert-private.h
@@ -36,3 +36,22 @@ struct l_key *cert_key_from_pkcs8_encrypted_private_key_=
info(const uint8_t *der,
 							const char *passphrase);
 struct l_key *cert_key_from_pkcs1_rsa_private_key(const uint8_t *der,
 							size_t der_len);
+
+struct cert_pkcs12_hash {
+	enum l_checksum_type alg;
+	unsigned int len;
+	unsigned int u;
+	unsigned int v;
+	struct asn1_oid oid;
+};
+
+uint8_t *cert_pkcs12_pbkdf(const char *password,
+				const struct cert_pkcs12_hash *hash,
+				const uint8_t *salt, size_t salt_len,
+				unsigned int iterations, uint8_t id,
+				size_t key_len);
+
+struct l_cipher *cert_cipher_from_pkcs_alg_id(const uint8_t *id_asn1,
+						size_t id_asn1_len,
+						const char *password,
+						bool *out_is_block);
diff --git a/ell/cert.c b/ell/cert.c
index a102fcc..8f0a4c2 100644
--- a/ell/cert.c
+++ b/ell/cert.c
@@ -30,8 +30,6 @@
 #include "queue.h"
 #include "asn1-private.h"
 #include "cipher.h"
-#include "pkcs5.h"
-#include "pkcs5-private.h"
 #include "cert.h"
 #include "cert-private.h"
 =

@@ -619,8 +617,8 @@ struct l_key *cert_key_from_pkcs8_encrypted_private_key=
_info(const uint8_t *der,
 	if (asn1_der_find_elem(der, der_len, 2, &tag, &tmp_len))
 		return NULL;
 =

-	alg =3D pkcs5_cipher_from_alg_id(alg_id, alg_id_len, passphrase,
-					&is_block);
+	alg =3D cert_cipher_from_pkcs_alg_id(alg_id, alg_id_len, passphrase,
+						&is_block);
 	if (!alg)
 		return NULL;
 =

diff --git a/ell/cert.h b/ell/cert.h
index 9fab88e..8dbb4ab 100644
--- a/ell/cert.h
+++ b/ell/cert.h
@@ -59,6 +59,15 @@ void l_certchain_walk_from_ca(struct l_certchain *chain,
 bool l_certchain_verify(struct l_certchain *chain, struct l_queue *ca_cert=
s,
 			const char **error);
 =

+bool l_cert_pkcs5_pbkdf1(enum l_checksum_type type, const char *password,
+				const uint8_t *salt, size_t salt_len,
+				unsigned int iter_count,
+				uint8_t *out_dk, size_t dk_len);
+bool l_cert_pkcs5_pbkdf2(enum l_checksum_type type, const char *password,
+				const uint8_t *salt, size_t salt_len,
+				unsigned int iter_count,
+				uint8_t *out_dk, size_t dk_len);
+
 #ifdef __cplusplus
 }
 #endif
diff --git a/ell/ell.h b/ell/ell.h
index 6662ad5..22fddf7 100644
--- a/ell/ell.h
+++ b/ell/ell.h
@@ -45,7 +45,6 @@
 #include <ell/tls.h>
 #include <ell/uuid.h>
 #include <ell/key.h>
-#include <ell/pkcs5.h>
 #include <ell/file.h>
 #include <ell/dir.h>
 #include <ell/net.h>
diff --git a/ell/ell.sym b/ell/ell.sym
index c98bd8c..cdbc5e8 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -415,9 +415,6 @@ global:
 	l_pem_load_file;
 	l_pem_load_private_key;
 	l_pem_load_private_key_from_data;
-	/* pkcs5 */
-	l_pkcs5_pbkdf1;
-	l_pkcs5_pbkdf2;
 	/* getrandom */
 	l_getrandom;
 	l_getrandom_is_supported;
@@ -536,6 +533,8 @@ global:
 	l_certchain_walk_from_leaf;
 	l_certchain_walk_from_ca;
 	l_certchain_verify;
+	l_cert_pkcs5_pbkdf1;
+	l_cert_pkcs5_pbkdf2;
 	/* ecc */
 	l_ecc_curve_get;
 	l_ecc_curve_get_name;
diff --git a/ell/pkcs5-private.h b/ell/pkcs5-private.h
deleted file mode 100644
index 9b85fdd..0000000
--- a/ell/pkcs5-private.h
+++ /dev/null
@@ -1,38 +0,0 @@
-/*
- *
- *  Embedded Linux library
- *
- *  Copyright (C) 2017  Intel Corporation. All rights reserved.
- *
- *  This library is free software; you can redistribute it and/or
- *  modify it under the terms of the GNU Lesser General Public
- *  License as published by the Free Software Foundation; either
- *  version 2.1 of the License, or (at your option) any later version.
- *
- *  This library is distributed in the hope that it will be useful,
- *  but WITHOUT ANY WARRANTY; without even the implied warranty of
- *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- *  Lesser General Public License for more details.
- *
- *  You should have received a copy of the GNU Lesser General Public
- *  License along with this library; if not, write to the Free Software
- *  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 =
 USA
- *
- */
-
-struct pkcs12_hash {
-	enum l_checksum_type alg;
-	unsigned int len;
-	unsigned int u;
-	unsigned int v;
-	struct asn1_oid oid;
-};
-
-uint8_t *pkcs12_pbkdf(const char *password, const struct pkcs12_hash *hash,
-			const uint8_t *salt, size_t salt_len,
-			unsigned int iterations, uint8_t id, size_t key_len);
-
-struct l_cipher *pkcs5_cipher_from_alg_id(const uint8_t *id_asn1,
-						size_t id_asn1_len,
-						const char *password,
-						bool *out_is_block);
diff --git a/ell/pkcs5.h b/ell/pkcs5.h
deleted file mode 100644
index ff7bdfd..0000000
--- a/ell/pkcs5.h
+++ /dev/null
@@ -1,47 +0,0 @@
-/*
- *
- *  Embedded Linux library
- *
- *  Copyright (C) 2017  Intel Corporation. All rights reserved.
- *
- *  This library is free software; you can redistribute it and/or
- *  modify it under the terms of the GNU Lesser General Public
- *  License as published by the Free Software Foundation; either
- *  version 2.1 of the License, or (at your option) any later version.
- *
- *  This library is distributed in the hope that it will be useful,
- *  but WITHOUT ANY WARRANTY; without even the implied warranty of
- *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- *  Lesser General Public License for more details.
- *
- *  You should have received a copy of the GNU Lesser General Public
- *  License along with this library; if not, write to the Free Software
- *  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 =
 USA
- *
- */
-
-#ifndef __ELL_PKCS5_H
-#define __ELL_PKCS5_H
-
-#ifdef __cplusplus
-extern "C" {
-#endif
-
-#include <stdbool.h>
-#include <stdint.h>
-
-bool l_pkcs5_pbkdf1(enum l_checksum_type type, const char *password,
-			const uint8_t *salt, size_t salt_len,
-			unsigned int iter_count,
-			uint8_t *out_dk, size_t dk_len);
-
-bool l_pkcs5_pbkdf2(enum l_checksum_type type, const char *password,
-			const uint8_t *salt, size_t salt_len,
-			unsigned int iter_count,
-			uint8_t *out_dk, size_t dk_len);
-
-#ifdef __cplusplus
-}
-#endif
-
-#endif /* __ELL_PKCS5_H */
diff --git a/ell/tls.c b/ell/tls.c
index 4eaa66d..47eac22 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -38,11 +38,11 @@
 #include "queue.h"
 #include "pem.h"
 #include "pem-private.h"
+#include "asn1-private.h"
 #include "cert.h"
 #include "cert-private.h"
 #include "tls-private.h"
 #include "key.h"
-#include "asn1-private.h"
 #include "strv.h"
 #include "missing.h"
 #include "string.h"
-- =

2.27.0

--===============2114483417901027480==--

