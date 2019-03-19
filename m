Content-Type: multipart/mixed; boundary="===============0656904264532174026=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 4/4] all: Replace uses of memset with explicit_bzero
Date: Tue, 19 Mar 2019 01:48:43 +0100
Message-ID: <20190319004843.13451-4-andrew.zaborowski@intel.com>
In-Reply-To: <20190319004843.13451-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0656904264532174026==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Replace existing uses of memset to clear secrets with explicit_bzero to
make sure it doesn't get optimized out.  This has some side effects as
documented in gcc docs though but seems to be the recommended anyway.
---
 ell/key.c        |  4 ++--
 ell/pem.c        |  4 ++--
 ell/settings.c   |  2 +-
 ell/tls-suites.c | 14 +++++++-------
 ell/tls.c        | 27 +++++++++++++++------------
 5 files changed, 27 insertions(+), 24 deletions(-)

diff --git a/ell/key.c b/ell/key.c
index ce4fbad..ed9941d 100644
--- a/ell/key.c
+++ b/ell/key.c
@@ -366,7 +366,7 @@ LIB_EXPORT bool l_key_extract(struct l_key *key, void *=
payload, size_t *len)
 	keylen =3D kernel_read_key(key->serial, payload, *len);
 =

 	if (keylen < 0 || (size_t)keylen > *len) {
-		memset(payload, 0, *len);
+		explicit_bzero(payload, *len);
 		return false;
 	}
 =

@@ -482,7 +482,7 @@ LIB_EXPORT struct l_key *l_key_generate_dh_private(cons=
t void *prime_buf,
 	buf[0] |=3D 1 << ((prime_bits - 2) % 8);
 =

 	private =3D l_key_new(L_KEY_RAW, buf, private_bytes);
-	memset(buf, 0, private_bytes);
+	explicit_bzero(buf, private_bytes);
 	l_free(buf);
 	return private;
 }
diff --git a/ell/pem.c b/ell/pem.c
index 4a91bb3..63b28ec 100644
--- a/ell/pem.c
+++ b/ell/pem.c
@@ -405,7 +405,7 @@ LIB_EXPORT struct l_key *l_pem_load_private_key(const c=
har *filename,
 		}
 =

 		l_cipher_free(alg);
-		memset(content, 0, len);
+		explicit_bzero(content, len);
 		l_free(content);
 		content =3D decrypted;
 		len =3D data_len;
@@ -443,7 +443,7 @@ done:
 =

 err:
 	if (content) {
-		memset(content, 0, len);
+		explicit_bzero(content, len);
 		l_free(content);
 	}
 =

diff --git a/ell/settings.c b/ell/settings.c
index 3b79431..7de344f 100644
--- a/ell/settings.c
+++ b/ell/settings.c
@@ -68,7 +68,7 @@ static void setting_destroy(void *data)
 	struct setting_data *pair =3D data;
 =

 	l_free(pair->key);
-	memset(pair->value, 0, strlen(pair->value));
+	explicit_bzero(pair->value, strlen(pair->value));
 	l_free(pair->value);
 	l_free(pair);
 }
diff --git a/ell/tls-suites.c b/ell/tls-suites.c
index 18ac366..0eb602a 100644
--- a/ell/tls-suites.c
+++ b/ell/tls-suites.c
@@ -265,7 +265,7 @@ static bool tls_send_rsa_client_key_xchg(struct l_tls *=
tls)
 	tls_tx_handshake(tls, TLS_CLIENT_KEY_EXCHANGE, buf, ptr - buf);
 =

 	tls_generate_master_secret(tls, pre_master_secret, 48);
-	memset(pre_master_secret, 0, 48);
+	explicit_bzero(pre_master_secret, 48);
 =

 	return true;
 }
@@ -329,8 +329,8 @@ static void tls_handle_rsa_client_key_xchg(struct l_tls=
 *tls,
 	}
 =

 	tls_generate_master_secret(tls, pre_master_secret, 48);
-	memset(pre_master_secret, 0, 48);
-	memset(random_secret, 0, 46);
+	explicit_bzero(pre_master_secret, 48);
+	explicit_bzero(random_secret, 46);
 }
 =

 static struct tls_key_exchange_algorithm tls_rsa_key_xchg =3D {
@@ -619,7 +619,7 @@ static bool tls_send_ecdhe_client_key_xchg(struct l_tls=
 *tls)
 =

 	tls_generate_master_secret(tls, pre_master_secret,
 					pre_master_secret_len);
-	memset(pre_master_secret, 0, pre_master_secret_len);
+	explicit_bzero(pre_master_secret, pre_master_secret_len);
 =

 	return true;
 }
@@ -694,7 +694,7 @@ static void tls_handle_ecdhe_client_key_xchg(struct l_t=
ls *tls,
 =

 	tls_generate_master_secret(tls, pre_master_secret,
 					pre_master_secret_len);
-	memset(pre_master_secret, 0, pre_master_secret_len);
+	explicit_bzero(pre_master_secret, pre_master_secret_len);
 =

 	return;
 =

@@ -1014,7 +1014,7 @@ static bool tls_send_dhe_client_key_xchg(struct l_tls=
 *tls)
 	tls_free_dhe_params(tls);
 	tls_generate_master_secret(tls, pre_master_secret + zeros,
 					pre_master_secret_len - zeros);
-	memset(pre_master_secret, 0, pre_master_secret_len);
+	explicit_bzero(pre_master_secret, pre_master_secret_len);
 	return true;
 }
 =

@@ -1074,7 +1074,7 @@ static void tls_handle_dhe_client_key_xchg(struct l_t=
ls *tls,
 	tls_free_dhe_params(tls);
 	tls_generate_master_secret(tls, pre_master_secret + zeros,
 					pre_master_secret_len - zeros);
-	memset(pre_master_secret, 0, pre_master_secret_len);
+	explicit_bzero(pre_master_secret, pre_master_secret_len);
 	return;
 =

 decode_error:
diff --git a/ell/tls.c b/ell/tls.c
index 8aa58d5..e910ad1 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -154,7 +154,7 @@ LIB_EXPORT bool l_tls_prf_get_bytes(struct l_tls *tls, =
bool use_master_secret,
 	else
 		r =3D tls_prf_get_bytes(tls, "", 0, label, seed, 64, buf, len);
 =

-	memset(seed, 0, 64);
+	explicit_bzero(seed, 64);
 =

 	return r;
 }
@@ -180,7 +180,7 @@ static void tls_reset_handshake(struct l_tls *tls)
 {
 	enum handshake_hash_type hash;
 =

-	memset(tls->pending.key_block, 0, sizeof(tls->pending.key_block));
+	explicit_bzero(tls->pending.key_block, sizeof(tls->pending.key_block));
 =

 	if (tls->pending.cipher_suite &&
 			tls->pending.cipher_suite->key_xchg->free_params)
@@ -205,9 +205,9 @@ static void tls_reset_handshake(struct l_tls *tls)
 =

 static void tls_cleanup_handshake(struct l_tls *tls)
 {
-	memset(tls->pending.client_random, 0, 32);
-	memset(tls->pending.server_random, 0, 32);
-	memset(tls->pending.master_secret, 0, 48);
+	explicit_bzero(tls->pending.client_random, 32);
+	explicit_bzero(tls->pending.server_random, 32);
+	explicit_bzero(tls->pending.master_secret, 48);
 }
 =

 static bool tls_change_cipher_spec(struct l_tls *tls, bool txrx,
@@ -242,7 +242,7 @@ static bool tls_change_cipher_spec(struct l_tls *tls, b=
ool txrx,
 	tls->record_iv_length[txrx] =3D 0;
 =

 	if (tls->fixed_iv_length[txrx]) {
-		memset(tls->fixed_iv[txrx], 0, tls->fixed_iv_length[txrx]);
+		explicit_bzero(tls->fixed_iv[txrx], tls->fixed_iv_length[txrx]);
 		tls->fixed_iv_length[txrx] =3D 0;
 	}
 =

@@ -267,7 +267,8 @@ static bool tls_change_cipher_spec(struct l_tls *tls, b=
ool txrx,
 						key_offset, mac->mac_length);
 =

 		/* Wipe out the now unneeded part of the key block */
-		memset(tls->pending.key_block + key_offset, 0, mac->mac_length);
+		explicit_bzero(tls->pending.key_block + key_offset,
+				mac->mac_length);
 =

 		if (!tls->mac[txrx]) {
 			if (error) {
@@ -309,7 +310,8 @@ static bool tls_change_cipher_spec(struct l_tls *tls, b=
ool txrx,
 		}
 =

 		/* Wipe out the now unneeded part of the key block */
-		memset(tls->pending.key_block + key_offset, 0, enc->key_length);
+		explicit_bzero(tls->pending.key_block + key_offset,
+				enc->key_length);
 =

 		if (!cipher) {
 			if (error) {
@@ -349,7 +351,8 @@ static bool tls_change_cipher_spec(struct l_tls *tls, b=
ool txrx,
 				key_offset, enc->iv_length);
 =

 		/* Wipe out the now unneeded part of the key block */
-		memset(tls->pending.key_block + key_offset, 0, enc->iv_length);
+		explicit_bzero(tls->pending.key_block + key_offset,
+				enc->iv_length);
 	} else if (tls->cipher_suite[txrx]->encryption &&
 			tls->cipher_suite[txrx]->encryption->fixed_iv_length) {
 		enc =3D tls->cipher_suite[txrx]->encryption;
@@ -363,8 +366,8 @@ static bool tls_change_cipher_spec(struct l_tls *tls, b=
ool txrx,
 			enc->fixed_iv_length);
 =

 		/* Wipe out the now unneeded part of the key block */
-		memset(tls->pending.key_block + key_offset, 0,
-			enc->fixed_iv_length);
+		explicit_bzero(tls->pending.key_block + key_offset,
+				enc->fixed_iv_length);
 	}
 =

 	return true;
@@ -1111,7 +1114,7 @@ void tls_generate_master_secret(struct l_tls *tls,
 				"key expansion", seed, 64,
 				tls->pending.key_block, key_block_size);
 =

-	memset(seed, 0, 64);
+	explicit_bzero(seed, 64);
 }
 =

 static void tls_get_handshake_hash(struct l_tls *tls,
-- =

2.19.1


--===============0656904264532174026==--

