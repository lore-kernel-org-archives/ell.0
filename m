Content-Type: multipart/mixed; boundary="===============4518724317724970041=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 3/7] tls: Add debug logging API
Date: Thu, 01 Nov 2018 03:12:16 +0100
Message-ID: <20181101021220.19073-3-andrew.zaborowski@intel.com>
In-Reply-To: <20181101021220.19073-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4518724317724970041==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add a debug logging API similar to that in dbus.h and genl.h.  A lot of
messages are added to report on the negotiation progress (Handshake, Alert
and ChangeCipherSpec messages) and all the possible error situations.
Especially configuration errors -- the most common errors -- should be
clear when looking at the logs.

No Application Data messages (plaintext) or raw TLS record contents
(encrypted) are logged because this can be easily done by the user
code and could add a flood of messages that would make it actually
harder to solve TLS issues.
---
 ell/tls-private.h |  24 +++
 ell/tls-record.c  |  66 ++++---
 ell/tls.c         | 427 +++++++++++++++++++++++++++++++++++-----------
 ell/tls.h         |   6 +
 4 files changed, 399 insertions(+), 124 deletions(-)

diff --git a/ell/tls-private.h b/ell/tls-private.h
index 8cf5be9..4f680a0 100644
--- a/ell/tls-private.h
+++ b/ell/tls-private.h
@@ -48,6 +48,7 @@ struct tls_hash_algorithm {
 	uint8_t tls_id;
 	enum l_checksum_type l_id;
 	size_t length;
+	const char *name;
 };
 =

 typedef bool (*tls_get_hash_t)(struct l_tls *tls, uint8_t tls_id,
@@ -89,6 +90,7 @@ struct tls_cipher_suite {
 =

 struct tls_compression_method {
 	int id;
+	const char *name;
 };
 =

 enum tls_handshake_state {
@@ -136,6 +138,9 @@ struct l_tls {
 	l_tls_ready_cb_t ready_handle;
 	l_tls_disconnect_cb_t disconnected;
 	void *user_data;
+	l_tls_debug_cb_t debug_handler;
+	l_tls_destroy_cb_t debug_destroy;
+	void *debug_data;
 =

 	char *ca_cert_path;
 	char *cert_path;
@@ -254,3 +259,22 @@ void tls_prf_get_bytes(struct l_tls *tls,
 				const char *label,
 				const void *seed, size_t seed_len,
 				uint8_t *buf, size_t len);
+
+#define TLS_DEBUG(fmt, args...)	\
+	l_util_debug(tls->debug_handler, tls->debug_data, "%s:%i " fmt,	\
+			__func__, __LINE__, ## args)
+#define TLS_SET_STATE(new_state)	\
+	do {	\
+		TLS_DEBUG("New state %s",	\
+				tls_handshake_state_to_str(new_state));	\
+		tls->state =3D new_state;	\
+	} while (0)
+#define TLS_DISCONNECT(desc, local_desc, fmt, args...)	\
+	do {	\
+		TLS_DEBUG("Disconnect desc=3D%s local-desc=3D%s reason=3D" fmt,\
+				l_tls_alert_to_str(desc),	\
+				l_tls_alert_to_str(local_desc), ## args);\
+		tls_disconnect(tls, desc, local_desc);	\
+	} while (0)
+
+const char *tls_handshake_state_to_str(enum tls_handshake_state state);
diff --git a/ell/tls-record.c b/ell/tls-record.c
index 0ad03ed..8038049 100644
--- a/ell/tls-record.c
+++ b/ell/tls-record.c
@@ -208,13 +208,9 @@ void tls_tx_record(struct l_tls *tls, enum tls_content=
_type type,
 static bool tls_handle_plaintext(struct l_tls *tls, const uint8_t *plainte=
xt,
 					int len, uint8_t type, uint16_t version)
 {
-	int header_len, need_len;
-	int chunk_len;
-
-	uint32_t hs_len;
-
 	if (len > (1 << 14)) {
-		tls_disconnect(tls, TLS_ALERT_DECODE_ERROR, 0);
+		TLS_DISCONNECT(TLS_ALERT_DECODE_ERROR, 0,
+				"Plaintext message too long: %i", len);
 		return false;
 	}
 =

@@ -246,30 +242,39 @@ static bool tls_handle_plaintext(struct l_tls *tls, c=
onst uint8_t *plaintext,
 		break;
 =

 	default:
-		tls_disconnect(tls, TLS_ALERT_DECODE_ERROR, 0);
+		TLS_DISCONNECT(TLS_ALERT_DECODE_ERROR, 0,
+				"Unknown content type %i", type);
 		return false;
 	}
 =

 	if (tls->message_buf_len && type !=3D tls->message_content_type) {
-		tls_disconnect(tls, TLS_ALERT_DECODE_ERROR, 0);
+		TLS_DISCONNECT(TLS_ALERT_DECODE_ERROR, 0,
+				"Message fragment type %i doesn't match "
+				"previous type %i", type,
+				tls->message_content_type);
 		return false;
 	}
 =

 	tls->message_content_type =3D type;
 =

 	while (1) {
+		int header_len, need_len;
+		int chunk_len;
+
 		/* Do we have a full header in tls->message_buf? */
 		header_len =3D (type =3D=3D TLS_CT_ALERT) ? 2 : 4;
 		need_len =3D header_len;
 =

 		if (tls->message_buf_len >=3D header_len) {
 			if (type =3D=3D TLS_CT_HANDSHAKE) {
-				hs_len =3D (tls->message_buf[1] << 16) |
+				uint32_t hs_len =3D (tls->message_buf[1] << 16) |
 					(tls->message_buf[2] << 8) |
 					(tls->message_buf[3] << 0);
 				if (hs_len > (1 << 14)) {
-					tls_disconnect(tls,
-						TLS_ALERT_DECODE_ERROR, 0);
+					TLS_DISCONNECT(TLS_ALERT_DECODE_ERROR,
+							0, "Handshake message "
+							"too long: %i",
+							(int) hs_len);
 					return false;
 				}
 =

@@ -333,19 +338,22 @@ static bool tls_handle_ciphertext(struct l_tls *tls)
 	fragment_len =3D l_get_be16(tls->record_buf + 3);
 =

 	if (fragment_len > (1 << 14) + 2048) {
-		tls_disconnect(tls, TLS_ALERT_RECORD_OVERFLOW, 0);
+		TLS_DISCONNECT(TLS_ALERT_RECORD_OVERFLOW, 0,
+				"Record fragment too long: %u", fragment_len);
 		return false;
 	}
 =

 	if ((tls->negotiated_version && tls->negotiated_version !=3D version) ||
 			(!tls->negotiated_version &&
 			 tls->record_buf[1] !=3D 0x03 /* Appending E.1 */)) {
-		tls_disconnect(tls, TLS_ALERT_PROTOCOL_VERSION, 0);
+		TLS_DISCONNECT(TLS_ALERT_PROTOCOL_VERSION, 0,
+				"Record version mismatch: %02x", version);
 		return false;
 	}
 =

 	if (fragment_len < tls->mac_length[0]) {
-		tls_disconnect(tls, TLS_ALERT_DECODE_ERROR, 0);
+		TLS_DISCONNECT(TLS_ALERT_DECODE_ERROR, 0,
+				"Record fragment too short: %u", fragment_len);
 		return false;
 	}
 =

@@ -366,7 +374,8 @@ static bool tls_handle_ciphertext(struct l_tls *tls)
 		else if (!l_cipher_decrypt(tls->cipher[0], tls->record_buf + 5,
 						compressed + 13,
 						cipher_output_len)) {
-			tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR, 0);
+			TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
+					"Decrypting record fragment failed");
 			return false;
 		}
 =

@@ -376,7 +385,8 @@ static bool tls_handle_ciphertext(struct l_tls *tls)
 =

 		if (memcmp(mac_buf, compressed + 13 + compressed_len,
 							tls->mac_length[0])) {
-			tls_disconnect(tls, TLS_ALERT_BAD_RECORD_MAC, 0);
+			TLS_DISCONNECT(TLS_ALERT_BAD_RECORD_MAC, 0,
+					"Record fragment MAC mismatch");
 			return false;
 		}
 =

@@ -390,7 +400,9 @@ static bool tls_handle_ciphertext(struct l_tls *tls)
 			i =3D tls->record_iv_length[0];
 =

 		if (fragment_len <=3D tls->mac_length[0] + i) {
-			tls_disconnect(tls, TLS_ALERT_DECODE_ERROR, 0);
+			TLS_DISCONNECT(TLS_ALERT_DECODE_ERROR, 0,
+					"Record fragment too short: %u",
+					fragment_len);
 			return false;
 		}
 =

@@ -402,7 +414,11 @@ static bool tls_handle_ciphertext(struct l_tls *tls)
 			 * should be returned here but that was declared
 			 * unsafe in the TLS 1.1 spec.
 			 */
-			tls_disconnect(tls, TLS_ALERT_BAD_RECORD_MAC, 0);
+			TLS_DISCONNECT(TLS_ALERT_BAD_RECORD_MAC, 0,
+					"Fragment data len %i not a multiple "
+					"of block length %zi",
+					cipher_output_len,
+					tls->block_length[0]);
 			return false;
 		}
 =

@@ -410,22 +426,23 @@ static bool tls_handle_ciphertext(struct l_tls *tls)
 			if (!l_cipher_set_iv(tls->cipher[0],
 						tls->record_buf + 5,
 						tls->record_iv_length[0])) {
-				tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR,
-						0);
+				TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
+						"Setting fragment IV failed");
 				return false;
 			}
 		} else if (tls->negotiated_version >=3D TLS_V11)
 			if (!l_cipher_decrypt(tls->cipher[0],
 						tls->record_buf + 5, iv,
 						tls->record_iv_length[0])) {
-				tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR,
-						0);
+				TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
+						"Setting fragment IV failed");
 				return false;
 			}
 =

 		if (!l_cipher_decrypt(tls->cipher[0], tls->record_buf + 5 + i,
 					compressed + 13, cipher_output_len)) {
-			tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR, 0);
+			TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
+					"Fragment decryption failed");
 			return false;
 		}
 =

@@ -469,7 +486,8 @@ static bool tls_handle_ciphertext(struct l_tls *tls)
 		if ((tls->mac_length[0] && memcmp(mac_buf, compressed + 13 +
 					compressed_len, tls->mac_length[0])) ||
 				error) {
-			tls_disconnect(tls, TLS_ALERT_BAD_RECORD_MAC, 0);
+			TLS_DISCONNECT(TLS_ALERT_BAD_RECORD_MAC, 0,
+					"Record fragment MAC mismatch");
 			return false;
 		}
 =

diff --git a/ell/tls.c b/ell/tls.c
index 3528ceb..4b37785 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -26,6 +26,7 @@
 #include <time.h>
 #include <stdlib.h>
 #include <errno.h>
+#include <stdio.h>
 =

 #include "util.h"
 #include "private.h"
@@ -185,7 +186,7 @@ static void tls_reset_handshake(struct l_tls *tls)
 	for (hash =3D 0; hash < __HANDSHAKE_HASH_COUNT; hash++)
 		tls_drop_handshake_hash(tls, hash);
 =

-	tls->state =3D TLS_HANDSHAKE_WAIT_HELLO;
+	TLS_SET_STATE(TLS_HANDSHAKE_WAIT_HELLO);
 	tls->cert_requested =3D 0;
 	tls->cert_sent =3D 0;
 }
@@ -197,11 +198,13 @@ static void tls_cleanup_handshake(struct l_tls *tls)
 	memset(tls->pending.master_secret, 0, 48);
 }
 =

-static bool tls_change_cipher_spec(struct l_tls *tls, bool txrx)
+static bool tls_change_cipher_spec(struct l_tls *tls, bool txrx,
+					const char **error)
 {
 	struct tls_bulk_encryption_algorithm *enc;
 	struct tls_mac_algorithm *mac;
 	int key_offset;
+	char error_buf[50];
 =

 	if (tls->cipher[txrx]) {
 		l_cipher_free(tls->cipher[txrx]);
@@ -240,8 +243,17 @@ static bool tls_change_cipher_spec(struct l_tls *tls, =
bool txrx)
 		/* Wipe out the now unneeded part of the key block */
 		memset(tls->pending.key_block + key_offset, 0, mac->mac_length);
 =

-		if (!tls->mac[txrx])
+		if (!tls->mac[txrx]) {
+			if (error) {
+				*error =3D error_buf;
+				snprintf(error_buf, sizeof(error_buf),
+						"Can't create %s's %s HMAC",
+						tls->cipher_suite[txrx]->name,
+						txrx ? "Tx" : "Rx");
+			}
+
 			return false;
+		}
 =

 		tls->mac_length[txrx] =3D mac->mac_length;
 =

@@ -262,8 +274,17 @@ static bool tls_change_cipher_spec(struct l_tls *tls, =
bool txrx)
 		/* Wipe out the now unneeded part of the key block */
 		memset(tls->pending.key_block + key_offset, 0, enc->key_length);
 =

-		if (!tls->cipher[txrx])
+		if (!tls->cipher[txrx]) {
+			if (error) {
+				*error =3D error_buf;
+				snprintf(error_buf, sizeof(error_buf),
+						"Can't create %s's %s cipher",
+						tls->cipher_suite[txrx]->name,
+						txrx ? "Tx" : "Rx");
+			}
+
 			return false;
+		}
 =

 		tls->cipher_type[txrx] =3D enc->cipher_type;
 		if (enc->cipher_type =3D=3D TLS_CIPHER_BLOCK) {
@@ -303,7 +324,7 @@ static void tls_reset_cipher_spec(struct l_tls *tls, bo=
ol txrx)
 =

 	tls->pending.cipher_suite =3D NULL;
 =

-	tls_change_cipher_spec(tls, txrx);
+	tls_change_cipher_spec(tls, txrx, NULL);
 }
 =

 static bool tls_send_rsa_client_key_xchg(struct l_tls *tls);
@@ -440,9 +461,9 @@ static struct tls_cipher_suite *tls_find_cipher_suite(c=
onst uint8_t *id)
 }
 =

 static struct tls_compression_method tls_compression_pref[] =3D {
-	/* CompressionMethod.null */
 	{
 		0,
+		"CompressionMethod.null",
 	},
 };
 =

@@ -459,9 +480,9 @@ static struct tls_compression_method *tls_find_compress=
ion_method(
 }
 =

 static const struct tls_hash_algorithm tls_handshake_hash_data[] =3D {
-	[HANDSHAKE_HASH_SHA256]	=3D { 4, L_CHECKSUM_SHA256, 32 },
-	[HANDSHAKE_HASH_MD5]	=3D { 1, L_CHECKSUM_MD5, 16 },
-	[HANDSHAKE_HASH_SHA1]	=3D { 2, L_CHECKSUM_SHA1, 20 },
+	[HANDSHAKE_HASH_SHA256]	=3D { 4, L_CHECKSUM_SHA256, 32, "SHA256" },
+	[HANDSHAKE_HASH_MD5]	=3D { 1, L_CHECKSUM_MD5, 16, "MD5" },
+	[HANDSHAKE_HASH_SHA1]	=3D { 2, L_CHECKSUM_SHA1, 20, "SHA1" },
 };
 =

 static bool tls_init_handshake_hash(struct l_tls *tls)
@@ -469,14 +490,20 @@ static bool tls_init_handshake_hash(struct l_tls *tls)
 	enum handshake_hash_type hash;
 =

 	for (hash =3D 0; hash < __HANDSHAKE_HASH_COUNT; hash++) {
-		if (tls->handshake_hash[hash])
+		if (tls->handshake_hash[hash]) {
+			TLS_DEBUG("Handshake hash %s already exists",
+					tls_handshake_hash_data[hash].name);
 			goto err;
+		}
 =

 		tls->handshake_hash[hash] =3D l_checksum_new(
 					tls_handshake_hash_data[hash].l_id);
 =

-		if (!tls->handshake_hash[hash])
+		if (!tls->handshake_hash[hash]) {
+			TLS_DEBUG("Can't create %s hash",
+					tls_handshake_hash_data[hash].name);
 			goto err;
+		}
 	}
 =

 	return true;
@@ -500,6 +527,31 @@ enum tls_handshake_type {
 	TLS_FINISHED		=3D 20,
 };
 =

+#define SWITCH_ENUM_TO_STR(val) \
+	case (val):		\
+		return L_STRINGIFY(val);
+
+static const char *tls_handshake_type_to_str(enum tls_handshake_type type)
+{
+	static char buf[40];
+
+	switch (type) {
+	SWITCH_ENUM_TO_STR(TLS_HELLO_REQUEST)
+	SWITCH_ENUM_TO_STR(TLS_CLIENT_HELLO)
+	SWITCH_ENUM_TO_STR(TLS_SERVER_HELLO)
+	SWITCH_ENUM_TO_STR(TLS_CERTIFICATE)
+	SWITCH_ENUM_TO_STR(TLS_SERVER_KEY_EXCHANGE)
+	SWITCH_ENUM_TO_STR(TLS_CERTIFICATE_REQUEST)
+	SWITCH_ENUM_TO_STR(TLS_SERVER_HELLO_DONE)
+	SWITCH_ENUM_TO_STR(TLS_CERTIFICATE_VERIFY)
+	SWITCH_ENUM_TO_STR(TLS_CLIENT_KEY_EXCHANGE)
+	SWITCH_ENUM_TO_STR(TLS_FINISHED)
+	}
+
+	snprintf(buf, sizeof(buf), "tls_handshake_type(%i)", type);
+	return buf;
+}
+
 static const uint8_t pkcs1_digest_info_md5_start[] =3D {
 	0x30, 0x20, 0x30, 0x0c, 0x06, 0x08, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d,
 	0x02, 0x05, 0x05, 0x00, 0x04, 0x10,
@@ -564,6 +616,9 @@ static void tls_send_alert(struct l_tls *tls, bool fata=
l,
 {
 	uint8_t buf[2];
 =

+	TLS_DEBUG("Sending a %s Alert: %s", fatal ? "Fatal" : "Warning",
+			l_tls_alert_to_str(alert_desc));
+
 	buf[0] =3D fatal ? 2 : 1;
 	buf[1] =3D alert_desc;
 =

@@ -601,6 +656,10 @@ static void tls_tx_handshake(struct l_tls *tls, int ty=
pe, uint8_t *buf,
 {
 	int i;
 =

+	TLS_DEBUG("Sending a %s of %zi bytes",
+			tls_handshake_type_to_str(type),
+			length - TLS_HANDSHAKE_HEADER_SIZE);
+
 	/* Fill in the handshake header */
 =

 	buf[0] =3D type;
@@ -693,15 +752,18 @@ static bool tls_send_certificate(struct l_tls *tls)
 		cert =3D NULL;
 =

 	if (tls->server && !cert) {
-		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR,
-						TLS_ALERT_BAD_CERT);
+		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, TLS_ALERT_BAD_CERT,
+				"Loading server certificate %s failed",
+				tls->cert_path);
 		return false;
 	}
 =

 	if (cert && !tls_cert_find_certchain(cert, tls->ca_cert_path)) {
 		if (tls->server) {
-			tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR,
-					TLS_ALERT_UNKNOWN_CA);
+			TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR,
+					TLS_ALERT_UNKNOWN_CA,
+					"Can't find certificate chain local "
+					"CA cert %s", tls->ca_cert_path);
 =

 			return false;
 		} else
@@ -711,8 +773,10 @@ static bool tls_send_certificate(struct l_tls *tls)
 	/* TODO: might want check this earlier and exclude the cipher suite */
 	if (cert && !tls->pending.cipher_suite->key_xchg->
 			validate_cert_key_type(cert)) {
-		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR,
-				TLS_ALERT_CERT_UNKNOWN);
+		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, TLS_ALERT_CERT_UNKNOWN,
+				"Local certificate has key type incompatible "
+				"with pending cipher suite %s",
+				tls->pending.cipher_suite->name);
 =

 		return false;
 	}
@@ -898,7 +962,8 @@ static bool tls_send_rsa_client_key_xchg(struct l_tls *=
tls)
 	ssize_t bytes_encrypted;
 =

 	if (!tls->peer_pubkey) {
-		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR, 0);
+		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
+				"Peer public key not received");
 =

 		return false;
 	}
@@ -908,7 +973,9 @@ static bool tls_send_rsa_client_key_xchg(struct l_tls *=
tls)
 	l_getrandom(pre_master_secret + 2, 46);
 =

 	if (tls->peer_pubkey_size + 32 > (int) sizeof(buf)) {
-		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR, 0);
+		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
+				"Peer public key too big: %zi",
+				tls->peer_pubkey_size);
 =

 		return false;
 	}
@@ -921,7 +988,9 @@ static bool tls_send_rsa_client_key_xchg(struct l_tls *=
tls)
 	ptr +=3D tls->peer_pubkey_size + 2;
 =

 	if (bytes_encrypted !=3D (ssize_t) tls->peer_pubkey_size) {
-		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR, 0);
+		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
+				"Encrypting PreMasterSecret failed: %s",
+				strerror(-bytes_encrypted));
 =

 		return false;
 	}
@@ -946,8 +1015,8 @@ static ssize_t tls_rsa_sign(struct l_tls *tls, uint8_t=
 *out, size_t len,
 	size_t expected_bytes;
 =

 	if (!tls->priv_key || !tls->priv_key_size) {
-		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR,
-				TLS_ALERT_BAD_CERT);
+		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, TLS_ALERT_BAD_CERT,
+				"No private key loaded");
 =

 		return -ENOKEY;
 	}
@@ -988,7 +1057,9 @@ static ssize_t tls_rsa_sign(struct l_tls *tls, uint8_t=
 *out, size_t len,
 	}
 =

 	if (result < 0)
-		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR, 0);
+		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
+				"Signing the hash failed: %s",
+				strerror(-result));
 =

 	return result;
 }
@@ -1011,14 +1082,18 @@ static bool tls_rsa_verify(struct l_tls *tls, const=
 uint8_t *in, size_t len,
 =

 	if (len < offset + 2 ||
 			(size_t) l_get_be16(in + offset) + offset + 2 !=3D len) {
-		tls_disconnect(tls, TLS_ALERT_DECODE_ERROR, 0);
+		TLS_DISCONNECT(TLS_ALERT_DECODE_ERROR, 0, "Signature msg too "
+				"short (%zi) or signature length doesn't match",
+				len);
 =

 		return false;
 	}
 =

 	/* Only the default hash type supported */
 	if (len !=3D offset + 2 + tls->peer_pubkey_size) {
-		tls_disconnect(tls, TLS_ALERT_DECODE_ERROR, 0);
+		TLS_DISCONNECT(TLS_ALERT_DECODE_ERROR, 0,
+				"Signature length %zi not equal %zi", len,
+				offset + 2 + tls->peer_pubkey_size);
 =

 		return false;
 	}
@@ -1026,13 +1101,16 @@ static bool tls_rsa_verify(struct l_tls *tls, const=
 uint8_t *in, size_t len,
 	if (tls->negotiated_version >=3D TLS_V12) {
 		/* Only RSA supported */
 		if (in[1] !=3D 1 /* RSA_sign */) {
-			tls_disconnect(tls, TLS_ALERT_DECRYPT_ERROR, 0);
+			TLS_DISCONNECT(TLS_ALERT_DECRYPT_ERROR, 0,
+					"Unknown signature algorithm %i",
+					in[1]);
 =

 			return false;
 		}
 =

 		if (!get_hash(tls, in[0], hash, &hash_len, &hash_type)) {
-			tls_disconnect(tls, TLS_ALERT_DECRYPT_ERROR, 0);
+			TLS_DISCONNECT(TLS_ALERT_DECRYPT_ERROR, 0,
+					"Unknown hash type %i", in[0]);
 =

 			return false;
 		}
@@ -1071,7 +1149,10 @@ static bool tls_rsa_verify(struct l_tls *tls, const =
uint8_t *in, size_t len,
 				expected_len, tls->peer_pubkey_size);
 =

 	if (!success)
-		tls_disconnect(tls, TLS_ALERT_DECRYPT_ERROR, 0);
+		TLS_DISCONNECT(TLS_ALERT_DECRYPT_ERROR, 0,
+				"Peer signature verification failed");
+	else
+		TLS_DEBUG("Peer signature verified");
 =

 	return success;
 }
@@ -1190,7 +1271,9 @@ static bool tls_verify_finished(struct l_tls *tls, co=
nst uint8_t *received,
 	size_t seed_len;
 =

 	if (len !=3D (size_t) tls->cipher_suite[0]->verify_data_length) {
-		tls_disconnect(tls, TLS_ALERT_DECODE_ERROR, 0);
+		TLS_DISCONNECT(TLS_ALERT_DECODE_ERROR, 0,
+				"TLS_FINISHED length not %i",
+				tls->cipher_suite[0]->verify_data_length);
 =

 		return false;
 	}
@@ -1214,7 +1297,8 @@ static bool tls_verify_finished(struct l_tls *tls, co=
nst uint8_t *received,
 				tls->cipher_suite[0]->verify_data_length);
 =

 	if (memcmp(received, expected, len)) {
-		tls_disconnect(tls, TLS_ALERT_DECRYPT_ERROR, 0);
+		TLS_DISCONNECT(TLS_ALERT_DECRYPT_ERROR, 0,
+				"TLS_FINISHED contents don't match");
 =

 		return false;
 	}
@@ -1306,7 +1390,9 @@ static void tls_handle_client_hello(struct l_tls *tls,
 	tls->client_version =3D l_get_be16(buf);
 =

 	if (tls->client_version < TLS_MIN_VERSION) {
-		tls_disconnect(tls, TLS_ALERT_PROTOCOL_VERSION, 0);
+		TLS_DISCONNECT(TLS_ALERT_PROTOCOL_VERSION, 0,
+				"Client version too low: %02x",
+				tls->client_version);
 		return;
 	}
 =

@@ -1319,6 +1405,8 @@ static void tls_handle_client_hello(struct l_tls *tls,
 			if (i !=3D HANDSHAKE_HASH_SHA1 && i !=3D HANDSHAKE_HASH_MD5)
 				tls_drop_handshake_hash(tls, i);
 =

+	TLS_DEBUG("Negotiated TLS 1.%i", (tls->negotiated_version & 0xff) - 1);
+
 	/* Select a cipher suite according to client's preference list */
 	while (cipher_suites_size) {
 		/*
@@ -1338,15 +1426,21 @@ static void tls_handle_client_hello(struct l_tls *t=
ls,
 	}
 =

 	if (!cipher_suites_size) {
-		tls_disconnect(tls, TLS_ALERT_HANDSHAKE_FAIL, 0);
+		TLS_DISCONNECT(TLS_ALERT_HANDSHAKE_FAIL, 0,
+				"No common cipher suites");
 		return;
 	}
 =

+	TLS_DEBUG("Negotiated %s", tls->pending.cipher_suite->name);
+
 	/* Select a compression method */
 =

 	/* CompressionMethod.null must be present in the vector */
-	if (!memchr(compression_methods, 0, compression_methods_size))
-		goto decode_error;
+	if (!memchr(compression_methods, 0, compression_methods_size)) {
+		TLS_DISCONNECT(TLS_ALERT_HANDSHAKE_FAIL, 0,
+				"No common compression methods");
+		return;
+	}
 =

 	while (compression_methods_size) {
 		tls->pending.compression_method =3D
@@ -1359,6 +1453,8 @@ static void tls_handle_client_hello(struct l_tls *tls,
 		compression_methods_size--;
 	}
 =

+	TLS_DEBUG("Negotiated %s", tls->pending.compression_method->name);
+
 	tls_send_server_hello(tls);
 =

 	if (tls->pending.cipher_suite->key_xchg->certificate_check &&
@@ -1376,14 +1472,15 @@ static void tls_handle_client_hello(struct l_tls *t=
ls,
 =

 	if (tls->pending.cipher_suite->key_xchg->certificate_check &&
 			tls->ca_cert_path)
-		tls->state =3D TLS_HANDSHAKE_WAIT_CERTIFICATE;
+		TLS_SET_STATE(TLS_HANDSHAKE_WAIT_CERTIFICATE);
 	else
-		tls->state =3D TLS_HANDSHAKE_WAIT_KEY_EXCHANGE;
+		TLS_SET_STATE(TLS_HANDSHAKE_WAIT_KEY_EXCHANGE);
 =

 	return;
 =

 decode_error:
-	tls_disconnect(tls, TLS_ALERT_DECODE_ERROR, 0);
+	TLS_DISCONNECT(TLS_ALERT_DECODE_ERROR, 0,
+			"ClientHello decode error");
 }
 =

 static void tls_handle_server_hello(struct l_tls *tls,
@@ -1410,7 +1507,8 @@ static void tls_handle_server_hello(struct l_tls *tls,
 	len -=3D session_id_size + 2 + 1;
 =

 	if (len !=3D 0) { /* We know we haven't solicited any extensions */
-		tls_disconnect(tls, TLS_ALERT_UNSUPPORTED_EXTENSION, 0);
+		TLS_DISCONNECT(TLS_ALERT_UNSUPPORTED_EXTENSION, 0,
+				"ServerHello contains extensions");
 		return;
 	}
 =

@@ -1418,9 +1516,11 @@ static void tls_handle_server_hello(struct l_tls *tl=
s,
 =

 	if (tls->negotiated_version < TLS_MIN_VERSION ||
 			tls->negotiated_version > TLS_VERSION) {
-		tls_disconnect(tls, tls->negotiated_version < TLS_MIN_VERSION ?
+		TLS_DISCONNECT(tls->negotiated_version < TLS_MIN_VERSION ?
 				TLS_ALERT_PROTOCOL_VERSION :
-				TLS_ALERT_ILLEGAL_PARAM, 0);
+				TLS_ALERT_ILLEGAL_PARAM, 0,
+				"Unsupported version %02x",
+				tls->negotiated_version);
 		return;
 	}
 =

@@ -1430,29 +1530,40 @@ static void tls_handle_server_hello(struct l_tls *t=
ls,
 			if (i !=3D HANDSHAKE_HASH_SHA1 && i !=3D HANDSHAKE_HASH_MD5)
 				tls_drop_handshake_hash(tls, i);
 =

+	TLS_DEBUG("Negotiated TLS 1.%i", (tls->negotiated_version & 0xff) - 1);
+
 	/* Set the new cipher suite and compression method structs */
 	tls->pending.cipher_suite =3D tls_find_cipher_suite(cipher_suite_id);
 	if (!tls->pending.cipher_suite) {
-		tls_disconnect(tls, TLS_ALERT_HANDSHAKE_FAIL, 0);
+		TLS_DISCONNECT(TLS_ALERT_HANDSHAKE_FAIL, 0,
+				"Unknown cipher suite %04x",
+				l_get_be16(cipher_suite_id));
 		return;
 	}
 =

+	TLS_DEBUG("Negotiated %s", tls->pending.cipher_suite->name);
+
 	tls->pending.compression_method =3D
 		tls_find_compression_method(compression_method_id);
 	if (!tls->pending.compression_method) {
-		tls_disconnect(tls, TLS_ALERT_HANDSHAKE_FAIL, 0);
+		TLS_DISCONNECT(TLS_ALERT_HANDSHAKE_FAIL, 0,
+				"Unknown compression method %i",
+				compression_method_id);
 		return;
 	}
 =

+	TLS_DEBUG("Negotiated %s", tls->pending.compression_method->name);
+
 	if (tls->pending.cipher_suite->key_xchg->certificate_check)
-		tls->state =3D TLS_HANDSHAKE_WAIT_CERTIFICATE;
+		TLS_SET_STATE(TLS_HANDSHAKE_WAIT_CERTIFICATE);
 	else
-		tls->state =3D TLS_HANDSHAKE_WAIT_KEY_EXCHANGE;
+		TLS_SET_STATE(TLS_HANDSHAKE_WAIT_KEY_EXCHANGE);
 =

 	return;
 =

 decode_error:
-	tls_disconnect(tls, TLS_ALERT_DECODE_ERROR, 0);
+	TLS_DISCONNECT(TLS_ALERT_DECODE_ERROR, 0,
+			"ServerHello decode error");
 }
 =

 static void tls_handle_certificate(struct l_tls *tls,
@@ -1473,8 +1584,12 @@ static void tls_handle_certificate(struct l_tls *tls,
 	if (total + 3 !=3D len)
 		goto decode_error;
 =

-	if (tls_cert_from_certificate_list(buf, total, &certchain) < 0)
-		goto decode_error;
+	if (tls_cert_from_certificate_list(buf, total, &certchain) < 0) {
+		TLS_DISCONNECT(TLS_ALERT_DECODE_ERROR, 0,
+				"Error decoding peer certificate chain");
+
+		goto done;
+	}
 =

 	/*
 	 * "Note that a client MAY send no certificates if it does not have any
@@ -1486,12 +1601,13 @@ static void tls_handle_certificate(struct l_tls *tl=
s,
 	 */
 	if (!certchain) {
 		if (!tls->server) {
-			tls_disconnect(tls, TLS_ALERT_HANDSHAKE_FAIL, 0);
+			TLS_DISCONNECT(TLS_ALERT_HANDSHAKE_FAIL, 0,
+					"Server sent no certificate chain");
 =

 			goto done;
 		}
 =

-		tls->state =3D TLS_HANDSHAKE_WAIT_KEY_EXCHANGE;
+		TLS_SET_STATE(TLS_HANDSHAKE_WAIT_KEY_EXCHANGE);
 =

 		goto done;
 	}
@@ -1504,15 +1620,18 @@ static void tls_handle_certificate(struct l_tls *tl=
s,
 	if (tls->ca_cert_path) {
 		ca_cert =3D tls_cert_load_file(tls->ca_cert_path);
 		if (!ca_cert) {
-			tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR,
-					TLS_ALERT_BAD_CERT);
+			TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR,
+					TLS_ALERT_BAD_CERT,
+					"Can't load %s", tls->ca_cert_path);
 =

 			goto done;
 		}
 	}
 =

 	if (!tls_cert_verify_certchain(certchain, ca_cert)) {
-		tls_disconnect(tls, TLS_ALERT_BAD_CERT, 0);
+		TLS_DISCONNECT(TLS_ALERT_BAD_CERT, 0,
+				"Peer certchain verification failed against "
+				"CA cert %s", tls->ca_cert_path);
 =

 		goto done;
 	}
@@ -1525,7 +1644,10 @@ static void tls_handle_certificate(struct l_tls *tls,
 	 */
 	if (!tls->pending.cipher_suite->key_xchg->
 			validate_cert_key_type(certchain)) {
-		tls_disconnect(tls, TLS_ALERT_UNSUPPORTED_CERT, 0);
+		TLS_DISCONNECT(TLS_ALERT_UNSUPPORTED_CERT, 0,
+				"Peer certificate key type incompatible with "
+				"pending cipher suite %s",
+				tls->pending.cipher_suite->name);
 =

 		goto done;
 	}
@@ -1540,7 +1662,8 @@ static void tls_handle_certificate(struct l_tls *tls,
 					tls->peer_cert->size);
 =

 	if (!tls->peer_pubkey) {
-		tls_disconnect(tls, TLS_ALERT_UNSUPPORTED_CERT, 0);
+		TLS_DISCONNECT(TLS_ALERT_UNSUPPORTED_CERT, 0,
+				"Error loading peer public key to kernel");
 =

 		goto done;
 	}
@@ -1548,7 +1671,8 @@ static void tls_handle_certificate(struct l_tls *tls,
 	if (!l_key_get_info(tls->peer_pubkey, L_KEY_RSA_PKCS1_V1_5,
 					L_CHECKSUM_NONE, &tls->peer_pubkey_size,
 					&dummy)) {
-		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR, 0);
+		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
+				"Can't l_key_get_info for peer public key");
 =

 		goto done;
 	}
@@ -1556,14 +1680,15 @@ static void tls_handle_certificate(struct l_tls *tl=
s,
 	tls->peer_pubkey_size /=3D 8;
 =

 	if (tls->server)
-		tls->state =3D TLS_HANDSHAKE_WAIT_KEY_EXCHANGE;
+		TLS_SET_STATE(TLS_HANDSHAKE_WAIT_KEY_EXCHANGE);
 	else
-		tls->state =3D TLS_HANDSHAKE_WAIT_HELLO_DONE;
+		TLS_SET_STATE(TLS_HANDSHAKE_WAIT_HELLO_DONE);
 =

 	goto done;
 =

 decode_error:
-	tls_disconnect(tls, TLS_ALERT_DECODE_ERROR, 0);
+	TLS_DISCONNECT(TLS_ALERT_DECODE_ERROR, 0,
+			"TLS_CERTIFICATE decode error");
 =

 done:
 	if (ca_cert)
@@ -1649,7 +1774,8 @@ static void tls_handle_certificate_request(struct l_t=
ls *tls,
 		else if ((int) first_supported !=3D -1)
 			tls->signature_hash =3D first_supported;
 		else {
-			tls_disconnect(tls, TLS_ALERT_UNSUPPORTED_CERT, 0);
+			TLS_DISCONNECT(TLS_ALERT_UNSUPPORTED_CERT, 0,
+					"No supported signature hash type");
 =

 			return;
 		}
@@ -1672,14 +1798,18 @@ static void tls_handle_certificate_request(struct l=
_tls *tls,
 	return;
 =

 decode_error:
-	tls_disconnect(tls, TLS_ALERT_DECODE_ERROR, 0);
+	TLS_DISCONNECT(TLS_ALERT_DECODE_ERROR, 0,
+			"CertificateRequest decode error");
 }
 =

 static void tls_handle_server_hello_done(struct l_tls *tls,
 						const uint8_t *buf, size_t len)
 {
+	const char *error;
+
 	if (len) {
-		tls_disconnect(tls, TLS_ALERT_DECODE_ERROR, 0);
+		TLS_DISCONNECT(TLS_ALERT_DECODE_ERROR, 0,
+				"ServerHello not empty");
 		return;
 	}
 =

@@ -1696,14 +1826,15 @@ static void tls_handle_server_hello_done(struct l_t=
ls *tls,
 =

 	tls_send_change_cipher_spec(tls);
 =

-	if (!tls_change_cipher_spec(tls, 1)) {
-		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR, 0);
+	if (!tls_change_cipher_spec(tls, 1, &error)) {
+		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
+				"change_cipher_spec: %s", error);
 		return;
 	}
 =

 	tls_send_finished(tls);
 =

-	tls->state =3D TLS_HANDSHAKE_WAIT_CHANGE_CIPHER_SPEC;
+	TLS_SET_STATE(TLS_HANDSHAKE_WAIT_CHANGE_CIPHER_SPEC);
 }
 =

 static void tls_handle_rsa_client_key_xchg(struct l_tls *tls,
@@ -1713,14 +1844,16 @@ static void tls_handle_rsa_client_key_xchg(struct l=
_tls *tls,
 	ssize_t bytes_decrypted;
 =

 	if (!tls->priv_key || !tls->priv_key_size) {
-		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR,
-				TLS_ALERT_BAD_CERT);
+		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, TLS_ALERT_BAD_CERT,
+				"No private key");
 =

 		return;
 	}
 =

 	if (len !=3D tls->priv_key_size + 2) {
-		tls_disconnect(tls, TLS_ALERT_DECODE_ERROR, 0);
+		TLS_DISCONNECT(TLS_ALERT_DECODE_ERROR, 0,
+				"ClientKeyExchange len %zi not %zi", len,
+				tls->priv_key_size + 2);
 =

 		return;
 	}
@@ -1728,7 +1861,9 @@ static void tls_handle_rsa_client_key_xchg(struct l_t=
ls *tls,
 	len =3D l_get_be16(buf);
 =

 	if (len !=3D tls->priv_key_size) {
-		tls_disconnect(tls, TLS_ALERT_DECODE_ERROR, 0);
+		TLS_DISCONNECT(TLS_ALERT_DECODE_ERROR, 0,
+				"EncryptedPreMasterSecret len %zi not %zi",
+				len, tls->priv_key_size);
 =

 		return;
 	}
@@ -1753,9 +1888,13 @@ static void tls_handle_rsa_client_key_xchg(struct l_=
tls *tls,
 	pre_master_secret[0] =3D tls->client_version >> 8;
 	pre_master_secret[1] =3D tls->client_version >> 0;
 =

-	if (bytes_decrypted !=3D 48)
+	if (bytes_decrypted !=3D 48) {
 		memcpy(pre_master_secret + 2, random_secret, 46);
 =

+		TLS_DEBUG("Error decrypting PreMasterSecret: %s",
+				strerror(-bytes_decrypted));
+	}
+
 	tls_generate_master_secret(tls, pre_master_secret, 48);
 	memset(pre_master_secret, 0, 48);
 	memset(random_secret, 0, 46);
@@ -1819,7 +1958,7 @@ static void tls_handle_certificate_verify(struct l_tl=
s *tls,
 	 */
 	tls->peer_authenticated =3D true;
 =

-	tls->state =3D TLS_HANDSHAKE_WAIT_CHANGE_CIPHER_SPEC;
+	TLS_SET_STATE(TLS_HANDSHAKE_WAIT_CHANGE_CIPHER_SPEC);
 }
 =

 static void tls_finished(struct l_tls *tls)
@@ -1829,7 +1968,7 @@ static void tls_finished(struct l_tls *tls)
 	/* Free up the resources used in the handshake */
 	tls_reset_handshake(tls);
 =

-	tls->state =3D TLS_HANDSHAKE_DONE;
+	TLS_SET_STATE(TLS_HANDSHAKE_DONE);
 	tls->ready =3D true;
 =

 	tls->ready_handle(peer_identity, tls->user_data);
@@ -1843,15 +1982,20 @@ static void tls_finished(struct l_tls *tls)
 static void tls_handle_handshake(struct l_tls *tls, int type,
 					const uint8_t *buf, size_t len)
 {
+	TLS_DEBUG("Handling a %s of %zi bytes",
+			tls_handshake_type_to_str(type), len);
+
 	switch (type) {
 	case TLS_HELLO_REQUEST:
 		if (tls->server) {
-			tls_disconnect(tls, TLS_ALERT_UNEXPECTED_MESSAGE, 0);
+			TLS_DISCONNECT(TLS_ALERT_UNEXPECTED_MESSAGE, 0,
+					"Message invalid in server mode");
 			break;
 		}
 =

 		if (len !=3D 0) {
-			tls_disconnect(tls, TLS_ALERT_DECODE_ERROR, 0);
+			TLS_DISCONNECT(TLS_ALERT_DECODE_ERROR, 0,
+					"HelloRequest not empty");
 			break;
 		}
 =

@@ -1866,13 +2010,16 @@ static void tls_handle_handshake(struct l_tls *tls,=
 int type,
 =

 	case TLS_CLIENT_HELLO:
 		if (!tls->server) {
-			tls_disconnect(tls, TLS_ALERT_UNEXPECTED_MESSAGE, 0);
+			TLS_DISCONNECT(TLS_ALERT_UNEXPECTED_MESSAGE, 0,
+					"Message invalid in client mode");
 			break;
 		}
 =

 		if (tls->state !=3D TLS_HANDSHAKE_WAIT_HELLO &&
 				tls->state !=3D TLS_HANDSHAKE_DONE) {
-			tls_disconnect(tls, TLS_ALERT_UNEXPECTED_MESSAGE, 0);
+			TLS_DISCONNECT(TLS_ALERT_UNEXPECTED_MESSAGE, 0,
+					"Message invalid in state %s",
+					tls_handshake_state_to_str(tls->state));
 			break;
 		}
 =

@@ -1882,12 +2029,15 @@ static void tls_handle_handshake(struct l_tls *tls,=
 int type,
 =

 	case TLS_SERVER_HELLO:
 		if (tls->server) {
-			tls_disconnect(tls, TLS_ALERT_UNEXPECTED_MESSAGE, 0);
+			TLS_DISCONNECT(TLS_ALERT_UNEXPECTED_MESSAGE, 0,
+					"Message invalid in server mode");
 			break;
 		}
 =

 		if (tls->state !=3D TLS_HANDSHAKE_WAIT_HELLO) {
-			tls_disconnect(tls, TLS_ALERT_UNEXPECTED_MESSAGE, 0);
+			TLS_DISCONNECT(TLS_ALERT_UNEXPECTED_MESSAGE, 0,
+					"Message invalid in state %s",
+					tls_handshake_state_to_str(tls->state));
 			break;
 		}
 =

@@ -1897,7 +2047,9 @@ static void tls_handle_handshake(struct l_tls *tls, i=
nt type,
 =

 	case TLS_CERTIFICATE:
 		if (tls->state !=3D TLS_HANDSHAKE_WAIT_CERTIFICATE) {
-			tls_disconnect(tls, TLS_ALERT_UNEXPECTED_MESSAGE, 0);
+			TLS_DISCONNECT(TLS_ALERT_UNEXPECTED_MESSAGE, 0,
+					"Message invalid in state %s",
+					tls_handshake_state_to_str(tls->state));
 			break;
 		}
 =

@@ -1914,7 +2066,10 @@ static void tls_handle_handshake(struct l_tls *tls, =
int type,
 				tls->cert_requested ||
 				!tls->pending.cipher_suite->key_xchg->
 				certificate_check) {
-			tls_disconnect(tls, TLS_ALERT_UNEXPECTED_MESSAGE, 0);
+			TLS_DISCONNECT(TLS_ALERT_UNEXPECTED_MESSAGE, 0,
+					"Message invalid in current state "
+					"or certificate check not supported "
+					"in pending cipher suite");
 			break;
 		}
 =

@@ -1924,7 +2079,9 @@ static void tls_handle_handshake(struct l_tls *tls, i=
nt type,
 =

 	case TLS_SERVER_HELLO_DONE:
 		if (tls->state !=3D TLS_HANDSHAKE_WAIT_HELLO_DONE) {
-			tls_disconnect(tls, TLS_ALERT_UNEXPECTED_MESSAGE, 0);
+			TLS_DISCONNECT(TLS_ALERT_UNEXPECTED_MESSAGE, 0,
+					"Message invalid in state %s",
+					tls_handshake_state_to_str(tls->state));
 			break;
 		}
 =

@@ -1934,7 +2091,9 @@ static void tls_handle_handshake(struct l_tls *tls, i=
nt type,
 =

 	case TLS_CERTIFICATE_VERIFY:
 		if (tls->state !=3D TLS_HANDSHAKE_WAIT_CERTIFICATE_VERIFY) {
-			tls_disconnect(tls, TLS_ALERT_UNEXPECTED_MESSAGE, 0);
+			TLS_DISCONNECT(TLS_ALERT_UNEXPECTED_MESSAGE, 0,
+					"Message invalid in state %s",
+					tls_handshake_state_to_str(tls->state));
 			break;
 		}
 =

@@ -1944,12 +2103,15 @@ static void tls_handle_handshake(struct l_tls *tls,=
 int type,
 =

 	case TLS_CLIENT_KEY_EXCHANGE:
 		if (!tls->server) {
-			tls_disconnect(tls, TLS_ALERT_UNEXPECTED_MESSAGE, 0);
+			TLS_DISCONNECT(TLS_ALERT_UNEXPECTED_MESSAGE, 0,
+					"Message invalid in client mode");
 			break;
 		}
 =

 		if (tls->state !=3D TLS_HANDSHAKE_WAIT_KEY_EXCHANGE) {
-			tls_disconnect(tls, TLS_ALERT_UNEXPECTED_MESSAGE, 0);
+			TLS_DISCONNECT(TLS_ALERT_UNEXPECTED_MESSAGE, 0,
+					"Message invalid in state %s",
+					tls_handshake_state_to_str(tls->state));
 			break;
 		}
 =

@@ -1964,15 +2126,17 @@ static void tls_handle_handshake(struct l_tls *tls,=
 int type,
 		 * this isn't 100% clear.
 		 */
 		if (tls->peer_pubkey)
-			tls->state =3D TLS_HANDSHAKE_WAIT_CERTIFICATE_VERIFY;
+			TLS_SET_STATE(TLS_HANDSHAKE_WAIT_CERTIFICATE_VERIFY);
 		else
-			tls->state =3D TLS_HANDSHAKE_WAIT_CHANGE_CIPHER_SPEC;
+			TLS_SET_STATE(TLS_HANDSHAKE_WAIT_CHANGE_CIPHER_SPEC);
 =

 		break;
 =

 	case TLS_FINISHED:
 		if (tls->state !=3D TLS_HANDSHAKE_WAIT_FINISHED) {
-			tls_disconnect(tls, TLS_ALERT_UNEXPECTED_MESSAGE, 0);
+			TLS_DISCONNECT(TLS_ALERT_UNEXPECTED_MESSAGE, 0,
+					"Message invalid in state %s",
+					tls_handshake_state_to_str(tls->state));
 			break;
 		}
 =

@@ -1980,10 +2144,13 @@ static void tls_handle_handshake(struct l_tls *tls,=
 int type,
 			break;
 =

 		if (tls->server) {
+			const char *error;
+
 			tls_send_change_cipher_spec(tls);
-			if (!tls_change_cipher_spec(tls, 1)) {
-				tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR,
-						0);
+			if (!tls_change_cipher_spec(tls, 1, &error)) {
+				TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
+						"change_cipher_spec: %s",
+						error);
 				break;
 			}
 			tls_send_finished(tls);
@@ -2014,7 +2181,8 @@ static void tls_handle_handshake(struct l_tls *tls, i=
nt type,
 		break;
 =

 	default:
-		tls_disconnect(tls, TLS_ALERT_UNEXPECTED_MESSAGE, 0);
+		TLS_DISCONNECT(TLS_ALERT_UNEXPECTED_MESSAGE, 0,
+				"Invalid message");
 	}
 }
 =

@@ -2048,7 +2216,7 @@ LIB_EXPORT struct l_tls *l_tls_new(bool server,
 		tls_send_client_hello(tls);
 	}
 =

-	tls->state =3D TLS_HANDSHAKE_WAIT_HELLO;
+	TLS_SET_STATE(TLS_HANDSHAKE_WAIT_HELLO);
 =

 	return tls;
 }
@@ -2078,6 +2246,9 @@ LIB_EXPORT void l_tls_free(struct l_tls *tls)
 	for (hash =3D 0; hash < __HANDSHAKE_HASH_COUNT; hash++)
 		tls_drop_handshake_hash(tls, hash);
 =

+	if (tls->debug_destroy)
+		tls->debug_destroy(tls->debug_data);
+
 	l_free(tls);
 }
 =

@@ -2094,35 +2265,42 @@ bool tls_handle_message(struct l_tls *tls, const ui=
nt8_t *message,
 			int len, enum tls_content_type type, uint16_t version)
 {
 	enum handshake_hash_type hash;
+	const char *error;
 =

 	switch (type) {
 	case TLS_CT_CHANGE_CIPHER_SPEC:
 		if (len !=3D 1 || message[0] !=3D 0x01) {
-			tls_disconnect(tls, TLS_ALERT_DECODE_ERROR, 0);
+			TLS_DISCONNECT(TLS_ALERT_DECODE_ERROR, 0,
+					"ChangeCipherSpec msg decode error");
 =

 			return false;
 		}
 =

 		if (tls->state !=3D TLS_HANDSHAKE_WAIT_CHANGE_CIPHER_SPEC) {
-			tls_disconnect(tls, TLS_ALERT_UNEXPECTED_MESSAGE, 0);
+			TLS_DISCONNECT(TLS_ALERT_UNEXPECTED_MESSAGE, 0,
+					"ChangeCipherSpec invalid in state %s",
+					tls_handshake_state_to_str(tls->state));
 =

 			return false;
 		}
 =

-		if (!tls_change_cipher_spec(tls, 0)) {
-			tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR, 0);
+		if (!tls_change_cipher_spec(tls, 0, &error)) {
+			TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
+					"change_cipher_spec: %s", error);
 =

 			return false;
 		}
 =

-		tls->state =3D TLS_HANDSHAKE_WAIT_FINISHED;
+		TLS_SET_STATE(TLS_HANDSHAKE_WAIT_FINISHED);
 =

 		return true;
 =

 	case TLS_CT_ALERT:
 		/* Verify AlertLevel */
 		if (message[0] !=3D 0x01 && message[0] !=3D 0x02) {
-			tls_disconnect(tls, TLS_ALERT_DECODE_ERROR, 0);
+			TLS_DISCONNECT(TLS_ALERT_DECODE_ERROR, 0,
+					"Received bad AlertLevel %i",
+					message[0]);
 =

 			return false;
 		}
@@ -2136,7 +2314,10 @@ bool tls_handle_message(struct l_tls *tls, const uin=
t8_t *message,
 		 * a fatal alert, then disconnect, so we do that
 		 * regardless of the alert level.
 		 */
-		tls_disconnect(tls, TLS_ALERT_CLOSE_NOTIFY, message[1]);
+		TLS_DISCONNECT(TLS_ALERT_CLOSE_NOTIFY, message[1],
+				"Peer sent a %s Alert: %s",
+				message[0] =3D=3D 0x02 ? "Fatal" : "Warning",
+				l_tls_alert_to_str(message[1]));
 =

 		return false;
 =

@@ -2196,7 +2377,9 @@ bool tls_handle_message(struct l_tls *tls, const uint=
8_t *message,
 =

 	case TLS_CT_APPLICATION_DATA:
 		if (!tls->ready) {
-			tls_disconnect(tls, TLS_ALERT_UNEXPECTED_MESSAGE, 0);
+			TLS_DISCONNECT(TLS_ALERT_UNEXPECTED_MESSAGE, 0,
+					"Application data message before "
+					"handshake finished");
 =

 			return false;
 		}
@@ -2214,11 +2397,13 @@ bool tls_handle_message(struct l_tls *tls, const ui=
nt8_t *message,
 =

 LIB_EXPORT void l_tls_close(struct l_tls *tls)
 {
-	tls_disconnect(tls, TLS_ALERT_CLOSE_NOTIFY, 0);
+	TLS_DISCONNECT(TLS_ALERT_CLOSE_NOTIFY, 0, "Closing session");
 }
 =

 LIB_EXPORT void l_tls_set_cacert(struct l_tls *tls, const char *ca_cert_pa=
th)
 {
+	TLS_DEBUG("ca-cert-path=3D%s", ca_cert_path);
+
 	if (tls->ca_cert_path) {
 		l_free(tls->ca_cert_path);
 		tls->ca_cert_path =3D NULL;
@@ -2232,6 +2417,9 @@ LIB_EXPORT bool l_tls_set_auth_data(struct l_tls *tls=
, const char *cert_path,
 					const char *priv_key_path,
 					const char *priv_key_passphrase)
 {
+	TLS_DEBUG("cert-path=3D%s priv-key-path=3D%s priv-key-passphrase=3D%p",
+			cert_path, priv_key_path, priv_key_passphrase);
+
 	if (tls->cert_path) {
 		l_free(tls->cert_path);
 		tls->cert_path =3D NULL;
@@ -2251,6 +2439,9 @@ LIB_EXPORT bool l_tls_set_auth_data(struct l_tls *tls=
, const char *cert_path,
 							priv_key_passphrase,
 							NULL,
 							&tls->priv_key_size);
+		TLS_DEBUG("l_pem_load_private_key returned %p, size %zi",
+				priv_key, tls->priv_key_size);
+
 		if (!priv_key)
 			return false;
 =

@@ -2262,6 +2453,7 @@ LIB_EXPORT bool l_tls_set_auth_data(struct l_tls *tls=
, const char *cert_path,
 		if (!l_key_get_info(tls->priv_key, L_KEY_RSA_PKCS1_V1_5,
 					L_CHECKSUM_NONE, &tls->priv_key_size,
 					&is_public) || is_public) {
+			TLS_DEBUG("Not a private key or l_key_get_info failed");
 			l_key_free(tls->priv_key);
 			tls->priv_key =3D NULL;
 			tls->priv_key_size =3D 0;
@@ -2335,6 +2527,25 @@ LIB_EXPORT const char *l_tls_alert_to_str(enum l_tls=
_alert_desc desc)
 	return NULL;
 }
 =

+const char *tls_handshake_state_to_str(enum tls_handshake_state state)
+{
+	static char buf[40];
+
+	switch (state) {
+	SWITCH_ENUM_TO_STR(TLS_HANDSHAKE_WAIT_HELLO)
+	SWITCH_ENUM_TO_STR(TLS_HANDSHAKE_WAIT_CERTIFICATE)
+	SWITCH_ENUM_TO_STR(TLS_HANDSHAKE_WAIT_KEY_EXCHANGE)
+	SWITCH_ENUM_TO_STR(TLS_HANDSHAKE_WAIT_HELLO_DONE)
+	SWITCH_ENUM_TO_STR(TLS_HANDSHAKE_WAIT_CERTIFICATE_VERIFY)
+	SWITCH_ENUM_TO_STR(TLS_HANDSHAKE_WAIT_CHANGE_CIPHER_SPEC)
+	SWITCH_ENUM_TO_STR(TLS_HANDSHAKE_WAIT_FINISHED)
+	SWITCH_ENUM_TO_STR(TLS_HANDSHAKE_DONE)
+	}
+
+	snprintf(buf, sizeof(buf), "tls_handshake_state(%i)", state);
+	return buf;
+}
+
 /* X509 Certificates and Certificate Chains */
 =

 #define X509_CERTIFICATE_POS			0
@@ -2581,3 +2792,19 @@ enum tls_cert_key_type tls_cert_get_pubkey_type(stru=
ct tls_cert *cert)
 =

 	return pkcs1_encryption_oids[i].key_type;
 }
+
+LIB_EXPORT bool l_tls_set_debug(struct l_tls *tls, l_tls_debug_cb_t functi=
on,
+				void *user_data, l_tls_destroy_cb_t destroy)
+{
+	if (unlikely(!tls))
+		return false;
+
+	if (tls->debug_destroy)
+		tls->debug_destroy(tls->debug_data);
+
+	tls->debug_handler =3D function;
+	tls->debug_destroy =3D destroy;
+	tls->debug_data =3D user_data;
+
+	return true;
+}
diff --git a/ell/tls.h b/ell/tls.h
index 9ab53fa..893fd63 100644
--- a/ell/tls.h
+++ b/ell/tls.h
@@ -60,6 +60,9 @@ typedef void (*l_tls_write_cb_t)(const uint8_t *data, siz=
e_t len,
 typedef void (*l_tls_ready_cb_t)(const char *peer_identity, void *user_dat=
a);
 typedef void (*l_tls_disconnect_cb_t)(enum l_tls_alert_desc reason,
 					bool remote, void *user_data);
+typedef void (*l_tls_debug_cb_t)(const char *str, void *user_data);
+typedef void (*l_tls_destroy_cb_t)(void *user_data);
+
 =

 /*
  * app_data_handler gets called with newly received decrypted data.
@@ -110,6 +113,9 @@ bool l_tls_prf_get_bytes(struct l_tls *tls,
 				size_t hash_len, bool use_master_secret,
 				const char *label, uint8_t *buf, size_t len);
 =

+bool l_tls_set_debug(struct l_tls *tls, l_tls_debug_cb_t function,
+			void *user_data, l_tls_destroy_cb_t destroy);
+
 #ifdef __cplusplus
 }
 #endif
-- =

2.19.1


--===============4518724317724970041==--

