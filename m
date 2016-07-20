Content-Type: multipart/mixed; boundary="===============5634543872883193916=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 3/4] key: Add key-based asymmetric crypto operations
Date: Wed, 20 Jul 2016 15:19:27 -0700
Message-ID: <20160720221928.24488-3-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20160720221928.24488-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5634543872883193916==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The kernel (as of v4.8) has asymmetric crypto methods available using
the keyctl API which make use of the kernel keyrings. The main
advantage of this API over AF_ALG is that typical asymmetric
operations involve fewer system calls.
---
 ell/key.c | 200 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++=
++++
 ell/key.h |  21 +++++++
 2 files changed, 221 insertions(+)

diff --git a/ell/key.c b/ell/key.c
index 60602f9..85e461f 100644
--- a/ell/key.c
+++ b/ell/key.c
@@ -29,10 +29,12 @@
 #include <stdint.h>
 #include <sys/syscall.h>
 #include <linux/keyctl.h>
+#include <errno.h>
 =

 #include "private.h"
 #include "util.h"
 #include "key.h"
+#include "string.h"
 =

 #ifndef KEYCTL_DH_COMPUTE
 #define KEYCTL_DH_COMPUTE 23
@@ -44,11 +46,47 @@ struct keyctl_dh_params {
 };
 #endif
 =

+#ifndef KEYCTL_PKEY_QUERY
+#define KEYCTL_PKEY_QUERY	24
+#define KEYCTL_PKEY_ENCRYPT	25
+#define KEYCTL_PKEY_DECRYPT	26
+#define KEYCTL_PKEY_SIGN	27
+#define KEYCTL_PKEY_VERIFY	28
+
+#define KEYCTL_SUPPORTS_ENCRYPT	0x01
+#define KEYCTL_SUPPORTS_DECRYPT	0x02
+#define KEYCTL_SUPPORTS_SIGN	0x04
+#define KEYCTL_SUPPORTS_VERIFY	0x08
+
+struct keyctl_pkey_query {
+	uint32_t supported_ops;
+	uint32_t key_size;
+	uint16_t max_data_size;
+	uint16_t max_sig_size;
+	uint16_t max_enc_size;
+	uint16_t max_dec_size;
+
+	uint32_t __spare[10];
+};
+
+struct keyctl_pkey_params {
+	int32_t key_id;
+	uint32_t in_len;
+	union {
+		uint32_t out_len;
+		uint32_t in2_len;
+	};
+	uint32_t __spare[7];
+};
+#endif
+
 static int32_t internal_keyring;
 =

 struct l_key {
 	int type;
 	int32_t serial;
+	char *encoding;
+	char *hash;
 };
 =

 struct l_keyring {
@@ -117,6 +155,43 @@ static long kernel_unlink_key(int32_t key_serial, int3=
2_t ring_serial)
 	return result >=3D 0 ? result : -errno;
 }
 =

+static char *format_key_info(const char *encoding, const char *hash)
+{
+	struct l_string *info;
+
+	if (!encoding && !hash)
+		return NULL;
+
+	info =3D l_string_new(0);
+
+	if (encoding)
+		l_string_append_printf(info, "enc=3D%s ", encoding);
+
+	if (hash)
+		l_string_append_printf(info, "hash=3D%s", hash);
+
+	return l_string_free(info, false);
+}
+
+static long kernel_query_key(int32_t key_serial, size_t *size, bool *publi=
c,
+				const char *encoding, const char *hash)
+{
+	long result;
+	struct keyctl_pkey_query query;
+	char *info =3D format_key_info(encoding, hash);
+
+	result =3D syscall(__NR_keyctl, KEYCTL_PKEY_QUERY, key_serial, 0,
+				info ?: "", &query);
+	if (result =3D=3D 0) {
+		*size =3D query.key_size;
+		*public =3D ((query.supported_ops & KEYCTL_SUPPORTS_ENCRYPT) &&
+			!(query.supported_ops & KEYCTL_SUPPORTS_DECRYPT));
+	}
+	l_free(info);
+
+	return result >=3D 0 ? result : -errno;
+}
+
 static long kernel_dh_compute(int32_t private, int32_t prime, int32_t base,
 			      void *payload, size_t len)
 {
@@ -132,6 +207,40 @@ static long kernel_dh_compute(int32_t private, int32_t=
 prime, int32_t base,
 	return result >=3D 0 ? result : -errno;
 }
 =

+static long kernel_key_eds(int op, int32_t serial, const char *encoding,
+				const char *hash, const void *in, void *out,
+				size_t len_in, size_t len_out)
+{
+	long result;
+	struct keyctl_pkey_params params =3D { .key_id =3D serial,
+					     .in_len =3D len_in,
+					     .out_len =3D len_out };
+	char *info =3D format_key_info(encoding, hash);
+
+	result =3D syscall(__NR_keyctl, op, &params, info ?: "", in, out);
+	l_free(info);
+
+	return result >=3D 0 ? result : -errno;
+}
+
+static long kernel_key_verify(int32_t serial, const char *encoding,
+				const char *hash, const void *data,
+				const void *sig, size_t len_data,
+				size_t len_sig)
+{
+	long result;
+	struct keyctl_pkey_params params =3D { .key_id =3D serial,
+					     .in_len =3D len_data,
+					     .in2_len =3D len_sig };
+	char *info =3D format_key_info(encoding, hash);
+
+	result =3D syscall(__NR_keyctl, KEYCTL_PKEY_VERIFY, &params, info ?: "",
+				data, sig);
+	l_free(info);
+
+	return result >=3D 0 ? result : -errno;
+}
+
 static bool setup_internal_keyring(void)
 {
 	internal_keyring =3D kernel_add_key("keyring", "ell-internal", NULL, 0,
@@ -220,6 +329,12 @@ LIB_EXPORT ssize_t l_key_get_size(struct l_key *key)
 	return kernel_read_key(key->serial, NULL, 0);
 }
 =

+bool l_key_get_info(struct l_key *key, size_t *bits, bool *public)
+{
+	return !kernel_query_key(key->serial, bits, public, key->encoding,
+					key->hash);
+}
+
 static bool compute_common(struct l_key *base,
 			   struct l_key *private,
 			   struct l_key *prime,
@@ -255,6 +370,91 @@ LIB_EXPORT bool l_key_compute_dh_secret(struct l_key *=
other_public,
 	return compute_common(other_public, private, prime, payload, len);
 }
 =

+LIB_EXPORT bool l_key_set_cipher(struct l_key *key,
+					enum l_asymmetric_cipher_type cipher)
+{
+	if (unlikely(!key))
+		return false;
+
+	switch (cipher) {
+	case L_CIPHER_RSA_PKCS1_V1_5:
+		key->encoding =3D "pkcs1";
+		break;
+	}
+
+	return true;
+}
+
+LIB_EXPORT bool l_key_set_checksum_info(struct l_key *key,
+					enum l_checksum_type checksum)
+{
+	if (unlikely(!key))
+		return false;
+
+	switch (checksum) {
+	case L_CHECKSUM_MD5:
+		key->hash =3D "md5";
+		break;
+	case L_CHECKSUM_SHA1:
+		key->hash =3D "sha1";
+		break;
+	case L_CHECKSUM_SHA256:
+		key->hash =3D "sha256";
+		break;
+	case L_CHECKSUM_SHA384:
+		key->hash =3D "sha384";
+		break;
+	case L_CHECKSUM_SHA512:
+		key->hash =3D "sha512";
+		break;
+	}
+
+	return true;
+}
+
+static ssize_t eds_common(struct l_key *key, const void *in, void *out,
+				size_t len_in, size_t len_out, int op)
+{
+	if (unlikely(!key))
+		return -EINVAL;
+
+	return kernel_key_eds(op, key->serial, key->encoding, key->hash, in,
+				out, len_in, len_out);
+}
+
+LIB_EXPORT ssize_t l_key_encrypt(struct l_key *key, const void *in, void *=
out,
+			size_t len_in, size_t len_out)
+{
+	return eds_common(key, in, out, len_in, len_out, KEYCTL_PKEY_ENCRYPT);
+}
+
+LIB_EXPORT ssize_t l_key_decrypt(struct l_key *key, const void *in, void *=
out,
+			size_t len_in, size_t len_out)
+{
+	return eds_common(key, in, out, len_in, len_out, KEYCTL_PKEY_DECRYPT);
+}
+
+LIB_EXPORT ssize_t l_key_sign(struct l_key *key, const void *in, void *out,
+			size_t len_in, size_t len_out)
+{
+	return eds_common(key, in, out, len_in, len_out, KEYCTL_PKEY_SIGN);
+}
+
+LIB_EXPORT bool l_key_verify(struct l_key *key, const void *data,
+				const void *sig, size_t len_data,
+				size_t len_sig)
+{
+	long result;
+
+	if (unlikely(!key))
+		return false;
+
+	result =3D kernel_key_verify(key->serial, key->encoding, key->hash,
+					data, sig, len_data, len_sig);
+
+	return result =3D=3D 0;
+}
+
 LIB_EXPORT struct l_keyring *l_keyring_new(enum l_keyring_type type,
 						const struct l_keyring *trusted)
 {
diff --git a/ell/key.h b/ell/key.h
index 5d981f1..f5176d1 100644
--- a/ell/key.h
+++ b/ell/key.h
@@ -30,6 +30,9 @@ extern "C" {
 #include <stddef.h>
 #include <stdbool.h>
 =

+#include <ell/checksum.h>
+#include <ell/cipher.h>
+
 struct l_key;
 struct l_keyring;
 =

@@ -54,12 +57,30 @@ bool l_key_extract(struct l_key *key, void *payload, si=
ze_t *len);
 =

 ssize_t l_key_get_size(struct l_key *key);
 =

+bool l_key_get_info(struct l_key *key, size_t *bits, bool *public);
+
 bool l_key_compute_dh_public(struct l_key *generator, struct l_key *privat=
e,
 			     struct l_key *prime, void *payload, size_t *len);
 =

 bool l_key_compute_dh_secret(struct l_key *other_public, struct l_key *pri=
vate,
 			     struct l_key *prime, void *payload, size_t *len);
 =

+bool l_key_set_cipher(struct l_key *key, enum l_asymmetric_cipher_type cip=
her);
+
+bool l_key_set_checksum_info(struct l_key *key, enum l_checksum_type check=
sum);
+
+ssize_t l_key_encrypt(struct l_key *key, const void *in, void *out,
+			size_t len_in, size_t len_out);
+
+ssize_t l_key_decrypt(struct l_key *key, const void *in, void *out,
+			size_t len_in, size_t len_out);
+
+ssize_t l_key_sign(struct l_key *key, const void *in, void *out,
+			size_t len_in, size_t len_out);
+
+bool l_key_verify(struct l_key *key, const void *data, const void *sig,
+			size_t len_data, size_t len_sig);
+
 struct l_keyring *l_keyring_new(enum l_keyring_type type,
 				const struct l_keyring *trust);
 =

-- =

2.9.2


--===============5634543872883193916==--

