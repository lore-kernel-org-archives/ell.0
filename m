Content-Type: multipart/mixed; boundary="===============8503755159416523704=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 13/17] tls: TLS Record Protocol layer.
Date: Fri, 24 Jul 2015 05:27:48 +0200
Message-ID: <1437708472-28124-4-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1437708472-28124-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8503755159416523704==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The Record Protocol is the lower of the two layers in TLS, described
in section 6 of RFC5246.  tls_tx_record in tls-record.c is called by
the higher layer to send Handshake messages during set up, to report
errors and to transmit application data to the peer.  The Record
layer in turn calls tls_handle_message (not in this patch) in tls.c
when an incoming message of any of these types is decoded.
---
 Makefile.am       |   3 +-
 ell/tls-private.h |   9 +
 ell/tls-record.c  | 508 ++++++++++++++++++++++++++++++++++++++++++++++++++=
++++
 ell/tls.c         |  47 +++++
 ell/tls.h         |   9 +
 5 files changed, 575 insertions(+), 1 deletion(-)
 create mode 100644 ell/tls-record.c

diff --git a/Makefile.am b/Makefile.am
index 29bf54e..0896100 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -84,7 +84,8 @@ ell_libell_la_SOURCES =3D $(linux_headers) \
 			ell/rsa-private.h \
 			ell/rsa.c \
 			ell/tls-private.h \
-			ell/tls.c
+			ell/tls.c \
+			ell/tls-record.c
 =

 ell_libell_la_LDFLAGS =3D -no-undefined \
 			-version-info $(ELL_CURRENT):$(ELL_REVISION):$(ELL_AGE)
diff --git a/ell/tls-private.h b/ell/tls-private.h
index 033403a..ff7e51f 100644
--- a/ell/tls-private.h
+++ b/ell/tls-private.h
@@ -183,3 +183,12 @@ void tls12_prf(enum l_checksum_type type, size_t hash_=
len,
 		const char *label,
 		const uint8_t *seed, size_t seed_len,
 		uint8_t *out, size_t out_len);
+
+void tls_disconnect(struct l_tls *tls, enum l_tls_alert_desc desc,
+			enum l_tls_alert_desc local_desc);
+
+void tls_tx_record(struct l_tls *tls, enum tls_content_type type,
+			const uint8_t *data, size_t len);
+
+bool tls_handle_message(struct l_tls *tls, const uint8_t *message,
+			int len, uint8_t type, uint16_t version);
diff --git a/ell/tls-record.c b/ell/tls-record.c
new file mode 100644
index 0000000..3217fec
--- /dev/null
+++ b/ell/tls-record.c
@@ -0,0 +1,508 @@
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
+
+#include "private.h"
+#include "tls.h"
+#include "checksum.h"
+#include "cipher.h"
+#include "cert.h"
+#include "tls-private.h"
+#include "random.h"
+
+/* Implementation-specific max Record Layer fragment size (must be < 16kB)=
 */
+#define TX_RECORD_MAX_LEN	4096
+
+/* TLSPlaintext + TLSCompressed + TLSCiphertext headers + seq_num sizes */
+#define TX_RECORD_MAX_HEADERS	(5 + 5 + 8 + 5)
+#define TX_RECORD_MAX_MAC	64
+
+/* Head room and tail room for the buffer passed to the cipher */
+#define TX_RECORD_HEADROOM	TX_RECORD_MAX_HEADERS
+#define TX_RECORD_TAILROOM	TX_RECORD_MAX_MAC
+
+static void tls_write_mac(struct l_tls *tls, uint8_t *compressed,
+				uint16_t compressed_len, uint8_t *out_buf,
+				bool txrx)
+{
+	uint8_t *in_buf;
+
+	/* Prepend the sequence number to the TLSCompressed buffer */
+	in_buf =3D compressed - 8;
+	l_put_be64(tls->seq_num[txrx]++, in_buf);
+
+	if (tls->mac[txrx]) {
+		l_checksum_reset(tls->mac[txrx]);
+		l_checksum_update(tls->mac[txrx], in_buf, compressed_len + 8);
+		l_checksum_get_digest(tls->mac[txrx], out_buf,
+					tls->mac_length[txrx]);
+	}
+}
+
+static void tls_tx_record_plaintext(struct l_tls *tls,
+					uint8_t *plaintext,
+					uint16_t plaintext_len)
+{
+	uint8_t *compressed;
+	uint16_t compressed_len;
+	uint8_t *cipher_input;
+	uint16_t cipher_input_len;
+	uint8_t *ciphertext;
+	uint16_t ciphertext_len;
+	uint8_t padding_length;
+	uint8_t buf[TX_RECORD_HEADROOM + TX_RECORD_MAX_LEN +
+				TX_RECORD_TAILROOM];
+	int offset;
+
+	/*
+	 * TODO: if DEFLATE is selected in current state, use a new buffer
+	 * on stack to write a TLSCompressed structure there, otherwise use
+	 * the provided buffer.  Since only null compression is supported
+	 * today we always use the provided buffer.
+	 */
+	compressed_len =3D plaintext_len - 5;
+	compressed =3D plaintext;
+
+	/* Build a TLSCompressed struct */
+	compressed[0] =3D plaintext[0]; /* Copy type and version fields */
+	compressed[1] =3D plaintext[1];
+	compressed[2] =3D plaintext[2];
+	compressed[3] =3D compressed_len >> 8;
+	compressed[4] =3D compressed_len >> 0;
+
+	switch (tls->cipher_type[1]) {
+	case TLS_CIPHER_STREAM:
+		/* Append the MAC after TLSCompressed.fragment, if needed */
+		tls_write_mac(tls, compressed, compressed_len + 5,
+				compressed + compressed_len + 5, true);
+
+		cipher_input =3D compressed + 5;
+		cipher_input_len =3D compressed_len + tls->mac_length[1];
+
+		if (!tls->cipher[1]) {
+			ciphertext =3D cipher_input;
+			ciphertext_len =3D cipher_input_len;
+		} else {
+			ciphertext =3D buf + TX_RECORD_HEADROOM;
+			ciphertext_len =3D cipher_input_len;
+			l_cipher_encrypt(tls->cipher[1], cipher_input,
+						ciphertext, cipher_input_len);
+		}
+
+		break;
+
+	case TLS_CIPHER_BLOCK:
+		/* Append the MAC after TLSCompressed.fragment, if needed */
+		cipher_input =3D compressed + 5;
+		tls_write_mac(tls, compressed, compressed_len + 5,
+				cipher_input + compressed_len, true);
+		cipher_input_len =3D compressed_len + tls->mac_length[1];
+
+		/* Add minimum padding */
+		padding_length =3D (~cipher_input_len) &
+			(tls->block_length[1] - 1);
+		memset(cipher_input + cipher_input_len, padding_length,
+				padding_length + 1);
+		cipher_input_len +=3D padding_length + 1;
+
+		/* Generate an IV */
+		ciphertext =3D buf + TX_RECORD_HEADROOM;
+
+		offset =3D 0;
+
+		if (tls->negotiated_version >=3D TLS_V12) {
+			l_getrandom(ciphertext, tls->record_iv_length[1]);
+
+			l_cipher_set_iv(tls->cipher[1], ciphertext,
+					tls->record_iv_length[1], 1);
+
+			offset =3D tls->record_iv_length[1];
+		}
+
+		l_cipher_encrypt(tls->cipher[1], cipher_input,
+					ciphertext + offset, cipher_input_len);
+		ciphertext_len =3D offset + cipher_input_len;
+
+		break;
+
+	case TLS_CIPHER_AEAD:
+		/* No AEAD ciphers supported today */
+	default:
+		return;
+	}
+
+	/* Build a TLSCiphertext struct */
+	ciphertext -=3D 5;
+	ciphertext[0] =3D plaintext[0]; /* Copy type and version fields */
+	ciphertext[1] =3D plaintext[1];
+	ciphertext[2] =3D plaintext[2];
+	ciphertext[3] =3D ciphertext_len >> 8;
+	ciphertext[4] =3D ciphertext_len >> 0;
+
+	tls->tx(tls->user_data, ciphertext, ciphertext_len + 5);
+}
+
+void tls_tx_record(struct l_tls *tls, enum tls_content_type type,
+			const uint8_t *data, size_t len)
+{
+	uint8_t buf[TX_RECORD_HEADROOM + TX_RECORD_MAX_LEN +
+				TX_RECORD_TAILROOM];
+	uint8_t *fragment, *plaintext;
+	uint16_t fragment_len;
+
+	while (len) {
+		fragment =3D buf + TX_RECORD_HEADROOM;
+		fragment_len =3D len < TX_RECORD_MAX_LEN ?
+			len : TX_RECORD_MAX_LEN;
+
+		/* Build a TLSPlaintext struct */
+		plaintext =3D fragment - 5;
+		plaintext[0] =3D type;
+		plaintext[1] =3D (uint8_t) (TLS_VERSION >> 8);
+		plaintext[2] =3D (uint8_t) (TLS_VERSION >> 0);
+		plaintext[3] =3D fragment_len >> 8;
+		plaintext[4] =3D fragment_len >> 0;
+		memcpy(plaintext + 5, data, fragment_len);
+
+		tls_tx_record_plaintext(tls, plaintext, fragment_len + 5);
+
+		data +=3D fragment_len;
+		len -=3D fragment_len;
+	}
+}
+
+static bool tls_handle_plaintext(struct l_tls *tls, const uint8_t *plainte=
xt,
+					int len, uint8_t type, uint16_t version)
+{
+	int header_len, need_len;
+	int chunk_len;
+
+	uint32_t hs_len;
+
+	if (len > (1 << 14)) {
+		tls_disconnect(tls, TLS_ALERT_DECODE_ERROR, 0);
+
+		return false;
+	}
+
+	switch (type) {
+	case TLS_CT_CHANGE_CIPHER_SPEC:
+	case TLS_CT_APPLICATION_DATA:
+		return tls_handle_message(tls, plaintext, len, type, version);
+
+	/*
+	 * We need to perform input reassembly twice@different levels:
+	 * once to make sure we're handling complete TLSCiphertext messages,
+	 * in l_tls_handle_rx(), and again here so that the Alert and
+	 * Handshake message type handlers deal with complete messages.
+	 * This does not affect ChangeCipherSpec messages because they're
+	 * just a single byte and there are never more than one such message
+	 * in a row.  Similarly it doesn't affect application data because
+	 * the application is not guaranteed that message boundaries are
+	 * preserved in any way and we don't know its message lengths anyway.
+	 * It does affect Alert because these messages are 2 byte long and
+	 * could potentially be split over two TLSPlaintext messages but
+	 * there are never more than one Alert in a TLSPlaintext for the same
+	 * reason as with ChangeCipherSpec.  Handshake messages are the
+	 * most affected although the need to do the reassembly twice still
+	 * seems wasteful considering most of these messages are sent in
+	 * plaintext and TLSCiphertext maps to TLSPlaintext records.
+	 */
+	case TLS_CT_ALERT:
+	case TLS_CT_HANDSHAKE:
+		break;
+
+	default:
+		tls_disconnect(tls, TLS_ALERT_DECODE_ERROR, 0);
+
+		return false;
+	}
+
+	if (tls->message_buf_len && type !=3D tls->message_content_type) {
+		tls_disconnect(tls, TLS_ALERT_DECODE_ERROR, 0);
+
+		return false;
+	}
+	tls->message_content_type =3D type;
+
+	while (1) {
+		/* Do we have a full header in tls->message_buf? */
+		header_len =3D (type =3D=3D TLS_CT_ALERT) ? 2 : 4;
+		need_len =3D header_len;
+
+		if (tls->message_buf_len >=3D header_len) {
+			if (type =3D=3D TLS_CT_HANDSHAKE) {
+				hs_len =3D (tls->message_buf[1] << 16) |
+					(tls->message_buf[2] << 8) |
+					(tls->message_buf[3] << 0);
+				if (hs_len > (1 << 14)) {
+					tls_disconnect(tls,
+						TLS_ALERT_DECODE_ERROR, 0);
+
+					return false;
+				}
+
+				need_len +=3D hs_len;
+			}
+
+			/* Do we have a full structure? */
+			if (tls->message_buf_len =3D=3D need_len) {
+				if (!tls_handle_message(tls, tls->message_buf,
+							need_len, type,
+							version))
+					return false;
+
+				tls->message_buf_len =3D 0;
+
+				continue;
+			}
+
+			if (!len)
+				break;
+		}
+
+		/* Try to fill up tls->message_buf up to need_len */
+		if (tls->message_buf_max_len < need_len) {
+			tls->message_buf_max_len =3D need_len;
+			tls->message_buf =3D
+				l_realloc(tls->message_buf, need_len);
+		}
+
+		need_len -=3D tls->message_buf_len;
+		chunk_len =3D need_len;
+		if (len < chunk_len)
+			chunk_len =3D len;
+
+		memcpy(tls->message_buf + tls->message_buf_len, plaintext,
+				chunk_len);
+		tls->message_buf_len +=3D chunk_len;
+		plaintext +=3D chunk_len;
+		len -=3D chunk_len;
+
+		if (chunk_len < need_len)
+			break;
+	}
+
+	return true;
+}
+
+static bool tls_handle_ciphertext(struct l_tls *tls)
+{
+	uint8_t type;
+	uint16_t version;
+	uint16_t fragment_len;
+	uint8_t mac_buf[TX_RECORD_MAX_MAC], i, padding_len;
+	int cipher_output_len, error;
+	uint8_t *compressed;
+	int compressed_len;
+
+	type =3D tls->record_buf[0];
+	version =3D l_get_be16(tls->record_buf + 1);
+	fragment_len =3D l_get_be16(tls->record_buf + 3);
+
+	if (fragment_len > (1 << 14) + 2048) {
+		tls_disconnect(tls, TLS_ALERT_RECORD_OVERFLOW, 0);
+
+		return false;
+	}
+
+	if (version < TLS_MIN_VERSION || version > TLS_VERSION) {
+		tls_disconnect(tls, TLS_ALERT_PROTOCOL_VERSION, 0);
+
+		return false;
+	}
+
+	if (fragment_len < tls->mac_length[0]) {
+		tls_disconnect(tls, TLS_ALERT_DECODE_ERROR, 0);
+
+		return false;
+	}
+
+	compressed =3D alloca(8 + 5 + fragment_len);
+	/* Copy the type and version fields */
+	compressed[8] =3D type;
+	l_put_be16(version, compressed + 9);
+
+	switch (tls->cipher_type[0]) {
+	case TLS_CIPHER_STREAM:
+		cipher_output_len =3D fragment_len;
+		compressed_len =3D cipher_output_len - tls->mac_length[0];
+		l_put_be16(compressed_len, compressed + 11);
+
+		if (!tls->cipher[0])
+			memcpy(compressed + 13, tls->record_buf + 5,
+					cipher_output_len);
+		else if (!l_cipher_decrypt(tls->cipher[0], tls->record_buf + 5,
+						compressed + 13,
+						cipher_output_len)) {
+			tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR, 0);
+
+			return false;
+		}
+
+		/* Calculate the MAC if needed */
+		tls_write_mac(tls, compressed + 8, 5 + compressed_len,
+				mac_buf, false);
+
+		if (tls->mac_length && memcmp(mac_buf, compressed + 13 +
+					compressed_len, tls->mac_length[0])) {
+			tls_disconnect(tls, TLS_ALERT_BAD_RECORD_MAC, 0);
+
+			return false;
+		}
+
+		compressed +=3D 13;
+
+		break;
+
+	case TLS_CIPHER_BLOCK:
+		i =3D 0;
+		if (tls->negotiated_version >=3D TLS_V12)
+			i =3D tls->record_iv_length[0];
+
+		if (fragment_len <=3D tls->mac_length[0] + i) {
+			tls_disconnect(tls, TLS_ALERT_DECODE_ERROR, 0);
+
+			return false;
+		}
+
+		cipher_output_len =3D fragment_len - i;
+
+		if (cipher_output_len % tls->block_length[0] !=3D 0) {
+			tls_disconnect(tls, TLS_ALERT_BAD_RECORD_MAC, 0);
+
+			return false;
+		}
+
+		if (tls->negotiated_version >=3D TLS_V12)
+			if (!l_cipher_set_iv(tls->cipher[0],
+						tls->record_buf + 5,
+						tls->record_iv_length[0], 0)) {
+				tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR,
+						0);
+
+				return false;
+			}
+
+		if (!l_cipher_decrypt(tls->cipher[0], tls->record_buf + 5 + i,
+					compressed + 13, cipher_output_len)) {
+			tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR, 0);
+
+			return false;
+		}
+
+		padding_len =3D compressed[13 + cipher_output_len - 1];
+		error =3D 0;
+		if (padding_len + tls->mac_length[0] + 1 >=3D
+				(size_t) cipher_output_len) {
+			padding_len =3D 0;
+			error =3D 1;
+		}
+
+		compressed_len =3D cipher_output_len - 1 - padding_len -
+			tls->mac_length[0];
+		l_put_be16(compressed_len, compressed + 11);
+
+		for (i =3D 0; i < padding_len; i++)
+			if (compressed[13 + cipher_output_len - 1 -
+					padding_len + i] !=3D padding_len)
+				error =3D 1;
+
+		/* Calculate the MAC if needed */
+		tls_write_mac(tls, compressed + 8, 5 + compressed_len,
+				mac_buf, false);
+
+		if ((tls->mac_length[0] && memcmp(mac_buf, compressed + 13 +
+					compressed_len, tls->mac_length[0])) ||
+				error) {
+			tls_disconnect(tls, TLS_ALERT_BAD_RECORD_MAC, 0);
+
+			return false;
+		}
+
+		compressed +=3D 13;
+
+		break;
+
+	case TLS_CIPHER_AEAD:
+		/* No AEAD ciphers supported today */
+	default:
+		return false;
+	}
+
+	/* DEFLATE not supported so just pass on compressed / compressed_len */
+
+	return tls_handle_plaintext(tls, compressed, compressed_len,
+					type, version);
+}
+
+LIB_EXPORT void l_tls_handle_rx(struct l_tls *tls, const uint8_t *data,
+				size_t len)
+{
+	int need_len;
+	int chunk_len;
+
+	/* Reassemble TLSCiphertext structures from the received chunks */
+
+	while (1) {
+		/* Do we have a full header in tls->record_buf? */
+		if (tls->record_buf_len >=3D 5) {
+			need_len =3D 5 + l_get_be16(tls->record_buf + 3);
+
+			/* Do we have a full structure? */
+			if (tls->record_buf_len =3D=3D need_len) {
+				if (!tls_handle_ciphertext(tls))
+					return;
+
+				tls->record_buf_len =3D 0;
+				need_len =3D 5;
+			}
+
+			if (!len)
+				break;
+		} else
+			need_len =3D 5;
+
+		/* Try to fill up tls->record_buf up to need_len */
+		if (tls->record_buf_max_len < need_len) {
+			tls->record_buf_max_len =3D need_len;
+			tls->record_buf =3D l_realloc(tls->record_buf, need_len);
+		}
+
+		need_len -=3D tls->record_buf_len;
+		chunk_len =3D need_len;
+		if (len < (size_t) chunk_len)
+			chunk_len =3D len;
+
+		memcpy(tls->record_buf + tls->record_buf_len, data, chunk_len);
+		tls->record_buf_len +=3D chunk_len;
+		data +=3D chunk_len;
+		len -=3D chunk_len;
+
+		if (chunk_len < need_len)
+			break;
+	}
+}
diff --git a/ell/tls.c b/ell/tls.c
index 5b4fea9..312a42b 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -182,6 +182,39 @@ static void tls_reset_cipher_spec(struct l_tls *tls, b=
ool txrx)
 	tls_change_cipher_spec(tls, txrx);
 }
 =

+static void tls_send_alert(struct l_tls *tls, bool fatal,
+				enum l_tls_alert_desc alert_desc)
+{
+	uint8_t buf[2];
+
+	buf[0] =3D fatal ? 2 : 1;
+	buf[1] =3D alert_desc;
+
+	tls_tx_record(tls, TLS_CT_ALERT, buf, 2);
+}
+
+/*
+ * Callers make sure this is about the last function before returning
+ * from the stack frames up to the exported library call so that the
+ * user-supplied disconnected callback here is free to use l_tls_free
+ * for example.
+ */
+void tls_disconnect(struct l_tls *tls, enum l_tls_alert_desc desc,
+			enum l_tls_alert_desc local_desc)
+{
+	tls_send_alert(tls, true, desc);
+
+	tls_reset_handshake(tls);
+
+	tls_reset_cipher_spec(tls, 0);
+	tls_reset_cipher_spec(tls, 1);
+
+	tls->ready =3D false;
+
+	tls->disconnected(tls->user_data, local_desc ?: desc,
+				local_desc && !desc);
+}
+
 static struct tls_cipher_suite tls_cipher_suite_pref[] =3D {
 };
 =

@@ -320,6 +353,20 @@ LIB_EXPORT void l_tls_free(struct l_tls *tls)
 	l_free(tls);
 }
 =

+LIB_EXPORT void l_tls_write(struct l_tls *tls, const uint8_t *data, size_t=
 len)
+{
+	if (unlikely(!tls->ready)) {
+		return;
+	}
+
+	tls_tx_record(tls, TLS_CT_APPLICATION_DATA, data, len);
+}
+
+LIB_EXPORT void l_tls_close(struct l_tls *tls)
+{
+	tls_disconnect(tls, TLS_ALERT_CLOSE_NOTIFY, 0);
+}
+
 LIB_EXPORT void l_tls_set_cacert(struct l_tls *tls, const char *ca_cert_pa=
th)
 {
 	if (tls->ca_cert_path) {
diff --git a/ell/tls.h b/ell/tls.h
index 86c8521..af0ebe3 100644
--- a/ell/tls.h
+++ b/ell/tls.h
@@ -75,6 +75,15 @@ struct l_tls *l_tls_new(bool server, l_tls_write_cb_t ap=
p_data_handler,
 =

 void l_tls_free(struct l_tls *tls);
 =

+/* Properly disconnect a connected session */
+void l_tls_close(struct l_tls *tls);
+
+/* Submit plaintext data to be encrypted and transmitted */
+void l_tls_write(struct l_tls *tls, const uint8_t *data, size_t len);
+
+/* Submit TLS payload from underlying transport to be decrypted */
+void l_tls_handle_rx(struct l_tls *tls, const uint8_t *data, size_t len);
+
 /* If peer is to be authenticated, supply the CA certificate */
 void l_tls_set_cacert(struct l_tls *tls, const char *ca_cert_path);
 =

-- =

2.1.4


--===============8503755159416523704==--

