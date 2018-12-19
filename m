Content-Type: multipart/mixed; boundary="===============5860557886765230473=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 4/9] tls: Define and use an enum type for TLS versions
Date: Wed, 19 Dec 2018 01:57:55 +0100
Message-ID: <20181219005800.12013-4-andrew.zaborowski@intel.com>
In-Reply-To: <20181219005800.12013-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5860557886765230473==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/tls-private.h | 18 ++++++++++--------
 ell/tls-record.c  | 10 +++++-----
 ell/tls.c         | 36 ++++++++++++++++++------------------
 3 files changed, 33 insertions(+), 31 deletions(-)

diff --git a/ell/tls-private.h b/ell/tls-private.h
index 2e254b2..0908b9c 100644
--- a/ell/tls-private.h
+++ b/ell/tls-private.h
@@ -20,13 +20,15 @@
  *
  */
 =

-/* Only TLS 1.2 supported */
-#define TLS_V12		((3 << 8) | 3)
-#define TLS_V11		((3 << 8) | 2)
-#define TLS_V10		((3 << 8) | 1)
+enum l_tls_version {
+	L_TLS_V10 =3D ((3 << 8) | 1),
+	L_TLS_V11 =3D ((3 << 8) | 2),
+	L_TLS_V12 =3D ((3 << 8) | 3),
+	L_TLS_V13 =3D ((3 << 8) | 4),	/* Not supported */
+};
 =

-#define TLS_VERSION	TLS_V12
-#define TLS_MIN_VERSION	TLS_V10
+#define TLS_VERSION	L_TLS_V12
+#define TLS_MIN_VERSION	L_TLS_V10
 =

 enum tls_cipher_type {
 	TLS_CIPHER_STREAM,
@@ -169,8 +171,8 @@ struct l_tls {
 	struct l_checksum *handshake_hash[__HANDSHAKE_HASH_COUNT];
 	uint8_t prev_digest[__HANDSHAKE_HASH_COUNT][HANDSHAKE_HASH_MAX_SIZE];
 =

-	uint16_t client_version;
-	uint16_t negotiated_version;
+	enum l_tls_version client_version;
+	enum l_tls_version negotiated_version;
 	bool cert_requested, cert_sent;
 	bool peer_authenticated;
 	struct l_cert *peer_cert;
diff --git a/ell/tls-record.c b/ell/tls-record.c
index bffa413..8cb7e57 100644
--- a/ell/tls-record.c
+++ b/ell/tls-record.c
@@ -135,14 +135,14 @@ static void tls_tx_record_plaintext(struct l_tls *tls,
 =

 		offset =3D 0;
 =

-		if (tls->negotiated_version >=3D TLS_V12) {
+		if (tls->negotiated_version >=3D L_TLS_V12) {
 			l_getrandom(ciphertext, tls->record_iv_length[1]);
 =

 			l_cipher_set_iv(tls->cipher[1], ciphertext,
 					tls->record_iv_length[1]);
 =

 			offset =3D tls->record_iv_length[1];
-		} else if (tls->negotiated_version >=3D TLS_V11) {
+		} else if (tls->negotiated_version >=3D L_TLS_V11) {
 			l_getrandom(iv, tls->record_iv_length[1]);
 =

 			l_cipher_encrypt(tls->cipher[1], iv, ciphertext,
@@ -444,7 +444,7 @@ static bool tls_handle_ciphertext(struct l_tls *tls)
 =

 	case TLS_CIPHER_BLOCK:
 		i =3D 0;
-		if (tls->negotiated_version >=3D TLS_V11)
+		if (tls->negotiated_version >=3D L_TLS_V11)
 			i =3D tls->record_iv_length[0];
 =

 		if (fragment_len <=3D tls->mac_length[0] + i) {
@@ -470,7 +470,7 @@ static bool tls_handle_ciphertext(struct l_tls *tls)
 			return false;
 		}
 =

-		if (tls->negotiated_version >=3D TLS_V12) {
+		if (tls->negotiated_version >=3D L_TLS_V12) {
 			if (!l_cipher_set_iv(tls->cipher[0],
 						tls->record_buf + 5,
 						tls->record_iv_length[0])) {
@@ -478,7 +478,7 @@ static bool tls_handle_ciphertext(struct l_tls *tls)
 						"Setting fragment IV failed");
 				return false;
 			}
-		} else if (tls->negotiated_version >=3D TLS_V11)
+		} else if (tls->negotiated_version >=3D L_TLS_V11)
 			if (!l_cipher_decrypt(tls->cipher[0],
 						tls->record_buf + 5, iv,
 						tls->record_iv_length[0])) {
diff --git a/ell/tls.c b/ell/tls.c
index eb459ce..eab9cc2 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -130,7 +130,7 @@ static bool tls_prf_get_bytes(struct l_tls *tls,
 				const void *seed, size_t seed_len,
 				uint8_t *buf, size_t len)
 {
-	if (tls->negotiated_version >=3D TLS_V12)
+	if (tls->negotiated_version >=3D L_TLS_V12)
 		return tls12_prf(tls->prf_hmac->l_id, tls->prf_hmac->length,
 					secret, secret_len, label,
 					seed, seed_len, buf, len);
@@ -332,7 +332,7 @@ static bool tls_change_cipher_spec(struct l_tls *tls, b=
ool txrx,
 			key_offset +=3D 2 * enc->key_length;
 	}
 =

-	if (tls->negotiated_version <=3D TLS_V10 &&
+	if (tls->negotiated_version <=3D L_TLS_V10 &&
 			tls->cipher_suite[txrx]->encryption &&
 			tls->cipher_suite[txrx]->encryption->cipher_type =3D=3D
 			TLS_CIPHER_BLOCK) {
@@ -535,9 +535,9 @@ static bool tls_cipher_suite_is_compatible(struct l_tls=
 *tls,
 =

 	if (suite->encryption &&
 			suite->encryption->cipher_type =3D=3D TLS_CIPHER_AEAD) {
-		uint16_t negotiated =3D tls->negotiated_version;
+		enum l_tls_version negotiated =3D tls->negotiated_version;
 =

-		if (negotiated && negotiated < TLS_V12) {
+		if (negotiated && negotiated < L_TLS_V12) {
 			if (error) {
 				*error =3D error_buf;
 				snprintf(error_buf, sizeof(error_buf),
@@ -589,10 +589,10 @@ static bool tls_cipher_suite_is_compatible(struct l_t=
ls *tls,
 		return false;
 	}
 =

-	if ((tls->negotiated_version && tls->negotiated_version < TLS_V12 &&
+	if ((tls->negotiated_version && tls->negotiated_version < L_TLS_V12 &&
 			(!l_checksum_is_supported(L_CHECKSUM_MD5, true) ||
 			 !l_checksum_is_supported(L_CHECKSUM_SHA1, true))) ||
-			(tls->negotiated_version >=3D TLS_V12 &&
+			(tls->negotiated_version >=3D L_TLS_V12 &&
 			 !l_checksum_is_supported(
 					suite->prf_hmac !=3D L_CHECKSUM_NONE ?
 					suite->prf_hmac : L_CHECKSUM_SHA256,
@@ -1034,7 +1034,7 @@ static bool tls_send_certificate_request(struct l_tls=
 *tls)
 	 * affect both of these steps so revisit which set we're passing
 	 * here.
 	 */
-	if (tls->negotiated_version >=3D TLS_V12) {
+	if (tls->negotiated_version >=3D L_TLS_V12) {
 		signature_hash_ptr =3D ptr;
 		ptr +=3D 2;
 =

@@ -1112,7 +1112,7 @@ static void tls_generate_master_secret(struct l_tls *=
tls,
 			tls->pending.cipher_suite->mac->mac_length;
 =

 	if (tls->pending.cipher_suite->encryption &&
-			tls->negotiated_version <=3D TLS_V10 &&
+			tls->negotiated_version <=3D L_TLS_V10 &&
 			tls->pending.cipher_suite->encryption->cipher_type =3D=3D
 			TLS_CIPHER_BLOCK)
 		key_block_size +=3D 2 *
@@ -1198,7 +1198,7 @@ static ssize_t tls_rsa_sign(struct l_tls *tls, uint8_=
t *out, size_t len,
 		return -ENOKEY;
 	}
 =

-	if (tls->negotiated_version >=3D TLS_V12) {
+	if (tls->negotiated_version >=3D L_TLS_V12) {
 		const struct tls_hash_algorithm *hash_type =3D
 			&tls_handshake_hash_data[tls->signature_hash];
 =

@@ -1250,7 +1250,7 @@ static bool tls_rsa_verify(struct l_tls *tls, const u=
int8_t *in, size_t len,
 =

 	/* 2 bytes for SignatureAndHashAlgorithm if version >=3D 1.2 */
 	offset =3D 2;
-	if (tls->negotiated_version < TLS_V12)
+	if (tls->negotiated_version < L_TLS_V12)
 		offset =3D 0;
 =

 	if (len < offset + 2 ||
@@ -1271,7 +1271,7 @@ static bool tls_rsa_verify(struct l_tls *tls, const u=
int8_t *in, size_t len,
 		return false;
 	}
 =

-	if (tls->negotiated_version >=3D TLS_V12) {
+	if (tls->negotiated_version >=3D L_TLS_V12) {
 		/* Only RSA supported */
 		if (in[1] !=3D 1 /* RSA_sign */) {
 			TLS_DISCONNECT(TLS_ALERT_DECRYPT_ERROR, 0,
@@ -1392,7 +1392,7 @@ static bool tls_send_certificate_verify(struct l_tls =
*tls)
 		return false;
 =

 	/* Stop maintaining handshake message hashes other than the PRF hash */
-	if (tls->negotiated_version >=3D TLS_V12)
+	if (tls->negotiated_version >=3D L_TLS_V12)
 		for (i =3D 0; i < __HANDSHAKE_HASH_COUNT; i++)
 			if (&tls_handshake_hash_data[i] !=3D tls->prf_hmac)
 				tls_drop_handshake_hash(tls, i);
@@ -1417,7 +1417,7 @@ static void tls_send_finished(struct l_tls *tls)
 	uint8_t seed[HANDSHAKE_HASH_MAX_SIZE * 2];
 	size_t seed_len;
 =

-	if (tls->negotiated_version >=3D TLS_V12) {
+	if (tls->negotiated_version >=3D L_TLS_V12) {
 		/* Same hash type as that used for the PRF (usually SHA256) */
 		enum handshake_hash_type hash;
 =

@@ -1458,7 +1458,7 @@ static bool tls_verify_finished(struct l_tls *tls, co=
nst uint8_t *received,
 		return false;
 	}
 =

-	if (tls->negotiated_version >=3D TLS_V12) {
+	if (tls->negotiated_version >=3D L_TLS_V12) {
 		enum handshake_hash_type hash;
 =

 		for (hash =3D 0; hash < __HANDSHAKE_HASH_COUNT; hash++)
@@ -1585,7 +1585,7 @@ static void tls_handle_client_hello(struct l_tls *tls,
 		TLS_VERSION : tls->client_version;
 =

 	/* Stop maintaining handshake message hashes other than MD1 and SHA. */
-	if (tls->negotiated_version < TLS_V12)
+	if (tls->negotiated_version < L_TLS_V12)
 		for (i =3D 0; i < __HANDSHAKE_HASH_COUNT; i++)
 			if (i !=3D HANDSHAKE_HASH_SHA1 && i !=3D HANDSHAKE_HASH_MD5)
 				tls_drop_handshake_hash(tls, i);
@@ -1714,7 +1714,7 @@ static void tls_handle_server_hello(struct l_tls *tls,
 	}
 =

 	/* Stop maintaining handshake message hashes other than MD1 and SHA. */
-	if (tls->negotiated_version < TLS_V12)
+	if (tls->negotiated_version < L_TLS_V12)
 		for (i =3D 0; i < __HANDSHAKE_HASH_COUNT; i++)
 			if (i !=3D HANDSHAKE_HASH_SHA1 && i !=3D HANDSHAKE_HASH_MD5)
 				tls_drop_handshake_hash(tls, i);
@@ -1911,7 +1911,7 @@ static void tls_handle_certificate_request(struct l_t=
ls *tls,
 	 * lists for use in tls_send_certificate.
 	 */
 =

-	if (tls->negotiated_version >=3D TLS_V12) {
+	if (tls->negotiated_version >=3D L_TLS_V12) {
 		/*
 		 * This only makes sense as a variable-length field, assume
 		 * there's a typo in RFC5246 7.4.4 here.
@@ -2125,7 +2125,7 @@ static void tls_handle_certificate_verify(struct l_tl=
s *tls,
 		return;
 =

 	/* Stop maintaining handshake message hashes other than the PRF hash */
-	if (tls->negotiated_version >=3D TLS_V12)
+	if (tls->negotiated_version >=3D L_TLS_V12)
 		for (i =3D 0; i < __HANDSHAKE_HASH_COUNT; i++)
 			if (&tls_handshake_hash_data[i] !=3D tls->prf_hmac)
 				tls_drop_handshake_hash(tls, i);
-- =

2.19.1


--===============5860557886765230473==--

