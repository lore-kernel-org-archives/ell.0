Content-Type: multipart/mixed; boundary="===============2296464817086107558=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 06/13] pkcs5: Add the PKCS#12 KDF
Date: Thu, 10 Dec 2020 20:31:59 +0100
Message-ID: <20201210193202.526451-6-andrew.zaborowski@intel.com>
In-Reply-To: <20201210193202.526451-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2296464817086107558==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add the key derivation algorithm used with PKCS#12 to pkcs5.c so that it
can be found together with the two PKCS#5 KDFs, and so that it can also
be used when parsing of the PKCS#12 AlgorithmIdentifiers in the next
commit.  This KDF is not recommended for new uses.
---
 ell/pkcs5-private.h |  12 ++++
 ell/pkcs5.c         | 146 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 158 insertions(+)

diff --git a/ell/pkcs5-private.h b/ell/pkcs5-private.h
index 27ff41c..9b85fdd 100644
--- a/ell/pkcs5-private.h
+++ b/ell/pkcs5-private.h
@@ -20,6 +20,18 @@
  *
  */
 =

+struct pkcs12_hash {
+	enum l_checksum_type alg;
+	unsigned int len;
+	unsigned int u;
+	unsigned int v;
+	struct asn1_oid oid;
+};
+
+uint8_t *pkcs12_pbkdf(const char *password, const struct pkcs12_hash *hash,
+			const uint8_t *salt, size_t salt_len,
+			unsigned int iterations, uint8_t id, size_t key_len);
+
 struct l_cipher *pkcs5_cipher_from_alg_id(const uint8_t *id_asn1,
 						size_t id_asn1_len,
 						const char *password,
diff --git a/ell/pkcs5.c b/ell/pkcs5.c
index 21fda2b..bb02c33 100644
--- a/ell/pkcs5.c
+++ b/ell/pkcs5.c
@@ -33,6 +33,7 @@
 #include "checksum.h"
 #include "cipher.h"
 #include "util.h"
+#include "utf8.h"
 #include "asn1-private.h"
 #include "pkcs5.h"
 #include "pkcs5-private.h"
@@ -182,14 +183,159 @@ LIB_EXPORT bool l_pkcs5_pbkdf2(enum l_checksum_type =
type, const char *password,
 	return !dk_len;
 }
 =

+static bool utf8_to_bmpstring(const char *utf, uint8_t *out_buf,
+				unsigned int *out_len)
+{
+	unsigned int n;
+	int utflen;
+	wchar_t cp;
+	uint16_t *ptr =3D (uint16_t *) out_buf;
+
+	for (n =3D strlen(utf); n; n -=3D utflen, utf +=3D utflen) {
+		if ((utflen =3D l_utf8_get_codepoint(utf, n, &cp)) <=3D 0 ||
+				cp > 0xffff)
+			return false;
+
+		*ptr++ =3D L_CPU_TO_BE16(cp);
+	}
+
+	*ptr++ =3D 0;
+	*out_len =3D (uint8_t *) ptr - out_buf;
+	return true;
+}
+
+/* RFC7292 Appendix B */
+uint8_t *pkcs12_pbkdf(const char *password, const struct pkcs12_hash *hash,
+			const uint8_t *salt, size_t salt_len,
+			unsigned int iterations, uint8_t id, size_t key_len)
+{
+	/* All lengths in bytes instead of bits */
+	unsigned int passwd_len =3D password ? 2 * strlen(password) + 2 : 0;
+	uint8_t bmpstring[passwd_len];
+	/* Documented as v(ceiling(s/v)), usually will just equal v */
+	unsigned int s_len =3D (salt_len + hash->v - 1) & ~(hash->v - 1);
+	/* Documented as p(ceiling(s/p)), usually will just equal v */
+	unsigned int p_len =3D (passwd_len + hash->v - 1) & ~(hash->v - 1);
+	uint8_t di[hash->v + s_len + p_len];
+	uint8_t *ptr;
+	unsigned int j;
+	uint8_t *key;
+	unsigned int bytes;
+	struct l_checksum *h;
+
+	/*
+	 * If non-ASCII characters are used the BMPString enoding can end
+	 * up being shorter than 2 * strlen(password) + 2 but not longer
+	 * after this call.  Update p_len afterwards just in case.
+	 * utf8_to_bmpstring doesn't need the string to be UTF-8-validated.
+	 */
+	if (password && !utf8_to_bmpstring(password, bmpstring, &passwd_len))
+		return NULL;
+
+	p_len =3D (passwd_len + hash->v - 1) & ~(hash->v - 1);
+
+	if (!(h =3D l_checksum_new(hash->alg))) {
+		explicit_bzero(bmpstring, sizeof(bmpstring));
+		return NULL;
+	}
+
+	memset(di, id, hash->v);
+	ptr =3D di + hash->v;
+
+	for (j =3D salt_len; j < s_len; j +=3D salt_len, ptr +=3D salt_len)
+		memcpy(ptr, salt, salt_len);
+
+	if (s_len) {
+		memcpy(ptr, salt, s_len + salt_len - j);
+		ptr +=3D s_len + salt_len - j;
+	}
+
+	for (j =3D passwd_len; j < p_len; j +=3D passwd_len, ptr +=3D passwd_len)
+		memcpy(ptr, bmpstring, passwd_len);
+
+	if (p_len)
+		memcpy(ptr, bmpstring, p_len + passwd_len - j);
+
+	explicit_bzero(bmpstring, sizeof(bmpstring));
+	key =3D l_malloc(key_len + hash->len);
+
+	for (bytes =3D 0; bytes < key_len; bytes +=3D hash->u) {
+		uint8_t b[hash->v];
+		uint8_t *input =3D di;
+		unsigned int input_len =3D hash->v + s_len + p_len;
+
+		for (j =3D 0; j < iterations; j++) {
+			if (!l_checksum_update(h, input, input_len) ||
+					l_checksum_get_digest(h,
+							key + bytes,
+							hash->len) <=3D 0) {
+				l_checksum_free(h);
+				l_free(key);
+				return NULL;
+			}
+
+			input =3D key + bytes;
+			input_len =3D hash->u;
+			l_checksum_reset(h);
+		}
+
+		if (bytes + hash->u >=3D key_len)
+			break;
+
+		for (j =3D 0; j < hash->v - hash->u; j +=3D hash->u)
+			memcpy(b + j, input, hash->u);
+
+		memcpy(b + j, input, hash->v - j);
+
+		ptr =3D di + hash->v;
+		for (j =3D 0; j < s_len + p_len; j +=3D hash->v, ptr +=3D hash->v) {
+			unsigned int k;
+			uint16_t carry =3D 1;
+
+			/*
+			 * Not specified in the RFC7292 but implementations
+			 * sum these octet strings as big-endian integers.
+			 * We could use 64-bit additions here but the benefit
+			 * may not compensate the cost of the byteswapping.
+			 */
+			for (k =3D hash->v - 1; k > 0; k--) {
+				carry =3D ptr[k] + b[k] + carry;
+				ptr[k] =3D carry;
+				carry >>=3D 8;
+			}
+
+			ptr[k] +=3D b[k] + carry;
+			explicit_bzero(&carry, sizeof(carry));
+		}
+
+		explicit_bzero(b, sizeof(b));
+	}
+
+	explicit_bzero(di, sizeof(di));
+	l_checksum_free(h);
+	return key;
+}
+
+/* RFC7292 Appendix A */
+static const struct pkcs12_hash pkcs12_sha1_hash =3D {
+	.alg =3D L_CHECKSUM_SHA1,
+	.len =3D 20,
+	.u   =3D 20,
+	.v   =3D 64,
+	.oid =3D { 5, { 0x2b, 0x0e, 0x03, 0x02, 0x1a } },
+};
+
+/* RFC8018 Section A.2 */
 static struct asn1_oid pkcs5_pbkdf2_oid =3D {
 	9, { 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x05, 0x0c }
 };
 =

+/* RFC8018 Section A.4 */
 static struct asn1_oid pkcs5_pbes2_oid =3D {
 	9, { 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x05, 0x0d }
 };
 =

+/* RFC8018 Section A.3 */
 static const struct pkcs5_pbes1_encryption_oid {
 	enum l_checksum_type checksum_type;
 	enum l_cipher_type cipher_type;
-- =

2.27.0

--===============2296464817086107558==--

