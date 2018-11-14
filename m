Content-Type: multipart/mixed; boundary="===============7841255165023845113=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 05/12] tls: Add AEAD cipher support
Date: Wed, 14 Nov 2018 14:18:55 +0100
Message-ID: <20181114131902.1695-5-andrew.zaborowski@intel.com>
In-Reply-To: <20181114131902.1695-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7841255165023845113==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/tls-private.h | 15 +++++++--
 ell/tls-record.c  | 82 +++++++++++++++++++++++++++++++++++++++++++++--
 ell/tls.c         | 65 ++++++++++++++++++++++++++++++-------
 3 files changed, 147 insertions(+), 15 deletions(-)

diff --git a/ell/tls-private.h b/ell/tls-private.h
index 4f680a0..a562846 100644
--- a/ell/tls-private.h
+++ b/ell/tls-private.h
@@ -38,10 +38,15 @@ enum tls_cipher_type {
 =

 struct tls_bulk_encryption_algorithm {
 	enum tls_cipher_type cipher_type;
-	enum l_cipher_type l_id;
+	union {
+		enum l_cipher_type l_id;
+		enum l_aead_cipher_type l_aead_id;
+	};
 	size_t key_length;
 	size_t iv_length;
+	size_t fixed_iv_length;
 	size_t block_length;
+	size_t auth_tag_length;
 };
 =

 struct tls_hash_algorithm {
@@ -192,11 +197,17 @@ struct l_tls {
 =

 	enum tls_cipher_type cipher_type[2];
 	struct tls_cipher_suite *cipher_suite[2];
-	struct l_cipher *cipher[2];
+	union {
+		struct l_cipher *cipher[2];
+		struct l_aead_cipher *aead_cipher[2];
+	};
 	struct l_checksum *mac[2];
 	size_t mac_length[2];
 	size_t block_length[2];
 	size_t record_iv_length[2];
+	size_t fixed_iv_length[2];
+	uint8_t fixed_iv[2][32];
+	size_t auth_tag_length[2];
 	uint64_t seq_num[2];
 	/*
 	 * Some of the key and IV parts of the "current" state are kept
diff --git a/ell/tls-record.c b/ell/tls-record.c
index 8038049..a8ff696 100644
--- a/ell/tls-record.c
+++ b/ell/tls-record.c
@@ -75,6 +75,7 @@ static void tls_tx_record_plaintext(struct l_tls *tls,
 	uint8_t buf[TX_RECORD_HEADROOM + TX_RECORD_MAX_LEN +
 				TX_RECORD_TAILROOM];
 	uint8_t iv[32];
+	uint8_t *assocdata;
 	int offset;
 =

 	/*
@@ -156,7 +157,49 @@ static void tls_tx_record_plaintext(struct l_tls *tls,
 		break;
 =

 	case TLS_CIPHER_AEAD:
-		/* No AEAD ciphers supported today */
+		/* Prepend seq_num to TLSCompressed.type + .version + .length */
+		assocdata =3D compressed - 8;
+		l_put_be64(tls->seq_num[1]++, assocdata);
+
+		cipher_input =3D compressed + 5;
+		cipher_input_len =3D compressed_len;
+
+		/*
+		 * Build the IV.  The explicit part generation method is
+		 * actually cipher suite-specific but our only AEAD cipher
+		 * suites only require this part to be unique for each
+		 * record.  For future suites there may need to be a callback
+		 * that generates the per-record IV or an enum for the suite
+		 * to select one of a few IV types.
+		 *
+		 * Note kernel's rfc4106(gcm(...)) algorithm could potentially
+		 * be used to build the IV.
+		 */
+		memcpy(iv, tls->fixed_iv[1], tls->fixed_iv_length[1]);
+		l_put_le64(tls->seq_num[1], iv + tls->fixed_iv_length[1]);
+
+		if (tls->record_iv_length[1] > 8)
+			memset(iv + tls->fixed_iv_length[1] + 8, 42,
+				tls->record_iv_length[1] - 8);
+
+		/* Build the GenericAEADCipher struct */
+		ciphertext =3D buf + TX_RECORD_HEADROOM;
+		memcpy(ciphertext, iv + tls->fixed_iv_length[1],
+			tls->record_iv_length[1]);
+		l_aead_cipher_encrypt(tls->aead_cipher[1],
+					cipher_input, cipher_input_len,
+					assocdata, 13,
+					iv, tls->fixed_iv_length[1] +
+					tls->record_iv_length[1],
+					ciphertext + tls->record_iv_length[1],
+					cipher_input_len +
+					tls->auth_tag_length[1]);
+
+		ciphertext_len =3D tls->record_iv_length[1] +
+			cipher_input_len + tls->auth_tag_length[1];
+
+		break;
+
 	default:
 		return;
 	}
@@ -332,6 +375,7 @@ static bool tls_handle_ciphertext(struct l_tls *tls)
 	uint8_t *compressed;
 	int compressed_len;
 	uint8_t iv[32];
+	uint8_t *assocdata;
 =

 	type =3D tls->record_buf[0];
 	version =3D l_get_be16(tls->record_buf + 1);
@@ -496,7 +540,41 @@ static bool tls_handle_ciphertext(struct l_tls *tls)
 		break;
 =

 	case TLS_CIPHER_AEAD:
-		/* No AEAD ciphers supported today */
+		if (fragment_len <=3D tls->record_iv_length[0] +
+				tls->auth_tag_length[0]) {
+			TLS_DISCONNECT(TLS_ALERT_DECODE_ERROR, 0,
+					"Record fragment too short: %u",
+					fragment_len);
+			return false;
+		}
+
+		compressed_len =3D fragment_len - tls->record_iv_length[0] -
+			tls->auth_tag_length[0];
+		l_put_be16(compressed_len, compressed + 11);
+
+		/* Prepend seq_num to TLSCompressed.type + .version + .length */
+		assocdata =3D compressed;
+		l_put_be64(tls->seq_num[0]++, assocdata);
+		compressed +=3D 13;
+
+		/* Build the IV */
+		memcpy(iv, tls->fixed_iv[0], tls->fixed_iv_length[0]);
+		memcpy(iv + tls->fixed_iv_length[0], tls->record_buf + 5,
+			tls->record_iv_length[0]);
+
+		if (!l_aead_cipher_decrypt(tls->aead_cipher[0],
+				tls->record_buf + 5 + tls->record_iv_length[0],
+				fragment_len - tls->record_iv_length[0],
+				assocdata, 13, iv, tls->fixed_iv_length[0] +
+				tls->record_iv_length[0],
+				compressed, compressed_len)) {
+			TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
+					"Decrypting record fragment failed");
+			return false;
+		}
+
+		break;
+
 	default:
 		return false;
 	}
diff --git a/ell/tls.c b/ell/tls.c
index 9dc97ff..fd26306 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -206,12 +206,20 @@ static bool tls_change_cipher_spec(struct l_tls *tls,=
 bool txrx,
 	int key_offset;
 	static char error_buf[200];
 =

-	if (tls->cipher[txrx]) {
-		l_cipher_free(tls->cipher[txrx]);
-		tls->cipher[txrx] =3D NULL;
-		tls->cipher_type[txrx] =3D TLS_CIPHER_STREAM;
+	if (tls->cipher_type[txrx] =3D=3D TLS_CIPHER_AEAD) {
+		if (tls->aead_cipher[txrx]) {
+			l_aead_cipher_free(tls->aead_cipher[txrx]);
+			tls->aead_cipher[txrx] =3D NULL;
+		}
+	} else {
+		if (tls->cipher[txrx]) {
+			l_cipher_free(tls->cipher[txrx]);
+			tls->cipher[txrx] =3D NULL;
+		}
 	}
 =

+	tls->cipher_type[txrx] =3D TLS_CIPHER_STREAM;
+
 	if (tls->mac[txrx]) {
 		l_checksum_free(tls->mac[txrx]);
 		tls->mac[txrx] =3D NULL;
@@ -221,6 +229,12 @@ static bool tls_change_cipher_spec(struct l_tls *tls, =
bool txrx,
 	tls->block_length[txrx] =3D 0;
 	tls->record_iv_length[txrx] =3D 0;
 =

+	if (tls->fixed_iv_length[txrx]) {
+		memset(tls->fixed_iv[txrx], 0, tls->fixed_iv_length[txrx]);
+		tls->fixed_iv_length[txrx] =3D 0;
+	}
+
+	tls->auth_tag_length[txrx] =3D 0;
 	tls->seq_num[txrx] =3D 0;
 =

 	tls->cipher_suite[txrx] =3D tls->pending.cipher_suite;
@@ -261,20 +275,31 @@ static bool tls_change_cipher_spec(struct l_tls *tls,=
 bool txrx,
 	}
 =

 	if (tls->cipher_suite[txrx]->encryption) {
+		void *cipher;
+
 		enc =3D tls->cipher_suite[txrx]->encryption;
 =

 		/* Server write / client read is 4th in the key block */
 		if ((tls->server && txrx) || (!tls->server && !txrx))
 			key_offset +=3D enc->key_length;
 =

-		tls->cipher[txrx] =3D l_cipher_new(enc->l_id,
+		if (enc->cipher_type =3D=3D TLS_CIPHER_AEAD) {
+			cipher =3D l_aead_cipher_new(enc->l_aead_id,
+						tls->pending.key_block +
+						key_offset, enc->key_length,
+						enc->auth_tag_length);
+			tls->aead_cipher[txrx] =3D cipher;
+		} else {
+			cipher =3D l_cipher_new(enc->l_id,
 						tls->pending.key_block +
 						key_offset, enc->key_length);
+			tls->cipher[txrx] =3D cipher;
+		}
 =

 		/* Wipe out the now unneeded part of the key block */
 		memset(tls->pending.key_block + key_offset, 0, enc->key_length);
 =

-		if (!tls->cipher[txrx]) {
+		if (!cipher) {
 			if (error) {
 				*error =3D error_buf;
 				snprintf(error_buf, sizeof(error_buf),
@@ -287,10 +312,10 @@ static bool tls_change_cipher_spec(struct l_tls *tls,=
 bool txrx,
 		}
 =

 		tls->cipher_type[txrx] =3D enc->cipher_type;
-		if (enc->cipher_type =3D=3D TLS_CIPHER_BLOCK) {
-			tls->record_iv_length[txrx] =3D enc->iv_length;
-			tls->block_length[txrx] =3D enc->block_length;
-		}
+		tls->record_iv_length[txrx] =3D enc->iv_length -
+			enc->fixed_iv_length;
+		tls->block_length[txrx] =3D enc->block_length;
+		tls->auth_tag_length[txrx] =3D enc->auth_tag_length;
 =

 		if ((tls->server && txrx) || (!tls->server && !txrx))
 			key_offset +=3D enc->key_length;
@@ -313,6 +338,21 @@ static bool tls_change_cipher_spec(struct l_tls *tls, =
bool txrx,
 =

 		/* Wipe out the now unneeded part of the key block */
 		memset(tls->pending.key_block + key_offset, 0, enc->iv_length);
+	} else if (tls->cipher_suite[txrx]->encryption &&
+			tls->cipher_suite[txrx]->encryption->fixed_iv_length) {
+		enc =3D tls->cipher_suite[txrx]->encryption;
+
+		/* Server write / client read is 6th in the key block */
+		if ((tls->server && txrx) || (!tls->server && !txrx))
+			key_offset +=3D enc->fixed_iv_length;
+
+		tls->fixed_iv_length[txrx] =3D enc->fixed_iv_length;
+		memcpy(tls->fixed_iv[txrx], tls->pending.key_block + key_offset,
+			enc->fixed_iv_length);
+
+		/* Wipe out the now unneeded part of the key block */
+		memset(tls->pending.key_block + key_offset, 0,
+			enc->fixed_iv_length);
 	}
 =

 	return true;
@@ -940,7 +980,10 @@ static void tls_generate_master_secret(struct l_tls *t=
ls,
 			TLS_CIPHER_BLOCK)
 		key_block_size +=3D 2 *
 			tls->pending.cipher_suite->encryption->iv_length;
-	/* Note: 2x fixed_IV_length also needed for AEAD ciphers */
+
+	if (tls->pending.cipher_suite->encryption)
+		key_block_size +=3D 2 * tls->pending.cipher_suite->encryption->
+			fixed_iv_length;
 =

 	/* Reverse order from the master secret seed */
 	memcpy(seed +  0, tls->pending.server_random, 32);
-- =

2.19.1


--===============7841255165023845113==--

