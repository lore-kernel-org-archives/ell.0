Content-Type: multipart/mixed; boundary="===============5907801784759872940=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 06/10][RFC] cipher: Implement PKCS#5 key derivation functions
Date: Fri, 11 Aug 2017 01:10:12 +0200
Message-ID: <20170810231016.29445-6-andrew.zaborowski@intel.com>
In-Reply-To: <20170810231016.29445-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5907801784759872940==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Implement the PBKDF1 and PBKDF2 functions from PKCS#4 - RFC8018.  This
is for now placed in cipher.c as a dependency for the
l_cipher_from_pkcs5_id patch but probably better fits in a separate file
called pkcs5.c or something else.

Note iwd already has a PBKDF2 implementation and unit tests, it can be
switched to use this ell version and the unit tests moved to ell.
---
 ell/cipher.c | 127 +++++++++++++++++++++++++++++++++++++++++++++++++++++++=
++++
 1 file changed, 127 insertions(+)

diff --git a/ell/cipher.c b/ell/cipher.c
index e51f6e7..8e60d61 100644
--- a/ell/cipher.c
+++ b/ell/cipher.c
@@ -34,6 +34,7 @@
 #include "cipher.h"
 #include "private.h"
 #include "random.h"
+#include "checksum.h"
 =

 #ifndef HAVE_LINUX_IF_ALG_H
 #ifndef HAVE_LINUX_TYPES_H
@@ -632,3 +633,129 @@ bool l_aead_cipher_is_supported(enum l_aead_cipher_ty=
pe type)
 =

 	return supported_aead_ciphers & (1 << type);
 }
+
+/* RFC8018 section 5.1 */
+static bool pkcs5_pbkdf1(enum l_checksum_type type, const char *password,
+				const uint8_t *salt, size_t salt_len,
+				unsigned int iter_count,
+				size_t dk_len, uint8_t *out_dk)
+{
+	size_t hash_len, t_len;
+	uint8_t t[20 + salt_len + strlen(password)];
+	struct l_checksum *checksum;
+
+	switch (type) {
+	case L_CHECKSUM_MD5:
+		hash_len =3D 16;
+		break;
+	case L_CHECKSUM_SHA1:
+		hash_len =3D 20;
+		break;
+	default:
+		return false;
+	}
+
+	if (dk_len > hash_len)
+		return false;
+
+	checksum =3D l_checksum_new(type);
+	if (!checksum)
+		return false;
+
+	memcpy(t, password, strlen(password));
+	memcpy(t + strlen(password), salt, salt_len);
+	t_len =3D strlen(password) + salt_len;
+
+	while (iter_count) {
+		l_checksum_reset(checksum);
+		if (!l_checksum_update(checksum, t, t_len))
+			break;
+		if (l_checksum_get_digest(checksum, t, hash_len) !=3D
+				(ssize_t) hash_len)
+			break;
+		t_len =3D hash_len;
+
+		iter_count--;
+	}
+
+	l_checksum_free(checksum);
+
+	if (iter_count)
+		return false;
+
+	memcpy(out_dk, t, dk_len);
+	return true;
+}
+
+/* RFC8018 section 5.2 */
+static bool pkcs5_pbkdf2(enum l_checksum_type type, const char *password,
+				const uint8_t *salt, size_t salt_len,
+				unsigned int iter_count,
+				size_t dk_len, uint8_t *out_dk)
+{
+	size_t h_len;
+	struct l_checksum *checksum;
+	unsigned int i;
+
+	switch (type) {
+	case L_CHECKSUM_SHA1:
+		h_len =3D 20;
+		break;
+	case L_CHECKSUM_SHA224:
+		h_len =3D 28;
+		break;
+	case L_CHECKSUM_SHA256:
+		h_len =3D 32;
+		break;
+	case L_CHECKSUM_SHA384:
+		h_len =3D 48;
+		break;
+	case L_CHECKSUM_SHA512:
+		h_len =3D 64;
+		break;
+	default:
+		return false;
+	}
+
+	checksum =3D l_checksum_new_hmac(type, password, strlen(password));
+	if (!checksum)
+		return false;
+
+	for (i =3D 1; dk_len; i++) {
+		unsigned int j, k;
+		uint8_t u[salt_len + 64];
+		size_t u_len;
+		size_t block_len =3D h_len;
+
+		if (block_len > dk_len)
+			block_len =3D dk_len;
+
+		memset(out_dk, 0, block_len);
+
+		memcpy(u, salt, salt_len);
+		l_put_be32(i, u + salt_len);
+		u_len =3D salt_len + 4;
+
+		for (j =3D 0; j < iter_count; j++) {
+			l_checksum_reset(checksum);
+			if (!l_checksum_update(checksum, u, u_len))
+				break;
+			if (l_checksum_get_digest(checksum, u, h_len) !=3D
+					(ssize_t) h_len)
+				break;
+			u_len =3D h_len;
+
+			for (k =3D 0; k < block_len; k++)
+				out_dk[k] ^=3D u[k];
+		}
+		if (j < iter_count)
+			break;
+
+		out_dk +=3D block_len;
+		dk_len -=3D block_len;
+	}
+
+	l_checksum_free(checksum);
+
+	return !dk_len;
+}
-- =

2.11.0


--===============5907801784759872940==--

