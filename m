Content-Type: multipart/mixed; boundary="===============3898159820430521258=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 11/17] Add TLS utilities and definitions as ell/tls{.c, .h,
 -private.h}
Date: Fri, 24 Jul 2015 05:27:46 +0200
Message-ID: <1437708472-28124-2-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1437708472-28124-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3898159820430521258==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This is the groundwork for TLS support, only general structures are
added here and a part of the public API (l_tls_* functions).  Also
the cryptographic utilities for the TLS1.2 Pseudo Random Function
(RFC5246 section 5) and the pre-master-secret generation (section
8.1) and the Change Cipher Spec operation used at the end of a
succesful handshake are added.
---
 Makefile.am       |   7 +-
 ell/ell.h         |   1 +
 ell/tls-private.h | 185 ++++++++++++++++++++++++
 ell/tls.c         | 417 ++++++++++++++++++++++++++++++++++++++++++++++++++=
++++
 ell/tls.h         | 102 +++++++++++++
 5 files changed, 710 insertions(+), 2 deletions(-)
 create mode 100644 ell/tls-private.h
 create mode 100644 ell/tls.c
 create mode 100644 ell/tls.h

diff --git a/Makefile.am b/Makefile.am
index 4792544..da1f4f1 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -37,7 +37,8 @@ pkginclude_HEADERS =3D ell/ell.h \
 			ell/cipher.h \
 			ell/random.h \
 			ell/uintset.h \
-			ell/cert.h
+			ell/cert.h \
+			ell/tls.h
 =

 lib_LTLIBRARIES =3D ell/libell.la
 =

@@ -81,7 +82,9 @@ ell_libell_la_SOURCES =3D $(linux_headers) \
 			ell/cert-private.h \
 			ell/cert.c \
 			ell/rsa-private.h \
-			ell/rsa.c
+			ell/rsa.c \
+			ell/tls-private.h \
+			ell/tls.c
 =

 ell_libell_la_LDFLAGS =3D -no-undefined \
 			-version-info $(ELL_CURRENT):$(ELL_REVISION):$(ELL_AGE)
diff --git a/ell/ell.h b/ell/ell.h
index 2c88216..c3c8ce5 100644
--- a/ell/ell.h
+++ b/ell/ell.h
@@ -39,6 +39,7 @@
 #include <ell/random.h>
 #include <ell/uintset.h>
 #include <ell/cert.h>
+#include <ell/tls.h>
 =

 #include <ell/netlink.h>
 #include <ell/genl.h>
diff --git a/ell/tls-private.h b/ell/tls-private.h
new file mode 100644
index 0000000..033403a
--- /dev/null
+++ b/ell/tls-private.h
@@ -0,0 +1,185 @@
+/*
+ *
+ *  Embedded Linux library
+ *
+ *  Copyright (C) 2011-2014  Intel Corporation. All rights reserved.
+ *
+ *  This library is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU Lesser General Public
+ *  License as published by the Free Software Foundation; either
+ *  version 2.1 of the License, or (at your option) any later version.
+ *
+ *  This library is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ *  Lesser General Public License for more details.
+ *
+ *  You should have received a copy of the GNU Lesser General Public
+ *  License along with this library; if not, write to the Free Software
+ *  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 =
 USA
+ *
+ */
+
+/* Only TLS 1.2 supported */
+#define TLS_V12		((3 << 8) | 3)
+#define TLS_V11		((3 << 8) | 2)
+#define TLS_V10		((3 << 8) | 1)
+
+#define TLS_VERSION	TLS_V12
+#define TLS_MIN_VERSION	TLS_V10
+
+enum tls_cipher_type {
+	TLS_CIPHER_STREAM,
+	TLS_CIPHER_BLOCK,
+	TLS_CIPHER_AEAD,
+};
+
+struct tls_bulk_encryption_algorithm {
+	enum tls_cipher_type cipher_type;
+	enum l_cipher_type l_id;
+	size_t key_length;
+	size_t iv_length;
+	size_t block_length;
+};
+
+struct tls_key_exchange_algorithm {
+	uint8_t id;
+
+	bool certificate_check;
+	bool key_exchange_msg;
+
+	bool (*validate_cert_key_type)(struct l_cert *cert);
+
+	bool (*send_server_key_exchange)(struct l_tls *tls);
+	bool (*handle_server_key_exchange)(struct l_tls *tls,
+						const uint8_t *buf, size_t len);
+
+	bool (*send_client_key_exchange)(struct l_tls *tls);
+	void (*handle_client_key_exchange)(struct l_tls *tls,
+						const uint8_t *buf, size_t len);
+
+	bool (*sign)(struct l_tls *tls, uint8_t **out,
+			const uint8_t *hash);
+	bool (*verify)(struct l_tls *tls, const uint8_t *in, size_t len,
+			const uint8_t *hash);
+};
+
+struct tls_mac_algorithm {
+	uint8_t id;
+	enum l_checksum_type hmac_type;
+	size_t mac_length;
+};
+
+struct tls_cipher_suite {
+	uint8_t id[2];
+	const char *name;
+	int verify_data_length;
+
+	struct tls_bulk_encryption_algorithm *encryption;
+	struct tls_key_exchange_algorithm *key_xchg;
+	struct tls_mac_algorithm *mac;
+};
+
+struct tls_compression_method {
+	int id;
+};
+
+enum tls_handshake_state {
+	TLS_HANDSHAKE_WAIT_HELLO,
+	TLS_HANDSHAKE_WAIT_CERTIFICATE,
+	TLS_HANDSHAKE_WAIT_KEY_EXCHANGE,
+	TLS_HANDSHAKE_WAIT_HELLO_DONE,
+	TLS_HANDSHAKE_WAIT_CERTIFICATE_VERIFY,
+	TLS_HANDSHAKE_WAIT_CHANGE_CIPHER_SPEC,
+	TLS_HANDSHAKE_WAIT_FINISHED,
+	TLS_HANDSHAKE_DONE,
+};
+
+enum tls_content_type {
+	TLS_CT_CHANGE_CIPHER_SPEC	=3D 20,
+	TLS_CT_ALERT			=3D 21,
+	TLS_CT_HANDSHAKE		=3D 22,
+	TLS_CT_APPLICATION_DATA		=3D 23,
+};
+
+/*
+ * Decide the hash for the Certificate Verify digital signature and the
+ * Finished PRF seed so we don't have to accumulate all of messages full
+ * contents until the Finished message.  If we're sent a hash of different
+ * type and need to verify we'll give up.
+ */
+#define HANDSHAKE_HASH_TYPE	L_CHECKSUM_SHA256
+#define HANDSHAKE_HASH_SIZE	32
+#define HANDSHAKE_HASH_TYPE_TLS	4
+
+struct l_tls {
+	bool server;
+
+	l_tls_write_cb_t tx, rx;
+	l_tls_ready_cb_t ready_handle;
+	l_tls_disconnect_cb_t disconnected;
+	void *user_data;
+
+	char *ca_cert_path;
+	char *cert_path;
+	char *priv_key_path;
+	char *priv_key_passphrase;
+
+	/* Record layer */
+
+	uint8_t *record_buf;
+	int record_buf_len;
+	int record_buf_max_len;
+
+	uint8_t *message_buf;
+	int message_buf_len;
+	int message_buf_max_len;
+	enum tls_content_type message_content_type;
+
+	/* Handshake protocol layer */
+
+	enum tls_handshake_state state;
+	struct l_checksum *handshake_hash;
+	uint8_t prev_digest[HANDSHAKE_HASH_SIZE];
+
+	uint16_t client_version;
+	uint16_t negotiated_version;
+	bool cert_requested, cert_sent;
+	bool peer_authenticated;
+	struct l_cert *peer_cert;
+	uint8_t *peer_pubkey;
+	size_t peer_pubkey_length;
+
+	/* SecurityParameters current and pending */
+
+	struct {
+		struct tls_cipher_suite *cipher_suite;
+		struct tls_compression_method *compression_method;
+		uint8_t master_secret[48];
+		uint8_t client_random[32];
+		uint8_t server_random[32];
+		uint8_t key_block[136]; /* Max key block size per 6.3 v1.1 */
+	} pending;
+
+	enum tls_cipher_type cipher_type[2];
+	struct tls_cipher_suite *cipher_suite[2];
+	struct l_cipher *cipher[2];
+	struct l_checksum *mac[2];
+	size_t mac_length[2];
+	size_t block_length[2];
+	size_t record_iv_length[2];
+	uint64_t seq_num[2];
+	/*
+	 * Some of the key and IV parts of the "current" state are kept
+	 * inside the cipher and mac states in the kernel so we don't
+	 * duplicate them here.
+	 */
+
+	bool ready;
+};
+
+void tls12_prf(enum l_checksum_type type, size_t hash_len,
+		const uint8_t *secret, size_t secret_len,
+		const char *label,
+		const uint8_t *seed, size_t seed_len,
+		uint8_t *out, size_t out_len);
diff --git a/ell/tls.c b/ell/tls.c
new file mode 100644
index 0000000..5b4fea9
--- /dev/null
+++ b/ell/tls.c
@@ -0,0 +1,417 @@
+/*
+ *  Embedded Linux library
+ *
+ *  Copyright (C) 2015  Intel Corporation. All rights reserved.
+ *
+ *  This library is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU Lesser General Public
+ *  License as published by the Free Software Foundation; either
+ *  version 2.1 of the License, or (at your option) any later version.
+ *
+ *  This library is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ *  Lesser General Public License for more details.
+ *
+ *  You should have received a copy of the GNU Lesser General Public
+ *  License along with this library; if not, write to the Free Software
+ *  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 =
 USA
+ */
+
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif
+
+#define _GNU_SOURCE
+#include <alloca.h>
+#include <time.h>
+
+#include "util.h"
+#include "private.h"
+#include "tls.h"
+#include "checksum.h"
+#include "cipher.h"
+#include "random.h"
+#include "cert.h"
+#include "cert-private.h"
+#include "tls-private.h"
+#include "asn1-private.h"
+#include "rsa-private.h"
+
+void tls12_prf(enum l_checksum_type type, size_t hash_len,
+		const uint8_t *secret, size_t secret_len,
+		const char *label,
+		const uint8_t *seed, size_t seed_len,
+		uint8_t *out, size_t out_len)
+{
+	struct l_checksum *hmac =3D l_checksum_new_hmac(type, secret, secret_len);
+	size_t a_len, chunk_len, prfseed_len =3D strlen(label) + seed_len;
+	uint8_t a[128], prfseed[prfseed_len];
+
+	/* Generate the hash seed or A(0) as label + seed */
+	memcpy(prfseed, label, strlen(label));
+	memcpy(prfseed + strlen(label), seed, seed_len);
+
+	memcpy(a, prfseed, prfseed_len);
+	a_len =3D prfseed_len;
+
+	while (out_len) {
+		/* Generate A(i) */
+		l_checksum_reset(hmac);
+		l_checksum_update(hmac, a, a_len);
+		l_checksum_get_digest(hmac, a, hash_len);
+		a_len =3D hash_len;
+
+		/* Append seed & generate output */
+		memcpy(a + a_len, prfseed, prfseed_len);
+		l_checksum_reset(hmac);
+		l_checksum_update(hmac, a, a_len + prfseed_len);
+
+		chunk_len =3D out_len < hash_len ? out_len : hash_len;
+		l_checksum_get_digest(hmac, out, chunk_len);
+		out +=3D chunk_len;
+		out_len -=3D chunk_len;
+	}
+
+	l_checksum_free(hmac);
+}
+
+static void tls_reset_handshake(struct l_tls *tls)
+{
+	memset(tls->pending.master_secret, 0, 48);
+	memset(tls->pending.key_block, 0, sizeof(tls->pending.key_block));
+
+	if (tls->peer_cert) {
+		l_free(tls->peer_cert);
+
+		tls->peer_cert =3D NULL;
+		tls->peer_pubkey =3D NULL;
+	}
+
+	l_checksum_reset(tls->handshake_hash);
+
+	tls->state =3D TLS_HANDSHAKE_WAIT_HELLO;
+	tls->cert_requested =3D 0;
+	tls->cert_sent =3D 0;
+}
+
+static bool tls_change_cipher_spec(struct l_tls *tls, bool txrx)
+{
+	struct tls_bulk_encryption_algorithm *enc;
+	struct tls_mac_algorithm *mac;
+	int key_offset;
+
+	if (tls->cipher[txrx]) {
+		l_cipher_free(tls->cipher[txrx]);
+		tls->cipher[txrx] =3D NULL;
+		tls->cipher_type[txrx] =3D TLS_CIPHER_STREAM;
+	}
+
+	if (tls->mac[txrx]) {
+		l_checksum_free(tls->mac[txrx]);
+		tls->mac[txrx] =3D NULL;
+	}
+
+	tls->mac_length[txrx] =3D 0;
+	tls->block_length[txrx] =3D 0;
+	tls->record_iv_length[txrx] =3D 0;
+
+	tls->seq_num[txrx] =3D 0;
+
+	tls->cipher_suite[txrx] =3D tls->pending.cipher_suite;
+	if (!tls->cipher_suite[txrx])
+		return true;
+
+	key_offset =3D 0;
+
+	if (tls->cipher_suite[txrx]->mac) {
+		mac =3D tls->cipher_suite[txrx]->mac;
+
+		/* Server write / client read is 2nd in the key block */
+		if ((tls->server && txrx) || (!tls->server && !txrx))
+			key_offset +=3D mac->mac_length;
+
+		tls->mac[txrx] =3D l_checksum_new_hmac(mac->hmac_type,
+						tls->pending.key_block +
+						key_offset, mac->mac_length);
+
+		/* Wipe out the now unneeded part of the key block */
+		memset(tls->pending.key_block + key_offset, 0, mac->mac_length);
+
+		if (!tls->mac[txrx])
+			return false;
+
+		tls->mac_length[txrx] =3D mac->mac_length;
+
+		key_offset =3D 2 * mac->mac_length;
+	}
+
+	if (tls->cipher_suite[txrx]->encryption) {
+		enc =3D tls->cipher_suite[txrx]->encryption;
+
+		/* Server write / client read is 4th in the key block */
+		if ((tls->server && txrx) || (!tls->server && !txrx))
+			key_offset +=3D enc->key_length;
+
+		tls->cipher[txrx] =3D l_cipher_new(enc->l_id,
+						tls->pending.key_block +
+						key_offset, enc->key_length);
+
+		/* Wipe out the now unneeded part of the key block */
+		memset(tls->pending.key_block + key_offset, 0, enc->key_length);
+
+		if (!tls->cipher[txrx])
+			return false;
+
+		tls->cipher_type[txrx] =3D enc->cipher_type;
+		if (enc->cipher_type =3D=3D TLS_CIPHER_BLOCK) {
+			tls->record_iv_length[txrx] =3D enc->iv_length;
+			tls->block_length[txrx] =3D enc->block_length;
+		}
+	}
+
+	return true;
+}
+
+static void tls_reset_cipher_spec(struct l_tls *tls, bool txrx)
+{
+	/* Reset everything to the TLS_NULL_WITH_NULL_NULL state */
+
+	tls->pending.cipher_suite =3D NULL;
+
+	tls_change_cipher_spec(tls, txrx);
+}
+
+static struct tls_cipher_suite tls_cipher_suite_pref[] =3D {
+};
+
+static struct tls_cipher_suite *tls_find_cipher_suite(const uint8_t *id)
+{
+	int i;
+
+	for (i =3D 0; i < (int) L_ARRAY_SIZE(tls_cipher_suite_pref); i++)
+		if (tls_cipher_suite_pref[i].id[0] =3D=3D id[0] &&
+				tls_cipher_suite_pref[i].id[1] =3D=3D id[1])
+			return &tls_cipher_suite_pref[i];
+
+	return NULL;
+}
+
+static struct tls_compression_method tls_compression_pref[] =3D {
+	/* CompressionMethod.null */
+	{
+		0,
+	},
+};
+
+static struct tls_compression_method *tls_find_compression_method(
+							const uint8_t id)
+{
+	int i;
+
+	for (i =3D 0; i < (int) L_ARRAY_SIZE(tls_compression_pref); i++)
+		if (tls_compression_pref[i].id =3D=3D id)
+			return &tls_compression_pref[i];
+
+	return NULL;
+}
+
+static void tls_generate_master_secret(struct l_tls *tls,
+					const uint8_t *pre_master_secret,
+					int pre_master_secret_len)
+{
+	uint8_t seed[64];
+	int key_block_size;
+
+	memcpy(seed +  0, tls->pending.client_random, 32);
+	memcpy(seed + 32, tls->pending.server_random, 32);
+
+	tls12_prf(L_CHECKSUM_SHA256, 32,
+			pre_master_secret, pre_master_secret_len,
+			"master secret", seed, 64,
+			tls->pending.master_secret, 48);
+
+	/* Directly generate the key block while we're at it */
+
+	/* 2x fixed_IV_length to be added for AEAD suppot */
+	key_block_size =3D 2 * tls->pending.cipher_suite->encryption->key_length +
+		2 * tls->pending.cipher_suite->mac->mac_length;
+
+	/* Reverse order from the master secret seed */
+	memcpy(seed +  0, tls->pending.server_random, 32);
+	memcpy(seed + 32, tls->pending.client_random, 32);
+
+	tls12_prf(L_CHECKSUM_SHA256, 32, tls->pending.master_secret, 48,
+			"key expansion", seed, 64,
+			tls->pending.key_block, key_block_size);
+
+	memset(seed, 0, 64);
+	memset(tls->pending.client_random, 0, 32);
+	memset(tls->pending.server_random, 0, 32);
+}
+
+static void tls_get_handshake_hash(struct l_tls *tls, uint8_t *out)
+{
+	struct l_checksum *hash =3D l_checksum_clone(tls->handshake_hash);
+
+	if (!hash)
+		return;
+
+	l_checksum_get_digest(hash, out, HANDSHAKE_HASH_SIZE);
+
+	l_checksum_free(hash);
+}
+
+LIB_EXPORT struct l_tls *l_tls_new(bool server,
+				l_tls_write_cb_t app_data_handler,
+				l_tls_write_cb_t tx_handler,
+				l_tls_ready_cb_t ready_handler,
+				l_tls_disconnect_cb_t disconnect_handler,
+				void *user_data)
+{
+	struct l_tls *tls;
+
+	tls =3D l_new(struct l_tls, 1);
+	tls->server =3D server;
+	tls->rx =3D app_data_handler;
+	tls->tx =3D tx_handler;
+	tls->ready_handle =3D ready_handler;
+	tls->disconnected =3D disconnect_handler;
+	tls->user_data =3D user_data;
+
+	tls->handshake_hash =3D l_checksum_new(HANDSHAKE_HASH_TYPE);
+	if (!tls->handshake_hash) {
+		l_free(tls);
+		return NULL;
+	}
+
+	tls_reset_handshake(tls);
+
+	/* If we're the client, start the handshake right away */
+	if (!tls->server)
+		tls_send_client_hello(tls);
+
+	tls->state =3D TLS_HANDSHAKE_WAIT_HELLO;
+
+	return tls;
+}
+
+LIB_EXPORT void l_tls_free(struct l_tls *tls)
+{
+	if (unlikely(!tls))
+		return;
+
+	l_tls_set_cacert(tls, NULL);
+	l_tls_set_auth_data(tls, NULL, NULL, NULL);
+
+	tls_reset_handshake(tls);
+
+	tls_reset_cipher_spec(tls, 0);
+	tls_reset_cipher_spec(tls, 1);
+
+	if (tls->record_buf)
+		l_free(tls->record_buf);
+
+	if (tls->message_buf)
+		l_free(tls->message_buf);
+
+	l_checksum_free(tls->handshake_hash);
+
+	l_free(tls);
+}
+
+LIB_EXPORT void l_tls_set_cacert(struct l_tls *tls, const char *ca_cert_pa=
th)
+{
+	if (tls->ca_cert_path) {
+		l_free(tls->ca_cert_path);
+		tls->ca_cert_path =3D NULL;
+	}
+
+	if (ca_cert_path)
+		tls->ca_cert_path =3D l_strdup(ca_cert_path);
+}
+
+LIB_EXPORT void l_tls_set_auth_data(struct l_tls *tls, const char *cert_pa=
th,
+				const char *priv_key_path,
+				const char *priv_key_passphrase)
+{
+	if (tls->cert_path) {
+		l_free(tls->cert_path);
+		l_free(tls->priv_key_path);
+		tls->cert_path =3D NULL;
+		tls->priv_key_path =3D NULL;
+	}
+
+	if (cert_path) {
+		tls->cert_path =3D l_strdup(cert_path);
+		tls->priv_key_path =3D l_strdup(priv_key_path);
+	}
+
+	if (tls->priv_key_passphrase) {
+		memset(tls->priv_key_passphrase, 0,
+				strlen(tls->priv_key_passphrase));
+		l_free(tls->priv_key_passphrase);
+		tls->priv_key_passphrase =3D NULL;
+	}
+
+	if (priv_key_passphrase)
+		tls->priv_key_passphrase =3D l_strdup(priv_key_passphrase);
+}
+
+LIB_EXPORT const char *l_tls_alert_to_str(enum l_tls_alert_desc desc)
+{
+	switch (desc) {
+	case TLS_ALERT_CLOSE_NOTIFY:
+		return "close_notify";
+	case TLS_ALERT_UNEXPECTED_MESSAGE:
+		return "unexpected_message";
+	case TLS_ALERT_BAD_RECORD_MAC:
+		return "bad_record_mac";
+	case TLS_ALERT_DECRYPT_FAIL_RESERVED:
+		return "decryption_failure_RESERVED";
+	case TLS_ALERT_RECORD_OVERFLOW:
+		return "record_overflow";
+	case TLS_ALERT_DECOMPRESS_FAIL:
+		return "decompression_failure";
+	case TLS_ALERT_HANDSHAKE_FAIL:
+		return "handshake_failure";
+	case TLS_ALERT_NO_CERT_RESERVED:
+		return "no_certificate_RESERVED";
+	case TLS_ALERT_BAD_CERT:
+		return "bad_certificate";
+	case TLS_ALERT_UNSUPPORTED_CERT:
+		return "unsupported_certificate";
+	case TLS_ALERT_CERT_REVOKED:
+		return "certificate_revoked";
+	case TLS_ALERT_CERT_EXPIRED:
+		return "certificate_expired";
+	case TLS_ALERT_CERT_UNKNOWN:
+		return "certificate_unknown";
+	case TLS_ALERT_ILLEGAL_PARAM:
+		return "illegal_parameter";
+	case TLS_ALERT_UNKNOWN_CA:
+		return "unknown_ca";
+	case TLS_ALERT_ACCESS_DENIED:
+		return "access_denied";
+	case TLS_ALERT_DECODE_ERROR:
+		return "decode_error";
+	case TLS_ALERT_DECRYPT_ERROR:
+		return "decrypt_error";
+	case TLS_ALERT_EXPORT_RES_RESERVED:
+		return "export_restriction_RESERVED";
+	case TLS_ALERT_PROTOCOL_VERSION:
+		return "protocol_version";
+	case TLS_ALERT_INSUFFICIENT_SECURITY:
+		return "insufficient_security";
+	case TLS_ALERT_INTERNAL_ERROR:
+		return "internal_error";
+	case TLS_ALERT_USER_CANCELED:
+		return "user_canceled";
+	case TLS_ALERT_NO_RENEGOTIATION:
+		return "no_renegotiation";
+	case TLS_ALERT_UNSUPPORTED_EXTENSION:
+		return "unsupported_extension";
+	}
+
+	return NULL;
+}
diff --git a/ell/tls.h b/ell/tls.h
new file mode 100644
index 0000000..86c8521
--- /dev/null
+++ b/ell/tls.h
@@ -0,0 +1,102 @@
+/*
+ *  Embedded Linux library
+ *
+ *  Copyright (C) 2015  Intel Corporation. All rights reserved.
+ *
+ *  This library is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU Lesser General Public
+ *  License as published by the Free Software Foundation; either
+ *  version 2.1 of the License, or (at your option) any later version.
+ *
+ *  This library is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ *  Lesser General Public License for more details.
+ *
+ *  You should have received a copy of the GNU Lesser General Public
+ *  License along with this library; if not, write to the Free Software
+ *  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 =
 USA
+ */
+
+#ifndef __ELL_TLS_H
+#define __ELL_TLS_H
+
+#ifdef __cplusplus
+extern "C" {
+#endif
+
+struct l_tls;
+
+enum l_tls_alert_desc {
+	TLS_ALERT_CLOSE_NOTIFY		=3D 0,
+	TLS_ALERT_UNEXPECTED_MESSAGE	=3D 10,
+	TLS_ALERT_BAD_RECORD_MAC	=3D 20,
+	TLS_ALERT_DECRYPT_FAIL_RESERVED	=3D 21,
+	TLS_ALERT_RECORD_OVERFLOW	=3D 22,
+	TLS_ALERT_DECOMPRESS_FAIL	=3D 30,
+	TLS_ALERT_HANDSHAKE_FAIL	=3D 40,
+	TLS_ALERT_NO_CERT_RESERVED	=3D 41,
+	TLS_ALERT_BAD_CERT		=3D 42,
+	TLS_ALERT_UNSUPPORTED_CERT	=3D 43,
+	TLS_ALERT_CERT_REVOKED		=3D 44,
+	TLS_ALERT_CERT_EXPIRED		=3D 45,
+	TLS_ALERT_CERT_UNKNOWN		=3D 46,
+	TLS_ALERT_ILLEGAL_PARAM		=3D 47,
+	TLS_ALERT_UNKNOWN_CA		=3D 48,
+	TLS_ALERT_ACCESS_DENIED		=3D 49,
+	TLS_ALERT_DECODE_ERROR		=3D 50,
+	TLS_ALERT_DECRYPT_ERROR		=3D 51,
+	TLS_ALERT_EXPORT_RES_RESERVED	=3D 60,
+	TLS_ALERT_PROTOCOL_VERSION	=3D 70,
+	TLS_ALERT_INSUFFICIENT_SECURITY	=3D 71,
+	TLS_ALERT_INTERNAL_ERROR	=3D 80,
+	TLS_ALERT_USER_CANCELED		=3D 90,
+	TLS_ALERT_NO_RENEGOTIATION	=3D 100,
+	TLS_ALERT_UNSUPPORTED_EXTENSION	=3D 110,
+};
+
+typedef void (*l_tls_write_cb_t)(void *user_data, const uint8_t *data,
+					size_t len);
+typedef void (*l_tls_ready_cb_t)(void *user_data, const char *peer_identit=
y);
+typedef void (*l_tls_disconnect_cb_t)(void *user_data,
+					enum l_tls_alert_desc reason,
+					bool remote);
+
+/*
+ * app_data_handler gets called with newly received decrypted data.
+ * tx_handler gets called to send TLS payloads off to remote end.
+ * ready_handler gets called when l_tls_write calls are first accepted.
+ */
+struct l_tls *l_tls_new(bool server, l_tls_write_cb_t app_data_handler,
+			l_tls_write_cb_t tx_handler,
+			l_tls_ready_cb_t ready_handler,
+			l_tls_disconnect_cb_t disconnect_handler,
+			void *user_data);
+
+void l_tls_free(struct l_tls *tls);
+
+/* If peer is to be authenticated, supply the CA certificate */
+void l_tls_set_cacert(struct l_tls *tls, const char *ca_cert_path);
+
+/*
+ * If we are to be authenticated, supply our certificate, private key and
+ * private key passphrase if needed (or NULL).  On the client this is opti=
onal,
+ * but if supplied, negotiation will fail if the certificate type doesn't
+ * match or one of the files can't be loaded.
+ * TODO: accept a callback to be used for passphrase query.
+ * TODO: allow NULL private key if certificate file contains the key.
+ * TODO: it may also be useful for the caller to be able to supply
+ * one certificate of each type so they can be used depending on which
+ * is compatible with the negotiated parameters.
+ */
+void l_tls_set_auth_data(struct l_tls *tls, const char *cert_path,
+				const char *priv_key_path,
+				const char *priv_key_passphrase);
+
+const char *l_tls_alert_to_str(enum l_tls_alert_desc desc);
+
+#ifdef __cplusplus
+}
+#endif
+
+#endif /* __ELL_TLS_H */
-- =

2.1.4


--===============3898159820430521258==--

