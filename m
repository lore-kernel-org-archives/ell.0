Content-Type: multipart/mixed; boundary="===============3929955275770537577=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 4/9] tls: Implement l_tls_set_version_range
Date: Thu, 13 Dec 2018 20:57:41 +0100
Message-ID: <20181213195746.32144-4-andrew.zaborowski@intel.com>
In-Reply-To: <20181213195746.32144-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3929955275770537577==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Allow user to set custom min and max TLS version limits, this can be
used to ensure we comply with a specific security profile.
---
 ell/ell.sym       |  1 +
 ell/tls-private.h | 10 ++---
 ell/tls-record.c  | 14 +++----
 ell/tls.c         | 99 +++++++++++++++++++++++++++++++++--------------
 ell/tls.h         |  8 +++-
 5 files changed, 87 insertions(+), 45 deletions(-)

diff --git a/ell/ell.sym b/ell/ell.sym
index 7d7a5e4..2ff7d30 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -417,6 +417,7 @@ global:
 	l_tls_close;
 	l_tls_set_cacert;
 	l_tls_set_auth_data;
+	l_tls_set_version_range;
 	l_tls_alert_to_str;
 	l_tls_set_debug;
 	/* uintset */
diff --git a/ell/tls-private.h b/ell/tls-private.h
index 8e6c277..e2ec014 100644
--- a/ell/tls-private.h
+++ b/ell/tls-private.h
@@ -20,13 +20,8 @@
  *
  */
 =

-/* Only TLS 1.2 supported */
-#define TLS_V12		((3 << 8) | 3)
-#define TLS_V11		((3 << 8) | 2)
-#define TLS_V10		((3 << 8) | 1)
-
-#define TLS_VERSION	TLS_V12
-#define TLS_MIN_VERSION	TLS_V10
+#define TLS_MAX_VERSION	L_TLS_V12
+#define TLS_MIN_VERSION	L_TLS_V10
 =

 enum tls_cipher_type {
 	TLS_CIPHER_STREAM,
@@ -145,6 +140,7 @@ struct l_tls {
 	l_tls_debug_cb_t debug_handler;
 	l_tls_destroy_cb_t debug_destroy;
 	void *debug_data;
+	uint16_t min_version, max_version;
 =

 	struct l_queue *ca_certs;
 	struct l_certchain *cert;
diff --git a/ell/tls-record.c b/ell/tls-record.c
index bffa413..bdab0c4 100644
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
@@ -223,7 +223,7 @@ void tls_tx_record(struct l_tls *tls, enum tls_content_=
type type,
 				TX_RECORD_TAILROOM];
 	uint8_t *fragment, *plaintext;
 	uint16_t fragment_len;
-	uint16_t version =3D tls->negotiated_version ?: TLS_MIN_VERSION;
+	uint16_t version =3D tls->negotiated_version ?: tls->min_version;
 =

 	if (type =3D=3D TLS_CT_ALERT)
 		tls->record_flush =3D true;
@@ -393,7 +393,7 @@ static bool tls_handle_ciphertext(struct l_tls *tls)
 =

 	if ((tls->negotiated_version && tls->negotiated_version !=3D version) ||
 			(!tls->negotiated_version &&
-			 tls->record_buf[1] !=3D 0x03 /* Appending E.1 */)) {
+			 tls->record_buf[1] !=3D 0x03 /* Appendix E.1 */)) {
 		TLS_DISCONNECT(TLS_ALERT_PROTOCOL_VERSION, 0,
 				"Record version mismatch: %02x", version);
 		return false;
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
index 8099e76..8abbabd 100644
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
@@ -532,10 +532,24 @@ static bool tls_cipher_suite_is_compatible(struct l_t=
ls *tls,
 {
 	static char error_buf[200];
 	struct l_cert *leaf;
+	uint16_t negotiated =3D tls->negotiated_version;
 =

 	if (suite->encryption &&
 			suite->encryption->cipher_type =3D=3D TLS_CIPHER_AEAD) {
-		uint16_t negotiated =3D tls->negotiated_version;
+		if (tls->max_version < L_TLS_V12) {
+			if (error) {
+				*error =3D error_buf;
+				snprintf(error_buf, sizeof(error_buf),
+						"Cipher suite %s uses an AEAD "
+						"cipher (TLS 1.2+) but "
+						TLS_VER_FMT
+						" is the max version allowed",
+						suite->name,
+						TLS_VER_ARGS(tls->max_version));
+			}
+
+			return false;
+		}
 =

 		if (negotiated && negotiated < L_TLS_V12) {
 			if (error) {
@@ -589,10 +603,13 @@ static bool tls_cipher_suite_is_compatible(struct l_t=
ls *tls,
 		return false;
 	}
 =

-	if ((tls->negotiated_version && tls->negotiated_version < TLS_V12 &&
-			(!l_checksum_is_supported(L_CHECKSUM_MD5, true) ||
-			 !l_checksum_is_supported(L_CHECKSUM_SHA1, true))) ||
-			(tls->negotiated_version >=3D TLS_V12 &&
+	if (
+			((tls->max_version < L_TLS_V12 ||
+			  (negotiated && negotiated < L_TLS_V12)) &&
+			 (!l_checksum_is_supported(L_CHECKSUM_MD5, true) ||
+			  !l_checksum_is_supported(L_CHECKSUM_SHA1, true))) ||
+			((tls->min_version >=3D L_TLS_V12 ||
+			  tls->negotiated_version >=3D L_TLS_V12) &&
 			 !l_checksum_is_supported(
 					suite->prf_hmac !=3D L_CHECKSUM_NONE ?
 					suite->prf_hmac : L_CHECKSUM_SHA256,
@@ -664,8 +681,14 @@ static const struct tls_hash_algorithm tls_handshake_h=
ash_data[] =3D {
 static bool tls_init_handshake_hash(struct l_tls *tls)
 {
 	enum handshake_hash_type hash;
+	bool tls10 =3D tls->max_version < L_TLS_V12;
 =

 	for (hash =3D 0; hash < __HANDSHAKE_HASH_COUNT; hash++) {
+		/* Skip hash types we already know we won't need */
+		if (tls10 && hash !=3D HANDSHAKE_HASH_SHA1 &&
+				hash !=3D HANDSHAKE_HASH_MD5)
+			continue;
+
 		if (tls->handshake_hash[hash]) {
 			TLS_DEBUG("Handshake hash %s already exists",
 					tls_handshake_hash_data[hash].name);
@@ -820,8 +843,8 @@ static bool tls_send_client_hello(struct l_tls *tls)
 =

 	/* Fill in the Client Hello body */
 =

-	*ptr++ =3D (uint8_t) (TLS_VERSION >> 8);
-	*ptr++ =3D (uint8_t) (TLS_VERSION >> 0);
+	*ptr++ =3D (uint8_t) (tls->max_version >> 8);
+	*ptr++ =3D (uint8_t) (tls->max_version >> 0);
 =

 	tls_write_random(tls->pending.client_random);
 	memcpy(ptr, tls->pending.client_random, 32);
@@ -843,7 +866,8 @@ static bool tls_send_client_hello(struct l_tls *tls)
 	}
 =

 	if (ptr =3D=3D len_ptr + 2) {
-		TLS_DEBUG("No compatible cipher suites, check kernel config");
+		TLS_DEBUG("No compatible cipher suites, check kernel config, "
+				"certificate's key type and TLS version range");
 		return false;
 	}
 =

@@ -1034,7 +1058,7 @@ static bool tls_send_certificate_request(struct l_tls=
 *tls)
 	 * affect both of these steps so revisit which set we're passing
 	 * here.
 	 */
-	if (tls->negotiated_version >=3D TLS_V12) {
+	if (tls->negotiated_version >=3D L_TLS_V12) {
 		signature_hash_ptr =3D ptr;
 		ptr +=3D 2;
 =

@@ -1112,7 +1136,7 @@ static void tls_generate_master_secret(struct l_tls *=
tls,
 			tls->pending.cipher_suite->mac->mac_length;
 =

 	if (tls->pending.cipher_suite->encryption &&
-			tls->negotiated_version <=3D TLS_V10 &&
+			tls->negotiated_version <=3D L_TLS_V10 &&
 			tls->pending.cipher_suite->encryption->cipher_type =3D=3D
 			TLS_CIPHER_BLOCK)
 		key_block_size +=3D 2 *
@@ -1147,8 +1171,9 @@ static bool tls_send_rsa_client_key_xchg(struct l_tls=
 *tls)
 		return false;
 	}
 =

-	pre_master_secret[0] =3D (uint8_t) (TLS_VERSION >> 8);
-	pre_master_secret[1] =3D (uint8_t) (TLS_VERSION >> 0);
+	/* Must match the version in tls_send_client_hello */
+	pre_master_secret[0] =3D (uint8_t) (tls->max_version >> 8);
+	pre_master_secret[1] =3D (uint8_t) (tls->max_version >> 0);
 	l_getrandom(pre_master_secret + 2, 46);
 =

 	if (tls->peer_pubkey_size + 32 > (int) sizeof(buf)) {
@@ -1198,7 +1223,7 @@ static ssize_t tls_rsa_sign(struct l_tls *tls, uint8_=
t *out, size_t len,
 		return -ENOKEY;
 	}
 =

-	if (tls->negotiated_version >=3D TLS_V12) {
+	if (tls->negotiated_version >=3D L_TLS_V12) {
 		const struct tls_hash_algorithm *hash_type =3D
 			&tls_handshake_hash_data[tls->signature_hash];
 =

@@ -1250,7 +1275,7 @@ static bool tls_rsa_verify(struct l_tls *tls, const u=
int8_t *in, size_t len,
 =

 	/* 2 bytes for SignatureAndHashAlgorithm if version >=3D 1.2 */
 	offset =3D 2;
-	if (tls->negotiated_version < TLS_V12)
+	if (tls->negotiated_version < L_TLS_V12)
 		offset =3D 0;
 =

 	if (len < offset + 2 ||
@@ -1271,7 +1296,7 @@ static bool tls_rsa_verify(struct l_tls *tls, const u=
int8_t *in, size_t len,
 		return false;
 	}
 =

-	if (tls->negotiated_version >=3D TLS_V12) {
+	if (tls->negotiated_version >=3D L_TLS_V12) {
 		/* Only RSA supported */
 		if (in[1] !=3D 1 /* RSA_sign */) {
 			TLS_DISCONNECT(TLS_ALERT_DECRYPT_ERROR, 0,
@@ -1392,7 +1417,7 @@ static bool tls_send_certificate_verify(struct l_tls =
*tls)
 		return false;
 =

 	/* Stop maintaining handshake message hashes other than the PRF hash */
-	if (tls->negotiated_version >=3D TLS_V12)
+	if (tls->negotiated_version >=3D L_TLS_V12)
 		for (i =3D 0; i < __HANDSHAKE_HASH_COUNT; i++)
 			if (&tls_handshake_hash_data[i] !=3D tls->prf_hmac)
 				tls_drop_handshake_hash(tls, i);
@@ -1417,7 +1442,7 @@ static void tls_send_finished(struct l_tls *tls)
 	uint8_t seed[HANDSHAKE_HASH_MAX_SIZE * 2];
 	size_t seed_len;
 =

-	if (tls->negotiated_version >=3D TLS_V12) {
+	if (tls->negotiated_version >=3D L_TLS_V12) {
 		/* Same hash type as that used for the PRF (usually SHA256) */
 		enum handshake_hash_type hash;
 =

@@ -1458,7 +1483,7 @@ static bool tls_verify_finished(struct l_tls *tls, co=
nst uint8_t *received,
 		return false;
 	}
 =

-	if (tls->negotiated_version >=3D TLS_V12) {
+	if (tls->negotiated_version >=3D L_TLS_V12) {
 		enum handshake_hash_type hash;
 =

 		for (hash =3D 0; hash < __HANDSHAKE_HASH_COUNT; hash++)
@@ -1574,18 +1599,18 @@ static void tls_handle_client_hello(struct l_tls *t=
ls,
 	/* Save client_version for Premaster Secret verification */
 	tls->client_version =3D l_get_be16(buf);
 =

-	if (tls->client_version < TLS_MIN_VERSION) {
+	if (tls->client_version < tls->min_version) {
 		TLS_DISCONNECT(TLS_ALERT_PROTOCOL_VERSION, 0,
 				"Client version too low: %02x",
 				tls->client_version);
 		return;
 	}
 =

-	tls->negotiated_version =3D TLS_VERSION < tls->client_version ?
-		TLS_VERSION : tls->client_version;
+	tls->negotiated_version =3D tls->client_version > tls->max_version ?
+		tls->max_version : tls->client_version;
 =

 	/* Stop maintaining handshake message hashes other than MD1 and SHA. */
-	if (tls->negotiated_version < TLS_V12)
+	if (tls->negotiated_version < L_TLS_V12)
 		for (i =3D 0; i < __HANDSHAKE_HASH_COUNT; i++)
 			if (i !=3D HANDSHAKE_HASH_SHA1 && i !=3D HANDSHAKE_HASH_MD5)
 				tls_drop_handshake_hash(tls, i);
@@ -1703,9 +1728,9 @@ static void tls_handle_server_hello(struct l_tls *tls,
 =

 	tls->negotiated_version =3D l_get_be16(buf);
 =

-	if (tls->negotiated_version < TLS_MIN_VERSION ||
-			tls->negotiated_version > TLS_VERSION) {
-		TLS_DISCONNECT(tls->negotiated_version < TLS_MIN_VERSION ?
+	if (tls->negotiated_version < tls->min_version ||
+			tls->negotiated_version > tls->max_version) {
+		TLS_DISCONNECT(tls->negotiated_version < tls->min_version ?
 				TLS_ALERT_PROTOCOL_VERSION :
 				TLS_ALERT_ILLEGAL_PARAM, 0,
 				"Unsupported version %02x",
@@ -1714,7 +1739,7 @@ static void tls_handle_server_hello(struct l_tls *tls,
 	}
 =

 	/* Stop maintaining handshake message hashes other than MD1 and SHA. */
-	if (tls->negotiated_version < TLS_V12)
+	if (tls->negotiated_version < L_TLS_V12)
 		for (i =3D 0; i < __HANDSHAKE_HASH_COUNT; i++)
 			if (i !=3D HANDSHAKE_HASH_SHA1 && i !=3D HANDSHAKE_HASH_MD5)
 				tls_drop_handshake_hash(tls, i);
@@ -1911,7 +1936,7 @@ static void tls_handle_certificate_request(struct l_t=
ls *tls,
 	 * lists for use in tls_send_certificate.
 	 */
 =

-	if (tls->negotiated_version >=3D TLS_V12) {
+	if (tls->negotiated_version >=3D L_TLS_V12) {
 		/*
 		 * This only makes sense as a variable-length field, assume
 		 * there's a typo in RFC5246 7.4.4 here.
@@ -2125,7 +2150,7 @@ static void tls_handle_certificate_verify(struct l_tl=
s *tls,
 		return;
 =

 	/* Stop maintaining handshake message hashes other than the PRF hash */
-	if (tls->negotiated_version >=3D TLS_V12)
+	if (tls->negotiated_version >=3D L_TLS_V12)
 		for (i =3D 0; i < __HANDSHAKE_HASH_COUNT; i++)
 			if (&tls_handshake_hash_data[i] !=3D tls->prf_hmac)
 				tls_drop_handshake_hash(tls, i);
@@ -2458,6 +2483,8 @@ LIB_EXPORT struct l_tls *l_tls_new(bool server,
 	tls->ready_handle =3D ready_handler;
 	tls->disconnected =3D disconnect_handler;
 	tls->user_data =3D user_data;
+	tls->min_version =3D TLS_MIN_VERSION;
+	tls->max_version =3D TLS_MAX_VERSION;
 =

 	tls->signature_hash =3D HANDSHAKE_HASH_SHA256;
 =

@@ -2751,6 +2778,18 @@ LIB_EXPORT bool l_tls_set_auth_data(struct l_tls *tl=
s, const char *cert_path,
 	return true;
 }
 =

+LIB_EXPORT void l_tls_set_version_range(struct l_tls *tls,
+					uint16_t min_version,
+					uint16_t max_version)
+{
+	tls->min_version =3D
+		(min_version && min_version > TLS_MIN_VERSION) ?
+		min_version : TLS_MIN_VERSION;
+	tls->max_version =3D
+		(max_version && max_version < TLS_MAX_VERSION) ?
+		max_version : TLS_MAX_VERSION;
+}
+
 LIB_EXPORT const char *l_tls_alert_to_str(enum l_tls_alert_desc desc)
 {
 	switch (desc) {
diff --git a/ell/tls.h b/ell/tls.h
index fb33404..5b2f398 100644
--- a/ell/tls.h
+++ b/ell/tls.h
@@ -25,6 +25,10 @@
 extern "C" {
 #endif
 =

+#define L_TLS_V12	((3 << 8) | 3)
+#define L_TLS_V11	((3 << 8) | 2)
+#define L_TLS_V10	((3 << 8) | 1)
+
 struct l_tls;
 =

 enum l_tls_alert_desc {
@@ -63,7 +67,6 @@ typedef void (*l_tls_disconnect_cb_t)(enum l_tls_alert_de=
sc reason,
 typedef void (*l_tls_debug_cb_t)(const char *str, void *user_data);
 typedef void (*l_tls_destroy_cb_t)(void *user_data);
 =

-
 /*
  * app_data_handler gets called with newly received decrypted data.
  * tx_handler gets called to send TLS payloads off to remote end.
@@ -107,6 +110,9 @@ bool l_tls_set_auth_data(struct l_tls *tls, const char =
*cert_path,
 				const char *priv_key_path,
 				const char *priv_key_passphrase);
 =

+void l_tls_set_version_range(struct l_tls *tls,
+				uint16_t min_version, uint16_t max_version);
+
 const char *l_tls_alert_to_str(enum l_tls_alert_desc desc);
 =

 enum l_checksum_type;
-- =

2.19.1


--===============3929955275770537577==--

