Content-Type: multipart/mixed; boundary="===============4341727652634566861=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 04/13] cipher: Add ARC4 implementation
Date: Thu, 10 Dec 2020 20:31:57 +0100
Message-ID: <20201210193202.526451-4-andrew.zaborowski@intel.com>
In-Reply-To: <20201210193202.526451-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4341727652634566861==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Re-add the L_CIPHER_ARC4 stream cipher for use in decoding PKCS#12
files.  Like RC2 it's implemented completely in cipher.c because the
kernel API doesn't support it.  This cipher is also discouraged where it
can be avoided.
---
 ell/cipher.c | 98 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 ell/cipher.h |  4 +--
 2 files changed, 100 insertions(+), 2 deletions(-)

diff --git a/ell/cipher.c b/ell/cipher.c
index a2db608..5d67d7a 100644
--- a/ell/cipher.c
+++ b/ell/cipher.c
@@ -162,6 +162,8 @@ static const char *cipher_type_to_name(enum l_cipher_ty=
pe type)
 		return "cbc(aes)";
 	case L_CIPHER_AES_CTR:
 		return "ctr(aes)";
+	case L_CIPHER_ARC4:
+		return NULL;
 	case L_CIPHER_DES:
 		return "ecb(des)";
 	case L_CIPHER_DES_CBC:
@@ -175,9 +177,11 @@ static const char *cipher_type_to_name(enum l_cipher_t=
ype type)
 	return NULL;
 }
 =

+static const struct local_impl local_arc4;
 static const struct local_impl local_rc2_cbc;
 =

 static const struct local_impl *local_impl_ciphers[] =3D {
+	[L_CIPHER_ARC4] =3D &local_arc4,
 	[L_CIPHER_RC2_CBC] =3D &local_rc2_cbc,
 };
 =

@@ -729,6 +733,100 @@ LIB_EXPORT bool l_aead_cipher_is_supported(enum l_aea=
d_cipher_type type)
 	return supported_aead_ciphers & (1 << type);
 }
 =

+/* ARC4 implementation copyright (c) 2001 Niels M=C3=B6ller */
+
+#define SWAP(a, b) do { uint8_t _t =3D a; a =3D b; b =3D _t; } while (0)
+
+static void arc4_set_key(uint8_t *S, const uint8_t *key, size_t key_length)
+{
+	unsigned int i;
+	uint8_t j;
+
+	for (i =3D 0; i < 256; i++)
+		S[i] =3D i;
+
+	for (i =3D j =3D 0; i < 256; i++) {
+		j +=3D S[i] + key[i % key_length];
+		SWAP(S[i], S[j]);
+	}
+}
+
+struct arc4_state {
+	struct arc4_state_ctx {
+		uint8_t S[256];
+		uint8_t i;
+		uint8_t j;
+	} ctx[2];
+};
+
+static void *local_arc4_new(enum l_cipher_type type,
+				const void *key, size_t key_length)
+{
+	struct arc4_state *s;
+
+	if (unlikely(key_length =3D=3D 0 || key_length > 256))
+		return NULL;
+
+	s =3D l_new(struct arc4_state, 1);
+	arc4_set_key(s->ctx[0].S, key, key_length);
+	s->ctx[1] =3D s->ctx[0];
+	return s;
+}
+
+static void local_arc4_free(void *data)
+{
+	explicit_bzero(data, sizeof(struct arc4_state));
+	l_free(data);
+}
+
+static ssize_t local_arc4_operate(void *data, __u32 operation,
+					const struct iovec *in, size_t in_cnt,
+					const struct iovec *out, size_t out_cnt)
+{
+	struct arc4_state *s =3D data;
+	struct iovec cur_in;
+	struct iovec cur_out;
+	struct arc4_state_ctx *ctx =3D
+		&s->ctx[operation =3D=3D ALG_OP_ENCRYPT ? 1 : 0];
+
+	if (!in_cnt || !out_cnt)
+		return 0;
+
+	cur_in =3D *in;
+	cur_out =3D *out;
+
+	while (1) {
+		while (!cur_in.iov_len) {
+			cur_in =3D *in++;
+
+			if (!--in_cnt)
+				return 0;
+		}
+
+		while (!cur_out.iov_len) {
+			cur_out =3D *out++;
+
+			if (!--out_cnt)
+				return 0;
+		}
+
+		ctx->j +=3D ctx->S[++ctx->i];
+		SWAP(ctx->S[ctx->i], ctx->S[ctx->j]);
+		*(uint8_t *) cur_out.iov_base++ =3D
+			*(uint8_t *) cur_in.iov_base++ ^
+			ctx->S[(ctx->S[ctx->i] + ctx->S[ctx->j]) & 0xff];
+		cur_in.iov_len--;
+		cur_out.iov_len--;
+	}
+}
+
+static const struct local_impl local_arc4 =3D {
+	local_arc4_new,
+	local_arc4_free,
+	NULL,
+	local_arc4_operate,
+};
+
 struct rc2_state {
 	union {
 		uint16_t xkey[64];
diff --git a/ell/cipher.h b/ell/cipher.h
index ed277a6..f4c31fa 100644
--- a/ell/cipher.h
+++ b/ell/cipher.h
@@ -33,8 +33,8 @@ enum l_cipher_type {
 	L_CIPHER_AES =3D 0,
 	L_CIPHER_AES_CBC,
 	L_CIPHER_AES_CTR,
-	/* L_CIPHER_ARC4, */
-	L_CIPHER_DES =3D 4,
+	L_CIPHER_ARC4,
+	L_CIPHER_DES,
 	L_CIPHER_DES_CBC,
 	L_CIPHER_DES3_EDE_CBC,
 	L_CIPHER_RC2_CBC,
-- =

2.27.0

--===============4341727652634566861==--

