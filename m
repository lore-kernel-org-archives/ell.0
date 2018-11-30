Content-Type: multipart/mixed; boundary="===============1426526975166742194=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/6] tls: Drop local code to add hash OID, let kernel do it
Date: Fri, 30 Nov 2018 13:05:45 +0100
Message-ID: <20181130120550.8866-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1426526975166742194==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Drop tls.c code to build the PKCS#1 DigestInfo structure which basically
consisted of prepending the signature hash algorithm's OID to the hash.
Let the key API do it by setting the hash type in the l_key_sign and
l_key_verify calls.  Slightly simplify the tls_rsa_sign and
tls_rsa_verify code while doing this.
---
 ell/tls.c | 169 ++++++++++++++++++------------------------------------
 1 file changed, 56 insertions(+), 113 deletions(-)

diff --git a/ell/tls.c b/ell/tls.c
index 018eb39..73a378c 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -744,65 +744,6 @@ static const char *tls_handshake_type_to_str(enum tls_=
handshake_type type)
 	return buf;
 }
 =

-static const uint8_t pkcs1_digest_info_md5_start[] =3D {
-	0x30, 0x20, 0x30, 0x0c, 0x06, 0x08, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d,
-	0x02, 0x05, 0x05, 0x00, 0x04, 0x10,
-};
-static const uint8_t pkcs1_digest_info_sha1_start[] =3D {
-	0x30, 0x21, 0x30, 0x09, 0x06, 0x05, 0x2b, 0x0e, 0x03, 0x02, 0x1a, 0x05,
-	0x00, 0x04, 0x14,
-};
-static const uint8_t pkcs1_digest_info_sha256_start[] =3D {
-	0x30, 0x31, 0x30, 0x0d, 0x06, 0x09, 0x60, 0x86, 0x48, 0x01, 0x65, 0x03,
-	0x04, 0x02, 0x01, 0x05, 0x00, 0x04, 0x20,
-};
-static const uint8_t pkcs1_digest_info_sha384_start[] =3D {
-	0x30, 0x41, 0x30, 0x0d, 0x06, 0x09, 0x60, 0x86, 0x48, 0x01, 0x65, 0x03,
-	0x04, 0x02, 0x02, 0x05, 0x00, 0x04, 0x30,
-};
-static const uint8_t pkcs1_digest_info_sha512_start[] =3D {
-	0x30, 0x51, 0x30, 0x0d, 0x06, 0x09, 0x60, 0x86, 0x48, 0x01, 0x65, 0x03,
-	0x04, 0x02, 0x03, 0x05, 0x00, 0x04, 0x40,
-};
-
-static void pkcs1_write_digest_info(enum l_checksum_type type,
-					uint8_t *out, size_t *out_len,
-					const uint8_t *hash, size_t hash_len)
-{
-	switch (type) {
-	case L_CHECKSUM_MD5:
-		memcpy(out, pkcs1_digest_info_md5_start,
-				sizeof(pkcs1_digest_info_md5_start));
-		*out_len =3D sizeof(pkcs1_digest_info_md5_start);
-		break;
-	case L_CHECKSUM_SHA1:
-		memcpy(out, pkcs1_digest_info_sha1_start,
-				sizeof(pkcs1_digest_info_sha1_start));
-		*out_len =3D sizeof(pkcs1_digest_info_sha1_start);
-		break;
-	case L_CHECKSUM_SHA256:
-		memcpy(out, pkcs1_digest_info_sha256_start,
-				sizeof(pkcs1_digest_info_sha256_start));
-		*out_len =3D sizeof(pkcs1_digest_info_sha256_start);
-		break;
-	case L_CHECKSUM_SHA384:
-		memcpy(out, pkcs1_digest_info_sha384_start,
-				sizeof(pkcs1_digest_info_sha384_start));
-		*out_len =3D sizeof(pkcs1_digest_info_sha384_start);
-		break;
-	case L_CHECKSUM_SHA512:
-		memcpy(out, pkcs1_digest_info_sha512_start,
-				sizeof(pkcs1_digest_info_sha512_start));
-		*out_len =3D sizeof(pkcs1_digest_info_sha512_start);
-		break;
-	default:
-		abort();
-	}
-
-	memcpy(out + *out_len, hash, hash_len);
-	*out_len +=3D hash_len;
-}
-
 static void tls_send_alert(struct l_tls *tls, bool fatal,
 				enum l_tls_alert_desc alert_desc)
 {
@@ -1248,13 +1189,11 @@ static bool tls_send_rsa_client_key_xchg(struct l_t=
ls *tls)
 static ssize_t tls_rsa_sign(struct l_tls *tls, uint8_t *out, size_t len,
 				tls_get_hash_t get_hash)
 {
-	ssize_t result;
-	const struct tls_hash_algorithm *hash_type;
-	uint8_t hash[HANDSHAKE_HASH_MAX_SIZE];
-	uint8_t sign_input[HANDSHAKE_HASH_MAX_SIZE * 2 + 32];
+	ssize_t result =3D -EMSGSIZE;
+	enum l_checksum_type sign_checksum_type;
+	uint8_t sign_input[HANDSHAKE_HASH_MAX_SIZE + 36];
 	size_t sign_input_len;
-	bool prepend_hash_type =3D false;
-	size_t expected_bytes;
+	uint8_t *ptr =3D out;
 =

 	if (!tls->priv_key || !tls->priv_key_size) {
 		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, TLS_ALERT_BAD_CERT,
@@ -1263,56 +1202,52 @@ static ssize_t tls_rsa_sign(struct l_tls *tls, uint=
8_t *out, size_t len,
 		return -ENOKEY;
 	}
 =

-	expected_bytes =3D tls->priv_key_size + 2;
-
 	if (tls->negotiated_version >=3D TLS_V12) {
-		hash_type =3D &tls_handshake_hash_data[tls->signature_hash];
-		get_hash(tls, hash_type->tls_id, hash, NULL, NULL);
+		const struct tls_hash_algorithm *hash_type =3D
+			&tls_handshake_hash_data[tls->signature_hash];
+
+		/* Build the DigitallySigned struct */
+		if (len < 2)	/* Is there space for the algorithm IDs */
+			goto error;
 =

-		pkcs1_write_digest_info(hash_type->l_id,
-					sign_input, &sign_input_len,
-					hash, hash_type->length);
+		get_hash(tls, hash_type->tls_id, sign_input, NULL, NULL);
+		sign_checksum_type =3D hash_type->l_id;
+		sign_input_len =3D hash_type->length;
 =

-		prepend_hash_type =3D true;
-		expected_bytes +=3D 2;
+		*ptr++ =3D hash_type->tls_id;
+		*ptr++ =3D 1;	/* RSA_sign */
+		len -=3D 2;
 	} else {
 		get_hash(tls, 1, sign_input + 0, NULL, NULL);	/* MD5 */
 		get_hash(tls, 2, sign_input + 16, NULL, NULL);	/* SHA1 */
+		sign_checksum_type =3D L_CHECKSUM_NONE;
 		sign_input_len =3D 36;
 	}
 =

-	result =3D -EMSGSIZE;
-
-	if (len >=3D expected_bytes) {
-		if (prepend_hash_type) {
-			*out++ =3D hash_type->tls_id;
-			*out++ =3D 1;	/* RSA_sign */
-		}
+	if (len < tls->priv_key_size + 2)
+		goto error;
 =

-		l_put_be16(tls->priv_key_size, out);
-		result =3D l_key_sign(tls->priv_key, L_KEY_RSA_PKCS1_V1_5,
-					L_CHECKSUM_NONE, sign_input, out + 2,
-					sign_input_len, tls->priv_key_size);
+	l_put_be16(tls->priv_key_size, ptr);
+	result =3D l_key_sign(tls->priv_key, L_KEY_RSA_PKCS1_V1_5,
+				sign_checksum_type, sign_input, ptr + 2,
+				sign_input_len, tls->priv_key_size);
+	ptr +=3D tls->priv_key_size + 2;
 =

-		if (result =3D=3D (ssize_t) tls->priv_key_size)
-			result =3D expected_bytes;
-	}
-
-	if (result < 0)
-		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
-				"Signing the hash failed: %s",
-				strerror(-result));
+	if (result =3D=3D (ssize_t) tls->priv_key_size)
+		return ptr - out; /* Success */
 =

+error:
+	TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
+			"Signing the hash failed: %s",
+			strerror(-result));
 	return result;
 }
 =

 static bool tls_rsa_verify(struct l_tls *tls, const uint8_t *in, size_t le=
n,
 				tls_get_hash_t get_hash)
 {
-	uint8_t hash[HANDSHAKE_HASH_MAX_SIZE];
-	size_t hash_len;
 	enum l_checksum_type hash_type;
-	uint8_t expected[HANDSHAKE_HASH_MAX_SIZE * 2 + 32];
+	uint8_t expected[HANDSHAKE_HASH_MAX_SIZE + 36];
 	size_t expected_len;
 	unsigned int offset;
 	bool success;
@@ -1350,7 +1285,8 @@ static bool tls_rsa_verify(struct l_tls *tls, const u=
int8_t *in, size_t len,
 			return false;
 		}
 =

-		if (!get_hash(tls, in[0], hash, &hash_len, &hash_type)) {
+		if (!get_hash(tls, in[0], expected, &expected_len,
+				&hash_type)) {
 			TLS_DISCONNECT(TLS_ALERT_DECRYPT_ERROR, 0,
 					"Unknown hash type %i", in[0]);
 =

@@ -1358,36 +1294,43 @@ static bool tls_rsa_verify(struct l_tls *tls, const=
 uint8_t *in, size_t len,
 		}
 =

 		/*
-		 * TODO: According to 4.7 we need to support at least two forms
-		 * of the signed content in the verification:
+		 * Note: Next we let the l_key_verify's underlying kernel
+		 * operation prepend the OID to the hash to build the
+		 * DigestInfo struct.  However according to 4.7 we need to
+		 * support at least two forms of the signed content in the
+		 * verification:
 		 *  - DigestInfo with NULL AlgorithmIdentifier.parameters,
-		 *  - DigestInfo with empty AlgorithmIdentifier.parameters.
+		 *  - DigestInfo with empty AlgorithmIdentifier.parameters,
+		 *
+		 * while the kernel only understands the former encoding.
+		 * Note PKCS#1 versions 2.0 and later section A.2.4 do
+		 * mandate NULL AlgorithmIdentifier.parameters.
 		 *
-		 * Additionally PKCS#1 now says BER is used in place of DER for
-		 * DigestInfo encoding which adds more ambiguity in the
+		 * Additionally PKCS#1 v1.5 said BER is used in place of DER
+		 * for DigestInfo encoding which adds more ambiguity in the
 		 * encoding.
 		 */
-		pkcs1_write_digest_info(hash_type, expected, &expected_len,
-					hash, hash_len);
 	} else {
 		get_hash(tls, 1, expected + 0, NULL, NULL);	/* MD5 */
 		get_hash(tls, 2, expected + 16, NULL, NULL);	/* SHA1 */
 		expected_len =3D 36;
+		hash_type =3D L_CHECKSUM_NONE;
 =

 		/*
-		 * Within the RSA padding for signatures PKCS#1 1.5 allows
-		 * the block format to be either 0 or 1, while PKCS#1 2.0
-		 * mandates block type 1 making the signatures unambiguous.
-		 * The l_asymmetric_cipher_verify implementation only
-		 * accepts block type 1.
-		 * TODO: TLS 1.0 doesn't specify that block type must be 1
-		 * like TLS 1.2 does meaning that both PKCS#1 1.5 types are
-		 * probably allowed.
+		 * Note: Within the RSA padding for signatures PKCS#1 1.5
+		 * allows the block format to be either 0 or 1, while PKCS#1
+		 * v2.0+ mandates block type 1 making the signatures
+		 * unambiguous.  TLS 1.0 doesn't additionally specify which
+		 * block type is to be used (TLS 1.2 does) meaning that both
+		 * PKCS#1 v1.5 types are allowed.  The l_key_verify's
+		 * underlying kernel implementation only accepts block type
+		 * 1.  If this ever becomes an issue we'd need to go back to
+		 * using L_KEY_RSA_RAW and our own PKCS#1 v1.5 verify logic.
 		 */
 	}
 =

 	success =3D l_key_verify(tls->peer_pubkey, L_KEY_RSA_PKCS1_V1_5,
-				L_CHECKSUM_NONE, expected, in + 4,
+				hash_type, expected, in + 4,
 				expected_len, tls->peer_pubkey_size);
 =

 	if (!success)
-- =

2.19.1


--===============1426526975166742194==--

