Content-Type: multipart/mixed; boundary="===============4527440460026417791=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 03/13] cipher: Add an RC2 implementation
Date: Thu, 10 Dec 2020 20:31:56 +0100
Message-ID: <20201210193202.526451-3-andrew.zaborowski@intel.com>
In-Reply-To: <20201210193202.526451-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4527440460026417791==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

RC2 is still used by default by tools creating PKCS#12 files (.pfx /
.p12).  Since it's not available from the kernel crypto API, add a local
implementation.  This is currently the only cipher implemented locally
so checks are needed in all our l_cipher ops to see whether a cipher is
handled locally or by the kernel.

Adding this cipher is not a recommendation of using it, it's discouraged
where it can be avoided.
---
 ell/cipher.c | 365 ++++++++++++++++++++++++++++++++++++++++++++++++++-
 ell/cipher.h |   1 +
 2 files changed, 363 insertions(+), 3 deletions(-)

diff --git a/ell/cipher.c b/ell/cipher.c
index 6aec42f..a2db608 100644
--- a/ell/cipher.c
+++ b/ell/cipher.c
@@ -86,14 +86,18 @@ struct af_alg_iv {
 #define ALG_SET_AEAD_AUTHSIZE	5
 #endif
 =

-#define is_valid_type(type)  ((type) <=3D L_CIPHER_DES3_EDE_CBC)
+#define is_valid_type(type)  ((type) <=3D L_CIPHER_RC2_CBC)
 =

 static uint32_t supported_ciphers;
 static uint32_t supported_aead_ciphers;
 =

 struct l_cipher {
 	int type;
-	int sk;
+	const struct local_impl *local;
+	union {
+		int sk;
+		void *local_data;
+	};
 };
 =

 struct l_aead_cipher {
@@ -101,6 +105,16 @@ struct l_aead_cipher {
 	int sk;
 };
 =

+struct local_impl {
+	void *(*cipher_new)(enum l_cipher_type,
+				const void *key, size_t key_length);
+	void (*cipher_free)(void *data);
+	bool (*set_iv)(void *data, const uint8_t *iv, size_t iv_length);
+	ssize_t (*operate)(void *data, __u32 operation,
+				const struct iovec *in, size_t in_cnt,
+				const struct iovec *out, size_t out_cnt);
+};
+
 static int create_alg(const char *alg_type, const char *alg_name,
 			const void *key, size_t key_length, size_t tag_length)
 {
@@ -154,11 +168,23 @@ static const char *cipher_type_to_name(enum l_cipher_=
type type)
 		return "cbc(des)";
 	case L_CIPHER_DES3_EDE_CBC:
 		return "cbc(des3_ede)";
+	case L_CIPHER_RC2_CBC:
+		return NULL;
 	}
 =

 	return NULL;
 }
 =

+static const struct local_impl local_rc2_cbc;
+
+static const struct local_impl *local_impl_ciphers[] =3D {
+	[L_CIPHER_RC2_CBC] =3D &local_rc2_cbc,
+};
+
+#define HAVE_LOCAL_IMPLEMENTATION(type)			\
+	((type) < L_ARRAY_SIZE(local_impl_ciphers) &&	\
+	 local_impl_ciphers[(type)])
+
 LIB_EXPORT struct l_cipher *l_cipher_new(enum l_cipher_type type,
 						const void *key,
 						size_t key_length)
@@ -176,6 +202,17 @@ LIB_EXPORT struct l_cipher *l_cipher_new(enum l_cipher=
_type type,
 	cipher->type =3D type;
 	alg_name =3D cipher_type_to_name(type);
 =

+	if (HAVE_LOCAL_IMPLEMENTATION(type)) {
+		cipher->local =3D local_impl_ciphers[type];
+		cipher->local_data =3D cipher->local->cipher_new(type,
+							key, key_length);
+
+		if (!cipher->local_data)
+			goto error_free;
+
+		return cipher;
+	}
+
 	cipher->sk =3D create_alg("skcipher", alg_name, key, key_length, 0);
 	if (cipher->sk < 0)
 		goto error_free;
@@ -230,7 +267,10 @@ LIB_EXPORT void l_cipher_free(struct l_cipher *cipher)
 	if (unlikely(!cipher))
 		return;
 =

-	close(cipher->sk);
+	if (cipher->local)
+		cipher->local->cipher_free(cipher->local_data);
+	else
+		close(cipher->sk);
 =

 	l_free(cipher);
 }
@@ -403,6 +443,15 @@ LIB_EXPORT bool l_cipher_encrypt(struct l_cipher *ciph=
er,
 	if (unlikely(!in) || unlikely(!out))
 		return false;
 =

+	if (cipher->local) {
+		struct iovec in_iov =3D { (void *) in, len };
+		struct iovec out_iov =3D { out, len };
+
+		return cipher->local->operate(cipher->local_data,
+						ALG_OP_ENCRYPT,
+						&in_iov, 1, &out_iov, 1) >=3D 0;
+	}
+
 	return operate_cipher(cipher->sk, ALG_OP_ENCRYPT, in, len,
 				NULL, 0, NULL, 0, out, len) >=3D 0;
 }
@@ -417,6 +466,11 @@ LIB_EXPORT bool l_cipher_encryptv(struct l_cipher *cip=
her,
 	if (unlikely(!in) || unlikely(!out))
 		return false;
 =

+	if (cipher->local)
+		return cipher->local->operate(cipher->local_data,
+						ALG_OP_ENCRYPT,
+						in, in_cnt, out, out_cnt) >=3D 0;
+
 	return operate_cipherv(cipher->sk, ALG_OP_ENCRYPT, in, in_cnt,
 				out, out_cnt) >=3D 0;
 }
@@ -430,6 +484,15 @@ LIB_EXPORT bool l_cipher_decrypt(struct l_cipher *ciph=
er,
 	if (unlikely(!in) || unlikely(!out))
 		return false;
 =

+	if (cipher->local) {
+		struct iovec in_iov =3D { (void *) in, len };
+		struct iovec out_iov =3D { out, len };
+
+		return cipher->local->operate(cipher->local_data,
+						ALG_OP_DECRYPT,
+						&in_iov, 1, &out_iov, 1) >=3D 0;
+	}
+
 	return operate_cipher(cipher->sk, ALG_OP_DECRYPT, in, len,
 				NULL, 0, NULL, 0, out, len) >=3D 0;
 }
@@ -444,6 +507,11 @@ LIB_EXPORT bool l_cipher_decryptv(struct l_cipher *cip=
her,
 	if (unlikely(!in) || unlikely(!out))
 		return false;
 =

+	if (cipher->local)
+		return cipher->local->operate(cipher->local_data,
+						ALG_OP_DECRYPT,
+						in, in_cnt, out, out_cnt) >=3D 0;
+
 	return operate_cipherv(cipher->sk, ALG_OP_DECRYPT, in, in_cnt,
 				out, out_cnt) >=3D 0;
 }
@@ -459,6 +527,13 @@ LIB_EXPORT bool l_cipher_set_iv(struct l_cipher *ciphe=
r, const uint8_t *iv,
 	if (unlikely(!cipher))
 		return false;
 =

+	if (cipher->local) {
+		if (!cipher->local->set_iv)
+			return false;
+
+		return cipher->local->set_iv(cipher->local_data, iv, iv_length);
+	}
+
 	memset(&c_msg_buf, 0, sizeof(c_msg_buf));
 	memset(&msg, 0, sizeof(struct msghdr));
 =

@@ -616,6 +691,10 @@ static void init_supported()
 		supported_ciphers |=3D 1 << c;
 	}
 =

+	for (c =3D 0; c < L_ARRAY_SIZE(local_impl_ciphers); c++)
+		if (HAVE_LOCAL_IMPLEMENTATION(c))
+			supported_ciphers |=3D 1 << c;
+
 	strcpy((char *) salg.salg_type, "aead");
 =

 	for (a =3D L_AEAD_CIPHER_AES_CCM; a <=3D L_AEAD_CIPHER_AES_GCM; a++) {
@@ -649,3 +728,283 @@ LIB_EXPORT bool l_aead_cipher_is_supported(enum l_aea=
d_cipher_type type)
 =

 	return supported_aead_ciphers & (1 << type);
 }
+
+struct rc2_state {
+	union {
+		uint16_t xkey[64];
+		uint8_t xkey8[128];
+	};
+	struct rc2_state_ctx {
+		union {
+			uint16_t x[4];
+			uint64_t x64;
+		};
+	} ctx[2];
+};
+
+/* Simplified from the 1996 public-domain implementation */
+static void rc2_keyschedule(struct rc2_state *s,
+				const uint8_t *key, size_t key_len,
+				size_t bits)
+{
+	static const uint8_t permute[256] =3D {
+		217,120,249,196, 25,221,181,237, 40,233,253,121, 74,160,216,157,
+		198,126, 55,131, 43,118, 83,142, 98, 76,100,136, 68,139,251,162,
+		 23,154, 89,245,135,179, 79, 19, 97, 69,109,141,  9,129,125, 50,
+		189,143, 64,235,134,183,123, 11,240,149, 33, 34, 92,107, 78,130,
+		 84,214,101,147,206, 96,178, 28,115, 86,192, 20,167,140,241,220,
+		 18,117,202, 31, 59,190,228,209, 66, 61,212, 48,163, 60,182, 38,
+		111,191, 14,218, 70,105,  7, 87, 39,242, 29,155,188,148, 67,  3,
+		248, 17,199,246,144,239, 62,231,  6,195,213, 47,200,102, 30,215,
+		  8,232,234,222,128, 82,238,247,132,170,114,172, 53, 77,106, 42,
+		150, 26,210,113, 90, 21, 73,116, 75,159,208, 94,  4, 24,164,236,
+		194,224, 65,110, 15, 81,203,204, 36,145,175, 80,161,244,112, 57,
+		153,124, 58,133, 35,184,180,122,252,  2, 54, 91, 37, 85,151, 49,
+		 45, 93,250,152,227,138,146,174,  5,223, 41, 16,103,108,186,201,
+		211,  0,230,207,225,158,168, 44, 99, 22,  1, 63, 88,226,137,169,
+		 13, 56, 52, 27,171, 51,255,176,187, 72, 12, 95,185,177,205, 46,
+		197,243,219, 71,229,165,156,119, 10,166, 32,104,254,127,193,173
+	};
+	uint8_t x;
+	unsigned int i;
+
+	memcpy(&s->xkey8, key, key_len);
+
+	/* Step 1: expand input key to 128 bytes */
+	x =3D s->xkey8[key_len - 1];
+
+	for (i =3D 0; key_len < 128; key_len++, i++)
+		s->xkey8[key_len] =3D x =3D permute[(x + s->xkey8[i]) & 255];
+
+	/* Step 2: reduce effective key size to "bits" */
+	key_len =3D (bits + 7) >> 3;
+	i =3D 128 - key_len;
+	s->xkey8[i] =3D x =3D permute[s->xkey8[i] & (255 >> (7 & -bits))];
+
+	while (i--)
+		s->xkey8[i] =3D x =3D permute[x ^ s->xkey8[i + key_len]];
+
+	/* Step 3: copy to xkey in little-endian order */
+	for (i =3D 0; i < 64; i++)
+		s->xkey[i] =3D L_CPU_TO_LE16(s->xkey[i]);
+}
+
+static uint64_t rc2_operate(struct rc2_state *s, uint64_t in, __u32 operat=
ion)
+{
+	int i;
+	union {
+		uint16_t x16[4];
+		uint64_t x64;
+	} x;
+
+	x.x64 =3D in;
+
+	if (operation =3D=3D ALG_OP_ENCRYPT) {
+		const uint16_t *xkey =3D s->xkey;
+
+		for (i =3D 0; i < 16; i++) {
+			x.x16[0] +=3D (x.x16[1] & ~x.x16[3]) +
+				(x.x16[2] & x.x16[3]) + *xkey++;
+			x.x16[0] =3D (x.x16[0] << 1) | (x.x16[0] >> 15);
+			x.x16[1] +=3D (x.x16[2] & ~x.x16[0]) +
+				(x.x16[3] & x.x16[0]) + *xkey++;
+			x.x16[1] =3D (x.x16[1] << 2) | (x.x16[1] >> 14);
+			x.x16[2] +=3D (x.x16[3] & ~x.x16[1]) +
+				(x.x16[0] & x.x16[1]) + *xkey++;
+			x.x16[2] =3D (x.x16[2] << 3) | (x.x16[2] >> 13);
+			x.x16[3] +=3D (x.x16[0] & ~x.x16[2]) +
+				(x.x16[1] & x.x16[2]) + *xkey++;
+			x.x16[3] =3D (x.x16[3] << 5) | (x.x16[3] >> 11);
+
+			if (i =3D=3D 4 || i =3D=3D 10) {
+				x.x16[0] +=3D s->xkey[x.x16[3] & 63];
+				x.x16[1] +=3D s->xkey[x.x16[0] & 63];
+				x.x16[2] +=3D s->xkey[x.x16[1] & 63];
+				x.x16[3] +=3D s->xkey[x.x16[2] & 63];
+			}
+		}
+	} else {
+		const uint16_t *xkey =3D s->xkey + 63;
+
+		for (i =3D 0; i < 16; i++) {
+			x.x16[3] =3D (x.x16[3] << 11) | (x.x16[3] >> 5);
+			x.x16[3] -=3D (x.x16[0] & ~x.x16[2]) +
+				(x.x16[1] & x.x16[2]) + *xkey--;
+			x.x16[2] =3D (x.x16[2] << 13) | (x.x16[2] >> 3);
+			x.x16[2] -=3D (x.x16[3] & ~x.x16[1]) +
+				(x.x16[0] & x.x16[1]) + *xkey--;
+			x.x16[1] =3D (x.x16[1] << 14) | (x.x16[1] >> 2);
+			x.x16[1] -=3D (x.x16[2] & ~x.x16[0]) +
+				(x.x16[3] & x.x16[0]) + *xkey--;
+			x.x16[0] =3D (x.x16[0] << 15) | (x.x16[0] >> 1);
+			x.x16[0] -=3D (x.x16[1] & ~x.x16[3]) +
+				(x.x16[2] & x.x16[3]) + *xkey--;
+
+			if (i =3D=3D 4 || i =3D=3D 10) {
+				x.x16[3] -=3D s->xkey[x.x16[2] & 63];
+				x.x16[2] -=3D s->xkey[x.x16[1] & 63];
+				x.x16[1] -=3D s->xkey[x.x16[0] & 63];
+				x.x16[0] -=3D s->xkey[x.x16[3] & 63];
+			}
+		}
+	}
+
+	return x.x64;
+}
+
+static void *local_rc2_cbc_new(enum l_cipher_type type,
+				const void *key, size_t key_length)
+{
+	struct rc2_state *s;
+
+	if (unlikely(key_length =3D=3D 0 || key_length > 128))
+		return NULL;
+
+	/*
+	 * The key length and the effective "strength" bits are separate
+	 * parameters but they match in our current use cases.
+	 */
+	s =3D l_new(struct rc2_state, 1);
+	rc2_keyschedule(s, key, key_length, key_length * 8);
+	return s;
+}
+
+static void local_rc2_cbc_free(void *data)
+{
+	explicit_bzero(data, sizeof(struct rc2_state));
+	l_free(data);
+}
+
+static bool local_rc2_cbc_set_iv(void *data,
+				const uint8_t *iv, size_t iv_length)
+{
+	struct rc2_state *s =3D data;
+
+	if (unlikely(iv_length !=3D 8))
+		return false;
+
+	s->ctx[0].x[0] =3D l_get_le16(iv + 0);
+	s->ctx[0].x[1] =3D l_get_le16(iv + 2);
+	s->ctx[0].x[2] =3D l_get_le16(iv + 4);
+	s->ctx[0].x[3] =3D l_get_le16(iv + 6);
+	s->ctx[1].x64 =3D s->ctx[0].x64;
+	return true;
+}
+
+static ssize_t local_rc2_cbc_operate(void *data, __u32 operation,
+					const struct iovec *in, size_t in_cnt,
+					const struct iovec *out, size_t out_cnt)
+{
+	struct rc2_state *s =3D data;
+	struct iovec cur_in =3D {};
+	struct iovec cur_out =3D {};
+	struct rc2_state_ctx *ctx =3D
+		&s->ctx[operation =3D=3D ALG_OP_ENCRYPT ? 1 : 0];
+
+#define CONSUME_IN(bytes, eof_ok)		\
+	cur_in.iov_len -=3D (bytes);		\
+	while (!cur_in.iov_len) {		\
+		if (!in_cnt) {			\
+			if (eof_ok)		\
+				break;		\
+			else			\
+				return -1;	\
+		}				\
+						\
+		cur_in =3D *in++;			\
+		in_cnt--;			\
+	}
+
+#define CONSUME_OUT(bytes)			\
+	cur_out.iov_len -=3D (bytes);		\
+	while (!cur_out.iov_len) {		\
+		if (!out_cnt)			\
+			return 0;		\
+						\
+		cur_out =3D *out++;		\
+		out_cnt--;			\
+	}
+
+	CONSUME_IN(0, true)
+	CONSUME_OUT(0)
+
+	while (cur_in.iov_len) {
+		union {
+			uint16_t x16[4];
+			uint64_t x64;
+		} inblk;
+
+		if (cur_in.iov_len >=3D 8) {
+#define CUR_IN16 (*(uint16_t **) &cur_in.iov_base)
+			inblk.x16[0] =3D l_get_le16(CUR_IN16++);
+			inblk.x16[1] =3D l_get_le16(CUR_IN16++);
+			inblk.x16[2] =3D l_get_le16(CUR_IN16++);
+			inblk.x16[3] =3D l_get_le16(CUR_IN16++);
+			CONSUME_IN(8, true)
+		} else {
+			inblk.x16[0] =3D *(uint8_t *) cur_in.iov_base++;
+			CONSUME_IN(1, false)
+			inblk.x16[0] |=3D (*(uint8_t *) cur_in.iov_base++) << 8;
+			CONSUME_IN(1, false)
+			inblk.x16[1] =3D *(uint8_t *) cur_in.iov_base++;
+			CONSUME_IN(1, false)
+			inblk.x16[1] |=3D (*(uint8_t *) cur_in.iov_base++) << 8;
+			CONSUME_IN(1, false)
+			inblk.x16[2] =3D *(uint8_t *) cur_in.iov_base++;
+			CONSUME_IN(1, false)
+			inblk.x16[2] |=3D (*(uint8_t *) cur_in.iov_base++) << 8;
+			CONSUME_IN(1, false)
+			inblk.x16[3] =3D *(uint8_t *) cur_in.iov_base++;
+			CONSUME_IN(1, false)
+			inblk.x16[3] |=3D (*(uint8_t *) cur_in.iov_base++) << 8;
+			CONSUME_IN(1, true)
+		}
+
+		if (operation =3D=3D ALG_OP_ENCRYPT)
+			ctx->x64 =3D rc2_operate(s, inblk.x64 ^ ctx->x64,
+						operation);
+		else
+			ctx->x64 ^=3D rc2_operate(s, inblk.x64, operation);
+
+		if (cur_out.iov_len >=3D 8) {
+#define CUR_OUT16 (*(uint16_t **) &cur_out.iov_base)
+			l_put_le16(ctx->x[0], CUR_OUT16++);
+			l_put_le16(ctx->x[1], CUR_OUT16++);
+			l_put_le16(ctx->x[2], CUR_OUT16++);
+			l_put_le16(ctx->x[3], CUR_OUT16++);
+			CONSUME_OUT(8)
+		} else {
+			*(uint8_t *) cur_out.iov_base++ =3D ctx->x[0];
+			CONSUME_OUT(1)
+			*(uint8_t *) cur_out.iov_base++ =3D ctx->x[0] >> 8;
+			CONSUME_OUT(1)
+			*(uint8_t *) cur_out.iov_base++ =3D ctx->x[1];
+			CONSUME_OUT(1)
+			*(uint8_t *) cur_out.iov_base++ =3D ctx->x[1] >> 8;
+			CONSUME_OUT(1)
+			*(uint8_t *) cur_out.iov_base++ =3D ctx->x[2];
+			CONSUME_OUT(1)
+			*(uint8_t *) cur_out.iov_base++ =3D ctx->x[2] >> 8;
+			CONSUME_OUT(1)
+			*(uint8_t *) cur_out.iov_base++ =3D ctx->x[3];
+			CONSUME_OUT(1)
+			*(uint8_t *) cur_out.iov_base++ =3D ctx->x[3] >> 8;
+			CONSUME_OUT(1)
+		}
+
+		/* Save ciphertext as IV for next CBC block */
+		if (operation =3D=3D ALG_OP_DECRYPT)
+			ctx->x64 =3D inblk.x64;
+
+		inblk.x64 =3D 0;
+	}
+
+	return 0;
+}
+
+static const struct local_impl local_rc2_cbc =3D {
+	local_rc2_cbc_new,
+	local_rc2_cbc_free,
+	local_rc2_cbc_set_iv,
+	local_rc2_cbc_operate,
+};
diff --git a/ell/cipher.h b/ell/cipher.h
index e1a4bda..ed277a6 100644
--- a/ell/cipher.h
+++ b/ell/cipher.h
@@ -37,6 +37,7 @@ enum l_cipher_type {
 	L_CIPHER_DES =3D 4,
 	L_CIPHER_DES_CBC,
 	L_CIPHER_DES3_EDE_CBC,
+	L_CIPHER_RC2_CBC,
 };
 =

 struct l_cipher *l_cipher_new(enum l_cipher_type type,
-- =

2.27.0

--===============4527440460026417791==--

