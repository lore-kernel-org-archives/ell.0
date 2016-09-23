Content-Type: multipart/mixed; boundary="===============2567617038704351977=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 6/9] key: Do RSA PKCS1 v1.5 padding in userspace instead of
 the kernel
Date: Fri, 23 Sep 2016 16:02:19 -0700
Message-ID: <20160923230222.27401-6-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20160923230222.27401-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2567617038704351977==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Kernel v4.8 removed the ability to perform RSA signing or verification
without also generating or verifying an additional hash, which breaks a
major use case for ELL crypto. Instead, rely on RSA raw operations.

Using raw RSA means the keyctl RSA verify operation no longer functions
for padded signatures, since it attempts to compare the results before
they are unpadded. Since the math for the "encrypt" op is the same, that
can be used instead.
---
 ell/key.c | 202 ++++++++++++++++++++++++++++++++++++++++++++++++++++------=
----
 ell/key.h |   1 +
 2 files changed, 173 insertions(+), 30 deletions(-)

diff --git a/ell/key.c b/ell/key.c
index a0cfcd4..24c42a2 100644
--- a/ell/key.c
+++ b/ell/key.c
@@ -35,6 +35,7 @@
 #include "util.h"
 #include "key.h"
 #include "string.h"
+#include "random.h"
 =

 #ifndef KEYCTL_DH_COMPUTE
 #define KEYCTL_DH_COMPUTE 23
@@ -223,24 +224,6 @@ static long kernel_key_eds(int op, int32_t serial, con=
st char *encoding,
 	return result >=3D 0 ? result : -errno;
 }
 =

-static long kernel_key_verify(int32_t serial, const char *encoding,
-				const char *hash, const void *data,
-				const void *sig, size_t len_data,
-				size_t len_sig)
-{
-	long result;
-	struct keyctl_pkey_params params =3D { .key_id =3D serial,
-					     .in_len =3D len_data,
-					     .in2_len =3D len_sig };
-	char *info =3D format_key_info(encoding, hash);
-
-	result =3D syscall(__NR_keyctl, KEYCTL_PKEY_VERIFY, &params, info ?: "",
-				data, sig);
-	l_free(info);
-
-	return result >=3D 0 ? result : -errno;
-}
-
 static bool setup_internal_keyring(void)
 {
 	internal_keyring =3D kernel_add_key("keyring", "ell-internal", NULL, 0,
@@ -342,7 +325,13 @@ static const char *lookup_cipher(enum l_key_cipher_typ=
e cipher)
 =

 	switch (cipher) {
 	case L_KEY_RSA_PKCS1_V1_5:
-		ret =3D "pkcs1";
+		/* Padding is handled in userspace, so the kernel only sees
+		 * raw RSA operations
+		 */
+		ret =3D "raw";
+		break;
+	case L_KEY_RSA_RAW:
+		ret =3D "raw";
 		break;
 	}
 =

@@ -437,14 +426,99 @@ static ssize_t eds_common(struct l_key *key,
 				len_out);
 }
 =

+static void getrandom_nonzero(uint8_t *buf, int len)
+{
+	l_getrandom(buf, len);
+
+	while (len--) {
+		while (buf[0] =3D=3D 0)
+			l_getrandom(buf, 1);
+
+		buf++;
+	}
+}
+
+/* PKCS#1 v1.5 RSA padding according to RFC3447 */
+static uint8_t *pad(const uint8_t *in, size_t len_in, size_t len_out,
+			uint8_t flag, bool randfill)
+{
+	size_t fill_len;
+	uint8_t *padded;
+
+	if (len_in > len_out - 11)
+		return NULL;
+
+	padded =3D l_malloc(len_out);
+	fill_len =3D len_out - len_in - 3;
+
+	padded[0] =3D 0x00;
+	padded[1] =3D flag;
+
+	if (randfill)
+		getrandom_nonzero(padded + 2, fill_len);
+	else
+		memset(padded + 2, 0xff, fill_len);
+
+	padded[fill_len + 2] =3D 0x00;
+	memcpy(padded + fill_len + 3, in, len_in);
+
+	return padded;
+}
+
+static ssize_t unpad(uint8_t *in, uint8_t *out, size_t len_in, size_t len_=
out,
+			uint8_t flag, bool randfill)
+{
+	size_t pos;
+	ssize_t unpad_len;
+
+	if (in[0] !=3D 0x00 || in[1] !=3D flag)
+		return -EINVAL;
+
+	if (randfill)
+		for (pos =3D 2; pos < len_in && in[pos] !=3D 0x00; pos++);
+	else
+		for (pos =3D 2; pos < len_in && in[pos] =3D=3D 0xff; pos++);
+
+	if (pos < 10 || pos =3D=3D len_in)
+		return -EINVAL;
+
+	pos++;
+	unpad_len =3D len_in - pos;
+
+	if (out) {
+		if ((size_t)unpad_len > len_out)
+			return -EINVAL;
+
+		memcpy(out, in + pos, unpad_len);
+	}
+
+	return unpad_len;
+}
+
 LIB_EXPORT ssize_t l_key_encrypt(struct l_key *key,
 					enum l_key_cipher_type cipher,
 					enum l_checksum_type checksum,
 					const void *in, void *out,
 					size_t len_in, size_t len_out)
 {
-	return eds_common(key, cipher, checksum, in, out, len_in, len_out,
+	uint8_t *padded =3D NULL;
+	ssize_t ret_len;
+
+	if (cipher =3D=3D L_KEY_RSA_PKCS1_V1_5) {
+		padded =3D pad(in, len_in, len_out, 0x02, true);
+		if (!padded)
+			return -EOVERFLOW;
+
+		cipher =3D L_KEY_RSA_RAW;
+	}
+
+	ret_len =3D eds_common(key, cipher, checksum, padded ?: in, out,
+				padded ? len_out : len_in, len_out,
 				KEYCTL_PKEY_ENCRYPT);
+
+	l_free(padded);
+
+	return ret_len;
 }
 =

 LIB_EXPORT ssize_t l_key_decrypt(struct l_key *key,
@@ -453,8 +527,25 @@ LIB_EXPORT ssize_t l_key_decrypt(struct l_key *key,
 					const void *in, void *out,
 					size_t len_in, size_t len_out)
 {
-	return eds_common(key, cipher, checksum, in, out, len_in, len_out,
-				KEYCTL_PKEY_DECRYPT);
+	uint8_t *padded =3D NULL;
+	ssize_t ret_len;
+
+	if (cipher =3D=3D L_KEY_RSA_PKCS1_V1_5)
+		padded =3D l_malloc(len_in);
+
+	ret_len =3D eds_common(key, cipher, checksum, in, padded ?: out, len_in,
+				padded ? len_in : len_out, KEYCTL_PKEY_DECRYPT);
+
+	if (ret_len < 0)
+		goto done;
+
+	if (padded)
+		ret_len =3D unpad(padded, out, ret_len, len_out, 0x02, true);
+
+done:
+	l_free(padded);
+
+	return ret_len;
 }
 =

 LIB_EXPORT ssize_t l_key_sign(struct l_key *key,
@@ -462,8 +553,24 @@ LIB_EXPORT ssize_t l_key_sign(struct l_key *key,
 				enum l_checksum_type checksum, const void *in,
 				void *out, size_t len_in, size_t len_out)
 {
-	return eds_common(key, cipher, checksum, in, out, len_in, len_out,
+	uint8_t *padded =3D NULL;
+	ssize_t ret_len;
+
+	if (cipher =3D=3D L_KEY_RSA_PKCS1_V1_5) {
+		padded =3D pad(in, len_in, len_out, 0x01, false);
+		if (!padded)
+			return -EOVERFLOW;
+
+		cipher =3D L_KEY_RSA_RAW;
+	}
+
+	ret_len =3D eds_common(key, cipher, checksum, padded ?: in, out,
+				padded ? len_out : len_in, len_out,
 				KEYCTL_PKEY_SIGN);
+
+	l_free(padded);
+
+	return ret_len;
 }
 =

 LIB_EXPORT bool l_key_verify(struct l_key *key,
@@ -472,16 +579,51 @@ LIB_EXPORT bool l_key_verify(struct l_key *key,
 				const void *sig, size_t len_data,
 				size_t len_sig)
 {
-	long result;
+	enum l_key_cipher_type kernel_cipher;
+	ssize_t hash_len;
+	uint8_t *compare_hash;
+	bool success =3D false;
+	uint8_t *sig_hash =3D l_malloc(len_sig);
 =

-	if (unlikely(!key))
-		return false;
+	/* The keyctl verify implementation compares the verify results
+	 * before we get a chance to unpad it. Instead, use the *encrypt*
+	 * operation (which uses the same math as verify) to get the hash
+	 * returned to us so it can be unpadded before comparing
+	 */
+	if (cipher =3D=3D L_KEY_RSA_PKCS1_V1_5)
+		kernel_cipher =3D L_KEY_RSA_RAW;
+	else
+		kernel_cipher =3D cipher;
+
+	hash_len =3D eds_common(key, kernel_cipher, checksum, sig, sig_hash,
+				len_sig, len_sig, KEYCTL_PKEY_ENCRYPT);
+
+	if (hash_len < 0) {
+		success =3D false;
+		goto done;
+	}
+
+	compare_hash =3D sig_hash;
+
+	if (cipher =3D=3D L_KEY_RSA_PKCS1_V1_5) {
+		ssize_t unpad_len;
+
+		unpad_len =3D unpad(sig_hash, NULL, hash_len, 0, 0x01, false);
+		if (unpad_len < 0) {
+			success =3D false;
+			goto done;
+		}
+
+		compare_hash +=3D hash_len - unpad_len;
+		hash_len =3D unpad_len;
+	}
 =

-	result =3D kernel_key_verify(key->serial, lookup_cipher(cipher),
-					lookup_checksum(checksum), data, sig,
-					len_data, len_sig);
+	success =3D (len_data =3D=3D (size_t)hash_len) &&
+		(memcmp(data, compare_hash, hash_len) =3D=3D 0);
+done:
+	l_free(sig_hash);
 =

-	return result =3D=3D 0;
+	return success;
 }
 =

 LIB_EXPORT struct l_keyring *l_keyring_new(enum l_keyring_type type,
diff --git a/ell/key.h b/ell/key.h
index 4cd6cfe..ff4b543 100644
--- a/ell/key.h
+++ b/ell/key.h
@@ -47,6 +47,7 @@ enum l_keyring_type {
 =

 enum l_key_cipher_type {
 	L_KEY_RSA_PKCS1_V1_5,
+	L_KEY_RSA_RAW,
 };
 =

 struct l_key *l_key_new(enum l_key_type type, const void *payload,
-- =

2.10.0


--===============2567617038704351977==--

