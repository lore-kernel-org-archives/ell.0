Content-Type: multipart/mixed; boundary="===============7218289916276478445=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 06/17] Add RSA PKCS#1 1.5 assymetric key encryption operations.
Date: Fri, 24 Jul 2015 05:26:47 +0200
Message-ID: <1437708410-28075-6-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1437708410-28075-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7218289916276478445==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

RSA support is required for different X509 digital certificate and TLS
operations and is since recently present in the kernel.  Being an
asymetric key cipher the API is not the same as that used by the
current symmetric ciphers in cipher.c based on the algif_skcipher driver.
At this time there's no corresponding algif_akcipher for userspace to
asymmetric key ciphers in Linux mainline or the crypto tree so this code
works against a patch that applies on the mainline kernel
4a10a91756ef381bced7b88cfb9232f660b92d93.  Another algif_akcipher
implementation has been posted this week to the linux-kernel-cryptapi
list but comments so far indicate that it will be a while before it is
finalised so temporarily acceping this implementation against a patched
kernel may be a better option than waiting for the mainline support.

There's another twist to RSA in that it is normally used with pre/post
processing step before/after applying actual RSA operations to the data,
called a padding scheme - usually one two standards.  We implement the
PKCS#1 v1.5 padding scheme.  This may also end up being implemented in
the kernel but this is unclear.  I decided not to call the ell files
ell/akcipher.{c,h} but rather ell/rsa.c and ell/rsa-private.h until
that is clear because we can then decide the API based on that.

ell/rsa.c only implements the padding scheme, reusing ell/cipher.c for
access to the kernel socket API.
---
 Makefile.am       |   4 +-
 ell/cipher.c      |   6 +-
 ell/cipher.h      |   1 +
 ell/rsa-private.h |  41 +++++++++
 ell/rsa.c         | 254 ++++++++++++++++++++++++++++++++++++++++++++++++++=
++++
 5 files changed, 304 insertions(+), 2 deletions(-)
 create mode 100644 ell/rsa-private.h
 create mode 100644 ell/rsa.c

diff --git a/Makefile.am b/Makefile.am
index fb2a35c..aab2f9e 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -76,7 +76,9 @@ ell_libell_la_SOURCES =3D $(linux_headers) \
 			ell/cipher.c \
 			ell/random.c \
 			ell/uintset.c \
-			ell/asn1-private.h
+			ell/asn1-private.h \
+			ell/rsa-private.h \
+			ell/rsa.c
 =

 ell_libell_la_LDFLAGS =3D -no-undefined \
 			-version-info $(ELL_CURRENT):$(ELL_REVISION):$(ELL_AGE)
diff --git a/ell/cipher.c b/ell/cipher.c
index 3619f2c..b85ba6b 100644
--- a/ell/cipher.c
+++ b/ell/cipher.c
@@ -76,7 +76,7 @@ struct af_alg_iv {
 #define SOL_ALG 279
 #endif
 =

-#define is_valid_type(type)  ((type) <=3D L_CIPHER_DES3_EDE_CBC)
+#define is_valid_type(type)  ((type) <=3D L_CIPHER_RSA)
 =

 struct l_cipher {
 	enum l_cipher_type type;
@@ -112,6 +112,10 @@ static int create_alg(enum l_cipher_type type,
 	case L_CIPHER_DES3_EDE_CBC:
 		strcpy((char *) salg.salg_name, "cbc(des3_ede)");
 		break;
+	case L_CIPHER_RSA:
+		strcpy((char *) salg.salg_name, "rsa");
+		strcpy((char *) salg.salg_type, "akcipher");
+		break;
 	}
 =

 	if (bind(sk, (struct sockaddr *) &salg, sizeof(salg)) < 0) {
diff --git a/ell/cipher.h b/ell/cipher.h
index 74b96a3..a4db8c2 100644
--- a/ell/cipher.h
+++ b/ell/cipher.h
@@ -34,6 +34,7 @@ enum l_cipher_type {
 	L_CIPHER_AES_CBC,
 	L_CIPHER_ARC4,
 	L_CIPHER_DES3_EDE_CBC,
+	L_CIPHER_RSA,
 };
 =

 struct l_cipher *l_cipher_new(enum l_cipher_type type,
diff --git a/ell/rsa-private.h b/ell/rsa-private.h
new file mode 100644
index 0000000..1835a88
--- /dev/null
+++ b/ell/rsa-private.h
@@ -0,0 +1,41 @@
+/*
+ *
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
+ *
+ */
+
+struct l_rsa;
+
+struct l_rsa *l_rsa_pkcs1_v1_5_new(const void *key, size_t key_length);
+
+void l_rsa_free(struct l_rsa *rsa);
+
+int l_rsa_get_key_size(struct l_rsa *rsa);
+
+bool l_rsa_encrypt(struct l_rsa *cipher, const void *in, void *out,
+			size_t len_in, size_t len_out);
+
+bool l_rsa_decrypt(struct l_rsa *cipher, const void *in, void *out,
+			size_t len_in, size_t len_out);
+
+bool l_rsa_sign(struct l_rsa *cipher, const void *in, void *out,
+		size_t len_in, size_t len_out);
+
+bool l_rsa_verify(struct l_rsa *cipher, const void *in, void *out,
+			size_t len_in, size_t len_out);
diff --git a/ell/rsa.c b/ell/rsa.c
new file mode 100644
index 0000000..62de136
--- /dev/null
+++ b/ell/rsa.c
@@ -0,0 +1,254 @@
+/*
+ *
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
+ *
+ */
+
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif
+
+#define _GNU_SOURCE
+
+#include "private.h"
+#include "rsa-private.h"
+#include "cipher.h"
+#include "random.h"
+#include "asn1-private.h"
+
+struct l_rsa {
+	struct l_cipher *cipher;
+	int key_size;
+};
+
+static bool parse_rsa_key(struct l_rsa *cipher, const void *key,
+				size_t key_length)
+{
+	/*
+	 * Parse the DER-encoded public or private RSA key to find
+	 * and cache the size of the modulus n for later use.
+	 * (RFC3279)
+	 */
+	size_t n_length;
+	const uint8_t *der;
+
+	if (key_length < 8)
+		return false;
+
+	/* Unpack the outer&inner SEQUENCE, take first INTEGER as the modulus */
+	der =3D der_find_elem_by_path((uint8_t *) key, key_length,
+					ASN1_ID_INTEGER, &n_length, 0, 0, -1);
+	if (!der || n_length < 4)
+		return false;
+
+	/* Skip leading zeros */
+	while (n_length && der[0] =3D=3D 0x00) {
+		der++;
+		n_length--;
+	}
+
+	cipher->key_size =3D n_length;
+
+	return true;
+}
+
+struct l_rsa *l_rsa_pkcs1_v1_5_new(const void *key, size_t key_length)
+{
+	struct l_rsa *rsa;
+
+	rsa =3D l_new(struct l_rsa, 1);
+	rsa->cipher =3D l_cipher_new(L_CIPHER_RSA, key, key_length);
+
+	if (!rsa->cipher)
+		goto error_free_rsa;
+
+	if (!parse_rsa_key(rsa, key, key_length))
+		goto error_free;
+
+	return rsa;
+
+error_free:
+	l_cipher_free(rsa->cipher);
+error_free_rsa:
+	l_free(rsa);
+	return NULL;
+}
+
+void l_rsa_free(struct l_rsa *rsa)
+{
+	if (unlikely(!rsa))
+		return;
+
+	l_cipher_free(rsa->cipher);
+	l_free(rsa);
+}
+
+int l_rsa_get_key_size(struct l_rsa *rsa)
+{
+	return rsa->key_size;
+}
+
+static void getrandom_nonzero(uint8_t *buf, int len)
+{
+	while (len--) {
+		l_getrandom(buf, 1);
+		while (buf[0] =3D=3D 0)
+			l_getrandom(buf, 1);
+
+		buf++;
+	}
+}
+
+bool l_rsa_encrypt(struct l_rsa *cipher,
+			const void *in, void *out,
+			size_t len_in, size_t len_out)
+{
+	/* PKCS#1 v1.5 RSA padding according to RFC3447 */
+	while (len_in) {
+		int chunk_len =3D
+			(size_t) cipher->key_size - 11 < len_in ?
+				cipher->key_size - 11 : (int) len_in;
+		uint8_t buf[cipher->key_size];
+		int ps_len =3D cipher->key_size - chunk_len - 3;
+
+		buf[0] =3D 0x00;
+		buf[1] =3D 0x02;
+		getrandom_nonzero(buf + 2, ps_len);
+		buf[ps_len + 2] =3D 0x00;
+		memcpy(buf + ps_len + 3, in, chunk_len);
+
+		if (!l_cipher_encrypt(cipher->cipher, buf, out,
+					cipher->key_size))
+			return false;
+
+		in +=3D chunk_len;
+		len_in -=3D chunk_len;
+		out +=3D cipher->key_size;
+		len_out -=3D cipher->key_size;
+	}
+
+	return true;
+}
+
+bool l_rsa_decrypt(struct l_rsa *cipher,
+			const void *in, void *out,
+			size_t len_in, size_t len_out)
+{
+	/* PKCS#1 v1.5 RSA padding according to RFC3447 */
+	while (len_in) {
+		uint8_t buf[cipher->key_size];
+		int pos;
+
+		if (len_in < (size_t) cipher->key_size)
+			return false;
+
+		if (!l_cipher_decrypt(cipher->cipher, in, buf,
+					cipher->key_size))
+			return false;
+
+		if (buf[0] !=3D 0x00)
+			return false;
+		if (buf[1] !=3D 0x02)
+			return false;
+
+		for (pos =3D 2; pos < cipher->key_size; pos++)
+			if (buf[pos] =3D=3D 0)
+				break;
+		if (pos < 10 || pos =3D=3D cipher->key_size)
+			return false;
+
+		pos++;
+		if (len_out < (size_t) cipher->key_size - pos)
+			return false;
+
+		memcpy(out, buf + pos, cipher->key_size - pos);
+
+		in +=3D cipher->key_size;
+		len_in -=3D cipher->key_size;
+		out +=3D cipher->key_size - pos;
+		len_out -=3D cipher->key_size - pos;
+	}
+
+	return true;
+}
+
+bool l_rsa_sign(struct l_rsa *cipher,
+		const void *in, void *out,
+		size_t len_in, size_t len_out)
+{
+	/* PKCS#1 v1.5 RSA padding according to RFC3447 */
+	uint8_t buf[cipher->key_size];
+	int ps_len =3D cipher->key_size - len_in - 3;
+
+	if (len_in > (size_t) cipher->key_size - 11)
+		return false;
+
+	buf[0] =3D 0x00;
+	buf[1] =3D 0x01;
+	memset(buf + 2, 0xff, ps_len);
+	buf[ps_len + 2] =3D 0x00;
+	memcpy(buf + ps_len + 3, in, len_in);
+
+	/*
+	 * The RSA signing operation uses the same primitive as
+	 * decryption so just call decrypt.
+	 */
+	if (!l_cipher_decrypt(cipher->cipher, buf, out, cipher->key_size))
+		return false;
+
+	return true;
+}
+
+bool l_rsa_verify(struct l_rsa *cipher,
+			const void *in, void *out,
+			size_t len_in, size_t len_out)
+{
+	/* PKCS#1 v1.5 RSA padding according to RFC3447 */
+	uint8_t buf[cipher->key_size];
+	int pos;
+
+	if (len_in !=3D (size_t) cipher->key_size)
+		return false;
+
+	/*
+	 * The RSA verify operation uses the same primitive as
+	 * encryption so just call encrypt.
+	 */
+	if (!l_cipher_encrypt(cipher->cipher, in, buf, cipher->key_size))
+		return false;
+
+	if (buf[0] !=3D 0x00)
+		return false;
+	if (buf[1] !=3D 0x01)
+		return false;
+
+	for (pos =3D 2; pos < cipher->key_size; pos++)
+		if (buf[pos] !=3D 0xff)
+			break;
+	if (pos < 10 || pos =3D=3D cipher->key_size || buf[pos] !=3D 0)
+		return false;
+
+	pos++;
+	if (len_out !=3D (size_t) cipher->key_size - pos)
+		return false;
+
+	memcpy(out, buf + pos, cipher->key_size - pos);
+
+	return true;
+}
-- =

2.1.4


--===============7218289916276478445==--

