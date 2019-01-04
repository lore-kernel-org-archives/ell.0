Content-Type: multipart/mixed; boundary="===============3749369255929069057=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 06/12] tls: Move cipher suite definitions to tls-suites.c
Date: Fri, 04 Jan 2019 02:26:34 +0100
Message-ID: <20190104012640.4022-6-andrew.zaborowski@intel.com>
In-Reply-To: <20190104012640.4022-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3749369255929069057==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Move the cipher suite-specific code to new file ell/tls-suites.c.
Unfortunately this requires a few functions and arrays to be exported
from tls.c.
---
 Makefile.am       |   1 +
 ell/tls-private.h |  25 +++
 ell/tls-suites.c  | 450 ++++++++++++++++++++++++++++++++++++++++++++
 ell/tls.c         | 465 ++--------------------------------------------
 4 files changed, 490 insertions(+), 451 deletions(-)
 create mode 100644 ell/tls-suites.c

diff --git a/Makefile.am b/Makefile.am
index 297c395..3eecbe0 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -103,6 +103,7 @@ ell_libell_la_SOURCES =3D $(linux_headers) \
 			ell/tls.c \
 			ell/tls-record.c \
 			ell/tls-extensions.c \
+			ell/tls-suites.c \
 			ell/uuid.c \
 			ell/key.c \
 			ell/pkcs5-private.h \
diff --git a/ell/tls-private.h b/ell/tls-private.h
index 938c358..442dc02 100644
--- a/ell/tls-private.h
+++ b/ell/tls-private.h
@@ -56,6 +56,8 @@ struct tls_hash_algorithm {
 	const char *name;
 };
 =

+extern const struct tls_hash_algorithm tls_handshake_hash_data[];
+
 typedef bool (*tls_get_hash_t)(struct l_tls *tls, uint8_t tls_id,
 				uint8_t *out, size_t *len,
 				enum l_checksum_type *type);
@@ -94,6 +96,8 @@ struct tls_cipher_suite {
 	enum l_checksum_type prf_hmac;
 };
 =

+extern struct tls_cipher_suite *tls_cipher_suite_pref[];
+
 struct tls_compression_method {
 	int id;
 	const char *name;
@@ -145,6 +149,19 @@ enum tls_content_type {
 	TLS_CT_APPLICATION_DATA		=3D 23,
 };
 =

+enum tls_handshake_type {
+	TLS_HELLO_REQUEST	=3D 0,
+	TLS_CLIENT_HELLO	=3D 1,
+	TLS_SERVER_HELLO	=3D 2,
+	TLS_CERTIFICATE		=3D 11,
+	TLS_SERVER_KEY_EXCHANGE	=3D 12,
+	TLS_CERTIFICATE_REQUEST	=3D 13,
+	TLS_SERVER_HELLO_DONE	=3D 14,
+	TLS_CERTIFICATE_VERIFY	=3D 15,
+	TLS_CLIENT_KEY_EXCHANGE	=3D 16,
+	TLS_FINISHED		=3D 20,
+};
+
 /*
  * Support the minimum required set of handshake hash types for the
  * Certificate Verify digital signature and the Finished PRF seed so we
@@ -269,9 +286,17 @@ void tls_tx_record(struct l_tls *tls, enum tls_content=
_type type,
 bool tls_handle_message(struct l_tls *tls, const uint8_t *message,
 			int len, enum tls_content_type type, uint16_t version);
 =

+#define TLS_HANDSHAKE_HEADER_SIZE	4
+
+void tls_tx_handshake(struct l_tls *tls, int type, uint8_t *buf, size_t le=
ngth);
+
 /* Optionally limit allowed cipher suites to a custom set */
 bool tls_set_cipher_suites(struct l_tls *tls, const char **suite_list);
 =

+void tls_generate_master_secret(struct l_tls *tls,
+				const uint8_t *pre_master_secret,
+				int pre_master_secret_len);
+
 int tls_parse_certificate_list(const void *data, size_t len,
 				struct l_certchain **out_certchain);
 =

diff --git a/ell/tls-suites.c b/ell/tls-suites.c
new file mode 100644
index 0000000..a3aed4c
--- /dev/null
+++ b/ell/tls-suites.c
@@ -0,0 +1,450 @@
+/*
+ *  Embedded Linux library
+ *
+ *  Copyright (C) 2018  Intel Corporation. All rights reserved.
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
+#include <stdlib.h>
+#include <errno.h>
+#include <string.h>
+
+#include "util.h"
+#include "tls.h"
+#include "cipher.h"
+#include "checksum.h"
+#include "cert.h"
+#include "tls-private.h"
+#include "key.h"
+#include "random.h"
+
+static bool tls_rsa_validate_cert_key(struct l_cert *cert)
+{
+	return l_cert_get_pubkey_type(cert) =3D=3D L_CERT_KEY_RSA;
+}
+
+static bool tls_send_rsa_client_key_xchg(struct l_tls *tls)
+{
+	uint8_t buf[1024 + 32];
+	uint8_t *ptr =3D buf + TLS_HANDSHAKE_HEADER_SIZE;
+	uint8_t pre_master_secret[48];
+	ssize_t bytes_encrypted;
+
+	if (!tls->peer_pubkey) {
+		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
+				"Peer public key not received");
+
+		return false;
+	}
+
+	/* Must match the version in tls_send_client_hello */
+	pre_master_secret[0] =3D (uint8_t) (TLS_VERSION >> 8);
+	pre_master_secret[1] =3D (uint8_t) (TLS_VERSION >> 0);
+
+	l_getrandom(pre_master_secret + 2, 46);
+
+	if (tls->peer_pubkey_size + 32 > (int) sizeof(buf)) {
+		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
+				"Peer public key too big: %zi",
+				tls->peer_pubkey_size);
+
+		return false;
+	}
+
+	l_put_be16(tls->peer_pubkey_size, ptr);
+	bytes_encrypted =3D l_key_encrypt(tls->peer_pubkey,
+					L_KEY_RSA_PKCS1_V1_5, L_CHECKSUM_NONE,
+					pre_master_secret, ptr + 2, 48,
+					tls->peer_pubkey_size);
+	ptr +=3D tls->peer_pubkey_size + 2;
+
+	if (bytes_encrypted !=3D (ssize_t) tls->peer_pubkey_size) {
+		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
+				"Encrypting PreMasterSecret failed: %s",
+				strerror(-bytes_encrypted));
+
+		return false;
+	}
+
+	tls_tx_handshake(tls, TLS_CLIENT_KEY_EXCHANGE, buf, ptr - buf);
+
+	tls_generate_master_secret(tls, pre_master_secret, 48);
+	memset(pre_master_secret, 0, 48);
+
+	return true;
+}
+
+static void tls_handle_rsa_client_key_xchg(struct l_tls *tls,
+						const uint8_t *buf, size_t len)
+{
+	uint8_t pre_master_secret[48], random_secret[46];
+	ssize_t bytes_decrypted;
+
+	if (!tls->priv_key || !tls->priv_key_size) {
+		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, TLS_ALERT_BAD_CERT,
+				"No private key");
+
+		return;
+	}
+
+	if (len !=3D tls->priv_key_size + 2) {
+		TLS_DISCONNECT(TLS_ALERT_DECODE_ERROR, 0,
+				"ClientKeyExchange len %zi not %zi", len,
+				tls->priv_key_size + 2);
+
+		return;
+	}
+
+	len =3D l_get_be16(buf);
+
+	if (len !=3D tls->priv_key_size) {
+		TLS_DISCONNECT(TLS_ALERT_DECODE_ERROR, 0,
+				"EncryptedPreMasterSecret len %zi not %zi",
+				len, tls->priv_key_size);
+
+		return;
+	}
+
+	bytes_decrypted =3D l_key_decrypt(tls->priv_key, L_KEY_RSA_PKCS1_V1_5,
+					L_CHECKSUM_NONE, buf + 2,
+					pre_master_secret, tls->priv_key_size,
+					48);
+
+	/*
+	 * Assume correct premaster secret client version which according
+	 * to the TLS1.2 spec is unlikely in client implementations SSLv3
+	 * and prior.  Spec suggests either not supporting them or adding
+	 * a configurable override for <=3D SSLv3 clients.  For now we have
+	 * no need to support them.
+	 *
+	 * On any decode error randomise the Pre Master Secret as per the
+	 * countermeasures in 7.4.7.1 and don't generate any alerts.
+	 */
+	l_getrandom(random_secret, 46);
+
+	pre_master_secret[0] =3D tls->client_version >> 8;
+	pre_master_secret[1] =3D tls->client_version >> 0;
+
+	if (bytes_decrypted !=3D 48) {
+		memcpy(pre_master_secret + 2, random_secret, 46);
+
+		TLS_DEBUG("Error decrypting PreMasterSecret: %s",
+				strerror(-bytes_decrypted));
+	}
+
+	tls_generate_master_secret(tls, pre_master_secret, 48);
+	memset(pre_master_secret, 0, 48);
+	memset(random_secret, 0, 46);
+}
+
+static ssize_t tls_rsa_sign(struct l_tls *tls, uint8_t *out, size_t len,
+				tls_get_hash_t get_hash)
+{
+	ssize_t result =3D -EMSGSIZE;
+	enum l_checksum_type sign_checksum_type;
+	uint8_t sign_input[HANDSHAKE_HASH_MAX_SIZE + 36];
+	size_t sign_input_len;
+	uint8_t *ptr =3D out;
+
+	if (!tls->priv_key || !tls->priv_key_size) {
+		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, TLS_ALERT_BAD_CERT,
+				"No private key loaded");
+
+		return -ENOKEY;
+	}
+
+	if (tls->negotiated_version >=3D L_TLS_V12) {
+		const struct tls_hash_algorithm *hash_type =3D
+			&tls_handshake_hash_data[tls->signature_hash];
+
+		/* Build the DigitallySigned struct */
+		if (len < 2)	/* Is there space for the algorithm IDs */
+			goto error;
+
+		get_hash(tls, hash_type->tls_id, sign_input, NULL, NULL);
+		sign_checksum_type =3D hash_type->l_id;
+		sign_input_len =3D hash_type->length;
+
+		*ptr++ =3D hash_type->tls_id;
+		*ptr++ =3D 1;	/* RSA_sign */
+		len -=3D 2;
+	} else {
+		get_hash(tls, 1, sign_input + 0, NULL, NULL);	/* MD5 */
+		get_hash(tls, 2, sign_input + 16, NULL, NULL);	/* SHA1 */
+		sign_checksum_type =3D L_CHECKSUM_NONE;
+		sign_input_len =3D 36;
+	}
+
+	if (len < tls->priv_key_size + 2)
+		goto error;
+
+	l_put_be16(tls->priv_key_size, ptr);
+	result =3D l_key_sign(tls->priv_key, L_KEY_RSA_PKCS1_V1_5,
+				sign_checksum_type, sign_input, ptr + 2,
+				sign_input_len, tls->priv_key_size);
+	ptr +=3D tls->priv_key_size + 2;
+
+	if (result =3D=3D (ssize_t) tls->priv_key_size)
+		return ptr - out; /* Success */
+
+error:
+	TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
+			"Signing the hash failed: %s",
+			strerror(-result));
+	return result;
+}
+
+static bool tls_rsa_verify(struct l_tls *tls, const uint8_t *in, size_t le=
n,
+				tls_get_hash_t get_hash)
+{
+	enum l_checksum_type hash_type;
+	uint8_t expected[HANDSHAKE_HASH_MAX_SIZE + 36];
+	size_t expected_len;
+	unsigned int offset;
+	bool success;
+
+	/* 2 bytes for SignatureAndHashAlgorithm if version >=3D 1.2 */
+	offset =3D 2;
+	if (tls->negotiated_version < L_TLS_V12)
+		offset =3D 0;
+
+	if (len < offset + 2 ||
+			(size_t) l_get_be16(in + offset) + offset + 2 !=3D len) {
+		TLS_DISCONNECT(TLS_ALERT_DECODE_ERROR, 0, "Signature msg too "
+				"short (%zi) or signature length doesn't match",
+				len);
+
+		return false;
+	}
+
+	/* Only the default hash type supported */
+	if (len !=3D offset + 2 + tls->peer_pubkey_size) {
+		TLS_DISCONNECT(TLS_ALERT_DECODE_ERROR, 0,
+				"Signature length %zi not equal %zi", len,
+				offset + 2 + tls->peer_pubkey_size);
+
+		return false;
+	}
+
+	if (tls->negotiated_version >=3D L_TLS_V12) {
+		/* Only RSA supported */
+		if (in[1] !=3D 1 /* RSA_sign */) {
+			TLS_DISCONNECT(TLS_ALERT_DECRYPT_ERROR, 0,
+					"Unknown signature algorithm %i",
+					in[1]);
+
+			return false;
+		}
+
+		if (!get_hash(tls, in[0], expected, &expected_len,
+				&hash_type)) {
+			TLS_DISCONNECT(TLS_ALERT_DECRYPT_ERROR, 0,
+					"Unknown hash type %i", in[0]);
+
+			return false;
+		}
+
+		/*
+		 * Note: Next we let the l_key_verify's underlying kernel
+		 * operation prepend the OID to the hash to build the
+		 * DigestInfo struct.  However according to 4.7 we need to
+		 * support at least two forms of the signed content in the
+		 * verification:
+		 *  - DigestInfo with NULL AlgorithmIdentifier.parameters,
+		 *  - DigestInfo with empty AlgorithmIdentifier.parameters,
+		 *
+		 * while the kernel only understands the former encoding.
+		 * Note PKCS#1 versions 2.0 and later section A.2.4 do
+		 * mandate NULL AlgorithmIdentifier.parameters.
+		 *
+		 * Additionally PKCS#1 v1.5 said BER is used in place of DER
+		 * for DigestInfo encoding which adds more ambiguity in the
+		 * encoding.
+		 */
+	} else {
+		get_hash(tls, 1, expected + 0, NULL, NULL);	/* MD5 */
+		get_hash(tls, 2, expected + 16, NULL, NULL);	/* SHA1 */
+		expected_len =3D 36;
+		hash_type =3D L_CHECKSUM_NONE;
+
+		/*
+		 * Note: Within the RSA padding for signatures PKCS#1 1.5
+		 * allows the block format to be either 0 or 1, while PKCS#1
+		 * v2.0+ mandates block type 1 making the signatures
+		 * unambiguous.  TLS 1.0 doesn't additionally specify which
+		 * block type is to be used (TLS 1.2 does) meaning that both
+		 * PKCS#1 v1.5 types are allowed.  The l_key_verify's
+		 * underlying kernel implementation only accepts block type
+		 * 1.  If this ever becomes an issue we'd need to go back to
+		 * using L_KEY_RSA_RAW and our own PKCS#1 v1.5 verify logic.
+		 */
+	}
+
+	success =3D l_key_verify(tls->peer_pubkey, L_KEY_RSA_PKCS1_V1_5,
+				hash_type, expected, in + offset + 2,
+				expected_len, tls->peer_pubkey_size);
+
+	if (!success)
+		TLS_DISCONNECT(TLS_ALERT_DECRYPT_ERROR, 0,
+				"Peer signature verification failed");
+	else
+		TLS_DEBUG("Peer signature verified");
+
+	return success;
+}
+
+static struct tls_key_exchange_algorithm tls_rsa =3D {
+	.id =3D 1, /* RSA_sign */
+	.certificate_check =3D true,
+	.validate_cert_key_type =3D tls_rsa_validate_cert_key,
+	.send_client_key_exchange =3D tls_send_rsa_client_key_xchg,
+	.handle_client_key_exchange =3D tls_handle_rsa_client_key_xchg,
+	.sign =3D tls_rsa_sign,
+	.verify =3D tls_rsa_verify,
+};
+
+static struct tls_bulk_encryption_algorithm tls_rc4 =3D {
+	.cipher_type =3D TLS_CIPHER_STREAM,
+	.l_id =3D L_CIPHER_ARC4,
+	.key_length =3D 16,
+}, tls_aes128 =3D {
+	.cipher_type =3D TLS_CIPHER_BLOCK,
+	.l_id =3D L_CIPHER_AES_CBC,
+	.key_length =3D 16,
+	.iv_length =3D 16,
+	.block_length =3D 16,
+}, tls_aes256 =3D {
+	.cipher_type =3D TLS_CIPHER_BLOCK,
+	.l_id =3D L_CIPHER_AES_CBC,
+	.key_length =3D 32,
+	.iv_length =3D 16,
+	.block_length =3D 16,
+}, tls_3des_ede =3D {
+	.cipher_type =3D TLS_CIPHER_BLOCK,
+	.l_id =3D L_CIPHER_DES3_EDE_CBC,
+	.key_length =3D 24,
+	.iv_length =3D 8,
+	.block_length =3D 8,
+}, tls_aes128_gcm =3D {
+	.cipher_type =3D TLS_CIPHER_AEAD,
+	.l_aead_id =3D L_AEAD_CIPHER_AES_GCM,
+	.key_length =3D 16,
+	.iv_length =3D 12,
+	.fixed_iv_length =3D 4,
+	.auth_tag_length =3D 16,
+}, tls_aes256_gcm =3D {
+	.cipher_type =3D TLS_CIPHER_AEAD,
+	.l_aead_id =3D L_AEAD_CIPHER_AES_GCM,
+	.key_length =3D 32,
+	.iv_length =3D 12,
+	.fixed_iv_length =3D 4,
+	.auth_tag_length =3D 16,
+};
+
+static struct tls_mac_algorithm tls_md5 =3D {
+	.id =3D 1,
+	.hmac_type =3D L_CHECKSUM_MD5,
+	.mac_length =3D 16,
+}, tls_sha =3D {
+	.id =3D 2,
+	.hmac_type =3D L_CHECKSUM_SHA1,
+	.mac_length =3D 20,
+}, tls_sha256 =3D {
+	.id =3D 4,
+	.hmac_type =3D L_CHECKSUM_SHA256,
+	.mac_length =3D 32,
+};
+
+static struct tls_cipher_suite tls_rsa_with_rc4_128_md5 =3D {
+	.id =3D { 0x00, 0x04 },
+	.name =3D "TLS_RSA_WITH_RC4_128_MD5",
+	.verify_data_length =3D 12,
+	.encryption =3D &tls_rc4,
+	.mac =3D &tls_md5,
+	.key_xchg =3D &tls_rsa,
+}, tls_rsa_with_rc4_128_sha =3D {
+	.id =3D { 0x00, 0x05 },
+	.name =3D "TLS_RSA_WITH_RC4_128_SHA",
+	.verify_data_length =3D 12,
+	.encryption =3D &tls_rc4,
+	.mac =3D &tls_sha,
+	.key_xchg =3D &tls_rsa,
+}, tls_rsa_with_3des_ede_cbc_sha =3D {
+	.id =3D { 0x00, 0x0a },
+	.name =3D "TLS_RSA_WITH_3DES_EDE_CBC_SHA",
+	.verify_data_length =3D 12,
+	.encryption =3D &tls_3des_ede,
+	.mac =3D &tls_sha,
+	.key_xchg =3D &tls_rsa,
+}, tls_rsa_with_aes_128_cbc_sha =3D {
+	.id =3D { 0x00, 0x2f },
+	.name =3D "TLS_RSA_WITH_AES_128_CBC_SHA",
+	.verify_data_length =3D 12,
+	.encryption =3D &tls_aes128,
+	.mac =3D &tls_sha,
+	.key_xchg =3D &tls_rsa,
+}, tls_rsa_with_aes_256_cbc_sha =3D {
+	.id =3D { 0x00, 0x35 },
+	.name =3D "TLS_RSA_WITH_AES_256_CBC_SHA",
+	.verify_data_length =3D 12,
+	.encryption =3D &tls_aes256,
+	.mac =3D &tls_sha,
+	.key_xchg =3D &tls_rsa,
+}, tls_rsa_with_aes_128_cbc_sha256 =3D {
+	.id =3D { 0x00, 0x3c },
+	.name =3D "TLS_RSA_WITH_AES_128_CBC_SHA256",
+	.verify_data_length =3D 12,
+	.encryption =3D &tls_aes128,
+	.mac =3D &tls_sha256,
+	.key_xchg =3D &tls_rsa,
+}, tls_rsa_with_aes_256_cbc_sha256 =3D {
+	.id =3D { 0x00, 0x3d },
+	.name =3D "TLS_RSA_WITH_AES_256_CBC_SHA256",
+	.verify_data_length =3D 12,
+	.encryption =3D &tls_aes256,
+	.mac =3D &tls_sha256,
+	.key_xchg =3D &tls_rsa,
+}, tls_rsa_with_aes_128_gcm_sha256 =3D {
+	.id =3D { 0x00, 0x9c },
+	.name =3D "TLS_RSA_WITH_AES_128_GCM_SHA256",
+	.verify_data_length =3D 12,
+	.encryption =3D &tls_aes128_gcm,
+	.key_xchg =3D &tls_rsa,
+}, tls_rsa_with_aes_256_gcm_sha384 =3D {
+	.id =3D { 0x00, 0x9d },
+	.name =3D "TLS_RSA_WITH_AES_256_GCM_SHA384",
+	.verify_data_length =3D 12,
+	.encryption =3D &tls_aes256_gcm,
+	.prf_hmac =3D L_CHECKSUM_SHA384,
+	.key_xchg =3D &tls_rsa,
+};
+
+struct tls_cipher_suite *tls_cipher_suite_pref[] =3D {
+	&tls_rsa_with_aes_256_cbc_sha,
+	&tls_rsa_with_aes_128_cbc_sha,
+	&tls_rsa_with_aes_256_cbc_sha256,
+	&tls_rsa_with_aes_128_cbc_sha256,
+	&tls_rsa_with_aes_256_gcm_sha384,
+	&tls_rsa_with_aes_128_gcm_sha256,
+	&tls_rsa_with_3des_ede_cbc_sha,
+	&tls_rsa_with_rc4_128_sha,
+	&tls_rsa_with_rc4_128_md5,
+	NULL,
+};
diff --git a/ell/tls.c b/ell/tls.c
index 413d80c..fe64456 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -378,158 +378,6 @@ static void tls_reset_cipher_spec(struct l_tls *tls, =
bool txrx)
 	tls_change_cipher_spec(tls, txrx, NULL);
 }
 =

-static bool tls_send_rsa_client_key_xchg(struct l_tls *tls);
-static void tls_handle_rsa_client_key_xchg(struct l_tls *tls,
-						const uint8_t *buf, size_t len);
-
-static ssize_t tls_rsa_sign(struct l_tls *tls, uint8_t *out, size_t len,
-				tls_get_hash_t get_hash);
-static bool tls_rsa_verify(struct l_tls *tls, const uint8_t *in, size_t le=
n,
-				tls_get_hash_t get_hash);
-
-static bool tls_rsa_validate_cert_key(struct l_cert *cert)
-{
-	return l_cert_get_pubkey_type(cert) =3D=3D L_CERT_KEY_RSA;
-}
-
-static struct tls_key_exchange_algorithm tls_rsa =3D {
-	.id =3D 1, /* RSA_sign */
-	.certificate_check =3D true,
-	.validate_cert_key_type =3D tls_rsa_validate_cert_key,
-	.send_client_key_exchange =3D tls_send_rsa_client_key_xchg,
-	.handle_client_key_exchange =3D tls_handle_rsa_client_key_xchg,
-	.sign =3D tls_rsa_sign,
-	.verify =3D tls_rsa_verify,
-};
-
-static struct tls_bulk_encryption_algorithm tls_rc4 =3D {
-	.cipher_type =3D TLS_CIPHER_STREAM,
-	.l_id =3D L_CIPHER_ARC4,
-	.key_length =3D 16,
-}, tls_aes128 =3D {
-	.cipher_type =3D TLS_CIPHER_BLOCK,
-	.l_id =3D L_CIPHER_AES_CBC,
-	.key_length =3D 16,
-	.iv_length =3D 16,
-	.block_length =3D 16,
-}, tls_aes256 =3D {
-	.cipher_type =3D TLS_CIPHER_BLOCK,
-	.l_id =3D L_CIPHER_AES_CBC,
-	.key_length =3D 32,
-	.iv_length =3D 16,
-	.block_length =3D 16,
-}, tls_3des_ede =3D {
-	.cipher_type =3D TLS_CIPHER_BLOCK,
-	.l_id =3D L_CIPHER_DES3_EDE_CBC,
-	.key_length =3D 24,
-	.iv_length =3D 8,
-	.block_length =3D 8,
-}, tls_aes128_gcm =3D {
-	.cipher_type =3D TLS_CIPHER_AEAD,
-	.l_aead_id =3D L_AEAD_CIPHER_AES_GCM,
-	.key_length =3D 16,
-	.iv_length =3D 12,
-	.fixed_iv_length =3D 4,
-	.auth_tag_length =3D 16,
-}, tls_aes256_gcm =3D {
-	.cipher_type =3D TLS_CIPHER_AEAD,
-	.l_aead_id =3D L_AEAD_CIPHER_AES_GCM,
-	.key_length =3D 32,
-	.iv_length =3D 12,
-	.fixed_iv_length =3D 4,
-	.auth_tag_length =3D 16,
-};
-
-static struct tls_mac_algorithm tls_md5 =3D {
-	.id =3D 1,
-	.hmac_type =3D L_CHECKSUM_MD5,
-	.mac_length =3D 16,
-}, tls_sha =3D {
-	.id =3D 2,
-	.hmac_type =3D L_CHECKSUM_SHA1,
-	.mac_length =3D 20,
-}, tls_sha256 =3D {
-	.id =3D 4,
-	.hmac_type =3D L_CHECKSUM_SHA256,
-	.mac_length =3D 32,
-};
-
-static struct tls_cipher_suite tls_rsa_with_rc4_128_md5 =3D {
-	.id =3D { 0x00, 0x04 },
-	.name =3D "TLS_RSA_WITH_RC4_128_MD5",
-	.verify_data_length =3D 12,
-	.encryption =3D &tls_rc4,
-	.mac =3D &tls_md5,
-	.key_xchg =3D &tls_rsa,
-}, tls_rsa_with_rc4_128_sha =3D {
-	.id =3D { 0x00, 0x05 },
-	.name =3D "TLS_RSA_WITH_RC4_128_SHA",
-	.verify_data_length =3D 12,
-	.encryption =3D &tls_rc4,
-	.mac =3D &tls_sha,
-	.key_xchg =3D &tls_rsa,
-}, tls_rsa_with_3des_ede_cbc_sha =3D {
-	.id =3D { 0x00, 0x0a },
-	.name =3D "TLS_RSA_WITH_3DES_EDE_CBC_SHA",
-	.verify_data_length =3D 12,
-	.encryption =3D &tls_3des_ede,
-	.mac =3D &tls_sha,
-	.key_xchg =3D &tls_rsa,
-}, tls_rsa_with_aes_128_cbc_sha =3D {
-	.id =3D { 0x00, 0x2f },
-	.name =3D "TLS_RSA_WITH_AES_128_CBC_SHA",
-	.verify_data_length =3D 12,
-	.encryption =3D &tls_aes128,
-	.mac =3D &tls_sha,
-	.key_xchg =3D &tls_rsa,
-}, tls_rsa_with_aes_256_cbc_sha =3D {
-	.id =3D { 0x00, 0x35 },
-	.name =3D "TLS_RSA_WITH_AES_256_CBC_SHA",
-	.verify_data_length =3D 12,
-	.encryption =3D &tls_aes256,
-	.mac =3D &tls_sha,
-	.key_xchg =3D &tls_rsa,
-}, tls_rsa_with_aes_128_cbc_sha256 =3D {
-	.id =3D { 0x00, 0x3c },
-	.name =3D "TLS_RSA_WITH_AES_128_CBC_SHA256",
-	.verify_data_length =3D 12,
-	.encryption =3D &tls_aes128,
-	.mac =3D &tls_sha256,
-	.key_xchg =3D &tls_rsa,
-}, tls_rsa_with_aes_256_cbc_sha256 =3D {
-	.id =3D { 0x00, 0x3d },
-	.name =3D "TLS_RSA_WITH_AES_256_CBC_SHA256",
-	.verify_data_length =3D 12,
-	.encryption =3D &tls_aes256,
-	.mac =3D &tls_sha256,
-	.key_xchg =3D &tls_rsa,
-}, tls_rsa_with_aes_128_gcm_sha256 =3D {
-	.id =3D { 0x00, 0x9c },
-	.name =3D "TLS_RSA_WITH_AES_128_GCM_SHA256",
-	.verify_data_length =3D 12,
-	.encryption =3D &tls_aes128_gcm,
-	.key_xchg =3D &tls_rsa,
-}, tls_rsa_with_aes_256_gcm_sha384 =3D {
-	.id =3D { 0x00, 0x9d },
-	.name =3D "TLS_RSA_WITH_AES_256_GCM_SHA384",
-	.verify_data_length =3D 12,
-	.encryption =3D &tls_aes256_gcm,
-	.prf_hmac =3D L_CHECKSUM_SHA384,
-	.key_xchg =3D &tls_rsa,
-};
-
-static struct tls_cipher_suite *tls_cipher_suite_pref[] =3D {
-	&tls_rsa_with_aes_256_cbc_sha,
-	&tls_rsa_with_aes_128_cbc_sha,
-	&tls_rsa_with_aes_256_cbc_sha256,
-	&tls_rsa_with_aes_128_cbc_sha256,
-	&tls_rsa_with_aes_256_gcm_sha384,
-	&tls_rsa_with_aes_128_gcm_sha256,
-	&tls_rsa_with_3des_ede_cbc_sha,
-	&tls_rsa_with_rc4_128_sha,
-	&tls_rsa_with_rc4_128_md5,
-};
-
 static bool tls_cipher_suite_is_compatible(struct l_tls *tls,
 					const struct tls_cipher_suite *suite,
 					const char **error)
@@ -629,12 +477,11 @@ static bool tls_cipher_suite_is_compatible(struct l_t=
ls *tls,
 =

 static struct tls_cipher_suite *tls_find_cipher_suite(const uint8_t *id)
 {
-	int i;
+	struct tls_cipher_suite **suite;
 =

-	for (i =3D 0; i < (int) L_ARRAY_SIZE(tls_cipher_suite_pref); i++)
-		if (tls_cipher_suite_pref[i]->id[0] =3D=3D id[0] &&
-				tls_cipher_suite_pref[i]->id[1] =3D=3D id[1])
-			return tls_cipher_suite_pref[i];
+	for (suite =3D tls_cipher_suite_pref; *suite; suite++)
+		if ((*suite)->id[0] =3D=3D id[0] && (*suite)->id[1] =3D=3D id[1])
+			return *suite;
 =

 	return NULL;
 }
@@ -658,7 +505,7 @@ static struct tls_compression_method *tls_find_compress=
ion_method(
 	return NULL;
 }
 =

-static const struct tls_hash_algorithm tls_handshake_hash_data[] =3D {
+const struct tls_hash_algorithm tls_handshake_hash_data[] =3D {
 	[HANDSHAKE_HASH_SHA384]	=3D { 5, L_CHECKSUM_SHA384, 48, "SHA384" },
 	[HANDSHAKE_HASH_SHA256]	=3D { 4, L_CHECKSUM_SHA256, 32, "SHA256" },
 	[HANDSHAKE_HASH_MD5]	=3D { 1, L_CHECKSUM_MD5, 16, "MD5" },
@@ -713,19 +560,6 @@ static const struct tls_hash_algorithm *tls_set_prf_hm=
ac(struct l_tls *tls)
 	return NULL;
 }
 =

-enum tls_handshake_type {
-	TLS_HELLO_REQUEST	=3D 0,
-	TLS_CLIENT_HELLO	=3D 1,
-	TLS_SERVER_HELLO	=3D 2,
-	TLS_CERTIFICATE		=3D 11,
-	TLS_SERVER_KEY_EXCHANGE	=3D 12,
-	TLS_CERTIFICATE_REQUEST	=3D 13,
-	TLS_SERVER_HELLO_DONE	=3D 14,
-	TLS_CERTIFICATE_VERIFY	=3D 15,
-	TLS_CLIENT_KEY_EXCHANGE	=3D 16,
-	TLS_FINISHED		=3D 20,
-};
-
 #define SWITCH_ENUM_TO_STR(val) \
 	case (val):		\
 		return L_STRINGIFY(val);
@@ -789,10 +623,7 @@ void tls_disconnect(struct l_tls *tls, enum l_tls_aler=
t_desc desc,
 				tls->user_data);
 }
 =

-#define TLS_HANDSHAKE_HEADER_SIZE	4
-
-static void tls_tx_handshake(struct l_tls *tls, int type, uint8_t *buf,
-				size_t length)
+void tls_tx_handshake(struct l_tls *tls, int type, uint8_t *buf, size_t le=
ngth)
 {
 	int i;
 =

@@ -903,8 +734,7 @@ static ssize_t tls_append_hello_extensions(struct l_tls=
 *tls,
 =

 static bool tls_send_client_hello(struct l_tls *tls)
 {
-	uint8_t buf[1024 + L_ARRAY_SIZE(tls_compression_pref) +
-			2 * L_ARRAY_SIZE(tls_cipher_suite_pref)];
+	uint8_t buf[1024 + L_ARRAY_SIZE(tls_compression_pref)];
 	uint8_t *ptr =3D buf + TLS_HANDSHAKE_HEADER_SIZE;
 	uint8_t *len_ptr;
 	unsigned int i;
@@ -1201,9 +1031,9 @@ static void tls_send_server_hello_done(struct l_tls *=
tls)
 				TLS_HANDSHAKE_HEADER_SIZE);
 }
 =

-static void tls_generate_master_secret(struct l_tls *tls,
-					const uint8_t *pre_master_secret,
-					int pre_master_secret_len)
+void tls_generate_master_secret(struct l_tls *tls,
+				const uint8_t *pre_master_secret,
+				int pre_master_secret_len)
 {
 	uint8_t seed[64];
 	int key_block_size;
@@ -1248,211 +1078,6 @@ static void tls_generate_master_secret(struct l_tls=
 *tls,
 	memset(seed, 0, 64);
 }
 =

-static bool tls_send_rsa_client_key_xchg(struct l_tls *tls)
-{
-	uint8_t buf[1024 + 32];
-	uint8_t *ptr =3D buf + TLS_HANDSHAKE_HEADER_SIZE;
-	uint8_t pre_master_secret[48];
-	ssize_t bytes_encrypted;
-
-	if (!tls->peer_pubkey) {
-		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
-				"Peer public key not received");
-
-		return false;
-	}
-
-	pre_master_secret[0] =3D (uint8_t) (TLS_VERSION >> 8);
-	pre_master_secret[1] =3D (uint8_t) (TLS_VERSION >> 0);
-	l_getrandom(pre_master_secret + 2, 46);
-
-	if (tls->peer_pubkey_size + 32 > (int) sizeof(buf)) {
-		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
-				"Peer public key too big: %zi",
-				tls->peer_pubkey_size);
-
-		return false;
-	}
-
-	l_put_be16(tls->peer_pubkey_size, ptr);
-	bytes_encrypted =3D l_key_encrypt(tls->peer_pubkey,
-					L_KEY_RSA_PKCS1_V1_5, L_CHECKSUM_NONE,
-					pre_master_secret, ptr + 2, 48,
-					tls->peer_pubkey_size);
-	ptr +=3D tls->peer_pubkey_size + 2;
-
-	if (bytes_encrypted !=3D (ssize_t) tls->peer_pubkey_size) {
-		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
-				"Encrypting PreMasterSecret failed: %s",
-				strerror(-bytes_encrypted));
-
-		return false;
-	}
-
-	tls_tx_handshake(tls, TLS_CLIENT_KEY_EXCHANGE, buf, ptr - buf);
-
-	tls_generate_master_secret(tls, pre_master_secret, 48);
-	memset(pre_master_secret, 0, 48);
-
-	return true;
-}
-
-static ssize_t tls_rsa_sign(struct l_tls *tls, uint8_t *out, size_t len,
-				tls_get_hash_t get_hash)
-{
-	ssize_t result =3D -EMSGSIZE;
-	enum l_checksum_type sign_checksum_type;
-	uint8_t sign_input[HANDSHAKE_HASH_MAX_SIZE + 36];
-	size_t sign_input_len;
-	uint8_t *ptr =3D out;
-
-	if (!tls->priv_key || !tls->priv_key_size) {
-		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, TLS_ALERT_BAD_CERT,
-				"No private key loaded");
-
-		return -ENOKEY;
-	}
-
-	if (tls->negotiated_version >=3D L_TLS_V12) {
-		const struct tls_hash_algorithm *hash_type =3D
-			&tls_handshake_hash_data[tls->signature_hash];
-
-		/* Build the DigitallySigned struct */
-		if (len < 2)	/* Is there space for the algorithm IDs */
-			goto error;
-
-		get_hash(tls, hash_type->tls_id, sign_input, NULL, NULL);
-		sign_checksum_type =3D hash_type->l_id;
-		sign_input_len =3D hash_type->length;
-
-		*ptr++ =3D hash_type->tls_id;
-		*ptr++ =3D 1;	/* RSA_sign */
-		len -=3D 2;
-	} else {
-		get_hash(tls, 1, sign_input + 0, NULL, NULL);	/* MD5 */
-		get_hash(tls, 2, sign_input + 16, NULL, NULL);	/* SHA1 */
-		sign_checksum_type =3D L_CHECKSUM_NONE;
-		sign_input_len =3D 36;
-	}
-
-	if (len < tls->priv_key_size + 2)
-		goto error;
-
-	l_put_be16(tls->priv_key_size, ptr);
-	result =3D l_key_sign(tls->priv_key, L_KEY_RSA_PKCS1_V1_5,
-				sign_checksum_type, sign_input, ptr + 2,
-				sign_input_len, tls->priv_key_size);
-	ptr +=3D tls->priv_key_size + 2;
-
-	if (result =3D=3D (ssize_t) tls->priv_key_size)
-		return ptr - out; /* Success */
-
-error:
-	TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
-			"Signing the hash failed: %s",
-			strerror(-result));
-	return result;
-}
-
-static bool tls_rsa_verify(struct l_tls *tls, const uint8_t *in, size_t le=
n,
-				tls_get_hash_t get_hash)
-{
-	enum l_checksum_type hash_type;
-	uint8_t expected[HANDSHAKE_HASH_MAX_SIZE + 36];
-	size_t expected_len;
-	unsigned int offset;
-	bool success;
-
-	/* 2 bytes for SignatureAndHashAlgorithm if version >=3D 1.2 */
-	offset =3D 2;
-	if (tls->negotiated_version < L_TLS_V12)
-		offset =3D 0;
-
-	if (len < offset + 2 ||
-			(size_t) l_get_be16(in + offset) + offset + 2 !=3D len) {
-		TLS_DISCONNECT(TLS_ALERT_DECODE_ERROR, 0, "Signature msg too "
-				"short (%zi) or signature length doesn't match",
-				len);
-
-		return false;
-	}
-
-	/* Only the default hash type supported */
-	if (len !=3D offset + 2 + tls->peer_pubkey_size) {
-		TLS_DISCONNECT(TLS_ALERT_DECODE_ERROR, 0,
-				"Signature length %zi not equal %zi", len,
-				offset + 2 + tls->peer_pubkey_size);
-
-		return false;
-	}
-
-	if (tls->negotiated_version >=3D L_TLS_V12) {
-		/* Only RSA supported */
-		if (in[1] !=3D 1 /* RSA_sign */) {
-			TLS_DISCONNECT(TLS_ALERT_DECRYPT_ERROR, 0,
-					"Unknown signature algorithm %i",
-					in[1]);
-
-			return false;
-		}
-
-		if (!get_hash(tls, in[0], expected, &expected_len,
-				&hash_type)) {
-			TLS_DISCONNECT(TLS_ALERT_DECRYPT_ERROR, 0,
-					"Unknown hash type %i", in[0]);
-
-			return false;
-		}
-
-		/*
-		 * Note: Next we let the l_key_verify's underlying kernel
-		 * operation prepend the OID to the hash to build the
-		 * DigestInfo struct.  However according to 4.7 we need to
-		 * support at least two forms of the signed content in the
-		 * verification:
-		 *  - DigestInfo with NULL AlgorithmIdentifier.parameters,
-		 *  - DigestInfo with empty AlgorithmIdentifier.parameters,
-		 *
-		 * while the kernel only understands the former encoding.
-		 * Note PKCS#1 versions 2.0 and later section A.2.4 do
-		 * mandate NULL AlgorithmIdentifier.parameters.
-		 *
-		 * Additionally PKCS#1 v1.5 said BER is used in place of DER
-		 * for DigestInfo encoding which adds more ambiguity in the
-		 * encoding.
-		 */
-	} else {
-		get_hash(tls, 1, expected + 0, NULL, NULL);	/* MD5 */
-		get_hash(tls, 2, expected + 16, NULL, NULL);	/* SHA1 */
-		expected_len =3D 36;
-		hash_type =3D L_CHECKSUM_NONE;
-
-		/*
-		 * Note: Within the RSA padding for signatures PKCS#1 1.5
-		 * allows the block format to be either 0 or 1, while PKCS#1
-		 * v2.0+ mandates block type 1 making the signatures
-		 * unambiguous.  TLS 1.0 doesn't additionally specify which
-		 * block type is to be used (TLS 1.2 does) meaning that both
-		 * PKCS#1 v1.5 types are allowed.  The l_key_verify's
-		 * underlying kernel implementation only accepts block type
-		 * 1.  If this ever becomes an issue we'd need to go back to
-		 * using L_KEY_RSA_RAW and our own PKCS#1 v1.5 verify logic.
-		 */
-	}
-
-	success =3D l_key_verify(tls->peer_pubkey, L_KEY_RSA_PKCS1_V1_5,
-				hash_type, expected, in + offset + 2,
-				expected_len, tls->peer_pubkey_size);
-
-	if (!success)
-		TLS_DISCONNECT(TLS_ALERT_DECRYPT_ERROR, 0,
-				"Peer signature verification failed");
-	else
-		TLS_DEBUG("Peer signature verified");
-
-	return success;
-}
-
 static void tls_get_handshake_hash(struct l_tls *tls,
 					enum handshake_hash_type type,
 					uint8_t *out)
@@ -2224,7 +1849,8 @@ static void tls_handle_certificate_request(struct l_t=
ls *tls,
 			hash_id =3D signature_hash_data[i + 0];
 =

 			/* Ignore hash types for signatures other than ours */
-			if (signature_hash_data[i + 1] !=3D tls_rsa.id)
+			if (signature_hash_data[i + 1] !=3D
+					tls->pending.cipher_suite->key_xchg->id)
 				continue;
 =

 			if (hash_id =3D=3D tls_handshake_hash_data[
@@ -2311,69 +1937,6 @@ static void tls_handle_server_hello_done(struct l_tl=
s *tls,
 	TLS_SET_STATE(TLS_HANDSHAKE_WAIT_CHANGE_CIPHER_SPEC);
 }
 =

-static void tls_handle_rsa_client_key_xchg(struct l_tls *tls,
-						const uint8_t *buf, size_t len)
-{
-	uint8_t pre_master_secret[48], random_secret[46];
-	ssize_t bytes_decrypted;
-
-	if (!tls->priv_key || !tls->priv_key_size) {
-		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, TLS_ALERT_BAD_CERT,
-				"No private key");
-
-		return;
-	}
-
-	if (len !=3D tls->priv_key_size + 2) {
-		TLS_DISCONNECT(TLS_ALERT_DECODE_ERROR, 0,
-				"ClientKeyExchange len %zi not %zi", len,
-				tls->priv_key_size + 2);
-
-		return;
-	}
-
-	len =3D l_get_be16(buf);
-
-	if (len !=3D tls->priv_key_size) {
-		TLS_DISCONNECT(TLS_ALERT_DECODE_ERROR, 0,
-				"EncryptedPreMasterSecret len %zi not %zi",
-				len, tls->priv_key_size);
-
-		return;
-	}
-
-	bytes_decrypted =3D l_key_decrypt(tls->priv_key, L_KEY_RSA_PKCS1_V1_5,
-					L_CHECKSUM_NONE, buf + 2,
-					pre_master_secret, tls->priv_key_size,
-					48);
-
-	/*
-	 * Assume correct premaster secret client version which according
-	 * to the TLS1.2 spec is unlikely in client implementations SSLv3
-	 * and prior.  Spec suggests either not supporting them or adding
-	 * a configurable override for <=3D SSLv3 clients.  For now we have
-	 * no need to support them.
-	 *
-	 * On any decode error randomise the Pre Master Secret as per the
-	 * countermeasures in 7.4.7.1 and don't generate any alerts.
-	 */
-	l_getrandom(random_secret, 46);
-
-	pre_master_secret[0] =3D tls->client_version >> 8;
-	pre_master_secret[1] =3D tls->client_version >> 0;
-
-	if (bytes_decrypted !=3D 48) {
-		memcpy(pre_master_secret + 2, random_secret, 46);
-
-		TLS_DEBUG("Error decrypting PreMasterSecret: %s",
-				strerror(-bytes_decrypted));
-	}
-
-	tls_generate_master_secret(tls, pre_master_secret, 48);
-	memset(pre_master_secret, 0, 48);
-	memset(random_secret, 0, 46);
-}
-
 static bool tls_get_prev_digest_by_id(struct l_tls *tls, uint8_t hash_id,
 					uint8_t *out, size_t *out_len,
 					enum l_checksum_type *type)
@@ -3067,12 +2630,12 @@ bool tls_set_cipher_suites(struct l_tls *tls, const=
 char **suite_list)
 	for (; *suite_list; suite_list++) {
 		unsigned int i;
 =

-		for (i =3D 0; i < L_ARRAY_SIZE(tls_cipher_suite_pref); i++)
+		for (i =3D 0; tls_cipher_suite_pref[i]; i++)
 			if (!strcmp(tls_cipher_suite_pref[i]->name,
 						*suite_list))
 				break;
 =

-		if (i < L_ARRAY_SIZE(tls_cipher_suite_pref))
+		if (tls_cipher_suite_pref[i])
 			*suite++ =3D tls_cipher_suite_pref[i];
 		else
 			TLS_DEBUG("Cipher suite %s is not supported",
-- =

2.19.1


--===============3749369255929069057==--

