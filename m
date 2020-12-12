Content-Type: multipart/mixed; boundary="===============7346357050498047508=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/5] pkcs5: Add the PKCS#12 KDF
Date: Sat, 12 Dec 2020 01:50:56 +0100
Message-ID: <20201212005100.578174-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7346357050498047508==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add the key derivation algorithm used with PKCS#12 to pkcs5.c so that it
can be found together with the two PKCS#5 KDFs, and so that it can also
be used when parsing of the PKCS#12 AlgorithmIdentifiers in the next
commit.  This KDF is not recommended for new uses.
---
 ell/pkcs5-private.h |  12 +++++
 ell/pkcs5.c         | 121 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 133 insertions(+)

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
index 21fda2b..979cebe 100644
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
@@ -182,14 +183,134 @@ LIB_EXPORT bool l_pkcs5_pbkdf2(enum l_checksum_type =
type, const char *password,
 	return !dk_len;
 }
 =

+/* RFC7292 Appendix B */
+uint8_t *pkcs12_pbkdf(const char *password, const struct pkcs12_hash *hash,
+			const uint8_t *salt, size_t salt_len,
+			unsigned int iterations, uint8_t id, size_t key_len)
+{
+	/* All lengths in bytes instead of bits */
+	size_t passwd_len =3D password ? 2 * strlen(password) + 2 : 0;
+	uint8_t *bmpstring;
+	/* Documented as v(ceiling(s/v)), usually will just equal v */
+	unsigned int s_len =3D (salt_len + hash->v - 1) & ~(hash->v - 1);
+	/* Documented as p(ceiling(s/p)), usually will just equal v */
+	unsigned int p_len =3D (passwd_len + hash->v - 1) & ~(hash->v - 1);
+	uint8_t di[hash->v + s_len + p_len];
+	uint8_t *ptr;
+	unsigned int j;
+	uint8_t *key;
+	unsigned int bytes;
+	struct l_checksum *h =3D l_checksum_new(hash->alg);
+
+	if (!h)
+		return NULL;
+
+	/*
+	 * The BMPString encoding, in practice same as UCS-2, can end up
+	 * at 2 * strlen(password) + 2 bytes or shorter depending on the
+	 * characters used.  Recalculate p_len after we know it.
+	 * Important: The password must be valid UTF-8 here.
+	 */
+	if (password) {
+		if (!(bmpstring =3D l_utf8_to_ucs2be(password, &passwd_len))) {
+			l_checksum_free(h);
+			return NULL;
+		}
+
+		p_len =3D (passwd_len + hash->v - 1) & ~(hash->v - 1);
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
+	if (p_len) {
+		memcpy(ptr, bmpstring, p_len + passwd_len - j);
+
+		explicit_bzero(bmpstring, passwd_len);
+		l_free(bmpstring);
+	}
+
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

--===============7346357050498047508==--

